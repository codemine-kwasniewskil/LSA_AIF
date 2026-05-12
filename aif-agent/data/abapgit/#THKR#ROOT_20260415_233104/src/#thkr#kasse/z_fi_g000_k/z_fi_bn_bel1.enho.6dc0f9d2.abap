"Name: \PR:SAPF110S\FO:AUSNAHMEN_AUSGEBEN\SE:BEGIN\EI
ENHANCEMENT 0 Z_FI_BN_BEL1.
* Tabelle YREGUP sichern
  data: lt_regup  type TABLE OF regup,
        ls_bnbel  type ZFI_F_BNBEL,
        ls_fherk  type ZFI_F_BNHERK.

  lt_regup = yregup[].

ENDENHANCEMENT.
