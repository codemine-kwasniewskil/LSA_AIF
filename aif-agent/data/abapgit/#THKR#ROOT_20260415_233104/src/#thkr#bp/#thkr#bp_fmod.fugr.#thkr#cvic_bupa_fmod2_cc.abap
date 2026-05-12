function /THKR/CVIC_BUPA_FMOD2_CC.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FLDGR) TYPE  TBZ3W-FLDGR
*"     REFERENCE(IN_STATUS) TYPE  BUS000FLDS-FLDSTAT
*"  EXPORTING
*"     REFERENCE(OUT_STATUS) TYPE  BUS000FLDS-FLDSTAT
*"--------------------------------------------------------------------
  "Kopie von FuBa CVIC_BUPA_EVENT_FMOD2_CC

  data:
    ls_knb1                     type knb1,
    lt_knb1                     type table of knb1,
    ls_kna1                     type kna1,
    lt_kna1                     type table of kna1,
    ls_error                    type cvis_message,
    lcl_ka_bp_customer          type ref to cvi_ka_bp_customer,
    ls_t001                     type t001,
    ls_errors                   type cvis_error,
    lv_authorized_for_activity  type char2,
    lv_customer_status          type cvi_optional_status,
    lt_compcodes                type cvis_cc_info_overview_t,
    lv_compcode                 type bukrs,
    ls_cust_auth_suppress_flags type cvi_cl_process_info=>ty_cust_auth_suppress_context,
    ls_kna1_old                 type kna1.

  field-symbols:
    <cc_info>          like line of lt_compcodes.

  " With new authorization concept for cust/vend data in transaction BP (note 3009859)
  " F_KNA1_APP authorization is not checked any more in AUTH1 event which means that
  " transaction BP is not switched to display or hide mode in case user has no authorization
  " therefore we need to check here if user is authorized to maintain/display company code
  " data and set the field status of all company code fields accordingly
  lv_authorized_for_activity = cvi_bdt_authorization_services=>get_max_cust_app_auth_for_user(
    exporting
      i_appkz    = 'F'
      i_activity = cvi_bdt_adapter=>get_activity( ) ).
  if lv_authorized_for_activity is initial or in_status = fstat_suppressed. "user has no autorization for F_KNA1_APP with APPKZ F and activity 03
    out_status = fstat_suppressed.
    return.
  endif.

