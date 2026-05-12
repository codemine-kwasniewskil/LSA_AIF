*"* use this source file for your ABAP unit test classes
CLASS /thkr/tcl_psm_ve_appl DEFINITION FOR TESTING INHERITING FROM /thkr/th_base
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>/thkr/tcl_Psm_Ve_Appl
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>/THKR/CL_PSM_VE_APPL
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE>X
*?</GENERATE_FIXTURE>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION>X
*?</GENERATE_INVOCATION>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>

  PUBLIC SECTION.
    METHODS: constructor RAISING  cx_ecatt_tdc_access .

  PRIVATE SECTION.
    DATA:
      mo_cut TYPE REF TO /thkr/cl_psm_ve_appl.  "class under test

    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.

    METHODS: setup.
    METHODS: teardown.
    METHODS: create_vermerk FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: get_vermerk_data FOR TESTING RAISING  cx_ecatt_tdc_access.
ENDCLASS.       "/thkr/tcl_Psm_Fo_Appl


CLASS /thkr/tcl_psm_ve_appl IMPLEMENTATION.

  METHOD constructor.
    super->constructor( i_tdc_name = '/THKR/TDC_PSM_INT_VE' ).
  ENDMETHOD.


  METHOD class_setup.
    get_variants( i_tdc_name = '/THKR/TDC_PSM_INT_VE' ).
    decide_variant_list( ).
  ENDMETHOD.


  METHOD setup.
    mo_cut = /thkr/cl_psm_ve_appl=>get_instance( ).
  ENDMETHOD.


  METHOD teardown.

  ENDMETHOD.


  METHOD create_vermerk.
    DATA: i_dto_psm_ve_create TYPE /thkr/dto_create_psm_ve.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_VE'.
      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_VE_CREATE'          " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_dto_psm_ve_create          " Variable, in die der Wert übertragen werden soll
      ).

      TRY.
          DATA(ls_vermerk) = mo_cut->create_vermerk( i_ve_create = i_dto_psm_ve_create ).               " DTO: Anlegen eines Beleges zu einer PSM-Anordnung

          cl_abap_unit_assert=>assert_not_initial( act = ls_vermerk ).
          IF ls_vermerk IS NOT INITIAL.
            mv_ok = abap_true.
          ENDIF.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
      ENDTRY.
    ENDLOOP. " Variants
  ENDMETHOD.


  METHOD get_vermerk_data.
    DATA: ls_vermerk_id TYPE /thkr/dto_psm_ve_key,
          rv_vermerk    TYPE /thkr/dto_psm_ve.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'READ_VE'.
      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'VERMERK_ID'             " Name des Parameters
          i_variant_name = <fs_variant>             " Name der Variante
        CHANGING
          e_param_value  = ls_vermerk_id            " Variable, in die der Wert übertragen werden soll
      ).

      TRY.
          rv_vermerk = mo_cut->get_vermerk_data( ls_vermerk_id ).
          cl_abap_unit_assert=>assert_not_initial( act = rv_vermerk ).

        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_fo).
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_fo ).
      ENDTRY.
    ENDLOOP. " Variants
  ENDMETHOD.
ENDCLASS.
