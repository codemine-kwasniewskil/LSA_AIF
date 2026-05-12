*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.11.2024
*"----------------------------------------------------------------------
* Map IBAN
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{EMSA,...)
* VALUE_IN2 BTYP €{SST,FUA,...}
* VALUE_IN3 22_RES1
* VALUE_IN4 leer
* VALUE_IN5 leer
*"----------------------------------------------------------------------
* Output
* VALUE_OUT Wert des DTO-Feldes
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_bu_langu.
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
  DATA l_t005 TYPE t005.
*"----------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------
* Interface ?
  TRY.
      CASE value_in.

        WHEN OTHERS.
* BTYP ?
          CASE value_in2.
            WHEN OTHERS.
              value_out = value_in3+0(1).
          ENDCASE.
*"----------------------------------------------------------------------
      ENDCASE.
*"----------------------------------------------------------------------
      IF value_out IS INITIAL.
        value_out = 'not found'.
      ENDIF.
    CATCH cx_sy_range_out_of_bounds.
      "Feld 22_RES1 ist leer.
      "Kein Land zurückgeben.
      CLEAR: value_out.
  ENDTRY.
*"----------------------------------------------------------------------
ENDFUNCTION.
