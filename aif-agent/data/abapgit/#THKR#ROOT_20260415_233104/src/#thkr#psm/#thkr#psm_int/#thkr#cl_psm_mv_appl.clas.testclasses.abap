*"* use this source file for your ABAP unit test classes

CLASS /thkr/tcl_psm_mv_appl DEFINITION FOR TESTING INHERITING FROM /thkr/th_base
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>/thkr/tcl_Psm_Mv_Appl
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>/THKR/CL_PSM_MV_APPL
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
      mo_cut TYPE REF TO /thkr/cl_psm_mv_appl.  "class under test

    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.

    METHODS: setup.
    METHODS: teardown.
    METHODS: create_psm_mv FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: update_psm_mv_value FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: read_psm_mv FOR TESTING RAISING  cx_ecatt_tdc_access.
ENDCLASS.       "/thkr/tcl_Psm_Mv_Appl


CLASS /thkr/tcl_psm_mv_appl IMPLEMENTATION.
  METHOD constructor.

    super->constructor( i_tdc_name = '/THKR/TDC_PSM_INT_MV' ).

  ENDMETHOD.

  METHOD class_setup.

    get_variants( i_tdc_name = '/THKR/TDC_PSM_INT_MV' ).
    decide_variant_list( ).


  ENDMETHOD.

  METHOD setup.

    mo_cut = /thkr/cl_psm_mv_appl=>get_instance( ).


  ENDMETHOD.


  METHOD teardown.


    IF test_run IS INITIAL AND mv_ok = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.

  ENDMETHOD.

  METHOD update_psm_mv_value.

    DATA:
          i_dto_psm_mv_update_val TYPE /thkr/s_dto_psm_mv_update_val.


    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'UPDATE_VAL'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_UPDATE_VAL'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_dto_psm_mv_update_val            " Variable, in die der Wert übertragen werden soll
      ).



      TRY.

          i_dto_psm_mv_update_val-test_run = test_run.

          mo_cut->update_psm_mv_value( i_dto_psm_mv_update_val =  i_dto_psm_mv_update_val ).


          mv_ok = abap_true.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
      ENDTRY.

    ENDLOOP. " Variants
  ENDMETHOD.

  METHOD create_psm_mv.


    DATA:
      lv_mandt            TYPE sy-mandt,
      e_kblnr             TYPE kblnr_dy,
      i_dto_psm_mv_create TYPE /thkr/s_dto_psm_mv_create.


    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_MV'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_MV_CREATE'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_dto_psm_mv_create               " Variable, in die der Wert übertragen werden soll
      ).

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'MANDT'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = lv_mandt
      ).

      IF lv_mandt IS NOT INITIAL.
        CHECK lv_mandt = sy-mandt.
      ENDIF.

      TRY.

          i_dto_psm_mv_create-test_run = test_run.

          mo_cut->create_psm_mv(
            EXPORTING
              i_dto_psm_mv_bel_create = i_dto_psm_mv_create                 " DTO: Anlegen eines Beleges zu einer PSM-Anordnung
            IMPORTING
              e_kblnr                 = DATA(lv_blnr)                " Beleg Nummer zu AO
          ).

          IF lv_blnr IS NOT INITIAL.
            mv_ok = abap_true.
          ENDIF.


          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
*            LOOP AT lx_psm_ao->get_bapiret_table( ) INTO DATA(ls_return).
*              BREAK-POINT.
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
*            ENDLOOP.
      ENDTRY.

    ENDLOOP. " Variants





  ENDMETHOD.


  METHOD read_psm_mv.

    DATA i_kblnr TYPE kblnr_dy.
    DATA e_dto_psm_mv_bel TYPE /thkr/s_dto_psm_mv.
    DATA r_dto_psm_mv_bel TYPE /thkr/s_dto_psm_mv.


    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'READ'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'KBLNR'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_kblnr               " Variable, in die der Wert übertragen werden soll
      ).

      TRY.

          r_dto_psm_mv_bel = mo_cut->read_psm_mv(
            EXPORTING
              i_kblnr          = i_kblnr
            IMPORTING
              e_dto_psm_mv_bel = e_dto_psm_mv_bel
          ).


          cl_abap_unit_assert=>assert_not_initial( act = e_dto_psm_mv_bel ).

        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_mv).
*            LOOP AT lx_psm_mv->get_bapiret_table( ) INTO DATA(ls_return).
*              BREAK-POINT.
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_mv
                                                 ).
*            ENDLOOP.

      ENDTRY.

    ENDLOOP. " Variants

  ENDMETHOD.




ENDCLASS.
