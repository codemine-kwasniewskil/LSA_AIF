*&---------------------------------------------------------------------*
*& Include          /thkr/EA_FORMS_PRN_O01
*&---------------------------------------------------------------------*
*& Module STATUS_0480 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0480 OUTPUT.
  SET PF-STATUS '0480'.

  PERFORM screen_0480.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0494 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

MODULE status_0494 OUTPUT.
  SET PF-STATUS '0494'.

  PERFORM screen_0494.

ENDMODULE.
*& Module STATUS_0521 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0521 OUTPUT.
  SET PF-STATUS '0521'.

  PERFORM screen_0521.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0507 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0507 OUTPUT.
  SET PF-STATUS '0507'.

  PERFORM screen_0507.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0509 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0509 OUTPUT.
  SET PF-STATUS '0509'.

  PERFORM screen_0509.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0515 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0515 OUTPUT.
  SET PF-STATUS '0515'.

  PERFORM screen_0515.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Form SCREEN_0480
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0480 .

  SET TITLEBAR '0497'.


  CLEAR okcode.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SCREEN_0494
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0494 .

  LOOP AT SCREEN.
    CASE gs_zfi_ea_fo-formtype.
      WHEN '2'.
        CASE screen-name.
          WHEN 'GS_FP_DATA-FTEXT_Z1'.
            screen-active = 0.
            screen-output = 0.
          WHEN 'GS_FP_DATA-FTEXT_Z2'.
            screen-active = 0.
            screen-output = 0.
          WHEN 'GS_FP_DATA-FTEXT_Z3'.
            screen-active = 0.
            screen-output = 0.
          WHEN 'GS_FP_DATA-VZTEXT'.
            screen-active = 0.
            screen-output = 0.
        ENDCASE.
      WHEN '4'.
        CASE screen-name.
          WHEN 'GS_FP_DATA-FTEXT_Z1'.
            screen-active = 0.
            screen-output = 0.
          WHEN 'GS_FP_DATA-FTEXT_Z2'.
            screen-active = 0.
            screen-output = 0.
          WHEN 'GS_FP_DATA-FTEXT_Z3'.
            screen-active = 0.
            screen-output = 0.
          WHEN 'GV_ZUVIEL1' OR 'GV_ZUVIEL2' OR 'GS_FP_DATA-AO_KASZE' OR 'TITEL_KASSZE_ANNAO' OR 'GV_AO_KASSZE'
                            OR 'GS_FP_DATA-KASZE' OR 'TITEL_KASZE_ANNAO' OR 'TITLE_ZUVIELZAHLUNG'.
            screen-active = 0.
            screen-output = 0.
        ENDCASE.
      WHEN OTHERS.
        CASE screen-name.
          WHEN 'GS_FP_DATA-VZTEXT' OR 'GV_ZUVIEL1'
               OR 'GV_ZUVIEL2' OR 'GS_FP_DATA-AO_KASZE' OR 'TITEL_KASSZE_ANNAO' OR 'GV_AO_KASSZE' OR 'GS_FP_DATA-KASZE'
               OR 'TITEL_KASZE_ANNAO' OR 'TITLE_ZUVIELZAHLUNG'.
            screen-active = 0.
            screen-output = 0.
        ENDCASE.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

  CASE gs_zfi_ea_fo-formtype.
    WHEN '1'.
      SET TITLEBAR '0494_1'.
    WHEN '2'.
      SET TITLEBAR '0494_2'.
    WHEN '3'.
      SET TITLEBAR '0494_3'.
    WHEN OTHERS.
      SET TITLEBAR '0494_4'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_0521
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0521 .

 SET TITLEBAR '0496'.

*  LOOP AT SCREEN.
*    CASE gs_zfi_ea_fo-formtype.
*      WHEN '2'.
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
*          WHEN 'GS_FP_DATA-VZTEXT'.
*            screen-active = 0.
*            screen-output = 0.
*        ENDCASE.
*      WHEN '4'.
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
*          WHEN 'GV_ZUVIEL1' OR 'GV_ZUVIEL2' OR 'GS_FP_DATA-AO_KASZE' OR 'TITEL_KASZE_ANNAO'
*                            OR 'GS_FP_DATA-KASZE' OR 'GV_AO_KASSZE'.
*            screen-active = 0.
*            screen-output = 0.
*        ENDCASE.
*      WHEN OTHERS.
*        CASE screen-name.
*          WHEN 'GS_FP_DATA-VZTEXT' OR 'GV_ZUVIEL1'
*               OR 'GV_ZUVIEL2' OR 'GS_FP_DATA-AO_KASZE' OR 'TITEL_KASZE_ANNAO'
*               OR 'GS_FP_DATA-KASZE' OR 'GV_AO_KASSZE'.
*            screen-active = 0.
*            screen-output = 0.
*        ENDCASE.
*    ENDCASE.
*
*    MODIFY SCREEN.
*  ENDLOOP.

*  CASE gs_zfi_ea_fo-formtype.
*    WHEN '1'.
*      SET TITLEBAR '0521_1'.
*    WHEN '2'.
*      SET TITLEBAR '0521_2'.
*    WHEN '3'.
*      SET TITLEBAR '0521_3'.
*    WHEN OTHERS.
*      SET TITLEBAR '0521_4'.
*  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_0507
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0507 .
  LOOP AT SCREEN.
