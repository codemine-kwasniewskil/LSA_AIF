FUNCTION /thkr/aif_vmap_pso_xml_bu_type.
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
  " Value_in = BSEC-ANRED
  " value_in2 = BSEC-STKZN


  value_out = /thkr/cl_aif_map=>get_instance( )->get_bu_type_pso_xml(
                                                iv_anred = CONV ad_titletx( VALUE_in )                " Anredetext
                                                iv_stkzn = conv stkzn( value_in2 )
                                                iv_name1 = conv string( raw_line-bsec-name1 )
                                                iv_name2 = conv string( raw_line-bsec-name2 )
                                                iv_name3 = conv string( raw_line-bsec-name3 )
                                                iv_name4 = conv string( raw_line-bsec-name4 )
                                              ).
ENDFUNCTION.
