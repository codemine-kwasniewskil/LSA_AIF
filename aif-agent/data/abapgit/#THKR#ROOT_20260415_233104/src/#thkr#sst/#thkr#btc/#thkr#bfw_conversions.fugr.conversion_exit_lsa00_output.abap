FUNCTION CONVERSION_EXIT_LSA00_OUTPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------

  PERFORM init_event_category2.

  READ TABLE event_category2_texts INTO data(l_line)
  WITH KEY event_category2 = input .
  IF sy-subrc = 0.
    output = l_line-sdescr.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.
