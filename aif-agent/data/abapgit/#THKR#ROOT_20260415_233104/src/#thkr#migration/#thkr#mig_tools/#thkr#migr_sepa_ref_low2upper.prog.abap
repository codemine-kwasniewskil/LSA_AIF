*&---------------------------------------------------------------------*
*& Report /THKR/MIGR_SEPA_REF_LOW2UPPER                                *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Beschreibung:                                                       *
*&                                                                     *
*& Update - Routine auf die Tabelle SEPA_MANDATe auf das Feld          *
*& Mandatsreferenz.                                                    *
*&                                                                     *
*& 1. Es sind Mandatsreferenz bei der Migration mit Kleinbuchstaben    *
*&    vorhanden. Diese Referenzen müssen umgestellt werden auf NUR     *
*&    Grossbuchstaben, damit Suchfunktionen auf ein Mandat             *
*&    funktionieren.                                                   *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:       Frank Brähler (Orexes GmbH)                            *
*& Anlage:      25.11.2025                                             *
*& Transaktion:                                                        *
*&                                                                     *
*& Änderer:     Frank Brähler                                          *
*& l.Datum:     25.11.2025                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/migr_sepa_ref_low2upper.

DATA: gv_mndid  TYPE sepa_mndid,
      gv_anz    TYPE i,
      gv_anz_n  TYPE numc08,
      gv_zeiger TYPE numc08,
      gv_strmsg TYPE string,
      gv_perc   TYPE p DECIMALS 2.

DATA: gt_mandat TYPE TABLE OF sepa_mandate.

FIELD-SYMBOLS: <gs_mandat> TYPE sepa_mandate.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_test  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK part1.

SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN COMMENT /1(79) comm1.
  SELECTION-SCREEN COMMENT /1(75) comm5.
  SELECTION-SCREEN COMMENT /1(75) comm2.
  SELECTION-SCREEN COMMENT /1(75) comm3.
  SELECTION-SCREEN COMMENT /1(75) comm4.
SELECTION-SCREEN END OF BLOCK part2.

AT SELECTION-SCREEN OUTPUT.
  comm1 = 'Dieser Report korrigiert die SEPA-Mandat Tabellen SEPA_MANDAT aufgrund von '.
  comm5 = 'Dateninkonstistenzen durch Kleinbuchstaben'.
  comm2 = 'SEPA_MANDATE mit Kleinbuchstaben werden ermittelt'.
  comm3 = 'Update auf das Feld MANDATASREFERNZ der Tabelle SEPA_MANDAT'.
  comm4 = 'Kleinbuchstaben werden in Großbuchstaben gewandelt!'.

START-OF-SELECTION.

  SELECT * FROM sepa_mandate INTO TABLE gt_mandat.

  LOOP AT gt_mandat ASSIGNING <gs_mandat>.
    <gs_mandat>-mndid = to_upper( <gs_mandat>-mndid ).
  ENDLOOP.

  DESCRIBE TABLE gt_mandat LINES gv_anz.
  MOVE gv_anz TO gv_anz_n.

  LOOP AT gt_mandat ASSIGNING <gs_mandat>.
    ADD 1 TO gv_zeiger.
    gv_perc = gv_zeiger / gv_anz.

    gv_strmsg = |{ gv_zeiger } { ' von ' } { gv_anz_n }|.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = gv_perc
        text       = gv_strmsg.

    IF p_test IS INITIAL.
      UPDATE sepa_mandate SET mndid = <gs_mandat>-mndid
                       WHERE mguid = <gs_mandat>-mguid.
    ENDIF.
  ENDLOOP.

  IF p_test IS INITIAL.
    gv_strmsg = |{ gv_anz_n } { 'geprüft mit UPDATE!' }|.
  ELSE.
    gv_strmsg = |{ gv_anz_n } { 'geprüft OHNE Update!' }|.
  ENDIF.

  MESSAGE gv_strmsg TYPE 'I'.
