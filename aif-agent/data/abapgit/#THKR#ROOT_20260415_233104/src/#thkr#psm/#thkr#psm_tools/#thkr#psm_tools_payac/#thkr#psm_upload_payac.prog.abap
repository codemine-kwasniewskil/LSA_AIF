*&---------------------------------------------------------------------*
*& Report ZZ_PSM_UPLOAD_PAYAC_S1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* Funktion: * Daten-Upload für die Tabelle PAYAC01

* welches die Pflege (Anlegen, Löschen) anhand einer lokalen CSV Datei
* ermöglicht. Die Daten werden zur Prüfung und als Protokoll nach der
* Verarbeitung in einem ALV-Grid dargestellt.

*

REPORT /thkr/psm_upload_payac MESSAGE-ID /thkr/fi_init.

*
INCLUDE /thkr/psm_upload_payac_s1_top.
*
INCLUDE /thkr/psm_upload_payac_s1_sel.
*
INCLUDE /thkr/psm_upload_payac_s1_f01.


* F4-Hilfe
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
* ---
  PERFORM get_filename CHANGING p_file.
* ---
  PERFORM check_filelen USING p_file.


***

*
START-OF-SELECTION.

* Daten lesen: Lokal
  IF ( p_server IS INITIAL ).
* ---
    PERFORM get_upl_data_local
      USING
        p_file
      CHANGING
        gt_upload.
*    ---
    IF ( gt_upload IS INITIAL ).
      MESSAGE i302.
      RETURN.
    ENDIF.
* --- Daten prüfen
    PERFORM check_data
      CHANGING
        gt_upload.
* --- Daten gegen vorhandene Datensätze prüfen
    PERFORM check_payac
      CHANGING
        gt_upload.
* ---
    IF ( p_test    IS INITIAL ) AND
       ( gv_fehler IS INITIAL ).
* --- --- Daten sichern
      PERFORM save_data CHANGING gt_upload.
* ---
    ENDIF.

* Daten lesen: Server
  ELSE.

* --- Daten neu vom Server einlesen (nicht im Restart-Modus)
    IF ( p_restar IS INITIAL ).
* --- ---
      PERFORM get_upl_data_server
        CHANGING
          gt_upload.
* ---
      DELETE FROM /thkr/psmulpaytm.
      COMMIT WORK.
* ---
      PERFORM db_tmp_insert
        USING
          gt_upload
        CHANGING
          gv_upl_tmp.
* ---
    ENDIF.

*
    IF ( p_test IS INITIAL ).

* --- ---
      CLEAR gt_upload.
*
      PERFORM db_tmp_select
        CHANGING
          gt_upload.

* ---
      CLEAR gv_fehler.

* --- Daten prüfen
      PERFORM check_data
        CHANGING
          gt_upload.

* --- Daten gegen vorhandene Datensätze prüfen
      PERFORM check_payac
        CHANGING
          gt_upload.

      IF ( gv_fehler IS INITIAL ).
* ---
        PERFORM save_data CHANGING gt_upload.
*
      ENDIF.

* ---
      PERFORM db_tmp_update
        USING
          gt_upload.

    ENDIF.

*
  ENDIF.





***

*
END-OF-SELECTION.

* LOKAL / SERVER
*  if ( p_server is initial ).

* ---
  IF ( gv_fehler IS INITIAL ).
* --- --- Protokollausgabe
    WRITE: 'Upload TMP:', gv_upl_tmp COLOR COL_TOTAL INTENSIFIED OFF.
    WRITE: 'Done' COLOR COL_POSITIVE INTENSIFIED OFF.
    ULINE.
  ELSE.

    DELETE gt_upload WHERE ampel = gc_green.
    PERFORM protokoll_ausgeben USING gt_upload.
  ENDIF.
