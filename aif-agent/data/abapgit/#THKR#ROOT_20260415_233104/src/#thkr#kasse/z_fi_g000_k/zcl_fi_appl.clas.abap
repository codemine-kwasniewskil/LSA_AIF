class ZCL_FI_APPL definition
  public
  final
  create public .

public section.

  class-methods GET_INSTANCE
    exporting
      !E_INSTANCE type ref to ZCL_FI_APPL
    returning
      value(R_INSTANCE) type ref to ZCL_FI_APPL .
  methods GET_USER_PARAM
    importing
      !I_PARID type MEMORYID
    exporting
      !E_PARVA type XUVALUE
    returning
      value(R_PARVA) type XUVALUE .
  methods FIND_NUMBERS_IN_STRING
    importing
      !I_VWZW type STRING
      !I_COUNT_MIN type INTEGER default 6
      !I_COUNT_MAX type INTEGER default 13
      !I_CHECK type XFELD default 'X'
    exporting
      !E_NUMBERS type STANDARD TABLE .
  methods GET_GEBKZ
    importing
      !I_FEBKO type FEBKO
    exporting
      !E_XBLNR type XBLNR
    changing
      !C_FEBEP type FEBEP .
  methods PROCESS_IMP_DATA
    importing
      !I_LOCATION type DXFIELDS-LOCATION
      !I_FILEPATH type DXFIELDS-LONGPATH
      !I_KZDATA type CHAR1 default 'S'
      !I_TST type XFELD default SPACE
    raising
      ZCX_FI_GEN .
protected section.

  class-data INSTANCE type ref to ZCL_FI_APPL .
  class-data GEN_APPL type ref to ZCL_FI_APPL .
private section.

  types:
    lt_string_table TYPE STANDARD TABLE OF string .

  data FILE_DATA type LT_STRING_TABLE .
  data IE_DATA type ref to DATA .
  data TEST type XFELD .
  data GES_COUNT type I .
  data KZDATA type CHAR01 .
  data TABNAME type TABNAME .
  data CSVNAME type TABNAME .
  constants C_IMP_STR_S type TABNAME value 'ZFI_F_ELKO_SUCHM_CSV' ##NO_TEXT.
  constants C_IMP_STR_F type TABNAME value 'ZFI_F_FTEXT_CSV' ##NO_TEXT.
  constants C_IMP_STR_E type TABNAME value 'ZFI_F_EMPF_CSV' ##NO_TEXT.
  constants C_IMP_STR_A type TABNAME value 'ZFI_F_AKTION_CSV' ##NO_TEXT.
  constants C_TRENNZ type CHAR01 value ';' ##NO_TEXT.
  constants C_TABNAME_S type TABNAME value 'zfi_elko_suchm' ##NO_TEXT.
  constants C_TABNAME_F type TABNAME value 'zfi_cu_bn_ftext' ##NO_TEXT.
  constants C_TABNAME_E type TABNAME value 'zfi_cu_bn_empf' ##NO_TEXT.
  constants C_TABNAME_A type TABNAME value 'zfi_cu_bn_aktion' ##NO_TEXT.
  constants C_USRPARM type MEMORYID value 'Z_TST_KASSZ' ##NO_TEXT.
  constants C_CONVERT1 type Z_CHAR06 value '. / - ' ##NO_TEXT.

  methods SEARCH_IBAN_GP
    importing
      !I_TESTRUN type XFELD
      !I_IBAN type PIBAN_EB
      !I_BUKRS type BUKRS
    exporting
      !E_T_LIFNR type ZFI_T_LIFNR
      !E_SUBRC type SUBRC
    changing
      !C_FEBEP type FEBEP .
  methods READ_FILE_DATA
    importing
      !I_LOCATION type DXFIELDS-LOCATION
      !I_FILEPATH type DXFIELDS-LONGPATH
    raising
      ZCX_FI_GEN .
  methods CONVERT_DATA_IMP_CSV
    importing
      !I_TABNAME type TABNAME .
  methods SAVE_IMP_DATA
    raising
      ZCX_FI_GEN .
  methods INSERT_DATA
    raising
      ZCX_FI_GEN .
