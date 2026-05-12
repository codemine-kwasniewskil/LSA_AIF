*&---------------------------------------------------------------------*
*& Include          ZFI_EA_FORMS_PRN_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0494  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0494 INPUT.
  PERFORM user_command_0494.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0521  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0521 INPUT.
  PERFORM user_command_0521.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form UPDATE_FIELDS_0480
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0480 .
  DATA: ls_fmfctr        TYPE fmfctr,
        ls_zom_addr_attr TYPE zom_addr_attr,
        ls_zom_addr_out  TYPE zom_addr_out.


  CLEAR: gs_fp_data-addr_z2, gs_fp_data-addr_z3,
         gs_fp_data-addr_z4, gs_fp_data-addr_z5,
         gs_fp_data-addr_z1, gv_fictr_bezei.


* Dienststelle aus Finanzstelle nachlesen
*  SELECT SINGLE name1 from FMFCTR into gs_fp_data-vztext "-> Aktuell: name1 aus Adressdaten der Finanzstelle.
*    WHERE fikrs = gv_fikrs AND fictr = gv_fictr.         "   Eigentlich: BEZEICH (fehlt noch in Struktur)
* evtl. doch überflüssig -> Zeile 1 der Anschrift aus OM enthält ebenfalls die Bezeichnung

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

* Service-BW Postfach
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
*&      Module  USER_COMMAND_0507  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0480 INPUT.
  PERFORM user_command_0480.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0480
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0480 .

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
*& Form USER_COMMAND_0494
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0494 .

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
*& Form USER_COMMAND_0521
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0521 .
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
*&      Module  USER_COMMAND_0507  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0507 INPUT.
  PERFORM user_command_0507.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0507
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0507 .

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
*&      Module  USER_COMMAND_0509  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0509 INPUT.
  PERFORM user_command_0509.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0509
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0509.

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
*&      Module  USER_COMMAND_0515  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0515 INPUT.
  PERFORM user_command_0515.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0515
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0515 .

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
*&      Module  USER_COMMAND_0510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0511 INPUT.
  PERFORM user_command_0511.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND_0511
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_0511.

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
*&      Module  UPDATE_FIELDS_0507  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0491 INPUT.

  PERFORM update_fields_0491.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0515  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0515 INPUT.

  PERFORM update_fields_0515.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0480  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0480 INPUT.

  PERFORM update_fields_0480.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0509  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0509 INPUT.

  PERFORM update_fields_0509.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0494  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0494 INPUT.

  PERFORM update_fields_0494.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  GET_BANKL_BANKS_VALUES_0494  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_bankl_banks_values_0494 INPUT.

  PERFORM get_bankl_banks_values_0494.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form GET_BANKL_BANKS_VALUES_0494
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bankl_banks_values_0494 .
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
      IF NOT gv_banks IS INITIAL.
        <if>-value      = gv_banks.
      ELSE.
        <if>-value      = 'DE'.
      ENDIF.
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
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'BACK'.
      CALL METHOD gr_text_editor->get_textstream
*         EXPORTING
*          ONLY_WHEN_MODIFIED     = CL_GUI_TEXTEDIT=>TRUE
        IMPORTING
          text                   = gv_text
*         IS_MODIFIED            =
        EXCEPTIONS
          error_cntl_call_method = 1
          not_supported_by_gui   = 2
          OTHERS                 = 3.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CALL METHOD cl_gui_cfw=>flush
        EXCEPTIONS
          cntl_system_error = 1
          cntl_error        = 2
          OTHERS            = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.
  CASE sy-ucomm.
    WHEN 'EXIT'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0511  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0511 INPUT.
  PERFORM update_fields_0511.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form UPDATE_FIELDS_0511
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0511 .
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

*    gv_printer      = ls_fmfctr-teletext.
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
*& Form GET_AVIS_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_avis_text .

  DATA: ls_fo_tb TYPE zfi_ea_fo_tb,
        lt_lines TYPE TABLE OF tline,
        ls_lines TYPE tline.

  SELECT SINGLE * FROM /thkr/ea_fo_tb INTO ls_fo_tb
    WHERE formid   EQ gv_formid
      AND variant  EQ gv_variant
      AND objectid EQ 'M015'.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = ls_fo_tb-tdid
        language                = ls_fo_tb-tdspras
        name                    = ls_fo_tb-tdname
        object                  = 'TEXT'
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc EQ 0.
      LOOP AT lt_lines INTO ls_lines.
        CASE sy-tabix.
          WHEN '1'.
            gs_fp_data-ftext_z1 = ls_lines-tdline.
          WHEN '2'.
            gs_fp_data-ftext_z2 = ls_lines-tdline.
          WHEN '3'.
            gs_fp_data-ftext_z3 = ls_lines-tdline.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form prepare_dynp_data_0491
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_dynp_data_0491 .

