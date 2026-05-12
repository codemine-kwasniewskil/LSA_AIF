"Name: \PR:SAPMF05A\FO:BSCHL_KONTO_BEARBEITUNG\SE:END\EI
ENHANCEMENT 0 /THKR/FI_SAPMF05A_SGTXT_TEILZ.
DATA: lv_teilz TYPE c.
IMPORT lv_teilz TO lv_teilz FROM MEMORY ID 'TEILZ_DEBI'.
IF bseg-sgtxt IS INITIAL AND bseg-koart EQ 'D' AND lv_teilz EQ abap_true.
  bseg-sgtxt = rf05a-augtx.        " 50 statt 13
ENDIF.
ENDENHANCEMENT.
