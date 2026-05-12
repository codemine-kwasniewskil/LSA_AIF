*----------------------------------------------------------------------*
***INCLUDE ZFI_EA_FORMS_PRN_I02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZFI_EA_FORMS_PRN_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0520 INPUT.
  PERFORM user_command_0520.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0495  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0495 INPUT.
  PERFORM user_command_0495.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0520
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0520 .
  DATA: lv_cancel TYPE xfeld.

  CLEAR lv_cancel.

  CASE okcode.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'DEBI'.
      PERFORM get_address_from_kunnr.
      CLEAR okcode.
    WHEN 'VIEW'.
      gv_screen_display = gc_screen_display.
      PERFORM processing USING gv_screen_display.
      CLEAR okcode.
    WHEN 'SEND'.
      CLEAR gv_screen_display.
      PERFORM check_address CHANGING lv_cancel.
      IF lv_cancel IS INITIAL.
        PERFORM processing USING gv_screen_display.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'MORE'.
      CALL SCREEN '0105' STARTING AT 1 1.
      CLEAR okcode.
    WHEN 'ETXT'.
      CALL SCREEN '0100' STARTING AT 1 1.
      CLEAR okcode.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0495
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0495 .

  DATA: lv_cancel TYPE xfeld.

  CLEAR lv_cancel.

  CASE okcode.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'VIEW'.
      gv_screen_display = gc_screen_display.
      PERFORM processing USING gv_screen_display.
      CLEAR okcode.
    WHEN 'SEND'.
      CLEAR gv_screen_display.
      PERFORM check_bank_address CHANGING lv_cancel.
      IF lv_cancel IS INITIAL.
        PERFORM processing USING gv_screen_display.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'MORE'.
      CALL SCREEN '0105' STARTING AT 1 1.
      CLEAR okcode.
    WHEN 'ETXT'.
      CALL SCREEN '0100' STARTING AT 1 1.
      CLEAR okcode.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0508  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0508 INPUT.
  PERFORM user_command_0508.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0508
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0508 .

  DATA: lv_cancel TYPE xfeld.

  CLEAR lv_cancel.

  CASE okcode.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'AVIS'.
      PERFORM get_avis_text.
    WHEN 'VIEW'.
      gv_screen_display = gc_screen_display.
      PERFORM processing USING gv_screen_display.
      CLEAR okcode.
    WHEN 'SEND'.
      CLEAR gv_screen_display.
      PERFORM check_address CHANGING lv_cancel.
      IF lv_cancel IS INITIAL.
        PERFORM processing USING gv_screen_display.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'MORE'.
      CALL SCREEN '0105' STARTING AT 1 1.
      CLEAR okcode.
    WHEN 'ETXT'.
      CALL SCREEN '0100' STARTING AT 1 1.
      CLEAR okcode.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form UPDATE_FIELDS_0508
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0508 .

  DATA: ls_fmfctr        TYPE fmfctr,
        ls_zom_addr_attr TYPE zom_addr_attr,
        ls_zom_addr_out  TYPE zom_addr_out.
  .

  CLEAR: gs_fp_data-addr_z2, gs_fp_data-addr_z3,
         gs_fp_data-addr_z4, gs_fp_data-addr_z5,
         gs_fp_data-addr_z6, gv_fictr_bezei.


  ls_zom_addr_attr-zpgsbr     =  gv_fictr(4).
  ls_zom_addr_attr-acc_fcentr =  gv_fictr.

  CALL FUNCTION 'Z_OM_FIND_ADDRESS'
    EXPORTING
      is_addr_attr            = ls_zom_addr_attr
    IMPORTING
      es_addr_out             = ls_zom_addr_out
    EXCEPTIONS
      is_addr_attr_is_initial = 1
      invalid_addr_type       = 2
      no_object_found         = 3
      OTHERS                  = 4.
  IF sy-subrc EQ 0.
    gs_fp_data-addr_z2 = ls_zom_addr_out-line0.
    gs_fp_data-addr_z3 = ls_zom_addr_out-line1.
    gs_fp_data-addr_z4 = ls_zom_addr_out-line2.
    gs_fp_data-addr_z5 = ls_zom_addr_out-line3.
    gs_fp_data-addr_z6 = ls_zom_addr_out-line4.

    gv_postfach_id   = ls_zom_addr_out-zzbepo.


