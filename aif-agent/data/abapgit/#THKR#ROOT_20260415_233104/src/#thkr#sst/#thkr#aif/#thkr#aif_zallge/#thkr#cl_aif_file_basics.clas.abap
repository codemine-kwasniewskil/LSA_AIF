class /THKR/CL_AIF_FILE_BASICS definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_s_ao_number_range,
        psoty TYPE psoty,
        first TYPE lotkz,
        last  TYPE lotkz,
      END OF ty_s_ao_number_range .
  types:
    ty_t_ao_number_range TYPE STANDARD TABLE OF ty_s_ao_number_range .
  types:
    BEGIN OF ty_s_result_per_btyp,
        btyp            TYPE char3,
        Total_amount    TYPE wrbtr,
        booked_amount   TYPE wrbtr,
        total_processed TYPE i,
        failed          TYPE i,
      END OF ty_s_result_per_btyp .
  types:
    ty_t_result_per_btyp TYPE STANDARD TABLE OF ty_s_result_per_btyp .

  constants GC_EMTPY_ROW type STRING value '                                                                                ' ##NO_TEXT.
  constants GC_SEPERATOR_LINE type STRING value '--------------------------------------------------------------------------------' ##NO_TEXT.
  data MT_AO_NUMBER_RANGE type TY_T_AO_NUMBER_RANGE .

  methods STRING_TO_BAPIRET2
    importing
      !I_MSG type STRING
    returning
      value(R_BAPIRET2) type BAPIRET2 .
  methods ADD_STRING_TO_RETURN_TAB
    importing
      !I_MSG type STRING
    changing
      !CT_RETURN_TAB type BAPIRET2_T .
  methods GET_FILEPATH
    importing
      !IV_LOGICAL_FILENAME type FILENAME-FILEINTERN
      !IV_FILENAME type STRING optional
    returning
      value(R_FILENAME) type STRING .
  methods WRITE_FILE_FROM_STRING
    importing
      !IV_OUTPUT_FILENAME type STRING
      !IV_CONTENT type STRING
      !IV_CP type DMC_CPAGE optional
    changing
      !CV_SUCCESS type /AIF/SUCCESSFLAG
      !CT_RETURN_TAB type BAPIRET2_T .
  methods WRITE_FILE_FROM_STRING_TABLE
    importing
      !IV_OUTPUT_FILENAME type STRING
      !IT_ROWS type STRING_TABLE
      !IV_CP type DMC_CPAGE optional
      !IV_WIDTH type I optional
      !IV_EOL type STRING
    changing
      !CV_SUCCESS type /AIF/SUCCESSFLAG
      !CT_RETURN_TAB type BAPIRET2_T .
  methods WRITE_AND_SEND_FILE
    importing
      !IV_OUTPUT_FILENAME type STRING
      !IT_ROWS type STRING_TABLE
      !IV_NS type /AIF/NS
      !IV_IFNAME type /AIF/IFNAME
      !IV_IFVERSION type /AIF/IFVERSION
      !IV_CP type DMC_CPAGE optional
      !IV_WIDTH type I optional
      !IV_EOL type STRING
    changing
      !CV_SUCCESS type /AIF/SUCCESSFLAG
      !CT_RETURN_TAB type BAPIRET2_T .
  methods SET_APN_STATUS
    importing
      !IT_APN_ZEILEN type /THKR/T_APN_ZEILEN
      !IS_DATA type /THKR/S_AIF_SAP
    exporting
      !EV_FAILED_RECORDS type I
      !EV_COUNT_RECORDS type I
      !ET_RESULT_PER_BTYP type TY_T_RESULT_PER_BTYP
    returning
      value(RT_APN_ZEILEN) type /THKR/T_APN_ZEILEN .
  methods CREATE_APN_HEADER
    importing
      !IS_APN_HEADER type /THKR/S_AIF_APN
      !IV_FAILED_RECORDS type I
      !IV_COUNT_RECORDS type I
      !IV_FILENAME type FILEEXTERN
      !IV_BEGINN_DATUM type DATS
      !IV_BEGINN_UZEIT type TIMS
    changing
      !CT_PROT_TABLE type STRING_TABLE .
  methods CREATE_APN_BODY
    importing
      !IT_RESULT_PER_BTYP type TY_T_RESULT_PER_BTYP
    changing
      !CT_PROT_TABLE type STRING_TABLE .
  methods CREATE_APN_FOOTER
    importing
      !IV_BEGINN_UZEIT type TIMS
      !IV_BEGINN_DATUM type DATS
      !IV_FILENAME type FILEEXTERN
    changing
      !CT_PROT_TABLE type STRING_TABLE .
  methods CREATE_LST_HEADER
    importing
      !IV_QUELLE type CHAR8
      !IV_VKUERZEL type CHAR3
      !IV_STELLE type CHAR4
    changing
      !CT_PROT_TABLE type STRING_TABLE .
  methods CREATE_LST_BODY
    importing
      !IT_LST type /THKR/T_LST_PROT
      !IS_DATA type /THKR/S_AIF_SAP
    changing
      !CT_PROT_TABLE type STRING_TABLE .
  methods CREATE_LST_FOOTER
    importing
      !IV_BEGINN_DATUM type DATS
      !IV_BEGINN_UZEIT type TIMS
    changing
      !CT_PROT_TABLE type STRING_TABLE .
  methods CREATE_CSV_ERR_BODY
    importing
      !IT_LST        type /THKR/T_LST_PROT
      !IS_DATA       type /THKR/S_AIF_SAP
    returning
      value(RV_HAS_ERRORS) type ABAP_BOOL
    changing
      !CT_CSV_TABLE  type STRING_TABLE .
  methods WRITE_AND_SEND_FILE_CSV
    importing
      !IV_OUTPUT_FILENAME type STRING
      !IT_ROWS            type STRING_TABLE
      !IV_NS              type /AIF/NS
      !IV_IFNAME          type /AIF/IFNAME
      !IV_IFVERSION       type /AIF/IFVERSION
      !IV_EOL             type STRING
    changing
      !CV_SUCCESS         type /AIF/SUCCESSFLAG
      !CT_RETURN_TAB      type BAPIRET2_T .
  methods GET_PROCESSING_STATUS
    importing
      !IS_DATA type /THKR/S_AIF_SAP
      !IV_GLBLID type /THKR/AIF_GLBLID
      !IV_KASSZ type XBLNR optional
      !IV_BTYP type STRING optional
      !IV_SST type STRING optional
    exporting
      !EV_SAP_OBJID type CA_OBTAB
      !ET_MSGS type BAPIRET2_TT
      !EV_KASSZ type XBLNR
      !EV_NETDT type NETDT
    returning
      value(RV_STATUS) type /AIF/PROC_STATUS .
  methods GET_APN_GET_NUMBER_RANGES
    importing
      !IS_DATA type /THKR/S_AIF_SAP .
  methods OVERWRITE_FILES
    importing
      !IV_NS type /AIF/NS
      !IV_IFNAME type /AIF/IFNAME
    returning
      value(RV_OVERWRITE) type FLAG .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF TY_S_RECIPIENT_LIST,
          ns type /aif/ns,
          recipient type /AIF/ALRT_REC,
    END OF ty_s_recipient_list .

  methods RTF_STRING_TO_BINARY
    importing
      !IV_RTF_STRING type STRING
    returning
      value(RV_ATTACHMENT) type SOLIX_TAB .
  methods ESCAPE_CSV
    importing
      !IV_VALUE type STRING
    returning
      value(RV_ESCAPED) type STRING .
  methods ADD_MAILS_FROM_USERNAMES
    importing
      !IT_ALRT_USER type /AIF/API_CUST_ALRT_USER_TT
    changing
      !CT_MAIL_RECIPIENTS type BCSY_SMTPA .
  methods GET_MAILS_FOR_RECIPIENT_LIST
    importing
      !IS_RECIPIENT_LIST type TY_S_RECIPIENT_LIST
    changing
      !CT_MAIL_RECIPIENTS type BCSY_SMTPA .
  methods SEND_MAIL
    importing
      !IT_MAIL_RECIPIENTS    type BCSY_SMTPA
      !IV_ATTACHMENT_CONTENT type STRING
      !IV_ATTACHMENT_NAME    type STRING
      !IV_ATTACHMENT_TYPE    type STRING optional
    returning
      value(RV_SUCCESS) type /AIF/SUCCESSFLAG .
  methods GET_RECIPIENT_LIST
    importing
      !IV_NS type /AIF/NS
      !IV_IFNAME type /AIF/IFNAME
      !IV_IFVERSION type /AIF/IFVERSION
    returning
      value(RS_RECIPIENT_LIST) type TY_S_RECIPIENT_LIST .
  methods GET_TREASURY_ID
    importing
      !IV_BELNR type BELNR_D
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR
    changing
      !CV_KASSZ type CHAR17 .
  methods CREATE_LST_SUCCESS
    importing
      !IS_LST type /THKR/S_AIF_LST
      !IS_DATA type /THKR/S_AIF_SAP
      !IV_KASSZ type XBLNR
      !IV_SAP_OBJID type CA_OBTAB
      !IV_NETDT type NETDT
    changing
      !CT_PROT_TABLE type STRING_TABLE .
  methods CREATE_LST_ERROR
    importing
      !IS_LST type /THKR/S_AIF_LST
      !IT_MSGS type BAPIRET2_TT
    changing
      !CT_ERROR_TAB type STRING_TABLE .
  methods APPEND_AO_NUMBER_RANGE
    importing
      !IV_PSOTY type PSOTY_D
      !IV_FIRST type LOTKZ optional
      !IV_LAST type LOTKZ optional .
  methods GET_TREASURY_ID_MB
    importing
      !IV_BELNR type BELNR_D
    changing
      !CV_KASSZ type CHAR17 .
  methods GET_NETDT_FROM_BSEG
    importing
      !IV_BUKRS type BUKRS
      !IV_BELNR type BELNR_D
      !IV_GJAHR type GJAHR
    returning
      value(RV_NETDT) type NETDT .
  methods GET_ERR_FOR_GLBLID
    importing
      !IS_DATA   type /THKR/S_AIF_SAP
      !IV_GLBLID type /THKR/AIF_GLBLID
    exporting
      !EV_STATUS type /AIF/PROC_STATUS
      !ET_MSGS   type BAPIRET2_TT .
