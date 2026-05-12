FUNCTION /THKR/AIF_VMAP_PSO_XML_AOBTYPE.
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
*"     REFERENCE(RAW_LINE) TYPE  PSO02
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  " der AO_BU_TYPE wird aus dem Geschäftspartner ermittelt. Deshalb wird hier das gleiche Regelwerk durchlaufen.
  "Lese erst die Anordung zum Kassenzeichen und Beleg.
  "Suche anschließend aus Geschäftspartner Anrede und Namen für die Bildung des Geschäftspartnertyps.
  Try.
    DATA(ls_ao_line) = raw_struct-values-items[ key-lotkz = raw_line-lotkz key-belnr = raw_line-belnr ].
    value_out = /thkr/cl_aif_map=>get_instance( )->get_bu_type_pso_xml(
                                                iv_anred = CONV ad_titletx( ls_ao_line-lt_pssec[ itabkey = raw_line-itabkey ]-bsec-anred )                " Anredetext
                                                iv_stkzn = CONV stkzn( ls_ao_line-lt_pssec[ itabkey = raw_line-itabkey ]-bsec-stkzn )
                                                iv_name1 = conv string( ls_ao_line-lt_pssec[ itabkey = raw_line-itabkey ]-bsec-name1 )
                                                iv_name2 = conv string( ls_ao_line-lt_pssec[ itabkey = raw_line-itabkey ]-bsec-name2 )
                                                iv_name3 = conv string( ls_ao_line-lt_pssec[ itabkey = raw_line-itabkey ]-bsec-name3 )
                                                iv_name4 = conv string( ls_ao_line-lt_pssec[ itabkey = raw_line-itabkey ]-bsec-name4 )
                                              ).
  catch cx_sy_itab_line_not_found.
    "Keine Anordnung.
    RETURN.
  ENDTRY.


ENDFUNCTION.
