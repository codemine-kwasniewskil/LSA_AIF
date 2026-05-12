*"----------------------------------------------------------------------
* Maximilian Kleissl  TSI  10.10.2024
*"----------------------------------------------------------------------
* BIC Dateinamen zusammenbauen.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_map_filename.
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
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_AIF_BIC_HEADER
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------


  value_out = raw_line-start+3 &&
    raw_line-verfa &&
    raw_line-gennr &&
    raw_line-konst_p1 &&
    raw_line-empf &&
    raw_line-konst_p2 &&
    raw_line-dienstnr.


ENDFUNCTION.
