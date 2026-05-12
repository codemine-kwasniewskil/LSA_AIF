*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XSLT_MSN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/migration_comm_item_msn.

PARAMETERS: p_fikrs  TYPE fikrs DEFAULT '1000',
            p_gjahr  TYPE gjahr DEFAULT '2024',
            p_sicom  TYPE xfeld DEFAULT ' ',  "Kennzeichen für kein Commit
            p_test   TYPE xfeld DEFAULT 'X',
            p_in_dir TYPE string DEFAULT 'H:\LSA_Migrationsthemen',
            p_logja  TYPE xfeld DEFAULT 'X',
            p_lognam TYPE string DEFAULT 'log_unterkonto',
            p_file   TYPE /thkr/file_w_path.




TYPES lty_result TYPE x LENGTH 1024.
* Deklaration Transformation
DATA: lt_result           TYPE STANDARD TABLE OF lty_result,
      l_file              TYPE /thkr/file_w_path,
      l_cstring           TYPE string,
      Lt_msn              TYPE /thkr/t_mig_fipo_msn,
      Ls_msn              TYPE LINE OF /thkr/t_mig_fipo_msn,
      l_xml_string        TYPE xstring,
      lv_timestring_conv  TYPE string,
      lv_message_ret2_out TYPE string.
DATA: lv_length TYPE i.
FIELD-SYMBOLS <fs_lastc>.
DATA: prestring TYPE string.
*Deklaratation für File laden
DATA: lt_file_table	TYPE filetable,	 "Tabelle, die selektierte Dateien enthält
      lv_rc         TYPE i  . "Rückgabewert: Anzahl Dateien oder -1 falls Fehler auftritt
FIELD-SYMBOLS: <fs_file_table> TYPE file_table.
SELECT-OPTIONS: so_msnky FOR ls_msn-schluessel NO INTERVALS.

*Struktur staging tabellen
*DATA: lt_staging TYPE /1lt/dseh1000598. "EH1 "/1lt/dskh1000028.


*Deklaration Datenaufbereitung
*Daten für zugehöroge FIPO
DATA: lt_imp_CMMT_ITEM_DATA TYPE TABLE OF fmci, "TYPE TABLE OF ifmcidat,
      lt_imp_CMMT_ITEM_TEXT TYPE TABLE OF fmcit, "TABLE OF fmcmmt_item_text,
      lt_imp_CMMT_ITEM_HIER TYPE TABLE OF fmhici. "TYPE  TABLE OF fmcmmt_item_hier.

DATA: lc_hsart TYPE fm_hsart VALUE 'B'. "Für Unterkonten ist die HSART immer B

*Daten zm Anlegen von Unterpositionen anlegen
DATA:
  lt_exp_CMMT_ITEM_DATA TYPE  TABLE OF fmci, "ifmcidat,
  lt_exp_CMMT_ITEM_TEXT TYPE  TABLE OF fmcit, "fmcmmt_item_text,
  lt_exp_CMMT_ITEM_HIER TYPE  TABLE OF fmhici. "fmcmmt_item_hier.
DATA:
  FIPEX_FIPO_imp  TYPE fipex,
  FIPEX_FP_uk_exp TYPE fipex,
  lv_longtext     TYPE stringval.
*Deklaraaation export Struktur
DATA:
  ls_exp_CMMT_ITEM_DATA TYPE   ifmcidat,
  ls_exp_CMMT_ITEM_TEXT TYPE   fmcmmt_item_text,
  ls_exp_CMMT_ITEM_HIER TYPE   fmcmmt_item_hier.
*Definition Import Struktur
FIELD-SYMBOLS:
  <fs_imp_CMMT_ITEM_DATA> TYPE   fmci, "ifmcidat,
  <fs_imp_CMMT_ITEM_TEXT> TYPE   fmcit, "fmcmmt_item_text,
  <fs_imp_CMMT_ITEM_HIER> TYPE   fmhici. "fmcmmt_item_hier.


DATA:  lt_et_return TYPE bapiret2_t.
DATA:  lt_et_return2 TYPE bapiret2_t.
DATA:  ls_et_return2 TYPE bapiret2.

*DATA:  lt_et_return_sammel TYPE bapiret2_t.
*DATA:  lt_et_return2_sammel TYPE bapiret2_t.
AT SELECTION-SCREEN OUTPUT.
*select option füllen
  so_msnky-sign = 'I'.
  so_msnky-option = 'EQ'.
  so_msnky-low = '00'.
  APPEND so_msnky.
  so_msnky-sign = 'I'.
  so_msnky-option = 'EQ'.
  so_msnky-low = '0'.
  APPEND so_msnky.




