*----------------------------------------------------------------------*
***INCLUDE LZKLSA966_FGO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9010 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9010 OUTPUT.
  SET PF-STATUS 'STATUS_9010'.
  SET TITLEBAR 'TITLE_9010'.

  IF gv_zins_input_flag = abap_false.
    LOOP AT SCREEN.
      IF screen-name = '/THKR/S_KLSA966_INCL-Z_INTRATE'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.
