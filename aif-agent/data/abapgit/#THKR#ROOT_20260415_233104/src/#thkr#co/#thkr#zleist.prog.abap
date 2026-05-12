*&---------------------------------------------------------------------*
*& Report /THKR/ZLEIST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/zleist.

************************************************************************
*Übernahme Mitarbeiter (entspr. Besoldung) pro Kostenstelle und Arbeits-
*anteil (je MA und KOSTL) aus EXCEL-Datei (vom Typ .txt mit Spaltentabu-
*latoren
************************************************************************
*TABLES: usr02, coas, cbpr, csks, /thkr/co_leist.

DATA: gt_recin     TYPE TABLE OF /thkr/co_leist_input,
      gs_recin     TYPE /thkr/co_leist_input,
      gv_datei     TYPE string,
      gv_rc        TYPE char1,
      gv_dienst(4) TYPE c.

DATA: gt_files TYPE TABLE OF file_table,
      gs_files TYPE file_table,
      gv_file  TYPE string.

*PARAMETERS: p_dienst(4) OBLIGATORY,
PARAMETERS: p_file  TYPE string OBLIGATORY.     "DEFAULT 'A:/sap/leistJJJJMMDDDD.txt' .

SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 37(45) TEXT-000.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 37(45) TEXT-001.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 37(45) TEXT-002.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 37(45) TEXT-003.
SELECTION-SCREEN SKIP.
PARAMETERS  p_simu(1) DEFAULT 'X'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM get_filename CHANGING p_file.

************************************************************************
START-OF-SELECTION.

  IF p_simu = 'X'.
    WRITE: / 'Die Verarbeitung der Datei(en) erfolgt im Simulationslauf.'.
  ELSE.
    WRITE: / 'Die Verarbeitung der Datei(en) erfolgt im Echtlauf.'.
  ENDIF.
  WRITE: /.

  IF lines( gt_files ) = 0.
    gs_files-filename = p_file.
    APPEND gs_files TO gt_files.
  ENDIF.

*  IF lines( gt_files ) = 0.
*    PERFORM get_datei.
*  ENDIF.

  LOOP AT gt_files INTO gs_files.

    gv_file = gs_files-filename.
    WRITE: / 'Datei', gv_file, 'wird verarbeitet.'.
    WRITE: /.


* Einlesen der LEIST-Datei
    CALL METHOD /thkr/cl_co_leistungsrechnung=>datei_einlesen
      EXPORTING
        i_dateiname = gv_file           "p_file
      IMPORTING
        e_recin     = gt_recin
        e_datei     = gv_datei
        e_rc        = gv_rc.

    IF NOT gv_rc IS INITIAL.
      ULINE.
      CASE gv_rc.
        WHEN '4'.
          WRITE: / 'Datei', gv_datei, 'wurde bereits verarbeitet.' COLOR 3.
          WRITE: / '!!! Sollte die Datei erneut verarbeitet werden, dann den Status !!!' COLOR 3.

          AUTHORITY-CHECK OBJECT 'S_TCODE'
           ID 'TCD' FIELD '/THKR/LEIST_DATEI'.
          IF sy-subrc = 0.
            WRITE: / '!!! in der Tabelle /THKR/CO_LEIST_D (TA /THKR/LEIST_DATEI) für diese Datei zurücksetzen !!!' COLOR 3.
          ELSE.
            WRITE: / '!!! dieser Datei zurücksetzen lassen. Bitte wenden Sie sich an Ihren zuständigen Admin/ZHM !!!' COLOR 3.
          ENDIF.

        WHEN '8'.
          WRITE: / 'Dateiname', gv_datei, 'unzulässig' COLOR 3.
          WRITE: / 'Richtiger Dateiname:    leistJJJJMMDDDD.txt' COLOR 5.
        WHEN OTHERS.
      ENDCASE.
      ULINE.
      CONTINUE.    "    EXIT.
    ENDIF.

* Prüfen Berechtigung des Users
    gv_dienst = gv_datei+11(4).
    CALL METHOD /thkr/cl_co_leistungsrechnung=>check_user
      EXPORTING
        i_dienststelle = gv_dienst
      IMPORTING
        e_rc           = gv_rc.

    IF NOT gv_rc IS INITIAL.
      WRITE: / 'Die Verarbeitung der Datei', gv_datei, 'wurde abgebrochen.' COLOR 3.
      CONTINUE.
    ENDIF.


* Prüfen der Datei und der Datensätze
    CALL METHOD /thkr/cl_co_leistungsrechnung=>check_daten
      EXPORTING
        i_dienststelle = gv_dienst
      IMPORTING
        e_rc           = gv_rc
      CHANGING
        c_recin        = gt_recin.


    IF NOT gv_rc IS INITIAL.
      ULINE.
      WRITE: / '!!! Datei fehlerhaft, keine Buchungen im SAP-System !!!' COLOR 3.
      WRITE: / '!!! Bitte Datei korrigieren !!!' COLOR 3.
*      WRITE: / '!!! Vor erneuter Verarbeitung des Status in der Tabelle /THKR/CO_LEIST_D !!!' COLOR 3.
*      WRITE: / '!!! (TA /THKR/LEIST_DATEI) für diese Datei zurücksetzen !!!' COLOR 3.
      ULINE.
      CONTINUE.    "EXIT.
    ENDIF.


    IF p_simu IS INITIAL.
*   Buchen der Belege und Erstellen der Fehlermappe
      CALL METHOD /thkr/cl_co_leistungsrechnung=>belege_buchen
        EXPORTING
          i_dienststelle = gv_dienst
        IMPORTING
          e_rc           = gv_rc
        CHANGING
          c_recin        = gt_recin.

*     Protokolldatensatz schreiben
      CALL METHOD /thkr/cl_co_leistungsrechnung=>schreiben_protokoll
        EXPORTING
          i_dateiname = gv_datei.

    ENDIF.

  ENDLOOP.

  IF sy-subrc <> 0.
    WRITE: / '!!! Es stand keine Datei zur Verarbeitung zur Verfügung !!!' COLOR 3.
  ENDIF.

****************************************************************************

FORM get_filename CHANGING cf_filename TYPE string.

  DATA:
    lt_filetable TYPE filetable,
    ls_filetable TYPE file_table,
    lf_action    TYPE i,
    lf_return    TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
*     window_title            =
      default_extension       = 'CSV'
      file_filter             = '*.CSV'
      multiselection          = 'X'
*     with_encoding           =
    CHANGING
      file_table              = lt_filetable
      rc                      = lf_return
      user_action             = lf_action
*     file_encoding           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    " error handling
    MESSAGE ID   sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.
  " OK => use filename
  IF    lf_action = cl_gui_frontend_services=>action_ok
    AND lf_return = 1.
*     Determine file name
    READ TABLE lt_filetable INTO ls_filetable INDEX 1.
    IF sy-subrc IS INITIAL.
*       take over file name
      cf_filename = ls_filetable-filename.
    ENDIF.
  ENDIF.

  gt_files = lt_filetable.
  IF lines( lt_filetable ) > 1.
    cf_filename = 'Mehrfachauswahl'.
  ENDIF.

ENDFORM.                    " get_filename


*&---------------------------------------------------------------------*
*& Form get_verzeichnis
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_FILE
*&---------------------------------------------------------------------*
*FORM get_datei.
*
*  DATA: lt_file  TYPE TABLE OF file_info,
*        ls_file  TYPE file_info,
*        lv_count TYPE i.
*
*  CALL METHOD cl_gui_frontend_services=>directory_list_files
*    EXPORTING
*      directory                   = p_verz
*      filter                      = p_file
*      files_only                  = 'X'
**     directories_only            =
*    CHANGING
*      file_table                  = lt_file
*      count                       = lv_count
*    EXCEPTIONS
*      cntl_error                  = 1
*      directory_list_files_failed = 2
*      wrong_parameter             = 3
*      error_no_gui                = 4
*      not_supported_by_gui        = 5
*      OTHERS                      = 6.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ELSE.
*    IF lv_count > 0.
*      LOOP AT lt_file INTO ls_file.
*        IF ls_file-filename CP '*leist*'.
*          CONCATENATE p_verz '\' ls_file-filename INTO gs_files-filename.
*          APPEND gs_files TO gt_files.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.
*
*
*ENDFORM.
