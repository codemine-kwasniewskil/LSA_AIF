*"----------------------------------------------------------------------
* Gereon Koks  TSI  12.11.2024
*"----------------------------------------------------------------------
* Map FISTL Finanzstelle
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{EMSA,...)
* VALUE_IN2 BTYP €{SST,FUA,...}
* VALUE_IN3 12_OEH
* VALUE_IN4 leer
* VALUE_IN5 leer
*"----------------------------------------------------------------------
* Output
* VALUE_OUT Wert des DTO-Feldes
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_fistl.
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
  DATA: lv_value_out(10).
*"----------------------------------------------------------------------
  CLEAR value_out.
  lv_value_out = value_in3.
  lv_value_out+4(4) = '0001'.
*"----------------------------------------------------------------------
* Interface ?
  CASE value_in.
*"----------------------------------------------------------------------
* Justiz
    WHEN 'SSTA' OR 'RSTA' OR 'EURF' OR 'EMSA' OR 'EURK' OR 'ESTA'.
      IF lv_value_out+0(4) = '1304'.
        lv_value_out+0(4) = '1305'.
      ENDIF.
* Alle anderen SST
    WHEN OTHERS.
*"----------------------------------------------------------------------
  ENDCASE.
*"----------------------------------------------------------------------
* "01" verteilende Finanzstelle
* "02" bewirtschaftende Finanzstelle
* "03" nicht im Konzept enthalten

* Buchungstyp ?
  CASE value_in2.
* Budgetierung
    WHEN 'AUF' OR 'ANS' OR 'FRE' OR 'EAN'.
      CONCATENATE lv_value_out '01' INTO lv_value_out.
    WHEN OTHERS.
      CONCATENATE lv_value_out '02' INTO lv_value_out.
  ENDCASE.
*"----------------------------------------------------------------------
  CONCATENATE lv_value_out+0(4) '.' lv_value_out+4(4) '.' lv_value_out+8(2) INTO value_out.
*"----------------------------------------------------------------------
ENDFUNCTION.
