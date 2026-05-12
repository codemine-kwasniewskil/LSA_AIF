*"----------------------------------------------------------------------
* Gereon Koks  TSI  16.10.2024
*"----------------------------------------------------------------------
* Map XEZER Einzugsermächtigung
*"----------------------------------------------------------------------
* Nur Bsp.
* Wird über Value-Mapping realisiert !
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{EMSA,...)
* VALUE_IN2 BTYP €{SST,FUA,...}
* VALUE_IN3 26_RES3
* VALUE_IN4 BIC-Feld 2
* VALUE_IN5 BIC-Feld 3
*"----------------------------------------------------------------------
* Output
* VALUE_OUT XEZER
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_xezer.
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
  IF NOT value_in3 IS INITIAL.
*"----------------------------------------------------------------------
* Interface ?
    CASE value_in.
*"----------------------------------------------------------------------
      WHEN OTHERS.
* BTYP ?
        CASE value_in2.
          WHEN OTHERS.
            CASE value_in3+18(1).
              WHEN 'J'.
                value_out = 'X'.
              WHEN 'N'.
                value_out = ''.
              WHEN OTHERS.
                value_out = ''.
            ENDCASE.
        ENDCASE.
*"----------------------------------------------------------------------
    ENDCASE.
*"----------------------------------------------------------------------
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
