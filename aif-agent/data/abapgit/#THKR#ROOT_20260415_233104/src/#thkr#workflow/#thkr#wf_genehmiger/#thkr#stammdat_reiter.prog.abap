*&---------------------------------------------------------------------*
*& Include          /THKR/STAMMDAT_REITER
*&---------------------------------------------------------------------*


" Rollen ORg/Berecht + Atribute Range erstellen
ls_typ_ber-sign = 'I'.
ls_typ_ber-option = 'EQ'.
ls_typ_ber-high = ''.
ls_typ_org-sign = 'I'.
ls_typ_org-option = 'EQ'.
ls_typ_org-high = ''.

LOOP AT lt_tab_result_05xxl ASSIGNING FIELD-SYMBOL(<fs_ber_r>).
  IF <fs_ber_r>-typ_orgebene IS NOT INITIAL.
    ls_typ_org-low = <fs_ber_r>-typ_orgebene.
    APPEND ls_typ_org TO lt_typ_org.
  ELSEIF <fs_ber_r>-typ_berecht IS NOT INITIAL.
    ls_typ_ber-low = <fs_ber_r>-typ_berecht.
    APPEND ls_typ_ber TO lt_typ_ber.
  ENDIF.
ENDLOOP.


TRY.
    CREATE OBJECT lo_check_kompl.
  CATCH cx_sy_create_object_error INTO exc_ref.
    MESSAGE exc_ref->get_text( ) TYPE 'E'.
ENDTRY.

************************************************************************
*   Falls Typ nicht befüllt oder nicht 'O' oder 'S'  -> Fehlermeldung  *
************************************************************************
IF p_obj3 IS INITIAL OR ( p_obj3 NE 'O' AND p_obj3 NE 'S' ).
  MESSAGE 'Bitte geben Sie O oder S ein.' TYPE 'E' ##NO_TEXT.
ENDIF.

IF s_objid3 IS INITIAL.
  MESSAGE 'Bitte fügen Sie mindestens eine Objekt-ID ein.' TYPE 'E' ##NO_TEXT.
ENDIF.


" Einzelabfrage
IF p_par6 = 'X'.

  lv_nummer = 1.

  SELECT DISTINCT objid
         FROM hrp1000
         INTO @ls_selectopt_r3
         WHERE objid IN @s_objid3 AND otype = @p_obj3 AND plvar = '01'
         AND begda <=  @sy-datum  AND endda >= @sy-datum.
    APPEND ls_selectopt_r3 TO lt_selectopt_r3.
  ENDSELECT.


  LOOP AT lt_selectopt_r3 ASSIGNING FIELD-SYMBOL(<fs_objid_r3>).

    CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
      EXPORTING
        plvar            = '01'
        otype            = p_obj3
        objid            = <fs_objid_r3>
        scenario         = 'SSP'
        seldate          = sy-datum
      TABLES
        attrib_ext       = lt_attr_ext_r3
      EXCEPTIONS
        no_active_plvar  = 1
        no_attributes    = 2
        no_values        = 3
        object_not_found = 4
        OTHERS           = 5.

    LOOP AT lt_attr_ext_r3 ASSIGNING FIELD-SYMBOL(<fs_attr_r3>).
      ls_struc_attr-nummer     =  lv_nummer .
      ls_struc_attr-objekttyp  =  p_obj3.
      ls_struc_attr-objektid   =  <fs_objid_r3>.
      ls_struc_attr-attrib     =  <fs_attr_r3>-attrib.
      ls_struc_attr-low        =  <fs_attr_r3>-low.
      ls_struc_attr-high       =  <fs_attr_r3>-high.
      ls_struc_attr-excluded   =  <fs_attr_r3>-excluded.
      ls_struc_attr-defaultval =  <fs_attr_r3>-defaultval.
      ls_struc_attr-inherited  =  <fs_attr_r3>-inherited.
      ls_struc_attr-inherit    =  <fs_attr_r3>-inherit.
      ls_struc_attr-inh_otype  =  <fs_attr_r3>-inh_otype.
      ls_struc_attr-inh_objid  =  <fs_attr_r3>-inh_objid.


      SELECT SINGLE atext INTO @DATA(lv_atext_r3)
             FROM t77omattrt
             WHERE attrib = @<fs_attr_r3>-attrib AND langu = 'D' . "#EC CI_NOORDER´
      ls_struc_attr-atext = lv_atext_r3.
      CLEAR lv_atext_r3.

      APPEND ls_struc_attr TO lt_struc_attr_gesamt_erw_r3.
      CLEAR ls_struc_attr.
    ENDLOOP.


