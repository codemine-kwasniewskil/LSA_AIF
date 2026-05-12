FUNCTION CONVERSION_EXIT_LSA01_INPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------
  PERFORM init_object_type.

  DATA: l_line TYPE ty_object_type_text.
  READ TABLE object_type_texts INTO l_line
  WITH KEY description = input.
  IF sy-subrc = 0.
    output = l_line-object_type.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.
