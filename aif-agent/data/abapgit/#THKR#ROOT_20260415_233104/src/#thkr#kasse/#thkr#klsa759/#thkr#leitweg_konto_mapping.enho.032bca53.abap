"Name: \TY:CL_FEB_BSPROC_BS\ME:GET_DETAILS\SE:END\EI
ENHANCEMENT 0 /THKR/LEITWEG_KONTO_MAPPING.
DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).
CHECK i_esnum IS NOT INITIAL.
SELECT SINGLE * FROM febep INTO @DATA(ls_febep_iban)
  WHERE kukey = @mv_kukey
    AND esnum = @i_esnum.

lr_elko->set_hkont_leitweg( EXPORTING is_febko = e_febko
                                      is_febep = ls_febep_iban
                            CHANGING  xv_hkont = e_febko-hkont ).
ENDENHANCEMENT.