*--------------------------------------------------------------------*
*  13.07.2022 11:02:00  REPRO-KOE:  " Rollen-Zuständigkeite          *
*--------------------------------------------------------------------*
    /THKR/CL_CHECK_KOMPL=>get_agr_from_objid(
      EXPORTING
        iv_otype = p_obj3
        iv_objid = <fs_objid_r3>
      IMPORTING
        rt_agrs  = lt_agrs_r3 ).


    LOOP AT lt_agrs_r3 ASSIGNING FIELD-SYMBOL(<fs_agrs_r3>).

      SELECT SINGLE flag_value
        FROM agr_flags
        INTO @DATA(lv_sammel_agr)
        WHERE agr_name = @<fs_agrs_r3> AND flag_type = 'COLL_AGR'.

      IF lv_sammel_agr = 'X'.

        SELECT child_agr FROM agr_agrs WHERE agr_name = @<fs_agrs_r3>
                                       INTO TABLE @DATA(agr_child).

        LOOP AT agr_child ASSIGNING FIELD-SYMBOL(<fs_agr_child>).

          " Org_Ebene
          SELECT * FROM agr_1252
                   WHERE agr_name = @<fs_agr_child>-child_agr AND low NE '*' AND low NE ''
                   INTO TABLE @DATA(lt_org_ebene).

          MOVE-CORRESPONDING lt_org_ebene TO lt_org_data_tmp.
          LOOP AT lt_org_data_tmp ASSIGNING FIELD-SYMBOL(<org_data_tmp>).
            <org_data_tmp>-typ_rolle = <fs_agrs_r3>+0(2).
            <org_data_tmp>-rolle_nr  = <fs_agrs_r3>+2(2).
          ENDLOOP.

          APPEND LINES OF lt_org_data_tmp TO lt_org_data.
          CLEAR: lt_org_ebene, lt_org_data_tmp.


          "Berechtigungswerte
          CALL FUNCTION 'PRGN_1251_READ_FIELD_VALUES'
            EXPORTING
              activity_group = <fs_agr_child>-child_agr
            TABLES
              field_values   = lt_field_values_tmp_r3
            EXCEPTIONS
              OTHERS         = 0.

          DELETE lt_field_values_tmp_r3
                 WHERE NOT deleted IS INITIAL.           "#EC CI_STDSEQ

          MOVE-CORRESPONDING lt_field_values_tmp_r3 TO lt_field_values_end_r3_tmp.
          LOOP AT lt_field_values_end_r3_tmp ASSIGNING FIELD-SYMBOL(<fs_r3_tmp>).
            <fs_r3_tmp>-agr_name  = <fs_agr_child>-child_agr.
            <fs_r3_tmp>-typ_rolle = <fs_agrs_r3>+0(2).
            <fs_r3_tmp>-rolle_nr  = <fs_agrs_r3>+2(2).
          ENDLOOP.

          APPEND LINES OF lt_field_values_end_r3_tmp TO lt_field_values_end_r3.
          CLEAR: lt_field_values_tmp_r3, lt_field_values_end_r3_tmp.

        ENDLOOP.

      ELSE.

        " Org_Ebene
        SELECT * FROM agr_1252
                 WHERE agr_name = @<fs_agrs_r3> AND low NE '*' AND low NE ''
                 INTO TABLE @DATA(lt_org_ebene_f).

        MOVE-CORRESPONDING lt_org_ebene_f TO lt_org_data KEEPING TARGET LINES.
        CLEAR lt_org_ebene_f.

        SELECT SINGLE agr_name FROM agr_define WHERE agr_name = @<fs_agrs_r3> INTO @DATA(lv_agr_name_def).
        CHECK sy-subrc = 0 AND lv_agr_name_def IS NOT INITIAL.

        "Berechtigungswerte
        CALL FUNCTION 'PRGN_1251_READ_FIELD_VALUES'
          EXPORTING
            activity_group = lv_agr_name_def
          TABLES
            field_values   = lt_field_values_tmp_r3
          EXCEPTIONS
            OTHERS         = 0.

        DELETE lt_field_values_tmp_r3
               WHERE NOT deleted IS INITIAL.             "#EC CI_STDSEQ

        MOVE-CORRESPONDING lt_field_values_tmp_r3 TO lt_field_values_end_r3_tmp.
        LOOP AT lt_field_values_end_r3_tmp ASSIGNING FIELD-SYMBOL(<fs_r3_tmp_2>).
          <fs_r3_tmp_2>-agr_name  = <fs_agrs_r3>.
        ENDLOOP.
        APPEND LINES OF lt_field_values_end_r3_tmp TO lt_field_values_end_r3.
        CLEAR: lt_field_values_tmp_r3, lt_field_values_end_r3_tmp.

      ENDIF.
    ENDLOOP.


