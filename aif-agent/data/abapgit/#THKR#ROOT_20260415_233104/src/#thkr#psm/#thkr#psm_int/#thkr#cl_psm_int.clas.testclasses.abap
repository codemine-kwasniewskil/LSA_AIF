*"* use this source file for your ABAP unit test classes

CLASS /thkr/tcl_psm_int_fp DEFINITION FOR TESTING INHERITING FROM /thkr/th_base
  DURATION SHORT
  RISK LEVEL HARMLESS.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>/thkr/tcl_Psm_Int_Fp
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>/THKR/CL_PSM_INT
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PUBLIC SECTION.
    METHODS: constructor RAISING  cx_ecatt_tdc_access .
  PRIVATE SECTION.
    DATA:
      m_cut TYPE REF TO /thkr/cl_psm_int.  "class under test
    METHODS: setup.
    METHODS: teardown.
    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.
    METHODS: create_psm_fp FOR TESTING.
    METHODS: get_dto_psm_fp FOR TESTING.
ENDCLASS.       "/thkr/tcl_Psm_Int_Fp


CLASS /thkr/tcl_psm_int_fp IMPLEMENTATION.
  METHOD constructor.
    super->constructor( i_tdc_name = '/THKR/TDC_PSM_INT_FP' ).
  ENDMETHOD.
  METHOD class_setup.
    get_variants( i_tdc_name = '/THKR/TDC_PSM_INT_FP' ).
    decide_variant_list( ).
  ENDMETHOD.
  METHOD setup.
    m_cut = /thkr/cl_psm_int=>get_instance( ).
  ENDMETHOD.
  METHOD teardown.
  ENDMETHOD.
  METHOD create_psm_fp.
    DATA: ls_dto_create_fp TYPE /thkr/dto_create_psm_fp.
    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_FP'.
      TRY.
          tdc_api->get_value( EXPORTING i_param_name   = 'DTO_FP_CREATE'
                                        i_variant_name = <fs_variant>
                              CHANGING  e_param_value  = ls_dto_create_fp ).

          m_cut->create_psm_fp( EXPORTING i_dto_psm_fp_create = ls_dto_create_fp
                                IMPORTING e_fipos         = DATA(ls_fipos) ).
        CATCH cx_ecatt_tdc_access.
          cl_abap_unit_assert=>fail( msg = TEXT-e01 ).
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_err).
          cl_abap_unit_assert=>fail( msg = lx_psm_err->get_longtext( ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
  METHOD get_dto_psm_fp.
    DATA: ls_dto_fp TYPE /thkr/dto_psm_fp_key.
    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'GET_PSM_FP'.
      TRY.
          tdc_api->get_value( EXPORTING i_param_name   = 'DTO_FP'
                                        i_variant_name = <fs_variant>
                              CHANGING  e_param_value  = ls_dto_fp ).
          DATA(ls_fipos) = m_cut->get_dto_psm_fp( EXPORTING i_dto_psm_fp = ls_dto_fp ).
        CATCH cx_ecatt_tdc_access.
          cl_abap_unit_assert=>fail( msg = TEXT-e01 ).
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_err).
          cl_abap_unit_assert=>fail( msg = lx_psm_err->get_longtext( ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS /thkr/tcl_psm_int_tg DEFINITION FOR TESTING
  DURATION SHORT
     INHERITING FROM /thkr/th_base  RISK LEVEL HARMLESS.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>/thkr/tcl_Psm_Int_Tg
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>/THKR/CL_PSM_INT
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PUBLIC SECTION.
    METHODS: constructor RAISING  cx_ecatt_tdc_access .
  PRIVATE SECTION.
    DATA:
      m_cut TYPE REF TO /thkr/cl_psm_int.  "class under test
    METHODS: setup.
    METHODS: teardown.
    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.
    METHODS: create_psm_tg FOR TESTING.
    METHODS: get_dto_psm_tg FOR TESTING.
ENDCLASS.       "/thkr/tcl_Psm_Int_Tg


CLASS /thkr/tcl_psm_int_tg IMPLEMENTATION.
  METHOD constructor.
    super->constructor( i_tdc_name = '/THKR/TDC_PSM_INT_TG' ).
  ENDMETHOD.
  METHOD class_setup.
    get_variants( i_tdc_name = '/THKR/TDC_PSM_INT_TG' ).
    decide_variant_list( ).
  ENDMETHOD.
  METHOD setup.
    m_cut = /thkr/cl_psm_int=>get_instance( ).
  ENDMETHOD.
  METHOD teardown.
  ENDMETHOD.
  METHOD create_psm_tg.
    DATA: ls_dto_create_tg TYPE /thkr/dto_create_psm_tg.
    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_TG'.
      TRY.
          tdc_api->get_value( EXPORTING i_param_name   = 'DTO_TG_CREATE'
                                        i_variant_name = <fs_variant>
                              CHANGING  e_param_value  = ls_dto_create_tg ).
          m_cut->create_psm_tg( EXPORTING i_dto_psm_tg_create = ls_dto_create_tg
                                IMPORTING e_psm_tg                = DATA(ls_tg) ).
        CATCH cx_ecatt_tdc_access.
          cl_abap_unit_assert=>fail( msg = TEXT-e01 ).
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_err).
          cl_abap_unit_assert=>fail( msg = lx_psm_err->get_longtext( ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
  METHOD get_dto_psm_tg.
    DATA: ls_dto_tg TYPE /thkr/dto_psm_tg_key.
    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'GET_PSM_TG'.
      TRY.
          tdc_api->get_value( EXPORTING i_param_name   = 'DTO_TG'
                                        i_variant_name = <fs_variant>
                              CHANGING  e_param_value  = ls_dto_tg ).
          DATA(ls_tg) = m_cut->get_dto_psm_tg( EXPORTING i_dto_psm_tg = ls_dto_tg ).
        CATCH cx_ecatt_tdc_access.
          cl_abap_unit_assert=>fail( msg = TEXT-e01 ).
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_err).
          cl_abap_unit_assert=>fail( msg = lx_psm_err->get_longtext( ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS /thkr/tcl_psm_int_fkz DEFINITION FOR TESTING
  DURATION SHORT
     INHERITING FROM /thkr/th_base  RISK LEVEL HARMLESS.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>/thkr/tcl_Psm_Int_Fkz
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>/THKR/CL_PSM_INT
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PUBLIC SECTION.
    METHODS: constructor RAISING  cx_ecatt_tdc_access .
  PRIVATE SECTION.
    DATA:
      m_cut TYPE REF TO /thkr/cl_psm_int.  "class under test
    METHODS: setup.
    METHODS: teardown.
    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.
    METHODS: create_psm_fkz FOR TESTING.
    METHODS: get_dto_psm_fkz FOR TESTING.
ENDCLASS.       "/thkr/tcl_Psm_Int_Fkz

CLASS /thkr/tcl_psm_int_fkz IMPLEMENTATION.
  METHOD constructor.
    super->constructor( i_tdc_name = '/THKR/TDC_PSM_INT_FKZ' ).
  ENDMETHOD.
  METHOD class_setup.
    get_variants( i_tdc_name = '/THKR/TDC_PSM_INT_FKZ' ).
    decide_variant_list( ).
  ENDMETHOD.
  METHOD setup.
    m_cut = /thkr/cl_psm_int=>get_instance( ).
  ENDMETHOD.
  METHOD teardown.
  ENDMETHOD.
  METHOD create_psm_fkz.
    DATA: ls_dto_create_fkz TYPE /thkr/dto_create_psm_fkz.
    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_FKZ'.
      TRY.
          tdc_api->get_value( EXPORTING i_param_name   = 'DTO_FKZ_CREATE'
                                        i_variant_name = <fs_variant>
                              CHANGING  e_param_value  = ls_dto_create_fkz ).
          DATA(ls_fkz) = m_cut->create_psm_fkz( EXPORTING i_dto_psm_fkz_create = ls_dto_create_fkz ).
        CATCH cx_ecatt_tdc_access.
          cl_abap_unit_assert=>fail( msg = TEXT-e01 ).
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_err).
          cl_abap_unit_assert=>fail( msg = lx_psm_err->get_longtext( ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
  METHOD get_dto_psm_fkz.
    DATA: ls_dto_fkz TYPE /thkr/dto_psm_fkz_key.
    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'GET_PSM_FKZ'.
      TRY.
          tdc_api->get_value( EXPORTING i_param_name   = 'DTO_FKZ'
                                        i_variant_name = <fs_variant>
                              CHANGING  e_param_value  = ls_dto_fkz ).
          DATA(ls_fkz) = m_cut->get_dto_psm_fkz( EXPORTING i_dto_psm_fkz = ls_dto_fkz ).
        CATCH cx_ecatt_tdc_access.
          cl_abap_unit_assert=>fail( msg = TEXT-e01 ).
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_err).
          cl_abap_unit_assert=>fail( msg = lx_psm_err->get_longtext( ) ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
