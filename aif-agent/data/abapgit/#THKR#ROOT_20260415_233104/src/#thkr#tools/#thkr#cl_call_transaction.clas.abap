class /THKR/CL_CALL_TRANSACTION definition
  public
  create public .

public section.

  constants:
    BEGIN OF mode,
        show_all_popups TYPE char1 VALUE 'A',
        show_error_only TYPE char1 VALUE 'E',
        no_display      TYPE char1 VALUE 'N',
      END OF mode .
  constants:
    BEGIN OF update,
        async TYPE char1 VALUE 'S',
        sync  TYPE char1 VALUE 'A',
        local TYPE char1 VALUE 'L',
      END OF update .

  methods CALL
    importing
      !MODE type CHAR1 default MODE-SHOW_ERROR_ONLY
      !UPDATE type CHAR1 default UPDATE-SYNC
    returning
      value(MESSAGES) type BAPIRET2_TAB .
  methods CONSTRUCTOR
    importing
      !TCODE type TCODE .
  methods GET_BDC
    returning
      value(BDCTABLE) type BDCDATA_TAB .
  methods SET_FIELD
    importing
      !FIELD type FNAM_____4
      !VALUE type ANY
    returning
      value(SELF) type ref to /THKR/CL_CALL_TRANSACTION .
  methods SET_CURSOR
    importing
      !VALUE type BDC_FVAL
    returning
      value(SELF) type ref to /THKR/CL_CALL_TRANSACTION .
  methods SET_OKCODE
    importing
      !VALUE type BDC_FVAL
    returning
      value(SELF) type ref to /THKR/CL_CALL_TRANSACTION .
  methods SET_PROGRAM
    importing
      !PROGRAM type BDC_PROG
      !DYNPRO type BDC_DYNR
    returning
      value(SELF) type ref to /THKR/CL_CALL_TRANSACTION .
  methods SET_TCODE
    importing
      !TCODE type TCODE .
  methods SET_FIELD_TRUE
    importing
      !FIELD type FNAM_____4
    returning
      value(SELF) type ref to /THKR/CL_CALL_TRANSACTION .
protected section.

  data BDCDATA type BDCDATA_TAB .
  data TCODE type TCODE .
private section.
ENDCLASS.



CLASS /THKR/CL_CALL_TRANSACTION IMPLEMENTATION.


  METHOD call.
    DATA(results) = VALUE tab_bdcmsgcoll( ).
    DATA return TYPE bapiret2.
    CALL TRANSACTION me->tcode USING me->bdcdata
       MODE mode     "A: show all dynpros E: show dynpro on error only N: do not display dynpro
       UPDATE update "S: synchronously A: asynchronously L: local
       MESSAGES INTO results.

    LOOP AT results INTO DATA(result).
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = result-msgtyp
          cl     = result-msgid
          number = CONV syst_msgno( result-msgnr )
          par1   = result-msgv1(50)
          par2   = result-msgv2(50)
          par3   = result-msgv3(50)
          par4   = result-msgv4(50)
        IMPORTING
          return = return.
      messages = VALUE #( BASE messages ( return ) ).
    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.
    me->tcode = tcode.
  ENDMETHOD.


  METHOD get_bdc.
    bdctable = me->bdcdata.
  ENDMETHOD.


  METHOD set_cursor.
    me->set_field( field = 'BDC_CURSOR' value = value ).
    self = me.
  ENDMETHOD.


  METHOD set_field.
    me->bdcdata = VALUE #( BASE me->bdcdata ( fnam = field fval = CONV bdc_fval( value ) ) ).
    self = me.
  ENDMETHOD.


  METHOD set_field_true.
    me->bdcdata = VALUE #( BASE me->bdcdata ( fnam = field fval = abap_true ) ).
    self = me.
  ENDMETHOD.


  METHOD set_okcode.
    me->set_field( field = 'BDC_OKCODE' value = value ).
    self = me.
  ENDMETHOD.


  METHOD set_program.
    me->bdcdata = VALUE #( BASE me->bdcdata ( program = program dynpro = dynpro dynbegin = abap_true ) ).
    self = me.
  ENDMETHOD.


  METHOD set_tcode.
    me->tcode = tcode.
  ENDMETHOD.
ENDCLASS.
