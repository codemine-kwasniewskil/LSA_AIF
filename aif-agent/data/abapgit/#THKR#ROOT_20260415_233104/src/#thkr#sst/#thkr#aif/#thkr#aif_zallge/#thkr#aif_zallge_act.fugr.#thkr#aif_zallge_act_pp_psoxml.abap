FUNCTION /thkr/aif_zallge_act_pp_psoxml .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_PSO_XML_SAP
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.                                             "#EC NOBREAK
*"----------------------------------------------------------------------
  DATA: lt_msgs             TYPE bapiret2_tt.
  DATA: lt_bp_msgs          TYPE bapiret2_tt.
  DATA: ls_meta             TYPE /thkr/cl_pso_xml_processing=>ty_s_meta.
  DATA: lt_table            TYPE TABLE OF string.
  DATA: lt_prot             TYPE STANDARD TABLE OF /thkr/s_pso_xml_pol_txt_prot.
  DATA: lo_form_tab         TYPE REF TO /thkr/cl_aif_rueck.
  DATA: lv_output_filename  TYPE string.
  DATA: lv_ns               TYPE /AIF/ns.
  DATA: lv_ifname           TYPE /aif/ifname.
  DATA: lv_ifversion        TYPE /aif/ifversion.
  DATA: lv_logical_filename TYPE filename-fileintern.
  DATA: lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics.

  ASSIGN curr_line  TO FIELD-SYMBOL(<ls_curr_line>).
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  success = 'Y'.

* Check if Actions are allowed.
    CALL FUNCTION '/THKR/AIF_ZALLGE_ACT_OFF'
      TABLES
        return_tab = return_tab
      EXCEPTIONS
        off        = 1
        OTHERS     = 2.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

  CREATE OBJECT lo_protokoll.
  CREATE OBJECT lo_form_tab.
*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                 number     = 418
                 type       = 'I'
                 message_v1 = '/THKR/AIF_ZALLGE_ACT_PP_PSOXML' ) TO return_tab.