ENDCLASS.



CLASS /THKR/CL_AIF_FILE_BASICS IMPLEMENTATION.


  METHOD add_mails_from_usernames.

    DATA: lt_return TYPE bapirettab,
          lt_smtp   TYPE TABLE OF bapiadsmtp.

    LOOP AT it_alrt_user INTO DATA(ls_alrt_user).
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = ls_alrt_user-uname
        TABLES
          return   = lt_return
          addsmtp  = lt_smtp.

      LOOP AT lt_smtp INTO DATA(ls_smtp).
        TRANSLATE ls_smtp-e_mail TO LOWER CASE.
        APPEND ls_smtp-e_mail TO ct_mail_recipients.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD ADD_STRING_TO_RETURN_TAB.
    DATA lv_bapiret2 TYPE bapiret2.
    lv_bapiret2 = string_to_bapiret2( i_msg = i_msg ).
    APPEND lv_bapiret2 TO ct_return_tab.
  ENDMETHOD.


  METHOD append_ao_number_range.
    TRY.
        IF iv_first IS SUPPLIED AND iv_first IS NOT INITIAL.
          if mt_ao_number_range[ psoty = iv_psoty ]-first is INITIAL.
            mt_ao_number_range[ psoty = iv_psoty ]-first = iv_first.
          endif.
        ENDIF.
        if iv_last is SUPPLIED and iv_last is NOT INITIAL.
          mt_ao_number_range[ psoty = iv_psoty ]-last = iv_last.
        endif.
      CATCH cx_sy_itab_line_not_found.
        APPEND VALUE ty_s_ao_number_range( psoty = iv_psoty
                                           first = iv_first ) TO mt_ao_number_range.
    ENDTRY.
  ENDMETHOD.


  METHOD create_apn_body.

    LOOP AT it_result_per_btyp ASSIGNING FIELD-SYMBOL(<ls_result>).
      APPEND |    Btyp= { <ls_result>-btyp }: { <ls_result>-total_processed } Saetze bearbeitet, davon { <ls_result>-failed } Saetze fehlerhaft| TO ct_prot_table.
      APPEND |      Summe: { <ls_result>-total_amount }, davon gebucht: { <ls_result>-booked_amount }| TO ct_prot_table.
    ENDLOOP.
    LOOP AT mt_ao_number_range ASSIGNING FIELD-SYMBOL(<ls_ao_number>).
      CASE: <ls_ao_number>-psoty.
        WHEN: '01'.
          APPEND |    Auszahlungsanordnung: erste vergebene Buchungsnummer = { <ls_ao_number>-first }| TO ct_prot_table.
          APPEND |    Auszahlungsanordnung: letzte vergebene Buchungsnummer = { <ls_ao_number>-last }| TO ct_prot_table.
        WHEN: '02'.
          APPEND |    Annahmeanordnung: erste vergebene Buchungsnummer = { <ls_ao_number>-first }| TO ct_prot_table.
          APPEND |    Annahmeanordnung: letzte vergebene Buchungsnummer = { <ls_ao_number>-last }| TO ct_prot_table.
        WHEN: '03'.
          APPEND |    Verrechnungsanordnung: erste vergebene Buchungsnummer = { <ls_ao_number>-first }| TO ct_prot_table.
          APPEND |    Verrechnungsanordnung: letzte vergebene Buchungsnummer = { <ls_ao_number>-last }| TO ct_prot_table.
        WHEN: '04'.
          APPEND |    Auszahlungsabsetzungsanordnung: erste vergebene Buchungsnummer = { <ls_ao_number>-first }| TO ct_prot_table.
          APPEND |    Auszahlungsabsetzungsanordnung: letzte vergebene Buchungsnummer = { <ls_ao_number>-last }| TO ct_prot_table.
        WHEN: '05'.
          APPEND |    Annahmeabsetzungsanordnung: erste vergebene Buchungsnummer = { <ls_ao_number>-first }| TO ct_prot_table.
          APPEND |    Annahmeabsetzungsanordnung: letzte vergebene Buchungsnummer = { <ls_ao_number>-last }| TO ct_prot_table.
        WHEN: '06'.
          APPEND |    Stundungsanordnung: erste vergebene Buchungsnummer = { <ls_ao_number>-first }| TO ct_prot_table.
          APPEND |    Stundungsanordnung: letzte vergebene Buchungsnummer = { <ls_ao_number>-last }| TO ct_prot_table.
      ENDCASE.
    ENDLOOP.
*      SORT lt_apn_zeilen BY buchungstyp.
*  Lv_last_buchungstyp = ''.
*  LOOP AT lt_apn_zeilen ASSIGNING <ls_apn_buchungscode>.
*    IF lv_last_buchungstyp <> <ls_apn_buchungscode>-buchungstyp.
*      IF lv_last_buchungstyp <> ''.
*        APPEND |    Btyp= { lv_last_buchungstyp }: { lv_anzahl_zeilen } Saetze bearbeitet, davon { lv_anzahl_zeilen_fehlerhaft } Saetze fehlerhaft| TO ct_prot_table.
*        APPEND |      Summe: { lv_summe }, davon gebucht: { lv_summe_gebucht }| TO ct_prot_table.
*      ENDIF.
*      lv_last_buchungstyp = <ls_apn_buchungscode>-buchungstyp.
*      lv_anzahl_zeilen = 0.
*      lv_summe = 0.
*      lv_summe_gebucht = 0.
*      lv_anzahl_zeilen_fehlerhaft = 0.
*    ENDIF.
*    Lv_anzahl_zeilen += 1.
*    Lv_summe += <ls_apn_buchungscode>-summe.
*    IF <ls_apn_buchungscode>-ao_proc_status <> 's' AND <ls_apn_buchungscode>-ao_proc_status <> 'w'.
*      Lv_anzahl_zeilen_fehlerhaft += 1.
*    ELSE.
*      Lv_summe_gebucht += <ls_apn_buchungscode>-summe.
*    ENDIF.
*  ENDLOOP.
*  IF lv_last_buchungstyp <> ''.
*    APPEND |    Btyp= { lv_last_buchungstyp }: { lv_anzahl_zeilen } Saetze bearbeitet, davon { lv_anzahl_zeilen_fehlerhaft } Saetze fehlerhaft| TO ct_prot_table.
*    APPEND |      Summe: { lv_summe }, davon gebucht: { lv_summe_gebucht }| TO ct_prot_table.
*  ENDIF.
  ENDMETHOD.


  method CREATE_APN_FOOTER.
  APPEND |      Ende der Bearbeitung der Datei: { iv_filename } | TO ct_prot_table.
  APPEND '    **** Prozess korrekt beendet! ****' TO ct_prot_table.
  APPEND |    am { sy-datum date = USER } um { sy-uzeit time = USER } Uhr  | TO ct_prot_table.
  APPEND '' TO ct_prot_table.
  APPEND |    Ende der Liste;   Erstelldatum: { iv_beginn_datum DATE = USER } { iv_beginn_uzeit+0(2) }:{ iv_beginn_uzeit+2(2) }| TO ct_prot_table.
  APPEND '' TO ct_prot_table.
  APPEND '    Absender: SAP - T-Systems NL Frankfurt am Main' TO ct_prot_table.
  endmethod.


  method CREATE_APN_HEADER.
  APPEND '' TO ct_prot_table.
  APPEND |    Einzelplan { is_apn_header-einzelplan }, DST { is_apn_header-dienststelle }, Echt-Betrieb| TO ct_prot_table.
  APPEND '    -------------------------------------' TO ct_prot_table.
  APPEND '' TO ct_prot_table.
  APPEND |    Prozessnachrichten Batch-Input: Schnittstelle { is_apn_header-verfahrenskuerzel }| TO ct_prot_table.
  APPEND '' TO ct_prot_table.
  APPEND '    **** Prozess gestartet ****' TO ct_prot_table.
  APPEND |    am { iv_beginn_datum DATE = USER } um { iv_beginn_uzeit TIME = USER } Uhr| TO ct_prot_table.
  APPEND |    Beginn der Bearbeitung der Datei: { iv_filename } | TO ct_prot_table.
  APPEND |    >>>>> { iv_count_records } Saetze aus Datei gelesen. | TO ct_prot_table.
  APPEND |    >>>>> { iv_count_records - iv_failed_records } Saetze aus Datei geladen. | TO ct_prot_table.


