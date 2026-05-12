*&---------------------------------------------------------------------*
*& Include          /THKR/QS_AIF_ALV_CL
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:    Frank Brähler (Orexes GmbH) (ZHM000000307)                *
*& Erstellt am: 06.05.2025                                             *
*&                                                                     *
*& l. Änderer : Frank Brähler (ZHM000000307)                           *
*& l. Datum   : 19.06.2025                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& ALV-Class - Inlcude für /THKR/QS_AIF_T_FMAP                         *
*&                                                                     *
*& CLASS für ALV innerhalb Programm                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Änderungshistorie:                                                  *
*& Datum    Änderer      Beschreibung                                  *
*& -------- ------------ --------------------------------------------- *
*& 20250506 ZHM000000307 Anlage des Reports                            *
*& 20250619 ZHM000000307 Erweiterung der Ausgabe im ALV                *
*&                                                                     *
*&---------------------------------------------------------------------*

CLASS lcl_alvgridcontainer DEFINITION.
  PUBLIC SECTION.

    TYPES: BEGIN OF ty_alv_cont,
             r_dccont   TYPE REF TO cl_gui_docking_container,
             r_dbcont   TYPE REF TO cl_gui_dialogbox_container,
             r_grid     TYPE REF TO cl_gui_alv_grid,
             title      TYPE lvc_title,
             strucnam   TYPE tabname,
             layout     TYPE lvc_s_layo,
             variant    TYPE disvariant,
             t_fieldcat TYPE lvc_t_fcat,
             t_sort     TYPE lvc_t_sort,
             t_filter   TYPE lvc_t_filt,
             t_excl_f   TYPE ui_functions,
             okcode     TYPE syst_ucomm,
             dynnr      TYPE sydynnr,
             r_outtab   TYPE REF TO data,
           END OF ty_alv_cont.

    METHODS:
      create_grid,
      update_grid.

    DATA: alvscreen TYPE ty_alv_cont,
          ok_code   TYPE syst_ucomm.

  PRIVATE SECTION.
    METHODS:
      set_fcat,
      create_container,
      handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column.
ENDCLASS.

DATA: ref_alv      TYPE REF TO lcl_alvgridcontainer,
      ref_alv_0200 TYPE REF TO lcl_alvgridcontainer.

CLASS lcl_alvgridcontainer IMPLEMENTATION.
  METHOD create_container.
    IF me->alvscreen-r_dccont IS INITIAL.
      CREATE OBJECT me->alvscreen-r_dccont
        EXPORTING
          repid                       = sy-repid
          dynnr                       = me->alvscreen-dynnr
          extension                   = 2000
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5
          OTHERS                      = 6.
      IF 0 <> sy-subrc.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD create_grid.
    IF me->alvscreen-r_grid IS INITIAL.
      create_container( ).
      CREATE OBJECT me->alvscreen-r_grid
        EXPORTING
          i_parent          = me->alvscreen-r_dccont
          i_appl_events     = abap_true
        EXCEPTIONS
          error_cntl_create = 1
          error_cntl_init   = 2
          error_cntl_link   = 3
          error_dp_create   = 4
          OTHERS            = 5.

      IF 0 <> sy-subrc.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      me->set_fcat( ).
      me->alvscreen-layout-sel_mode   = 'B'.
      me->alvscreen-layout-cwidth_opt = 'X'.

      IF me->alvscreen-dynnr EQ '0100'.
        SET HANDLER handle_double_click FOR me->alvscreen-r_grid.
        CALL METHOD me->alvscreen-r_grid->set_table_for_first_display
          EXPORTING
            is_layout                     = me->alvscreen-layout
            i_structure_name              = me->alvscreen-strucnam
            i_save                        = 'A'
            i_default                     = 'X'
          CHANGING
            it_outtab                     = gt_alv_t_fmap
            it_fieldcatalog               = me->alvscreen-t_fieldcat
          EXCEPTIONS
            invalid_parameter_combination = 1
            program_error                 = 2
            too_many_lines                = 3
            OTHERS                        = 4.
        IF 0 <> sy-subrc.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

      IF me->alvscreen-dynnr EQ '0200'.
        CALL METHOD me->alvscreen-r_grid->set_table_for_first_display
          EXPORTING
            is_layout                     = me->alvscreen-layout
            i_structure_name              = me->alvscreen-strucnam
            i_save                        = 'A'
            i_default                     = 'X'
            i_bypassing_buffer            = 'X'
            i_buffer_active               = space
          CHANGING
            it_outtab                     = gt_alv_t_fmap_sst
            it_fieldcatalog               = me->alvscreen-t_fieldcat
          EXCEPTIONS
            invalid_parameter_combination = 1
            program_error                 = 2
            too_many_lines                = 3
            OTHERS                        = 4.
        IF 0 <> sy-subrc.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD update_grid.
    alvscreen-r_grid->refresh_table_display( ).
  ENDMETHOD.

  METHOD set_fcat.
    DATA: ltext TYPE string.

    FIELD-SYMBOLS: <fs_fc> TYPE lvc_s_fcat.

