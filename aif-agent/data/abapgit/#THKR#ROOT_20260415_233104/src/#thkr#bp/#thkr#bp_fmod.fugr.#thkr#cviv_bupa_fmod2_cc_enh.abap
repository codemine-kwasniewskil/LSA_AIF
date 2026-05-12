function /THKR/CVIV_BUPA_FMOD2_CC_ENH.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FLDGR) TYPE  TBZ3W-FLDGR
*"     REFERENCE(IN_STATUS) TYPE  BUS000FLDS-FLDSTAT
*"  EXPORTING
*"     REFERENCE(OUT_STATUS) TYPE  BUS000FLDS-FLDSTAT
*"----------------------------------------------------------------------
 "Kopie von FuBa CVIV_BUPA_EVENT_FMOD2_CC_ENH

  data:
    lt_lfb1                     type table of lfb1,
    lt_lfa1                     type table of lfa1,
    lt_compcodes                type cvis_cc_info_overview_t,

    ls_lfb1                     type lfb1,
    ls_lfa1                     type lfa1,
    ls_error                    type cvis_error,
    ls_vend_auth_suppress_flags type cvi_cl_process_info=>ty_supp_auth_suppress_context,
    ls_lfa1_old                 type lfa1,

    lv_activity                 type activ_auth,
    lv_in_status                type bu_fldstat,
    lv_vendor_status            type cvi_optional_status,
    lv_compcode                 type bukrs,

    lcl_ka_bp_vendor            type ref to cvi_ka_bp_vendor.

  field-symbols:
    <cc_info>          like line of lt_compcodes.

  " call default FMOD2 function module for vendor company code data in transaction BP first
  call function 'CVIV_BUPA_EVENT_FMOD2_CC'
    exporting
      fldgr      = fldgr
      in_status  = in_status
    importing
      out_status = out_status.
  " use result as new "in_status" for further processing
  lv_in_status = out_status.

  if cvi_bdt_adapter=>get_current_bp( ) is not initial.
    lv_vendor_status = cvi_bdt_adapter=>get_opt_vendor_status( ).
  endif.

  if lv_vendor_status <> cvi_bdt_adapter=>cv_status_not_relevant and
     lv_vendor_status <> cvi_bdt_adapter=>cv_status_optional.

    out_status = lv_in_status.

    lv_compcode = cvi_bdt_adapter=>get_current_company_code( ).
    if lv_compcode is not initial.
      lt_compcodes = cvi_bdt_adapter=>get_company_codes( ).
      read table lt_compcodes assigning <cc_info>
        with key company_code = lv_compcode.

      if <cc_info> is not assigned or <cc_info>-vendor_status is not initial.
        if cvi_bdt_adapter=>get_activity( ) <> '03'.
          cvi_bdt_adapter=>authority_check_vend_comp_code(
            exporting
              iv_actvt        = '02'
              iv_company_code = lv_compcode
            importing
              es_error = ls_error ).
        endif.
      endif.
    endif.

    case fldgr.
      when '3375' or '3359' or '3558'. "LFB1-SPERR, LFB1-NODEL, LFB1-LOEVM
        if fldgr = '3375'.
          lv_activity = '05'.
            out_status = lv_in_status.
        else.
          out_status = lv_in_status.
          lv_activity = '06'.
        endif.

        "F_LFA1_BUK
        cvi_bdt_authorization_services=>buffered_auth_check_vend_cc(
          exporting
            i_activity = lv_activity
            i_bukrs    = lv_compcode
          importing
            e_error    = ls_error ).
        if ls_error-is_error is not initial and lv_in_status <> fstat_suppressed.
          out_status = fstat_display.
          return.
        endif.

        "F_LFA1_APP / F_LFA1_GRP
        fsbp_memory_factory=>get_instance(
                i_partner    = cvi_bdt_adapter=>get_current_bp( )
                i_table_name = table_name_lfa1
              )->get_data_new( importing e_data_new = lt_lfa1 ).

        read table lt_lfa1 into ls_lfa1 with key lifnr = cvi_bdt_adapter=>get_current_vendor( ).

        ls_vend_auth_suppress_flags-skip_begru_check = true.
        ls_vend_auth_suppress_flags-skip_gen_check   = true.
        ls_vend_auth_suppress_flags-skip_tcode_check = true.

        cvi_bdt_authorization_services=>buffered_auth_check_vend_lfa1(
          exporting
            i_lfa1_new                 = ls_lfa1
            i_lfa1_old                 = ls_lfa1_old
            i_activity                 = lv_activity
            i_appkz                    = 'F'
            i_vend_auth_suppress_flags = ls_vend_auth_suppress_flags
          importing
            e_error                    = ls_error ).
        if ls_error-is_error is not initial and lv_in_status <> fstat_suppressed.
          out_status = fstat_display.
          return.
        endif.

        "F_LFA1_BEK
        fsbp_memory_factory=>get_instance(
                i_partner    = cvi_bdt_adapter=>get_current_bp( )
                i_table_name = table_name_lfb1
              )->get_data_new( importing e_data_new = lt_lfb1 ).

        read table lt_lfb1 into ls_lfb1 with key lifnr = cvi_bdt_adapter=>get_current_vendor( ) bukrs = lv_compcode.

        if ls_lfb1-begru is not initial.
          cvi_bdt_authorization_services=>buf_auth_check_vend_begru(
            exporting
              i_activity = lv_activity
              i_lifnr    = ls_lfa1-lifnr
              i_begru    = ls_lfb1-begru
            importing
              e_error    = ls_error ).
          if ls_error-is_error is not initial and lv_in_status <> fstat_suppressed.
            out_status = fstat_display.
            return.
          endif.
        endif.

      when '3349'."LFA1-SPERR
        out_status = lv_in_status.

        if out_status = fstat_suppressed or out_status = fstat_display.
          return.
        endif.

        "F_LFA1_GEN / F_LFA1_APP / F_LFA1_GRP / F_LFA1_BEK
        fsbp_memory_factory=>get_instance(
                i_partner    = cvi_bdt_adapter=>get_current_bp( )
                i_table_name = table_name_lfa1
              )->get_data_new( importing e_data_new = lt_lfa1 ).

        read table lt_lfa1 into ls_lfa1 with key lifnr = cvi_bdt_adapter=>get_current_vendor( ).

        ls_vend_auth_suppress_flags-skip_tcode_check = true.

        cvi_bdt_authorization_services=>buffered_auth_check_vend_lfa1(
          exporting
            i_lfa1_new                 = ls_lfa1
            i_lfa1_old                 = ls_lfa1_old
            i_activity                 = '05'
            i_appkz                    = 'F'
            i_vend_auth_suppress_flags = ls_vend_auth_suppress_flags
          importing
            e_error                    = ls_error ).
        if ls_error-is_error is not initial and lv_in_status <> fstat_suppressed.
          out_status = fstat_display.
          return.
        endif.

      when others.
        out_status = lv_in_status.

    endcase.
  endif.

endfunction.
