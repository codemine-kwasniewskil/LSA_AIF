"Name: \PR:RFAPBALANCE\FO:CHECK_AUTHORITY_GROUPS\SE:END\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_BUPA_6.

IF pr_kunnr IS NOT INITIAL.

  SELECT partner FROM but000
    INTO TABLE @DATA(lt_partner)
    WHERE partner IN @pr_kunnr.

ELSEIF pr_lifnr IS NOT INITIAL.

  SELECT partner FROM but000
      INTO TABLE @lt_partner
      WHERE partner IN @pr_lifnr.

ENDIF.

IF lt_partner IS NOT INITIAL.

  DATA(lv_object) = /thkr/cl_auth_check=>get_bupa_object( ).

  LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).

    DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = <fs_partner>-partner
                              iv_object = lv_object ).
    IF no_auth_l EQ abap_true.
      MESSAGE e010(/thkr/bp) WITH <fs_partner>.

    ENDIF.

  ENDLOOP.

ENDIF.

ENDENHANCEMENT.
