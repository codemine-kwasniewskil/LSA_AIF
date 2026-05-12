*&---------------------------------------------------------------------*
*& Report /THKR/GP_SET_KORR_CODEPAGE                                   *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& Korrektur der Datenfelder mit fehlerhaften Datencodierung.          *
*&                                                                     *
*& Spalten der CSV-Tabelle                                             *
*& Spalte A: Geschäftspartner      - PARTNER                           *
*& Spalte B: Suchbegirff           - BU_SORT1   nicht relevant         *
*& Spalte C: Name 1                - NAME_ORG1  nicht relevant         *
*& Spalte D: Vorname               - NAME_FIRST nicht relevant         *
*& Spalte E: Nachname              - NAME_LAST  nicht relevant         *
*& Spalte F: Name1/Nachname        - MV_NAME1   nicht relevant         *
*& Spalte G: Name2/Nachname        - MV_NAME2   nicht relevant         *
*& Spalte H: Strasse               -            nicht relevant         *
*& Spalte I: Hausnummer            -            nicht relevant         *
*& Spalte J: Ort                   -            nicht relevant         *
*& Spalte K: PLZ                   -            nicht relevant         *
*&                                                                     *
*& Spalte L: Suchbegirff           - BU_SORT1   Update-Daten UPPER     *
*& Spalte M: Name 1                - NAME_ORG1  Update-Daten           *
*& Spalte N: Vorname               - NAME_FIRST Update-Daten           *
*& Spalte O: Nachname              - NAME_LAST  Update-Daten           *
*& Spalte P: Name1/Nachname        - MV_NAME1   Update-Daten UPPER     *
*& Spalte Q: Name2/Nachname        - MV_NAME2   Update-Daten UPPER     *
*& Spalte R: Strasse               -            Update-Daten           *
*& Spalte S: Hausnummer            -            nicht relevant         *
*& Spalte T: Ort                   -            Update-Daten           *
*& Spalte U: PLZ                   -            nicht relevant         *
*&                                                                     *
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        19.03.2026                                            *
*&                                                                     *
*& l. Änderung:  24.03.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/gp_set_korr_codepage.

************************************************************************
* TOP - Include - Deklarationen                                        *
************************************************************************
INCLUDE /thkr/gp_set_korr_codepage_top.

************************************************************************
* SCR - Include - Deklarationen                                        *
************************************************************************
INCLUDE /thkr/gp_set_korr_codepage_scr.

************************************************************************
* Start der Programmverarbeitung                                       *
************************************************************************
START-OF-SELECTION.
  IF p_file IS INITIAL.
    MESSAGE 'Bitte CSV-Datei angeben'
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
        SPLIT lv_line AT ';' INTO <fs_row>-as_partner
                                  <fs_row>-bs_bu_sort1
                                  <fs_row>-cs_name_org1
                                  <fs_row>-ds_name_first
                                  <fs_row>-es_name_last
                                  <fs_row>-fs_mv_name1
                                  <fs_row>-gs_mv_name2
                                  <fs_row>-hs_street
                                  <fs_row>-is_house_num1
                                  <fs_row>-js_city1
                                  <fs_row>-ks_post_code1
                                  <fs_row>-ls_bu_sort1
                                  <fs_row>-ms_name_org1
                                  <fs_row>-ns_name_first
                                  <fs_row>-os_name_last
                                  <fs_row>-ps_mv_name1
                                  <fs_row>-qs_mv_name2
                                  <fs_row>-rs_street
                                  <fs_row>-ss_house_num1
                                  <fs_row>-ts_city1
                                  <fs_row>-us_post_code1.
      ENDLOOP.
    ENDIF.

  ELSE.
    MESSAGE 'Nur CSV-Dateien werden verarbeitet!' TYPE 'I'.
  ENDIF.

