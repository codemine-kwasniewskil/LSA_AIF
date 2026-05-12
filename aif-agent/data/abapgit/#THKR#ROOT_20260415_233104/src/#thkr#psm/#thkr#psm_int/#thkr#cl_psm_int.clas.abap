class /THKR/CL_PSM_INT definition
  public
  final
  create private .

public section.

  methods CREATE_BELEG
    importing
      !I_BELEG_CREATE type /THKR/DTO_CREATE_PSM_BELEG
    returning
      value(R_DTO) type /THKR/DTO_PSM_BELEG_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_FB
    importing
      !I_FB_CREATE type /THKR/DTO_CREATE_PSM_FB
    returning
      value(R_DTO) type /THKR/DTO_PSM_FB_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_FKZ
    importing
      !I_DTO_PSM_FKZ_CREATE type /THKR/DTO_CREATE_PSM_FKZ
    returning
      value(R_FKZ) type /THKR/DTO_PSM_FKZ_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_FO
    importing
      !I_FO_CREATE type /THKR/DTO_CREATE_PSM_FO
    returning
      value(R_DTO) type /THKR/DTO_PSM_FO_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_VE
    importing
      !I_VE_CREATE type /THKR/DTO_CREATE_PSM_VE
    returning
      value(R_DTO) type /THKR/DTO_PSM_VE_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods UPDATE_PSM_FP_LONGTEXT
    importing
      !IS_FP_KEY type /THKR/S_PSM_FP_KEY
      !IV_TEXT_ID type TDID
      !IV_TEXT type STRING
      !IV_LANGU type SYLANGU default SY-LANGU .
  methods UPDATE_PSM_FP
    importing
      !I_DTO_PSM_FP_UPDATE type /THKR/DTO_UPDATE_PSM_FP
    exporting
      value(E_FIPOS) type /THKR/DTO_PSM_FP_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods UPDATE_PSM_FO
    importing
      !I_FO_UPDATE type /THKR/DTO_CREATE_PSM_FO
    returning
      value(R_DTO) type /THKR/DTO_PSM_FO_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods UPDATE_PSM_FB
    importing
      !I_FB_UPDATE type /THKR/DTO_CREATE_PSM_FB
    returning
      value(R_DTO) type /THKR/DTO_PSM_FB_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_FP
    importing
      !I_DTO_PSM_FP_CREATE type /THKR/DTO_CREATE_PSM_FP
    exporting
      value(E_FIPOS) type /THKR/DTO_PSM_FP_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_PSM_TG
    importing
      !I_DTO_PSM_TG_CREATE type /THKR/DTO_CREATE_PSM_TG
    exporting
      value(E_PSM_TG) type /THKR/DTO_PSM_TG_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods GET_DTO_PSM_FB
    importing
      !I_FKBER_ID type /THKR/DTO_GET_PSM_FB
    returning
      value(R_DTO) type /THKR/DTO_PSM_FB
    raising
      /THKR/CX_PSM_INT_FI .
  methods GET_DTO_PSM_FKZ
    importing
      !I_DTO_PSM_FKZ type /THKR/DTO_GET_PSM_FKZ
    returning
      value(R_DTO) type /THKR/DTO_PSM_FKZ
    raising
      /THKR/CX_PSM_INT_FI .
  methods GET_DTO_PSM_FO
    importing
      !I_FOND_ID type /THKR/DTO_GET_PSM_FO
    returning
      value(R_DTO) type /THKR/DTO_PSM_FO
    raising
      /THKR/CX_PSM_INT_FI .
  methods GET_DTO_PSM_VE
    importing
      !I_VERMERK_ID type /THKR/DTO_GET_PSM_VE
    returning
      value(R_DTO) type /THKR/DTO_PSM_VE .
  methods GET_DTO_PSM_FP
    importing
      !I_DTO_PSM_FP type /THKR/DTO_GET_PSM_FP
    returning
      value(R_DTO) type /THKR/DTO_PSM_FP .
  methods GET_DTO_PSM_TG
    importing
      !I_DTO_PSM_TG type /THKR/DTO_GET_PSM_TG
    returning
      value(R_DTO) type /THKR/DTO_PSM_TG .
  class-methods GET_INSTANCE
    exporting
      !E_INSTANCE type ref to /THKR/CL_PSM_INT
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_INT .
  methods GET_DTO_BBELEG
    importing
      !I_DTO_PSM_BELEG type /THKR/DTO_GET_PSM_BELEG
    returning
      value(R_DTO) type /THKR/DTO_PSM_BELEG_KEY .
