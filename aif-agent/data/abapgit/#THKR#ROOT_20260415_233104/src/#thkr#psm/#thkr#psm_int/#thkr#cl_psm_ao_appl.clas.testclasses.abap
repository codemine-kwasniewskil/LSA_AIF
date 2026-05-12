*"* use this source file for your ABAP unit test classes

CLASS /thkr/tcl_psm_ao_appl DEFINITION FOR TESTING INHERITING FROM /thkr/th_base
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>ztcl_Fmpo_Appl
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>/THKR/CL_FMPO_APPL
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
      mo_cut TYPE REF TO /thkr/cl_psm_ao_appl.  "class under test

    CLASS-METHODS: class_setup RAISING  cx_ecatt_tdc_access.

    METHODS: setup.
    METHODS: teardown.
    METHODS: create_psm_ao FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: create_psm_verr_ao FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: create_psm_dauer_ao FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: due_psm_ao  FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: due_date_psm_ao  FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: change_psm_ao FOR TESTING RAISING  cx_ecatt_tdc_access.
    METHODS: get_psm_ao FOR TESTING RAISING  cx_ecatt_tdc_access.

ENDCLASS.       "ztcl_psm_mv_Appl


CLASS /thkr/tcl_psm_ao_appl IMPLEMENTATION.
  METHOD constructor.

    super->constructor( i_tdc_name = '/THKR/TDC_PSM_INT_AO' ).

  ENDMETHOD.

  METHOD class_setup.

    get_variants( i_tdc_name = '/THKR/TDC_PSM_INT_AO' ).
    decide_variant_list( ).


  ENDMETHOD.

  METHOD setup.

    mo_cut = /thkr/cl_psm_ao_appl=>get_instance( ).


  ENDMETHOD.


  METHOD teardown.

    IF test_run IS INITIAL AND mv_ok = abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.

  ENDMETHOD.

  METHOD get_psm_ao.
    DATA:
      i_lotkz    TYPE lotkz,
      i_bukrs    TYPE bukrs,
      i_gjahr    TYPE gjahr,
      ls_dto_exp TYPE /thkr/s_dto_psm_ao,
      ls_dto_act TYPE /thkr/s_dto_psm_ao.



    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'GET'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'LOTKZ'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_lotkz                " Variable, in die der Wert übertragen werden soll
      ).
      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'BUKRS'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_bukrs                " Variable, in die der Wert übertragen werden soll
      ).
      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'GJAHR'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_gjahr               " Variable, in die der Wert übertragen werden soll
      ).
      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_AO'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = ls_dto_exp              " Variable, in die der Wert übertragen werden soll
      ).

      TRY.

          ls_dto_act = mo_cut->get_dto_psm_ao(
            EXPORTING
              i_lotkz = i_lotkz                 " Bündelungskennzeichen für Belege
              i_bukrs = i_bukrs                " Buchungskreis
              i_gjahr = i_gjahr                 " Geschäftsjahr
*             i_belnr =                  " Belegnummer eines Buchhaltungsbeleges
          ).

          "  wenn Fehler dann kommt der als Exeption
        CATCH cx_root INTO DATA(lx_root).
          cl_abap_unit_assert=>assert_not_bound( act = lx_root ).
      ENDTRY.


** Vergleich der eigentlichen Werte
* TODO Mapping Positionen und Vergleich Positionen
*      LOOP AT ls_dto_act-t_beleg ASSIGNING FIELD-SYMBOL(<fs_data>).
*        CLEAR <fs_data>-t_kont.
*      ENDLOOP.
*      LOOP AT ls_dto_exp-t_beleg ASSIGNING <fs_data>.
*        CLEAR <fs_data>-t_kont.
*      ENDLOOP.

*      cl_abap_unit_assert=>assert_equals(
*        EXPORTING
*          act = ls_dto_act
*          exp = ls_dto_exp
*      ).


    ENDLOOP.

  ENDMETHOD.

  METHOD change_psm_ao.


    DATA:
      i_dto_psm_ao_bel_new    TYPE /thkr/s_dto_psm_ao_bel_change,
      i_dto_psm_ao_bel_change TYPE /thkr/s_dto_psm_ao_bel_change,
      ls_document_number      TYPE /thkr/s_psm_ao_document_number.


    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CHANGE_AO'.
      CLEAR: i_dto_psm_ao_bel_change.

      TRY.

          tdc_api->get_value(
            EXPORTING
              i_param_name   = 'DTO_PSM_AO_CHANGE'                 " Name des Parameters
              i_variant_name = <fs_variant>                 " Name der Variante
            CHANGING
              e_param_value  = i_dto_psm_ao_bel_new               " Variable, in die der Wert übertragen werden soll
          ).