*    CASE gs_zfi_ea_fo-formtype.
*      WHEN '1'.
** Kassenzeichen der Annahmeanordnung und Aktenzeich ausblenden
*        IF screen-name EQ 'GV_AO_KASSZE' OR screen-name EQ 'GS_FP_DATA-AKTZE'
*           OR screen-name EQ 'GS_FP_DATA-KASZE'.
*          screen-active = 0.
*          screen-output = 0.
*        ENDIF.
* Kassenzeichen ausblenden
        IF screen-name EQ 'GS_FP_DATA-KASZE'.
          screen-active = 0.
          screen-output = 0.
        ENDIF.
*      WHEN '2'.
** Kassenzeichen der Annahmeanordnung ausblenden
*        IF screen-name EQ 'GV_AO_KASSZE' OR screen-name EQ 'GS_FP_DATA-KASZE'.
*          screen-active = 0.
*          screen-output = 0.
*        ENDIF.
*
*      WHEN '3'.
** Kein Freitext, Aktenzeichen und AVIS
*        CASE screen-name.
*          WHEN 'GS_FP_DATA-FTEXT_Z1' OR 'GS_FP_DATA-FTEXT_Z2' OR 'GS_FP_DATA-FTEXT_Z3'
*               OR 'GS_FP_DATA-AKTZE' OR 'AVIS' OR 'GS_FP_DATA-KASZE'.
*            screen-active = 0.
*            screen-output = 0.
*        ENDCASE.
*      WHEN '4'.
** Kein Freitext, Aktenzeichen und AVIS, Status, Leiter/Amtsvorstand
*        CASE screen-name.
*          WHEN 'GS_FP_DATA-ADDR_Z1' OR 'GS_FP_DATA-STATUS'   OR 'GS_FP_DATA-FTEXT_Z1'
*                                    OR 'GS_FP_DATA-FTEXT_Z2' OR 'GS_FP_DATA-FTEXT_Z3'
*                                    OR 'GS_FP_DATA-AKTZE'    OR 'AVIS'
*                                    OR 'GV_AO_KASSZE'.
*            screen-active = 0.
*            screen-output = 0.
*        ENDCASE.
*      WHEN OTHERS.
*        CASE screen-name.
*          WHEN 'GS_FP_DATA-ADDR_Z1' OR 'GS_FP_DATA-FTEXT_Z1' OR 'GS_FP_DATA-FTEXT_Z2'
*                                    OR 'GS_FP_DATA-FTEXT_Z3' OR 'GS_FP_DATA-AKTZE'
*                                    OR 'AVIS'                OR 'GV_AO_KASSZE'.
*            screen-active = 0.
*            screen-output = 0.
*        ENDCASE.
*    ENDCASE.

*Name des Vorstands nur bei Eskalationsstufe 3
*    IF screen-name = 'GS_FP_DATA-ADDR_Z1'.
*      CASE gs_fp_data-status.
*        WHEN 3.
*          screen-input = 1.
*        WHEN OTHERS.
*          screen-input = 0.
*      ENDCASE.
*    ENDIF.

* Übernahme der Einstellungen
    MODIFY SCREEN.
  ENDLOOP.


  SET TITLEBAR '0491'.

  CLEAR okcode.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_0509
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0509 .

  SET TITLEBAR '0509_1'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0511 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0511 OUTPUT.
  SET PF-STATUS '0511'.

  PERFORM screen_0511.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Form SCREEN_0511
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0511 .
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'GS_FP_DATA-FTEXT_Z2'.
        screen-active = 0.
        screen-output = 0.
      WHEN 'GS_FP_DATA-FTEXT_Z3'.
        screen-active = 0.
        screen-output = 0.
    ENDCASE.

    MODIFY SCREEN.
  ENDLOOP.

  CASE gs_zfi_ea_fo-formtype.
    WHEN '1'.
      SET TITLEBAR '0511_1'.
    WHEN '2'.
      SET TITLEBAR '0511_2'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_0515
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_0515 .
*  LOOP AT SCREEN.
** Übernahme der Einstellungen
*    MODIFY SCREEN.
*  ENDLOOP.

  CASE gs_zfi_ea_fo-formtype.
    WHEN '1'.
      SET TITLEBAR '0515_1'.
  ENDCASE.

  CLEAR okcode.

ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  IF gv_edit_cont IS INITIAL.
    CREATE OBJECT gr_editor_container
      EXPORTING
        container_name              = 'GR_TEXTEDITOR'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc EQ 0.
      CREATE OBJECT gr_text_editor
        EXPORTING
          parent                     = gr_editor_container
          wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
          wordwrap_position          = gv_line_length
          wordwrap_to_linebreak_mode = cl_gui_textedit=>true.

      gv_edit_cont = 'X'.
    ENDIF.
  ENDIF.

  CALL METHOD gr_text_editor->set_textstream
    EXPORTING
      text = gv_text.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form PREPARE_DYNP_DATA_0494
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_dynp_data_0494 .

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
* Ort -> Postleitzahl ggf. nach Ortsnamen im System
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
*& Form PREPARE_DYNP_DATA_0521
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_dynp_data_0521 .

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

*OUTPUT MODULE FOR TC 'GTC_EMAIL_ADDR'.
*UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE gtc_email_addr_change_tc_attr OUTPUT.
* neue Eingabezeilen bereitstellen
  DO 20 TIMES.
    APPEND INITIAL LINE TO gt_email_addr.
  ENDDO.

  DESCRIBE TABLE gt_email_addr LINES gtc_email_addr-lines.
ENDMODULE.
