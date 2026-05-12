FUNCTION CONVERSION_EXIT_LSA07_INPUT.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"--------------------------------------------------------------------
  DATA: l_input  TYPE string,
        l_output TYPE string.

  l_input = input.
  CONDENSE l_input NO-GAPS.
  output = l_input.

ENDFUNCTION.