************************************************************************
* Verarbeitung und Prüfung der Inhalte und Anpassung des GSBER         *
************************************************************************
  IF NOT gt_target[] IS INITIAL AND
     NOT p_head IS INITIAL.
    DELETE gt_target INDEX 1.
  ENDIF.

************************************************************************
* Leerzeilen BU_SORT1 ist LEER, entfernen                              *
************************************************************************
  DELETE gt_target WHERE bs_bu_sort1 IS INITIAL.

************************************************************************
* Nur die Decodierten Daten holen und ggf. Nachcodieren wegen '?'      *
************************************************************************
  CLEAR gt_upddata[].
  DESCRIBE TABLE gt_target LINES gv_lines.
  MOVE gv_lines TO gv_nlines.
  LOOP AT gt_target INTO gs_target.
    gv_prozent = sy-tabix / gv_lines.
    MOVE sy-tabix TO gv_nindex.
    CONCATENATE 'Verarbeite Datensatz ' gv_nindex ' / ' gv_nlines
              INTO gv_msg RESPECTING BLANKS.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = gv_prozent
        text       = gv_msg.

    CLEAR gs_upddata.
    MOVE: gs_target-as_partner    TO gv_npartner,
          gv_npartner             TO gs_upddata-partner,
          gs_target-ls_bu_sort1   TO gs_upddata-bu_sort1,
          gs_target-ms_name_org1  TO gs_upddata-name_org1,
          gs_target-ns_name_first TO gs_upddata-name_first,
          gs_target-os_name_last  TO gs_upddata-name_last,
          gs_target-ps_mv_name1   TO gs_upddata-mv_name1,
          gs_target-qs_mv_name2   TO gs_upddata-mv_name2,
          gs_target-rs_street     TO gs_upddata-street,
          gs_target-ss_house_num1 TO gs_upddata-house_num1,
          gs_target-ts_city1      TO gs_upddata-city1,
          gs_target-us_post_code1 TO gs_upddata-post_code1.

************************************************************************
*    Prüfung der Felder auf 'ß' bei SORT1  und dann Korrektur des      *
*    nächsten Zeichen                                                  *
************************************************************************
    FIND FIRST OCCURRENCE OF 'ß' IN gs_upddata-bu_sort1.
    IF 0 EQ sy-subrc.
      gv_offset_f = 0.
      gv_length_f = strlen( gs_upddata-bu_sort1 ).
      WHILE gv_offset_f <= gv_length_f.
        gv_char = gs_upddata-bu_sort1+gv_offset_f(1).
        IF gv_char = 'ß'.
          ADD 1 TO gv_offset_f.
          IF gv_offset_f LT gv_length_f.
            gv_wrong_char = gs_upddata-bu_sort1+gv_offset_f(1).
            REPLACE FIRST OCCURRENCE OF gv_wrong_char IN gs_upddata-bu_sort1 WITH ''.
            gv_length_f = strlen( gs_upddata-bu_sort1 ).
          ENDIF.
        ENDIF.
        ADD 1 TO gv_offset_f.
      ENDWHILE.
    ENDIF.
    TRANSLATE gs_upddata-bu_sort1 TO UPPER CASE.

************************************************************************
*    Prüfung der Felder auf 'ß' bei ORG1  und dann Korrektur des      *
*    nächsten Zeichen                                                  *
************************************************************************
    FIND FIRST OCCURRENCE OF 'ß' IN gs_upddata-name_org1.
    IF 0 EQ sy-subrc.
      gv_offset_f = 0.
      gv_length_f = strlen( gs_upddata-name_org1 ).
      WHILE gv_offset_f <= gv_length_f.
        gv_char = gs_upddata-name_org1+gv_offset_f(1).
        IF gv_char = 'ß'.
          ADD 1 TO gv_offset_f.
          IF gv_offset_f LT gv_length_f.
            gv_wrong_char = gs_upddata-name_org1+gv_offset_f(1).
            REPLACE FIRST OCCURRENCE OF gv_wrong_char IN gs_upddata-name_org1 WITH ''.
            gv_length_f = strlen( gs_upddata-name_org1 ).
          ENDIF.
        ENDIF.
        ADD 1 TO gv_offset_f.
      ENDWHILE.
    ENDIF.