* aktuelle Daten holen und mit Wert aus TDC überschreiben

          DATA(ls_dto_act) = mo_cut->get_dto_psm_ao(
            EXPORTING
              i_lotkz = i_dto_psm_ao_bel_new-lotkz                 " Bündelungskennzeichen für Belege
              i_bukrs = i_dto_psm_ao_bel_new-bukrs           " Buchungskreis
              i_gjahr = i_dto_psm_ao_bel_new-gjahr         " Geschäftsjahr
              i_belnr = i_dto_psm_ao_bel_new-belnr                 " Belegnummer eines Buchhaltungsbeleges
          ).

          WHILE 1 = 1.
            IF sy-index < 6.
              CONTINUE.
            ENDIF.
            IF sy-index >	26. " ab T_KONT abbrechen
              EXIT.
            ENDIF.
            ASSIGN COMPONENT sy-index OF STRUCTURE i_dto_psm_ao_bel_new TO FIELD-SYMBOL(<fs_head_new>).
            IF sy-subrc <> 0.
              EXIT.
            ENDIF.
            DATA(lv_idx) = sy-index - 5.
            ASSIGN COMPONENT lv_idx OF STRUCTURE ls_dto_act-t_beleg[ 1 ] TO FIELD-SYMBOL(<fs_head_old>).
            IF sy-subrc = 0 AND <fs_head_new> IS NOT INITIAL.
              <fs_head_old> = <fs_head_new>.
            ENDIF.
          ENDWHILE.

          IF i_dto_psm_ao_bel_new-t_kont IS NOT INITIAL.
            WHILE 1 = 1.
              ASSIGN COMPONENT sy-index OF STRUCTURE i_dto_psm_ao_bel_new-t_kont[ 1 ] TO FIELD-SYMBOL(<fs_field_new>).
              IF sy-subrc <> 0.
                EXIT.
              ENDIF.

              ASSIGN COMPONENT sy-index OF STRUCTURE ls_dto_act-t_beleg[ 1 ]-t_kont[ 1 ] TO FIELD-SYMBOL(<fs_field_old>).
              IF sy-subrc = 0 AND <fs_field_new> IS NOT INITIAL.
                <fs_field_old> = <fs_field_new>.
              ENDIF.
            ENDWHILE.
          ENDIF.

          i_dto_psm_ao_bel_change = CORRESPONDING #( ls_dto_act ).
          i_dto_psm_ao_bel_change = CORRESPONDING #( ls_dto_act-t_beleg[ 1 ] ).
          i_dto_psm_ao_bel_change-t_kont = CORRESPONDING #( ls_dto_act-t_beleg[ 1 ]-t_kont ).
          i_dto_psm_ao_bel_change-lotkz = ls_dto_act-lotkz.
          i_dto_psm_ao_bel_change-bukrs = ls_dto_act-bukrs.
          i_dto_psm_ao_bel_change-gjahr = ls_dto_act-gjahr.
          i_dto_psm_ao_bel_change-psoty = ls_dto_act-psoty.
          i_dto_psm_ao_bel_change-waers = ls_dto_act-waers.

          i_dto_psm_ao_bel_change-test_run = test_run.


          mo_cut->change_psm_ao_beleg(
            EXPORTING
              i_dto_psm_ao_bel_change  = i_dto_psm_ao_bel_change                 " DTO: Ändern eines Beleges zu einer PSM-Anordnung
            IMPORTING
              e_psm_ao_document_number = ls_document_number                 " Beleg Nummer zu AO
          ).

          mv_ok = abap_true.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
*            LOOP AT lx_psm_ao->get_bapiret_table( ) INTO DATA(ls_return).
*              BREAK-POINT.
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
*            ENDLOOP.
      ENDTRY.


    ENDLOOP. " Variants

  ENDMETHOD.

  METHOD  create_psm_verr_ao.

    DATA:
          i_dto_psm_ao_verr TYPE /thkr/s_dto_psm_ao_verrechnung.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'VERR_AO'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_AO_VERR'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_dto_psm_ao_verr               " Variable, in die der Wert übertragen werden soll
      ).

      i_dto_psm_ao_verr-test_run = test_run.
      TRY.

          mo_cut->create_psm_ao_verrechnung(
            EXPORTING
              i_psm_ao_verrechnung     = i_dto_psm_ao_verr                  " VErrechnungsanordnung
            IMPORTING
              e_psm_ao_document_number = DATA(e_psm_doc)                 " Beleg Nummer zu AO
          ).


          mv_ok = abap_true.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
