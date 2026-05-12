FUNCTION /thkr/bcs_keyfigures_text_read.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_T_KEYFIGS) TYPE  FMKF_KFTAB
*"  EXPORTING
*"     REFERENCE(E_T_KEYFIG_TEXT) TYPE  FMKF_KFTXTTAB
*"----------------------------------------------------------------------


  SELECT name heading keyfig INTO CORRESPONDING FIELDS OF TABLE e_t_keyfig_text
                                 FROM /thkr/kf_kf_t                              " zcbb_bukf_kf_t -  Kennzahlen - Texte für Kennzahlen
                                 FOR ALL ENTRIES IN i_t_keyfigs
                             WHERE keyfig = i_t_keyfigs-keyfig
                               AND langu  = sy-langu
                               AND applic = con_applic.



ENDFUNCTION.
