*"----------------------------------------------------------------------
* Gereon Koks  TSI  7.11.2024
*"----------------------------------------------------------------------
* Map BU_BIRTHDT
* "Nomally" always 46_NAME2+56(8)
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{EMSA,...)
* VALUE_IN2 BTYP €{SST,FUA,...}
* VALUE_IN3 46_NAME2
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BLDAT
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_bu_birthdt.
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
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"--------------------------------------------------------------------
  DATA lv_length TYPE i.
*"----------------------------------------------------------------------
* Interface ?
  CASE value_in.
*"----------------------------------------------------------------------
    WHEN OTHERS.
* BTYP ?
      CASE value_in2.
        WHEN OTHERS.
          lv_length = strlen( value_in3 ).

          IF lv_length < 63.
            value_out = sy-datum.
          ELSE.
            value_out = value_in3+55(8).
          ENDIF.
      ENDCASE.
*"----------------------------------------------------------------------
  ENDCASE.
*"----------------------------------------------------------------------
  IF value_out IS INITIAL.
    value_out = 'not found'.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
