*----------------------------------------------------------------------*
***INCLUDE LZ_FI_BN_BELEGO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_9110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo_9110 OUTPUT.

  DATA: ls_screen        TYPE screen.
  DATA  lt_fcode TYPE TABLE OF sy-ucomm.
  CLEAR lt_fcode[].

*&---------------------------------------------------------------------*
* Zahlungsanzeigen nur Drucken
*&---------------------------------------------------------------------*
  IF zfi_f_dto_nachr-herk = c_char_y.
    APPEND 'SENDEN'  TO lt_fcode.
  ELSE.
    APPEND 'PRINT'  TO lt_fcode.
  ENDIF.

*&---------------------------------------------------------------------*
* inaktive Zahlungsanzeigen nicht  Drucken
*&---------------------------------------------------------------------*
  IF zfi_f_dto_nachr-inaktiv = c_on.
    APPEND 'PRINT'  TO lt_fcode.
  ENDIF.


  SET PF-STATUS 'STATUS_9110' EXCLUDING lt_fcode.
* SET TITLEBAR 'xxx'.


*&---------------------------------------------------------------------*
* Zahlungsanzeigen nur Drucken--> Felder setzen/ausblenden
*&---------------------------------------------------------------------*
  IF zfi_f_dto_nachr-herk = c_char_y.
    zfi_f_dto_nachr-kzbnart = c_char_p.
*&---------------------------------------------------------------------*
* Feld Benachrichtungsart fest setzen
*&---------------------------------------------------------------------*
    LOOP AT SCREEN INTO ls_screen .
      IF ls_screen-group1 = c_za.
        ls_screen-input = 0.
        MODIFY SCREEN FROM ls_screen.
*&---------------------------------------------------------------------*
* Feld Empfänger ausblenden
*&---------------------------------------------------------------------*
      ELSEIF ls_screen-group1 = 'ZA1'.
        ls_screen-input = 0.
        ls_screen-output = 0.
        ls_screen-invisible = 1.
        MODIFY SCREEN FROM ls_screen.
      ENDIF.
    ENDLOOP.


    IF gs_out-dest IS INITIAL.
      zfi_bn_druck-dest = 'PDF1'.
      zfi_bn_druck-preview = c_on.
      zfi_bn_druck-nodialog = c_on.
    ELSE.
      zfi_bn_druck-dest = gs_out-dest.
      zfi_bn_druck-preview = gs_out-preview .
      zfi_bn_druck-nodialog = c_on.
    ENDIF.

  ELSE.
*&---------------------------------------------------------------------*
* Für normale Meldungen -Drucker ausblenden
*&---------------------------------------------------------------------*
    LOOP AT SCREEN INTO ls_screen .
      IF ls_screen-group1 = 'ZA2'.
        ls_screen-input = 0.
        ls_screen-output = 0.
        ls_screen-invisible = 1.
        MODIFY SCREEN FROM ls_screen.
      ENDIF.
      CASE zfi_f_dto_nachr-kzbnart.
        WHEN 'D' OR 'P'.
* Feld Empfänger ausblenden
          IF ls_screen-group1 = 'ZA1'.
            ls_screen-input = 0.
            ls_screen-output = 0.
            ls_screen-invisible = 1.
            MODIFY SCREEN FROM ls_screen.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_AUTH_CHECK_9110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo_auth_check_9110 OUTPUT.

  DATA: lv_auth_activ TYPE fm_authact VALUE '03',
        lv_fikrs      TYPE fikrs      VALUE '1000'.

* Berechtigung
  DATA: lv_fm_fmfctr_authgrp TYPE fm_authgrc,    "Finanzstelle
        lv_subrc             TYPE n.             "Subrc

* Berechtigungsprüfung
  lv_fm_fmfctr_authgrp = zfi_f_dto_nachr-fistl.    "Finanzstelle

  IF 1 = 2.
    AUTHORITY-CHECK OBJECT 'Z_FICA_TRG'
      ID 'FM_AUTHACT' FIELD lv_auth_activ
      ID 'FM_FIKRS'   FIELD lv_fikrs
      ID 'FM_AUTHGRF' DUMMY
      ID 'FM_AUTHGRC' FIELD lv_fm_fmfctr_authgrp
      ID 'FM_AUTHGRP' DUMMY
      ID 'FM_AUTHGRM' DUMMY
      ID 'FM_GRP_FAR' DUMMY.
  ENDIF.

  CALL FUNCTION 'Z_CHECK_FICA_TRG'
    EXPORTING
      activity          = lv_auth_activ     "aktuell auf 03
      fm_area           = lv_fikrs          "1000
      fm_fmfctr_authgrp = lv_fm_fmfctr_authgrp
*     fm_fipex_authgrp  = lv_fm_fipex_authgrp
*     FM_MEASURE_AUTHGRP       = LS_AUTH_GRP_HHP
*     FM_FAREA_AUTHGRP  =
    IMPORTING
      ex_subrc          = lv_subrc.
  IF lv_subrc <> 0.
    MESSAGE s028(z_fi_nachr) with zfi_f_dto_nachr-belnr.
    CLEAR gs_out.
    LEAVE TO SCREEN 0.
  ELSE.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'ACTVT' FIELD lv_auth_activ
        ID 'BUKRS' FIELD zfi_f_dto_nachr-bukrs.
    IF sy-subrc NE 0.
      MESSAGE s028(z_fi_nachr) with zfi_f_dto_nachr-belnr.
      CLEAR gs_out.
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDIF.
ENDMODULE.
