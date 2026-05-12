*&---------------------------------------------------------------------*
*& Include          ZXFMCU21
*&---------------------------------------------------------------------*
data: lv_kaz type /thkr/d_kassenzeichen.
data: ls_kblk_kaz type /thkr/kblk_kaz.
*break zhm000000091.
get parameter id '/THKR/KLSA841_KBLK' field lv_kaz.
set parameter id '/THKR/KLSA841_KBLK' field ''.
if lv_kaz <> ''.
*update kblk set xblnr = lv_kaz where BELNR = i_f_kblk-belnr.
  ls_kblk_kaz-belnr = i_f_kblk-belnr.
  ls_kblk_kaz-xblnr = lv_kaz.
  insert /thkr/kblk_kaz from ls_kblk_kaz.
endif.
