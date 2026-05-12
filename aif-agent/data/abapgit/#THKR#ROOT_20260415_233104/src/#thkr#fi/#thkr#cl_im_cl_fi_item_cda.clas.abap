class /THKR/CL_IM_CL_FI_ITEM_CDA definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FI_ITEMS_CH_DATA .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_IM_CL_FI_ITEM_CDA IMPLEMENTATION.


  METHOD if_ex_fi_items_ch_data~change_items.


    DATA lt_items TYPE it_rfposxext.
    lt_items[] = ct_items[].

    FIELD-SYMBOLS <ls_item> TYPE LINE OF it_rfposxext.

    TYPES: BEGIN OF ty_auth_key,
             augrp_fistl TYPE fmfctr-augrp,
             augrp_fipex TYPE fmci-augrp,
             fipex       TYPE fm_fipex,
           END OF ty_auth_key.

    TYPES: BEGIN OF ty_item_id,
             bukrs TYPE acdoca-rbukrs,
             belnr TYPE acdoca-belnr,
             gjahr TYPE acdoca-gjahr,
             buzei TYPE acdoca-buzei,
           END OF ty_item_id.

    TYPES: BEGIN OF ty_item2auth,
             bukrs       TYPE acdoca-rbukrs,
             belnr       TYPE acdoca-belnr,
             gjahr       TYPE acdoca-gjahr,
             buzei       TYPE acdoca-buzei,
             augrp_fistl TYPE fmfctr-augrp,
             augrp_fipex TYPE fmci-augrp,
             fipex       TYPE fm_fipex,
           END OF ty_item2auth.

    DATA: lt_auth_candidates TYPE SORTED TABLE OF ty_auth_key
                                 WITH UNIQUE KEY augrp_fistl augrp_fipex fipex,
          lt_auth_ok         TYPE HASHED TABLE OF ty_auth_key
                                  WITH UNIQUE KEY augrp_fistl augrp_fipex fipex,
          lt_item2auth       TYPE HASHED TABLE OF ty_item2auth
                                  WITH UNIQUE KEY bukrs belnr gjahr buzei,
          ls_auth_key        TYPE ty_auth_key,
          ls_item2auth       TYPE ty_item2auth.

    LOOP AT lt_items ASSIGNING <ls_item>.
      SELECT SINGLE fistl, fipex
        FROM acdoca
        WHERE rbukrs = @<ls_item>-bukrs
          AND belnr  = @<ls_item>-belnr
          AND gjahr  = @<ls_item>-gjahr
          AND buzei  = @<ls_item>-buzei
        INTO @DATA(ls_fistl_fipex).

      CLEAR ls_auth_key.

      IF ls_fistl_fipex-fistl IS NOT INITIAL.
        SELECT SINGLE augrp
          FROM fmfctr
          INTO @ls_auth_key-augrp_fistl
          WHERE fikrs  = '1000'
            AND fictr  = @ls_fistl_fipex-fistl
            AND datab  <= @sy-datum
            AND datbis >= @sy-datum.
      ENDIF.

      IF ls_fistl_fipex-fipex IS NOT INITIAL.
        SELECT SINGLE augrp
          FROM fmci
          INTO @ls_auth_key-augrp_fipex
          WHERE fikrs = '1000'
            AND gjahr = @<ls_item>-gjahr
            AND fipex = @ls_fistl_fipex-fipex.

        ls_auth_key-fipex = ls_fistl_fipex-fipex.

      ENDIF.

      ls_item2auth-bukrs       = <ls_item>-bukrs.
      ls_item2auth-belnr       = <ls_item>-belnr.
      ls_item2auth-gjahr       = <ls_item>-gjahr.
      ls_item2auth-buzei       = <ls_item>-buzei.
      ls_item2auth-augrp_fistl = ls_auth_key-augrp_fistl.
      ls_item2auth-augrp_fipex = ls_auth_key-augrp_fipex.
      ls_item2auth-fipex = ls_auth_key-fipex.
      INSERT ls_item2auth INTO TABLE lt_item2auth.

      IF ls_auth_key-augrp_fistl IS NOT INITIAL OR
         ls_auth_key-augrp_fipex IS NOT INITIAL OR
         ls_auth_key-fipex IS NOT INITIAL..
        INSERT ls_auth_key INTO TABLE lt_auth_candidates.
      ENDIF.
    ENDLOOP.

    DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).

        LOOP AT lt_auth_candidates INTO ls_auth_key.
          DATA lv_subrc TYPE n.
          lv_subrc = 4.

          CASE lv_object_fica.
            WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

              CALL FUNCTION '/THKR/CHECK_FICA_UTK'
                EXPORTING
                  activity          = '03'
                  fm_fmfctr_authgrp = ls_auth_key-augrp_fistl
                  fm_fipex          = ls_auth_key-fipex
                  iv_user           = sy-uname
                IMPORTING
                  ex_subrc          = lv_subrc.

            WHEN OTHERS.

              CALL FUNCTION 'Z_CHECK_FICA_TRG'
                EXPORTING
                  activity          = '03'
                  fm_fmfctr_authgrp = ls_auth_key-augrp_fistl
                  fm_fipex_authgrp  = ls_auth_key-augrp_fipex
                  iv_user           = sy-uname
                IMPORTING
                  ex_subrc          = lv_subrc.

          ENDCASE.

          IF lv_subrc = 0.
            INSERT ls_auth_key INTO TABLE lt_auth_ok.
          ENDIF.
        ENDLOOP.

        DATA(lv_idx) = lines( lt_items ).
        WHILE lv_idx > 0.
          ASSIGN lt_items[ lv_idx ] TO <ls_item>.
          IF sy-subrc NE 0.
            lv_idx = lv_idx - 1.
            CONTINUE.
          ENDIF.
          READ TABLE lt_item2auth INTO ls_item2auth
               WITH TABLE KEY bukrs = <ls_item>-bukrs
                               belnr = <ls_item>-belnr
                               gjahr = <ls_item>-gjahr
                               buzei = <ls_item>-buzei.
          IF sy-subrc <> 0.
            DELETE lt_items INDEX lv_idx.
          ELSE.
            READ TABLE lt_auth_ok WITH TABLE KEY
                 augrp_fistl = ls_item2auth-augrp_fistl
                 augrp_fipex = ls_item2auth-augrp_fipex
                 fipex       = ls_item2auth-fipex
                 TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              DELETE lt_items INDEX lv_idx.
            ENDIF.
          ENDIF.
          lv_idx = lv_idx - 1.
        ENDWHILE.

        ct_items[] = lt_items[].

        IF lines( ct_items ) = 0.

          IF sy-tcode IS NOT INITIAL.
            MESSAGE 'Es konnten keine Posten ermittelt werden' TYPE 'S' DISPLAY LIKE 'E'.
            LEAVE TO TRANSACTION sy-tcode.
          ELSE.
            MESSAGE 'Es konnten keine Posten ermittelt werden' TYPE 'E'.
          ENDIF.
        ENDIF.

      ENDMETHOD.
ENDCLASS.