ENDCLASS.



CLASS ZCL_FI_APPL IMPLEMENTATION.


  METHOD convert_data_imp_csv.

    TYPES: BEGIN OF lty_field,
             position  TYPE tabfdpos,
             fieldname TYPE fieldname,
             domname   TYPE domname,
             ddtext    TYPE as4text,
           END OF lty_field.

    DATA: l_tabname    TYPE tabname,
          lt_field     TYPE STANDARD TABLE OF lty_field,
          l_field      TYPE lty_field,
          l_line       TYPE REF TO data,
          l_file_line  TYPE string,
          l_file_index TYPE i,
          l_num_lines  TYPE i,
          l_offset     TYPE i,
          l_start      TYPE i,
          l_len        TYPE i,
          l_flen       TYPE i,
          l_pos        TYPE i,
          l_maxpos     TYPE i,
          l_dummy      TYPE string,
          l_count      TYPE i.

    FIELD-SYMBOLS: <ie_line>       TYPE any,
                   <ie_line_field> TYPE any,
                   <ie_table>      TYPE STANDARD TABLE.

    l_tabname = i_tabname.

*   Datenstruktur der Importdaten ermitteln
    SELECT position fieldname domname
      FROM dd03l
      INTO CORRESPONDING FIELDS OF TABLE lt_field
      WHERE tabname = l_tabname
      AND as4local = 'A'
      AND  fieldname <> '.INCLUDE'
      ORDER BY position.

* IMPORT (nur wenn Feld-Überschrift = ddtext in Kopfzeile der csv-Datei)
*    IF i_kzimp IS NOT INITIAL.
*      LOOP AT lt_field INTO l_field.
*        SELECT ddtext INTO l_field-ddtext
*          FROM dd03t WHERE tabname = l_tabname
*                       AND fieldname = l_field-fieldname
*                       AND ddlanguage = 'DE'
*                       AND as4local = 'A'.
*        ENDSELECT.
*        IF sy-subrc <> 0.
*          SELECT ddtext domname INTO CORRESPONDING FIELDS OF l_field
*            FROM dd03m WHERE tabname = l_tabname
*                         AND fieldname = l_field-fieldname
*                         AND ddlanguage = 'DE'
*                         AND fldstat = 'A'.
*          ENDSELECT.
*        ENDIF.
*        MODIFY lt_field FROM l_field TRANSPORTING ddtext domname.
*      ENDLOOP.
*    ENDIF.

    DESCRIBE TABLE lt_field LINES l_maxpos.

*   Import: csv-Daten nach IE_DATA konvertieren
*   Zeile der Zielstruktur erstellen
    CREATE DATA l_line TYPE (l_tabname).
    ASSIGN l_line->* TO <ie_line>.

*   Interne Tabelle für Zieldaten erstellen
*   IE_DATA referenziert auf Importdaten
    CREATE DATA ie_data TYPE STANDARD TABLE OF (l_tabname).
    ASSIGN ie_data->* TO <ie_table>.

    DESCRIBE TABLE file_data LINES l_num_lines.

    l_file_index = 1. " Kopfzeile auslassen
*   l_file_index = 0. " keine Kopfzeile vorhanden

    WHILE l_file_index < l_num_lines.

      l_file_index = l_file_index + 1.
      CLEAR: l_offset, l_start, l_pos.

      READ TABLE file_data INDEX l_file_index INTO l_file_line.

      l_len = strlen( l_file_line ).

      WHILE l_offset < l_len  AND l_pos <= l_maxpos.

        l_pos = l_pos + 1.
        READ TABLE lt_field INDEX l_pos INTO l_field.
        ASSIGN l_line->(l_field-fieldname) TO <ie_line_field>.

        FIND c_trennz IN SECTION OFFSET l_offset OF l_file_line   "C_TRENNZ = ';'
        MATCH OFFSET l_offset.
        IF sy-subrc <> 0.
