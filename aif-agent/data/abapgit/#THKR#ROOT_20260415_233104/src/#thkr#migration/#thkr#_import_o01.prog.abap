*----------------------------------------------------------------------*
***INCLUDE /THKR/_IMPORT_O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module Update_Screen OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE Update_Screen OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'refr'.
      IF p_objekt = 'IOS' OR p_objekt = 'VSA'.
        screen-active = 0.
        screen-input = 0.
      ELSE.
        screen-active = 1.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.
