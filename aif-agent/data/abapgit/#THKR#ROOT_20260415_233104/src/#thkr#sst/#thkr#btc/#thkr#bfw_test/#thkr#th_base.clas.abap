class /THKR/TH_BASE definition
  public
  abstract
  create public
  for testing
  duration short
  risk level harmless .

public section.

  class-data TDC_NAME type ETOBJ_NAME .

  methods CONSTRUCTOR
    importing
      !I_TDC_NAME type ETOBJ_NAME
    raising
      CX_ECATT_TDC_ACCESS .
protected section.

  class-data T_TDC_VARIANTS type ETVAR_NAME_TABTYPE .
  class-data TDC_API type ref to CL_APL_ECATT_TDC_API .
  class-data TEST_RUN type /THKR/D_PS_FM_TEST_RUN .
  data MV_OK type FLAG .

  class-methods DECIDE_VARIANT_LIST
    importing
      !I_METHOD type SEOCPDNAME optional .
  class-methods GET_VARIANTS
    importing
      !I_TDC_NAME type ETOBJ_NAME
    raising
      CX_ECATT_TDC_ACCESS .
private section.

  class-methods CLASS_SETUP .
ENDCLASS.



CLASS /THKR/TH_BASE IMPLEMENTATION.


  METHOD class_setup.



  ENDMETHOD.


  METHOD constructor.

    tdc_name = i_tdc_name.

  ENDMETHOD.


  METHOD decide_variant_list.

    CONSTANTS:
              lc_testrun(11) TYPE c VALUE 'kein Commit'.

    DATA:
      lt_spopli TYPE TABLE OF spopli,
      lv_answer TYPE c.

* Testflag Abfrage an 1. Stelle
    APPEND INITIAL LINE TO lt_spopli ASSIGNING FIELD-SYMBOL(<fs_line>).
    <fs_line>-varoption = lc_testrun.
    <fs_line>-selflag = abap_true.

* Alle Varianten aufnehmen
    LOOP AT t_tdc_variants INTO DATA(lv_var).
      APPEND INITIAL LINE TO lt_spopli ASSIGNING <fs_line>.
      <fs_line>-varoption = lv_var.
    ENDLOOP.


* Variantenauswahl
    CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
      EXPORTING
*       CURSORLINE         = 1
        mark_flag          = 'X'
        mark_max           = 100
        start_col          = 50
        start_row          = 10
        textline1          = TEXT-002
        textline2          = i_method
*       TEXTLINE3          = ' '
        titel              = TEXT-001
*       DISPLAY_ONLY       = ' '
      IMPORTING
        answer             = lv_answer
      TABLES
        t_spopli           = lt_spopli
      EXCEPTIONS
        not_enough_answers = 1
        too_much_answers   = 2
        too_much_marks     = 3
        OTHERS             = 4.
    IF sy-subrc <> 0.
      CLEAR  t_tdc_variants.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      RETURN.
    ENDIF.

* Selektierte Varianten übernehmen
    CLEAR t_tdc_variants.

    LOOP AT lt_spopli INTO DATA(ls_selection).
      CASE ls_selection-varoption.
        WHEN lc_testrun.
          test_run = ls_selection-selflag.
        WHEN OTHERS.
          IF ls_selection-selflag IS NOT INITIAL.
            lv_var = ls_selection-varoption.
            APPEND lv_var TO t_tdc_variants.
          ENDIF.
      ENDCASE.

    ENDLOOP.


  ENDMETHOD.


  METHOD get_variants.

    IF i_tdc_name IS NOT INITIAL.
      tdc_name = i_tdc_name.
    ENDIF.

* Varianten laden
    tdc_api = cl_apl_ecatt_tdc_api=>get_instance( i_testdatacontainer = tdc_name ).
    t_tdc_variants = tdc_api->get_variant_list( ).
    DELETE TABLE t_tdc_variants FROM CONV #( 'ECATTDEFAULT' ).


  ENDMETHOD.
ENDCLASS.
