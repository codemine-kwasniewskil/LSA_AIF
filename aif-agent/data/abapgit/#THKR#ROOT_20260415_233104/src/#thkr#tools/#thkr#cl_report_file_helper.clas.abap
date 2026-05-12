class /THKR/CL_REPORT_FILE_HELPER definition
  public
  final
  create public .

public section.

  class-methods GUI_ASCII_UPLOAD
    importing
      !FILEPATH type STRING
    returning
      value(DATA_TAB) type STRINGTAB
    raising
      /THKR/CX_REPORT_FILE_HELPER .
  class-methods GUI_ASCII_DOWNLOAD
    importing
      !FILEPATH type STRING
      !DATA_TAB type STRINGTAB
    raising
      /THKR/CX_REPORT_FILE_HELPER .
  class-methods GUI_DOWNLOAD_DIALOG
    importing
      !DEFAULT_NAME type STRING default 'datei.txt'
    returning
      value(FILEPATH) type STRING
    raising
      /THKR/CX_REPORT_FILE_HELPER .
  class-methods GUI_UPLOAD_DIALOG
    returning
      value(FILEPATH) type STRING
    raising
      /THKR/CX_REPORT_FILE_HELPER .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_REPORT_FILE_HELPER IMPLEMENTATION.


  method GUI_ASCII_DOWNLOAD.

   data(data_to_write) = data_tab.

    cl_gui_frontend_services=>gui_download(
      EXPORTING
        filename                  = filepath             " Name der Datei
*      IMPORTING
*        filelength                = data(filelength)           " Anzahl der übertragenen Bytes
      CHANGING
        data_tab                  = data_to_write           " Übergabetabelle
      EXCEPTIONS
        file_write_error          = 1                    " Datei kann nicht geschrieben werden
        no_batch                  = 2                    " Frontend-Funktion im Batch nicht ausführbar.
        gui_refuse_filetransfer   = 3                    " falsches Frontend
        invalid_type              = 4                    " Ungültiger Wert für Parameter FILETYPE
        no_authority              = 5                    " Keine Berechtigung für Download
        unknown_error             = 6                    " Unbekannter Fehler
        header_not_allowed        = 7                    " Header ist nicht zulässig.
        separator_not_allowed     = 8                    " Separator ist nicht zulässig.
        filesize_not_allowed      = 9                    " Angabe der Dateigröße nicht zulässig.
        header_too_long           = 10                   " Die Headerinformation ist zur Zeit auf maximal 1023 Bytes be
        dp_error_create           = 11                   " DataProvider kann nicht erzeugt werden
        dp_error_send             = 12                   " Fehler beim Senden der Daten durch DP
        dp_error_write            = 13                   " Fehler beim Schreiben der Daten durch DP
        unknown_dp_error          = 14                   " Fehler beim Aufruf des Dataprovider
        access_denied             = 15                   " Zugriff auf Datei nicht erlaubt.
        dp_out_of_memory          = 16                   " Nicht genug Speicher im Dataprovider
        disk_full                 = 17                   " Speichermedium ist voll.
        dp_timeout                = 18                   " Timeout des Dataproviders
        file_not_found            = 19                   " Datei konnte nicht gefunden werden.
        dataprovider_exception    = 20                   " Allgemeiner Ausnahmefehler im Dataprovider
        control_flush_error       = 21                   " Fehler im Controlframework.
        not_supported_by_gui      = 22                   " Nicht unterstützt von GUI
        error_no_gui              = 23                   " GUI nicht verfügbar
    ).
    IF SY-SUBRC <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_report_file_helper
        EXPORTING
          textid = /thkr/cx_report_file_helper=>file_error
          v1  = 'File Download'
          v2  = CONV #( sy-subrc ).
    ENDIF.

  endmethod.


  METHOD gui_ascii_upload.

    DATA(data_to_write) = data_tab.

    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = filepath              " Name der Datei