START-OF-SELECTION.
  IF p_file IS INITIAL. "Entweder pfad für backend mitgeben oder Filedialog
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        initial_directory       = p_in_dir
      CHANGING
        file_table              = lt_file_table
        rc                      = lv_rc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.
    IF sy-subrc <> 0.
    ELSE.
      LOOP AT lt_file_table ASSIGNING  <fs_file_table>.
      ENDLOOP.
* Implement suitable error handling here
    ENDIF.

    l_file = <fs_file_table>-filename.
  ELSE.

    l_file = p_file.
  ENDIF.

  cl_gui_frontend_services=>gui_upload(
    EXPORTING
      filename = CONV #( l_file ) "FILENAME TYPE STRING  DEFAULT SPACE  Name der Datei

      filetype = 'BIN'
    CHANGING
      data_tab = lt_result ).

  LOOP AT lt_result INTO DATA(l_result).
    CONCATENATE l_xml_string l_result INTO l_xml_string IN BYTE MODE.
  ENDLOOP.

  TRY.


      CALL TRANSFORMATION /thkr/msn_to_abap
        SOURCE XML l_xml_string
        RESULT table = lt_msn.


    CATCH cx_root INTO DATA(l_oerror).
      /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

  ENDTRY.


*Finanzpositionen holen


  CALL FUNCTION 'FM_COM_ITEM_GET_LIST_RFC'
    EXPORTING
      i_fm_area         = p_fikrs
      i_fisc_year       = p_gjahr
*     I_FLG_ONLY_POSTABLE           =
*     I_FLG_ONLY_NON_POSTABLE       =
      i_flg_text        = 'X'
      i_flg_hierarchy   = 'X'
* IMPORTING
*     ET_MESSAGES       =
    TABLES
*     R_FIPEX           =
      et_cmmt_item_text = lt_imp_CMMT_ITEM_TEXT
      et_cmmt_item_data = lt_imp_CMMT_ITEM_DATA
      et_cmmt_item_hier = lt_imp_CMMT_ITEM_HIER.
  IF sy-sysid = 'EH1' AND sy-batch = space.
*    BREAK-POINT.
  ENDIF.
*  *Vorbereitung logaufbau
  OPEN DATASET p_lognam FOR APPENDING IN  TEXT MODE ENCODING DEFAULT.
  IF sy-subrc EQ 0.
    GET TIME STAMP FIELD DATA(lv_ts).
    CONVERT TIME STAMP lv_ts TIME ZONE 'CET' INTO TIME lv_timestring_conv .
    IF  p_sicom  = space AND p_test = 'X'.

      CONCATENATE 'Testmodus: ' sy-datum lv_timestring_conv sy-uname l_file INTO prestring SEPARATED BY '_'.
    ELSE.
      CONCATENATE 'Echtlauf: ' sy-datum lv_timestring_conv sy-uname l_file INTO prestring SEPARATED BY '_'.
    ENDIF.

    TRANSFER prestring TO p_lognam.
  ENDIF.


  LOOP AT lt_msn INTO DATA(l_msn).
*auszuschließende Schlüssel austeuern
    CHECK l_msn-schluessel NOT IN so_msnky.
* *    inaktve UNterkonten (status = 2)  ausschließen
    CHECK l_msn-status NE '2'.

    CONCATENATE l_msn-kapitel l_msn-Titel INTO FIPEX_FIPO_imp.
    CONDENSE  FIPEX_FIPO_imp NO-GAPS. "zum lesen Fipo
*    prüfen ob letztes Feld im Schlüssel einen Großbuchstaben enthält

*prüfen für kapitel  1120, 1130 und 1140 ob letzterbuchstabe ein capital Character ist, dann ukonto nicht anlegen

    IF  l_msn-kapitel EQ '1120' OR
        l_msn-kapitel EQ '1130' OR
        l_msn-kapitel EQ '1140' .


      lv_length = strlen( l_msn-schluessel ) - 1. "letztes Zeichn muss gelesen werden
      ASSIGN l_msn-schluessel+lv_length(1) TO <fs_lastc>.
      CHECK <fs_lastc> NA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
    ENDIF.


    CONCATENATE l_msn-kapitel l_msn-Titel l_msn-schluessel INTO FIPEX_FP_UK_exp." =zum exportieren Unterkonto
    CONDENSE  FIPEX_FP_UK_exp NO-GAPS.
*    keine Kleinbuchstaben mehr erlaubt
    TRANSLATE FIPEX_FP_UK_exp TO UPPER CASE.

    READ TABLE lt_imp_CMMT_ITEM_DATA     WITH  KEY  fipex =  FIPEX_FIPO_imp                    ASSIGNING <fs_imp_CMMT_ITEM_DATA> .

    IF sy-subrc = 0.
      READ TABLE lt_imp_CMMT_ITEM_TEXT     WITH  KEY  fipex =  FIPEX_FIPO_imp                    ASSIGNING <fs_imp_CMMT_ITEM_TEXT> .
      READ TABLE lt_imp_CMMT_ITEM_HIER     WITH  KEY  fipex =  FIPEX_FIPO_imp                    ASSIGNING <fs_imp_CMMT_ITEM_HIER> .
