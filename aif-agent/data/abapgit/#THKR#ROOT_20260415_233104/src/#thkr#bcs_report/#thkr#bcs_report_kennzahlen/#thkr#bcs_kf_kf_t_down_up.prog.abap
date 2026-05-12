*&---------------------------------------------------------------------*
*& Report /THKR/BCS_KF_KF_T_DOWN_UP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/BCS_KF_KF_T_DOWN_UP.



*--------------------------------------------------------------------*
* DATA & TYPES
*--------------------------------------------------------------------*

DATA: lv_table TYPE string.



TYPES: BEGIN OF ty_itab,
         data TYPE string,
       END OF ty_itab.

TYPES: tty_itab TYPE STANDARD TABLE OF ty_itab.



TYPES: BEGIN OF ty_file,
         data TYPE string,
       END OF ty_file.

TYPES: tty_file TYPE STANDARD TABLE OF ty_file.



TYPES: BEGIN OF ty_upload.
         INCLUDE STRUCTURE /THKR/KF_KF_T.
       TYPES  END OF ty_upload.



TYPES: tty_upload TYPE STANDARD TABLE OF ty_upload.


DATA: gt_file    TYPE STANDARD TABLE OF ty_file,
      gt_upload  TYPE tty_upload,
      gt_itab    TYPE tty_itab,
      gt_outfile TYPE tty_file.


DATA: gv_down_file TYPE rlgrap-filename.

*--------------------------------------------------------------------*





**********************************************************************
* PARAMETER - SCREEN
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001. "Selektion

PARAMETERS: p_file  TYPE rlgrap-filename,
            p_split TYPE char1           DEFAULT '|'.
SELECTION-SCREEN END OF BLOCK b1.



SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002. "Modus
PARAMETERS: rb_up   RADIOBUTTON GROUP gr1 DEFAULT 'X',
            rb_down RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK b2.



SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003. "Speichern beim Upload oder nur Test
PARAMETERS: p_test TYPE c AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b3.

**********************************************************************
* AT SELECTION-SCREEN ON VALUE-REQUEST
**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

* Open-File-Dialog zur Auswahl Inputdatei
  PERFORM get_filename.



**********************************************************************
* AT SELECTION-SCREEN
**********************************************************************
AT SELECTION-SCREEN.
* Die Download-Datei wird im gleichen Verzeichnis gespeichert
* Nur mit zusätzlichen Namen "_conv" und als TXT
  PERFORM get_down_file    USING p_file
                        CHANGING gv_down_file.





**********************************************************************
* START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.


  lv_table = '/THKR/KF_KF_T'.


*--------------------------------------------------------------------*
* Download der Daten
*--------------------------------------------------------------------*
  IF    rb_up IS NOT INITIAL.

*-- Datei hochladen in Flatfile von Frontend
    PERFORM upload_file       USING p_file
                           CHANGING gt_file.




*-- Flatfile in strukturierte interne Tabelle GT_UPLOAD konvertieren
    PERFORM read_flatfile_into_upload     USING gt_file
                                       CHANGING gt_upload.


*-- Speichern der Daten
    IF p_test IS INITIAL.

      IF gt_upload[] IS  NOT INITIAL.
        PERFORM save_data USING gt_upload.

        MESSAGE i531(0u) WITH 'Upload und Speichern komplett'.
      ENDIF. " IF gt_upload IS  NOT INITIAL.

    ENDIF. " IF p_test IS INITIAL.



*--------------------------------------------------------------------*
* Download der Daten
*--------------------------------------------------------------------*
  ELSEIF rb_down IS NOT INITIAL.


*-- zu selektierende Tabelle
    REFRESH: gt_upload.
    SELECT * FROM (lv_table) INTO CORRESPONDING FIELDS OF TABLE gt_upload
       ORDER BY PRIMARY KEY.


*-- Fülle Ausgabestruktur aus Uploaddatei und Headerdaten
    PERFORM fill_itab     USING gt_upload
                       CHANGING gt_itab.


    gt_outfile[] = gt_itab[].

