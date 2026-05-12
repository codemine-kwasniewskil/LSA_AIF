class /THKR/CL_FI_ITEM_AUTH_CUST definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_BADI_FI_AUTHORITY_ITEM_C .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_FI_ITEM_AUTH_CUST IMPLEMENTATION.


  METHOD if_ex_badi_fi_authority_item_c~fi_authority_item_cust.

    DATA: lv_partner TYPE bu_partner,
          lv_type    TYPE c.

    IF i_bseg-lifnr IS NOT INITIAL.
      lv_partner = i_bseg-lifnr.
      lv_type = 'K'.

    ELSEIF i_bseg-kunnr IS NOT INITIAL.

      lv_partner = i_bseg-kunnr.
      lv_type = 'D'.

    ENDIF.

    DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                                 iv_partner = lv_partner
                                 iv_type = lv_type  ).
    IF no_auth_l EQ abap_true.

      c_rcode = 4.
      c_msgid = '/THKR/BP'.
      c_msgno = '010'.
      MESSAGE e010(/thkr/bp) WITH lv_partner.

    ENDIF.


  ENDMETHOD.
ENDCLASS.