*            LOOP AT lx_psm_ao->get_bapiret_table( ) INTO DATA(ls_return).
*              BREAK-POINT.
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
*            ENDLOOP.
      ENDTRY.


    ENDLOOP.

  ENDMETHOD.

  METHOD create_psm_dauer_ao.

    DATA:
      ls_document_number   TYPE /thkr/s_psm_ao_document_number,
      ls_dto_psm_ao_create TYPE /thkr/s_dto_psm_ao_bel_create.


    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_DAO'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_AO_BEL_CREATE'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = ls_dto_psm_ao_create               " Variable, in die der Wert übertragen werden soll
      ).

      CLEAR ls_document_number.

      ls_dto_psm_ao_create-test_run = test_run.
      TRY.

          mo_cut->create_psm_ao_beleg(
            EXPORTING
              i_dto_psm_ao_bel_create  = ls_dto_psm_ao_create                 " DTO: Anlegen eines Beleges zu einer PSM-Anordnung
            IMPORTING
              e_psm_ao_document_number = ls_document_number                 " Beleg Nummer zu AO
          ).

          mv_ok = abap_true.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
*            LOOP AT lx_psm_ao->get_bapiret_table( ) INTO DATA(ls_return).
*              BREAK-POINT.
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
*            ENDLOOP.
      ENDTRY.


    ENDLOOP. " Variants
  ENDMETHOD.

  METHOD create_psm_ao.

    DATA:
      ls_document_number      TYPE /thkr/s_psm_ao_document_number,
      i_dto_psm_ao_bel_create	TYPE /thkr/s_dto_psm_ao_bel_create,
      i_dto_psm_ao_create     TYPE /thkr/s_dto_psm_ao_create.


    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'CREATE_AO'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_AO_CREATE'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
        CHANGING
          e_param_value  = i_dto_psm_ao_create               " Variable, in die der Wert übertragen werden soll
      ).

      CLEAR ls_document_number.
      LOOP AT i_dto_psm_ao_create-t_beleg ASSIGNING FIELD-SYMBOL(<fs_beleg>).
        CLEAR i_dto_psm_ao_bel_create.
        MOVE-CORRESPONDING i_dto_psm_ao_create TO i_dto_psm_ao_bel_create.
        MOVE-CORRESPONDING <fs_beleg> TO i_dto_psm_ao_bel_create.
        i_dto_psm_ao_bel_create-lotkz = ls_document_number-lotkz.

        i_dto_psm_ao_bel_create-test_run = test_run.
        TRY.

            mo_cut->create_psm_ao_beleg(
              EXPORTING
                i_dto_psm_ao_bel_create  = i_dto_psm_ao_bel_create                 " DTO: Anlegen eines Beleges zu einer PSM-Anordnung
              IMPORTING
                e_psm_ao_document_number = ls_document_number                 " Beleg Nummer zu AO
            ).

            mv_ok = abap_true.

            "  wenn Fehler dann kommt der als Exeption
          CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
*            LOOP AT lx_psm_ao->get_bapiret_table( ) INTO DATA(ls_return).
*              BREAK-POINT.
            cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
*            ENDLOOP.
        ENDTRY.

      ENDLOOP. " Beleg

    ENDLOOP. " Variants



  ENDMETHOD.

  METHOD due_psm_ao.



    DATA:
      i_dto_psm_ao_bel_create	TYPE /thkr/s_dto_psm_ao_bel_create,
      ls_ao_settings          TYPE /thkr/s_dto_psm_ao_settings,
      ls_ao_param             TYPE /thkr/s_dto_psm_ao_param.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'DUE_AO'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_AO_BEL_CREATE'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
*         i_path         =                  " Pfad innerhalb des Parameters
        CHANGING
          e_param_value  = i_dto_psm_ao_bel_create            " Variable, in die der Wert übertragen werden soll
      ).

      MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ls_ao_settings.
      MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ls_ao_param.


      TRY.

