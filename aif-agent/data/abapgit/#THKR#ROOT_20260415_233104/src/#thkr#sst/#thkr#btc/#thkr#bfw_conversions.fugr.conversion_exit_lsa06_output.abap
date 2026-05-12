FUNCTION CONVERSION_EXIT_LSA06_OUTPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------

  IF input IS NOT INITIAL.
    CONCATENATE input(4) input+4(4) input+8(10) INTO output SEPARATED BY '/'.
  ENDIF.


ENDFUNCTION.
