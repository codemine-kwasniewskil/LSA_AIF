FUNCTION /thkr/aif_vmap_ane_finance .
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
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(RAW_STRUCT)
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------


  CLEAR value_out.

  IF value_in <> ''.
    DATA belnr TYPE kblnr.
    SELECT SINGLE belnr, bukrs, fikrs FROM kblk INTO ( @belnr, @DATA(lv_burks), @DATA(lv_fikrs) ) WHERE ktext = @value_in.
  ENDIF.

  IF value_in2 = 'BELNR'.
    value_out = belnr.
  ELSEIF value_in2 = 'BUKRS'.
    value_out = lv_burks.
  ELSEIF value_in2 = 'FIKRS'.
    value_out = lv_fikrs.
  ELSEIF value_in2 = 'FISTL'.
    SELECT SINGLE fistl FROM kblp INTO @value_out WHERE belnr = @belnr.
  ELSEIF value_in2 = 'FIPEX'.
    SELECT SINGLE fipex FROM kblp INTO @value_out WHERE belnr = @belnr.
  ELSEIF value_in2 = 'GSBER'.
    SELECT SINGLE gsber FROM kblp INTO @value_out WHERE belnr = @belnr.
  ELSEIF value_in2 = 'HKONT'.
    SELECT SINGLE saknr FROM kblp INTO @value_out WHERE belnr = @belnr.
  ELSEIF value_in2 = 'KOSTL'.
    SELECT SINGLE kostl FROM kblp INTO @value_out WHERE belnr = @belnr.
  ELSEIF value_in2 = 'MWSKZ'.
    SELECT SINGLE zz_mwskz FROM kblp INTO @value_out WHERE belnr = @belnr.
  ENDIF.

*"----------------------------------------------------------------------
ENDFUNCTION.