************************Original Code******************************
*  APPEND '' TO lt_table.
*  APPEND |    Einzelplan { ls_apn_kopf-einzelplan }, DST { ls_apn_kopf-dienststelle }, Echt-Betrieb| TO lt_table.
*  APPEND '    -------------------------------------' TO lt_table.
*  APPEND '' TO lt_table.
*  APPEND |    Prozessnachrichten Batch-Input: Schnittstelle { ls_apn_kopf-verfahrenskuerzel }| TO lt_table.
*  APPEND '' TO lt_table.
*  APPEND '    **** Prozess gestartet ****' TO lt_table.
*  Lv_anzahl_zeilen = 0.
*  Lv_anzahl_zeilen_fehlerhaft = 0.
*  LOOP AT lt_apn_zeilen ASSIGNING FIELD-SYMBOL(<ls_apn_buchungscode>).
*    Lv_anzahl_zeilen = lv_anzahl_zeilen + 1.
*    IF <ls_apn_buchungscode>-ao_proc_status <> 's' AND <ls_apn_buchungscode>-ao_proc_status <> 'w'.
*      lv_anzahl_zeilen_fehlerhaft = lv_anzahl_zeilen_fehlerhaft + 1.
*    ENDIF.
*  ENDLOOP.
*  APPEND |    >>>>> { lv_anzahl_zeilen } Saetze aus datei gelesen. | TO lt_table.
*  APPEND |    >>>>> { lv_anzahl_zeilen - lv_anzahl_zeilen_fehlerhaft } Saetze aus datei geladen. | TO lt_table.
************************Original Code******************************
  endmethod.


  METHOD create_csv_err_body.
    DATA: lt_msgs   TYPE bapiret2_tt,
          lv_status TYPE /aif/proc_status,
          lv_errtxt TYPE string.

    rv_has_errors = abap_false.

    LOOP AT it_lst ASSIGNING FIELD-SYMBOL(<ls_lst>).
      get_err_for_glblid(
        EXPORTING
          is_data   = is_data
          iv_glblid = <ls_lst>-glblid
        IMPORTING
          ev_status = lv_status
          et_msgs   = lt_msgs ).

      " Include explicit E/A status; also include status-less records that carry
      " E/A messages (proc_status can stay initial when FI posting fails silently).
      " Exclude records not found in any sub-table (status and msgs both empty).
      CHECK lv_status = 'E' OR lv_status = 'A'
         OR ( lv_status IS INITIAL
              AND ( line_exists( lt_msgs[ type = 'E' ] )
                    OR line_exists( lt_msgs[ type = 'A' ] ) ) ).
      rv_has_errors = abap_true.

      DATA(ls_err) = COND bapiret2(
        WHEN line_exists( lt_msgs[ type = 'E' ] ) THEN lt_msgs[ type = 'E' ]
        WHEN line_exists( lt_msgs[ type = 'A' ] ) THEN lt_msgs[ type = 'A' ] ).

      DATA(lv_errnr) = COND string(
        WHEN ls_err IS NOT INITIAL THEN |{ ls_err-id }/{ ls_err-number }| ).
      CLEAR lv_errtxt.
      IF ls_err IS NOT INITIAL.
        MESSAGE ID ls_err-id TYPE ls_err-type
          NUMBER ls_err-number
          WITH ls_err-message_v1 ls_err-message_v2
               ls_err-message_v3 ls_err-message_v4
          INTO lv_errtxt.
      ENDIF.

      APPEND escape_csv( |{ <ls_lst>-typ }|     ) && ';' &&
             escape_csv( |{ <ls_lst>-quelle }|  ) && ';' &&
             escape_csv( |{ <ls_lst>-satznr }|  ) && ';' &&
             escape_csv( |{ <ls_lst>-pos }|     ) && ';' &&
             escape_csv( |{ <ls_lst>-kap }|     ) && ';' &&
             escape_csv( |{ <ls_lst>-titel }|   ) && ';' &&
             escape_csv( |{ <ls_lst>-ukto }|    ) && ';' &&
             escape_csv( |{ <ls_lst>-oeh }|     ) && ';' &&
             escape_csv( |{ <ls_lst>-faellig }| ) && ';' &&
             escape_csv( |{ <ls_lst>-soll }|    ) && ';' &&
             escape_csv( lv_errnr               ) && ';' &&
             escape_csv( lv_errtxt              )
        TO ct_csv_table.
    ENDLOOP.
  ENDMETHOD.


  METHOD create_lst_body.
    DATA: lt_string_tab TYPE STANDARD TABLE OF swastrtab.
    DATA: lt_error_tab TYPE string_table.
    DATA: lt_msgs TYPE bapiret2_tt.
    DATA: lv_kassz TYPE xblnr.
    DATA: lv_netdt TYPE netdt.
    DATA: lv_sap_objid TYPE CA_OBTAB.

    FIELD-SYMBOLS: <lt_object> TYPE STANDARD TABLE.

    LOOP AT it_lst ASSIGNING FIELD-SYMBOL(<ls_lst>).
      DATA(lv_status) = get_processing_status(
                          EXPORTING
                          is_data   = is_data                 " Output Struktur
                          iv_glblid = <ls_lst>-glblid                 " Globale Beleg ID (Konkatenation aus dstnr,hhj,quelle,qbelnr)
                          iv_sst = |{ conv string( <ls_lst>-verfahrenskuerzel ) CASE = UPPER }|
                          iv_btyp = |{ conv string( <ls_lst>-typ ) CASE = UPPER }|
                          IMPORTING
                            et_msgs = lt_msgs
                            ev_kassz = lv_kassz
                            ev_sap_objid = lv_sap_objid
                            ev_netdt  = lv_netdt
                        ).
      CASE lv_status.
        WHEN: 'S'.
          "im Erfolgsfall
          create_lst_success(
            EXPORTING
              is_lst        = <ls_lst>                 " HKR: AIF Struktur für LST
              is_data       = is_data                 " Output Struktur
              iv_kassz      = lv_kassz
              iv_sap_objid  = lv_sap_objid
              iv_netdt      = lv_netdt
            CHANGING
              ct_prot_table = ct_prot_table                 " Tabelle von Strings
          ).
        WHEN: 'E' OR '' OR 'A'.
          create_lst_error(
            EXPORTING
              is_lst       =  <ls_lst>                " HKR: AIF Struktur für LST
              it_msgs      = lt_msgs
            CHANGING
              ct_error_tab = lt_error_tab                 " Tabelle von Strings
          ).
      ENDCASE.
    ENDLOOP.

    APPEND LINES OF lt_error_tab to ct_prot_table.
*  IF <ls_data> IS ASSIGNED AND <ls_data> IS NOT INITIAL.
*    LOOP AT lt_lst INTO DATA(ls_lst).
*      "Hier fängt die Logik der einzelnen Datensätze an. Templates werden mit Daten aus der Struktur ls_lst gefüllt
*      lv_template_zeile_1 = |{ ls_lst-typ } { ls_lst-quelle } { ls_lst-satznr } { ls_lst-pos } { ls_lst-kap } { ls_lst-titel } { ls_lst-ukto } { ls_lst-oeh } { ls_lst-faellig } { ls_lst-soll }|.
*      lv_template_zeile_2 = |{ ls_lst-kassenzeichen } { ls_lst-bvbreferenz } { ls_lst-aktenzeichen } { ls_lst-buchnr }|.
*      lv_template_zeile_3 = |{ ls_lst-name } { ls_lst-plz } { ls_lst-ort } { ls_lst-huelnr }|.
*      lv_template_zeile_4 = |{ ls_lst-zahlungsgrund }|.
*      "Strings werden in die Tabelle gefüllt
*      APPEND lv_template_zeile_1 TO lt_table. "erste Zeile des jeweiligen Datensatzes
*      APPEND lv_template_zeile_2 TO lt_table. "zweite Zeile des jeweiligen Datensatzes
*      APPEND lv_template_zeile_3 TO lt_table. "dritte Zeile des jeweiligen Datensatzes
*      APPEND lv_template_zeile_4 TO lt_table. "vierte Zeile des jeweiligen Datensatzes
*      APPEND lv_trenner TO lt_table. "Datensatzende
*    ENDLOOP.
*  ENDIF.
  ENDMETHOD.


  method CREATE_LST_ERROR.
    DATA: lt_string_tab TYPE STANDARD TABLE OF swastrtab.

 "erste Zeile der Fehlertabelle.
          APPEND |{ 'Fehler' WIDTH = 80 PAD = space }| TO ct_error_tab.
          "Zweite Zeile
          APPEND |{ is_lst-typ WIDTH = 4 PAD = space }| &&
          |{ is_lst-quelle WIDTH = 9 PAD = space }| &&
          |{ is_lst-satznr WIDTH = 9 PAD = space }| &&
          |{ is_lst-pos  WIDTH = 4 PAD = space }| &&
          |{ is_lst-kap  WIDTH = 5 PAD = space }| &&
          |{ is_lst-titel WIDTH = 7 PAD = space }| &&
          |{ is_lst-ukto  WIDTH = 7 PAD = space } | &&
          |{ is_lst-oeh  WIDTH = 9 PAD = space }| &&
          |{ CONV dats( is_lst-faellig ) DATE = USER }| &&
          |{ COND string( WHEN CONV i( is_lst-soll ) > 0 THEN '+' ELSE '-' ) && replace( val = is_lst-soll sub = '-' with ='' ) ALIGN = RIGHT WIDTH = 15 PAD = space }| TO ct_error_tab.
          "dritte Zeile && weitere zeilen
          LOOP AT it_msgs ASSIGNING FIELD-SYMBOL(<ls_msg>) WHERE type = 'E' OR type = 'A'.
            APPEND |{ 'Fehlerklasse:' WIDTH = 14 PAD = space }| &&
            |{ <ls_msg>-id WIDTH = 20 PAD = space }| &&
            |{ 'Fehlernummer:' WIDTH = 14 PAD = space }| &&
            |{ <ls_msg>-number WIDTH = 3 PAD = space }| TO ct_error_tab.

            "Nachrichtentext erstellen
            MESSAGE ID <ls_msg>-id TYPE <ls_msg>-type NUMBER <ls_msg>-number
            WITH <ls_msg>-message_v1 <ls_msg>-message_v2 <ls_msg>-message_v3 <ls_msg>-message_v4
            INTO DATA(lv_text).

            "Text umbrechen
            CALL FUNCTION 'SWA_STRING_SPLIT'
              EXPORTING
                input_string                 = lv_text
                max_component_length         = 80
*               TERMINATING_SEPARATORS       =
*               OPENING_SEPARATORS           =
              TABLES
                string_components            = lt_string_tab
              EXCEPTIONS
                max_component_length_invalid = 1
                OTHERS                       = 2.
            IF sy-subrc <> 0.
              APPEND gc_emtpy_row TO ct_error_tab.
            ELSE.
              LOOP AT lt_string_tab ASSIGNING FIELD-SYMBOL(<ls_text>).
                APPEND |{ <ls_text>-str }| TO ct_error_tab.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
          "Datensatzende
          APPEND gc_seperator_line TO ct_error_tab.
  endmethod.


  METHOD escape_csv.
    DATA(lv_special) = ';"' && cl_abap_char_utilities=>newline.
    DATA(lv_trimmed) = condense( iv_value ).
    rv_escaped = COND #(
      WHEN lv_trimmed CA lv_special
      THEN |"{ replace( val = lv_trimmed sub = '"' with = '""' occ = 0 ) }"|
      ELSE lv_trimmed ).
  ENDMETHOD.


  method CREATE_LST_FOOTER.

      APPEND gc_emtpy_row TO ct_prot_table.
  APPEND gc_emtpy_row TO ct_prot_table.
  APPEND |Ende der Liste;   Verarbeitungsdatum: { |{ iv_beginn_datum DATE = USER } { iv_beginn_uzeit+0(2) }:{ iv_beginn_uzeit+2(2) }| }                          | TO ct_prot_table.
  APPEND gc_emtpy_row TO ct_prot_table.
  APPEND gc_emtpy_row TO ct_prot_table.
  APPEND 'Absender: SAP - T-Systems, NL Frankfurt am Main                         ' TO ct_prot_table.

