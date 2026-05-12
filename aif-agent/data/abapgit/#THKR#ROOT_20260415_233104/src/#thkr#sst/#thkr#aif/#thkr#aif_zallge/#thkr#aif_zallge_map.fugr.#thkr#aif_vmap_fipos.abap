*"----------------------------------------------------------------------
* Gereon Koks  TSI  2.6.2025
*"----------------------------------------------------------------------
* Map FIPEX nach FIPOS
*"----------------------------------------------------------------------
* Input
* VALUE_IN  @FIPEX
* VALUE_IN2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT @FIPOS
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_fipos.
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
  DATA: lv_fipex TYPE fm_fipex,
        lv_fipos TYPE fipos.
*"--------------------------------------------------------------------
  lv_fipex = value_in.
*"--------------------------------------------------------------------
  CALL FUNCTION 'FM_FIPOS_GET_FROM_FIPEX'
    EXPORTING
      i_fipex        = lv_fipex
    IMPORTING
      e_fipos        = lv_fipos
* TABLES
*     T_FMFXPO       =
    EXCEPTIONS
      input_error    = 1
      data_not_found = 2
      OTHERS         = 3.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    value_out = lv_fipos.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
