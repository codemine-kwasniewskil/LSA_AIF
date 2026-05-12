FUNCTION /THKR/AIF_VMAP_ANTRAGSNUMMER.
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
  CLEAR value_out.
*"----------------------------------------------------------------------
  "VALUE_in  = Buchungskreis (BUKRS)
  "VALUE_IN2 = Anordnungsnummer (LOTKZ)
  "VALUE_IN3 = Kassenzeichen (XBLNR)


  SELECT SINGLE psofn
     FROM bkpf
    WHERE bukrs = @value_in
      and lotkz = @value_in2
      and xblnr = @value_in3
    INTO @value_out.
  IF sy-subrc <> 0.
    CLEAR: value_out.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