* Daten aus Reiter "Kontierung"
  DATA: lt_feb_accnt_save TYPE TABLE OF feb_accnt_save,
        ls_feb_accnt_save LIKE LINE OF lt_feb_accnt_save.

  SELECT SINGLE * FROM feb_accnt_save INTO ls_feb_accnt_save
    WHERE kukey = gv_kukey AND esnum = gv_esnum.

  gv_fikrs = ls_feb_accnt_save-fikrs.
  gv_fictr = ls_feb_accnt_save-fistl.

  CALL FUNCTION 'CONVERSION_EXIT_FIPEX_OUTPUT'
    EXPORTING
      input  = ls_feb_accnt_save-fipex
    IMPORTING
      output = gs_fp_data-buchungsstelle.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PREPARE_DYNP_DATA_0507
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_dynp_data_0492 .
  gv_ao_kassze = gs_worklist_fe-xblnr.

** Set Selection
  CASE gs_worklist_fe-kkref+3(1).
    WHEN 1.
      gs_fp_data-ftext_z1 = abap_true.
    WHEN 2.
      gs_fp_data-ftext_z2 = abap_true.
    WHEN 3.
      gs_fp_data-ftext_z3 = abap_true.
    WHEN 4.
      gs_fp_data-status = abap_true.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form UPDATE_FIELDS_0507
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0491 .

  DATA: ls_fmfctr        TYPE fmfctr,
        ls_zom_addr_attr TYPE zom_addr_attr,
        ls_zom_addr_out  TYPE zom_addr_out.

  CLEAR: gs_fp_data-addr_z2, gs_fp_data-addr_z3,
         gs_fp_data-addr_z4, gs_fp_data-addr_z5,
         gs_fp_data-addr_z6, gv_fictr_bezei.

* Felder aus AO auslesen
  SELECT SINGLE FROM /thkr/cds_bjcube
    FIELDS
      psofn
      ,solloriginalbetrag
      ,CAST( gezahlt AS CURR( 12,2 ) ) AS gezahlt
      ,offenessoll
      ,lifname
      ,wrbtr
    WHERE    fikrs               EQ @gv_fikrs
         AND documentreferenceid EQ @gv_ao_kassze
         AND fistl               EQ @gv_fictr
         AND wrttp               EQ 54
         AND btart               EQ '0100'
         AND lifname             NE @space
    INTO @DATA(ls_result).
  IF sy-subrc NE 0.
    MESSAGE i065 DISPLAY LIKE 'I' WITH gv_ao_kassze.
    IF okcode EQ 'SEND' OR okcode EQ 'VIEW'.
      CLEAR okcode.
    ENDIF.
  ENDIF.

  gs_fp_data-ftext_z1 = ls_result-psofn.
  gs_fp_data-ftext_z2 = ls_result-lifname.
  gs_fp_data-g_betrag = abs( ls_result-solloriginalbetrag ).
** Grund der Rücküberweisung
  gs_fp_data-aktze = gs_worklist_fe-kkref.

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

* Service-BW Postfach
    gv_postfach_id   = ls_zom_addr_out-zzbepo.


* Reihenfolge der vorgeschlagenen Versandart

*    gv_printer      = ls_fmfctr-teletext.
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
*& Form UPDATE_FIELDS_0509
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0509 .

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
* Service-BW Postfach
    gv_postfach_id   = ls_zom_addr_out-zzbepo.


* Reihenfolge der vorgeschlagenen Versandart

*    gv_printer      = ls_fmfctr-teletext.
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
*& Form UPDATE_FIELDS_0515
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0515 .

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
* Adresse
    gs_fp_data-addr_z1 = ls_zom_addr_out-line0.
    gs_fp_data-addr_z2 = ls_zom_addr_out-line1.
    gs_fp_data-addr_z3 = ls_zom_addr_out-line2.
    gs_fp_data-addr_z4 = ls_zom_addr_out-line3.
    gs_fp_data-addr_z5 = ls_zom_addr_out-line4.

