*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_STORNO_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module SET_PF_STATUS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_pf_status OUTPUT.
  SET PF-STATUS 'STORNO'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TITLE_STORNO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_title_storno OUTPUT.
  SET TITLEBAR 'STORNO'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module AUTHORITY_CHECK OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE authority_check OUTPUT.

  " Vorbelegung Transaktion            "001
  if sy-tcode = gc_tcode.
    data(lv_tcode) = gc_tcode.
  else.
    lv_tcode = gc_tcode_k.
  endif.

  " Berechtigung Transaktion
  AUTHORITY-CHECK OBJECT 'S_TCODE'
       ID 'TCD' FIELD lv_tcode.
  IF sy-subrc NE 0.
    MESSAGE e133(/THKR/FI_WF_BKPF).
* Keine Berechtigung zur Bearbeitung vorhanden.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TITLE_MM OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_title_mm OUTPUT.
  SET TITLEBAR 'MM'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_PF_STATUS_MM OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_pf_status_bearb OUTPUT.
  SET PF-STATUS 'BEARB'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TITLE_FI OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_title_fi OUTPUT.
  SET TITLEBAR 'FI'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TITLE_SD OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_title_sd OUTPUT.
  SET TITLEBAR 'SD'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_OK OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_ok OUTPUT.
  CLEAR ok-code.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init OUTPUT.
  PERFORM init.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0305 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_0305 OUTPUT.
  SET PF-STATUS 'REFX_ANZ'.
  SET TITLEBAR 'REFX'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_0905 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_0905 OUTPUT.
  SET PF-STATUS 'REFX'.
  SET TITLEBAR 'REFX'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&SPWIZARD: OUTPUT MODULE FOR TC 'REFERENZEN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE referenzen_change_tc_attr OUTPUT.
*
*  DESCRIBE TABLE gt_referenz LINES referenzen-lines.
*  IF referenzen-lines <> 0.
*    " Damit die restlichen Eingabezeilen eingabebereit sind
*    ADD 20 TO referenzen-lines.
*  ENDIF.

ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'REFERENZEN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE referenzen_get_lines OUTPUT.
*  g_referenzen_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_BUTTON_0305 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_button_0305 OUTPUT.

*  " Ermittlung Anzahl Refnr
*  DESCRIBE TABLE gt_referenz LINES DATA(lv_line).
*
*  " Steuereung Button Referenz erfolgreich eingeben
*  LOOP AT SCREEN INTO DATA(ls_screen).
*    CASE ls_screen-name.
*      WHEN 'REFOK'.
*        IF lv_line > 0.
*          ls_screen-invisible = '0'.
*        ELSE.
*          ls_screen-invisible = '1'.
*        ENDIF.
*      WHEN 'MORE'.
*        IF lv_line > 0.
*          ls_screen-invisible = '1'.
*        ELSE.
*          ls_screen-invisible = '0'.
*        ENDIF.
*    ENDCASE.
*    MODIFY SCREEN FROM ls_screen.
*  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& MODULE vorbelegen_datum OUTPUT
*&---------------------------------------------------------------------*
*&  Datumsfeld bei Storna Faktura soll vorbelegt werden
*&---------------------------------------------------------------------*
MODULE vorbelegen_datum OUTPUT.

  gs_storno-fkdat = sy-datum.

ENDMODULE.
