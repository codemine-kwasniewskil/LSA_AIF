"Name: \PR:SAPLFMRI\FO:DOC_PREPARE_COLLECT\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_STATKZ_SET.

"Setzen Statistikkennzeichen - EOL-043
CALL FUNCTION '/THKR/PSM_SET_STATSKZ'
    EXPORTING
      i_f_accit  = l_f_accit
    CHANGING
      ch_fmifiit = c_t_fmifiit.
ENDENHANCEMENT.
