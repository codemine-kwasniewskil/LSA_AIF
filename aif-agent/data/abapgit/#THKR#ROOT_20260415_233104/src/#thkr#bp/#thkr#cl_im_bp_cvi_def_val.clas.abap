class /THKR/CL_IM_BP_CVI_DEF_VAL definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_CVI_DEFAULT_VALUES .
protected section.

  constants SORTBY_POSTING_DATE type DZUAWA value '001' ##NO_TEXT.
  constants BUGROUP_FREMDVERFAHREN type BU_GROUP value '0007' ##NO_TEXT.
  constants BUROLE_D_FREMDVERFAH_INT type BU_PARTNERROLECAT value 'ZDE08' ##NO_TEXT.
  constants BUROLE_D_FREMDVERFAHREN type BU_PARTNERROLECAT value 'ZDE07' ##NO_TEXT.
  constants BUROLE_K_FREMDVERFAH_INT type BU_PARTNERROLECAT value 'ZKR08' ##NO_TEXT.
  constants BUROLE_K_FREMDVERFAHREN type BU_PARTNERROLECAT value 'ZKR07' ##NO_TEXT.
private section.

  class-methods _SET_DEFAULT_VALUES
    importing
      !ROLE_CATEGORIES type CVIS_ROLE_CATEGORY_T optional
      !BUT000 type BUT000 optional
      !KOART type KOART optional
      !NEW_COMPANY_CODE type BUKRS optional
    changing
      !COMPANY_DATA type DATA
      !DUNNING type DATA optional .
ENDCLASS.



CLASS /THKR/CL_IM_BP_CVI_DEF_VAL IMPLEMENTATION.


  method IF_CVI_DEFAULT_VALUES~GET_DEFAULTS_FOR_CUST.
  endmethod.


  METHOD if_cvi_default_values~get_defaults_for_cust_cc.

    CHECK i_new_company_code IS NOT INITIAL.
    _set_default_values( EXPORTING role_categories = i_role_categories
                                   but000           = i_but000
                                   koart            = 'D'
                                   new_company_code = i_new_company_code
                         CHANGING  company_data     = c_company_data
                                   dunning          = c_dunning ).

  ENDMETHOD.


  method IF_CVI_DEFAULT_VALUES~GET_DEFAULTS_FOR_CUST_SALES.
  endmethod.


  method IF_CVI_DEFAULT_VALUES~GET_DEFAULTS_FOR_VEND.
  endmethod.


  METHOD if_cvi_default_values~get_defaults_for_vend_cc.

    CHECK i_new_company_code IS NOT INITIAL.
    _set_default_values( EXPORTING role_categories = i_role_categories
                                   but000          = i_but000
                                   koart           = 'K'
                         CHANGING  company_data    = c_company_data ).

  ENDMETHOD.


  method IF_CVI_DEFAULT_VALUES~GET_DEFAULTS_FOR_VEND_PORG.
  endmethod.


  METHOD _set_default_values.

    DATA(new_values) = VALUE cmds_ei_company_data( ).

** static default values:
    new_values-zuawa = sortby_posting_date.

** dynamic default values:
** Case 1: Special behaviour for 0007 Fremdverfahren & 0008 Fremd.int -> Use Customfield SST instead of BP group
    IF line_exists( role_categories[ category = burole_d_fremdverfahren ] )
    OR line_exists( role_categories[ category = burole_k_fremdverfahren ] )
    OR line_exists( role_categories[ category = burole_d_fremdverfah_int ] )
    OR line_exists( role_categories[ category = burole_k_fremdverfah_int ] ).
      new_values-akont = /thkr/cl_bp_general=>get_akonto_from_sst( sst = but000-/thkr/sst koart = koart ).
    ELSE.
      new_values-akont = /thkr/cl_bp_general=>get_akonto_from_bpgroup( bpgrp = but000-bu_group koart = koart ).
    ENDIF.

    "MGRUP has to be '01'
    new_values-mgrup = '01'.

    company_data  = CORRESPONDING #( new_values ).

"Für Debitoren muss das Mahnverfahren "MVM1" vorbelegt werden.
    IF koart = 'D'.
      DATA(new_values_mahn) = VALUE cvis_cust_cc_dunning_t( ).
      APPEND INITIAL LINE TO new_values_mahn ASSIGNING FIELD-SYMBOL(<fs_dunning>).
      IF sy-subrc = 0.
        <fs_dunning>-mandt = sy-mandt.
        <fs_dunning>-bukrs = new_company_code.
        <fs_dunning>-kunnr = but000-partner.
        <fs_dunning>-mahna = 'MVM1'.
      ENDIF.
      dunning = CORRESPONDING #( new_values_mahn ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
