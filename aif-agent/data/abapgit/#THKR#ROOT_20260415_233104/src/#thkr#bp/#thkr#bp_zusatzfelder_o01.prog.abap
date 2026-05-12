*----------------------------------------------------------------------*
***INCLUDE /THKR/BP_ZUSATZFELDER_O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  CALL FUNCTION 'BUS_PBO'
*   EXPORTING
*     IV_TC1_PROGRAM       =
*     IV_TC1_CONTROL       =
*     IV_TC2_PROGRAM       =
*     IV_TC2_CONTROL       =
*   CHANGING
*     C_TC1                =
*     C_TC2                =
            .


ENDMODULE.
