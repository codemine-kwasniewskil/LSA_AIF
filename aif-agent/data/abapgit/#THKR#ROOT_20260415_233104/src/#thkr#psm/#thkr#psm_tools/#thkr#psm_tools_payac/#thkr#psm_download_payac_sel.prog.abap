*&---------------------------------------------------------------------*
*& Include          Z_PSM_DOWNLOAD_PAYAC_SEL
*&---------------------------------------------------------------------*


* Modus
selection-screen begin of block modu with frame title text-101.
* ---
    parameters: p_f_db radiobutton group fkt default 'X'.
    selection-screen skip.
  parameters: p_f_jw radiobutton group fkt.
    parameters: p_gj_neu type gjahr.

selection-screen end   of block modu.




* PAYAC01
selection-screen begin of block paya with frame title text-102.
* ---
* ---
  parameters: p_gjahr type gjahr obligatory.
  select-options: s_bukfm for payac01-bukfm.
*
selection-screen end   of block paya.


* FMCI
selection-screen begin of block fmci with frame title text-103.
* ---
  parameters:
              p_fikrs type fikrs obligatory DEFAULT '1000',
              p_druck type fm_druck.
* ---
" select-options: s_zwfvm for fmci-zzwfverm.
*
selection-screen end   of block fmci.


* Datei
selection-screen begin of block file with frame title text-111.
* ---
  parameters: p_datnam type localfile obligatory.
*
selection-screen end of block file.
* ---

  selection-screen skip.
* ---
  parameters: p_test as checkbox default 'X'.
selection-screen skip.

parameters: p_maxlin type sytabix default 1000.
