*----------------------------------------------------------------------*
***INCLUDE /THKR/LFI_SEPA_MANDATE_UIO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  " get mandate data (for append subscreen)
  IF sy-dynnr EQ 206.
    IF g_aktyp EQ '01'.
      FREE: sepa_mandate-/thkr/gsber, sepa_mandate-/thkr/xblnr.
    ENDIF.
    CALL FUNCTION 'SEPA_MANDATE_DET_GET_PBO'
      IMPORTING
        e_mandate = gs_mandate
        e_aktyp   = g_aktyp.
    sepa_mandate-/thkr/gsber = gs_mandate-/thkr/gsber.
    sepa_mandate-/thkr/xblnr = gs_mandate-/thkr/xblnr.
  ENDIF.

  " get mandate data
  CASE sy-dynnr.
    WHEN 206.
      " fill data from User's parameters
      IF sepa_mandate-/thkr/gsber IS INITIAL.
        IF g_aktyp EQ '01'.
          GET PARAMETER ID 'GSB' FIELD sepa_mandate-/thkr/gsber.
        ENDIF.
      ENDIF.
  ENDCASE.

  " no input for IDs in display mode
  IF g_aktyp   EQ '03'
  AND sy-dynnr EQ 206.
    LOOP AT SCREEN.
      CHECK screen-input = 1.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DYNPRO_MODIF OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE dynpro_modif OUTPUT.
  IF sy-dynnr EQ 206.
    CALL FUNCTION 'SEPA_MANDATE_DET_GET_PBO'
      IMPORTING
        e_mandate = gs_mandate
        e_aktyp   = g_aktyp.
    sepa_mandate-/thkr/gsber = gs_mandate-/thkr/gsber.
    sepa_mandate-/thkr/xblnr = gs_mandate-/thkr/xblnr.
  ENDIF.

  CASE g_aktyp.
    WHEN  '01'.
      LOOP AT SCREEN.
        IF screen-name = 'SEPA_MANDATE-/THKR/GSBER' OR screen-name = 'SEPA_MANDATE-/THKR/XBLNR'.
          screen-input = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN '02'.
      LOOP AT SCREEN.
* 20250603 DF-1235 ->
*        IF screen-name = 'SEPA_MANDATE-/THKR/GSBER' OR screen-name = 'SEPA_MANDATE-/THKR/XBLNR'.
        IF screen-name = 'SEPA_MANDATE-/THKR/GSBER'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-name = 'SEPA_MANDATE-/THKR/XBLNR'.
          screen-input = '1'.
          MODIFY SCREEN.
        ENDIF.
* 20250603 DF-1235 <-
      ENDLOOP.
  ENDCASE.
ENDMODULE.