* check if strategy is active, if not -> set all customer fields to display mode
  lcl_ka_bp_customer = cvi_ka_bp_customer=>get_instance( ).
  if lcl_ka_bp_customer->is_strategy_active(
       i_source_object = lcl_ka_bp_customer->ukm_object_partner
       i_target_object = lcl_ka_bp_customer->ukm_object_customer
      ) is initial.
    if in_status <> fstat_suppressed.
      out_status = fstat_display.
    else.
      out_status = in_status.
    endif.
    return.
  endif.

  if cvi_bdt_adapter=>get_current_bp( ) is not initial.
    lv_customer_status = cvi_bdt_adapter=>get_opt_customer_status( ).
  else.
    out_status = in_status.
    return.
  endif.

  if lv_customer_status = cvi_bdt_adapter=>cv_status_not_relevant.
    out_status = fstat_suppressed.
  elseif lv_customer_status = cvi_bdt_adapter=>cv_status_optional.
    if in_status = fstat_suppressed.
      out_status = fstat_suppressed.
    else.
      out_status = fstat_display.
    endif.
  else. "lv_customer_status = cv_status_created/not_optional/optional_and_set
    out_status = in_status.

    lv_compcode  = cvi_bdt_adapter=>get_current_company_code( ).
    if lv_compcode is not initial.
      lt_compcodes = cvi_bdt_adapter=>get_company_codes( ).
      read table lt_compcodes assigning <cc_info>
        with key company_code = lv_compcode.

      if <cc_info> is not assigned or <cc_info>-customer_status is not initial.
        if cvi_bdt_adapter=>get_activity( ) <> '03'.
          cvi_bdt_adapter=>authority_check_cust_comp_code(
            exporting
              iv_actvt        = '02'
              iv_company_code = lv_compcode
            importing
              es_error = ls_errors ).
        endif.

        if ls_errors-is_error is initial.

          case fldgr.
            when '1893' or  '1894' or '0342' or '1940'.
              if in_status = fstat_suppressed.
                out_status = in_status.
              else.
                "Set the dunning data to display mode if dunning procedure and all dunning data empty
                if gs_knb5-mahna is initial and gs_knb5-knrma is initial and gs_knb5-mahns is initial
                  and gs_knb5-madat is initial and gs_knb5-gmvdt is initial and gs_knb5-busab is initial
                  and gs_knb5-mansp is initial.
                  out_status = fstat_display.
                  clear dunn_block_txt.
                else.
                  out_status = in_status.
                endif.
              endif.

            when '1890'.

              if ls_errors-is_error = true and in_status <> fstat_suppressed.
                out_status = fstat_display.
              else.
                out_status = in_status.
              endif.

              if out_status = fstat_suppressed or out_status = fstat_display.
                return.
              endif.

              "Block authority - activity 05
              "F_KNA1_GEN / F_KNA1_APP / F_KNA1_GRP / F_KNA1_BED
              fsbp_memory_factory=>get_instance(
                      i_partner    = cvi_bdt_adapter=>get_current_bp( )
                      i_table_name = table_name_kna1
                    )->get_data_new( importing e_data_new = lt_kna1 ).

              read table lt_kna1 into ls_kna1 with key kunnr = cvi_bdt_adapter=>get_current_customer( ).
              if ls_kna1-begru is initial.
                ls_cust_auth_suppress_flags-skip_begru_check = true.
              endif.
              ls_cust_auth_suppress_flags-skip_tcode_check = true.

              cvi_bdt_authorization_services=>buffered_auth_check_cust_kna1(
                exporting
                  i_kna1_new                 = ls_kna1
                  i_kna1_old                 = ls_kna1_old
                  i_activity                 = '05'
                  i_appkz                    = 'F'
                  i_cust_auth_suppress_flags = ls_cust_auth_suppress_flags
                importing
                  e_error                    = ls_error ).
              if ls_error-is_error is not initial and in_status <> fstat_suppressed.
                out_status = fstat_display.
                return.
              endif.

            when '1891'.
               IF ls_errors-is_error = true.
                if in_status = fstat_suppressed.
                  out_status = fstat_suppressed.
                else.
                  out_status = fstat_display.
                endif.
              else.
                out_status = in_status.
              endif.

              if out_status = fstat_suppressed or out_status = fstat_display.
                return.
              endif.

              "Block authority - activity 05
              "Authority check of company code
              cvi_bdt_authorization_services=>buffered_auth_check_cust_cc(
                exporting
                  i_activity = '05'
                  i_bukrs    = lv_compcode
                importing
                  e_error    = ls_error ).
              if ls_error-is_error is not initial and in_status <> fstat_suppressed.
                out_status = fstat_display.
                return.
              endif.

              "F_KNA1_APP / F_KNA1_GRP
              fsbp_memory_factory=>get_instance(
                      i_partner    = cvi_bdt_adapter=>get_current_bp( )
                      i_table_name = table_name_kna1
                    )->get_data_new( importing e_data_new = lt_kna1 ).

              read table lt_kna1 into ls_kna1 with key kunnr = cvi_bdt_adapter=>get_current_customer( ).
              ls_cust_auth_suppress_flags-skip_begru_check = true.
              ls_cust_auth_suppress_flags-skip_gen_check = true.
              ls_cust_auth_suppress_flags-skip_tcode_check = true.

              cvi_bdt_authorization_services=>buffered_auth_check_cust_kna1(
                exporting
                  i_kna1_new                 = ls_kna1
                  i_kna1_old                 = ls_kna1_old
                  i_activity                 = '05'
                  i_appkz                    = 'F'
                  i_cust_auth_suppress_flags = ls_cust_auth_suppress_flags
                importing
                  e_error                    = ls_error ).
              if ls_error-is_error is not initial and in_status <> fstat_suppressed.
                out_status = fstat_display.
                return.
              endif.

              "F_KNA1_BED
              fsbp_memory_factory=>get_instance(
                      i_partner    = cvi_bdt_adapter=>get_current_bp( )
                      i_table_name = table_name_knb1
                    )->get_data_new( importing e_data_new = lt_knb1 ).

              read table lt_knb1 into ls_knb1 with key kunnr = cvi_bdt_adapter=>get_current_customer( ) bukrs = lv_compcode.
              if ls_knb1-begru is not initial.
                cvi_bdt_authorization_services=>buf_auth_check_cust_begru(
                  exporting
                    i_activity = '05'
                    i_kunnr    = ls_kna1-kunnr
                    i_begru    = ls_knb1-begru
                  importing
                    e_error    = ls_error ).
                if ls_error-is_error is not initial and in_status <> fstat_suppressed.
                  out_status = fstat_display.
                  return.
                endif.
              endif.

            when '1897'. "withholding tax
              if in_status = fstat_suppressed.
                out_status = in_status.
              else.
                select single * from t001 into ls_t001
                  where bukrs = lv_compcode
                    and wt_newwt = true.
                if sy-subrc <> 0 or ls_errors-is_error = true.
                  out_status = fstat_display.
                else.
                  out_status = in_status.
                endif.
              endif.


            when '1871'. "customer payment method supplement: hide if T042-XUZAW is false for current company code
              if in_status = fstat_suppressed.
                out_status = fstat_suppressed.
              else.
                data: lv_result type boole_d.
                lv_result = cvi_bdt_adapter=>is_xuzaw_active_for_curr_cc( lv_compcode ).
                if lv_result = true.
                  out_status = in_status.
                else.
                  out_status = fstat_suppressed.
                endif.
              endif.

            when '1929'.
              if in_status = fstat_suppressed.
                out_status = fstat_suppressed.
              else.
                data:
                  lv_customer    type kunnr,
                  lv_cc_cur      type bukrs,
                  lv_head_office type kunnr.
                "check if current customer is already assigned as head office for this company code
                lv_customer = cvi_bdt_adapter=>get_current_customer( ).
                lv_cc_cur = cvi_bdt_adapter=>get_current_company_code( ).
                if lv_customer is not initial.
                  select single kunnr from knb1 into lv_head_office
                    where bukrs = lv_cc_cur and knrze = lv_customer.
                endif.
                if lv_head_office is not initial.
                  "customer is already head office in this company code and cannot have a head office itself ==> hide field
                  out_status = fstat_suppressed.
                else.
                  out_status = in_status.
                endif.
              endif.

            when others.
              out_status = in_status.

          endcase.
        endif.
      endif.
    endif.
  endif.

  if lv_compcode is initial
     or ( <cc_info> is assigned and <cc_info>-customer_status is initial )
     or ls_errors-is_error is not initial
     or lv_authorized_for_activity = '03'. "user has no autorization for F_KNA1_APP with APPKZ F and activity 02

    if out_status = fstat_suppressed or in_status = fstat_suppressed.
      out_status = in_status.
    else.
      out_status = fstat_display.
    endif.

  endif.

endfunction.