*--------------------------------------------------------------------*
*  13.07.2022 13:32:09  REPRO-KOE:  aus Ber-felder Typ der Berecht   *
*--------------------------------------------------------------------*
    /THKR/CL_CHECK_KOMPL=>get_typ_ber_from_agr_fields(
                        EXPORTING
                        it_02xxl    = lt_tab_result_02xxl
                        CHANGING
                        it_agr_1251 = lt_field_values_end_r3 ).


    ""Tabellen bereinigen von unnöt. Daten
    DELETE lt_org_data WHERE low EQ '*' OR low EQ '' OR low EQ '''' OR low EQ 'DUMMY'.
    DELETE lt_org_data WHERE low CS '*' OR low CS '$'.
    DELETE lt_org_data WHERE varbl NOT IN lt_typ_org.

    DELETE lt_field_values_end_r3 WHERE low EQ '*' OR
                                        low EQ 'DUMMY' OR
                                        low CS '*' OR
                                        low CS '$' OR
                                        low EQ ''''.
    DELETE lt_field_values_end_r3 WHERE typ_berecht NOT IN lt_typ_ber.

*--------------------------------------------------------------------*
*  13.07.2022 11:02:21  REPRO-KOE: Stammdaten prüfen - Attribute     *
*--------------------------------------------------------------------*


    /THKR/CL_CHECK_KOMPL=>check_attrib(
      EXPORTING
        it_tab_ur13c = lt_tab_result_13c
        it_tab_06xxl = lt_tab_result_06xxl
        it_t77omattot = lt_t77omattot
      CHANGING
        it_attrib     = lt_struc_attr_gesamt_erw_r3 ).


*--------------------------------------------------------------------*
*  13.07.2022 11:02:21  REPRO-KOE: Stammdaten prüfen - Ord_typ       *
*--------------------------------------------------------------------*
    /THKR/CL_CHECK_KOMPL=>check_org_data(
      EXPORTING
        iv_index      = lv_nummer
        iv_otype      = p_obj3
        iv_objid      = <fs_objid_r3>
        it_05xxl      =  lt_typ_org
        it_t77omattot =  lt_t77omattot
        it_org_data   =  lt_org_data
        it_ur13c      =  lt_tab_result_13c
      CHANGING
        it_attrib     =  lt_struc_attr_gesamt_erw_r3
    ).


*--------------------------------------------------------------------*
*  13.07.2022 11:02:21  REPRO-KOE: Stammdaten prüfen - Typ Ber       *
*--------------------------------------------------------------------*
    SORT lt_field_values_end_r3 BY typ_rolle rolle_nr agr_name typ_berecht field low.
    DELETE ADJACENT DUPLICATES FROM lt_field_values_end_r3
           COMPARING typ_rolle rolle_nr agr_name typ_berecht field low.

    /THKR/CL_CHECK_KOMPL=>check_ber_data(
      EXPORTING
        it_t77omattot = lt_t77omattot
        it_ur13c      = lt_tab_result_13c
        it_ber_data   = lt_field_values_end_r3
        it_02xxl      = lt_tab_result_02xxl
        iv_index      = lv_nummer
        iv_objid      = <fs_objid_r3>
        iv_otype      = p_obj3
      CHANGING
        it_attrib     = lt_struc_attr_gesamt_erw_r3
    ).


    " Nur fehlerhafte Datensätze anzeigen
    IF p_par8 = 'X'.
      DELETE lt_struc_attr_gesamt_erw_r3 WHERE NOT status EQ k_icon_yellow AND
                                               NOT status EQ k_icon_red.

    ENDIF.

    APPEND LINES OF lt_struc_attr_gesamt_erw_r3 TO lt_r3_gesamt.
    CLEAR: lt_struc_attr_gesamt_erw_r3 , lt_field_values_end_r3,
           lt_org_data.

    lv_nummer = lv_nummer + 1.
  ENDLOOP.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE 'Selektierte Werte in HRP1000 nicht vorhanden.' TYPE 'E' ##NO_TEXT.
  ENDIF.




  " Top-Down