*Aufbauen Unterkonto exportsatz*
      MOVE-CORRESPONDING:
      <fs_imp_CMMT_ITEM_DATA>  TO   ls_exp_CMMT_ITEM_DATA,
*     <fs_imp_CMMT_ITEM_text>  TO   ls_exp_CMMT_ITEM_text,    "Texte sollen nicht aus der Fipo kommen PPF 20241218
     <fs_imp_CMMT_ITEM_hier>  TO   ls_exp_CMMT_ITEM_hier.

*
*einmischen Unterkonto spezifika

*Text Bezeichnung
      ls_exp_CMMT_ITEM_text-bezei = l_msn-bezeichnung.
      ls_exp_CMMT_ITEM_text-text1 = l_msn-bezeichnung(50).
      ls_exp_CMMT_ITEM_text-text2 = l_msn-bezeichnung+50(10).
*      ls_exp_CMMT_ITEM_text-text3 = l_msn-bezeichnung+60.


*      CONCATENATE <fs_imp_CMMT_ITEM_TEXT>-text1   <fs_imp_CMMT_ITEM_TEXT>-text2  <fs_imp_CMMT_ITEM_TEXT>-text3  INTO lv_longtext SEPARATED BY space.
      lv_longtext = l_msn-bezeichnung.
*Festlegung 'Unterkonto' = HSART 'B'
      ls_exp_CMMT_ITEM_data-hsart = lc_hsart.



*      TRY.
*  IF p_logja NE space.

*      ENDIF.
*      TRY.
      CALL FUNCTION 'Z_FM_COM_ITEM_MIGRATION'
        EXPORTING
          i_fm_area         = p_fikrs
          i_cmmt_item       = FIPEX_FP_UK_exp
          i_fisc_year       = p_gjahr
          is_cmmt_item_data = ls_exp_CMMT_ITEM_data
          is_cmmt_item_text = ls_exp_CMMT_ITEM_text
          is_cmmt_item_hier = ls_exp_CMMT_ITEM_hier
          i_flg_test        = p_test "'X'
          i_flg_commit      = p_sicom "'X'
          i_longtext        = lv_longtext
        IMPORTING
          et_messages       = lt_et_return.
      .






*        CATCH cx_root INTO DATA(l_oerror_2).
*      /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

*      ENDTRY.
      IF lt_et_return IS INITIAL.
        CONCATENATE: 'erfolg: ' FIPEX_FP_UK_exp  INTO ls_et_return2-message.   "ls_exp_CMMT_ITEM_data-kapitel  ls_exp_CMMT_ITEM_data-titel ls_exp_CMMT_ITEM_data-schluessel
        APPEND ls_et_return2 TO lt_et_return2.

        CLEAR ls_et_return2.
      ELSE.
        LOOP AT  lt_et_return INTO DATA(ls_et_return).
          MOVE FIPEX_FP_UK_exp TO ls_et_return-message_v4.
          APPEND ls_et_return TO lt_et_return2.
        ENDLOOP.
      ENDIF.
    ELSE.

*?????????????????????????*
      CONCATENATE: 'Keine_FIPO: ' FIPEX_FP_UK_exp  INTO ls_et_return2-message.   "ls_exp_CMMT_ITEM_data-kapitel  ls_exp_CMMT_ITEM_data-titel ls_exp_CMMT_ITEM_data-schluessel
      APPEND ls_et_return2 TO lt_et_return2.

      CLEAR ls_et_return2.

    ENDIF.
    CLEAR: ls_exp_CMMT_ITEM_data, ls_exp_CMMT_ITEM_text, ls_exp_CMMT_ITEM_hier.
  ENDLOOP.
  IF sy-sysid EQ 'EH1' AND sy-batch = space.
*    BREAK-POINT.
  ENDIF.

*ggf. protokoll rausschreiben
  LOOP AT lt_et_return2 INTO ls_et_return2.

    CONCATENATE ls_et_return2-message space ls_et_return2-message_v4 INTO lv_message_ret2_out.
    TRANSFER lv_message_ret2_out    TO p_lognam.


  ENDLOOP.
  GET TIME STAMP FIELD lv_ts.
  CONVERT TIME STAMP lv_ts TIME ZONE 'CET' INTO TIME lv_timestring_conv .

  CONCATENATE sy-datum lv_timestring_conv sy-uname l_file INTO prestring SEPARATED BY '_'.
  TRANSFER prestring TO p_lognam.
  CLOSE DATASET p_lognam.



*  ENDIF.

  CLEAR lt_msn.
