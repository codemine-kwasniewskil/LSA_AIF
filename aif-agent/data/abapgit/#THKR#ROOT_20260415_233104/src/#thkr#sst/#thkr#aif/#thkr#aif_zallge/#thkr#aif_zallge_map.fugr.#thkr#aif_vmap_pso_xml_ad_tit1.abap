FUNCTION /THKR/AIF_VMAP_PSO_XML_AD_TIT1 .
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
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_DE_PSO_FMBSEC
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  "Feld value_in = BU_TYPE (nach dem Mapping)

  DATA: lo_name TYPE REF TO /thkr/cl_aif_fmap_name.

  CLEAR value_out.
  "Aufbau Name
  lo_name = NEW /thkr/cl_aif_fmap_name( ).


    DATA(lv_fullname) = raw_line-bsec-name1 && raw_line-bsec-name2 && raw_line-bsec-name3 && raw_line-bsec-name4.
  "Mapping academic title
  value_out = lo_name->map_ad_title1(
                iv_bu_type  = conv bu_type( value_in )                " Geschäftspartnertyp
                iv_fullname = lv_fullname
              ).
ENDFUNCTION.
