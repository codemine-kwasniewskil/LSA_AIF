FUNCTION /THKR/AIF_MAP_TIMS_FORMAT .
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
"VALUE_IN = DATUM
"VALUE_IN2 = Rückgabeformat

value_out = |{ conv tims( VALUE_IN ) TIME = COND #( WHEN value_in2 = 'USER' THEN cl_abap_format=>d_user
                                       WHEN value_in2 = 'RAW' THEN cl_abap_format=>d_raw
                                       WHEN value_in2 = 'ISO' THEN cl_abap_format=>d_iso
                                       WHEN value_in2 = 'ENV' THEN cl_abap_format=>d_environment
                                       ELSE cl_abap_format=>d_user ) }|.
ENDFUNCTION.
