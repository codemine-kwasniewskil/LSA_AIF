class /THKR/CL_DATA_STORE definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !ID type CHAR10 .
  class-methods GET
    importing
      !ID type CHAR10
    returning
      value(SELF) type ref to /THKR/CL_DATA_STORE .
  methods SET_ATTR
    importing
      !KEY type CHAR255
      !VALUE type CHAR255 .
  methods GET_ATTR
    importing
      !KEY type CHAR255
    returning
      value(VALUE) type CHAR255 .
protected section.
PRIVATE SECTION.
  TYPES: BEGIN OF ty_store,
           id   TYPE char10,
           inst TYPE REF TO /thkr/cl_data_store,
         END OF ty_store.

  TYPES:
    ty_stores TYPE TABLE OF ty_store.

  DATA store TYPE /thkr/t_keyvalue .
  CLASS-DATA instances TYPE ty_stores .
  DATA id TYPE char10 .
ENDCLASS.



CLASS /THKR/CL_DATA_STORE IMPLEMENTATION.


  METHOD constructor.
    me->id = id.
  ENDMETHOD.


  METHOD get.
    TRY.
        self = instances[ id = id  ]-inst.
      CATCH cx_sy_itab_line_not_found .
        self = NEW #( id = id ).
        instances = VALUE #( BASE instances ( id = id inst = self ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_attr.
    TRY.
        value = me->store[ key = key ]-value.
      CATCH cx_sy_itab_line_not_found .
        " Just return empty value
    ENDTRY.
  ENDMETHOD.


  METHOD set_attr.
    TRY.
        me->store[ key = key ]-value = value.
      CATCH cx_sy_itab_line_not_found.
        me->store = VALUE #( BASE me->store ( key = key value = value ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
