*&---------------------------------------------------------------------*
*& Report /THKR/MIGR_UPD_FIPOS_LOW2UPPER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/migr_upd_fipos_low2upper.

SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN : BEGIN OF LINE.
    PARAMETERS: p_cor  RADIOBUTTON GROUP rbg DEFAULT 'X' USER-COMMAND flag.
    SELECTION-SCREEN COMMENT 03(10) TEXT-s11.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: p_del  RADIOBUTTON GROUP rbg.
    SELECTION-SCREEN COMMENT 17(12) TEXT-s12.
  SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK part2.

SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_test  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK part3.

SELECTION-SCREEN BEGIN OF BLOCK part4 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN COMMENT /1(79) comm1.
  SELECTION-SCREEN COMMENT /1(75) comm5.
  SELECTION-SCREEN COMMENT /1(75) comm2.
  SELECTION-SCREEN COMMENT /1(75) comm3.
  SELECTION-SCREEN COMMENT /1(75) comm4.
SELECTION-SCREEN END OF BLOCK part4.

AT SELECTION-SCREEN OUTPUT.
  comm1 = 'Dieser Report korrigiert die Fipos Tabellen FMCI und FMHICI aufgrund von '.
  comm5 = 'Dateninkonstistenzen durch Kleinbuchstaben'.
  comm2 = '1. Fipos mit Kleinbuchstaben werden ermittelt'.
  comm3 = '2. Fipos NEU mit Großbuchstaben angelegt'.
  comm4 = '3. Fipos mit Kleinbuchstaben werden gelöscht'.

START-OF-SELECTION.

  DATA(processor) = NEW /thkr/cl_migr_upd_fipos_l2u( testmode = p_test correction = p_cor ).
  TRY.
      processor->display_data( ).
    CATCH cx_salv_error INTO DATA(err).
      MESSAGE err->get_text( ) TYPE 'E'.
  ENDTRY.
*