* Reihenfolge der vorgeschlagenen Versandart

*    gv_printer      =
*    gv_mail_rc_user =

    gv_telfx        = ls_zom_addr_out-faxnr.
    gv_email_addr   = ls_zom_addr_out-zzmail.
    gv_tland        = ls_zom_addr_out-land1.

    CLEAR: gv_mail_in, gv_mail_ex, gv_fax, gv_druck, gv_service_bw.

* Radiobutton für Kommunikation setzen
    IF NOT gv_postfach_id IS INITIAL.
      gv_service_bw = abap_true.
    ELSEIF NOT gv_mail_rc_user IS INITIAL.
      gv_mail_in = abap_true.
    ELSEIF NOT gv_email_addr IS INITIAL.
      gv_mail_ex = abap_true.
    ELSEIF NOT gv_telfx IS INITIAL.
      gv_fax = abap_true.
    ELSE.
      gv_druck = abap_true.
    ENDIF.
  ELSE.
    MESSAGE i033 WITH gv_fictr DISPLAY LIKE 'I'.
  ENDIF.

  IF okcode EQ 'SEND' OR okcode EQ 'VIEW'.
    CLEAR okcode.
  ENDIF.
  MESSAGE i062 DISPLAY LIKE 'I'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0528  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0528 INPUT.
  PERFORM user_command_0528.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form 0528_USER_COMMAND_0528
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0528 .

  DATA: lv_cancel TYPE xfeld.

  CLEAR lv_cancel.

  CASE okcode.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'VIEW'.
      gv_screen_display = gc_screen_display.
      PERFORM processing USING gv_screen_display.
      CLEAR okcode.
    WHEN 'SEND'.
      CLEAR gv_screen_display.
      PERFORM check_address CHANGING lv_cancel.
      IF lv_cancel IS INITIAL.
        PERFORM processing USING gv_screen_display.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'MORE'.
      CALL SCREEN '0105' STARTING AT 1 1.
      CLEAR okcode.
    WHEN 'ETXT'.
      CALL SCREEN '0100' STARTING AT 1 1.
      CLEAR okcode.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0510 INPUT.
  PERFORM user_command_0510.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0510
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0510 .

  DATA: lv_cancel TYPE xfeld.

  CLEAR lv_cancel.

  CASE okcode.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'VIEW'.
      gv_screen_display = gc_screen_display.
      PERFORM processing USING gv_screen_display.
      CLEAR okcode.
    WHEN 'SEND'.
      CLEAR gv_screen_display.
      PERFORM check_address CHANGING lv_cancel.
      IF lv_cancel IS INITIAL.
        PERFORM processing USING gv_screen_display.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'MORE'.
      CALL SCREEN '0105' STARTING AT 1 1.
      CLEAR okcode.
    WHEN 'ETXT'.
      CALL SCREEN '0100' STARTING AT 1 1.
      CLEAR okcode.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0508  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0508 INPUT.

  PERFORM update_fields_0508.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0495  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0495 INPUT.

  PERFORM update_fields_0495.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  GET_BANKL_BANKS_VALUES_0495  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_bankl_banks_values_0495 INPUT.

  PERFORM get_bankl_banks_values_0495.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_BANKL_BANKS_VALUES_0495
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bankl_banks_values_0495 .
  DATA: ls_shlp   TYPE shlp_descr,
        lt_retval TYPE TABLE OF ddshretval,
        ls_retval TYPE ddshretval,
        lt_fields TYPE TABLE OF dynpread,
        ls_fields TYPE dynpread.

  FIELD-SYMBOLS <if> TYPE ddshiface.

  CLEAR lt_fields.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = 'ZFI_EA_BANK_HLP'
      shlptype = 'SH'
    IMPORTING
      shlp     = ls_shlp.

  LOOP AT ls_shlp-interface ASSIGNING <if>.
    IF <if>-shlpfield = 'BANKL'.
      <if>-valfield   = 'BANKL'.
    ENDIF.
    IF <if>-shlpfield = 'BANKS'.
      <if>-valfield   = 'BANKS'.
      <if>-value      = 'DE'.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
    TABLES
      return_values = lt_retval.

  IF NOT lt_retval IS INITIAL.

