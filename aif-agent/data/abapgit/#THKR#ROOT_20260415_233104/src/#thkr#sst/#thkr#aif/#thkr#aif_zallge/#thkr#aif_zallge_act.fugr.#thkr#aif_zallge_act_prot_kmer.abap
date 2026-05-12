*"----------------------------------------------------------------------
* Maximilian Kleissl  tsi  4.9.2024
*"----------------------------------------------------------------------
* action erstellt APN Protokoll
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_prot_kmer .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA: lt_table            TYPE TABLE OF string,
        lv_output_filename  TYPE string,
        lv_ns               TYPE /AIF/ns,
        lv_ifname           TYPE /aif/ifname,
        lv_ifversion        TYPE /aif/ifversion,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics,
        lo_form_tab         TYPE REF TO /thkr/cl_aif_rueck,
        lt_msgs             TYPE bapiret2_tt,
        lt_kmer_prot        TYPE STANDARD TABLE OF /thkr/s_dto_prot_kmer.

  ASSIGN data TO FIELD-SYMBOL(<ls_data>).
  APPEND VALUE #( id         = 'KM'
              number     = 418
              type       = 'I'
              message_v1 = '/THKR/AIF_ZALLGE_ACT_PROT_KMER' ) TO return_tab.

  CREATE OBJECT lo_protokoll.
  CREATE OBJECT lo_form_tab.

  LOOP AT <ls_data>-add_prot_kmer ASSIGNING FIELD-SYMBOL(<ls_prot>).
    Try.
    DATA(lv_status) = lo_protokoll->get_processing_status(
                                  EXPORTING
                                    is_data =  <ls_data>
                                    iv_glblid = <ls_prot>-glblid
                                    iv_kassz = <ls_prot>-kassenzeichen
                                    iv_sst =  |{ conv string( <ls_data>-lst[ glblid = <ls_prot>-glblid ]-verfahrenskuerzel ) CASE = UPPER }|
                                    iv_btyp = |{ conv string( <ls_data>-lst[ glblid = <ls_prot>-glblid ]-typ ) CASE = UPPER }|
                                  IMPORTING
                                    et_msgs = lt_msgs
                                    ev_kassz = <ls_prot>-kassenzeichen ).
    Catch cx_sy_itab_line_not_found.
      if 1 = 0. message e078(/THKR/SST) with <ls_prot>-glblid.endif.
      APPEND value bapiret2( id = '/THKR/SST'
                             number = 078
                             type = 'E'
                             message_v1 = <ls_prot>-glblid ) to lt_msgs.
    ENDTRY.

    LOOP AT lt_msgs ASSIGNING FIELD-SYMBOL(<ls_msg>) WHERE type = 'E' OR type = 'A' OR type = '' .
      "Erzeuge Fehlertext für erste Fehlermeldung.
      <ls_prot>-fehlernummer = <ls_msg>-number.
      MESSAGE ID <ls_msg>-id TYPE <ls_msg>-type NUMBER <ls_msg>-number
            WITH <ls_msg>-message_v1 <ls_msg>-message_v2 <ls_msg>-message_v3 <ls_msg>-message_v4
            INTO  <ls_prot>-fehlertext.

      EXIT.
    ENDLOOP.
  ENDLOOP.
  lt_kmer_prot = CORRESPONDING #( <ls_data>-add_prot_kmer ).
  lt_table = lo_form_tab->modify_output_tab(
             it_rueck_lines = lt_kmer_prot                 " Tabelle von Strings
           ).

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns        = lv_ns
      ifname    = lv_ifname
      ifversion = lv_ifversion.

  Lv_logical_filename = |/THKR/AIF_{ lv_ifname }_PRT|.
  lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename = CONV string( <ls_data>-common-dateiname ) ).

  DATA(lv_eol) =  COND #( WHEN lo_form_tab->ms_pprop-cr_lf = 1 THEN cl_abap_char_utilities=>cr_lf(1)
                                         WHEN lo_form_tab->ms_pprop-cr_lf = 2 THEN cl_abap_char_utilities=>newline
                                         WHEN lo_form_tab->ms_pprop-cr_lf = 3 THEN cl_abap_char_utilities=>cr_lf
                                         WHEN lo_form_tab->ms_pprop-cr_lf IS INITIAL THEN cl_abap_char_utilities=>newline ).


  CALL METHOD lo_protokoll->write_and_send_file
    EXPORTING
      iv_output_filename = lv_output_filename
      it_rows            = lt_table[]
      iv_ns              = lv_ns
      iv_ifname          = lv_ifname
      iv_ifversion       = lv_ifversion
      iv_eol             = CONV string( lv_eol )
    CHANGING
      cv_success         = success
      ct_return_tab      = return_tab[].

ENDFUNCTION.
