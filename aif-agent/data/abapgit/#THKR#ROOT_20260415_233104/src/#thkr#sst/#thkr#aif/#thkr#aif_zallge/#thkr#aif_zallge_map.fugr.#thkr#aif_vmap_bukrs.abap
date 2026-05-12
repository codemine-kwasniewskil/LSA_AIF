*"----------------------------------------------------------------------
* Gereon Koks  TSI  19.2.2025
*"----------------------------------------------------------------------
* Map BUKRS
* Für Testzwecke
*"----------------------------------------------------------------------
* Input
* VALUE_IN  12_OEH
* VALUE_IN2 09_AO
* VALUE_IN3 13_MSN
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT Wert des DTO-Feldes
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_bukrs.
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
  DATA: ls_/thkr/centralmap TYPE /thkr/centralmap.
*"----------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------
  SELECT * FROM /thkr/centralmap INTO ls_/thkr/centralmap
    WHERE oeh_old         =  value_in
      AND ep              =  value_in2
      AND kam_sub_acc_old =  value_in3.
*      AND valid_from      <= sy-datum
*      AND valid_to        >= sy-datum.

    value_out = ls_/thkr/centralmap-bukrs.
  ENDSELECT.

  IF sy-subrc <> 0.
    value_out = '????'.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