* Rückgabetabelle ist gefüllt:
    READ TABLE lt_retval INTO ls_retval WITH KEY fieldname = 'BANKL'.
    IF sy-subrc = 0.
      ls_fields-fieldvalue  = ls_retval-fieldval.
      ls_fields-fieldname   = 'GV_BANKL'.
      APPEND ls_fields TO lt_fields.
    ENDIF.

    READ TABLE lt_retval INTO ls_retval WITH KEY fieldname = 'BANKS'.
    IF sy-subrc = 0.
      ls_fields-fieldvalue  = ls_retval-fieldval.
      ls_fields-fieldname   = 'GV_BANKS'.
      APPEND ls_fields TO lt_fields.
    ENDIF.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-cprog
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_fields.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0492 INPUT.
  PERFORM update_fields_0492.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form 0510_UPDATE_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0492 .

  DATA: ls_fmfctr        TYPE fmfctr,
        ls_zom_addr_attr TYPE zom_addr_attr,
        ls_zom_addr_out  TYPE zom_addr_out.

  CLEAR: gs_fp_data-addr_z2, gs_fp_data-addr_z3,
         gs_fp_data-addr_z4, gs_fp_data-addr_z5,
         gs_fp_data-addr_z1, gv_fictr_bezei.


** Get AnnAO and calculate fee:
  SELECT SINGLE FROM /thkr/cds_bjcube
      FIELDS CAST( solloriginalbetrag AS CHAR )
      WHERE   accountingdocumenttype  LIKE 'D%'
        AND   btart                   = '0100'
        AND   documentreferenceid     = @gv_ao_kassze
       INTO @gs_fp_data-ao_soll_betrag_text.
  IF sy-subrc NE 0.
    MESSAGE i065 DISPLAY LIKE 'I' WITH gv_ao_kassze.
    IF okcode EQ 'SEND' OR okcode EQ 'VIEW'.
      CLEAR okcode.
    ENDIF.
    RETURN.
  ENDIF.
  gs_fp_data-gebuehr = gs_worklist_fe-kwbtr - gs_fp_data-ao_soll_betrag_text.

  gs_fp_data-ao_kasze = gv_ao_kassze.
  ls_zom_addr_attr-zpgsbr     =  gv_fictr(4).
  ls_zom_addr_attr-acc_fcentr =  gv_fictr.

  CALL FUNCTION 'Z_OM_FIND_ADDRESS'
    EXPORTING
      is_addr_attr            = ls_zom_addr_attr
    IMPORTING
      es_addr_out             = ls_zom_addr_out
    EXCEPTIONS
      is_addr_attr_is_initial = 1
      invalid_addr_type       = 2
      no_object_found         = 3
      OTHERS                  = 4.
  IF sy-subrc EQ 0.
    gs_fp_data-addr_z1 = ls_zom_addr_out-line0.
    gs_fp_data-addr_z2 = ls_zom_addr_out-line1.
    gs_fp_data-addr_z3 = ls_zom_addr_out-line2.
    gs_fp_data-addr_z4 = ls_zom_addr_out-line3.
    gs_fp_data-addr_z5 = ls_zom_addr_out-line4.

    gv_postfach_id   = ls_zom_addr_out-zzbepo.

* Reihenfolge der vorgeschlagenen Versandart

*    gv_printer      =
*    gv_mail_rc_user =

    gv_telfx        = ls_zom_addr_out-faxnr.
    gv_email_addr   = ls_zom_addr_out-zzmail.
    gv_tland        = ls_zom_addr_out-land1.

    CLEAR: gv_mail_in, gv_mail_ex, gv_fax, gv_druck, gv_service_bw.

