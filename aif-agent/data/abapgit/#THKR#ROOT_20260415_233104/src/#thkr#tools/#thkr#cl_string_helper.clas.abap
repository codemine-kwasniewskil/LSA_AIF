CLASS /thkr/cl_string_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS format
      IMPORTING
        !str         TYPE clike
        !par1        TYPE any
        !par2        TYPE any OPTIONAL
        !par3        TYPE any OPTIONAL
        !par4        TYPE any OPTIONAL
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS convert_to_stringtab
      IMPORTING
        !str1        TYPE clike
        !str2        TYPE clike OPTIONAL
      RETURNING
        VALUE(value) TYPE stringtab .
    CLASS-METHODS convert_to_stringtab2
      IMPORTING
        !input        TYPE table
      RETURNING
        VALUE(output) TYPE stringtab .
    CLASS-METHODS cast
      IMPORTING
        !input       TYPE any
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS alpha_in
      IMPORTING
        !input       TYPE clike
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS alpha_out
      IMPORTING
        !input       TYPE clike
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS concat
      IMPORTING
        !p1          TYPE any
        !p2          TYPE any
        !p3          TYPE any OPTIONAL
        !p4          TYPE any OPTIONAL
        !p5          TYPE any OPTIONAL
        !p6          TYPE any OPTIONAL
        !p7          TYPE any OPTIONAL
        !p8          TYPE any OPTIONAL
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS pad_left
      IMPORTING
        !input       TYPE any
        !symbol      TYPE clike
        !length      TYPE int4
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS substring
      IMPORTING
        !s           TYPE clike
        !skip        TYPE int4 OPTIONAL
        !take        TYPE int4 OPTIONAL
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS starts_with
      IMPORTING
        !s           TYPE clike
        !p           TYPE clike
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS to_string
      IMPORTING
        !input       TYPE any
      RETURNING
        VALUE(value) TYPE string .
    CLASS-METHODS read_from_table_by_index
      IMPORTING
        !table       TYPE stringtab
        !index       TYPE i
      RETURNING
        VALUE(value) TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_STRING_HELPER IMPLEMENTATION.


  METHOD alpha_in.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = input
      IMPORTING
        output = value.
  ENDMETHOD.


  METHOD alpha_out.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = input
      IMPORTING
        output = value.
    CONDENSE value.
  ENDMETHOD.


  METHOD cast.
    value = input.
  ENDMETHOD.


  METHOD concat.
    CONCATENATE p1 p2 INTO value RESPECTING BLANKS.
    IF p3 IS SUPPLIED.
      CONCATENATE value p3 INTO value RESPECTING BLANKS.
    ENDIF.
    IF p4 IS SUPPLIED.
      CONCATENATE value p4 INTO value RESPECTING BLANKS.
    ENDIF.
    IF p5 IS SUPPLIED.
      CONCATENATE value p5 INTO value RESPECTING BLANKS.
    ENDIF.
    IF p6 IS SUPPLIED.
      CONCATENATE value p6 INTO value RESPECTING BLANKS.
    ENDIF.
    IF p7 IS SUPPLIED.
      CONCATENATE value p7 INTO value RESPECTING BLANKS.
    ENDIF.
    IF p8 IS SUPPLIED.
      CONCATENATE value p8 INTO value RESPECTING BLANKS.
    ENDIF.
  ENDMETHOD.


  METHOD convert_to_stringtab.
    APPEND str1 TO value.
    IF str2 IS SUPPLIED.
      APPEND str2 TO value.
    ENDIF.
  ENDMETHOD.


  METHOD convert_to_stringtab2.
    DATA:
      lv_string TYPE string.
    FIELD-SYMBOLS:
      <row> TYPE data.

    LOOP AT input ASSIGNING <row>.
      lv_string = <row>.
      APPEND lv_string TO output.
    ENDLOOP.
  ENDMETHOD.


  METHOD format.
    DATA:
      lv_temp TYPE string.

    value = str.

    lv_temp = par1.
    REPLACE ALL OCCURRENCES OF '&1' IN value WITH lv_temp.

    IF par2 IS SUPPLIED.
      lv_temp = par2.
      REPLACE ALL OCCURRENCES OF '&2' IN value WITH lv_temp.
    ENDIF.

    IF par3 IS SUPPLIED.
      lv_temp = par3.
      REPLACE ALL OCCURRENCES OF '&3' IN value WITH lv_temp.
    ENDIF.

    IF par4 IS SUPPLIED.
      lv_temp = par4.
      REPLACE ALL OCCURRENCES OF '&4' IN value WITH lv_temp.
    ENDIF.
  ENDMETHOD.


  METHOD pad_left.
    DATA:
      lv_pad_symbol(1) TYPE c.

    IF strlen( symbol ) > 0.
      lv_pad_symbol = symbol(1).
    ENDIF.

    value = input.
    CONDENSE value.
    IF value IS INITIAL AND lv_pad_symbol IS INITIAL.
      RETURN.
    ENDIF.
    DO.
      IF strlen( value ) >= length.
        RETURN.
      ENDIF.
      CONCATENATE lv_pad_symbol value INTO value RESPECTING BLANKS.
    ENDDO.
  ENDMETHOD.


  METHOD read_from_table_by_index.
    CLEAR sy-subrc.
    READ TABLE table INDEX index INTO value.
  ENDMETHOD.


  METHOD starts_with.
    DATA:
      lv_length TYPE i.

    IF strlen( p ) > strlen( s ).
      RETURN.
    ENDIF.

    lv_length = strlen( p ).
    IF p = s(lv_length).
      value = 'X'.
    ENDIF.
  ENDMETHOD.


  METHOD substring.
    value = s.
    IF skip > 0.
      SHIFT value LEFT BY skip PLACES.
    ENDIF.
    IF take > 0 AND strlen( value ) > take.
      value = value(take).
    ENDIF.
  ENDMETHOD.


  METHOD to_string.
    value = input.
  ENDMETHOD.
ENDCLASS.