ELSEIF p_par7 = 'X'.

  lv_nummer = 1.
  CLEAR lt_r3_gesamt.

  SELECT SINGLE objid                                   "#EC CI_NOORDER
         FROM hrp1000
         INTO @ls_selectopt3
         WHERE objid = @s_objid3-low  AND otype = @p_obj3 AND plvar = '01'
         AND   begda <= @sy-datum     AND endda >= @sy-datum. "#EC CI_NOORDER


  IF ls_selectopt3 IS INITIAL.
    MESSAGE 'Selektierte Werte in HRP1000 nicht vorhanden.' TYPE 'E' ##NO_TEXT.
  ENDIF.

  CALL FUNCTION 'RH_STRUC_GET' "
    EXPORTING
      act_otype      = p_obj3
      act_objid      = ls_selectopt3
      act_wegid      = 'O-O-S-P'
      act_plvar      = '01'
    IMPORTING
      act_plvar      = ld_act_plvar2              " Plan Version
    TABLES
      result_objec   = lt_result_objec3           " objec
    EXCEPTIONS
      no_plvar_found = 1                          " No active plan version exists
      no_entry_found = 2.                         " No agent found


  IF sy-subrc IS NOT INITIAL.
    MESSAGE 'Zu dem Objekt existieren keine TopDown-Elemente.' TYPE 'E' ##NO_TEXT.
  ELSE.

    LOOP AT lt_result_objec3  ASSIGNING FIELD-SYMBOL(<fs_objec3>).


      CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
        EXPORTING
          plvar            = '01'
          otype            = <fs_objec3>-otype
          objid            = <fs_objec3>-objid
          scenario         = 'SSP'
          seldate          = sy-datum
        TABLES
          attrib_ext       = lt_attr_ext_r3
        EXCEPTIONS
          no_active_plvar  = 1
          no_attributes    = 2
          no_values        = 3
          object_not_found = 4
          OTHERS           = 5.

      CHECK sy-subrc IS INITIAL.

      LOOP AT lt_attr_ext_r3 ASSIGNING FIELD-SYMBOL(<fs_attr_r3_2>).
        ls_struc_attr-nummer     =  lv_nummer .
        ls_struc_attr-objekttyp  =  <fs_objec3>-otype.
        ls_struc_attr-objektid   =  <fs_objec3>-objid.
        ls_struc_attr-attrib     =  <fs_attr_r3_2>-attrib.
        ls_struc_attr-low        =  <fs_attr_r3_2>-low.
        ls_struc_attr-high       =  <fs_attr_r3_2>-high.
        ls_struc_attr-excluded   =  <fs_attr_r3_2>-excluded.
        ls_struc_attr-defaultval =  <fs_attr_r3_2>-defaultval.
        ls_struc_attr-inherited  =  <fs_attr_r3_2>-inherited.
        ls_struc_attr-inherit    =  <fs_attr_r3_2>-inherit.
        ls_struc_attr-inh_otype  =  <fs_attr_r3_2>-inh_otype.
        ls_struc_attr-inh_objid  =  <fs_attr_r3_2>-inh_objid.


        SELECT SINGLE atext INTO @DATA(lv_atext_r3_2)
               FROM t77omattrt
               WHERE attrib = @<fs_attr_r3_2>-attrib AND langu = 'D' . "#EC CI_NOORDER´
        ls_struc_attr-atext = lv_atext_r3_2.
        CLEAR lv_atext_r3.

        APPEND ls_struc_attr TO lt_struc_attr_gesamt_erw_r3.
        CLEAR ls_struc_attr.
      ENDLOOP.

