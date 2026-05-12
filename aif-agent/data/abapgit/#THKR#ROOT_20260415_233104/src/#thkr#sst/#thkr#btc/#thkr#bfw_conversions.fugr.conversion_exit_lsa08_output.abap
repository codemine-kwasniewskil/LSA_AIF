FUNCTION CONVERSION_EXIT_LSA08_OUTPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------

  PERFORM init_PROCESS_TYPE.

  READ TABLE PROCESS_TYPE_texts INTO DATA(l_line)
  WITH KEY domvalue_l = input .
  IF sy-subrc = 0.
    output = l_line-ddtext.
  ELSE.
    output = input.
  ENDIF.


ENDFUNCTION.
