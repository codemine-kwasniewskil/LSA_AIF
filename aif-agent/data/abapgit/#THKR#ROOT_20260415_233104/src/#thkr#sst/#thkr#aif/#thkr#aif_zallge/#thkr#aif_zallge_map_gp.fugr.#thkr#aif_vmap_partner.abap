*"----------------------------------------------------------------------
* Gereon Koks  TSI  30.1.2026
*"----------------------------------------------------------------------
* Map PARTNER
*"----------------------------------------------------------------------
* Input
* VALUE_IN  @BU_BPEXT
* VALUE_IN2 @/THKR/SST
* VALUE_IN3 @BU_TYPE
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BUDAT
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_partner.
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
  DATA: db_but000    TYPE but000,
        lv_type      TYPE bu_type,
        lv_bpext     TYPE bu_bpext,
        lv_/thkr/sst TYPE /thkr/dte_bu_sst.
*"----------------------------------------------------------------------
  lv_bpext     = value_in.
  lv_/thkr/sst = value_in2.
  lv_type      = value_in3.
*"----------------------------------------------------------------------
  SELECT SINGLE * FROM but000 INTO db_but000
    WHERE type      = lv_type
      AND bpext     = lv_bpext
      AND /thkr/sst = lv_/thkr/sst.

  IF sy-subrc = 0.
    value_out = db_but000-partner.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
