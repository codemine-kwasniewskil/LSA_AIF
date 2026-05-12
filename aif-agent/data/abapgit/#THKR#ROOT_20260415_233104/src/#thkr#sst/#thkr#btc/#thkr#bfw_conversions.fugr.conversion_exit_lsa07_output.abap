FUNCTION CONVERSION_EXIT_LSA07_OUTPUT.
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

  IF input IS NOT INITIAL.
    IF strlen( l_input ) >= 9.
      CONCATENATE l_input(4) l_input+4(5) INTO l_output SEPARATED BY space.
      output = l_output.
    ELSE.
      output = input.
    ENDIF.
  ENDIF.

ENDFUNCTION.