*       letztes Feld, da kein weiterer Trenner gefunden
          l_offset = l_len.
        ENDIF.

        l_flen = l_offset - l_start.

        <ie_line_field> = l_file_line+l_start(l_flen).

        l_offset = l_offset + 1.
        l_start = l_offset.

        IF l_field-fieldname(4) = 'BTRG'.
          TRANSLATE <ie_line_field> USING '. '.
          CONDENSE <ie_line_field> NO-GAPS.
        ENDIF.
      ENDWHILE.
      APPEND <ie_line> TO <ie_table>.
      l_count = l_count + 1.

    ENDWHILE.
  ENDMETHOD.


  METHOD find_numbers_in_string.

    DATA: l_numbers   TYPE TABLE OF string,
          l_vwzw      TYPE string,
          l_head      TYPE string,
          l_xblnr     TYPE xblnr,
          l_prfz      TYPE n,
          l_len       TYPE i,
          res         TYPE i,
          l_res_temp  TYPE i,
          l_length    TYPE i,
          l_count_min TYPE i,
          l_count_max TYPE i.

    IF i_count_min > i_count_max.
      RETURN.
    ENDIF.
    l_count_min = i_count_min.
    l_count_max = i_count_max.
*--------------------------------------------------------------------
* wird beibehalten, da zu kleine Ziffernfolgen nicht aussagekräftig
* Repro-ROC
*--------------------------------------------------------------------
    IF l_count_min < 6.
      l_count_min = 6.
    ENDIF.
*--------------------------------------------------------------------
* Abschneiden auf 13 nur bei Prüfung auf Prüfziffer
* sonst auch länger
* Repro-ROC
*--------------------------------------------------------------------
* Abschneiden bei 13 Stellen
    IF l_count_max > 13 and i_check = 'X'.
*      l_count_min = 13.
      l_count_max = 13.
    ENDIF.

    IF i_vwzw IS INITIAL.
      RETURN.
    ENDIF.

    REFRESH: l_numbers, e_numbers.

    l_vwzw = i_vwzw.
* ggf sind mehrere Leerzeichen vorhanden, die werden ignoriert
       TRANSLATE l_vwzw USING c_convert1.
       condense l_vwzw no-gaps.
    l_len = strlen( l_vwzw ).
    res = 0.

*   Verwendungszweck in 6 - xx-stellige Zahlenfolgen zerlegen
    WHILE res < l_len.
      WHILE l_vwzw+res(1) NA '0123456789'.
        res = res + 1.
        IF res >= l_len.
          EXIT.
        ENDIF.
      ENDWHILE.
      IF res >= l_len.
        EXIT.
      ENDIF.

*hier beginnt die erste Ziffer
      CLEAR l_head.
      l_res_temp = res.
      l_length = 0.
*      WHILE l_vwzw+res_temp(1) CA '0123456789'.

      WHILE l_vwzw+res(1) CA '0123456789'.
        CONCATENATE l_head l_vwzw+res(1) INTO l_head.
        res = res + 1.
        l_length = l_length + 1.
*neu
      IF strlen( l_head ) >= l_count_min AND strlen( l_head ) <= l_count_max.
        APPEND l_head TO l_numbers.
      ENDIF.

        IF res >= l_len.
          EXIT.
        ENDIF.

        IF l_length >= l_count_max.
          shift  l_vwzw left by 1 places.
          res = l_res_temp.
          l_len = l_len - 1.
          l_length = 0.
          EXIT.
        ENDIF.

      ENDWHILE.
      IF strlen( l_head ) >= l_count_min AND strlen( l_head ) <= l_count_max.
        APPEND l_head TO l_numbers.
      ENDIF.
*    endwhile.


    ENDWHILE.

    SORT l_numbers.
    DELETE ADJACENT DUPLICATES FROM l_numbers.

*   13-stellige KZ müssen eine korrekte Prfz haben, sonst entfernen
    IF l_count_max = 13 and i_Check = 'X'.
      LOOP AT l_numbers INTO l_xblnr.

        IF strlen( l_xblnr ) = 13.
