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
FUNCTION /THKR/AIF_VMAP_WRBTR_KOR .
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
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_AIF_BIC
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  DATA: lv_wrbtr(10) TYPE p DECIMALS 2.
  DATA: lv_betr(10)  TYPE p DECIMALS 2.
  lv_wrbtr = CONV #( value_in ).

  READ TABLE raw_struct-line INTO DATA(line) WITH KEY 01_btyp  = 'KOR'
                                                      18_betr3 = |{ value_in2 }{ value_in3 }{ value_in4 }|.
  IF sy-subrc = 0.
    lv_betr = line-15_betr1.
    lv_wrbtr += lv_betr.
  ENDIF.
  value_out = lv_wrbtr / 100.
*"----------------------------------------------------------------------
ENDFUNCTION.