*--------------------------------------------------------------------*
*  13.07.2022 11:02:00  REPRO-KOE:  " Rollen-Zuständigkeite          *
*--------------------------------------------------------------------*
      CLEAR lt_agrs_r3.
      /THKR/CL_CHECK_KOMPL=>get_agr_from_objid(
        EXPORTING
          iv_otype = <fs_objec3>-otype
          iv_objid = <fs_objec3>-objid
        IMPORTING
          rt_agrs  = lt_agrs_r3 ).

      LOOP AT lt_agrs_r3 ASSIGNING FIELD-SYMBOL(<fs_agrs_r3_2>).

        SELECT SINGLE flag_value
        FROM agr_flags
        INTO @DATA(lv_sammel_agr_2)
        WHERE agr_name = @<fs_agrs_r3_2> AND flag_type = 'COLL_AGR'.

        IF lv_sammel_agr_2 = 'X'.

          SELECT child_agr FROM agr_agrs WHERE agr_name = @<fs_agrs_r3_2>
                                         INTO TABLE @DATA(agr_child_2).

          LOOP AT agr_child_2 ASSIGNING FIELD-SYMBOL(<fs_agr_child_2>).

            " Org_Ebene
            SELECT * FROM agr_1252
                     WHERE agr_name = @<fs_agr_child_2>-child_agr AND low NE '*' AND low NE ''
                     INTO TABLE @DATA(lt_org_ebene_2).

            MOVE-CORRESPONDING lt_org_ebene_2 TO lt_org_data_tmp_2.
            LOOP AT lt_org_data_tmp_2 ASSIGNING FIELD-SYMBOL(<org_data_tmp_2>).
              <org_data_tmp_2>-typ_rolle = <fs_agrs_r3_2>+0(2).
              <org_data_tmp_2>-rolle_nr  = <fs_agrs_r3_2>+2(2).
            ENDLOOP.

            APPEND LINES OF lt_org_data_tmp_2 TO lt_org_data_2.
            CLEAR: lt_org_ebene_2, lt_org_data_tmp_2.


            "Berechtigungswerte
            CALL FUNCTION 'PRGN_1251_READ_FIELD_VALUES'
              EXPORTING
                activity_group = <fs_agr_child_2>-child_agr
              TABLES
                field_values   = lt_field_values_tmp_r3_2
              EXCEPTIONS
                OTHERS         = 0.

            DELETE lt_field_values_tmp_r3_2
                   WHERE NOT deleted IS INITIAL.         "#EC CI_STDSEQ

            MOVE-CORRESPONDING lt_field_values_tmp_r3_2 TO lt_field_values_end_r3_tmp_2.
            LOOP AT lt_field_values_end_r3_tmp_2 ASSIGNING FIELD-SYMBOL(<fs_r3_tmp_3>).
              <fs_r3_tmp_3>-agr_name  = <fs_agr_child_2>-child_agr.
              <fs_r3_tmp_3>-typ_rolle = <fs_agrs_r3_2>+0(2).
              <fs_r3_tmp_3>-rolle_nr  = <fs_agrs_r3_2>+2(2).
            ENDLOOP.

            APPEND LINES OF lt_field_values_end_r3_tmp_2 TO lt_field_values_end_r3_2.
            CLEAR: lt_field_values_tmp_r3_2, lt_field_values_end_r3_tmp_2.

          ENDLOOP.
        ELSE.

          " Org_Ebene
          SELECT * FROM agr_1252
                   WHERE agr_name = @<fs_agrs_r3_2> AND low NE '*' AND low NE ''
                   INTO TABLE @DATA(lt_org_ebene_f_2).

          MOVE-CORRESPONDING lt_org_ebene_f_2 TO lt_org_data_2 KEEPING TARGET LINES.
          CLEAR lt_org_ebene_f_2.

          SELECT SINGLE agr_name FROM agr_define WHERE agr_name = @<fs_agrs_r3_2> INTO @DATA(lv_agr_name_def_2).
          CHECK sy-subrc = 0 AND lv_agr_name_def_2 IS NOT INITIAL.

          "Berechtigungswerte
          CALL FUNCTION 'PRGN_1251_READ_FIELD_VALUES'
            EXPORTING
              activity_group = lv_agr_name_def_2
            TABLES
              field_values   = lt_field_values_tmp_r3_2
            EXCEPTIONS
              OTHERS         = 0.

          DELETE lt_field_values_tmp_r3_2
                 WHERE NOT deleted IS INITIAL.           "#EC CI_STDSEQ

          MOVE-CORRESPONDING lt_field_values_tmp_r3_2 TO lt_field_values_end_r3_tmp_2.
          LOOP AT lt_field_values_end_r3_tmp_2 ASSIGNING FIELD-SYMBOL(<fs_r3_tmp_4>).
            <fs_r3_tmp_4>-agr_name  = <fs_agrs_r3_2>.
          ENDLOOP.
          APPEND LINES OF lt_field_values_end_r3_tmp_2 TO lt_field_values_end_r3_2.
          CLEAR: lt_field_values_tmp_r3_2, lt_field_values_end_r3_tmp_2.
        ENDIF.

      ENDLOOP.