protected section.
private section.

  constants MC_BBELEG_BUDTYPE type BUKU_BUDTYPE value 'HH' ##NO_TEXT.
  constants MC_BBELEG_VALTYPE type BUKU_VALTYPE value 'B1' ##NO_TEXT.
  constants MC_BBELEG_DKEY type BUKU_SPRED value '1' ##NO_TEXT.
  class-data INSTANCE type ref to /THKR/CL_PSM_INT .
  constants MC_DOCTYPE_JAHR type BUED_DOCTYPE value 'JAHR' ##NO_TEXT.
  constants MC_BBELEG_DOCSTATE type BUED_DOCSTATE value '1' ##NO_TEXT.
  constants MC_BBELEG_PROCESS type BUKU_PROCESS_UI value 'ENTR' ##NO_TEXT.
  constants MC_BBELEG_MEASURE type FM_MEASURE value '9999' ##NO_TEXT.
  constants MC_BBELEG_FUNDSCTR type FISTL value '0000000000' ##NO_TEXT.
  constants MC_BBELEG_ADD_PROCESS type BUKU_PROCESS_UI value 'SUPL' ##NO_TEXT.
ENDCLASS.



CLASS /THKR/CL_PSM_INT IMPLEMENTATION.


  METHOD create_beleg.
    DATA: ls_header	TYPE /thkr/s_budget_beleg_header,
          lt_items  TYPE /thkr/t_budget_beleg_item.

    ls_header-fm_area         = i_beleg_create-fikrs.
    ls_header-version         = i_beleg_create-version.
    ls_header-docdate         = sy-datum.
    ls_header-doctype         = mc_doctype_jahr.
    ls_header-docstate        = mc_bbeleg_docstate." '1'.
    CASE i_beleg_create-version(2).
      WHEN 'NT'.
        ls_header-process         = mc_bbeleg_add_process. "SUPL'.
      WHEN OTHERS.
        ls_header-process         = mc_bbeleg_process. "ENTR'.
    ENDCASE.


    LOOP AT i_beleg_create-ansatz INTO DATA(item).
      APPEND INITIAL LINE TO lt_items ASSIGNING FIELD-SYMBOL(<item>).
      <item>-item_num   = lines( lt_items ).
      <item>-fisc_year  = item-gjahr.
      <item>-cash_year  = item-cyear.
      <item>-budcat     = i_beleg_create-budcat.
      CASE i_beleg_create-version(2).
        WHEN 'NT'.
          <item>-budtype = i_beleg_create-version(2) && '0' && i_beleg_create-version+2(1).
        WHEN OTHERS.
          <item>-budtype    = i_beleg_create-version.
      ENDCASE.
      <item>-fund       = i_beleg_create-fincode.
      <item>-cmmt_item  = i_beleg_create-fipex.
      <item>-func_area  = i_beleg_create-fkber.
      <item>-total_amount = item-ansatz.
      <item>-trans_curr   = item-currency.
      <item>-valtype      = mc_bbeleg_valtype.
      <item>-distkey      = mc_bbeleg_dkey.

      <item>-measure   = mc_bbeleg_measure.
      <item>-funds_ctr = i_beleg_create-fictr. "mc_bbeleg_fundsctr.
    ENDLOOP.

    CHECK lt_items IS NOT INITIAL.

    r_dto = /thkr/cl_fm_bl_appl=>create_bbeleg( is_beleg       = ls_header
                                                it_beleg_items = lt_items ).
    IF r_dto IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e009 WITH i_beleg_create-fincode i_beleg_create-fkber i_beleg_create-fipex.
    ENDIF.
  ENDMETHOD.


  METHOD create_psm_fb.

    DATA(lo_psm_fb) = /thkr/cl_psm_fb_appl=>get_instance( ).
    CHECK lo_psm_fb IS BOUND.

    IF lo_psm_fb->check_existance( i_fb_create-fkber ) = abap_false.
      r_dto = lo_psm_fb->create_fkber( i_fb_create ).
    ELSE.
      r_dto = lo_psm_fb->update_fkber( i_fb_create ).
    ENDIF.
    IF r_dto IS INITIAL.
      " Fehler beim Erstellen des Funktionsbereichs &1
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e017 WITH i_fb_create-fkber.
    ENDIF.
  ENDMETHOD.


  METHOD create_psm_fkz.
    DATA(lo_psm_fkz) = /thkr/cl_psm_fkz_appl=>get_instance( CORRESPONDING #( i_dto_psm_fkz_create ) ).
    CHECK lo_psm_fkz IS BOUND.

    IF lo_psm_fkz->get_fkz_data( ) IS INITIAL.
      r_fkz = CORRESPONDING #( lo_psm_fkz->create_fkz( is_data = CORRESPONDING #( i_dto_psm_fkz_create ) ) ).
      IF r_fkz IS INITIAL.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e020 WITH i_dto_psm_fkz_create-fikrs i_dto_psm_fkz_create-gjahr i_dto_psm_fkz_create-fkz .
      ENDIF.
    ELSE.
      " update is not required due to business logic
    ENDIF.
  ENDMETHOD.


  METHOD create_psm_fo.
    DATA(lo_psm_fo) = /thkr/cl_psm_fo_appl=>get_instance( ).
    CHECK lo_psm_fo IS BOUND.

    IF lo_psm_fo->check_existance( CORRESPONDING #( i_fo_create ) ) = abap_false.
      r_dto = CORRESPONDING #( lo_psm_fo->create_fond( i_fo_create ) ).
    ELSE.
      r_dto = CORRESPONDING #( lo_psm_fo->update_fond( i_fo_create ) ).
    ENDIF.
    IF r_dto IS INITIAL.
      " Fehler beim Erstellen einer Fond &1 &2
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e006 WITH i_fo_create-fikrs i_fo_create-fincode.
    ENDIF.
  ENDMETHOD.


  METHOD create_psm_fp.
    DATA(lo_psm_fp) = /thkr/cl_psm_fp_appl=>get_instance( fikrs = i_dto_psm_fp_create-fikrs
                                                          gjahr = i_dto_psm_fp_create-gjahr
                                                          fipex = i_dto_psm_fp_create-fipex ).
    CHECK lo_psm_fp IS BOUND.
    e_fipos = CORRESPONDING #( lo_psm_fp->create_fipos( i_fp_data = CORRESPONDING #( i_dto_psm_fp_create )
                                                        i_fp_text = CORRESPONDING #( i_dto_psm_fp_create ) ) ).
    IF e_fipos IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e002 WITH i_dto_psm_fp_create-fikrs i_dto_psm_fp_create-gjahr i_dto_psm_fp_create-fipex.
    ENDIF.
  ENDMETHOD.


  METHOD create_psm_tg.
    DATA(lo_psm_tg) = /thkr/cl_psm_tg_appl=>get_instance(  CORRESPONDING #( i_dto_psm_tg_create ) ).
    CHECK lo_psm_tg IS BOUND.

    e_psm_tg = CORRESPONDING #( lo_psm_tg->create_tg( is_data = CORRESPONDING #( i_dto_psm_tg_create ) ) ).
    IF e_psm_tg IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e021 WITH i_dto_psm_tg_create-fikrs i_dto_psm_tg_create-gjahr i_dto_psm_tg_create-titelgrp.
    ENDIF.
  ENDMETHOD.


  METHOD create_psm_ve.
    DATA(lo_psm_ve) = /thkr/cl_psm_ve_appl=>get_instance( ).
    CHECK lo_psm_ve IS BOUND.

    r_dto = CORRESPONDING #( lo_psm_ve->create_vermerk( i_ve_create ) ).
    IF r_dto IS INITIAL.
      " Fehler beim Erstellen einer Vermerk
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e030 WITH i_ve_create-applic i_ve_create-txtcat i_ve_create-txttempl.
    ENDIF.
  ENDMETHOD.


  METHOD get_dto_bbeleg.
    r_dto = /thkr/cl_fm_bl_appl=>get_bbeleg_data( is_beleg = CORRESPONDING #( i_dto_psm_beleg ) ).
  ENDMETHOD.


  METHOD get_dto_psm_fb.
    DATA(lo_psm_fb) = /thkr/cl_psm_fb_appl=>get_instance( ).
    CHECK lo_psm_fb IS BOUND.
    r_dto = CORRESPONDING #( lo_psm_fb->get_fkber_data( EXPORTING i_fkber_id = i_fkber_id
                                                                  i_flg_text = abap_true ) ).
    IF r_dto IS INITIAL.
*      " Der Funktionsbereich &1 ist nicht vorhanden
*      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e016 WITH i_fkber_id-fkber.
    ENDIF.
  ENDMETHOD.


  METHOD get_dto_psm_fkz.
    DATA(lo_psm_fkz) = /thkr/cl_psm_fkz_appl=>get_instance( fkz = CORRESPONDING #( i_dto_psm_fkz ) ).
    CHECK lo_psm_fkz IS BOUND.
    r_dto = CORRESPONDING #( lo_psm_fkz->get_fkz_data( ) ).
*    IF r_dto IS INITIAL.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e018 WITH i_dto_psm_fkz-fikrs i_dto_psm_fkz-gjahr i_dto_psm_fkz-fkz.
*    ENDIF.
  ENDMETHOD.


  METHOD get_dto_psm_fo.
    DATA(lo_psm_fo) = /thkr/cl_psm_fo_appl=>get_instance( ).
    CHECK lo_psm_fo IS BOUND.
    r_dto = CORRESPONDING #( lo_psm_fo->get_fond_data( EXPORTING i_fond_id  = i_fond_id
                                                                 i_flg_text = abap_true ) ).
    IF r_dto IS INITIAL.
*      " Der Fond &1 &2 ist nicht vorhanden
*      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e005 WITH i_fond_id-fikrs i_fond_id-fincode.
    ENDIF.
  ENDMETHOD.


  METHOD get_dto_psm_fp.
    DATA: ls_fp_text TYPE /thkr/s_psm_fp_text.

    DATA(lo_psm_fp) = /thkr/cl_psm_fp_appl=>get_instance( fikrs = i_dto_psm_fp-fikrs gjahr = i_dto_psm_fp-gjahr fipex = i_dto_psm_fp-fipex ).
    CHECK lo_psm_fp IS BOUND.
    r_dto = CORRESPONDING #( lo_psm_fp->get_fipos_data( EXPORTING i_flg_text = abap_true
                                                        IMPORTING e_fp_text  = ls_fp_text ) ).
    IF r_dto IS INITIAL.
      EXIT.
      "RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e001 WITH i_dto_psm_fp-fikrs i_dto_psm_fp-gjahr i_dto_psm_fp-fipex.
    ELSEIF ls_fp_text IS NOT INITIAL.
      MOVE-CORRESPONDING ls_fp_text TO r_dto.
    ENDIF.
  ENDMETHOD.


  METHOD get_dto_psm_tg.
    DATA(lo_psm_tg) = /thkr/cl_psm_tg_appl=>get_instance( CORRESPONDING #( i_dto_psm_tg ) ).
    CHECK lo_psm_tg IS BOUND.
    r_dto = CORRESPONDING #( lo_psm_tg->get_tg_data( ) ).
*    IF r_dto IS INITIAL.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e019 WITH i_dto_psm_tg-fikrs i_dto_psm_tg-gjahr i_dto_psm_tg-titelgrp.
*    ENDIF.
  ENDMETHOD.


  METHOD get_dto_psm_ve.
    DATA(lo_psm_ve) = /thkr/cl_psm_ve_appl=>get_instance( ).
    CHECK lo_psm_ve IS BOUND.
    r_dto = CORRESPONDING #( lo_psm_ve->get_vermerk_data( EXPORTING i_vermerk_id  = i_vermerk_id
                                                                    i_flg_text = abap_true ) ).
    IF r_dto IS INITIAL.