*       Prüfziffer prüfen
          CALL FUNCTION 'Z_NSI_HHV_KZ_PRUEFZIFFER'
            EXPORTING
              im_xblnr       = l_xblnr
            IMPORTING
              ex_pruefziffer = l_prfz.

          IF l_xblnr+12(1) <> l_prfz.
            DELETE l_numbers.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDIF.

*   Ausgabe
    SORT l_numbers DESCENDING.
    e_numbers = l_numbers.

  ENDMETHOD.


  method GET_GEBKZ.
*-----------------------------------------------------------------
*
 data:
      l_xblnr     type xblnr,
      l_vozei2    type VOZPM_EB.

   clear e_xblnr.

   IF c_febep-epvoz = 'S'.
      l_vozei2 = '-'.
    ELSE.
      l_vozei2 = '+'.
    ENDIF.


select single xblnr from zfi_gebkz_elko into l_xblnr
  where bukrs  = i_febko-bukrs and
        HBKID  = i_febko-hbkid and
        HKTID  = i_febko-hktid and
        vgext  = c_febep-vgext and
        VOZPM  =  l_vozei2 .

     if sy-subrc ne 0.
     clear l_xblnr.
* zur Weitergabe an Z_FIEB_901_ALGORITHM
     else.
       e_xblnr = l_xblnr.
       c_febep-xblnr = l_xblnr.
*       c_febep-info1 = l_xblnr.
     endif.

  endmethod.


  METHOD get_instance.

    IF instance IS INITIAL.
      CREATE OBJECT instance.
    ENDIF.

    gen_appl   = instance.
    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.


  METHOD get_user_param.

    DATA  lt_param  TYPE ustyp_t_parameters.

*   User-Parameter lesen
    CALL FUNCTION 'SUSR_USER_PARAMETERS_GET'
      EXPORTING
        user_name       = sy-uname
      TABLES
        user_parameters = lt_param.
    IF sy-subrc <> 0.
    ENDIF.

    LOOP AT lt_param ASSIGNING FIELD-SYMBOL(<parm>)
                    WHERE parid = i_parid.
      e_parva = <parm>-parva.
      r_parva = <parm>-parva.

    ENDLOOP.

  ENDMETHOD.


  METHOD insert_data.
***    DATA:
***      lt_suchm  TYPE TABLE OF zfi_elko_suchm,  "DB-Tabelle
***      ls_suchm  TYPE zfi_elko_suchm,           "DB-Tabelle
***      lt_ftext  TYPE TABLE OF zfi_cu_bn_ftext,
***      ls_ftext  TYPE zfi_cu_bn_ftext,
***      lt_empf   TYPE TABLE OF zfi_cu_bn_empf,
***      ls_empf   TYPE zfi_cu_bn_empf,
***      lt_aktion TYPE TABLE OF zfi_cu_bn_aktion,
***      ls_aktion TYPE zfi_cu_bn_aktion,
***      l_msgv1   TYPE sy-msgv1,
***      l_oerror  TYPE REF TO cx_root,
***      l_mess    TYPE string.
***
***    FIELD-SYMBOLS: <tab> TYPE STANDARD TABLE.
***
***    ASSIGN ie_data->* TO <tab>.
***
****   DB-Tabelle füllen
***    LOOP AT <tab> ASSIGNING FIELD-SYMBOL(<csvdata>).
***      CASE kzdata.
***        WHEN 'S'.
***          MOVE-CORRESPONDING <csvdata> TO ls_suchm.
***          APPEND ls_suchm TO lt_suchm.
***        WHEN 'F'.
***          MOVE-CORRESPONDING <csvdata> TO ls_ftext.
***          APPEND ls_ftext TO lt_ftext.
***        WHEN 'E'.
***          MOVE-CORRESPONDING <csvdata> TO ls_empf.
***          APPEND ls_empf TO lt_empf.
***        WHEN 'A'.
***          MOVE-CORRESPONDING <csvdata> TO ls_aktion.
***          APPEND ls_aktion TO lt_aktion.
***      ENDCASE.
***    ENDLOOP.
***
***    CASE kzdata.
***      WHEN 'S'.
***        IF test IS INITIAL.
***          MODIFY zfi_elko_suchm FROM TABLE lt_suchm.
***        ENDIF.
***      WHEN 'F'.
***        IF test IS INITIAL.
***          MODIFY zfi_cu_bn_ftext FROM TABLE lt_ftext.
***        ENDIF.
***      WHEN 'E'.
***        IF test IS INITIAL.
***          MODIFY zfi_cu_bn_empf FROM TABLE lt_empf.
***        ENDIF.
***      WHEN 'A'.
***        IF test IS INITIAL.
***          MODIFY zfi_cu_bn_aktion FROM TABLE lt_aktion.
***        ENDIF.
***    ENDCASE.
***
***    IF sy-subrc <> 0.
***      ROLLBACK WORK.
***      l_msgv1 = tabname.
***      RAISE EXCEPTION TYPE zcx_fi_gen
***        EXPORTING
***          textid  = zcx_fi_gen=>insert_error_sql
***          tabname = l_msgv1
***          txt     = ' '.
***    ENDIF.
  ENDMETHOD.


  METHOD process_imp_data.
    test = i_tst.
    kzdata = i_kzdata.
    CASE kzdata.
      WHEN 'S'.
        csvname = c_imp_str_s.
        tabname = c_tabname_s.
      WHEN 'F'.
        csvname = c_imp_str_f.
        tabname = c_tabname_f.
      WHEN 'E'.
        csvname = c_imp_str_e.
        tabname = c_tabname_e.
      WHEN 'A'.
        csvname = c_imp_str_a.
        tabname = c_tabname_a.
      WHEN OTHERS.
        RETURN.
    ENDCASE.

