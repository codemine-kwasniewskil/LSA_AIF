*&---------------------------------------------------------------------*
*& Include          /THKR/R_SEND_IST_RUECK_C01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      CLASS DEFINITION
*&---------------------------------------------------------------------*
CLASS lcl_appl DEFINITION.
*    -----//-----
  PUBLIC SECTION.
    CLASS-METHODS:
      main,
      display,
      f4_ns,
      f4_sst.

*    -----//-----
  PROTECTED SECTION.
    CONSTANTS:
      mc_default_fikrs TYPE fikrs VALUE 1000.
    CLASS-DATA:
      mt_alv   TYPE tt_alv_data,
      mo_table TYPE REF TO cl_salv_table.

*    -----//-----
  PRIVATE SECTION.
    CLASS-METHODS:
      get_data,
      transfer_to_aif RAISING /aif/cx_enabler_base,
      call_xslt_transformation,
      get_seldata RETURNING VALUE(rs_value) TYPE /thkr/s_fi_document_selection.
ENDCLASS.

*&---------------------------------------------------------------------*
*&      CLASS IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS lcl_appl IMPLEMENTATION.
  METHOD main.
    " get data by selection criterias
    get_data( ).

*    call_xslt_transformation( ).

    " send data via AIF
    TRY.
        transfer_to_aif( ).
      CATCH /aif/cx_enabler_base.
    ENDTRY.

  ENDMETHOD.

  METHOD get_data.
    DATA: lt_document_data TYPE /thkr/t_fi_document_data,
          lt_kassenz_saldo TYPE /thkr/t_fi_document_data,
          lt_bkpf          TYPE SORTED TABLE OF bkpf WITH UNIQUE KEY bukrs belnr gjahr.
    DATA(lo_psm_fi_extract) = /thkr/cl_fi_appl=>get_instance( ).
    CHECK lo_psm_fi_extract IS BOUND.

    lo_psm_fi_extract->get_all_psm_fi_document_data( EXPORTING i_selection_data = get_seldata( )
                                                     IMPORTING e_document_data  = lt_document_data
                                                               e_kassenz_saldo  = lt_kassenz_saldo ).

    IF lt_kassenz_saldo IS NOT INITIAL.
      SELECT bukrs belnr gjahr xref1_hd
        FROM bkpf
        INTO CORRESPONDING FIELDS OF TABLE lt_bkpf
        FOR ALL ENTRIES IN lt_kassenz_saldo[]
        WHERE bukrs = lt_kassenz_saldo-bukrs
          AND belnr = lt_kassenz_saldo-belnr
          AND gjahr = lt_kassenz_saldo-gjahr.
    ENDIF.