************************************************************************
*   Feldkatalog uas DB-Tabelle / Struktur lesen                        *
************************************************************************
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name   = me->alvscreen-strucnam "
        i_bypassing_buffer = 'X'
      CHANGING
        ct_fieldcat        = alvscreen-t_fieldcat.

************************************************************************
*   Feldkatalog bereinigen für die Ausgabe festlegen                   *
************************************************************************
    DELETE me->alvscreen-t_fieldcat WHERE fieldname EQ 'MANDT'.
    IF me->alvscreen-dynnr EQ '0100'.
      DELETE me->alvscreen-t_fieldcat WHERE fieldname EQ 'IFNAME'.
      DELETE me->alvscreen-t_fieldcat WHERE fieldname EQ 'IFVERSION'.
      DELETE me->alvscreen-t_fieldcat WHERE fieldname EQ 'SMAPNR'.
    ENDIF.

    IF pa_coll IS INITIAL.
      DELETE me->alvscreen-t_fieldcat WHERE fieldname EQ 'ANZHL'.
    ENDIF.

************************************************************************
*   Scleife über den Feldkatalog                                       *
************************************************************************
    LOOP AT me->alvscreen-t_fieldcat ASSIGNING <fs_fc>.
      <fs_fc>-no_zero    = 'X'.
      <fs_fc>-no_sign    = 'X'.
      <fs_fc>-col_opt    = 'X'.
      <fs_fc>-key        = space.
      <fs_fc>-key_sel    = space.
      <fs_fc>-emphasize  = space.
      <fs_fc>-fix_column = space.

      IF <fs_fc>-fieldname EQ 'LFD_NR'    OR
         <fs_fc>-fieldname EQ 'NS'        OR
         <fs_fc>-fieldname EQ 'FIELDNAME' OR
         <fs_fc>-fieldname EQ 'RECTYPE'.
        <fs_fc>-key     = 'X'.
        <fs_fc>-key_sel = 'X'.
      ENDIF.

      IF <fs_fc>-fieldname EQ 'ANZHL'.
        <fs_fc>-col_pos = 4.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD handle_double_click.
    DATA: lv_lfdnr TYPE /thkr/lfd_nr_6.
    READ TABLE gt_alv_t_fmap ASSIGNING FIELD-SYMBOL(<fs_row>) INDEX e_row-index.
    IF 0 EQ sy-subrc.
      CLEAR: gt_alv_t_fmap_sst[], gt_tmp_t_fmap_sst[].
      SELECT * FROM /aif/t_fmap INTO TABLE gt_tmp_t_fmap_sst
             WHERE ns               EQ <fs_row>-ns
             AND   fieldname        EQ <fs_row>-fieldname
             AND   rectype          EQ <fs_row>-rectype
             AND   sap_fieldname1   EQ <fs_row>-sap_fieldname1
             AND   sap_fieldname2   EQ <fs_row>-sap_fieldname2
             AND   sap_fieldname3   EQ <fs_row>-sap_fieldname3
             AND   sap_fieldname4   EQ <fs_row>-sap_fieldname4
             AND   sap_fieldname5   EQ <fs_row>-sap_fieldname5
             AND   fieldname_link   EQ <fs_row>-fieldname_link
             AND   convdtel         EQ <fs_row>-convdtel
             AND   convexit         EQ <fs_row>-convexit
             AND   convexitdir      EQ <fs_row>-convexitdir
             AND   ns_vmapname      EQ <fs_row>-ns_vmapname
             AND   vmapname         EQ <fs_row>-vmapname
             AND   valmapfunction   EQ <fs_row>-valmapfunction
             AND   fieldoffset      EQ <fs_row>-fieldoffset
             AND   fieldlength      EQ <fs_row>-fieldlength
             AND   fieldoffset1     EQ <fs_row>-fieldoffset1
             AND   fieldlength1     EQ <fs_row>-fieldlength1
             AND   fieldoffset2     EQ <fs_row>-fieldoffset2
             AND   fieldlength2     EQ <fs_row>-fieldlength2
             AND   fieldoffset3     EQ <fs_row>-fieldoffset3
             AND   fieldlength3     EQ <fs_row>-fieldlength3
             AND   fieldoffset4     EQ <fs_row>-fieldoffset4
             AND   fieldlength4     EQ <fs_row>-fieldlength4
             AND   fieldoffset5     EQ <fs_row>-fieldoffset5
             AND   fieldlength5     EQ <fs_row>-fieldlength5
             AND   separatorstring  EQ <fs_row>-separatorstring
             AND   tabname          EQ <fs_row>-tabname
             AND   tabselfield      EQ <fs_row>-tabselfield
             AND   operator         EQ <fs_row>-operator
             AND   tabselcompfield  EQ <fs_row>-tabselcompfield
             AND   nstabselvalue    EQ <fs_row>-nstabselvalue
             AND   tabselvaluename  EQ <fs_row>-tabselvaluename
             AND   tabselvalue      EQ <fs_row>-tabselvalue
             AND   tabselformat     EQ <fs_row>-tabselformat
             AND   tabselfield2     EQ <fs_row>-tabselfield2
             AND   operator2        EQ <fs_row>-operator2
             AND   tabselcompfield2 EQ <fs_row>-tabselcompfield2
             AND   nstabselvalue2   EQ <fs_row>-nstabselvalue2
             AND   tabselvaluename2 EQ <fs_row>-tabselvaluename2
             AND   tabselvalue2     EQ <fs_row>-tabselvalue2
             AND   tabselformat2    EQ <fs_row>-tabselformat2
             AND   tabselfield3     EQ <fs_row>-tabselfield3
             AND   operator3        EQ <fs_row>-operator3
             AND   tabselcompfield3 EQ <fs_row>-tabselcompfield3
             AND   nstabselvalue3   EQ <fs_row>-nstabselvalue3
             AND   tabselvaluename3 EQ <fs_row>-tabselvaluename3
             AND   tabselvalue3     EQ <fs_row>-tabselvalue3
             AND   tabselformat3    EQ <fs_row>-tabselformat3
             AND   nscheck          EQ <fs_row>-nscheck
             AND   aifcheck         EQ <fs_row>-aifcheck
             AND   chkba            EQ <fs_row>-chkba
          ORDER BY ns ifname ifversion.

      CLEAR lv_lfdnr.
      LOOP AT gt_tmp_t_fmap_sst ASSIGNING  <gs_a>.
        ADD 1 TO lv_lfdnr.
        MOVE-CORRESPONDING <gs_a> TO gs_alv_t_fmap_sst.
        MOVE lv_lfdnr TO gs_alv_t_fmap_sst-lfd_nr.
        APPEND gs_alv_t_fmap_sst TO gt_alv_t_fmap_sst.
      ENDLOOP.

      IF gt_tmp_t_fmap_sst[] IS NOT INITIAL.
        CREATE OBJECT ref_alv_0200.
        ref_alv_0200->alvscreen-dynnr    = '0200'.
        ref_alv_0200->alvscreen-strucnam = '/THKR/S_ALV_T_AIF_T_FMAP'.
        CALL SCREEN 0200.
        IF ref_alv_0200->alvscreen-r_grid IS NOT INITIAL.
          ref_alv_0200->alvscreen-r_grid->free( ).
        ENDIF.
        IF ref_alv_0200->alvscreen-r_dbcont IS NOT INITIAL.
          ref_alv_0200->alvscreen-r_dbcont->free( ).
        ENDIF.
        IF ref_alv_0200->alvscreen-r_dccont IS NOT INITIAL.
          ref_alv_0200->alvscreen-r_dccont->free( ).
        ENDIF.
        FREE ref_alv_0200.
        cl_gui_cfw=>flush( ).
      ENDIF.
    ELSE.
      MESSAGE 'Fehler' TYPE 'W'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