*--------------------------------------------------------------------*
*  13.07.2022 13:32:09  REPRO-KOE:  aus Ber-felder Typ der Berecht   *
*--------------------------------------------------------------------*
      /THKR/CL_CHECK_KOMPL=>get_typ_ber_from_agr_fields(
                          EXPORTING
                          it_02xxl    = lt_tab_result_02xxl
                          CHANGING
                          it_agr_1251 = lt_field_values_end_r3_2 ).

      ""Tabellen bereinigen von unnöt. Daten
      DELETE lt_org_data_2 WHERE low EQ '*' OR low EQ '' OR low EQ '''' OR low EQ 'DUMMY'.
      DELETE lt_org_data_2 WHERE low CS '*' OR low CS '$'.
      DELETE lt_org_data_2 WHERE varbl NOT IN lt_typ_org.

      DELETE lt_field_values_end_r3_2 WHERE low EQ '*' OR
                                            low EQ 'DUMMY' OR
                                            low CS '*' OR
                                            low CS '$' OR
                                            low EQ ''''.
      DELETE lt_field_values_end_r3_2 WHERE typ_berecht NOT IN lt_typ_ber.


*--------------------------------------------------------------------*
*  13.07.2022 11:02:21  REPRO-KOE: Stammdaten prüfen - Attribute     *
*--------------------------------------------------------------------*

      /THKR/CL_CHECK_KOMPL=>check_attrib(
        EXPORTING
          it_tab_ur13c = lt_tab_result_13c
          it_tab_06xxl = lt_tab_result_06xxl
          it_t77omattot = lt_t77omattot
        CHANGING
          it_attrib     = lt_struc_attr_gesamt_erw_r3 ).



*--------------------------------------------------------------------*
*  13.07.2022 11:02:21  REPRO-KOE: Stammdaten prüfen - Ord_typ       *
*--------------------------------------------------------------------*
      /THKR/CL_CHECK_KOMPL=>check_org_data(
        EXPORTING
          iv_index      = lv_nummer
          iv_otype      = <fs_objec3>-otype
          iv_objid      = <fs_objec3>-objid
          it_05xxl      =  lt_typ_org
          it_t77omattot =  lt_t77omattot
          it_org_data   =  lt_org_data_2
          it_ur13c      =  lt_tab_result_13c
        CHANGING
          it_attrib     =  lt_struc_attr_gesamt_erw_r3 ).


*--------------------------------------------------------------------*
*  13.07.2022 11:02:21  REPRO-KOE: Stammdaten prüfen - Typ Ber       *
*--------------------------------------------------------------------*
      SORT lt_field_values_end_r3_2 BY typ_rolle rolle_nr agr_name typ_berecht field low.
      DELETE ADJACENT DUPLICATES FROM lt_field_values_end_r3_2
             COMPARING typ_rolle rolle_nr agr_name typ_berecht field low.

      /THKR/CL_CHECK_KOMPL=>check_ber_data(
  EXPORTING
    it_t77omattot = lt_t77omattot
    it_ur13c      = lt_tab_result_13c
    it_ber_data   = lt_field_values_end_r3_2
    it_02xxl      = lt_tab_result_02xxl
    iv_index      = lv_nummer
    iv_objid      = <fs_objec3>-objid
    iv_otype      = <fs_objec3>-otype
  CHANGING
    it_attrib     = lt_struc_attr_gesamt_erw_r3
).


      " Nur fehlerhafte Datensätze anzeigen
      IF p_par8 = 'X'.
        DELETE lt_struc_attr_gesamt_erw_r3 WHERE NOT status EQ k_icon_yellow AND
                                                 NOT status EQ k_icon_red.

      ENDIF.

      APPEND LINES OF lt_struc_attr_gesamt_erw_r3 TO lt_r3_gesamt.
      CLEAR: lt_struc_attr_gesamt_erw_r3 , lt_field_values_end_r3_2,
             lt_org_data_2.


      lv_nummer = lv_nummer + 1.
    ENDLOOP.

  ENDIF.

ENDIF.


IF lo_check_kompl IS BOUND.
  lo_check_kompl->r3_play_gui_alv_grid( CHANGING it_table = lt_r3_gesamt ).
ENDIF.
