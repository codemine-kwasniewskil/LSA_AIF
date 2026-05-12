*"* use this source file for your ABAP unit test classes

CLASS ltc_pseudo_process_bp DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.

  PRIVATE SECTION.
    DATA testsize TYPE int8.
    CLASS-DATA environment TYPE REF TO if_osql_test_environment .
    DATA:
      f_cut TYPE REF TO /thkr/cl_pseudo_process_bp.  "class under test

    CLASS-METHODS: class_setup.
    CLASS-METHODS: class_teardown.
    METHODS: setup.
    METHODS: teardown.
    METHODS: process_data FOR TESTING.
    METHODS: process_data_testmode FOR TESTING.
ENDCLASS.       "ltc_Pseudo_Process_Bp


CLASS ltc_pseudo_process_bp IMPLEMENTATION.

  METHOD class_setup.
    environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'BUT000' ) ) ).
  ENDMETHOD.
  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.
  METHOD setup.
    "** Max Size?!?!
    me->testsize = 999.

    DO me->testsize TIMES.
      CASE sy-index MOD 3.
        WHEN 0.
          INSERT INTO but000 VALUES @( VALUE #( partner   = |2000000{ sy-index }|   type       = '1' bpext = 'XX'
                                                name_last = |Nachname_{ sy-index }| name_first = |Vorname_{ sy-index }|
                                                bu_sort1  = |Nachname_{ sy-index }| bu_sort2   = |Vorname_{ sy-index }|
                                                mc_name1  = |Nachname_{ sy-index }| mc_name2   = |Vorname_{ sy-index }| ) ).
        WHEN 1.
          INSERT INTO but000 VALUES @( VALUE #( partner   = |2000000{ sy-index }| type      = '2' bpext = 'XX'
                                                name_org1 = |Org1_{ sy-index }|   name_org2 = |Org2_{ sy-index }|
                                                name_org3 = |Org3_{ sy-index }|   name_org4 = |Org4_{ sy-index }|
                                                bu_sort1  = |Org_{ sy-index }|    bu_sort2  = |Org_{ sy-index }|
                                                mc_name1  = |Org_{ sy-index }|    mc_name2  = |Org_{ sy-index }| ) ).
        WHEN 2.
          INSERT INTO but000 VALUES @( VALUE #( partner   = |2000000{ sy-index }| type      = '3' bpext = 'XX'
                                                name_grp1 = |Group1_{ sy-index }| name_grp2 = |Group2_{ sy-index }|
                                                bu_sort1  = |Group_{ sy-index }|  bu_sort2  = |Group_{ sy-index }|
                                                mc_name1  = |Group_{ sy-index }|  mc_name2  = |Group_{ sy-index }| ) ).
      ENDCASE.

    ENDDO.
    CREATE OBJECT f_cut.
  ENDMETHOD.
  METHOD teardown.
    environment->clear_doubles( ).
  ENDMETHOD.


  METHOD process_data_testmode.

    SELECT FROM but000 FIELDS * ORDER BY partner INTO TABLE @DATA(but).

    DATA i_testmode TYPE flag.

    DATA(results) = f_cut->/thkr/if_pseudo_process~process_data( i_testmode = abap_true ).

    cl_abap_unit_assert=>assert_not_initial( act = results ).
    SELECT FROM but000 FIELDS * ORDER BY partner INTO TABLE @DATA(but_neu).
    cl_abap_unit_assert=>assert_equals( act = but exp = but_neu ).

  ENDMETHOD.


  METHOD process_data.

    SELECT FROM but000 FIELDS * ORDER BY partner INTO TABLE @DATA(but).

    DATA i_testmode TYPE flag.

    DATA(results) = f_cut->/thkr/if_pseudo_process~process_data( i_testmode = abap_false i_chunksize = 100 ).
    cl_abap_unit_assert=>assert_not_initial( act = results ).
    SELECT FROM but000 FIELDS * ORDER BY partner INTO TABLE @DATA(but_neu).
    "** Check one per Type
    IF but[ type = 1 ] = but_neu[ type = 1 ].
      cl_abap_unit_assert=>fail( msg = 'No Person changes in DB!' ).
    ENDIF.
    IF but[ type = 2 ] = but_neu[ type = 2 ].
      cl_abap_unit_assert=>fail( msg = 'No Orgs changes in DB!' ).
    ENDIF.
    IF but[ type = 3 ] = but_neu[ type = 3 ].
      cl_abap_unit_assert=>fail( msg = 'No Grps changes in DB!' ).
    ENDIF.
    "** And random check:
    DATA(rand_i) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = CONV #( me->testsize ) )->get_next( ).
    IF but[ rand_i  ] = but_neu[ rand_i ].
      cl_abap_unit_assert=>fail( msg = 'No Person changes in DB!' ).
    ENDIF.
    rand_i = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = CONV #( me->testsize ) )->get_next( ).
    IF but[ rand_i  ] = but_neu[ rand_i ].
      cl_abap_unit_assert=>fail( msg = 'No Person changes in DB!' ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