*    APPEND lv_leerzeile TO lt_table.
*  APPEND lv_leerzeile TO lt_table.
*  APPEND |Ende der Liste;   Verarbeitungsdatum: { lv_formatted }                          | TO lt_table.
*  APPEND lv_leerzeile TO lt_table.
*  APPEND lv_leerzeile TO lt_table.
*  APPEND 'Absender: SAP - T-Systems, NL Frankfurt am Main                         ' TO lt_table.
  endmethod.


  method CREATE_LST_HEADER.
  APPEND | Übergabeprotokoll BI{ iv_quelle }.{ iv_vkuerzel }.{ iv_stelle } - Teil 1: Buchungen                       | TO ct_prot_table. " Zeile 1
  APPEND gc_emtpy_row TO ct_prot_table. " Zeile 2
  APPEND 'Typ Quelle   Satz-Nr  Pos Kap  Titel  Ukto   OEH      Fällig                Soll' TO ct_prot_table. " Zeile 3
  APPEND 'Kassenzeichen     BVB/Referenz               Aktenzeichen               Buch-Nr.' TO ct_prot_table. " Zeile 4
  APPEND 'Name                                         PLZ   Ort                   HÜL-Nr.' TO ct_prot_table. " Zeile 5
  APPEND 'Zahlungsgrund                                                                   ' TO ct_prot_table. " Zeile 6
  APPEND gc_seperator_line TO ct_prot_table. " Zeile 7


*    lv_quelle = lt_lst[ 1 ]-quelle.
*  lv_vkuerzel = lt_lst[ 1 ]-verfahrenskuerzel.
*  lv_stelle = lt_lst[ 1 ]-dienststelle.
*
*
*
*  APPEND | Übergabeprotokoll BI{ lv_quelle }.{ lv_vkuerzel }.{ lv_stelle } - Teil 1: Buchungen                       | TO lt_table. " Zeile 1
*  APPEND lv_leerzeile TO lt_table. " Zeile 2
*  APPEND 'Typ Quelle   Satz-Nr  Pos Kap  Titel  Ukto   OEH      Fällig                Soll' TO lt_table. " Zeile 3
*  APPEND 'Kassenzeichen     BVB/Referenz               Aktenzeichen               Buch-Nr.' TO lt_table. " Zeile 4
*  APPEND 'Name                                         PLZ   Ort                   HÜL-Nr.' TO lt_table. " Zeile 5
*  APPEND 'Zahlungsgrund                                                                   ' TO lt_table. " Zeile 6
*  APPEND lv_trenner TO lt_table. " Zeile 7
  endmethod.


  METHOD create_lst_success.
    DATA: lt_string_tab TYPE STANDARD TABLE OF swastrtab.

    "Strings werden in die Tabelle gefüllt
    "erste Zeile des jeweiligen Datensatzes
    APPEND |{ is_lst-typ WIDTH = 4 PAD = space }| &&
    |{ is_lst-quelle WIDTH = 9 PAD = space }| &&
    |{ is_lst-satznr WIDTH = 9 PAD = space }| &&
    |{ is_lst-pos  WIDTH = 4 PAD = space }| &&
    |{ is_lst-kap  WIDTH = 5 PAD = space }| &&
    |{ is_lst-titel WIDTH = 7 PAD = space }| &&
    |{ is_lst-ukto  WIDTH = 7 PAD = space } | &&
    |{ is_lst-oeh  WIDTH = 9 PAD = space }| &&
    |{ CONV dats( cond #( WHEN is_lst-faellig is INITIAL then iv_netdt
                          else is_lst-faellig ) ) DATE = USER WIDTH = 10 }| &&
    |{ COND string( WHEN CONV i( is_lst-soll ) > 0 THEN '+' ELSE '-' ) && replace( val = is_lst-soll sub = '-' with = '' ) ALIGN = RIGHT WIDTH = 15 PAD = space }| TO ct_prot_table.
    "zweite Zeile des jeweiligen Datensatzes
