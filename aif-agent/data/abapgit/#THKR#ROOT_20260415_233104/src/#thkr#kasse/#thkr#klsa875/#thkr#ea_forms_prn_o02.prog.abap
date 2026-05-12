*----------------------------------------------------------------------*
***INCLUDE /THKR/EA_FORMS_PRN_002.
*----------------------------------------------------------------------*
*& Module STATUS_0495 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0495 OUTPUT.
  SET PF-STATUS '0495'.

  PERFORM screen_0495.

ENDMODULE.
*& Module STATUS_0520 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0520 OUTPUT.
  SET PF-STATUS '0520'.

  PERFORM screen_0520.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0508 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0508 OUTPUT.
  SET PF-STATUS '0508'.

  PERFORM screen_0508.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SCREEN_0495
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0495 .

  LOOP AT SCREEN.
*    CASE gs_zfi_ea_fo-formtype.
*      WHEN '1' OR '2'.
        CASE screen-name.
          WHEN 'GS_FP_DATA-VZTEXT'.
            screen-active = 0.
            screen-output = 0.
        ENDCASE.
*    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

  SET TITLEBAR '0495'.

*  CASE gs_zfi_ea_fo-formtype.
*    WHEN '1'.
*      SET TITLEBAR '0495_1'.
*    WHEN '2'.
*      SET TITLEBAR '0495_2'.
*    WHEN '3'.
*      SET TITLEBAR '0495_3'.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_0520
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0520 .

  LOOP AT SCREEN.
*    CASE gs_zfi_ea_fo-formtype.
*      WHEN '10'.
*        CASE screen-name.
*          WHEN 'GS_FP_DATA-VZTEXT'.
*            screen-active = 0.
*            screen-output = 0.
*        ENDCASE.
*      WHEN '11'.
*        CASE screen-name.
*          WHEN 'GS_FP_DATA-FTEXT_Z1'.
*            screen-active = 0.
*            screen-output = 0.
*          WHEN 'GS_FP_DATA-FTEXT_Z2'.
*            screen-active = 0.
*            screen-output = 0.
*          WHEN 'GS_FP_DATA-FTEXT_Z3'.
*            screen-active = 0.
*            screen-output = 0.
*        ENDCASE.
*    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

  CASE gs_zfi_ea_fo-formtype.
    WHEN '1'.
      SET TITLEBAR '0520'.
*    WHEN '10'.
*      SET TITLEBAR '0520_1'.
*    WHEN '11'.
*      SET TITLEBAR '0520_2'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_0508
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0508 .

  SET TITLEBAR '0494'.

*  LOOP AT SCREEN.
*    IF gs_zfi_ea_fo-formtype EQ '4'.
** Keine Eskalationsstufe und Frist
*      CASE screen-name.
*        WHEN 'GV_STATUS_ALT' OR 'GV_FRIST' OR 'GS_FP_DATA-FERTIG'
*             OR 'GS_FP_DATA-ADDR_Z1'.
*          screen-active = 0.
*          screen-output = 0.
*      ENDCASE.
*    ELSE.
*      CASE screen-name.
*        WHEN 'GS_FP_DATA-FTEXT_Z1'.
*          screen-active = 0.
*          screen-output = 0.
*      ENDCASE.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

*  CASE gs_zfi_ea_fo-formtype.
*    WHEN '1'.
*      SET TITLEBAR '0508_1'.
*    WHEN '5'.
*      SET TITLEBAR '0508_2'.

*ENDCASE.


ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0510 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0510 OUTPUT.
  SET PF-STATUS '0510'.

  PERFORM screen_0510.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0528 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0528 OUTPUT.
  SET PF-STATUS '0528'.

  PERFORM screen_0528.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Form SCREEN_0510
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0510 .


  SET TITLEBAR '0492'.

*  LOOP AT SCREEN.
*    IF gs_zfi_ea_fo-formtype EQ '8' OR gs_zfi_ea_fo-formtype EQ '9'.
** Kassenzeichen der Annahmeanordnung nur für Ausgabeart 1 und 2
*      IF screen-name EQ 'GV_AO_KASSZE'.
*        screen-active = 0.
*        screen-output = 0.
*      ENDIF.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SCREEN_0528
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0528 .
  IF GV_bankvermerk EQ '7'.
    LOOP AT SCREEN.
      IF screen-name = 'GS_FP_DATA-BANKVERMERK'.
        screen-output = 1.
        screen-active = 1.
      ENDIF.