*-- Download konvertierte Datei auf Frontend
    IF p_test IS INITIAL.
      PERFORM download     USING  gv_down_file
                                  gt_outfile.

      MESSAGE i531(0u) WITH 'Download komplett'.
    ENDIF. " IF p_test IS INITIAL.

  ENDIF.


*--------------------------------------------------------------------*
* Anzeige der Daten
*--------------------------------------------------------------------*
  PERFORM show_data USING  gt_upload.
**********************************************************************







*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       Popupdialog für Uploadpfad in Parameter laden
*----------------------------------------------------------------------*
FORM get_filename.


  DATA: lt_file_table TYPE filetable,
        ls_file       TYPE file_table,
        lv_rc         TYPE i.


  ls_file-filename = p_file.


  APPEND ls_file TO lt_file_table.


  CALL METHOD cl_gui_frontend_services=>file_open_dialog
*    EXPORTING
*      WINDOW_TITLE            =
*      DEFAULT_EXTENSION       =
*      DEFAULT_FILENAME        =
*      FILE_FILTER             =
*      WITH_ENCODING           =
*      INITIAL_DIRECTORY       =
*      MULTISELECTION          =
    CHANGING
      file_table              = lt_file_table
      rc                      = lv_rc
*     USER_ACTION             =
*     FILE_ENCODING           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid   "Nachrichtenklasse
          TYPE sy-msgty   "Typ (E = Error, S = Success, I = Info, A = Abbruch)
        NUMBER sy-msgno   "Nachrichtennummer
          WITH sy-msgv1   "Platzhaltervariable1
               sy-msgv2   "Platzhaltervariable2
               sy-msgv3   "Platzhaltervariable3
               sy-msgv4.  "Platzhaltervariable4


    MESSAGE i800(29) WITH p_file.  "Die sequentielle Datei & konnte nicht geöffnet werden
    MESSAGE i821(29).               "Verarbeitung wurde abgebrochen

    LEAVE PROGRAM.
  ENDIF.

  READ TABLE lt_file_table INTO ls_file INDEX 1.

  IF sy-subrc = 0.
    p_file = ls_file-filename.
  ENDIF.


ENDFORM.                    " GET_FILENAME




*&---------------------------------------------------------------------*
*&      Form  UPLOAD_FILE
*&---------------------------------------------------------------------*
*       Upload Datei
*----------------------------------------------------------------------*
FORM upload_file     USING iv_file  TYPE rlgrap-filename
                  CHANGING ct_file  TYPE tty_file.


  DATA: lv_filename TYPE string.

  CONSTANTS: lc_11 TYPE i VALUE 11,
             lc_12 TYPE i VALUE 12,
             lc_13 TYPE i VALUE 13,
             lc_14 TYPE i VALUE 14,
             lc_15 TYPE i VALUE 15,
             lc_16 TYPE i VALUE 16,
             lc_17 TYPE i VALUE 17,
             lc_18 TYPE i VALUE 18,
             lc_19 TYPE i VALUE 19.


  lv_filename = iv_file.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
*     FILETYPE                = 'ASC'
*     HAS_FIELD_SEPARATOR     = SPACE
*     HEADER_LENGTH           = 0
*     READ_BY_LINE            = 'X'
*     DAT_MODE                = SPACE
      codepage                = '1100'   "SAP(ISO)-Codepage 1100 Bezug auf ISO-Codepage 8859-1 (umfasst meiste westeuropäischen Zeichen)
*     IGNORE_CERR             = ABAP_TRUE
*     REPLACEMENT             = '#'
*     VIRUS_SCAN_PROFILE      =
*    IMPORTING
*     FILELENGTH              =
*     HEADER                  =
    CHANGING
      data_tab                = ct_file
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
      header_too_long         = lc_11
      unknown_dp_error        = lc_12
      access_denied           = lc_13
      dp_out_of_memory        = lc_14
      disk_full               = lc_15
      dp_timeout              = lc_16
      not_supported_by_gui    = lc_17
      error_no_gui            = lc_18
      OTHERS                  = lc_19.


  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " UPLOAD_FILE