************************************************************************
*    Prüfung der Felder auf 'ß' bei NAME_FIRST und dann Korrektur des  *
*    nächsten Zeichen                                                  *
************************************************************************
    FIND FIRST OCCURRENCE OF 'ß' IN gs_upddata-name_first.
    IF 0 EQ sy-subrc.
      gv_offset_f = 0.
      gv_length_f = strlen( gs_upddata-name_first ).
      WHILE gv_offset_f <= gv_length_f.
        gv_char = gs_upddata-name_first+gv_offset_f(1).
        IF gv_char = 'ß'.
          ADD 1 TO gv_offset_f.
          IF gv_offset_f LT gv_length_f.
            gv_wrong_char = gs_upddata-name_first+gv_offset_f(1).
            REPLACE FIRST OCCURRENCE OF gv_wrong_char IN gs_upddata-name_first WITH ''.
            gv_length_f = strlen( gs_upddata-name_first ).
          ENDIF.
        ENDIF.
        ADD 1 TO gv_offset_f.
      ENDWHILE.
    ENDIF.

************************************************************************
*    Prüfung der Felder auf 'ß' bei NAME_LAST und dann Korrektur des   *
*    nächsten Zeichen                                                  *
************************************************************************
    FIND FIRST OCCURRENCE OF 'ß' IN gs_upddata-name_last.
    IF 0 EQ sy-subrc.
      gv_offset_f = 0.
      gv_length_f = strlen( gs_upddata-name_last ).
      WHILE gv_offset_f <= gv_length_f.
        gv_char = gs_upddata-name_last+gv_offset_f(1).
        IF gv_char = 'ß'.
          ADD 1 TO gv_offset_f.
          IF gv_offset_f LT gv_length_f.
            gv_wrong_char = gs_upddata-name_last+gv_offset_f(1).
            REPLACE FIRST OCCURRENCE OF gv_wrong_char IN gs_upddata-name_last WITH ''.
            gv_length_f = strlen( gs_upddata-name_last ).
          ENDIF.
        ENDIF.
        ADD 1 TO gv_offset_f.
      ENDWHILE.
    ENDIF.

************************************************************************
*    Prüfung der Felder auf 'ß' bei MV_NAME1  und dann Korrektur des   *
*    nächsten Zeichen                                                  *
************************************************************************
    FIND FIRST OCCURRENCE OF 'ß' IN gs_upddata-mv_name1.
    IF 0 EQ sy-subrc.
      gv_offset_f = 0.
      gv_length_f = strlen( gs_upddata-mv_name1 ).
      WHILE gv_offset_f <= gv_length_f.
        gv_char = gs_upddata-mv_name1+gv_offset_f(1).
        IF gv_char = 'ß'.
          ADD 1 TO gv_offset_f.
          IF gv_offset_f LT gv_length_f.
            gv_wrong_char = gs_upddata-mv_name1+gv_offset_f(1).
            REPLACE FIRST OCCURRENCE OF gv_wrong_char IN gs_upddata-mv_name1 WITH ''.
            gv_length_f = strlen( gs_upddata-mv_name1 ).
          ENDIF.
        ENDIF.
        ADD 1 TO gv_offset_f.
      ENDWHILE.
    ENDIF.
    TRANSLATE gs_upddata-mv_name1 TO UPPER CASE.

