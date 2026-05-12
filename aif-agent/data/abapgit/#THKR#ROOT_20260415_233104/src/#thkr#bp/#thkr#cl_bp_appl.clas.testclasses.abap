*"* use this source file for your ABAP unit test classes

CLASS /thkr/tcl_bp_appl DEFINITION FOR TESTING INHERITING FROM /thkr/th_base
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>ztcl_Bp_Appl
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>THKR/CL_BP_APPL
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE>X
*?</GENERATE_FIXTURE>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION>X
*?</GENERATE_INVOCATION>
*?<GENERATE_ASSERT_EQUAL>X
*?</GENERATE_ASSERT_EQUAL>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PUBLIC SECTION.
    METHODS: constructor RAISING  cx_ecatt_tdc_access .

  PRIVATE SECTION.
    DATA:
       mo_cut TYPE REF TO /thkr/cl_bp_appl.  "class under test

    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.

    METHODS: setup.
    METHODS: teardown.
    METHODS: release_partner FOR TESTING  RAISING  cx_ecatt_tdc_access.
    METHODS: create_partner FOR TESTING  RAISING  cx_ecatt_tdc_access.
    METHODS: get_partner_data FOR TESTING  RAISING  cx_ecatt_tdc_access.
    METHODS: modify_partner FOR TESTING  RAISING  cx_ecatt_tdc_access.
ENDCLASS.       "ztcl_Bp_Appl


CLASS /thkr/tcl_bp_appl IMPLEMENTATION.
  METHOD constructor.

    super->constructor( i_tdc_name = '/THKR/TDC_BP' ).

  ENDMETHOD.

  METHOD setup.

    mo_cut = /thkr/cl_bp_appl=>get_instance( ).


  ENDMETHOD.


  METHOD class_setup.

    get_variants( i_tdc_name = '/THKR/TDC_BP' ).
    decide_variant_list( ).


  ENDMETHOD.

  METHOD teardown.

    IF test_run IS INITIAL AND mv_ok = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.

    CALL FUNCTION 'BUFFER_REFRESH_ALL'.

  ENDMETHOD.

  METHOD release_partner.
    DATA lv_partner TYPE bu_partner.
    DATA lv_bukrs TYPE bukrs.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'RELEASE'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'PARTNER'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
*         i_path         =                  " Pfad innerhalb des Parameters
        CHANGING
          e_param_value  = lv_partner               " Variable, in die der Wert übertragen werden soll
      ).


      TRY.

          mo_cut->release_partner( i_partner = lv_partner i_test_run = test_run ).

          mv_ok = abap_true.


          "  wenn Fehler dann kommt der als Exeption
        CATCH cx_root INTO DATA(lx_root).
          cl_abap_unit_assert=>assert_not_bound(  act = lx_root  ).
      ENDTRY.


    ENDLOOP.
  ENDMETHOD.

  METHOD create_partner.
    DATA i_dto_bp TYPE /thkr/s_dto_bp_create.
    DATA r_partner TYPE partner.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_BP_CREATE'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
*         i_path         =                  " Pfad innerhalb des Parameters
        CHANGING
          e_param_value  = i_dto_bp               " Variable, in die der Wert übertragen werden soll
      ).

      TRY.

          r_partner = mo_cut->create_partner( i_dto_bp ).

          cl_abap_unit_assert=>assert_not_initial( act = r_partner ).

          IF r_partner IS NOT INITIAL.
            mv_ok = abap_true.
          ENDIF.


          "  wenn Fehler dann kommt der als Exeption
        CATCH cx_root INTO DATA(lx_root).
          cl_abap_unit_assert=>assert_not_bound(  act = lx_root  ).
      ENDTRY.


    ENDLOOP.



  ENDMETHOD.


  METHOD get_partner_data.

    DATA i_partner TYPE bu_partner.
    DATA r_dto_bp TYPE /thkr/s_dto_bp.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'GET'.
      TRY.
          tdc_api->get_value(
            EXPORTING
              i_param_name   = 'PARTNER'                 " Name des Parameters
              i_variant_name = <fs_variant>                 " Name der Variante
*             i_path         =                  " Pfad innerhalb des Parameters
            CHANGING
              e_param_value  = i_partner               " Variable, in die der Wert übertragen werden soll
          ).

          r_dto_bp = mo_cut->get_partner_data( i_partner ).

          cl_abap_unit_assert=>assert_not_initial(  act = r_dto_bp ).

        CATCH cx_root INTO DATA(lx_root).
          cl_abap_unit_assert=>assert_initial(  act = lx_root ).

      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD modify_partner.


    DATA i_dto_bp TYPE /thkr/s_dto_bp_modify.
    DATA i_partner TYPE bu_partner.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'MODIFY'.

      TRY.
          tdc_api->get_value(
            EXPORTING
              i_param_name   = 'PARTNER'                 " Name des Parameters
              i_variant_name = <fs_variant>                 " Name der Variante
*             i_path         =                  " Pfad innerhalb des Parameters
            CHANGING
              e_param_value  = i_partner              " Variable, in die der Wert übertragen werden soll
          ).

          i_dto_bp = CORRESPONDING #( mo_cut->get_partner_data( i_partner = i_partner ) ).


          i_dto_bp-bu_name1 = 'Test_' && sy-uzeit.


          mo_cut->modify_partner( i_dto_bp ).

          mv_ok = abap_true.

        CATCH cx_root INTO DATA(lx_root).
          cl_abap_unit_assert=>assert_initial( act = lx_root  ).
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.




ENDCLASS.
