FUNCTION CONVERSION_EXIT_ZSIGN_INPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"  EXCEPTIONS
*"      ERROR_MESSAGE
*"----------------------------------------------------------------------

" Holen Sie sich das Dezimalformat aus den Benutzereinstellungen (SU01/SU3)
" Dezimaldarstellung aus den Benutzereinstellungen holen (SU01/SU3)

  IF gv_decimal_sign IS INITIAL.
    CALL FUNCTION 'CLSE_SELECT_USR01'
      EXPORTING
        username         = sy-uname
        iv_delete_buffer = abap_true
      IMPORTING
        decimal_sign     = gv_decimal_sign
        separator        = gv_separator.
  ENDIF.
  DATA(lv_input) = CONV string( input ).
  REPLACE ALL OCCURRENCES OF gv_separator IN lv_input WITH ''.
  REPLACE gv_decimal_sign IN lv_input WITH '.'.
  CONDENSE lv_input NO-GAPS.
  TRY.
      output = lv_input.
    CATCH cx_sy_conversion_no_number.
      " Clear message fields of sy structure, so that 'Conversion error' will be raised
      " Alle Message Felder der sy Struktur löschen, damit 'Fehler bei der Konvertierung.' geworfen wird
      CLEAR: sy-msgty, sy-msgno, sy-msgv1, sy-msgv2, sy-msgv3, sy-msgv4.
      RAISE error_message.
  ENDTRY.
ENDFUNCTION.
