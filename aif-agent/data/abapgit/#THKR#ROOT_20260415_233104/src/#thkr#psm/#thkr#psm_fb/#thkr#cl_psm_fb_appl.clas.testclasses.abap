*"* use this source file for your ABAP unit test classes
CLASS /thkr/tcl_psm_fb_appl DEFINITION FOR TESTING INHERITING FROM /thkr/th_base
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>/thkr/tcl_Psm_Fb_Appl
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>/THKR/CL_PSM_FB_APPL
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
      mo_cut TYPE REF TO /thkr/cl_psm_fb_appl.  "class under test

    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.

    METHODS: setup.
    METHODS: teardown.
    METHODS: create_fkber FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: update_fkber FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: get_fkber_data FOR TESTING RAISING  cx_ecatt_tdc_access.
ENDCLASS.       "/thkr/tcl_Psm_Fb_Appl


CLASS /thkr/tcl_psm_fb_appl IMPLEMENTATION.

  METHOD constructor.
    super->constructor( i_tdc_name = '/THKR/TDC_PSM_INT_FB' ).
  ENDMETHOD.


  METHOD class_setup.
    get_variants( i_tdc_name = '/THKR/TDC_PSM_INT_FB' ).
    decide_variant_list( ).
  ENDMETHOD.


  METHOD setup.
    mo_cut = /thkr/cl_psm_fb_appl=>get_instance( ).
  ENDMETHOD.


  METHOD teardown.

  ENDMETHOD.


  METHOD create_fkber.
    DATA: i_dto_psm_fb_create TYPE /thkr/dto_create_psm_fb.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_FB'.
      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_FB_CREATE'          " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_dto_psm_fb_create          " Variable, in die der Wert übertragen werden soll
      ).

      TRY.
          DATA(lv_fkber) = mo_cut->create_fkber( i_fb_create = i_dto_psm_fb_create ).               " DTO: Anlegen eines Beleges zu einer PSM-Anordnung

          cl_abap_unit_assert=>assert_not_initial( act = lv_fkber ).
          IF lv_fkber IS NOT INITIAL.
            mv_ok = abap_true.
          ENDIF.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
      ENDTRY.
    ENDLOOP. " Variants
  ENDMETHOD.


  METHOD update_fkber.
    DATA: i_dto_psm_fb_create TYPE /thkr/dto_create_psm_fb.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_FB'.
      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_FB_CREATE'          " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_dto_psm_fb_create          " Variable, in die der Wert übertragen werden soll
      ).

      TRY.
          DATA(lv_fkber) = mo_cut->update_fkber( i_fb_create = i_dto_psm_fb_create ).               " DTO: Anlegen eines Beleges zu einer PSM-Anordnung

          cl_abap_unit_assert=>assert_not_initial( act = lv_fkber ).
          IF lv_fkber IS NOT INITIAL.
            mv_ok = abap_true.
          ENDIF.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
      ENDTRY.
    ENDLOOP. " Variants
  ENDMETHOD.


  METHOD get_fkber_data.
    DATA: ls_fkber_id TYPE /thkr/dto_get_psm_fb,
          rv_fkber    TYPE /thkr/dto_psm_fb.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'READ_FB'.
      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'FKBER_ID'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = ls_fkber_id               " Variable, in die der Wert übertragen werden soll
      ).

      TRY.
          rv_fkber = mo_cut->get_fkber_data( ls_fkber_id ).
          cl_abap_unit_assert=>assert_not_initial( act = rv_fkber ).

        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_fb).
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_fb ).
      ENDTRY.
    ENDLOOP. " Variants
  ENDMETHOD.
ENDCLASS.
