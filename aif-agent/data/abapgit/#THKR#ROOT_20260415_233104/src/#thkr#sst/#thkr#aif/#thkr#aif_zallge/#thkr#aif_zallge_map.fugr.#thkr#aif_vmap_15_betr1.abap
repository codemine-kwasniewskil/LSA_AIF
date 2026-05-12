*"----------------------------------------------------------------------
* Gereon Koks  TSI  7.11.2024
*"----------------------------------------------------------------------
* Map WRBTR
* Komma-Behandlung
*"----------------------------------------------------------------------
* Input
* VALUE_IN  15_BETR1
* VALUE_IN2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BUDAT
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_VMAP_15_BETR1.
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
DATA: lv_wrbtr TYPE p DECIMALS 2.
DATA: lv_wrbtr_2 TYPE p DECIMALS 0.
lv_wrbtr = value_in.
MULTIPLY lv_wrbtr BY 100.
lv_wrbtr_2 = lv_wrbtr.
value_out = |{ lv_wrbtr_2 SIGN = LEFT }|.
*"----------------------------------------------------------------------
ENDFUNCTION.
