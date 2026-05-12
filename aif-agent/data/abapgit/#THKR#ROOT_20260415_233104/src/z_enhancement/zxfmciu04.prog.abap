*&---------------------------------------------------------------------*
*& Include          ZXFMCIU04
*&---------------------------------------------------------------------*
e_f_fmxci_cus-zz_fkz      = ifmcidy-zz_fkz.
e_f_fmxci_cus-zz_tg       = ifmcidy-zz_tg.
e_f_fmxci_cus-zz_non_avk  = ifmcidy-zz_non_avk.
e_f_fmxci_cus-zz_apl      = ifmcidy-zz_apl.

IF ifmcidy-zz_oz1 <> TEXT-ioz.
  e_f_fmxci_cus-zz_oz1  = ifmcidy-zz_oz1.
ENDIF.
IF ifmcidy-zz_oz2 <> TEXT-ioz.
  e_f_fmxci_cus-zz_oz2  = ifmcidy-zz_oz2.
ENDIF.
IF ifmcidy-zz_oz3 <> TEXT-ioz.
  e_f_fmxci_cus-zz_oz3  = ifmcidy-zz_oz3.
ENDIF.
IF ifmcidy-zz_oz4 <> TEXT-ioz.
  e_f_fmxci_cus-zz_oz4  = ifmcidy-zz_oz4.
ENDIF.
IF ifmcidy-zz_oz5 <> TEXT-ioz.
  e_f_fmxci_cus-zz_oz5  = ifmcidy-zz_oz5.
ENDIF.
IF ifmcidy-zz_uz1 <> TEXT-ioz.
  e_f_fmxci_cus-zz_uz1  = ifmcidy-zz_uz1.
ENDIF.
