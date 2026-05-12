FUNCTION /THKR/AIF_VMAP_PSO_XML_SST_BA.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"         OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_DE_PSO_FMBSEC
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"--------------------------------------------------------------------
  " Value_in = BSEC-ANRED
  " value_in2 = BSEC-STKZN


  value_out = /thkr/cl_pso_xml_processing=>get_instance( )->get_/thkr/sst(
                                                           is_raw_struct = raw_struct                 " Empfänger
                                                           is_raw_line   = raw_line                 " BP: Schnittstellenpartner
                                                         ).
ENDFUNCTION.
