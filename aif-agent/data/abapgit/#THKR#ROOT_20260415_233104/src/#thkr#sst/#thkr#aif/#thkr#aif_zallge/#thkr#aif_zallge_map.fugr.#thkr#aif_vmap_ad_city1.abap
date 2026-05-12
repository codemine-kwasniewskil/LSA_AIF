*"----------------------------------------------------------------------
* Gereon Koks  TSI  15.10.2024
*"----------------------------------------------------------------------
* Map AD_STREET
*"----------------------------------------------------------------------
* Housenumber is taken out of the field,
* because housenumber belongs to ADDR1_DATA-HOUSE_NUM1 (SAP)
* and not to ADDR1_DATA-STREET (SAP)
*"----------------------------------------------------------------------
* Input
* VALUE_IN  39 inpres5
* VALUE_IN2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT AD_STREET
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_ad_city1.
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
  SELECT SINGLE a~city1
    FROM adrc AS a
  INNER JOIN but020 AS b
    ON b~addrnumber = a~addrnumber
    WHERE b~partner = @value_in
   INTO @value_out.
ENDFUNCTION.