* Postfach ID Service-BW
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
*&      Module  UPDATE_ADDRESS_0507  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_address_0507 INPUT.
* Eskalationszeile zurücksetzen
  CLEAR gs_fp_data-addr_z1.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form check_address
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_address CHANGING cv_cancel TYPE c.
  DATA: lv_adr_lines TYPE i,
        lv_answer    TYPE c.

  CLEAR lv_adr_lines.
  IF NOT gs_fp_data-addr_z1 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-addr_z2 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-addr_z3 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-addr_z4 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-addr_z5 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-addr_z6 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF lv_adr_lines < 3.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Kontrolle Anschriftszeilen'(000)
        text_question         = 'Sind die Anschriftszeilen ausreichend gefüllt?'(001)
        text_button_1         = 'Ja'(002)
*       ICON_BUTTON_1         = ' '
        text_button_2         = 'Nein'(003)
*       ICON_BUTTON_2         = ' '
*       DEFAULT_BUTTON        = '1'
        display_cancel_button = 'X'
*       USERDEFINED_F1_HELP   = ' '
*       START_COLUMN          = 25
*       START_ROW             = 6
*       POPUP_TYPE            =
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        answer                = lv_answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      IF lv_answer NE '1'.
        cv_cancel = 'X'.
      ENDIF.
    ENDIF.


  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_address
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_bank_address CHANGING cv_cancel TYPE c.
  DATA: lv_adr_lines TYPE i,
        lv_answer    TYPE c.

  CLEAR lv_adr_lines.
  IF NOT gs_fp_data-bank_addr_z1 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-bank_addr_z2 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-bank_addr_z3 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-bank_addr_z4 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-bank_addr_z5 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF NOT gs_fp_data-bank_addr_z6 IS INITIAL.
    lv_adr_lines = lv_adr_lines + 1.
  ENDIF.
  IF lv_adr_lines < 3.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Kontrolle Anschriftszeilen'(000)
        text_question         = 'Sind die Anschriftszeilen ausreichend gefüllt?'(001)
        text_button_1         = 'Ja'(002)
*       ICON_BUTTON_1         = ' '
        text_button_2         = 'Nein'(003)
*       ICON_BUTTON_2         = ' '
*       DEFAULT_BUTTON        = '1'
        display_cancel_button = 'X'
*       USERDEFINED_F1_HELP   = ' '
*       START_COLUMN          = 25
*       START_ROW             = 6
*       POPUP_TYPE            =
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        answer                = lv_answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      IF lv_answer NE '1'.
        cv_cancel = 'X'.
      ENDIF.
    ENDIF.


  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_address_from_kunnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_address_from_kunnr .

  DATA:
    lv_sender_country    TYPE szad_field-send_cntry VALUE 'DE',
    lv_address_number    TYPE adrc-addrnumber,
    lv_counter           TYPE i,
    lt_address_printform TYPE	szadr_printform_table,
    ls_address_printform TYPE szadr_printform_table_line.

  IF NOT gv_kunnr IS INITIAL.
* ggf Kundennummer mit 0 auffüllen
    lv_counter = 10 - strlen( gv_kunnr ).

    DO lv_counter TIMES.
      CONCATENATE '0' gv_kunnr INTO gv_kunnr.
    ENDDO.
* Adressnummer suchen
    SELECT SINGLE adrnr FROM kna1 INTO lv_address_number
       WHERE kunnr EQ gv_kunnr.
    IF sy-subrc EQ 0.
* Adressenaufbereitung
      CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
        EXPORTING
          address_type                   = '1'
          address_number                 = lv_address_number
          sender_country                 = lv_sender_country
          number_of_lines                = 5
        IMPORTING
          address_printform_table        = lt_address_printform
        EXCEPTIONS
          address_blocked                = 1
          person_blocked                 = 2
          contact_person_blocked         = 3
          addr_to_be_formated_is_blocked = 4
          OTHERS                         = 5.
      IF sy-subrc EQ 0.
* Adresse in Felder übertragen
        IF NOT lt_address_printform[] IS INITIAL.
          LOOP AT lt_address_printform INTO ls_address_printform .
            CASE sy-tabix.
              WHEN '1'.
                gs_fp_data-addr_z1 = ls_address_printform-address_line.
              WHEN '2'.
                gs_fp_data-addr_z2 = ls_address_printform-address_line.
              WHEN '3'.
                gs_fp_data-addr_z3 = ls_address_printform-address_line.
              WHEN '4'.
                gs_fp_data-addr_z4 = ls_address_printform-address_line.
              WHEN '5'.
                gs_fp_data-addr_z5 = ls_address_printform-address_line.
            ENDCASE.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FIELDS_0521  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_fields_0521 INPUT.
  PERFORM update_fields_0521.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form update_fields_0521
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0521 .
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
*&---------------------------------------------------------------------*
*& Form prepare_dynp_data_0528
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_dynp_data_0528 .
  gs_fp_data-ao_fipex = gs_fp_data-ao_vom = gv_ao_kassze = gc_unbekannt.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_VERMERK_0528  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_vermerk_0528 INPUT.

  IF gv_bankvermerk EQ '7'.
    LOOP AT SCREEN.
      IF screen-name = 'GS_FP_DATA-BANKVERMERK'.
        screen-output = 1.
        screen-active = 1.
      ENDIF.
