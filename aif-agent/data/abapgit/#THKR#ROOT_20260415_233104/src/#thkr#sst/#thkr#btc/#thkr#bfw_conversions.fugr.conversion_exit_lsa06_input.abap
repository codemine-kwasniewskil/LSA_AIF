FUNCTION CONVERSION_EXIT_LSA06_INPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------
  DATA: l_input  TYPE string,
        l_output TYPE string.

  l_input = input.
  IF strlen( l_input ) = 20.
    CONCATENATE l_input(4) l_input+5(4) l_input+10(10) INTO l_output.
    output = l_output.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.