************************************************************************
*    Prüfung der Felder auf 'ß' bei MV_NAME2  und dann Korrektur des   *
*    nächsten Zeichen                                                  *
************************************************************************
    FIND FIRST OCCURRENCE OF 'ß' IN gs_upddata-mv_name2.
    IF 0 EQ sy-subrc.
      gv_offset_f = 0.
      gv_length_f = strlen( gs_upddata-mv_name2 ).
      WHILE gv_offset_f <= gv_length_f.
        gv_char = gs_upddata-mv_name2+gv_offset_f(1).
        IF gv_char = 'ß'.
          ADD 1 TO gv_offset_f.
          IF gv_offset_f LT gv_length_f.
            gv_wrong_char = gs_upddata-mv_name2+gv_offset_f(1).
            REPLACE FIRST OCCURRENCE OF gv_wrong_char IN gs_upddata-mv_name2 WITH ''.
            gv_length_f = strlen( gs_upddata-mv_name2 ).
          ENDIF.
        ENDIF.
        ADD 1 TO gv_offset_f.
      ENDWHILE.
    ENDIF.
    TRANSLATE gs_upddata-mv_name2 TO UPPER CASE.

************************************************************************
*    Prüfung der Felder auf 'ß' bei STREET und dann Korrektur des      *
*    nächsten Zeichen                                                  *
************************************************************************
    FIND FIRST OCCURRENCE OF 'ß' IN gs_upddata-street.
    IF 0 EQ sy-subrc.
      gv_offset_f = 0.
      gv_length_f = strlen( gs_upddata-street ).
      WHILE gv_offset_f <= gv_length_f.
        gv_char = gs_upddata-street+gv_offset_f(1).
        IF gv_char = 'ß'.
          ADD 1 TO gv_offset_f.
          IF gv_offset_f LT gv_length_f.
            gv_wrong_char = gs_upddata-street+gv_offset_f(1).
            REPLACE FIRST OCCURRENCE OF gv_wrong_char IN gs_upddata-street WITH ''.
            gv_length_f = strlen( gs_upddata-street ).
          ENDIF.
        ENDIF.
        ADD 1 TO gv_offset_f.
      ENDWHILE.
    ENDIF.

************************************************************************
*    Prüfung der Felder auf 'ß' bei city1  und dann Korrektur des      *
*    nächsten Zeichen                                                  *
************************************************************************
    FIND FIRST OCCURRENCE OF 'ß' IN gs_upddata-city1.
    IF 0 EQ sy-subrc.
      gv_offset_f = 0.
      gv_length_f = strlen( gs_upddata-city1 ).
      WHILE gv_offset_f <= gv_length_f.
        gv_char = gs_upddata-city1+gv_offset_f(1).
        IF gv_char = 'ß'.
          ADD 1 TO gv_offset_f.
          IF gv_offset_f LT gv_length_f.
            gv_wrong_char = gs_upddata-city1+gv_offset_f(1).
            REPLACE FIRST OCCURRENCE OF gv_wrong_char IN gs_upddata-city1 WITH ''.
            gv_length_f = strlen( gs_upddata-city1 ).
          ENDIF.
        ENDIF.
        ADD 1 TO gv_offset_f.
      ENDWHILE.
    ENDIF.

    APPEND gs_upddata TO gt_upddata.
  ENDLOOP.
************************************************************************
* Prüfung der Felder auf '"' und Lösche dieses Zeichen                 *
************************************************************************
  REPLACE ALL OCCURRENCES OF '"' IN TABLE gt_upddata WITH ''.
  MOVE-CORRESPONDING gt_upddata TO gt_chgdata.

  LOOP AT gt_chgdata ASSIGNING <gfs_chg>.
    SELECT SINGLE partner_guid FROM but000 INTO <gfs_chg>-partner_guid
                        WHERE partner = <gfs_chg>-partner.
    SELECT SINGLE addrnumber FROM but020 INTO <gfs_chg>-addrnumber
                        WHERE partner = <gfs_chg>-partner.
  ENDLOOP.

