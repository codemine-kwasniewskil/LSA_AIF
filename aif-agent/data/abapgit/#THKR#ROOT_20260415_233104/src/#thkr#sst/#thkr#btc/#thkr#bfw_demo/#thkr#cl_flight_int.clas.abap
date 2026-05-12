CLASS /thkr/cl_flight_int DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CLASS-METHODS get_instance
      EXPORTING
        !e_instance       TYPE REF TO /thkr/cl_flight_int
      RETURNING
        VALUE(r_instance) TYPE REF TO /thkr/cl_flight_int .
    METHODS get_dto_flight
      IMPORTING
        !i_flight_id TYPE /thkr/bfw_test_flight_id
      EXPORTING
        !e_dto       TYPE /thkr/s_dto_flight
      RAISING
        /thkr/cx_lsa1 .
    METHODS get_dto_aplane
      IMPORTING
        !i_planetype TYPE s_planetye OPTIONAL
        !i_flight_id TYPE /thkr/bfw_test_flight_id OPTIONAL
      EXPORTING
        !e_dto       TYPE /thkr/s_dto_aplane
      RAISING
        /thkr/cx_lsa1 .
    METHODS get_tdto_flight
      IMPORTING
        !i_selection TYPE /thkr/s_flight_selection
      EXPORTING
        !e_tdto      TYPE /thkr/t_dto_flight
      RAISING
        /thkr/cx_lsa1 .
    METHODS get_dto_carrier
      IMPORTING
        !i_carr_id TYPE s_carr_id
      EXPORTING
        !e_dto     TYPE /thkr/s_dto_carrier_d
      RAISING
        /thkr/cx_lsa1 .
protected section.
private section.

  class-data INSTANCE type ref to /THKR/CL_FLIGHT_INT .
ENDCLASS.



CLASS /THKR/CL_FLIGHT_INT IMPLEMENTATION.


  METHOD get_dto_aplane.

    DATA: l_mess      TYPE string,
          l_selection TYPE /thkr/s_flight_selection,
          l_planetype TYPE s_planetye.

    CLEAR: e_dto.

    IF i_planetype IS NOT INITIAL.
      l_planetype = i_planetype.
    ELSE.
      ASSERT i_flight_id IS NOT INITIAL.

      get_dto_flight(
        EXPORTING
          i_flight_id = i_flight_id
        IMPORTING
          e_dto       = DATA(l_dto_flight) ).
      l_planetype = l_dto_flight-planetype.

    ENDIF.


    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @e_dto
      FROM saplane
      WHERE planetype = @l_planetype.

    IF sy-subrc <> 0.
      MESSAGE i001(/thkr/bfw_demo) WITH l_planetype INTO l_mess.

      RAISE EXCEPTION TYPE /thkr/cx_lsa1
        EXPORTING
          textid = /thkr/cx_lsa1=>/thkr/cx_lsa1
          mess   = l_mess.

    ENDIF.


  ENDMETHOD.


  METHOD get_dto_carrier.

    DATA: l_mess      TYPE string,
          l_selection TYPE /thkr/s_flight_selection,
          l_planetype TYPE s_planetye.

    CLEAR: e_dto.

    SELECT SINGLE carrid AS carr_id, carrname, currcode, url INTO CORRESPONDING FIELDS OF @e_dto
      FROM scarr
      WHERE carrid = @i_carr_id.

    IF sy-subrc <> 0.
      MESSAGE i001(/thkr/bfw_demo) WITH l_planetype INTO l_mess.

      RAISE EXCEPTION TYPE /thkr/cx_lsa1
        EXPORTING
          textid = /thkr/cx_lsa1=>/thkr/cx_lsa1
          mess   = l_mess.

    ENDIF.

    l_selection-carr_id = e_dto-carr_id.

    get_tdto_flight(
      EXPORTING
        i_selection = l_selection
      IMPORTING
        e_tdto      = e_dto-t_flight ).

  ENDMETHOD.


  METHOD get_dto_flight.

    DATA: l_carrid      TYPE s_carr_id,
          l_connid      TYPE s_conn_id,
          l_fldate      TYPE dats,
          lt_return     TYPE bapiret2_t,
          l_flight_data TYPE bapisfldat,
          l_add_info    TYPE bapisfladd.

    CLEAR: e_dto.

    l_carrid = i_flight_id(3).
    l_connid = i_flight_id+3(4).
    l_fldate = i_flight_id+7(8).

    CALL FUNCTION 'BAPI_FLIGHT_GETDETAIL'
      EXPORTING
        airlineid       = l_carrid
        connectionid    = l_connid
        flightdate      = l_fldate
      IMPORTING
        flight_data     = l_flight_data
        additional_info = l_add_info
      TABLES
        return          = lt_return.

    LOOP AT lt_return INTO DATA(l_return) WHERE type = 'E'.
      RAISE EXCEPTION TYPE /thkr/cx_lsa1
        EXPORTING
          textid     = /thkr/cx_lsa1=>/thkr/cx_lsa1
          mess       = CONV #( l_return-message )
          t_bapiret2 = lt_return.
    ENDLOOP.

    MOVE-CORRESPONDING l_flight_data TO e_dto.
    e_dto-flight_id = i_flight_id.
    e_dto-planetype = l_add_info-planetype.


  ENDMETHOD.


  method GET_INSTANCE.


    IF instance IS INITIAL.
      CREATE OBJECT instance.
    ENDIF.

    e_instance = instance.
    r_instance = instance.

  endmethod.


  METHOD get_tdto_flight.

    DATA: lt_flight TYPE STANDARD TABLE OF bapisfldat,
          lt_return TYPE bapiret2_t.

    CLEAR e_tdto.

    CALL FUNCTION 'BAPI_FLIGHT_GETLIST'
      EXPORTING
        airline     = i_selection-carr_id
*       DESTINATION_FROM       =
*       DESTINATION_TO         =
*       MAX_ROWS    =
      TABLES
*       DATE_RANGE  =
*       EXTENSION_IN           =
        flight_list = lt_flight
*       EXTENSION_OUT          =
        return      = lt_return.

    LOOP AT lt_return INTO DATA(l_return) WHERE type = 'E'.
      RAISE EXCEPTION TYPE /thkr/cx_lsa1
        EXPORTING
          textid     = /thkr/cx_lsa1=>/thkr/cx_lsa1
          mess       = CONV #( l_return-message )
          t_bapiret2 = lt_return.
    ENDLOOP.

    LOOP AT lt_flight INTO DATA(l_flight).
      APPEND INITIAL LINE TO e_tdto ASSIGNING FIELD-SYMBOL(<dto>).
      MOVE-CORRESPONDING l_flight TO <dto>.
      CONCATENATE l_flight-airlineid l_flight-connectid l_flight-flightdate INTO <dto>-flight_id RESPECTING BLANKS.

    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