*    DATA(lv_kassz) = is_lst-kassenzeichen.
*    IF is_data-ao IS NOT INITIAL.
*      TRY.
*          get_treasury_id(
*            EXPORTING
*              iv_belnr = is_data-ao[ glblid = is_lst-glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
*              iv_bukrs = is_data-ao[ glblid = is_lst-glblid ]-bukrs                 " Buchungskreis
*              iv_gjahr = is_data-ao[ glblid = is_lst-glblid ]-gjahr                 " Feld vom Typ DATS
*            CHANGING
*              cv_kassz = lv_kassz                 " Feld der Laenge 17
*          ).
*        CATCH cx_sy_itab_line_not_found.
*          "Sollabgan, Sollzugang.
*          "befindet sich in AO-Reference
*          TRY.
*              get_treasury_id(
*                EXPORTING
*                  iv_belnr = is_data-ao_reference[ glblid = is_lst-glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
*                  iv_bukrs = is_data-ao_reference[ glblid = is_lst-glblid ]-bukrs                 " Buchungskreis
*                  iv_gjahr = is_data-ao_reference[ glblid = is_lst-glblid ]-gjahr                 " Feld vom Typ DATS
*                CHANGING
*                  cv_kassz = lv_kassz                 " Feld der Laenge 17
*                  ).
*            CATCH cx_sy_itab_line_not_found.
*              "Anordungen haben Kassenzeichen.
*              "Mittelbindungen nicht. Daher keine weitere Prüfung
*              CLEAR: lv_kassz.
*          ENDTRY.
*      ENDTRY.
*    ENDIF.
    APPEND |{ iv_kassz WIDTH = 18 PAD = space }| &&
    |{ is_lst-bvbreferenz WIDTH = 27 PAD = space }| &&
    |{ is_lst-aktenzeichen WIDTH = 25 PAD = space }| &&
    |{ iv_sap_objid WIDTH = 10 PAD = space }| TO ct_prot_table.
    "dritte Zeile des jeweiligen Datensatzes
    APPEND |{ is_lst-name WIDTH = 45 PAD = space }| &&
    |{ is_lst-plz WIDTH = 6 PAD = space }| &&
    |{ is_lst-ort WIDTH = 22 PAD = space }| &&
    |{ is_lst-huelnr WIDTH = 7 PAD = space }| TO ct_prot_table.
    "vierte Zeile des jeweiligen Datensatzes
    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string                 = CONV string( is_lst-zahlungsgrund )
        max_component_length         = 80
*       TERMINATING_SEPARATORS       =
*       OPENING_SEPARATORS           =
      TABLES
        string_components            = lt_string_tab
      EXCEPTIONS
        max_component_length_invalid = 1
        OTHERS                       = 2.
    IF sy-subrc <> 0.
      APPEND gc_emtpy_row TO ct_prot_table.
    ELSE.
      LOOP AT lt_string_tab ASSIGNING FIELD-SYMBOL(<ls_text>).
        APPEND |{ <ls_text>-str }| TO ct_prot_table.
      ENDLOOP.
    ENDIF.
    "Datensatzende
    APPEND gc_seperator_line TO ct_prot_table.
  ENDMETHOD.


  METHOD get_apn_get_number_ranges.
    DATA: ls_ausao_range TYPE ty_s_ao_number_range.
    DATA: ls_annao_range TYPE ty_s_ao_number_range.
    DATA: ls_absao_range TYPE ty_s_ao_number_range.

**************************************************************************************
*                       Annahme- und Auszahlungsanordnungen                          *
**************************************************************************************
    LOOP AT is_data-ao ASSIGNING FIELD-SYMBOL(<ls_ao>).
      IF <ls_ao>-belnr IS NOT INITIAL.
        CASE: <ls_ao>-psoty.
          WHEN: '01'.
            "Auszahlung
            "1. Annordnungsnummer
            append_ao_number_range(
              iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
              iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
*             iv_last  =                  " Bündelungskennzeichen für Belege
            ).
            "letzte Anordnungsnummer
            append_ao_number_range(
               iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
*             iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
               iv_last  = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
             ).
          WHEN: '02'.
            "Annahmeanordnung
            "1. Annordnungsnummer
            append_ao_number_range(
              iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
              iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
*             iv_last  =                  " Bündelungskennzeichen für Belege
            ).
            "letzte Anordnungsnummer
            append_ao_number_range(
               iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
*             iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
               iv_last  = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
             ).
        ENDCASE.
      ENDIF.
    ENDLOOP.
**************************************************************************************
*                       Sollzugang und Sollabgang                                    *
**************************************************************************************

    LOOP AT is_data-ao_reference ASSIGNING <ls_ao>.
      IF <ls_ao>-belnr IS NOT INITIAL.
        CASE: <ls_ao>-psoty.
          WHEN: '04' OR '05'.
            "Absetzungsanordnung
            "1. Annordnungsnummer
            append_ao_number_range(
              iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
              iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
*             iv_last  =                  " Bündelungskennzeichen für Belege
            ).
            "letzte Anordnungsnummer
            append_ao_number_range(
               iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
*             iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
               iv_last  = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
             ).
          WHEN: '02'.
            "Sollzugang
            "1. Annordnungsnummer
            append_ao_number_range(
              iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
              iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
*             iv_last  =                  " Bündelungskennzeichen für Belege
            ).
            "letzte Anordnungsnummer
            append_ao_number_range(
               iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
*             iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
               iv_last  = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
             ).
        ENDCASE.
      ENDIF.
    ENDLOOP.
**************************************************************************************
*                               Stundung                                             *
**************************************************************************************
    LOOP AT is_data-ao_stu ASSIGNING <ls_ao>.
      IF <ls_ao>-belnr IS NOT INITIAL.
        CASE: <ls_ao>-psoty.
          WHEN: '06'.
            "Stundungsanordnung
            "1. Annordnungsnummer
            append_ao_number_range(
              iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
              iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
*             iv_last  =                  " Bündelungskennzeichen für Belege
            ).
            "letzte Anordnungsnummer
            append_ao_number_range(
               iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
*             iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
               iv_last  = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
             ).
        ENDCASE.
      ENDIF.
    ENDLOOP.
**************************************************************************************
*                               Verrechnungsanordnung                                *
**************************************************************************************
    LOOP AT is_data-ao_stu ASSIGNING <ls_ao>.
      IF <ls_ao>-belnr IS NOT INITIAL.
        CASE: <ls_ao>-psoty.
          WHEN: '03'.
            "Verrechnungsanordnung
            "1. Annordnungsnummer
            append_ao_number_range(
              iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
              iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
*             iv_last  =                  " Bündelungskennzeichen für Belege
            ).
            "letzte Anordnungsnummer
            append_ao_number_range(
               iv_psoty = <ls_ao>-psoty                 " Belegtypen Zahlungsanordnung Kommunen
*             iv_first = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
               iv_last  = <ls_ao>-lotkz                 " Bündelungskennzeichen für Belege
             ).
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_filepath.
    DATA lv_filename TYPE filename-fileintern.

    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        logical_filename = iv_logical_filename
        operating_system = 'Linux'
        parameter_1      = iv_filename
      IMPORTING
        file_name        = lv_filename
      EXCEPTIONS
        file_not_found   = 1
        OTHERS           = 2.
    r_filename = lv_filename.
  ENDMETHOD.


  METHOD get_mails_for_recipient_list.
    DATA:
      lt_alrt_user   TYPE TABLE OF /aif/t_alrt_user,
      lt_alrt_role   TYPE TABLE OF /aif/t_alrt_role,
      lt_agr_users   TYPE /aif/api_cust_alrt_user_tt,
      lt_alrt_ext    TYPE TABLE OF /aif/t_alrt_ext,
      lt_ext_contact TYPE TABLE OF /aif/ext_contact.

    SELECT uname FROM /aif/t_alrt_user INTO CORRESPONDING FIELDS OF TABLE @lt_alrt_user WHERE NSRECIPIENT = @is_recipient_list-ns
                                                                                          AND recipient = @is_recipient_list-recipient.
      if sy-subrc = 0.
        CALL METHOD add_mails_from_usernames EXPORTING it_alrt_user = lt_alrt_user CHANGING ct_mail_recipients = ct_mail_recipients.
        CLEAR lt_alrt_user.
      endif.

    SELECT agr_name FROM /aif/t_alrt_role INTO CORRESPONDING FIELDS OF TABLE @lt_alrt_role WHERE NSRECIPIENT = @is_recipient_list-ns
                                                                                          AND recipient = @is_recipient_list-recipient.
    IF lt_alrt_role IS NOT INITIAL.
      SELECT uname
        FROM agr_users
        INTO CORRESPONDING FIELDS OF TABLE @lt_alrt_user
        FOR ALL ENTRIES IN @lt_alrt_role
        WHERE agr_name = @lt_alrt_role-agr_name AND from_dat <= @sy-datum AND to_dat >= @sy-datum.
      CALL METHOD add_mails_from_usernames EXPORTING it_alrt_user = lt_alrt_user CHANGING ct_mail_recipients = ct_mail_recipients.
    ENDIF.

    SELECT smtpadr
      FROM /aif/ext_contact as mail
    inner JOIN /aif/t_alrt_ext as contact
      on contact~contact_guid = mail~contact_guid
     WHERE contact~nsrecipient = @is_recipient_list-ns
      AND contact~recipient = @is_recipient_list-recipient
      into TABLE @DATA(lt_smtp).

*    SELECT contact_guid FROM /aif/t_alrt_ext INTO CORRESPONDING FIELDS OF TABLE @lt_alrt_ext WHERE NSRECIPIENT = @is_recipient_list-ns
*                                                                                               AND recipient = @is_recipient_list-recipient.
*    if sy-subrc = 0.
*    SELECT smtpadr FROM /aif/ext_contact INTO CORRESPONDING FIELDS OF TABLE @lt_ext_contact FOR ALL ENTRIES IN @lt_alrt_ext WHERE contact_guid = @lt_alrt_ext-contact_guid.
    LOOP AT lt_smtp ASSIGNING FIELD-SYMBOL(<ls_smpt>).
      TRANSLATE <ls_smpt>-smtpadr TO LOWER CASE.
      APPEND <ls_smpt>-smtpadr TO ct_mail_recipients[].
    ENDLOOP.


    SORT ct_mail_recipients.
    DELETE ADJACENT DUPLICATES FROM ct_mail_recipients.

  ENDMETHOD.


  method GET_NETDT_FROM_BSEG.
    "Ermittlung der Nettofälligkeit aus Kreditor- oder Debitorzeile
    "Wenn nichts gefunden wurde, dann Fälligkeit mit Systemdatum belegen
    SELECT single NETDT
      FROM BSEG
     WHERE bukrs = @iv_bukrs
       and belnr = @iv_belnr
       and gjahr = @iv_gjahr
       and ( koart = 'K'
        OR   koart = 'D' )
      into @rv_netdt.
      if sy-subrc = 0.
        rv_netdt = sy-datum.
      endif.
  endmethod.


  METHOD get_processing_status.
    "Loop über interne Tabelle anstatt Read Table, weil es passieren kann,
    "dass zu einer globalen Kennung (GLBLID) mehere Datensätze erzeugt werden
    "zum Beispiel bei Auszahlungen mit Referenz auf Einnahmesollstellungen (Allerdings existiert nur die Auszahlung in der BIC-Datei)
    "1. Datensatz = Annahmeanordnung
    "2. Datensatz = Auszahlungsanordnung
    DATA: lv_kassz TYPE char17.
    DATA: ls_t_check TYPE  /aif/t_check.
    DATA: ls_TABCHK TYPE  /aif/t_tabchk.
    DATA: lt_return TYPE STANDARD TABLE OF BAPIRET2.
    DATA: lv_error TYPE Flag.

    CLEAR: rv_status,
           et_msgs.
*********************************************************************
*                         Prüfung Buchungscode                      *
*********************************************************************
    "APN Protokoll liefert diese Felder nicht. Keine Prüfung notwendig
    "LST Protokoll liefert diese Felder. Prüfung wird ausgeführt
    IF iv_btyp IS NOT INITIAL AND iv_sst IS NOT INITIAL.
      ls_t_check-mandt = ls_tabchk-mandt = sy-mandt.
      ls_t_check-ns = ls_tabchk-ns = 'ZALLGE'.
      ls_t_check-aifcheck = ls_tabchk-aifcheck = 'CHK_BTYP_SST'.
      ls_tabchk-fuba_check = '/THKR/AIF_ZALLGE_CHK_BTYP_SUPP'.
      CALL FUNCTION '/THKR/AIF_ZALLGE_CHK_BTYP_SUPP'
        EXPORTING
          data_struct = is_data
          data_line   = is_data
          data_field  = '01_BTYP'
*         MSGTY       = 'E'
          value1      = 'ZALLGE'
          value2      = 'MAP_/THKR/SST'
          value3      = iv_sst
          value4      = iv_btyp
          value5      = ''
*         T_IFCHECK   =
*         T_IFACT     =
*         T_ACCHECK   =
*         T_FUNC      =
*         T_FMAPCOND  =
          t_check     = ls_t_check
          t_tabchk    = ls_tabchk
*         SENDING_SYSTEM       =
        TABLES
          return_tab  = lt_return
          data_table  = is_data-lst
        CHANGING
          error       = lv_error.
    ELSE.
      "Die Felder Schnittstelle und BIC-Buchungscode wurden nicht übergeben.
      "Demnach auch keine Prüfung.
      lv_error = abap_false.
    ENDIF.
    IF lv_error = abap_true.
      IF 1 = 0. MESSAGE e001(/thkr/sst).ENDIF.
      APPEND VALUE bapiret2( type   = 'E'
                                 id     = '/THKR/SST'
                                 number = 001
                                 message_v1 = |Zur Schnittstelle { iv_sst }|
                                 message_v2 = | ist der Buchungsschlüssel { iv_btyp }|
                                 message_v3 = | nicht vorgesehen und kann|
                                 message_v4 = | nicht verarbeitet werden.| ) TO et_msgs.
      rv_status = 'E'.
    ELSE.

*********************************************************************
*                         Lese Anordnungen                          *
*********************************************************************
      LOOP AT is_data-ao ASSIGNING FIELD-SYMBOL(<ls_ao>) WHERE glblid = iv_glblid.
        IF <ls_ao>-ao_proc_status = 'E' OR
           <ls_ao>-ao_proc_status = 'A' OR
           <ls_ao>-ao_proc_status IS INITIAL.
          rv_status = <ls_ao>-ao_proc_status.
          et_msgs = is_data-ao[ glblid = iv_glblid ]-msg.
          IF is_data-ao[ glblid = iv_glblid ]-xblnr IS INITIAL.
            get_treasury_id(
              EXPORTING
                iv_belnr = is_data-ao[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                iv_bukrs = is_data-ao[ glblid = iv_glblid ]-bukrs                 " Buchungskreis
                iv_gjahr = is_data-ao[ glblid = iv_glblid ]-gjahr                 " Feld vom Typ DATS
              CHANGING
                cv_kassz = lv_kassz                 " Feld der Laenge 17
            ).
            ev_kassz = lv_kassz.
          ELSE.
            ev_kassz = is_data-ao[ glblid = iv_glblid ]-xblnr.
          ENDIF.
          EXIT.
        ELSE.
          rv_status = <ls_ao>-ao_proc_status.
          ev_sap_objid = <ls_ao>-lotkz.
          IF is_data-ao[ glblid = iv_glblid ]-xblnr IS INITIAL.
            get_treasury_id(
              EXPORTING
                iv_belnr = is_data-ao[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                iv_bukrs = is_data-ao[ glblid = iv_glblid ]-bukrs                 " Buchungskreis
                iv_gjahr = is_data-ao[ glblid = iv_glblid ]-gjahr                 " Feld vom Typ DATS
              CHANGING
                cv_kassz = lv_kassz                 " Feld der Laenge 17
            ).
            ev_kassz = lv_kassz.
          ELSE.
            ev_kassz = is_data-ao[ glblid = iv_glblid ]-xblnr.
          ENDIF.
          ev_netdt = get_netdt_from_bseg(
                       iv_bukrs = is_data-ao[ glblid = iv_glblid ]-bukrs                  " Buchungskreis
                       iv_belnr = is_data-ao[ glblid = iv_glblid ]-belnr                  " Belegnummer eines Buchhaltungsbeleges
                       iv_gjahr = is_data-ao[ glblid = iv_glblid ]-gjahr                  " Geschäftsjahr
                     ).
          CONTINUE.
        ENDIF.
      ENDLOOP.
      IF rv_status IS INITIAL.
*********************************************************************
*              Keine AO - Lese Anordnung Referenz                   *
*********************************************************************
        LOOP AT is_data-ao_reference ASSIGNING <ls_ao> WHERE glblid = iv_glblid.
          IF <ls_ao>-ao_proc_status = 'E' OR
             <ls_ao>-ao_proc_status = 'A' OR
             <ls_ao>-ao_proc_status IS INITIAL.
            rv_status = <ls_ao>-ao_proc_status.
            et_msgs = is_data-ao_reference[ glblid = iv_glblid ]-msg.
            IF is_data-ao_reference[ glblid = iv_glblid ]-xblnr IS INITIAL.
              get_treasury_id(
                EXPORTING
                  iv_belnr = is_data-ao_reference[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                  iv_bukrs = is_data-ao_reference[ glblid = iv_glblid ]-bukrs                 " Buchungskreis
                  iv_gjahr = is_data-ao_reference[ glblid = iv_glblid ]-gjahr                 " Feld vom Typ DATS
                CHANGING
                  cv_kassz = lv_kassz                  " Feld der Laenge 17
              ).
              ev_kassz = lv_kassz.
            ELSE.
              ev_kassz = is_data-ao_reference[ glblid = iv_glblid ]-xblnr.
            ENDIF.

            EXIT.
          ELSE.
            rv_status = <ls_ao>-ao_proc_status.
            ev_sap_objid = <ls_ao>-lotkz.
            IF is_data-ao_reference[ glblid = iv_glblid ]-xblnr IS INITIAL.
              get_treasury_id(
                EXPORTING
                  iv_belnr = is_data-ao_reference[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                  iv_bukrs = is_data-ao_reference[ glblid = iv_glblid ]-bukrs                 " Buchungskreis
                  iv_gjahr = is_data-ao_reference[ glblid = iv_glblid ]-gjahr                 " Feld vom Typ DATS
                CHANGING
                  cv_kassz = lv_kassz                  " Feld der Laenge 17
              ).
              ev_kassz = lv_kassz.
            ELSE.
              ev_kassz = is_data-ao_reference[ glblid = iv_glblid ]-xblnr.
            ENDIF.
            ev_netdt = get_netdt_from_bseg(
               iv_bukrs = is_data-ao_reference[ glblid = iv_glblid ]-bukrs                  " Buchungskreis
               iv_belnr = is_data-ao_reference[ glblid = iv_glblid ]-belnr                  " Belegnummer eines Buchhaltungsbeleges
               iv_gjahr = is_data-ao_reference[ glblid = iv_glblid ]-gjahr                  " Geschäftsjahr
             ).
            CONTINUE.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF rv_status IS INITIAL.
*********************************************************************
*                keine AO Referenz - Lese Mittelbindung             *
*********************************************************************
        LOOP AT is_data-mb ASSIGNING FIELD-SYMBOL(<ls_mb>) WHERE glblid = iv_glblid.
          IF <ls_mb>-mv_proc_status = 'E' OR
             <ls_mb>-mv_proc_status = 'A' OR
             <ls_mb>-mv_proc_status IS INITIAL.
            rv_status = <ls_mb>-mv_proc_status.
            et_msgs = is_data-mb[ glblid = iv_glblid ]-msg.
            IF is_data-mb[ glblid = iv_glblid ]-xblnr IS INITIAL.
              get_treasury_id_mb(
                EXPORTING
                  iv_belnr = is_data-mb[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                CHANGING
                  cv_kassz = lv_kassz                  " Feld der Laenge 17
              ).
              ev_kassz = lv_kassz.
            ELSE.
              ev_kassz = is_data-mb[ glblid = iv_glblid ]-xblnr.
            ENDIF.

            EXIT.
          ELSE.
            rv_status = <ls_mb>-mv_proc_status.
            ev_sap_objid = <ls_mb>-belnr.
            IF is_data-mb[ glblid = iv_glblid ]-xblnr IS INITIAL.
              get_treasury_id_mb(
                EXPORTING
                  iv_belnr = is_data-mb[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                CHANGING
                  cv_kassz = lv_kassz                  " Feld der Laenge 17
              ).
              ev_kassz = lv_kassz.
            ELSE.
              ev_kassz = is_data-mb[ glblid = iv_glblid ]-xblnr.
            ENDIF.
            CONTINUE.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF rv_status IS INITIAL.
*********************************************************************
*               Keine MB - Lese MB Änderung                         *
*********************************************************************
        LOOP AT is_data-mb_up ASSIGNING FIELD-SYMBOL(<ls_mb_up>) WHERE glblid = iv_glblid.
          IF <ls_mb_up>-mv_up_proc_status = 'E' OR
             <ls_mb_up>-mv_up_proc_status = 'A' OR
             <ls_mb_up>-mv_up_proc_status IS INITIAL.
            rv_status = <ls_mb_up>-mv_up_proc_status.
            et_msgs = is_data-mb_up[ glblid = iv_glblid ]-msg.
            ev_kassz = iv_kassz.
            EXIT.
          ELSE.
            rv_status = <ls_mb_up>-mv_up_proc_status.
            ev_sap_objid = <ls_mb_up>-belnr.
            CONTINUE.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF rv_status IS INITIAL.
*********************************************************************
*             Keine MB Änderung - Lese Verrechnungsanordnung        *
*********************************************************************
        LOOP AT is_data-vr ASSIGNING FIELD-SYMBOL(<ls_vr>) WHERE glblid = iv_glblid.
          IF <ls_vr>-vr_proc_status = 'E' OR
             <ls_vr>-vr_proc_status = 'A' OR
             <ls_vr>-vr_proc_status IS INITIAL.
            rv_status = <ls_vr>-vr_proc_status.
            et_msgs = is_data-vr[ glblid = iv_glblid ]-msg.
            IF is_data-vr[ glblid = iv_glblid ]-xblnr IS INITIAL.
              get_treasury_id(
                EXPORTING
                  iv_belnr = is_data-vr[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                  iv_bukrs = is_data-vr[ glblid = iv_glblid ]-bukrs                 " Buchungskreis
                  iv_gjahr = is_data-vr[ glblid = iv_glblid ]-gjahr                 " Feld vom Typ DATS
                CHANGING
                  cv_kassz = lv_kassz                  " Feld der Laenge 17
              ).
              ev_kassz = lv_kassz.
            ELSE.
              ev_kassz = is_data-vr[ glblid = iv_glblid ]-xblnr.
            ENDIF.

            EXIT.
          ELSE.
            rv_status = <ls_vr>-vr_proc_status.
            ev_sap_objid = <ls_vr>-lotkz.
            IF is_data-vr[ glblid = iv_glblid ]-xblnr IS INITIAL.
              get_treasury_id(
                EXPORTING
                  iv_belnr = is_data-vr[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                  iv_bukrs = is_data-vr[ glblid = iv_glblid ]-bukrs                 " Buchungskreis
                  iv_gjahr = is_data-vr[ glblid = iv_glblid ]-gjahr                 " Feld vom Typ DATS
                CHANGING
                  cv_kassz = lv_kassz                  " Feld der Laenge 17
              ).
              ev_kassz = lv_kassz.
            ELSE.
              ev_kassz = is_data-vr[ glblid = iv_glblid ]-xblnr.
            ENDIF.
            ev_netdt = get_netdt_from_bseg(
               iv_bukrs = is_data-ao[ glblid = iv_glblid ]-bukrs                  " Buchungskreis
               iv_belnr = is_data-ao[ glblid = iv_glblid ]-belnr                  " Belegnummer eines Buchhaltungsbeleges
               iv_gjahr = is_data-ao[ glblid = iv_glblid ]-gjahr                  " Geschäftsjahr
             ).
            CONTINUE.
          ENDIF.
        ENDLOOP.
      ENDIF.
      IF rv_status IS INITIAL.
*********************************************************************
*            Keine VR - Lese Storno                                 *
*********************************************************************
        LOOP AT is_data-storno ASSIGNING FIELD-SYMBOL(<ls_storno>) WHERE glblid = iv_glblid.
          IF <ls_storno>-proc_status = 'E' OR
             <ls_storno>-proc_status = 'A' OR
             <ls_storno>-proc_status IS INITIAL.
            rv_status = <ls_storno>-proc_status.
            et_msgs = is_data-storno[ glblid = iv_glblid ]-msg.
            IF is_data-storno[ glblid = iv_glblid ]-kassz IS INITIAL.
              get_treasury_id(
                EXPORTING
                  iv_belnr = is_data-storno[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                  iv_bukrs = is_data-storno[ glblid = iv_glblid ]-bukrs                 " Buchungskreis
                  iv_gjahr = is_data-storno[ glblid = iv_glblid ]-gjahr                 " Feld vom Typ DATS
                CHANGING
                  cv_kassz = lv_kassz                  " Feld der Laenge 17
              ).
              ev_kassz = lv_kassz.
            ELSE.
              ev_kassz =  is_data-storno[ glblid = iv_glblid ]-kassz.
            ENDIF.
            EXIT.
          ELSE.
            rv_status = <ls_storno>-proc_status.
            ev_sap_objid = <ls_storno>-lotkz.
            IF is_data-storno[ glblid = iv_glblid ]-kassz IS INITIAL.
              get_treasury_id(
                EXPORTING
                  iv_belnr = is_data-storno[ glblid = iv_glblid ]-belnr                 " Zuordnung Positionsnummern Materialbeleg-Einkaufsbeleg
                  iv_bukrs = is_data-storno[ glblid = iv_glblid ]-bukrs                 " Buchungskreis
                  iv_gjahr = is_data-storno[ glblid = iv_glblid ]-gjahr                 " Feld vom Typ DATS
                CHANGING
                  cv_kassz = lv_kassz                  " Feld der Laenge 17
              ).
              ev_kassz = lv_kassz.
            ELSE.
              ev_kassz = is_data-vr[ glblid = iv_glblid ]-xblnr.
            ENDIF.
            CONTINUE.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  method GET_RECIPIENT_LIST.

SELECT SINGLE NSRECIP, RECIPIENT
  from /THKR/T_PROT_MSD
 WHERE NS = @iv_ns
  and IFNAME = @iv_ifname
  AND IFVERSION = @iv_ifversion
  into @rs_recipient_list.
  if sy-subrc <> 0.
    clear rs_recipient_list.
  ENDIF.
  endmethod.


  method GET_TREASURY_ID.
    if cv_kassz is INITIAL.
      "Kassenzeichen wurde nicht durch das Fremdverfahren mitgegegen
      "SAP hat ein neues erzeugt, welches erst bei der Buchung der Belege
      "erfolgt. Daher wird hier das Kassenzeichen aus dem Belegkopf ermittelt.
      SELECT single XBLNR
        from BKPF
        WHERE bukrs = @iv_bukrs
          AND belnr = @iv_belnr
          AND gjahr = @iv_gjahr
        into @cv_kassz.
        if sy-subrc <> 0.
          "Keinen Beleg gefunden.
          "Kein Kassenzeichen ausgeben
          CLEAR cv_kassz.
        endif.
    endif.
  endmethod.


  method GET_TREASURY_ID_MB.
    if cv_kassz is INITIAL.
      "Kassenzeichen wurde nicht durch das Fremdverfahren mitgegegen
      "SAP hat ein neues erzeugt, welches erst bei der Buchung der Belege
      "erfolgt. Daher wird hier das Kassenzeichen aus dem Belegkopf ermittelt.
      SELECT single XBLNR
        from KBLK
        WHERE belnr = @iv_belnr
        into @cv_kassz.
        if sy-subrc <> 0.
          "Keinen Beleg gefunden.
          "Kein Kassenzeichen ausgeben
          CLEAR cv_kassz.
        endif.
    endif.
  endmethod.


  METHOD overwrite_files.
    CONSTANTS: lc_vmap_run_conf TYPE /AIF/vmapname VALUE 'MAP_RUN_CONFIG'.
    CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_overwrite TYPE /aif/vmap_extval VALUE 'FILES_OVWR'.
    CONSTANTS: lc_asterisk TYPE char1 VALUE '*'.

    "Parameter Dateien überschreiben für Schnittstelle abrufen
    SELECT SINGLE int_value
      FROM /aif/t_mvmapval5
     WHERE ns = @lc_vmap_ns_zallge
       AND vmapname = @lc_vmap_run_conf
       AND ext_value1 = @iv_ns
       AND ext_value2 = @iv_ifname
       AND EXT_value3 = @lc_overwrite
    INTO @rv_overwrite.
    IF sy-subrc <> 0.
      "Kein Parameter Dateien überschreiben für Schnittelle gefunden.
      "Allgemein prüfen.
      SELECT SINGLE int_value
        FROM /aif/t_mvmapval5
       WHERE ns = @lc_vmap_ns_zallge
         AND vmapname = @lc_vmap_run_conf
         AND ext_value1 = @lc_asterisk
         AND ext_value2 = @lc_asterisk
         AND EXT_value3 = @lc_overwrite
        INTO @rv_overwrite.
      IF sy-subrc <> 0.
        "Es gibt auch keinen allgemeinen Eintrag zum Überschreiben der Datei
        "Also Dateien nicht überschreiben.
        CLEAR: rv_overwrite.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD rtf_string_to_binary.
    DATA: lv_rtf_xstring TYPE xstring.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = iv_rtf_string
      IMPORTING
        buffer = lv_rtf_xstring
      EXCEPTIONS
        OTHERS = 1.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lv_rtf_xstring
      TABLES
        binary_tab = rv_attachment
      EXCEPTIONS
        OTHERS     = 1.
  ENDMETHOD.


  METHOD send_mail.
    DATA : lo_mime_helper     TYPE REF TO cl_gbt_multirelated_service,
           lo_bcs             TYPE REF TO cl_bcs,
           lo_doc_bcs         TYPE REF TO cl_document_bcs,
           lo_recipient       TYPE REF TO if_recipient_bcs,
           lt_soli            TYPE TABLE OF soli,
           ls_soli            TYPE soli,
           lv_status          TYPE bcs_rqst,
           lv_attachment      TYPE solix_tab,
           lv_attachment_name TYPE char50.

    CREATE OBJECT lo_mime_helper.

    SPLIT iv_attachment_name AT '/' INTO TABLE DATA(lt_parts).
    READ TABLE lt_parts INTO lv_attachment_name INDEX lines( lt_parts ).
    SPLIT lv_attachment_name AT '.' INTO TABLE DATA(lt_bic_name_parts).
    READ TABLE lt_bic_name_parts INTO DATA(lv_sst_name) INDEX 2.
    lt_soli = cl_document_bcs=>string_to_soli( |Informationen zur Schnittstelle { lv_sst_name }| ).

    TRY.
    " Set the HTML body of the mail
    CALL METHOD lo_mime_helper->set_main_html
      EXPORTING
        content = lt_soli.




* Set the subject of the mail.
    lo_doc_bcs = cl_document_bcs=>create_from_multirelated(
                    i_subject          = |Informationen zur Schnittstelle { lv_sst_name }|
                    i_importance       = '5'                " 1~High Priority  5~Average priority 9~Low priority
                    i_multirel_service = lo_mime_helper ).

    lo_bcs = cl_bcs=>create_persistent( ).

    lo_bcs->set_document( i_document = lo_doc_bcs ).

* Set the email address

        LOOP AT it_mail_recipients INTO DATA(lv_recipient_mail_address).
          lo_recipient = cl_cam_address_bcs=>create_internet_address(
                          i_address_string =  lv_recipient_mail_address ).

          lo_bcs->add_recipient( i_recipient = lo_recipient ).
        ENDLOOP.

        CALL METHOD rtf_string_to_binary EXPORTING iv_rtf_string = iv_attachment_content RECEIVING rv_attachment = lv_attachment.

        lo_doc_bcs->add_attachment(
          i_attachment_type    = CONV so_obj_tp( COND #(
                                   WHEN iv_attachment_type IS SUPPLIED
                                    AND iv_attachment_type IS NOT INITIAL
                                   THEN iv_attachment_type
                                   ELSE 'rtf' ) )
          i_attachment_subject = lv_attachment_name
          i_att_content_hex    = lv_attachment ).



* Change the status.
        lv_status = 'N'.
        CALL METHOD lo_bcs->set_status_attributes
          EXPORTING
            i_requested_status = lv_status.
      CATCH cx_document_bcs INTO DATA(lx_document_bcs).
        rv_success = 'N'.
      CATCH cx_send_req_bcs INTO DATA(lx_send_req_bcs).
        rv_success = 'N'.
        WRITE:/ 'Senden fehlgeschlagen'.
      catch cx_address_bcs into DATA(lx_address_bcs).
        rv_success = 'N'.
      CATCH cx_gbt_mime INTO data(lx_gbt_mime).
        rv_success = 'N'.
      CATCH cx_bcom_mime into DATA(lx_bco_mime).
        rv_success = 'N'.
    ENDTRY.

*&---------------------------------------------------------------------*
*& Send the email
*&---------------------------------------------------------------------*
    TRY.
        lo_bcs->send( ).
        COMMIT WORK.
        rv_success = 'Y'.
      CATCH cx_bcs INTO DATA(lx_bcs).
        ROLLBACK WORK.
    ENDTRY.
  ENDMETHOD.


  METHOD set_apn_status.
    rt_apn_zeilen = it_apn_zeilen.
    ev_count_records = 0.
    ev_failed_records = 0.

    "Auswertung der verarbeiteten Buchungssätze
    LOOP AT rt_apn_zeilen ASSIGNING FIELD-SYMBOL(<fs_apn>).
      ev_count_records += 1.
      <fs_apn>-ao_proc_status = get_processing_status(
                                  is_data   = is_data                 " Output Struktur
                                  iv_glblid = <fs_apn>-glblid                 " Globale Beleg ID (Konkatenation aus dstnr,hhj,quelle,qbelnr)
                                ).
      IF <fs_apn>-ao_proc_status = 'E' OR <fs_apn>-ao_proc_status = 'A' OR <fs_apn>-ao_proc_status = ''.
        " E = Verarbeitungsfehler
        " A = Anwendungsfehler
        " leer = fehlgeschlagene Aktionsprüfung -> E
        ev_failed_records += 1.
      ENDIF.
      "Bearbeitung pro Buchungscode bestimmen
      READ TABLE et_result_per_btyp WITH KEY btyp = <fs_apn>-buchungstyp ASSIGNING FIELD-SYMBOL(<ls_result>).
      IF sy-subrc = 0.
        "Es existiert bereits ein Buchungstyp
        "Summe und Anzahl zu bestehenden Datensatz dazuaddieren
        <ls_result>-total_amount += <fs_apn>-summe.     "Gesamtsumme pro Buchungstyp
        <ls_result>-total_processed += 1.               "Anzahl Buchungen pro Buchungstyp
        IF <fs_apn>-ao_proc_status = 'E' OR <fs_apn>-ao_proc_status = 'A' OR <fs_apn>-ao_proc_status = ''.
          " E = Verarbeitungsfehler
          " A = Anwendungsfehler
          " leer = fehlgeschlagene Aktionsprüfung -> E
          <ls_result>-failed += 1.                       "Anzahl fehlgeschlagener Buchungen
        ELSE.
          <ls_result>-booked_amount += <fs_apn>-summe.  "gebuchte Zahlungen pro Buchungstyp
        ENDIF.
      ELSE.
        "Neuer Buchungstyp
        APPEND INITIAL LINE TO et_result_per_btyp ASSIGNING <ls_result>.
        <ls_result>-btyp = <fs_apn>-buchungstyp.      "Buchungstyp hinzufügen
        <ls_result>-total_amount = <fs_apn>-summe.    "Gesamtsumme pro Buchungstyp
        <ls_result>-total_processed = 1.              "Anzahl Buchungen pro Buchungstyp
        IF <fs_apn>-ao_proc_status = 'E' OR <fs_apn>-ao_proc_status = 'A' OR <fs_apn>-ao_proc_status = ''.
          " E = Verarbeitungsfehler
          " A = Anwendungsfehler
          " leer = fehlgeschlagene Aktionsprüfung -> E
          <ls_result>-failed = 1.                      "Anzahl fehlgeschlagener Buchungen
        ELSE.
          <ls_result>-booked_amount = <fs_apn>-summe. "gebuchte Zahlungen pro Buchungstyp
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD STRING_TO_BAPIRET2.
    DATA:
      msg_len TYPE i,
      max_len TYPE i,
      ls_bapiret2 TYPE bapiret2.

    msg_len = strlen( i_msg ).
    IF msg_len < 50.
      ls_bapiret2-message_v1 = i_msg.
    ELSEIF msg_len < 100.
      ls_bapiret2-message_v1 = i_msg(50).
      Max_len = msg_len - 50.
      ls_bapiret2-message_v2 = i_msg+50(max_len).
    ELSEIF msg_len < 150.
      ls_bapiret2-message_v1 = i_msg(50).
      ls_bapiret2-message_v2 = i_msg+50(50).
      Max_len = msg_len - 100.
      ls_bapiret2-message_v3 = i_msg+100(max_len).
    ELSE.
      ls_bapiret2-message_v1 = i_msg(50).
      ls_bapiret2-message_v2 = i_msg+50(50).
      ls_bapiret2-message_v3 = i_msg+100(50).
      ls_bapiret2-message_v4 = i_msg+150(50).
    ENDIF.

    ls_bapiret2-id = 'bl'.
    ls_bapiret2-number = 1.
    ls_bapiret2-type = 'e'.

    r_bapiret2 = ls_bapiret2.
  ENDMETHOD.


  METHOD write_and_send_file_csv.
    " concat_lines_of places sep between rows (not after last) — same semantics
    " as the manual last-row check in write_and_send_file, without the loop.
    DATA(lv_content)         = concat_lines_of( table = it_rows sep = iv_eol ).
    DATA(lt_mail_recipients) = VALUE bcsy_smtpa( ).

    write_file_from_string(
      EXPORTING
        iv_output_filename = iv_output_filename
        iv_content         = lv_content
      CHANGING
        ct_return_tab      = ct_return_tab
        cv_success         = cv_success ).

    IF cv_success = 'N'.
      RETURN.
    ENDIF.

    DATA(ls_recipient_list) = get_recipient_list(
      iv_ns        = iv_ns
      iv_ifname    = iv_ifname
      iv_ifversion = iv_ifversion ).

    IF ls_recipient_list IS INITIAL.
      RETURN.
    ENDIF.

    get_mails_for_recipient_list(
      EXPORTING
        is_recipient_list  = ls_recipient_list
      CHANGING
        ct_mail_recipients = lt_mail_recipients ).

    IF lt_mail_recipients IS INITIAL.
      RETURN.
    ENDIF.

    cv_success = send_mail(
      it_mail_recipients    = lt_mail_recipients
      iv_attachment_content = lv_content
      iv_attachment_name    = iv_output_filename
      iv_attachment_type    = 'txt' ).
  ENDMETHOD.


  METHOD write_and_send_file.
    DATA: lv_content         TYPE string VALUE '',
          lt_mail_recipients TYPE bcsy_smtpa,
          lv_recipient_list  TYPE string VALUE 'RCV_LIST_FREMDV_0016'.

    LOOP AT it_rows INTO DATA(row).
      IF sy-tabix = lines( it_rows ).
        IF iv_width IS SUPPLIED.
          lv_content = |{ lv_content }{ row WIDTH = 80 }|.
        ELSE.
          lv_content = |{ lv_content }{ row }|.
        ENDIF.
      ELSE.
        IF iv_width IS SUPPLIED.
          lv_content = |{ lv_content }{ row WIDTH = 80 }{ iv_eol }|.
        ELSE.
          lv_content = |{ lv_content }{ row }{ iv_eol }|.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CALL METHOD write_file_from_string
      EXPORTING
        iv_output_filename = iv_output_filename
        iv_content         = lv_content
        iv_cp              = iv_cp
      CHANGING
        ct_return_tab      = ct_return_tab
        cv_success         = cv_success.

    IF cv_success = 'N'.
      EXIT.
    ENDIF.

    DATA(ls_recipient_list) = get_recipient_list(
      EXPORTING
        iv_ns             = iv_ns                 " Namensraum
        iv_ifname         = iv_ifname                 " Schnittstellenname
        iv_ifversion      = iv_ifversion                 " Schnittstellenversion
    ).
    IF ls_recipient_list IS NOT INITIAL.
      CALL METHOD get_mails_for_recipient_list EXPORTING is_recipient_list = ls_recipient_list CHANGING ct_mail_recipients = lt_mail_recipients.

      IF lt_mail_recipients IS NOT INITIAL.
        cv_success = send_mail(
          EXPORTING
            it_mail_recipients    = lt_mail_recipients
            iv_attachment_content = lv_content
            iv_attachment_name    = iv_output_filename ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD write_file_from_string.
    DATA    msg     TYPE string.
    IF iv_cp IS NOT INITIAL.
      OPEN DATASET iv_output_filename FOR OUTPUT IN LEGACY TEXT MODE CODE PAGE iv_cp MESSAGE msg.
      IF sy-subrc <> 0.
        cv_success = 'N'.
        CALL METHOD add_string_to_return_tab EXPORTING i_msg = msg CHANGING ct_return_tab = ct_return_tab.
        EXIT.
      ENDIF.
    ELSE.
      OPEN DATASET iv_output_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT MESSAGE msg.
      IF sy-subrc <> 0.
        cv_success = 'N'.
        CALL METHOD add_string_to_return_tab EXPORTING i_msg = msg CHANGING ct_return_tab = ct_return_tab.
        EXIT.
      ENDIF.
    ENDIF.

    TRY.
        TRANSFER iv_content TO iv_output_filename NO END OF LINE.
        IF sy-subrc <> 0.
          cv_success = 'N'.
          CALL METHOD add_string_to_return_tab EXPORTING i_msg = msg CHANGING ct_return_tab = ct_return_tab.
          EXIT.
        ENDIF.

        CLOSE DATASET iv_output_filename.
        cv_success = 'Y'.
        APPEND VALUE #(
        id = '/SCWM/LM_MS'
        number = 124
        type = 'S'
        message_v1 = iv_output_filename
        ) TO ct_return_tab.
        IF 0 = 1. " Um über se91 gefunden zu werden
          MESSAGE s124(/scwm/lm_ms) WITH iv_output_filename.
        ENDIF.
      CATCH cx_sy_conversion_codepage.
        IF 0 = 1. MESSAGE e046(/THKR/SST).ENDIF.
        APPEND VALUE bapiret2(  id = '/THKR/SST'
                                number = 046
                                type = 'E'
                                ) TO ct_return_tab.

    ENDTRY.
  ENDMETHOD.


  METHOD write_file_from_string_table.
    DATA lv_content      TYPE string VALUE ''.

    LOOP AT it_rows INTO DATA(row).
      IF iv_width IS SUPPLIED.
        lv_content = |{ lv_content }{ row WIDTH = iv_width }{ iv_eol }|.
      ELSE.
        lv_content = |{ lv_content }{ row }{ iv_eol }|.
      ENDIF.
    ENDLOOP.

    CALL METHOD write_file_from_string
      EXPORTING
        iv_output_filename = iv_output_filename
        iv_content         = lv_content
        iv_cp              = iv_cp
      CHANGING
        ct_return_tab      = ct_return_tab
        cv_success         = cv_success.
  ENDMETHOD.


  METHOD get_err_for_glblid.
    CLEAR: ev_status, et_msgs.

    ASSIGN is_data-ao[ glblid = iv_glblid ] TO FIELD-SYMBOL(<ls_ao>).
    IF <ls_ao> IS ASSIGNED.
      ev_status = <ls_ao>-ao_proc_status.
      et_msgs   = <ls_ao>-msg.
      RETURN.
    ENDIF.

    ASSIGN is_data-ao_reference[ glblid = iv_glblid ] TO FIELD-SYMBOL(<ls_ao_ref>).
    IF <ls_ao_ref> IS ASSIGNED.
      ev_status = <ls_ao_ref>-ao_proc_status.
      et_msgs   = <ls_ao_ref>-msg.
      RETURN.
    ENDIF.

    ASSIGN is_data-mb[ glblid = iv_glblid ] TO FIELD-SYMBOL(<ls_mb>).
    IF <ls_mb> IS ASSIGNED.
      ev_status = <ls_mb>-mv_proc_status.
      et_msgs   = <ls_mb>-msg.
      RETURN.
    ENDIF.

    ASSIGN is_data-mb_up[ glblid = iv_glblid ] TO FIELD-SYMBOL(<ls_mb_up>).
    IF <ls_mb_up> IS ASSIGNED.
      ev_status = <ls_mb_up>-mv_up_proc_status.
      et_msgs   = <ls_mb_up>-msg.
      RETURN.
    ENDIF.

    ASSIGN is_data-vr[ glblid = iv_glblid ] TO FIELD-SYMBOL(<ls_vr>).
    IF <ls_vr> IS ASSIGNED.
      ev_status = <ls_vr>-vr_proc_status.
      et_msgs   = <ls_vr>-msg.
      RETURN.
    ENDIF.

    ASSIGN is_data-storno[ glblid = iv_glblid ] TO FIELD-SYMBOL(<ls_storno>).
    IF <ls_storno> IS ASSIGNED.
      ev_status = <ls_storno>-proc_status.
      et_msgs   = <ls_storno>-msg.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
