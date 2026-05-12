*"* use this source file for your ABAP unit test classes

CLASS /thkr/tcl_fi_appl DEFINITION FOR TESTING INHERITING FROM /thkr/th_base
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>/thkr/tcl_Fi_Appl
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>/THKR/CL_FI_APPL
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
      mo_cut TYPE REF TO /thkr/cl_fi_appl.  "class under test

    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.
    METHODS: setup.
    METHODS: teardown.
    METHODS: get_all_psm_fi_document_data FOR TESTING.
ENDCLASS.       "/thkr/tcl_Fi_Appl


CLASS /thkr/tcl_fi_appl IMPLEMENTATION.
  METHOD constructor.

    super->constructor( i_tdc_name = '/THKR/TDC_FI_INT' ).

  ENDMETHOD.

  METHOD class_setup.

    get_variants( i_tdc_name = '/THKR/TDC_FI_INT' ).
    decide_variant_list( ).


  ENDMETHOD.

  METHOD setup.

    mo_cut = /thkr/cl_fi_appl=>get_instance( ).


  ENDMETHOD.

  METHOD teardown.

    IF test_run IS INITIAL AND mv_ok = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.

  ENDMETHOD.

  METHOD get_all_psm_fi_document_data.

    DATA:
      lt_data     TYPE  /thkr/t_fi_document_data,
      lt_saldo     TYPE  /thkr/t_fi_document_data,
      i_selection TYPE /thkr/s_fi_document_selection.


    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'GET'.
      TRY.
          tdc_api->get_value(
            EXPORTING
              i_param_name   = 'SELECTION_DATA'                 " Name des Parameters
              i_variant_name = <fs_variant>                 " Name der Variante
            CHANGING
              e_param_value  = i_selection                " Variable, in die der Wert übertragen werden soll
          ).
        CATCH cx_ecatt_tdc_access INTO DATA(lx_cx_ecatt).
          cl_abap_unit_assert=>assert_not_bound( act = lx_cx_ecatt ).
      ENDTRY.
      TRY.

          mo_cut->get_all_psm_fi_document_data(
            EXPORTING
              i_selection_data = i_selection                  " Selektionskriterien: FI-Belege
            IMPORTING
              e_document_data = lt_data
             e_kassenz_saldo = lt_saldo
          ).

          cl_abap_unit_assert=>assert_not_initial( act = lt_data ).
          cl_abap_unit_assert=>assert_not_initial( act = lt_saldo ).

          "  wenn Fehler dann kommt der als Exeption
        CATCH cx_root INTO DATA(lx_root).
          cl_abap_unit_assert=>assert_not_bound( act = lx_root ).
      ENDTRY.


    ENDLOOP.

  ENDMETHOD.





ENDCLASS.