*"----------------------------------------------------------------------
  "Protokolldatei erstellen
  LOOP AT <ls_data>-werte-anordnungen ASSIGNING FIELD-SYMBOL(<ls_anordnung>).
    LOOP AT <ls_anordnung>-txt_prot ASSIGNING FIELD-SYMBOL(<ls_prot>).
      "Fehlermeldungen und Finanzmetadaten aus Verarbeitung ermitteln
      "lt_msgs, ls_meta und lt_bp_msgs löschen. Sonst wird für die nächste Nachricht die Fehlermeldung der vorhergehenden
      "Nachricht angezeigt
      CLEAR: lt_msgs, ls_meta, lt_bp_msgs.
      <ls_prot>-msgty = /thkr/cl_pso_xml_processing=>get_instance( )->get_processing_status(
                                                                     EXPORTING
                                                                       is_data   = <ls_anordnung>                 " Output Struktur
                                                                       iv_glblid =  <ls_prot>-glblid                " Globale Beleg ID (Konkatenation aus dstnr,hhj,quelle,qbelnr)
                                                                       iv_msgty  = <ls_prot>-msgty
                                                                     IMPORTING
                                                                       et_msgs    = lt_msgs
                                                                       et_bp_msgs = lt_bp_msgs
                                                                       es_meta    = ls_meta
                                                                   ).

      "Fehler bei Anlage Geschäftspartner
      LOOP AT lt_bp_msgs ASSIGNING FIELD-SYMBOL(<ls_msg>) WHERE type = 'E' OR type = 'A' OR type = '' .
        "Erzeuge Fehlertext für erste Fehlermeldung.
        MESSAGE ID <ls_msg>-id TYPE <ls_msg>-type NUMBER <ls_msg>-number
              WITH <ls_msg>-message_v1 <ls_msg>-message_v2 <ls_msg>-message_v3 <ls_msg>-message_v4
              INTO  DATA(lv_msgtxt).
        APPEND VALUE /thkr/s_pso_xml_pol_txt_prot(
            pol_lotkz = <ls_prot>-pol_lotkz
            pol_belnr = <ls_prot>-pol_belnr
            pol_kassz = <ls_prot>-pol_kassz
            hkr_lotkz = ls_meta-lotkz
            hkr_belnr = ls_meta-belnr
            hkr_kassz = ls_meta-xblnr
            status  = 1
            msgno = <ls_msg>-number
            msgid = <ls_msg>-id
            msgtxt = lv_msgtxt
            msgty = <ls_prot>-msgty
             ) TO lt_prot.
      ENDLOOP.
      "Im Fehlerfall Meldung ins Log schreiben.
      LOOP AT lt_msgs ASSIGNING <ls_msg> WHERE type = 'E' OR type = 'A' OR type = '' .
        "Erzeuge Fehlertext für erste Fehlermeldung.
        MESSAGE ID <ls_msg>-id TYPE <ls_msg>-type NUMBER <ls_msg>-number
              WITH <ls_msg>-message_v1 <ls_msg>-message_v2 <ls_msg>-message_v3 <ls_msg>-message_v4
              INTO  lv_msgtxt.
        APPEND VALUE /thkr/s_pso_xml_pol_txt_prot(
            pol_lotkz = <ls_prot>-pol_lotkz
            pol_belnr = <ls_prot>-pol_belnr
            pol_kassz = <ls_prot>-pol_kassz
            hkr_lotkz = ls_meta-lotkz
            hkr_belnr = ls_meta-belnr
            hkr_kassz = ls_meta-xblnr
            status = 1
            msgno = <ls_msg>-number
            msgid = <ls_msg>-id
            msgtxt = lv_msgtxt
            msgty = <ls_prot>-msgty
             ) TO lt_prot.
      ENDLOOP.

      "Keine Fehler.
      "Erfolgsmeldung.
      IF sy-subrc <> 0.
        <ls_prot>-msgid = /thkr/cl_pso_xml_processing=>get_instance( )->gc_msgid.
        MESSAGE s027(/thkr/sst) INTO lv_msgtxt.
        APPEND VALUE /thkr/s_pso_xml_pol_txt_prot(
            pol_lotkz = <ls_prot>-pol_lotkz
            pol_belnr = <ls_prot>-pol_belnr
            pol_kassz = <ls_prot>-pol_kassz
            hkr_lotkz = ls_meta-lotkz
            hkr_belnr = ls_meta-belnr
            hkr_kassz = ls_meta-xblnr
            status = cond #( WHEN <ls_prot>-status is INITIAL then 0
                             else <ls_prot>-status )
            msgno = cond #( WHEN <ls_prot>-msgno is INITIAL then 027
                             else <ls_prot>-msgno )
            msgid = cond #( WHEN <ls_prot>-msgid is INITIAL then /thkr/cl_pso_xml_processing=>get_instance( )->gc_msgid
                             else <ls_prot>-msgid )
            msgtxt = cond #( WHEN <ls_prot>-msgtxt is INITIAL then lv_msgtxt
                             else <ls_prot>-msgtxt )
            msgty = <ls_prot>-msgty
           ) TO lt_prot.

      ENDIF.
    ENDLOOP.



  ENDLOOP.

  lt_table = lo_form_tab->modify_output_tab(
            it_rueck_lines = lt_prot                 " Tabelle von Strings
          ).

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns        = lv_ns
      ifname    = lv_ifname
      ifversion = lv_ifversion.

  Lv_logical_filename = |/THKR/AIF_{ lv_ifname }_PRT|.
  lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename = conv string( <ls_anordnung>-common-dateiname ) ).

  CALL METHOD lo_protokoll->write_and_send_file
    EXPORTING
      iv_output_filename = lv_output_filename
      it_rows            = lt_table[]
      iv_ns              = lv_ns
      iv_ifname          = lv_ifname
      iv_ifversion       = lv_ifversion
      iv_eol              = conv string( cl_abap_char_utilities=>newline )
    CHANGING
      cv_success         = success
      ct_return_tab      = return_tab[].
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