* AO lesen
          mo_cut->get_dto_psm_ao(
            EXPORTING
              i_lotkz           = i_dto_psm_ao_bel_create-lotkz                " Bündelungskennzeichen für Belege
              i_bukrs           = i_dto_psm_ao_bel_create-bukrs               " Buchungskreis
              i_gjahr           = i_dto_psm_ao_bel_create-gjahr
              i_belnr           = i_dto_psm_ao_bel_create-belnr                 " Geschäftsjahr
            RECEIVING
              r_dto_ps_fm_order = DATA(ls_ao_data)                 " Data Transfer Object für HKR Anordnungen
          ).


          MOVE-CORRESPONDING ls_ao_data TO i_dto_psm_ao_bel_create.
          MOVE-CORRESPONDING  ls_ao_data-t_beleg[ 1 ] TO i_dto_psm_ao_bel_create.


          MOVE-CORRESPONDING ls_ao_settings TO i_dto_psm_ao_bel_create.
          MOVE-CORRESPONDING ls_ao_param TO i_dto_psm_ao_bel_create.

          i_dto_psm_ao_bel_create-psoty = /thkr/cl_psm_ao_appl=>c_psoty_stundung_06.
          CLEAR i_dto_psm_ao_bel_create-blart.

          i_dto_psm_ao_bel_create-test_run = test_run.
          i_dto_psm_ao_bel_create-psoxb = abap_true.

          mo_cut->create_psm_ao_beleg(
            EXPORTING
              i_dto_psm_ao_bel_create = i_dto_psm_ao_bel_create                   " DTO: Anlegen eines Beleges zu einer PSM-Anordnung
          ).

          mv_ok = abap_true.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
*            LOOP AT lx_psm_ao->get_bapiret_table( ) INTO DATA(ls_return).
*              BREAK-POINT.
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
*            ENDLOOP.
      ENDTRY.

    ENDLOOP.


  ENDMETHOD.


  METHOD due_date_psm_ao.


    DATA:
      i_dto_psm_ao_bel_create	TYPE /thkr/s_dto_psm_ao_bel_create,
      ls_ao_settings          TYPE /thkr/s_dto_psm_ao_settings,
      ls_ao_param             TYPE /thkr/s_dto_psm_ao_param.

    LOOP AT t_tdc_variants ASSIGNING FIELD-SYMBOL(<fs_variant>) WHERE table_line CS 'DUE_DATE'.

      tdc_api->get_value(
        EXPORTING
          i_param_name   = 'DTO_PSM_AO_BEL_CREATE'                 " Name des Parameters
          i_variant_name = <fs_variant>                 " Name der Variante
*         i_path         =                  " Pfad innerhalb des Parameters
        CHANGING
          e_param_value  = i_dto_psm_ao_bel_create            " Variable, in die der Wert übertragen werden soll
      ).

      MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ls_ao_settings.
      MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ls_ao_param.

      TRY.
* AO lesen
          mo_cut->get_dto_psm_ao(
            EXPORTING
              i_lotkz           = i_dto_psm_ao_bel_create-lotkz                " Bündelungskennzeichen für Belege
              i_bukrs           = i_dto_psm_ao_bel_create-bukrs               " Buchungskreis
              i_gjahr           = i_dto_psm_ao_bel_create-gjahr
              i_belnr           = i_dto_psm_ao_bel_create-belnr                 " Geschäftsjahr
            RECEIVING
              r_dto_ps_fm_order = DATA(ls_ao_data)                 " Data Transfer Object für HKR Anordnungen
          ).


          MOVE-CORRESPONDING ls_ao_data TO i_dto_psm_ao_bel_create.
          MOVE-CORRESPONDING  ls_ao_data-t_beleg[ 1 ] TO i_dto_psm_ao_bel_create.


          MOVE-CORRESPONDING ls_ao_settings TO i_dto_psm_ao_bel_create.
          MOVE-CORRESPONDING ls_ao_param TO i_dto_psm_ao_bel_create.

          i_dto_psm_ao_bel_create-psoty = /thkr/cl_psm_ao_appl=>c_psoty_stundung_06.
          CLEAR i_dto_psm_ao_bel_create-blart.

          i_dto_psm_ao_bel_create-test_run = test_run.
          i_dto_psm_ao_bel_create-psoxb = abap_true.

          mo_cut->create_due_date_deferral(
            EXPORTING
              i_dto_psm_ao_bel_create = i_dto_psm_ao_bel_create                   " DTO: Anlegen eines Beleges zu einer PSM-Anordnung
          ).

          mv_ok = abap_true.

          "  wenn Fehler dann kommt der als Exeption
        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
*            LOOP AT lx_psm_ao->get_bapiret_table( ) INTO DATA(ls_return).
*              BREAK-POINT.
          cl_abap_unit_assert=>assert_not_bound( act = lx_psm_ao ).
*            ENDLOOP.
      ENDTRY.

    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
