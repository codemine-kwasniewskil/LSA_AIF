class /THKR/CL_IST_RM_CREATE definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_alv.
        INCLUDE TYPE /thkr/s_aif_raw_rueck.
    TYPES: xref1_hd TYPE xref1_hd.
    TYPES END OF ty_alv .
  types:
    tt_alv_data TYPE TABLE OF ty_alv .
  types:
    ttr_blart TYPE RANGE OF blart .
  types:
    ttr_cpudt TYPE RANGE OF cpudt .
  types:
    BEGIN OF ty_sel,
             so_cpudt TYPE ttr_cpudt,
             so_blart TYPE ttr_blart,
             fikrs    TYPE fikrs,
             aif_ns   TYPE /aif/ns,
             aif_name TYPE /aif/pers_rtcfgr_name,
             sst      TYPE /thkr/dte_bu_sst,
             send     TYPE flag,
             resend   TYPE flag.
    TYPES END OF ty_sel .

  class-data SELECTION type TY_SEL .

  class-methods MAIN
    importing
      !SO_CPUDT type TTR_CPUDT
      !SO_BLART type TTR_BLART
      !FIKRS type FIKRS
      !AIF_NS type /AIF/NS
      !AIF_NAME type /AIF/PERS_RTCFGR_NAME
      !SST type /THKR/DTE_BU_SST
      !SEND type FLAG
      !RESEND type FLAG .
  class-methods DISPLAY .
PROTECTED SECTION.

  CONSTANTS mc_default_fikrs TYPE fikrs VALUE 1000 ##NO_TEXT.
*      mt_alv   TYPE tt_alv_data,
*    -----//-----
  CLASS-DATA mo_table TYPE REF TO cl_salv_table .
  CLASS-DATA mt_alv TYPE tt_alv_data .
  CLASS-DATA mt_data TYPE TABLE OF /thkr/cds_aif_ist_rm_sel_v2 .
private section.

  class-methods GET_DATA .
  class-methods TRANSFER_TO_AIF
    raising
      /AIF/CX_ENABLER_BASE .
  class-methods GET_SELDATA
    returning
      value(RS_VALUE) type /THKR/S_FI_DOCUMENT_SELECTION .
ENDCLASS.



CLASS /THKR/CL_IST_RM_CREATE IMPLEMENTATION.


  METHOD display.
    DATA: lo_functions  TYPE REF TO cl_salv_functions,
          lo_display    TYPE REF TO cl_salv_display_settings,
          lo_layout     TYPE REF TO cl_salv_layout,
          lo_columns    TYPE REF TO cl_salv_columns_table,
          lo_selections TYPE REF TO cl_salv_selections.
    DATA: key            TYPE salv_s_layout_key.

*    CHECK p_disp IS NOT INITIAL.

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


  METHOD get_data.
*    DATA: lt_document_data TYPE /thkr/t_fi_document_data,
*          lt_kassenz_saldo TYPE /thkr/t_fi_document_data,
*          lt_bkpf          TYPE SORTED TABLE OF bkpf WITH UNIQUE KEY bukrs belnr gjahr.
*    DATA(lo_psm_fi_extract) = /thkr/cl_fi_appl=>get_instance( ).
**    CHECK lo_psm_fi_extract IS BOUND.
**
*    lo_psm_fi_extract->get_all_psm_fi_document_data( EXPORTING i_selection_data = get_seldata( )
*                                                     IMPORTING e_document_data  = lt_document_data
*                                                               e_kassenz_saldo  = lt_kassenz_saldo ).

    DATA(where_clause) =       'blart                       IN @selection-so_blart'
*                             &&' AND kassenzeichen          IN @ms_selection_data-xblnr_ra'
                             &&' AND cpudt                  IN @selection-so_cpudt'.
*                             &&' AND alreadysent            EQ @selection-resend'
*                             &&' AND gezahlt                NE 0'.

*    "** If SST is given: Just select related items:
    IF selection-sst IS NOT INITIAL.
      where_clause =  where_clause && ' AND xref1_hd   EQ @selection-sst'.
