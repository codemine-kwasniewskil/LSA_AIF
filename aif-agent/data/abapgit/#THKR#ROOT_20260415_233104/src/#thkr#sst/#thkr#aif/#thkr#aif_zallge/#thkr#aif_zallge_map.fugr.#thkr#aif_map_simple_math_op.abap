FUNCTION /thkr/aif_map_simple_math_op.
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
  "Feld value_in = 1. Operant
  "Feld value_in2 = math. Operation
  "Feld value_in3 = 2. Operant

  DATA: lv_operant_1 TYPE i.
  DATA: lv_operant_2 TYPE i.

  IF value_in CO '0123456789' AND value_in3 CO '0123456789'.
    "Check input are only numbers
    lv_operant_1 = value_in.
    lv_operant_2 = value_in3.

    CASE value_in2.
      WHEN: 'ADD'.
        "Addition
        value_out = lv_operant_1 + lv_operant_2.
      WHEN: 'SUB'.
        "Subtraction
        value_out = lv_operant_1 - lv_operant_2.
      WHEN: 'MUL'.
        "Multiplication
        value_out = lv_operant_1 * lv_operant_2.
      WHEN: 'DIV'.
        "division
        TRY.
            value_out = lv_operant_1 / lv_operant_2.
          CATCH cx_sy_zerodivide .
            CLEAR: value_out.
        ENDTRY.
      WHEN: 'MOD'.
        "Modulus
        value_out = lv_operant_1 MOD lv_operant_2.
      WHEN: OTHERS.
        CLEAR: value_out.
    ENDCASE.
  ELSE.
    CLEAR value_out.
  ENDIF.



ENDFUNCTION.
