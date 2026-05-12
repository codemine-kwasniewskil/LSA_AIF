*"----------------------------------------------------------------------
* Gereon Koks  TSI  5.2.2025
*"----------------------------------------------------------------------
* Map WAERS
* Währung wird entweder übergeben oder
* über den Buchungskreis abgeleitet.
*"----------------------------------------------------------------------
* Input
* VALUE_IN  31_LFD
* VALUE_IN2 @BUKRS
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT WAERS
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_waers.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  DATA: ls_tcurc TYPE tcurc.
*"----------------------------------------------------------------------
  IF NOT value_in IS INITIAL.
    value_out = value_in.
  ELSE.
    SELECT WAERS FROM t001 INTO value_out
      WHERE bukrs = value_in2.
    ENDSELECT.
  ENDIF.
*"----------------------------------------------------------------------
* Gibt's die Währung überhaupt ?
  SELECT * FROM tcurc INTO ls_tcurc
    WHERE waers = value_out.

  ENDSELECT.

  IF sy-subrc <> 0.
    value_out = 'ERR'.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