*&---------------------------------------------------------------------*
*&      Form  READ_FLATFILE_INTO_UPLOAD
*&---------------------------------------------------------------------*
*       Flatfile in strukturierte ITAB konvertieren
*----------------------------------------------------------------------*
FORM read_flatfile_into_upload   USING  it_file   TYPE tty_file
                              CHANGING  ct_upload TYPE tty_upload.


  DATA: ls_file   TYPE ty_file,
        ls_upload TYPE ty_upload.


  LOOP AT it_file INTO ls_file.

    CLEAR ls_upload.

    IF ls_file-data IS NOT INITIAL.
      SPLIT ls_file-data  AT p_split INTO

            ls_upload-client
            ls_upload-applic
            ls_upload-keyfig
            ls_upload-langu
            ls_upload-name
            ls_upload-heading
            ls_upload-var1
            ls_upload-var2
            ls_upload-var3
            ls_upload-var4
            .

      ls_upload-client = sy-mandt.  " ersetzen gegen den aktuellen Mandanten

      APPEND ls_upload TO ct_upload.

    ENDIF. "  IF ls_file-data IS NOT INITIAL.

  ENDLOOP. " LOOP AT it_file INTO ls_file.



ENDFORM.                    " READ_FLATFILE_INTO_UPLOAD




*&---------------------------------------------------------------------*
*&      Form  FILL_ITAB
*&---------------------------------------------------------------------*
*       Füllen Interne Tabelle
*----------------------------------------------------------------------*
FORM fill_itab   USING     it_upload  TYPE tty_upload
                 CHANGING  ct_itab    TYPE tty_itab.



  DATA: ls_file   TYPE ty_file,
        ls_line   TYPE ty_itab,
        ls_upload TYPE ty_itab.


*-----------------------------------------------------*
* Füllen Positionen
*-----------------------------------------------------*
  LOOP AT it_upload ASSIGNING FIELD-SYMBOL(<fs_upload>).

    CLEAR:  ls_line .
    CONCATENATE
        <fs_upload>-client
        <fs_upload>-applic
        <fs_upload>-keyfig
        <fs_upload>-langu
        <fs_upload>-name
        <fs_upload>-heading
        <fs_upload>-var1
        <fs_upload>-var2
        <fs_upload>-var3
        <fs_upload>-var4

            INTO  ls_line-data
     SEPARATED BY p_split.

    APPEND  ls_line  TO ct_itab.

  ENDLOOP. " LOOP AT it_upload ASSIGNING FIELD-SYMBOL(<fs_upload>).



ENDFORM.                    " FILL_OUTPUT




*&---------------------------------------------------------------------*
*&      Form  GET_DOWN_FILE
*&---------------------------------------------------------------------*
*       Fülle Pfad für Downloadfile
*----------------------------------------------------------------------*
FORM get_down_file  USING    iv_file      TYPE rlgrap-filename
                    CHANGING cv_down_file TYPE rlgrap-filename.

  DATA: lv_length TYPE i.

  MOVE iv_file  TO  cv_down_file.

***  lv_length = strlen( iv_file ).
***
**** Inputfilepfad kürzen um ".csv"
***  lv_length = lv_length - 4.
***
**** Inputfilepfad lediglich ergänzen um "_conv_txt"
***  CONCATENATE iv_file(lv_length)
***              '_conv.txt'
***              INTO cv_down_file.



ENDFORM.                    " GET_DOWN_FILE




*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD
*&---------------------------------------------------------------------*
*       Download konvertiertes File
*----------------------------------------------------------------------*
FORM download  USING    iv_down_file TYPE rlgrap-filename
                        it_outfile   TYPE tty_file.

  DATA: lv_filename TYPE string.

  lv_filename = iv_down_file.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
*     BIN_FILESIZE            =
      filename                = lv_filename
