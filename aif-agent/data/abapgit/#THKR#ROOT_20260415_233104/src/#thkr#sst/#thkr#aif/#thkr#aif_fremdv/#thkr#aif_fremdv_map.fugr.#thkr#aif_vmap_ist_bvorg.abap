FUNCTION /thkr/aif_vmap_ist_bvorg.
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
  "VALUE_in = Kassenzeichen
  "Value_in2 = Buchungskreis
  "Value_in3 = Geschäftsjahr
  IF value_in IS NOT INITIAL.
    SELECT bk~xblnr AS  xblnr, LAST_VALUE( bk~belnr ) OVER( PARTITION BY xblnr ORDER BY belnr ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS belnr,
      fm~fmbelnr
      FROM bkpf AS bk
    INNER JOIN fmifiit AS fm
      ON fm~knbelnr = bk~belnr
      WHERE bk~xblnr = @value_in
        AND bk~bukrs = @value_in2
        AND fm~gjahr = @value_in3
        AND fm~wrttp = '57'
      ORDER BY fm~stunr ASCENDING
      INTO TABLE @DATA(lt_belnr).
    IF sy-subrc <> 0.
      CLEAR value_out.
    ELSE.
      DATA(lv_belnr) = lt_belnr[ 1 ]-belnr.
      SELECT SINGLE bvorg
        FROM bkpf
        WHERE xblnr = @value_in
          AND belnr = @lv_belnr
    INTO @value_out.
    ENDIF.
  ELSE.
    value_out = value_in3.
  ENDIF.
ENDFUNCTION.
