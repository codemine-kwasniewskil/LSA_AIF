FUNCTION /thkr/klsa966_get_incl.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_BUKRS) TYPE  BUKRS
*"     REFERENCE(IV_BELNR) TYPE  BELNR_D
*"     REFERENCE(IV_GJAHR) TYPE  GJAHR
*"     REFERENCE(IV_LOTKZ) TYPE  LOTKZ OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_KLSA966_INCL) TYPE  /THKR/S_KLSA966_INCL
*"----------------------------------------------------------------------

  STATICS: lv_bukrs TYPE bukrs,
           lv_belnr TYPE belnr_d,
           lv_gjahr TYPE gjahr.

* Pro Beleg einmal lesen & überschreiben
  IF ( lv_bukrs <> iv_bukrs ) OR
     ( lv_belnr <> iv_belnr ) OR
     ( lv_gjahr <> iv_gjahr ).
* ---
    lv_bukrs = iv_bukrs.
    lv_belnr = iv_belnr.
    lv_gjahr = iv_gjahr.
* ---
    CLEAR: /thkr/s_klsa966_incl.
* --- Von DB lesen
    SELECT SINGLE z_vzskz z_intrate z_009
      FROM bkpf
      INTO (/thkr/s_klsa966_incl-z_vzskz, /thkr/s_klsa966_incl-z_intrate, /thkr/s_klsa966_incl-z_009 )
      WHERE bukrs = iv_bukrs
        AND belnr = iv_belnr
        AND gjahr = iv_gjahr.
*
  ENDIF.

  IF iv_lotkz IS NOT INITIAL
  AND /thkr/s_klsa966_incl IS INITIAL.
    "** DauerAO
    SELECT SINGLE FROM psokpf
        FIELDS z_intrate
        WHERE lotkz = @iv_lotkz
          and bukrs = @iv_bukrs
        INTO @/thkr/s_klsa966_incl-z_intrate.
  ENDIF.

*** Return
  es_klsa966_incl     = /thkr/s_klsa966_incl.
ENDFUNCTION.
