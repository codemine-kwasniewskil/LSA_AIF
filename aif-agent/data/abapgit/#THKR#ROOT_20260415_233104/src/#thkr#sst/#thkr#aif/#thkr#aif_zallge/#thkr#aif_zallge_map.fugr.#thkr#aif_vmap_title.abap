*"----------------------------------------------------------------------
* Gereon Koks  TSI  26.11.2024
*"----------------------------------------------------------------------
* Input
* VALUE_IN  BU_TYPE
* VALUE_IN2 46_NAME2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BUDAT
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_title.
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
  CASE value_in.
* Natürliche Person
    WHEN '1'.
      "Anredeschlüssel steht an  55 stelle des Felds 46_NAME2.
      TRY.
          CASE value_in2+54(1).
            WHEN 'M' OR '1'. "Herr
              value_out = '0002'.
            WHEN 'W' OR '2'. "Frau
              value_out = '0001'.
            WHEN OTHERS.
              value_out = '0002'.
          ENDCASE.
        CATCH cx_sy_range_out_of_bounds.
          value_out = '0002'.
      ENDTRY.
* Organisation
    WHEN '2'. "Firma
      value_out = '0003'.
    WHEN OTHERS.
  ENDCASE.
*"----------------------------------------------------------------------
ENDFUNCTION.
