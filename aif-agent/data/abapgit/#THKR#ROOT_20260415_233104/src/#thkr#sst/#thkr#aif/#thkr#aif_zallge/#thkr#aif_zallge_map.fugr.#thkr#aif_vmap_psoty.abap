*"----------------------------------------------------------------------
* Gereon Koks  TSI  2.10.2024
*"----------------------------------------------------------------------
* Map PSOTY
*"----------------------------------------------------------------------
* Nur Bsp.
* Wird über Value-Mapping realisiert !
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{0001,0002,...)
* VALUE_IN2 BTYP €{SST,FUA,...}
* VALUE_IN3 BIC-Feld 1
* VALUE_IN4 BIC-Feld 2
* VALUE_IN5 BIC-Feld 3
*"----------------------------------------------------------------------
* Output
* VALUE_OUT Wert des DTO-Feldes
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_VMAP_PSOTY.
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
  value_out = value_in.
*"----------------------------------------------------------------------
ENDFUNCTION.