*    LOOP AT lt_document_data ASSIGNING FIELD-SYMBOL(<ls_item>).
    LOOP AT lt_kassenz_saldo ASSIGNING FIELD-SYMBOL(<ls_item>).
      APPEND INITIAL LINE TO mt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>).
      MOVE-CORRESPONDING <ls_item> TO <ls_alv>.
      READ TABLE lt_bkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf>) WITH TABLE KEY bukrs = <ls_item>-bukrs belnr = <ls_item>-belnr gjahr = <ls_item>-gjahr.
      IF sy-subrc = 0.
        <ls_alv>-xref1_hd = <ls_bkpf>-xref1_hd.
      ENDIF.
    ENDLOOP.

    SORT mt_alv BY xref1_hd.
  ENDMETHOD.

  METHOD transfer_to_aif.
    DATA: lt_aif       TYPE STANDARD TABLE OF /thkr/s_aif_file_rueck,
          ls_aif       TYPE /thkr/s_aif_file_rueck,
          ls_aif_rueck TYPE /thkr/s_aif_raw_rueck.

    CHECK p_send IS NOT INITIAL.

    IF p_sst IS NOT INITIAL.
      " AIF single structure mode
      ls_aif-sst       = p_sst.
      ls_aif-resend    = p_resend.
      ls_aif-t_rueck[] = CORRESPONDING #( mt_alv[] ).

      TRY.
          /aif/cl_enabler_xml=>transfer_to_aif( EXPORTING is_any_structure = ls_aif
                                                          iv_queue_ns      = p_q_ns
                                                          iv_queue_name    = p_q_name
                                                          iv_use_buffer    = abap_true ).

        CATCH /aif/cx_inf_det_base.
          " Generic Exception for AIF Enabler
        CATCH /aif/cx_enabler_base.
          " Generic Exception for AIF Enabler
        CATCH /aif/cx_aif_engine_not_found.
          " General exception class for AIF engines
        CATCH /aif/cx_error_handling_general.
          " AIF Error Handling Exception Class
        CATCH /aif/cx_aif_engine_base.
          " Base Exception Class for AIF Engines
      ENDTRY.

    ELSE.
      " AIF multiple mode
      LOOP AT mt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>) WHERE xref1_hd IS NOT INITIAL.
        FREE: ls_aif_rueck.
        READ TABLE lt_aif ASSIGNING FIELD-SYMBOL(<ls_aif>) WITH KEY sst = <ls_alv>-xref1_hd BINARY SEARCH.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING <ls_alv> TO ls_aif_rueck.
          APPEND ls_aif_rueck         TO <ls_aif>-t_rueck[].
        ELSE.
          APPEND INITIAL LINE         TO lt_aif ASSIGNING <ls_aif>.
          <ls_aif>-sst    = <ls_alv>-xref1_hd.
          <ls_aif>-resend = p_resend.
          MOVE-CORRESPONDING <ls_alv> TO ls_aif_rueck.
          APPEND ls_aif_rueck         TO <ls_aif>-t_rueck[].
        ENDIF.
      ENDLOOP.

      TRY.
          /aif/cl_enabler_xml=>transfer_to_aif_mult( EXPORTING it_any_structure = lt_aif
                                                               iv_queue_ns      = p_q_ns
                                                               iv_queue_name    = p_q_name
                                                               iv_use_buffer    = abap_true ).

        CATCH /aif/cx_inf_det_base.
          " Generic Exception for AIF Enabler
        CATCH /aif/cx_enabler_base.
          " Generic Exception for AIF Enabler
        CATCH /aif/cx_aif_engine_not_found.
          " General exception class for AIF engines
        CATCH /aif/cx_error_handling_general.
          " AIF Error Handling Exception Class
        CATCH /aif/cx_aif_engine_base.
          " Base Exception Class for AIF Engines
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD call_xslt_transformation.
    DATA: ls_document_data LIKE LINE OF mt_alv,
          lv_date          TYPE char40,
          lv_xml           TYPE string.

