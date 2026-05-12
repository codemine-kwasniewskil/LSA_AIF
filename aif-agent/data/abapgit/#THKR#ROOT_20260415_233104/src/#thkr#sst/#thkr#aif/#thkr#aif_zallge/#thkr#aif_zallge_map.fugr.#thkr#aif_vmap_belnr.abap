*"----------------------------------------------------------------------
* Gereon Koks  TSI  20.12.2024
*"----------------------------------------------------------------------
* Map BELNR
* Beim Buchungsschlüssel 15_SAB wird für eine Referenz (XBLNR / 28_AKTZ)
* die alte (bereits gebuchte) Anordnung gefunden.
* Diese Anordnung wird abgesetzt.
*"----------------------------------------------------------------------
* Input
* VALUE_IN  28_AKTZ
* VALUE_IN2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT Wert des DTO-Feldes
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_belnr.
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
  DATA: ls_bkpf TYPE bkpf.

  SELECT * FROM bkpf INTO ls_bkpf
    WHERE blart = 'DR'
      AND xblnr = value_in.

    value_out = ls_bkpf-belnr.
  ENDSELECT.
*"----------------------------------------------------------------------
ENDFUNCTION.