*  IMPORTING
*       filelength              = filelength         " Dateilänge
*       header                  = header             " Header der Datei bei binärem Upload
      CHANGING
        data_tab                = data_tab           " Übergabetabelle für Datei-Inhalt
*       isscanperformed         = space              " File ist bereits gescannt
      EXCEPTIONS
        file_open_error         = 1                  " Datei nicht vorhanden, kann nicht geöffnet werde
        file_read_error         = 2                  " Fehler beim Lesen der Datei
        no_batch                = 3                  " Frontend-Funktion im Batch nicht ausführbar.
        gui_refuse_filetransfer = 4                  " Falsches Frontend oder Fehler im Frontend
        invalid_type            = 5                  " Falscher Parameter FILETYPE
        no_authority            = 6                  " Keine Berechtigung für Upload
        unknown_error           = 7                  " Unbekannter Fehler
        bad_data_format         = 8                  " Daten in der Datei können nicht interpretiert werden.
        header_not_allowed      = 9                  " Header ist nicht zulässig.
        separator_not_allowed   = 10                 " Separator ist nicht zulässig.
        header_too_long         = 11                 " Die Headerinformation ist zur Zeit auf maximal 1023 Bytes be
        unknown_dp_error        = 12                 " Fehler beim Aufruf des Dataprovider
        access_denied           = 13                 " Zugriff auf Datei nicht erlaubt.
        dp_out_of_memory        = 14                 " Nicht genug Speicher im Dataprovider
        disk_full               = 15                 " Speichermedium ist voll.
        dp_timeout              = 16                 " Timeout des Dataproviders
        not_supported_by_gui    = 17                 " Nicht unterstützt von GUI
        error_no_gui            = 18                 " GUI nicht verfügbar
    ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_report_file_helper
        EXPORTING
          textid = /thkr/cx_report_file_helper=>file_error
          v1     = 'File Upload'
          v2     = CONV #( sy-subrc ).
    ENDIF.


  ENDMETHOD.


  METHOD gui_download_dialog.
    DATA: filename TYPE string,
          path     TYPE string,
          fullpath TYPE string.

    cl_gui_frontend_services=>file_save_dialog(
      EXPORTING
        default_file_name         = default_name
      CHANGING
        filename                  = filename          " Dateiname für Sichern
        path                      = path              " Pfad zu Datei
        fullpath                  = filepath          " Pfad + Dateiname
      EXCEPTIONS
        cntl_error                = 1                 " Controlfehler
        error_no_gui              = 2                 " Kein GUI verfügbar
        not_supported_by_gui      = 3                 " Nicht unterstützt von GUI
        invalid_default_file_name = 4                 " Invalider default Dateiname
    ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_report_file_helper
        EXPORTING
          textid = /thkr/cx_report_file_helper=>dialog_error
          v1  = 'File Save'
          v2  = CONV #( sy-subrc ).
    ENDIF.

  ENDMETHOD.


  METHOD gui_upload_dialog.
    DATA: file_table TYPE filetable,
          rc         TYPE i.

    cl_gui_frontend_services=>file_open_dialog(
      CHANGING
        file_table              = file_table        " Tabelle, die selektierte Dateien enthält
        rc                      = rc                " Rückgabewert: Anzahl Dateien oder -1 falls Fehler auftritt
      EXCEPTIONS
        file_open_dialog_failed = 1                 " Dialog: "Datei Öffnen" fehlgeschlagen
        cntl_error              = 2                 " Controlfehler
        error_no_gui            = 3                 " Kein GUI verfügbar
        not_supported_by_gui    = 4                 " Nicht unterstützt von GUI
    ).
    IF sy-subrc <> 0 OR rc = -1 OR file_table IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_report_file_helper
        EXPORTING
          textid = /thkr/cx_report_file_helper=>dialog_error
          v1     = 'File Open'
          v2     = CONV #( sy-subrc ).
    ENDIF.
    filepath = file_table[ 1 ].
  ENDMETHOD.
ENDCLASS.
