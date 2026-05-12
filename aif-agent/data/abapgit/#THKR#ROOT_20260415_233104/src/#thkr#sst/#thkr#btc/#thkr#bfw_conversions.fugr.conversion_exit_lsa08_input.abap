FUNCTION CONVERSION_EXIT_LSA08_INPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------
  PERFORM init_PROCESS_TYPE.

  READ TABLE PROCESS_TYPE_texts INTO DATA(l_line)
  WITH KEY ddtext = input .
  IF sy-subrc = 0.
    output = l_line-domvalue_l.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.
