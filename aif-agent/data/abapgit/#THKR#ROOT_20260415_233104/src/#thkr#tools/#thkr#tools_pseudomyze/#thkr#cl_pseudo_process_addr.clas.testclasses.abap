*"* use this source file for your ABAP unit test classes

CLASS ltc_pseudo_process_addr DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.

  PRIVATE SECTION.
    CLASS-DATA environment TYPE REF TO if_osql_test_environment .
    DATA:
      f_cut TYPE REF TO /thkr/cl_pseudo_process_addr.  "class under test

    CLASS-METHODS: class_setup.
    CLASS-METHODS: class_teardown.
    METHODS: setup.
    METHODS: teardown.
    METHODS: process_data FOR TESTING.
    METHODS: process_data_testmode FOR TESTING.
ENDCLASS.       "ltc_Pseudo_Process_Bp


CLASS ltc_pseudo_process_addr IMPLEMENTATION.

  METHOD class_setup.
    environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'ADRC' ) ) ).
  ENDMETHOD.
  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.
  METHOD setup.
    DO 1000 TIMES.
      CASE sy-index MOD 3.
        WHEN 0 OR 1.
          INSERT INTO adrc VALUES @( VALUE #( addrnumber = sy-index
                                              name1      = |Org1_{ sy-index }|   sort1     = |Org1_{ sy-index }| mc_name1 = |Org1_{ sy-index }|
                                              name2      = |Org2_{ sy-index }|
                                              name3      = |Org3_{ sy-index }|
                                              name4      = |Org4_{ sy-index }|
                                              street     = |Street_{ sy-index }| mc_street = |Street_{ sy-index }|
                                              city1      = |City_{ sy-index }|   mc_city1  = |City_{ sy-index }|
                                              post_code1 = |{ sy-index }| ) ).
        WHEN 2.
          INSERT INTO adrc VALUES @( VALUE #( addrnumber = sy-index
                                              street     = |Street_{ sy-index }| mc_street = |Street_{ sy-index }|
                                              city1      = |City_{ sy-index }|   mc_city1  = |City_{ sy-index }|
                                              post_code1 = |{ sy-index }| ) ).
      ENDCASE.
    ENDDO.
    CREATE OBJECT f_cut.
  ENDMETHOD.
  METHOD teardown.
    environment->clear_doubles( ).
  ENDMETHOD.


  METHOD process_data_testmode.

    SELECT FROM adrc FIELDS * ORDER BY addrnumber INTO TABLE @DATA(but).

    DATA i_testmode TYPE flag.

    DATA(results) = f_cut->/thkr/if_pseudo_process~process_data( i_testmode = abap_true ).

    cl_abap_unit_assert=>assert_not_initial( act = results ).
    SELECT FROM adrc FIELDS * ORDER BY addrnumber INTO TABLE @DATA(but_neu).
    cl_abap_unit_assert=>assert_equals( act = but exp = but_neu ).

  ENDMETHOD.


  METHOD process_data.

    SELECT FROM adrc FIELDS * ORDER BY addrnumber INTO TABLE @DATA(but).

    DATA i_testmode TYPE flag.

    DATA(results) = f_cut->/thkr/if_pseudo_process~process_data( i_testmode = abap_false ).
    cl_abap_unit_assert=>assert_not_initial( act = results ).
    SELECT FROM adrc  FIELDS * ORDER BY addrnumber INTO TABLE @DATA(but_neu).
    "** Check one per Type
    IF but[ 1 ] = but_neu[ 1 ].
      cl_abap_unit_assert=>fail( msg = 'No data changes in DB!' ).
    ENDIF.
    IF but[ 2 ] = but_neu[ 2 ].
      cl_abap_unit_assert=>fail( msg = 'No data changes in DB!' ).
    ENDIF.
  ENDMETHOD.



ENDCLASS.