* Radiobutton für Kommunikation setzen
    IF NOT gv_postfach_id IS INITIAL.
      gv_service_bw = abap_true.
    ELSEIF NOT gv_mail_rc_user IS INITIAL.
      gv_mail_in = abap_true.
    ELSEIF NOT gv_email_addr IS INITIAL.
      gv_mail_ex = abap_true.
    ELSEIF NOT gv_telfx IS INITIAL.
      gv_fax = abap_true.
    ELSE.
      gv_druck = abap_true.
    ENDIF.
  ELSE.
    MESSAGE i033 WITH gv_fictr DISPLAY LIKE 'I'.
  ENDIF.

  IF okcode EQ 'SEND' OR okcode EQ 'VIEW'.
    CLEAR okcode.
  ENDIF.
  MESSAGE i062 DISPLAY LIKE 'I'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0528 INPUT.
  PERFORM update_fields_0528.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form 0528_UPDATE_FIELDS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0528 .
  DATA: ls_fmfctr        TYPE fmfctr,
        ls_zom_addr_attr TYPE zom_addr_attr,
        ls_zom_addr_out  TYPE zom_addr_out.
  .

  CLEAR: gs_fp_data-addr_z2, gs_fp_data-addr_z3,
         gs_fp_data-addr_z4, gs_fp_data-addr_z5,
         gs_fp_data-addr_z1, gv_fictr_bezei.


  ls_zom_addr_attr-zpgsbr     =  gv_fictr(4).
  ls_zom_addr_attr-acc_fcentr =  gv_fictr.

  CALL FUNCTION 'Z_OM_FIND_ADDRESS'
    EXPORTING
      is_addr_attr            = ls_zom_addr_attr
    IMPORTING
      es_addr_out             = ls_zom_addr_out
    EXCEPTIONS
      is_addr_attr_is_initial = 1
      invalid_addr_type       = 2
      no_object_found         = 3
      OTHERS                  = 4.
  IF sy-subrc EQ 0.
    gs_fp_data-addr_z1 = ls_zom_addr_out-line0.
    gs_fp_data-addr_z2 = ls_zom_addr_out-line1.
    gs_fp_data-addr_z3 = ls_zom_addr_out-line2.
    gs_fp_data-addr_z4 = ls_zom_addr_out-line3.
    gs_fp_data-addr_z5 = ls_zom_addr_out-line4.

    gv_postfach_id   = ls_zom_addr_out-zzbepo.


* Reihenfolge der vorgeschlagenen Versandart

*    gv_printer      =
*    gv_mail_rc_user =

    gv_telfx        = ls_zom_addr_out-faxnr.
    gv_email_addr   = ls_zom_addr_out-zzmail.
    gv_tland        = ls_zom_addr_out-land1.

    CLEAR: gv_mail_in, gv_mail_ex, gv_fax, gv_druck, gv_service_bw.

* Radiobutton für Kommunikation setzen
    IF NOT gv_postfach_id IS INITIAL.
      gv_service_bw = abap_true.
    ELSEIF NOT gv_mail_rc_user IS INITIAL.
      gv_mail_in = abap_true.
    ELSEIF NOT gv_email_addr IS INITIAL.
      gv_mail_ex = abap_true.
    ELSEIF NOT gv_telfx IS INITIAL.
      gv_fax = abap_true.
    ELSE.
      gv_druck = abap_true.
    ENDIF.
  ELSE.
    MESSAGE i033 WITH gv_fictr DISPLAY LIKE 'I'.
  ENDIF.

  IF okcode EQ 'SEND' OR okcode EQ 'VIEW'.
    CLEAR okcode.
  ENDIF.
  MESSAGE i062 DISPLAY LIKE 'I'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_DYNP_DATA_0508
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_dynp_data_0508 .
* Status der Eskalationsstufe
  gv_status_alt  = 1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0520 INPUT.
  PERFORM update_fields_0520.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form 0520_update_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0520 .
  DATA: lv_counter TYPE i.

  IF NOT gv_kunnr IS INITIAL.
* ggf Kundennummer mit 0 auffüllen
    lv_counter = 10 - strlen( gv_kunnr ).

    DO lv_counter TIMES.
      CONCATENATE '0' gv_kunnr INTO gv_kunnr.
    ENDDO.
* Name ermitteln
    SELECT SINGLE name1 FROM kna1 INTO gv_name1
       WHERE kunnr EQ gv_kunnr.
  ELSE.
    CLEAR gv_name1.
  ENDIF.

ENDFORM.
