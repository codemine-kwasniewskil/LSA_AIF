"Name: \PR:RFFMFBAO_NEW\FO:AUTHORITY_CHECK_K_D\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_BUPA_4.
DATA: lt_partner TYPE STANDARD TABLE OF bu_partner.
DATA: lv_change_flag TYPE flag.
DATA(lt_pso) = g_t_pso[].

SELECT lifnr FROM @lt_pso AS lif
  WHERE lifnr IS NOT INITIAL
  INTO TABLE @DATA(lt_lifnr).

SELECT kunnr FROM @lt_pso AS kun
  WHERE kunnr IS NOT INITIAL
  INTO TABLE @DATA(lt_kunnr).

APPEND LINES OF lt_lifnr TO lt_partner.
APPEND LINES OF lt_kunnr TO lt_partner.

IF lt_partner IS NOT INITIAL.

  DATA(lv_object) = /thkr/cl_auth_check=>get_bupa_object( ).

  SORT lt_partner.
  DELETE ADJACENT DUPLICATES FROM lt_partner.
  LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).
    DATA(rv_no_auth) = /thkr/cl_auth_check=>check_bupa_auth(
        EXPORTING iv_partner = <fs_partner>
                  iv_object = lv_object
        ).

    IF rv_no_auth = abap_true.

      SELECT belnr, bukrs, gjahr
        FROM @lt_pso AS pso
        WHERE lifnr = @<fs_partner> OR kunnr = @<fs_partner>
        INTO TABLE @DATA(lt_belege).
      IF sy-subrc = 0.

        LOOP AT lt_belege ASSIGNING FIELD-SYMBOL(<fs_beleg>).

          DELETE g_t_pso[] WHERE belnr = <fs_beleg>-belnr
          AND gjahr = <fs_beleg>-gjahr
          AND bukrs = <fs_beleg>-bukrs.

        ENDLOOP.

        CLEAR rv_no_auth.
        lv_change_flag = abap_true.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF lv_change_flag = abap_true.
    IF u_flg_msg IS INITIAL.
      MESSAGE i002(fmrp).
      u_flg_msg = abap_true.
    ENDIF.

  ENDIF.
ENDIF.
ENDENHANCEMENT.