************************************************************************
* Update durchführen                                                   *
************************************************************************
  DESCRIBE TABLE gt_chgdata LINES gv_lines.
  MOVE gv_lines TO gv_nlines.
  IF p_test IS INITIAL.
    LOOP AT gt_chgdata INTO gs_chgdata.
      gv_prozent = sy-tabix / gv_lines.
      MOVE sy-tabix TO gv_nindex.
      CONCATENATE 'Ändere Datensatz ' gv_nindex ' / ' gv_nlines
                INTO gv_msg RESPECTING BLANKS.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = gv_prozent
          text       = gv_msg.
      PERFORM set_newdata USING gs_chgdata.
    ENDLOOP.
  ELSE.
    LOOP AT gt_chgdata INTO gs_chgdata.
      gv_prozent = sy-tabix / gv_lines.
      MOVE sy-tabix TO gv_nindex.
      CONCATENATE 'Testausgabe Datensatz ' gv_nindex ' / ' gv_nlines
                INTO gv_msg RESPECTING BLANKS.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = gv_prozent
          text       = gv_msg.
      IF sy-batch IS INITIAL.
        WRITE: /5 gs_chgdata-partner,    gv_trenner,
                  gs_chgdata-bu_sort1,   gv_trenner,
                  gs_chgdata-name_last,  gv_trenner,
                  gs_chgdata-name_first, gv_trenner,
                  gs_chgdata-name_org1,  gv_trenner,
                  gs_chgdata-mv_name1,   gv_trenner,
                  gs_chgdata-mv_name2,   gv_trenner,
                  gs_chgdata-post_code1, gv_trenner,
                  gs_chgdata-city1,      gv_trenner,
                  gs_chgdata-street,     gv_trenner,
                  gs_chgdata-house_num1, gv_trenner,
                  ' TEST !'.
      ELSE.
        CONCATENATE gs_chgdata-partner    gv_trenner
                    gs_chgdata-bu_sort1   gv_trenner
                    gs_chgdata-name_last  gv_trenner
                    gs_chgdata-name_first gv_trenner
                    gs_chgdata-name_org1  gv_trenner
                    gs_chgdata-mv_name1   gv_trenner
                    gs_chgdata-mv_name2   gv_trenner
                    gs_chgdata-post_code1 gv_trenner
                    gs_chgdata-city1      gv_trenner
                    gs_chgdata-street     gv_trenner
                    gs_chgdata-house_num1 gv_trenner
                    ' TEST !' INTO gv_strmsg RESPECTING BLANKS.
        MESSAGE gv_strmsg TYPE 'S'.
      ENDIF.
    ENDLOOP.
  ENDIF.

INITIALIZATION.
************************************************************************
* Initialisierung Selektions-Title                                     *
************************************************************************
  a1_titel = TEXT-t01.


*&---------------------------------------------------------------------*
*& Form set_newdata                                                    *
*&---------------------------------------------------------------------*
*& Setzen der Felds XDELE für ausgewählte GP's                         *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM set_newdata USING ps_newdat TYPE ty_upddata.
************************************************************************
* Lokale Variablen                                                     *
************************************************************************
  DATA: lv_trenner TYPE c LENGTH 3 VALUE ' | ',
        lv_strmsg  TYPE string,
        lv_street  TYPE ad_mc_strt,
        lv_city1   TYPE ad_city1.

************************************************************************
*     BUT000 direkt Update für MC_NAME1 und MC_NAME2                   *
************************************************************************
  UPDATE but000 SET bu_sort1   = ps_newdat-bu_sort1
                    name_org1  = ps_newdat-name_org1
                    name_last  = ps_newdat-name_last
                    name_first = ps_newdat-name_first
                    mc_name1   = ps_newdat-mv_name1
                    mc_name2   = ps_newdat-mv_name2
                WHERE partner EQ ps_newdat-partner.

  IF 0 EQ sy-subrc.
