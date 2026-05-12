*&---------------------------------------------------------------------*
*& Include ZXF01U01
*&---------------------------------------------------------------------*

DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).

* AVIK, AVIP und AVIR bei einer Teilzahlung speichern
lr_elko->save_avis_db( EXPORTING is_febep   = i_febep
                                 is_febko   = i_febko
                                 iv_testrun = i_testrun ).

* Zusatzkontierung setzen
lr_elko->set_kontierung( EXPORTING is_febep = i_febep
                                   is_febko = i_febko
                         CHANGING  xt_febcl = t_febcl[] ).
