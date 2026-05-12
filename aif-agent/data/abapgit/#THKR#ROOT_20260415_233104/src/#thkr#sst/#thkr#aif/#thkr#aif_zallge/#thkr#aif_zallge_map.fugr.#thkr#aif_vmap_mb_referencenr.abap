*"----------------------------------------------------------------------
* Maximilian Kleissl  TSI  29.11.2024
*"----------------------------------------------------------------------
* Map AD_STREET
*"----------------------------------------------------------------------
* Shortens the reference for Mittelbindung
*"----------------------------------------------------------------------
* Input
* VALUE_IN  39 inpres5
* VALUE_IN2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT AD_HSNM1
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_mb_referencenr.
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
*"     REFERENCE(VALUE_OUT) TYPE  CHAR10
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------

  IF strlen( value_in ) <= 16.
    value_out = value_in.
  ELSE.
      APPEND VALUE #( id = 'CNV20551'
                    number = '258'
                    type = 'E'
                    message_v1 = ''
                    message_v2 = 'MB Reference'
                    message_v3 = strlen( value_in )
                    message_v4 = 16 ) TO return_tab.
  ENDIF.

*"----------------------------------------------------------------------
ENDFUNCTION.