*     FILETYPE                = 'ASC'
*     APPEND                  = SPACE
*     WRITE_FIELD_SEPARATOR   = SPACE
*     HEADER                  = '00'
*     TRUNC_TRAILING_BLANKS   = SPACE
*     WRITE_LF                = 'X'
*     COL_SELECT              = SPACE
*     COL_SELECT_MASK         = SPACE
*     DAT_MODE                = SPACE
*     CONFIRM_OVERWRITE       = SPACE
*     NO_AUTH_CHECK           = SPACE
*     CODEPAGE                = SPACE
*     IGNORE_CERR             = ABAP_TRUE
*     REPLACEMENT             = '#'
*     WRITE_BOM               = SPACE
*     TRUNC_TRAILING_BLANKS_EOL = 'X'
*     WK1_N_FORMAT            = SPACE
*     WK1_N_SIZE              = SPACE
*     WK1_T_FORMAT            = SPACE
*     WK1_T_SIZE              = SPACE
*    IMPORTING
*     FILELENGTH              =
    CHANGING
      data_tab                = it_outfile
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.


    MESSAGE i800(29) WITH iv_down_file.
    MESSAGE i821(29).

    LEAVE PROGRAM.

  ENDIF. "  IF sy-subrc <> 0.

ENDFORM.                    " DOWNLOAD




*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_UPLOAD  text
*----------------------------------------------------------------------*
FORM save_data  USING    ct_upload TYPE tty_upload.


  MODIFY (lv_table) FROM TABLE ct_upload.
  COMMIT WORK.

ENDFORM.




*&---------------------------------------------------------------------*
*&      Form  SHOW_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_UPLOAD  text
*----------------------------------------------------------------------*
FORM show_data  USING    ct_upload TYPE tty_upload.


*--------------------------------------------------------------------*
* Ausgabe
*--------------------------------------------------------------------*
  DATA: lr_salv             TYPE REF TO cl_salv_table.
  DATA: go_functions        TYPE REF TO cl_salv_functions.        "Symbolleiste
  DATA: go_display          TYPE REF TO cl_salv_display_settings. "Displayeinstellungen
  DATA: go_columns          TYPE REF TO cl_salv_columns_table.    "Spaltenmanipulation
  DATA: go_column           TYPE REF TO cl_salv_column_table.
  DATA: go_events           TYPE REF TO cl_salv_events_table.     " Events
  DATA: go_selections       TYPE REF TO cl_salv_selections.       " ausgewählte Zeilen

  DATA: gt_columns          TYPE salv_t_column_ref.
  DATA: gs_columns          TYPE salv_s_column_ref.

  DATA: color               TYPE lvc_s_colo.                      "Farbe
  DATA: go_sorts            TYPE REF TO cl_salv_sorts.            "Sortierung
  DATA: go_agg              TYPE REF TO cl_salv_aggregations.     "Aggregation
  DATA: go_filter           TYPE REF TO cl_salv_filters.          "Filter
  DATA: go_layout           TYPE REF TO cl_salv_layout.           "Layout
  DATA: key                 TYPE salv_s_layout_key.

* Fehlerhandling
  DATA: gr_err_salv         TYPE REF TO cx_salv_msg.
  DATA: gr_err_salv_exist   TYPE REF TO cx_salv_existing.
  DATA: gr_err_wrong_call   TYPE REF TO cx_salv_wrong_call.
  DATA: gv_string           TYPE string.

* Info in der oberen Leiste
  DATA: lv_counter          TYPE i.
  DATA: lv_counter_string   TYPE string.
  DATA: lv_info             TYPE lvc_title.




* Setzen einer Entscheidung
  DATA: lt_rows             TYPE salv_t_row.
  DATA: ls_rows             TYPE int4.


* Zähler für Titelbar
  DATA: lv_lin_results        TYPE i.
  DATA: lv_lin_results_string TYPE string.
*--------------------------------------------------------------------*





  TRY.
      cl_salv_table=>factory(
       EXPORTING                                                   " Zusätzlich, um eigene Funktionen zu implementieren
            list_display = if_salv_c_bool_sap=>false               " s.o.
            r_container  = cl_gui_container=>default_screen     " s.o.
       IMPORTING
          r_salv_table   = lr_salv
       CHANGING
          t_table        = ct_upload ).
    CATCH cx_salv_msg INTO gr_err_salv.
