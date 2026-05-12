"Name: \PR:SAPLF150\FO:FILL_OUTPUTPARAMS\SE:END\EI
ENHANCEMENT 0 /THKR/SST_STORE_DUNNING.
"" for storing the pdf after dunning run we need the pdf:
IF is_itcpo-tddest = 'MHN'.
  xs_outputparams-getpdf = abap_true.
ENDIF.

ENDENHANCEMENT.