* Übernahme der Einstellungen
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    CLEAR gs_fp_data-bankvermerk.
    LOOP AT SCREEN.
      IF screen-name = 'GS_FP_DATA-BANKVERMERK'.
        screen-output = 0.
        screen-active = 0.
      ENDIF.
* Übernahme der Einstellungen
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  UPDATE_FAXNR_0480  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE update_faxnr_0480 INPUT.
  IF NOT gs_fp_data-faxnr IS INITIAL.
    gv_telfx = gs_fp_data-faxnr.
  ELSE.
    gs_fp_data-faxnr = gv_telfx.
  ENDIF.
  IF gv_tland IS INITIAL.
    gv_tland = 'DE'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LEAVE_DYNPRO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE leave_dynpro INPUT.
  PERFORM leave_dynpro.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form leave_dynpro
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM leave_dynpro .
  CASE okcode.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
ENDFORM.

MODULE gtc_email_addr_modify INPUT.

  DATA: ls_email_addr       TYPE gs_emailaddr_ty,
        ls_address_unstruct	TYPE sx_address.


  IF NOT gs_email_addr-receiver IS INITIAL.
    CONDENSE gs_email_addr-receiver NO-GAPS.

    ls_address_unstruct-type    = 'INT'.
    ls_address_unstruct-address = gs_email_addr-receiver.

    CALL FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'
      EXPORTING
        address_unstruct    = ls_address_unstruct
      EXCEPTIONS
        error_address_type  = 1
        error_address       = 2
        error_group_address = 3
        OTHERS              = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

* Übernahme der Daten
  READ TABLE gt_email_addr INTO ls_email_addr
    INDEX gtc_email_addr-current_line.
  IF sy-subrc EQ 0.
    MODIFY gt_email_addr
      FROM gs_email_addr
     INDEX gtc_email_addr-current_line.
  ELSE.
    APPEND gs_email_addr TO gt_email_addr.
  ENDIF.

  DELETE gt_email_addr WHERE receiver IS INITIAL.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GV_EMAIL_ADDR_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE gv_email_addr_modify INPUT.

  IF NOT gv_email_addr IS INITIAL.
    CONDENSE gv_email_addr NO-GAPS.

    ls_address_unstruct-type    = 'INT'.
    ls_address_unstruct-address = gv_email_addr.

    CALL FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'
      EXPORTING
        address_unstruct    = ls_address_unstruct
      EXCEPTIONS
        error_address_type  = 1
        error_address       = 2
        error_group_address = 3
        OTHERS              = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_INPUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_input INPUT.

  DATA: lt_dynpfields TYPE TABLE OF dynpread,
        ls_dynpfields TYPE dynpread,
        lv_dynname    TYPE progname,
        lv_dynnr      TYPE sychar04,
        lv_fcode      TYPE char20.

  FIELD-SYMBOLS: <field> TYPE any.

  lv_dynname = sy-repid.
  lv_dynnr   = sy-dynnr.


  CLEAR lt_dynpfields.

  LOOP AT SCREEN.
    IF screen-input = 1 AND screen-output = 1.
      MOVE screen-name TO ls_dynpfields-fieldname.
      APPEND ls_dynpfields TO lt_dynpfields.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = lv_dynname
      dynumb               = lv_dynnr
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.
  IF sy-subrc = 0.
    LOOP AT lt_dynpfields INTO ls_dynpfields.
      ASSIGN (ls_dynpfields-fieldname) TO <field>.
      <field> = ls_dynpfields-fieldvalue.
    ENDLOOP.
  ENDIF.
  IF gv_new = space.

    CONCATENATE '=' okcode INTO lv_fcode.

*    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*      EXPORTING
*        functioncode           = lv_fcode
*      EXCEPTIONS
*        function_not_supported = 1
*        OTHERS                 = 2.
*    IF sy-subrc <> 0.
*
*    ENDIF.
  ELSE.
    CLEAR gv_new.
  ENDIF.
ENDMODULE.
