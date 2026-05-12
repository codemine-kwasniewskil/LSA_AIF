FUNCTION conversion_exit_lsa00_input.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"----------------------------------------------------------------------
  PERFORM init_event_category2.

  READ TABLE event_category2_texts INTO DATA(l_line)
  WITH KEY sdescr = input .
  IF sy-subrc = 0.
    output = l_line-event_category2.
  ELSE.
    output = input.
  ENDIF.

ENDFUNCTION.
