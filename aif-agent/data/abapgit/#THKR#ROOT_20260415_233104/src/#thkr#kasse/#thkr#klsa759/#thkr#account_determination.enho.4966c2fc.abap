"Name: \PR:RFEBBU00\FO:ACCOUNT_DETERMINATION\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/ACCOUNT_DETERMINATION.
DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).

lr_elko->set_hkont_leitweg( EXPORTING is_febko = febko
                                      is_febep = febep
                            CHANGING  xv_hkont = febko-hkont ).


ENDENHANCEMENT.