*      " Der Fond &1 &2 ist nicht vorhanden
*      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e005 WITH i_fond_id-fikrs i_fond_id-fincode.
    ENDIF.
  ENDMETHOD.


  METHOD GET_INSTANCE.

    IF instance IS INITIAL.

      CREATE OBJECT instance.

    ENDIF.

    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.


  METHOD update_psm_fb.
    DATA(lo_psm_fb) = /thkr/cl_psm_fb_appl=>get_instance( ).
    CHECK lo_psm_fb IS BOUND.

    r_dto = lo_psm_fb->update_fkber( i_fb_update ).
    IF r_dto IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
    ENDIF.
  ENDMETHOD.


  METHOD update_psm_fo.
    DATA(lo_psm_fo) = /thkr/cl_psm_fo_appl=>get_instance( ).
    CHECK lo_psm_fo IS BOUND.

    r_dto = CORRESPONDING #( lo_psm_fo->update_fond( i_fo_update ) ).
    IF r_dto IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
    ENDIF.
  ENDMETHOD.


  METHOD update_psm_fp.
    DATA(lo_psm_fp) = /thkr/cl_psm_fp_appl=>get_instance( fikrs = i_dto_psm_fp_update-fikrs
                                                          gjahr = i_dto_psm_fp_update-gjahr
                                                          fipex = i_dto_psm_fp_update-fipex ).
    CHECK lo_psm_fp IS BOUND.
    e_fipos = CORRESPONDING #( lo_psm_fp->update_fipos( i_fp_data = CORRESPONDING #( i_dto_psm_fp_update )
                                                        i_fp_text = CORRESPONDING #( i_dto_psm_fp_update ) ) ).
    IF e_fipos IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e012 WITH i_dto_psm_fp_update-fikrs i_dto_psm_fp_update-gjahr i_dto_psm_fp_update-fipex.
    ENDIF.
  ENDMETHOD.


  METHOD update_psm_fp_longtext.
    DATA(lo_psm_fp) = /thkr/cl_psm_fp_appl=>get_instance( fikrs = is_fp_key-fikrs
                                                          gjahr = is_fp_key-gjahr
                                                          fipex = is_fp_key-fipex ).
    CHECK lo_psm_fp IS BOUND.
    lo_psm_fp->update_longtext( tdid  = iv_text_id
                                text  = iv_text
                                spras = iv_langu ).
  ENDMETHOD.
ENDCLASS.