* Daten einlesen (File einlesen nach FILE_DATA)
    read_file_data(
      EXPORTING
        i_location = i_location
        i_filepath = i_filepath ).

* Daten konvertieren (Ergebnis auf IE_DATA)
    convert_data_imp_csv(
      EXPORTING
        i_tabname = csvname ).

* csv-Daten aus IE_DATA in zugehörige DB-Tabellen sichern
    save_imp_data( ).

    COMMIT WORK.
  ENDMETHOD.


  METHOD read_file_data.

    DATA: l_filename TYPE  string,
          l_line     TYPE  string,
          l_msgv1    TYPE  string,
          l_msgv2    TYPE  msgv2.

    l_filename = i_filepath.

    IF i_location = 'P'.
*     Datei auf dem PC in interne Tabelle file_data laden

      cl_gui_frontend_services=>gui_upload(
        EXPORTING
          filename     = l_filename
          filetype     = 'ASC'
          read_by_line = 'X'
        CHANGING
          data_tab     = file_data
        EXCEPTIONS
          file_open_error         = 1
          file_read_error         = 2
          no_batch                = 3
          gui_refuse_filetransfer = 4
          invalid_type            = 5
          no_authority            = 6
          unknown_error           = 7
          bad_data_format         = 8
          header_not_allowed      = 9
          separator_not_allowed   = 10
          header_too_long         = 11
          unknown_dp_error        = 12
          access_denied           = 13
          dp_out_of_memory        = 14
          disk_full               = 15
          dp_timeout              = 16
*         not_supported_by_gui    = 17
*         error_no_gui            = 18
          OTHERS                  = 19          ).
      IF sy-subrc <> 0.
        l_msgv1 = i_filepath.
        l_msgv2 = sy-subrc.
        CONDENSE l_msgv2 NO-GAPS.
        RAISE EXCEPTION TYPE zcx_fi_gen
          EXPORTING
            textid   = zcx_fi_gen=>file_upload_error
            filename = l_msgv1
            rc       = l_msgv2.
      ENDIF.

    ELSE.
*   Datei auf dem Applicationsserver in Tabelle file_data laden
      OPEN DATASET i_filepath IN BINARY MODE FOR INPUT.
