*&---------------------------------------------------------------------*
*& Include          /THKR/WF_HANDLE_WFEVENTS_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  " Abarbeitung der Funktionen
  okcode = sy-ucomm.
  CASE okcode.

    WHEN '&SAV'.

      " Ermitteln der geänderten Kopplungen
      PERFORM ermittle_aenderungen.

      " Holen der Kopplungen aus der Datenbank und Update
      PERFORM handle_events.

    WHEN OTHERS.
      " do nothing

  ENDCASE.

  CLEAR okcode.

  LEAVE TO SCREEN 0.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LEAVE_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE leave_100 INPUT.

  " Abarbeitung der Funktionen
  CASE okcode.

    WHEN 'BACK'.
      LEAVE TO SCREEN 0.

    WHEN 'CANC' OR 'EXIT'.
*     Verlassen des Programms
      LEAVE PROGRAM.

    WHEN OTHERS.
      " do nothing

  ENDCASE.

  CLEAR okcode.

ENDMODULE.