************************************************************************
*     ADRC   direkt Update für MC_NAME1 und MC_NAME2                   *
************************************************************************
    MOVE ps_newdat-city1 TO lv_city1.
    CONCATENATE ps_newdat-street ' ' ps_newdat-house_num1 INTO lv_street RESPECTING BLANKS.
    TRANSLATE lv_street TO UPPER CASE.
    TRANSLATE lv_city1  TO UPPER CASE.

    UPDATE adrc SET name1      = @ps_newdat-name_org1,
                    city1      = @ps_newdat-city1,
                    street     = @ps_newdat-street,
                    house_num1 = @ps_newdat-house_num1,
                    post_code1 = @ps_newdat-post_code1,
                    sort1      = @ps_newdat-bu_sort1,
                    mc_name1   = @ps_newdat-mv_name1,
                    mc_street  = @lv_street,
                    mc_city1   = @lv_city1
                  WHERE addrnumber EQ @ps_newdat-addrnumber.
    IF 0 EQ sy-subrc.
      COMMIT WORK.
      IF sy-batch IS INITIAL.
        WRITE: /5 ps_newdat-partner,    lv_trenner,
                  ps_newdat-bu_sort1,   lv_trenner,
                  ps_newdat-name_last,  lv_trenner,
                  ps_newdat-name_first, lv_trenner,
                  ps_newdat-name_org1,  lv_trenner,
                  ps_newdat-mv_name1,   lv_trenner,
                  ps_newdat-mv_name2,   lv_trenner,
                  ps_newdat-post_code1, lv_trenner,
                  ps_newdat-city1,      lv_trenner,
                  ps_newdat-street,     lv_trenner,
                  ps_newdat-house_num1, lv_trenner,
                  ' geändert!'.
      ELSE.
        CONCATENATE ps_newdat-partner    lv_trenner
                    ps_newdat-bu_sort1   lv_trenner
                    ps_newdat-name_last  lv_trenner
                    ps_newdat-name_first lv_trenner
                    ps_newdat-name_org1  lv_trenner
                    ps_newdat-mv_name1   lv_trenner
                    ps_newdat-mv_name2   lv_trenner
                    ps_newdat-post_code1 lv_trenner
                    ps_newdat-city1      lv_trenner
                    ps_newdat-street     lv_trenner
                    ps_newdat-house_num1 lv_trenner
                    ' geändert!' INTO lv_strmsg RESPECTING BLANKS.
        MESSAGE lv_strmsg TYPE 'S'.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
      IF sy-batch IS INITIAL.
        WRITE: /5 'Adressdaten konnten nicht genädert werden!',
               /5 ps_newdat-partner,    lv_trenner,
                  ps_newdat-bu_sort1,   lv_trenner,
                  ps_newdat-name_last,  lv_trenner,
                  ps_newdat-name_first, lv_trenner,
                  ps_newdat-name_org1,  lv_trenner,
                  ps_newdat-mv_name1,   lv_trenner,
                  ps_newdat-mv_name2,   lv_trenner,
                  ps_newdat-post_code1, lv_trenner,
                  ps_newdat-city1,      lv_trenner,
                  ps_newdat-street,     lv_trenner,
                  ps_newdat-house_num1, lv_trenner,
                  ' FEHLER!'.
      ELSE.
        MESSAGE 'Adressdaten konnten nicht genädert werden!' TYPE 'S'.
        CONCATENATE ps_newdat-partner    lv_trenner
                    ps_newdat-bu_sort1   lv_trenner
                    ps_newdat-name_last  lv_trenner
                    ps_newdat-name_first lv_trenner
                    ps_newdat-name_org1  lv_trenner
                    ps_newdat-mv_name1   lv_trenner
                    ps_newdat-mv_name2   lv_trenner
                    ps_newdat-post_code1 lv_trenner
                    ps_newdat-city1      lv_trenner
                    ps_newdat-street     lv_trenner
                    ps_newdat-house_num1 lv_trenner
                    ' FEHLER!' INTO lv_strmsg RESPECTING BLANKS.
        MESSAGE lv_strmsg TYPE 'S'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
