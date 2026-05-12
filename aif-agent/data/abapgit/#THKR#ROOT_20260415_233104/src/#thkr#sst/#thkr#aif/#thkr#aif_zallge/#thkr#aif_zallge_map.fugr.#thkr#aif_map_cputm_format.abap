FUNCTION /thkr/aif_map_cputm_format .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"         OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"--------------------------------------------------------------------
  "VALUE_IN = Geschäftsjahr
  "VALUE_IN2 = Aktenzeichen
  "VALUE_IN3 = Format

  SELECT SINGLE cputm
    FROM bkpf
    WHERE gjahr = @value_in
     AND psofn = @value_in2
  INTO @DATA(lv_cputm).
  IF sy-subrc = 0.

    value_out = |{  lv_cputm TIME = COND #( WHEN value_in3 = 'USER' THEN cl_abap_format=>d_user
                                           WHEN value_in3 = 'RAW' THEN cl_abap_format=>d_raw
                                           WHEN value_in3 = 'ISO' THEN cl_abap_format=>d_iso
                                           WHEN value_in3 = 'ENV' THEN cl_abap_format=>d_environment
                                           ELSE cl_abap_format=>d_user ) }|.
  ELSE.
    CLEAR value_out.
  ENDIF.
ENDFUNCTION.
