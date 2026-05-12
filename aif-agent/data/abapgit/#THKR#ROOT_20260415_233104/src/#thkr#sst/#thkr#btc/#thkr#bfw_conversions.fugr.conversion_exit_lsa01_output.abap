FUNCTION CONVERSION_EXIT_LSA01_OUTPUT.
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
  WITH KEY object_type = input.
  IF sy-subrc = 0.
    output = l_line-description.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.