*    ls_document_data = VALUE #( bukrs = 'R090'
*                                lotkz = '2100000201'
*                                belnr = '6000000467'
*                                gjahr = '2024'
*                                fikrs = '1000'
*                                blart = 'DR'
*                                budat = '20241117'
*                                waers = 'EUR'
*                                xblnr = '1112128000719'
*                                solloriginalbetrag = '1712.00'
*                                offenessoll = '1712.00'
*                                sgtxt = 'Stundung Änderung Basisdatum'
*                                fipex = '112011959'
*                                fistl = '1101502002'
*                                partner = '0200000004'
*                                businesspartner_name = 'CD_04 PSM - Bewirtsch. 2 +1'
*                                street = 'Teststraße'
*                                house_no = '1'
*                                city = 'Hennef'
*                                postl_cod1 = '53733'
*                                country = 'DE'
*                                iban = 'DE02120300000000202051'
*                              ).
*    APPEND ls_document_data TO mt_alv.
*
*    ls_document_data = VALUE #( bukrs = 'R090'
*                                lotkz = '2100000202'
*                                belnr = '6000000468'
*                                gjahr = '2024'
*                                fikrs = '1000'
*                                blart = 'ST'
*                                budat = '20241117'
*                                waers = 'EUR'
*                                xblnr = '1112128000719'
*                                solloriginalbetrag = '1812.00'
*                                offenessoll = '1812.00'
*                                sgtxt = 'Test text'
*                                fipex = '112011959'
*                                fistl = '1101502002'
*                                partner = '0200000004'
*                                businesspartner_name = 'CD_04 PSM - Bewirtsch. 2 +1'
*                                street = 'Teststraße'
*                                house_no = '1'
*                                city = 'Hennef'
*                                postl_cod1 = '53733'
*                                country = 'DE'
*                                iban = 'DE02120300000000202051'
*                              ).
*    APPEND ls_document_data TO mt_alv.

    lv_date = |{ sy-datum(4) }-{ sy-datum+4(2) }-{ sy-datum+6(2) }T{ sy-uzeit(2) }:{ sy-uzeit+2(2) }:{ sy-uzeit+4(2) }.0|.

    CALL TRANSFORMATION /thkr/abap_to_bruecke_ist
      SOURCE metadata = lv_date
             data = mt_alv
      RESULT XML lv_xml.
  ENDMETHOD.


  METHOD get_seldata.
    rs_value = VALUE #( fikrs = p_fikrs
                        bukrs_ra = so_bukrs[]
                        gjahr_ra = so_gjahr[]
                        belnr_ra = so_belnr[]
                        blart_ra = so_blart[]
                        budat_ra = so_budat[]
                        lotkz_ra = so_lotkz[]
                        fipex_ra = so_fipex[]
                        fictr_ra = so_fictr[]
                        xblnr_ra = so_xblnr[]
                        resend   = p_resend
                        sst_key  = p_sst
                  ).
  ENDMETHOD.

  METHOD f4_ns.
    DATA: lt_return TYPE STANDARD TABLE OF ddshretval.

    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
      EXPORTING
        tabname           = '/AIF/T_NS'
        fieldname         = 'NS'
        dynpprog          = 'X'
        dynpnr            = 'X'
        dynprofield       = 'X'
*       VALUE             = ' '
        selection_screen  = 'X'
      TABLES
        return_tab        = lt_return
      EXCEPTIONS
        field_not_found   = 1
        no_help_for_field = 2
        inconsistent_help = 3
        no_values_found   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'.
    cl_gui_cfw=>flush( ).

  ENDMETHOD.

  METHOD f4_sst.
    DATA: lt_return TYPE STANDARD TABLE OF ddshretval.

    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
      EXPORTING
        tabname           = '/THKR/GPSSTTXT'
        fieldname         = 'SST'
        dynpprog          = 'X'
        dynpnr            = 'X'
        dynprofield       = 'X'
*       VALUE             = ' '
        selection_screen  = 'X'
      TABLES
        return_tab        = lt_return
      EXCEPTIONS
        field_not_found   = 1
        no_help_for_field = 2
        inconsistent_help = 3
        no_values_found   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'.
    cl_gui_cfw=>flush( ).

  ENDMETHOD.

  METHOD display.
    DATA: lo_functions  TYPE REF TO cl_salv_functions,
          lo_display    TYPE REF TO cl_salv_display_settings,
          lo_layout     TYPE REF TO cl_salv_layout,
          lo_columns    TYPE REF TO cl_salv_columns_table,
          lo_selections TYPE REF TO cl_salv_selections.
    DATA: key            TYPE salv_s_layout_key.

    CHECK p_disp IS NOT INITIAL.

    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = mo_table
                                CHANGING  t_table = mt_alv[] ).

        lo_functions = mo_table->get_functions( ).
        lo_functions->set_all( abap_true ).

        lo_columns = mo_table->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        lo_selections = mo_table->get_selections( ).
        lo_selections->set_selection_mode( if_salv_c_selection_mode=>cell ).

        lo_display = mo_table->get_display_settings( ).
        lo_display->set_striped_pattern( cl_salv_display_settings=>true ).
        lo_display->set_list_header( TEXT-t01 ).

        lo_layout = mo_table->get_layout( ).
        key-report = sy-repid.
        lo_layout->set_key( key ).
        lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
        lo_layout->set_default( cl_salv_layout=>true ).

        mo_table->display( ).
      CATCH cx_salv_msg INTO DATA(lo_salv_msg).
        DATA(lv_msg) = lo_salv_msg->get_text( ).
        MESSAGE lv_msg TYPE 'E'.
      CATCH cx_salv_not_found.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