*      if selection-resend = abap_true.
*        where_clause =  where_clause && ' AND sstkey      EQ @selection-sst'.
*      endif.
    ENDIF.


    SELECT FROM /thkr/cds_aif_ist_rm_sel_v2
     FIELDS *
     WHERE (where_clause)
*     ORDER BY bukrs, kassenzeichen", stunr
     INTO TABLE @mt_data.
    IF sy-subrc NE 0.
      "Dann keine Daten
    ENDIF.

*    IF lt_kassenz_saldo IS NOT INITIAL.
*      SELECT bukrs belnr gjahr xref1_hd
*        FROM bkpf
*        INTO CORRESPONDING FIELDS OF TABLE lt_bkpf
*        FOR ALL ENTRIES IN lt_kassenz_saldo[]
*        WHERE bukrs = lt_kassenz_saldo-bukrs
*          AND belnr = lt_kassenz_saldo-belnr
*          AND gjahr = lt_kassenz_saldo-gjahr.
*    ENDIF.
*
**    LOOP AT lt_document_data ASSIGNING FIELD-SYMBOL(<ls_item>).
*    LOOP AT lt_kassenz_saldo ASSIGNING FIELD-SYMBOL(<ls_item>).
*      APPEND INITIAL LINE TO mt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>).
*      MOVE-CORRESPONDING <ls_item> TO <ls_alv>.
*      READ TABLE lt_bkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf>) WITH TABLE KEY bukrs = <ls_item>-bukrs belnr = <ls_item>-belnr gjahr = <ls_item>-gjahr.
*      IF sy-subrc = 0.
*        <ls_alv>-xref1_hd = <ls_bkpf>-xref1_hd.
*      ENDIF.
*    ENDLOOP.
    mt_alv = CORRESPONDING #( mt_data ).

    SORT mt_alv BY xref1_hd.
  ENDMETHOD.


  METHOD get_seldata.
*    rs_value = VALUE #( fikrs = p_fikrs
*                        bukrs_ra = so_bukrs[]
*                        gjahr_ra = so_gjahr[]
*                        belnr_ra = so_belnr[]
*                        blart_ra = so_blart[]
*                        budat_ra = so_budat[]
*                        lotkz_ra = so_lotkz[]
*                        fipex_ra = so_fipex[]
*                        fictr_ra = so_fictr[]
*                        xblnr_ra = so_xblnr[]
*                        resend   = p_resend
*                        sst_key  = p_sst
*                  ).
  ENDMETHOD.


   METHOD main.
    " get data by selection criterias
    selection = VALUE #( so_cpudt = so_cpudt so_blart = so_blart
                         fikrs = fikrs
                         aif_name = aif_name
                         aif_ns = aif_ns
                         sst    = sst
                         send   = send
                         resend = resend ) .
    get_data( ).

    TRY.
        transfer_to_aif( ).
      CATCH /aif/cx_enabler_base.
    ENDTRY.

  ENDMETHOD.


  METHOD transfer_to_aif.
    DATA: lt_aif       TYPE STANDARD TABLE OF /thkr/s_aif_file_rueck,
          ls_aif       TYPE /thkr/s_aif_file_rueck,
          ls_aif_rueck TYPE /thkr/s_aif_raw_rueck.

    CHECK selection-send IS NOT INITIAL.

    IF selection-sst IS NOT INITIAL.
      " AIF single structure mode
      ls_aif-sst       = selection-sst.
      ls_aif-resend    = selection-resend.
      ls_aif-t_rueck[] = CORRESPONDING #( mt_alv[] ).

      TRY.
          /aif/cl_enabler_xml=>transfer_to_aif( EXPORTING is_any_structure = ls_aif
                                                          iv_queue_ns      = selection-aif_ns
                                                          iv_queue_name    = selection-aif_name
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
          <ls_aif>-resend = selection-resend.
          MOVE-CORRESPONDING <ls_alv> TO ls_aif_rueck.
          APPEND ls_aif_rueck         TO <ls_aif>-t_rueck[].
        ENDIF.
      ENDLOOP.

      TRY.
          /aif/cl_enabler_xml=>transfer_to_aif_mult( EXPORTING it_any_structure = lt_aif
                                                               iv_queue_ns      = selection-aif_ns
                                                               iv_queue_name    = selection-aif_name
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
ENDCLASS.