*     Fehler anzeigen
      gv_string = gr_err_salv->get_text( ).
      MESSAGE gv_string TYPE 'E'.
  ENDTRY.









**********************************************************************
* Anzeige Parameter setzen
**********************************************************************

* Instanz für Spalten holen
  go_columns = lr_salv->get_columns( ).


****----------------------------------*
**** Feldeigenschaften anpassen
****----------------------------------*
***
****-- KUNNR als Hotspot -----------*
***TRY.
***    go_column ?= go_columns->get_column( 'XXXXX' ).
***  CATCH cx_salv_not_found.
***ENDTRY.
***
****   Set the HotSpot for KUNNR
***TRY.
***    CALL METHOD go_column->set_cell_type
***      EXPORTING
***        value = if_salv_c_cell_type=>hotspot.
***  CATCH cx_salv_data_error .
***ENDTRY.
***
****   Spalte zentriert
***TRY.
***    CALL METHOD go_column->set_alignment
***      EXPORTING
***        value = if_salv_c_alignment=>centered.
***  CATCH cx_salv_data_error .
***ENDTRY.
****----------------------------------*



*----------------------------------*
* Alle verfügbaren Spalten holen
*----------------------------------*
  gt_columns = go_columns->get( ).

**** und jetzt in LOOP die Überschrift ändern
***LOOP AT gt_columns INTO gs_columns.
***  CASE gs_columns-columnname.
***    WHEN 'COUNTER'.
***      gs_columns-r_column->set_short_text( 'Anzahl' ).
***      gs_columns-r_column->set_medium_text( 'Anzahl Einträge' ).
***      gs_columns-r_column->set_long_text( 'Anzahhl Einträge' ).
***
***  ENDCASE.
***ENDLOOP.




*-- Selection zulassen
  go_selections = lr_salv->get_selections( ).
  go_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).


*-- events
  go_events = lr_salv->get_event( ).
**  CREATE OBJECT event_handler.

*** SET HANDLER event_handler->on_click FOR go_events.
*** SET HANDLER event_handler->on_link_click   FOR go_events.



*   Symbolleiste wird eingeblendet
  go_functions = lr_salv->get_functions( ).
  go_functions->set_all( abap_true ).


*-- Parameter setzen
  go_display = lr_salv->get_display_settings( ).
  go_display->set_striped_pattern( cl_salv_display_settings=>true ).

***  IF p_test IS NOT INITIAL.
***    go_display->set_list_header( 'Testlauf' ).
***  ELSE.
***    go_display->set_list_header( 'Echtlauf' ).
***  ENDIF.


  CLEAR: lv_lin_results, lv_lin_results_string, lv_info.

  DESCRIBE TABLE ct_upload LINES lv_lin_results.       " zählen
  MOVE lv_lin_results TO  lv_lin_results_string.       " in zeichenartiges Objekt umwandeln


  IF p_test IS NOT INITIAL.

    CONCATENATE '*** Testlauf *** / '
                'Anzahl Einträge:'
                lv_lin_results_string
          INTO  lv_info
   SEPARATED BY space.

  ELSE.

    CONCATENATE '!!! Echtlauf !!! / '
                'Anzahl Einträge:'
                lv_lin_results_string
          INTO  lv_info
   SEPARATED BY space.

  ENDIF. "  IF p_test IS NOT INITIAL.

  go_display->set_list_header( lv_info ).


* Sortierung
  go_sorts = lr_salv->get_sorts( ).
  "gr_sorts->add_sort( 'SPALTENNAME' ).

* Layout (Layoutänderungen abspeicherbar)
  go_layout   = lr_salv->get_layout( ).
  key-report  = sy-repid.
  go_layout->set_key( key ).
  go_layout->set_save_restriction( cl_salv_layout=>restrict_none ).

  go_layout->set_initial_layout( '/DEFAULT' ).


**********************************************************************
* Anzeige Tabelle
**********************************************************************
  lr_salv->display( ).


* "Trägerbildschirm" für Container rufen
* ist nur notwendig, da bei CL_SALV_TABLE=>FACTORY ein Container angegeben wurde
  WRITE space.





ENDFORM.
