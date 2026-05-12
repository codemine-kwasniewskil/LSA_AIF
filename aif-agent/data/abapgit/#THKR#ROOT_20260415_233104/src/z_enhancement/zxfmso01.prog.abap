*----------------------------------------------------------------------*
***INCLUDE ZXFMSO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

DATA mv_txt_out     TYPE char255.
DATA mv_ddlb_values TYPE vrm_values.

MODULE set_field_inputreadiness OUTPUT.
  DATA: cust_fmmdstf  LIKE STANDARD TABLE OF fmmdstf.
*  data: screen_fields        TYPE fmmd_t_fieldname.
*-----Get field selection string
  DATA(screen_fields) = VALUE fmmd_t_fieldname( ( fieldname = 'ZZ_FUNDDISTR_LVL' ) ).
  PERFORM screen_fieldstatus_get(sapmfmfs)  TABLES cust_fmmdstf USING  ifmfctrdy-fikrs '2'.
  TRY.
      DATA(funddistr_lvl_fieldstatus) = cust_fmmdstf[ fieldname = 'ZZ_FUNDDISTR_LVL' ]-fieldstatus.
    CATCH cx_sy_itab_line_not_found.
      " Nothing to do!
  ENDTRY.
  LOOP AT SCREEN.
    IF screen-name = 'IFMFCTRDY-ZZ_FUNDDISTR_LVL'.
      screen-input = '0'.
*      IF gv_input_state = abap_true
*      OR funddistr_lvl_fieldstatus = 3.
*        screen-input = '0'.
*      ELSEIF funddistr_lvl_fieldstatus = 1.
*        screen-required = '1'.
*      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.

MODULE set_ddlb_values OUTPUT.
  SELECT fundist_lvl
        ,fundist_lvl_txt
    FROM /thkr/c_fund_dis
    INTO TABLE @DATA(fund_dis)
    ORDER BY sort.

  mv_ddlb_values = VALUE #( FOR item IN fund_dis ( key = item-fundist_lvl text = item-fundist_lvl_txt ) ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'IFMFCTRDY-ZZ_FUNDDISTR_LVL'
      values = mv_ddlb_values.
ENDMODULE.

MODULE set_description_field OUTPUT.
  TRY.
      mv_txt_out = mv_ddlb_values[ key = ifmfctrdy-zz_funddistr_lvl ]-text.
    CATCH cx_sy_itab_line_not_found.
      mv_txt_out = TEXT-ntf.
  ENDTRY.

ENDMODULE.


MODULE set_description_field INPUT.
  TRY.
      mv_txt_out = mv_ddlb_values[ key = ifmfctrdy-zz_funddistr_lvl ]-text.
    CATCH cx_sy_itab_line_not_found.
      mv_txt_out = TEXT-ntf.
  ENDTRY.

ENDMODULE.
