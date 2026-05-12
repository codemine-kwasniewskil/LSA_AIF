*----------------------------------------------------------------------*
***INCLUDE /THKR/LBP_EXT_FIELDSF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form screen_detail_fmod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_detail_fmod .


DATA lv_message type sy-subrc.
  clear gv_posnr.
  CALL FUNCTION 'BUS_MESSAGE_STATUS_GET'
   IMPORTING
     MAX_MSG              = lv_message
            .

  clear lv_message.
  if lv_message lt 8.
    CALL FUNCTION 'BUS_SCREEN_GET'
     IMPORTING
*       E_VARTP       =
*       E_VARNR       =
*       E_XSEQU       =
*       E_DYNID       =
*       E_XSCIN       =
*       E_XSCDT       =
*       E_XSCFS       =
*       E_XSCPP       =
       E_POSNR       = gv_posnr
*       E_TRDYN       =
*       E_CALLS       =
*       E_SITYP       =
*     TABLES
*       T_SICHT       =
              .
    loop at screen.
      Endloop.
Endif.
ENDFORM.
