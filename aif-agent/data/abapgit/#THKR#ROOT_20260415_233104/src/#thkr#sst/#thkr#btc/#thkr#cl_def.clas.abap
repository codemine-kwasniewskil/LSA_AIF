CLASS /thkr/cl_def DEFINITION
  PUBLIC
  CREATE PROTECTED .

  PUBLIC SECTION.

*    DATA md TYPE /thkr/s_md READ-ONLY .
*    DATA cust TYPE /thkr/s_cust READ-ONLY .
    DATA event_category_trace TYPE /thkr/event_category2 READ-ONLY VALUE 'TRACE' ##NO_TEXT.
    CONSTANTS tmbin_enable_test_features TYPE /thkr/tmbin VALUE 4 ##NO_TEXT.
    CONSTANTS tmbin_trace TYPE /thkr/tmbin VALUE 64 ##NO_TEXT.


    METHODS constructor .
    CLASS-METHODS get_lsa_def
      RETURNING
        VALUE(r_instance) TYPE REF TO /thkr/cl_def .
    METHODS testmode_is_set
      IMPORTING
        !i_flag         TYPE /thkr/tmbin
      RETURNING
        VALUE(r_is_set) TYPE xfeld .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA instance TYPE REF TO /thkr/cl_def .
    DATA test_mode TYPE /thkr/tmbin .
ENDCLASS.



CLASS /THKR/CL_DEF IMPLEMENTATION.


  METHOD constructor.

    DATA: l_test_mode TYPE xuvalue,
          l_num       TYPE i.

    GET PARAMETER ID '/THKR/TEST_MODE' FIELD l_test_mode.

*    SELECT SINGLE * INTO CORRESPONDING FIELDS OF cust
*      FROM /thkr/c_cust.

*    SELECT SINGLE * INTO CORRESPONDING FIELDS OF md
*      FROM /thkr/t_md.

*    ASSERT sy-subrc = 0.  "Stammdatentabelle /THKR/T_MD muss Eintrag enthalten!

    TRY.
        l_num     = l_test_mode.
        test_mode = l_num.
      CATCH cx_sy_conversion_no_number.

    ENDTRY.

  ENDMETHOD.


  METHOD get_lsa_def.

    IF instance IS INITIAL.
      CREATE OBJECT instance.
    ENDIF.

    r_instance = instance.

  ENDMETHOD.


  METHOD testmode_is_set.

    DATA:  l_null TYPE /thkr/tmbin.

    CLEAR r_is_set.

    IF i_flag BIT-AND test_mode > l_null.
      r_is_set = 'X'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