* Übernahme der Einstellungen
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name = 'GS_FP_DATA-BANKVERMERK'.
        screen-output = 0.
        screen-active = 0.
      ENDIF.
* Übernahme der Einstellungen
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  SET TITLEBAR '0528_1'.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form PREPARE_DYNP_DATA_0495
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_dynp_data_0495 .

  DATA: ls_bnka    TYPE bnka,
        lv_landx50 TYPE landx50.

  DATA: lt_string  TYPE STANDARD TABLE OF swastrtab,
        ls_string  TYPE swastrtab,
        lv_string  TYPE string,
        lv_string2 TYPE string,
        lv_string3 TYPE string,
        lv_string4 TYPE string.


* Bankleitzahl und Land aus IBAN entnehmen
  gv_bankl = gs_worklist_fe-piban+4(8).
  gv_banks = gs_worklist_fe-piban(2).

* Bankzuordnung bei Bankanfrage Vorbelegung
  SELECT SINGLE * FROM bnka INTO ls_bnka
     WHERE banks EQ gv_banks
       AND bankl EQ gv_bankl.
    IF sy-subrc EQ 0.
      CLEAR: gs_fp_data-bank_addr_z1, gs_fp_data-bank_addr_z2, gs_fp_data-bank_addr_z3,
             gs_fp_data-bank_addr_z4, gs_fp_data-bank_addr_z5.

      gs_fp_data-bank_addr_z1 = ls_bnka-banka.
* Strasse
      gs_fp_data-bank_addr_z2 = ls_bnka-stras.
* Ort Postleitzahl ggf. nach Ortsnamen im System
      SPLIT ls_bnka-ort01 AT ' ' INTO lv_string lv_string2.
      IF lv_string2 CO '0123456789'.
        CONCATENATE lv_string2 lv_string INTO gs_fp_data-bank_addr_z3
          SEPARATED BY space.
      ELSEIF NOT lv_string2 IS INITIAL.
        SPLIT lv_string2 AT ' ' INTO lv_string2 lv_string3.
        IF lv_string3 CO '0123456789'.
          CONCATENATE lv_string3 lv_string lv_string2 INTO gs_fp_data-bank_addr_z3
            SEPARATED BY space.
        ELSEIF NOT lv_string3 IS INITIAL.
          SPLIT lv_string3 AT ' ' INTO lv_string3 lv_string4.
          IF lv_string4 CO '0123456789'.
            CONCATENATE lv_string4 lv_string lv_string2 lv_string3 INTO gs_fp_data-bank_addr_z3
              SEPARATED BY space.
          ELSE.
            gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
          ENDIF.
        ELSE.
          gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
        ENDIF.
      ELSE.
        gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
      ENDIF.

      SHIFT gs_fp_data-bank_addr_z3 LEFT DELETING LEADING ' '.

* Land
      IF ls_bnka-banks NE 'DE'.
        SELECT SINGLE landx FROM t005t INTO lv_landx50
                    WHERE land1 EQ ls_bnka-banks
                      AND spras EQ 'D'.
          IF sy-subrc EQ 0.
            gs_fp_data-bank_addr_z4 = lv_landx50.
          ENDIF.
        ENDIF.
      ENDIF.
      IF gv_banks IS INITIAL.
        gv_banks = 'DE'.
      ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form PREPARE_DYNP_DATA_0520
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_dynp_data_0520 .

  DATA: lv_counter TYPE i.

  IF NOT gs_worklist_fe-avkon IS INITIAL.
    gv_kunnr = gs_worklist_fe-avkon.
* ggf Kundennummer mit 0 auffüllen
    lv_counter = 10 - strlen( gv_kunnr ).

    DO lv_counter TIMES.
      CONCATENATE '0' gv_kunnr INTO gv_kunnr.
    ENDDO.
* Name ermitteln
    SELECT SINGLE name1 FROM kna1 INTO gv_name1
       WHERE kunnr EQ gv_kunnr.
    ELSE.
      CLEAR: gv_kunnr, gv_name1.
    ENDIF.

ENDFORM.
