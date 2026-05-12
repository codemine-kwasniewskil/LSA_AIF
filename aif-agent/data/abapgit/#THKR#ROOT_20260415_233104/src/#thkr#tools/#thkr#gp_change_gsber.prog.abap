*&---------------------------------------------------------------------*
*& Report /THKR/GP_CHANGE_GSBER                                        *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& Das Feld GSBER mittels einer EXCEL-Datei in der Tabelle BUT000      *
*& anpassen.                                                           *
*&                                                                     *
*& Spalten der EXCEL-Tabelle                                           *
*& Spalte A: Geschäftspartner      - Inhalt PFLICHT                    *
*& Spalte B: Ext. Partnernummer    - Inhalt kann auch leer sein        *
*& Spalte C: BP: Geschäftsbereich  - Inhalt PFLICHT - Alter GSBER      *
*& Spalte D: Richtiger Geschäftsbereich - Inhalt PFLICHT - Neuer GSBER *
*& Spalte E: Hinweis               - Inhalt kann auch leer sein        *
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        05.02.2026                                            *
*&                                                                     *
*& l. Änderung:  06.02.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/gp_change_gsber.

************************************************************************
* TOP - Include - Deklarationen                                        *
************************************************************************
INCLUDE /thkr/gp_change_gsber_top.

************************************************************************
* SCR - Include - Deklarationen                                        *
************************************************************************
INCLUDE /thkr/gp_change_gsber_scr.

************************************************************************
* Start der Programmverarbeitung                                       *
************************************************************************
START-OF-SELECTION.
  IF p_file IS INITIAL.
    MESSAGE 'Bitte Excel-Datei angeben'
    TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF p_file CP '*.csv'.
    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename = p_file
        filetype = 'ASC'
      CHANGING
        data_tab = gt_raw_data
      EXCEPTIONS
        OTHERS   = 1 ).
    IF sy-subrc = 0.
      LOOP AT gt_raw_data INTO DATA(lv_line).
        APPEND INITIAL LINE TO gt_target ASSIGNING FIELD-SYMBOL(<fs_row>).
        SPLIT lv_line AT ';' INTO <fs_row>-s1_partner
                                  <fs_row>-s2_butext
                                  <fs_row>-s3_ogsber
                                  <fs_row>-s4_ngsber
                                  <fs_row>-s5_txt
                                  <fs_row>-s6_dummy
                                  <fs_row>-s7_dummy.
      ENDLOOP.
    ENDIF.

  ELSE.
    MESSAGE 'Nur Excel-Dateien werden verarbeitet!' TYPE 'I'.
  ENDIF.

************************************************************************
* Verarbeitung und Prüfung der Inhalte und Anpassung des GSBER         *
************************************************************************
  DESCRIBE TABLE gt_target LINES gv_lines.
  MOVE gv_lines TO gv_nlines.
  LOOP AT gt_target INTO gs_target.
    IF NOT p_head IS INITIAL AND
       sy-tabix EQ 1.
      CONTINUE.
    ENDIF.
    gv_prozent = sy-tabix / gv_lines.
    MOVE sy-tabix TO gv_nindex.
    CONCATENATE 'Verarbeite Datensatz ' gv_nindex ' / ' gv_nlines
              INTO gv_msg RESPECTING BLANKS.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = gv_prozent
        text       = gv_msg.

    IF NOT gs_target-s4_ngsber IS INITIAL.
************************************************************************
*     Prüfung, ob der neue GSBER auch gültig ist.                      *
************************************************************************
      READ TABLE gt_gsber TRANSPORTING NO FIELDS
                  WITH KEY gsber = gs_target-s4_ngsber.
      IF 0 EQ sy-subrc.
        MOVE gs_target-s1_partner TO gv_npartner.
        MOVE gv_npartner          TO gv_partner.
        SELECT SINGLE * FROM but000 INTO gs_but000
                        WHERE partner EQ gv_partner.
        IF 0 EQ sy-subrc.
          UPDATE but000 SET /thkr/gsber = gs_target-s4_ngsber(4)
                          WHERE partner EQ gs_but000-partner.
          IF 0 EQ sy-subrc.
            WRITE: /5  gs_but000-partner,
                       ' | ',
                       gs_but000-/thkr/gsber,
                       ' | ',
                       gs_target-s4_ngsber,
                       ' | geändert!'.
          ELSE.
            WRITE: /5  gs_but000-partner,
                       ' | ',
                       gs_but000-/thkr/gsber,
                       ' | ',
                       gs_target-s4_ngsber,
                       ' | ERROR: Update fehlerhaft!'.
          ENDIF.
        ELSE.
          WRITE: /5  gs_target-s1_partner,
                     ' | ',
                     gs_target-s3_ogsber,
                     ' | ',
                     gs_target-s4_ngsber,
                     ' | ERROR: GP nicht vorhanden!'.
        ENDIF.
      ELSE.
        WRITE: /5  gs_target-s1_partner,
                   ' | ',
                   gs_target-s3_ogsber,
                   ' | ',
                   gs_target-s4_ngsber,
                   ' | ERROR: Kein GÜLTIGER GSBER!'.
      ENDIF.
    ELSE.
      WRITE: /5  gs_target-s1_partner,
                 ' | ',
                 gs_target-s3_ogsber,
                 ' | ',
                 gs_target-s4_ngsber,
                 ' | ERROR: Kein neuer GSBER!'.
    ENDIF.
  ENDLOOP.

INITIALIZATION.
************************************************************************
* Initialisierung Selektions-Title                                     *
************************************************************************
  a1_titel = TEXT-t01.
  SELECT * FROM tgsb INTO TABLE gt_gsber.
