*----------------------------------------------------------------------*
***INCLUDE /THKR/LTAB_MAINTI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_BIC_FIELDS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_bic_fields INPUT.
  CONSTANTS: lc_FIELDNAME TYPE string VALUE '/THKR/T_EDAS_OWR-FIELDNAME'.

  TYPES:
    BEGIN OF ty_s_values,
      fieldname TYPE fieldname,
    END OF ty_s_values.

  DATA: lo_struc TYPE REF TO cl_abap_structdescr.
  DATA: lt_values TYPE STANDARD TABLE OF ty_s_values.
  DATA: lt_return TYPE STANDARD TABLE OF ddshretval.
  DATA: ls_dynpread       TYPE dynpread ##NEEDED.
  DATA: lt_dynread        TYPE STANDARD TABLE OF dynpread ##NEEDED.

  lo_struc ?= cl_abap_structdescr=>describe_by_name( p_name = '/THKR/S_AIF_BIC_ZEILE' ).
  DATA(lt_comp) = lo_struc->components.

  CLEAR lt_values.
  LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>).
    APPEND <ls_comp>-name TO lt_values.
  ENDLOOP.


*   Popup zur Auswahl zulaessiger Werte
      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          retfield    = conv DFIES-FIELDNAME( 'FIELDNAME' )
          dynpprog    = '/THKR/SAPLTAB_MAINT'
          dynpnr      = sy-dynnr
          dynprofield = conv HELP_INFO-DYNPROFLD( lc_fieldname )
          value_org   = 'S'
          display     = abap_false
        TABLES
          value_tab   = lt_values
          return_tab  = lt_return
        EXCEPTIONS
          OTHERS      = 0.

  CLEAR lt_dynread.

  TRY.
      ls_dynpread-fieldname = lc_FIELDNAME.
      ls_dynpread-fieldvalue = lt_return[ 1 ]-fieldval.
      INSERT ls_dynpread INTO TABLE lt_dynread.


      CALL FUNCTION 'DYNP_VALUES_UPDATE'
        EXPORTING
          dyname     = sy-repid
          dynumb     = sy-dynnr
        TABLES
          dynpfields = lt_dynread
        EXCEPTIONS
*         INVALID_ABAPWORKAREA       = 1
*         INVALID_DYNPROFIELD        = 2
*         INVALID_DYNPRONAME         = 3
*         INVALID_DYNPRONUMMER       = 4
*         INVALID_REQUEST            = 5
*         NO_FIELDDESCRIPTION        = 6
*         UNDEFIND_ERROR             = 7
          OTHERS     = 0.

    CATCH cx_sy_itab_line_not_found.
      "nichts machen
  ENDTRY.
ENDMODULE.
