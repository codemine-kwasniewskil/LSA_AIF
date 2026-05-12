*&---------------------------------------------------------------------*
*& Report /THKR/ORDER_UPDATER_CENTRALMAP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/order_updater_centralmap.

DATA mbnr TYPE kblk-belnr.
DATA aonr TYPE psosegs-lotkz.


SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN : BEGIN OF LINE.
    PARAMETERS: p_mb  RADIOBUTTON GROUP rbg DEFAULT 'X' USER-COMMAND flag.
    SELECTION-SCREEN COMMENT 03(15) TEXT-s11.
    SELECTION-SCREEN POSITION 18.
    PARAMETERS: p_dao  RADIOBUTTON GROUP rbg.
    SELECTION-SCREEN COMMENT 20(15) TEXT-s12.
*    SELECTION-SCREEN POSITION 30.
*    PARAMETERS: p_ce  RADIOBUTTON GROUP rbg.
*    SELECTION-SCREEN COMMENT 32(12) TEXT-s13.
  SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK part1.

SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS s_mb FOR mbnr MODIF ID mb.
  SELECT-OPTIONS s_ao FOR aonr MODIF ID ao.
  PARAMETERS: p_bukr TYPE psosegs-bukrs OBLIGATORY DEFAULT 'R090' MODIF ID ao.
  PARAMETERS: p_aogj TYPE psosegs-gjahr OBLIGATORY DEFAULT '2025' MODIF ID ao.
SELECTION-SCREEN END OF BLOCK part2.

SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_test  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK part3.
SELECTION-SCREEN BEGIN OF BLOCK part4 WITH FRAME TITLE TEXT-004.
  SELECTION-SCREEN COMMENT /1(75) comm1.
  SELECTION-SCREEN COMMENT /1(75) comm2.

SELECTION-SCREEN END OF BLOCK part4.

AT SELECTION-SCREEN OUTPUT.
  comm1 = 'Dieser Report aktualsiert Werte am Beleg'.
  comm2 = 'Hinweis: Änderung direkt auf der Datenbanktabelle!'.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'MB'.
        IF p_mb  = 'X'.
          screen-active = '1'.
        ELSE .
          screen-active = '0'.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'AO'.
        IF p_dao  = 'X'.
          screen-active = '1'.
        ELSE .
          screen-active = '0'.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

START-OF-SELECTION.

data(processor) = new /thkr/cl_mig_order_upgrade( ).

processor->process_mb( mbs = s_mb[] ).