*      OPEN DATASET i_filepath IN TEXT MODE FOR INPUT ENCODING NON-UNICODE.
      IF sy-subrc <> 0.
        l_msgv1 = i_filepath.
        RAISE EXCEPTION TYPE zcx_fi_gen
          EXPORTING
            textid   = zcx_fi_gen=>file_open_error
            filename = l_msgv1.
      ENDIF.

      WHILE sy-subrc = 0.
        READ DATASET i_filepath INTO l_line.
        IF l_line IS NOT INITIAL.
          APPEND l_line TO file_data.
        ENDIF.
      ENDWHILE.

      CLOSE DATASET i_filepath.
    ENDIF.

  ENDMETHOD.


  METHOD save_imp_data.
    DATA: l_num_lines TYPE i,
          l_return    TYPE bapiret2,
          l_msgv1     TYPE msgv1,
          l_msgv2     TYPE msgv2.
    DATA:
      lo_sqlerr   TYPE REF TO cx_sy_open_sql_db,
      lv_txterror TYPE string,
      lv_msgtxt   TYPE msgtxt.


    FIELD-SYMBOLS: <tab> TYPE STANDARD TABLE.

    ASSIGN ie_data->* TO <tab>.

    DESCRIBE TABLE <tab> LINES ges_count.

    CHECK ges_count > 0.

    TRY.
*       Insert in Tabelle
        insert_data( ).

      CATCH cx_sy_open_sql_db INTO lo_sqlerr.
        lv_txterror = lo_sqlerr->get_text( ).
        lv_msgtxt = lv_txterror.
        ROLLBACK WORK.
        l_msgv1 = tabname.
        l_msgv2 = lv_msgtxt.

        RAISE EXCEPTION TYPE zcx_fi_gen
          EXPORTING
            textid  = zcx_fi_gen=>insert_error_sql
            tabname = l_msgv1
            txt     = l_msgv2.
    ENDTRY.
  ENDMETHOD.


  METHOD search_iban_gp.

    DATA: ls_tiban    TYPE tiban,
          lt_tiban    TYPE TABLE OF tiban,
          lt_lfbk     TYPE TABLE OF lfbk,
          ls_lfbk     TYPE lfbk,
          l_lifnr     TYPE lifnr,
          l_subrc     TYPE subrc,
          letters(26) TYPE c VALUE 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.

* ISO-code prüfen
    IF NOT i_iban(2) CO letters.       " ist keine IBAN
      e_subrc = 1.
      RETURN.
    ENDIF.

    SELECT * FROM tiban INTO TABLE lt_tiban WHERE iban = i_iban.

    IF lines( lt_tiban ) = 0.
      e_subrc = 2.                   "Keine IBAN gefunden
      RETURN.
    ENDIF.
    IF lines( lt_tiban ) = 1 AND i_testrun IS INITIAL.
      LOOP AT lt_tiban INTO ls_tiban.
        c_febep-piban = ls_tiban-iban.
        c_febep-pabks = ls_tiban-banks.
        c_febep-pablz = ls_tiban-bankl.
        c_febep-pakto = ls_tiban-bankn.
      ENDLOOP.
    ENDIF.

    IF lines( lt_tiban ) >= 1.
      LOOP AT lt_tiban INTO ls_tiban.
        SELECT * FROM lfbk APPENDING TABLE lt_lfbk WHERE banks = ls_tiban-banks
                                                AND bankl = ls_tiban-bankl
                                                AND bankn = ls_tiban-bankn.
      ENDLOOP.
    ENDIF.

*   GP im Buchungskreis finden
    LOOP AT lt_lfbk INTO ls_lfbk.

      SELECT SINGLE lifnr INTO l_lifnr FROM lfb1 WHERE lifnr = ls_lfbk-lifnr
                                                 AND   bukrs = i_bukrs.
      IF sy-subrc = 0.
        APPEND l_lifnr TO e_t_lifnr.
      ENDIF.
      CLEAR l_lifnr.
    ENDLOOP.

    IF lines( e_t_lifnr ) = 0.
      e_subrc = 3.                         "Kein Kreditor im Buchungskreis gefunden
    ENDIF.

  ENDMETHOD.
ENDCLASS.
