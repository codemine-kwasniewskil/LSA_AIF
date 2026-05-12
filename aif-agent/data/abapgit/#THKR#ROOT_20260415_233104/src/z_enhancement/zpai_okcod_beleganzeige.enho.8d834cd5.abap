"Name: \PR:SAPMF05L\FO:PAI_OKCOD_BELEGANZEIGE\SE:BEGIN\EI
ENHANCEMENT 0 ZPAI_OKCOD_BELEGANZEIGE.
data lv_activity type aCTIV_AUTH.
*
  CASE sy-ucomm.

    WHEN 'ZINS'.
      Case t020-aktyp.
        when 'A'.
          lv_activity = '03'.
        When 'H'.
          lv_activity = '01'.
        when 'V'.
          lv_activity = '02'.
        endcase.

      CALL FUNCTION '/THKR/KLSA966_CALL_SCREEN_9010'
        EXPORTING
          iv_bukrs          = bkpf-bukrs
          iv_belnr          = bkpf-belnr
          iv_gjahr          = bkpf-gjahr
          iv_activity       = lv_activity.
                .

      clear sy-ucomm.
      clear ok-code.

  ENDCASE.

ENDENHANCEMENT.
