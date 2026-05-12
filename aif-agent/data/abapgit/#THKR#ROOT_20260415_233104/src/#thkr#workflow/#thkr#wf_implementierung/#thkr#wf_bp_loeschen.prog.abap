*&---------------------------------------------------------------------*
*& Report /THKR/WF_BP_LOESCHEN
*&---------------------------------------------------------------------*
************************************************************************
*  Im Wf zu Business Partner werden bei der Ablehnung eines neu        *
*  angelegten Business Partner die Löschkennzeichen gesetzt  .         *
*  Innerhalb des WF kann nicht gelöscht werden, da sonst die Instanz   *
*  verloren geht.                                                      *
*  Deswegen werden nur die Flags gesetzt, gelöscht aber zu einem       *
*  späteren Zeitpunkt                                                  *
*  E.Dosch 08.07.2024                                                  *
*  F.Braehler 18.02.2025 - Prüfungen und Return-Status                 *
*  A.Baier 04.04.2025 - Prüfen, ob BP durch WF zum Löschen vorgesehen  *
************************************************************************
*&
*&---------------------------------------------------------------------*
REPORT /thkr/wf_bp_loeschen MESSAGE-ID /thkr/wf.

************************************************************************
* Definitionen von Tables, sonst funktioniert SELEKTOPTIONS nicht      *
************************************************************************
TABLES: but000.

************************************************************************
* Globale Tabellentypen                                                *
************************************************************************
DATA: gt_bapiret2 TYPE bapiret2_t,
      gt_partner  TYPE TABLE OF bu_partner,
      gt_worklist TYPE STANDARD TABLE OF swr_wihdr,
      gt_worktmp  TYPE STANDARD TABLE OF swr_wihdr.


************************************************************************
* Globale Strukturen für das Programm                                  *
************************************************************************
DATA: gs_objkey   TYPE swo_typeid.

************************************************************************
* Globale Variablen für das Programm                                   *
************************************************************************
DATA: gv_objtype  TYPE swo_objtyp.

************************************************************************
* Globale Feld-Symbole                                                 *
************************************************************************
FIELD-SYMBOLS: <fs_partner>  TYPE bu_partner,
               <fs_bapiret2> TYPE bapiret2.

************************************************************************
* Ranges                                                               *
************************************************************************
DATA: gr_wf_bp_del  TYPE RANGE OF bu_partner,
      gr_bp_deleted TYPE RANGE OF bu_partner.
************************************************************************
* Start Selektionsbild                                                 *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK bp001 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS so_partn FOR but000-partner NO INTERVALS.
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN BEGIN OF BLOCK bp002 WITH FRAME TITLE TEXT-002.
    SELECTION-SCREEN SKIP.
    SELECTION-SCREEN BEGIN OF LINE.
      SELECTION-SCREEN COMMENT (28) lc_test FOR FIELD p_test.
      PARAMETERS p_test  TYPE xflag AS CHECKBOX.
    SELECTION-SCREEN END OF LINE.
    SELECTION-SCREEN SKIP.
  SELECTION-SCREEN END OF BLOCK bp002.
SELECTION-SCREEN END OF BLOCK bp001.

************************************************************************
* Initialiserungen für das Programm incl. Berechtigungsprüfung         *
************************************************************************
INITIALIZATION.
  lc_test = TEXT-003.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
  ID 'TCD' FIELD '/THKR/WF_BP_LOESCHEN'.
  IF sy-subrc <> 0.
    MESSAGE 'Keine Berechtigung für Transaktion /THKR/WF_BP_LOESCHEN.' TYPE 'E' DISPLAY LIKE 'S'.
  ENDIF.
************************************************************************
* Berechtigungsprüfung auf S_WF_ADM - Löschberechtigung (6)            *
************************************************************************
  AUTHORITY-CHECK OBJECT 'S_WF_ADM'
  ID 'ACTVT' FIELD '06'.
  IF sy-subrc <> 0.
    MESSAGE TEXT-e01 TYPE 'E' DISPLAY LIKE 'S'.
  ENDIF.

************************************************************************
* Start Selektionsbild                                                 *
* Initialisierung der BP'S mit Archiv- bzw. Löschvormerkung            *
* Auslesen der Betroffenen Bu_partner                                  *
************************************************************************
START-OF-SELECTION.
  SELECT 'I' AS sign, 'EQ' AS option, partner AS low
      FROM /thkr/wf_bp_del INTO TABLE @gr_wf_bp_del.
  IF sy-subrc = 0.

    SELECT partner FROM but000 INTO TABLE  gt_partner
                   WHERE partner IN so_partn
                   AND partner IN gr_wf_bp_del
                   AND   xdele   EQ  'X'.
    IF NOT gt_partner[] IS INITIAL.
      IF p_test = 'X'.
        IF sy-batch IS INITIAL.
          WRITE TEXT-h01. " ' T E S T M O D U S'.
        ELSE.
          MESSAGE s202 WITH TEXT-h01.
        ENDIF.
      ELSE.
        IF sy-batch IS INITIAL.
          WRITE TEXT-h02. " 'E C H T L A U F '.
        ELSE.
          MESSAGE s202 WITH TEXT-h02.
        ENDIF.
      ENDIF.

      LOOP AT gt_partner ASSIGNING <fs_partner>.
        CLEAR gt_bapiret2[].

