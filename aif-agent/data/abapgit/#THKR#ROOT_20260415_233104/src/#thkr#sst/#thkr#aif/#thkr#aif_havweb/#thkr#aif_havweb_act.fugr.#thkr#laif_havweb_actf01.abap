*----------------------------------------------------------------------*
***INCLUDE /THKR/LAIF_HAVWEB_ACTF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form fp_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM fp_process  USING    io_int_appl TYPE REF TO /thkr/cl_psm_int
                          is_fp       TYPE /thkr/dto_create_psm_fp
                 CHANGING ct_return TYPE bapiret2_t.
  REFRESH ct_return.
  IF io_int_appl->get_dto_psm_fp( VALUE #( fikrs = is_fp-fikrs gjahr = is_fp-gjahr fipex = is_fp-fipex ) ) IS INITIAL.
    " Finanzposition Creation
    TRY.
        io_int_appl->create_psm_fp( is_fp ).
        MESSAGE s028(/thkr/psm_int_fi) WITH is_fp-fikrs is_fp-gjahr is_fp-fipex INTO DATA(lv_message).
      CATCH /thkr/cx_psm_int_fi INTO DATA(lo_exp).
        /thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lo_exp CHANGING messages = ct_return ).
        IF lo_exp->if_t100_message~t100key-msgid <> '/THKR/PSM_INT_FI' OR
           lo_exp->if_t100_message~t100key-msgno <> '002'.
          MESSAGE e002(/thkr/psm_int_fi) WITH is_fp-fikrs is_fp-gjahr is_fp-fipex INTO lv_message.
          /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
        ENDIF.
    ENDTRY.
  ELSE.
    TRY.
        io_int_appl->update_psm_fp( CORRESPONDING #( is_fp ) ).
        MESSAGE s011(/thkr/psm_int_fi) WITH is_fp-fikrs is_fp-gjahr is_fp-fipex INTO lv_message.
      CATCH /thkr/cx_psm_int_fi INTO lo_exp.
        /thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lo_exp CHANGING messages = ct_return ).
        IF lo_exp->if_t100_message~t100key-msgid <> '/THKR/PSM_INT_FI' OR
           lo_exp->if_t100_message~t100key-msgno <> '012'.
          MESSAGE e002(/thkr/psm_int_fi) WITH is_fp-fikrs is_fp-gjahr is_fp-fipex INTO lv_message.
          /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
        ENDIF.
    ENDTRY.
  ENDIF.
  /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fo_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM fo_process  USING    io_int_appl TYPE REF TO /thkr/cl_psm_int
                          is_fo       TYPE /thkr/dto_create_psm_fo
                          iv_gjahr    TYPE gjahr
                 CHANGING ct_return   TYPE bapiret2_t.
  REFRESH ct_return.
  TRY.
      IF io_int_appl->get_dto_psm_fo( i_fond_id = VALUE #( fikrs = is_fo-fikrs fincode = is_fo-fincode gjahr_fincode = iv_gjahr ) ) IS INITIAL.
        " Fond Creation
        io_int_appl->create_psm_fo( is_fo ).
        MESSAGE s024(/thkr/psm_int_fi) WITH is_fo-fikrs is_fo-fincode INTO DATA(lv_message).
      ELSE.
        " Fond Update
        io_int_appl->update_psm_fo( CORRESPONDING #( is_fo ) ).
        MESSAGE s013(/thkr/psm_int_fi) WITH is_fo-fikrs is_fo-fincode INTO lv_message.
      ENDIF.
      /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
**
    CATCH /thkr/cx_psm_int_fi INTO DATA(lo_exp).
      /thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lo_exp CHANGING messages = ct_return ).
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form fb_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM fb_process  USING    io_int_appl TYPE REF TO /thkr/cl_psm_int
                          is_fb       TYPE /thkr/dto_create_psm_fb
                          iv_gjahr    TYPE gjahr
                 CHANGING ct_return   TYPE bapiret2_t.
  REFRESH ct_return.
  TRY.
      IF io_int_appl->get_dto_psm_fb( i_fkber_id = VALUE #( fkber = is_fb-fkber gjahr_fkber = iv_gjahr ) ) IS INITIAL.
        " Funktionsbereich(Kapitel) Creation
        io_int_appl->create_psm_fb( is_fb ).
        MESSAGE s025(/thkr/psm_int_fi) WITH is_fb-fkber INTO DATA(lv_message).
      ELSE.
        " Funktionsbereich(Kapitel) Update
        io_int_appl->update_psm_fb( CORRESPONDING #( is_fb ) ).
        MESSAGE s042(/thkr/psm_int_fi) WITH is_fb-fkber INTO lv_message.
      ENDIF.
      /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
    CATCH /thkr/cx_psm_int_fi INTO DATA(lo_exp).
      /thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lo_exp CHANGING messages = ct_return ).
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form tg_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM tg_process  USING    io_int_appl TYPE REF TO /thkr/cl_psm_int
                          is_tg       TYPE /thkr/dto_create_psm_tg
                 CHANGING ct_return   TYPE bapiret2_t.
  REFRESH ct_return.
  TRY.
      IF io_int_appl->get_dto_psm_tg( VALUE #( fikrs = is_tg-fikrs gjahr = is_tg-gjahr fkber = is_tg-fkber titelgrp = is_tg-titelgrp ) ) IS INITIAL.
        " TitelGroup Creation
        io_int_appl->create_psm_tg( is_tg ).
        MESSAGE s026(/thkr/psm_int_fi) WITH is_tg-fikrs is_tg-gjahr is_tg-fkber is_tg-titelgrp INTO DATA(lv_message).
      ELSE.
        MESSAGE w023(/thkr/psm_int_fi) WITH is_tg-fikrs is_tg-gjahr is_tg-fkber is_tg-titelgrp INTO lv_message.
      ENDIF.
      /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
    CATCH /thkr/cx_psm_int_fi INTO DATA(lo_exp).
      /thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lo_exp CHANGING messages = ct_return ).
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ve_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ve_process  USING    io_int_appl TYPE REF TO /thkr/cl_psm_int
                          is_ve       TYPE /thkr/dto_create_psm_ve
                 CHANGING ct_return TYPE bapiret2_t.
  REFRESH ct_return.
  CHECK is_ve-txtcat IS NOT INITIAL.
  IF io_int_appl->get_dto_psm_ve( VALUE #( applic = is_ve-applic txtcat = is_ve-txtcat txttempl = is_ve-txttempl ) ) IS INITIAL.
    " Vermerke Creation
    TRY.
        io_int_appl->create_psm_ve( is_ve ).
        MESSAGE s031(/thkr/psm_int_fi) WITH is_ve-applic is_ve-txtcat is_ve-text INTO DATA(lv_message).
        /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
      CATCH /thkr/cx_psm_int_fi INTO DATA(lo_exp).
        /thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lo_exp CHANGING messages = ct_return ).
    ENDTRY.
  ELSE.
    MESSAGE w032(/thkr/psm_int_fi) WITH is_ve-applic is_ve-txtcat is_ve-text INTO lv_message.
    /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
  ENDIF.
ENDFORM.

FORM fp_longtext_process USING    io_int_appl TYPE REF TO /thkr/cl_psm_int
                                  is_fp       TYPE /thkr/dto_create_psm_fp
                                  is_ve       TYPE /thkr/dto_create_psm_ve
                         CHANGING ct_return TYPE bapiret2_t.
  REFRESH ct_return.
  CHECK is_ve-textart IS NOT INITIAL.
  TRY.
      io_int_appl->update_psm_fp_longtext( is_fp_key  = CORRESPONDING #( is_fp )
                                           iv_text_id = is_ve-textart
                                           iv_text    = is_ve-longtext
                                           iv_langu   = is_fp-spras ).
      "MESSAGE s031(/thkr/psm_int_fi) WITH is_ve-applic is_ve-txtcat is_ve-text INTO DATA(lv_message).
      "/thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
    CATCH /thkr/cx_psm_int_fi INTO DATA(lo_exp).
      "/thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lo_exp CHANGING messages = ct_return ).
  ENDTRY.


ENDFORM.

FORM beleg_process  USING io_int_appl TYPE REF TO /thkr/cl_psm_int
                          is_beleg    TYPE /thkr/dto_create_psm_beleg
                          iv_mode     TYPE char6
                 CHANGING ct_return TYPE bapiret2_t.
  DATA: lt_gjahr TYPE RANGE OF gjahr.
  REFRESH ct_return.
  DATA(ls_beleg) = is_beleg.
  TRY.
      IF iv_mode(1) = 'D'.
        lt_gjahr = VALUE #( ( sign = 'I' option = 'EQ' low = is_beleg-gjahr  )
                            ( sign = 'I' option = 'EQ' low = ( is_beleg-gjahr + 1 ) ) ).
      ELSE.
        lt_gjahr = VALUE #( ( sign = 'I' option = 'EQ' low = is_beleg-gjahr  ) ).
      ENDIF.
      DELETE ls_beleg-ansatz WHERE gjahr NOT IN lt_gjahr OR
                                   ansatz IS INITIAL.
      CHECK ls_beleg-ansatz IS NOT INITIAL.
      IF ls_beleg-version IS INITIAL.
        ls_beleg-version = /thkr/cl_fm_bl_appl=>get_bbeleg_version( iv_fikrs = ls_beleg-fikrs iv_gjahr = ls_beleg-gjahr iv_fipex = ls_beleg-fipex iv_budcat = ls_beleg-budcat ).
      ENDIF.
      DATA(ls_beleg_old) = io_int_appl->get_dto_bbeleg( CORRESPONDING #( is_beleg ) ).
      IF ls_beleg_old IS INITIAL OR ls_beleg_old-revstate = '2' OR ls_beleg_old-revstate = '1'.
        DATA(ls_beleg_new) = io_int_appl->create_beleg( ls_beleg ).
        CASE ls_beleg-budcat.
          WHEN '9F'.
            MESSAGE s035(/thkr/psm_int_fi) WITH ls_beleg_new-fm_area ls_beleg_new-docyear ls_beleg_new-docnr INTO DATA(lv_message).
          WHEN '9G'.
            MESSAGE s036(/thkr/psm_int_fi) WITH ls_beleg_new-fm_area ls_beleg_new-docyear ls_beleg_new-docnr INTO lv_message.
        ENDCASE.
      ELSE.
        CASE ls_beleg-budcat.
          WHEN '9F'.
            MESSAGE w037(/thkr/psm_int_fi) WITH |{ ls_beleg_old-fm_area }/{ ls_beleg_old-docyear }/{ ls_beleg_old-docnr }|
                                                |{ is_beleg-fikrs }/{ is_beleg-gjahr }/{ is_beleg-fipex }| INTO lv_message.
          WHEN '9G'.
            MESSAGE w038(/thkr/psm_int_fi) WITH |{ ls_beleg_old-fm_area }/{ ls_beleg_old-docyear }/{ ls_beleg_old-docnr }|
                                                |{ is_beleg-fikrs }/{ is_beleg-gjahr }/{ is_beleg-fipex }| INTO lv_message.
        ENDCASE.
      ENDIF.
      /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
    CATCH /thkr/cx_psm_int_fi INTO DATA(lo_exp).
      IF lo_exp->if_t100_message~t100key-msgid <> '/THKR/PSM_INT_FI' OR
         lo_exp->if_t100_message~t100key-msgno <> '009'.
        /thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lo_exp CHANGING messages = ct_return ).
      ENDIF.
      MESSAGE e009(/thkr/psm_int_fi) WITH |{ is_beleg-fikrs }/{ is_beleg-gjahr }/{ is_beleg-fipex }| INTO lv_message.
      /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = ct_return ).
  ENDTRY.
ENDFORM.