*     Objekt-Key setzen BP-ID
        MOVE <fs_partner> TO gs_objkey.
************************************************************************
*     1. Step - Prüfen, ob noch ggf. offene Workflowas aktiv sind,     *
*        Dann keine Verarbeitung und entsprechende Meldung bzw.        *
*        Return eines entsprechenden Status-Text                       *
************************************************************************
*     1a. Objekttyp BUS1006         1.ter Durchlauf                    *
************************************************************************
        MOVE 'BUS1006' TO gv_objtype.
        CALL FUNCTION 'SAP_WAPI_WORKITEMS_TO_OBJECT'
          EXPORTING
            objtype                  = gv_objtype
            objkey                   = gs_objkey
            top_level_items          = 'X'
            selection_status_variant = 0003
          TABLES
            worklist                 = gt_worktmp.

        gt_worklist[] = gt_worktmp[].

************************************************************************
*    1b. Objekttyp /THKR/1006      2.ter Durchlauf                     *
************************************************************************
        MOVE '/THKR/1006' TO gv_objtype.
        CALL FUNCTION 'SAP_WAPI_WORKITEMS_TO_OBJECT'
          EXPORTING
            objtype                  = gv_objtype
            objkey                   = gs_objkey
            top_level_items          = 'X'
            selection_status_variant = 0003
          TABLES
            worklist                 = gt_worktmp.

        APPEND LINES OF gt_worktmp TO gt_worklist.

************************************************************************
*     Nur wenn die Worklist leer ist, darf eine Löschung vorgenommen   *
*     werden.                                                          *
************************************************************************
        IF gt_worklist[] IS INITIAL.
************************************************************************
*       2. Step - Fuba BUP_BUPA_DELETE - Löschen von Geschäftspartnern *
*          verwendeun und prüfen, wo Fehler passieren mit Test-KZ      *
************************************************************************
          CALL FUNCTION 'BUP_BUPA_DELETE'
            EXPORTING
              iv_partner           = <fs_partner>
              iv_testrun           = p_test
              iv_xdele             = 'X'
              iv_with_log          = 'X'
            TABLES
              et_results           = gt_bapiret2
            EXCEPTIONS
              deletion_not_allowed = 1
              fatal_error          = 2
              OTHERS               = 3.

          IF sy-subrc NE 0.
            READ TABLE gt_bapiret2 ASSIGNING  <fs_bapiret2> INDEX 1.
            IF sy-subrc EQ 0.
              IF sy-batch IS INITIAL.
                WRITE:/ <fs_partner>, <fs_bapiret2>-message.
              ELSE.
                MESSAGE s200 WITH <fs_partner> <fs_bapiret2>-message.
              ENDIF.
            ELSE.
              IF sy-batch IS INITIAL.
                WRITE:/ <fs_partner>, TEXT-004.   "Fehlerhaft!
              ELSE.
                MESSAGE s201 WITH <fs_partner> TEXT-004.  "Fehlerhaft!
              ENDIF.
            ENDIF.
          ELSE .
            IF sy-batch IS INITIAL.
              WRITE:/ <fs_partner>, TEXT-005.    "Erfolgreich gelöscht!
            ELSE.
              MESSAGE s201 WITH <fs_partner> TEXT-005.  "Erfolgreich gelöscht!
            ENDIF.

            APPEND INITIAL LINE TO gr_bp_deleted ASSIGNING FIELD-SYMBOL(<fs_bp_deleted>).
            IF sy-subrc = 0.
              <fs_bp_deleted>-sign = 'I'.
              <fs_bp_deleted>-option = 'EQ'.
              <fs_bp_deleted>-low = <fs_partner>.
            ENDIF.

          ENDIF.
        ELSE.
          IF sy-batch IS INITIAL.
            WRITE:/ <fs_partner>, TEXT-006.    "ist Fehlerhaft! - WorkItems vorhanden!
          ELSE.
            MESSAGE s201 WITH <fs_partner> TEXT-006.    "ist Fehlerhaft! - WorkItems vorhanden!
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF p_test IS INITIAL.
        IF gr_bp_deleted IS NOT INITIAL.
          DELETE FROM /thkr/wf_bp_del WHERE partner IN gr_bp_deleted.
        ENDIF.
      ENDIF.
    ELSE.
      IF sy-batch IS INITIAL.
        MESSAGE i108.    "Es wurden keine Einträge selektiert, keine Änderung der Daten
      ELSE.
        MESSAGE s108.    "Es wurden keine Einträge selektiert, keine Änderung der Daten
      ENDIF.
    ENDIF.

  ENDIF.
