FUNCTION /THKR/FEB_2_KONTIERUNG .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_AUGLV)
*"     REFERENCE(I_FEBEP) LIKE  FEBEP STRUCTURE  FEBEP
*"     REFERENCE(I_FEBKO) LIKE  FEBKO STRUCTURE  FEBKO
*"  TABLES
*"      T_FEBCL STRUCTURE  FEBCL
*"      T_FEBRE STRUCTURE  FEBRE
*"      T_FTCLEAR STRUCTURE  FTCLEAR
*"      T_FTPOST STRUCTURE  FTPOST
*"      T_FTTAX STRUCTURE  FTTAX
*"--------------------------------------------------------------------


*----------------------------------------------------------- neue Version mit einem Baustein
  CALL FUNCTION '/THKR/FEB_KONTIERUNG'
    EXPORTING
      i_auglv   = i_auglv
      i_febep   = i_febep
      i_febko   = i_febko
      i_area    = '2'                " Buchungsbereich 2
    TABLES
      t_febcl   = t_febcl
      t_febre   = t_febre
      t_ftclear = t_ftclear
      t_ftpost  = t_ftpost
      t_fttax   = t_fttax.

* Kontierung für Gutschriften kommt aus der Mittelvormerkung (Allg.AO)
  CALL FUNCTION '/THKR/FEB_KONTIERNG_ALLGAO_901'
    EXPORTING
      i_auglv   = i_auglv
      i_febep   = i_febep
      i_febko   = i_febko
      i_area    = '2'                " Buchungsbereich 2
    TABLES
      t_febcl   = t_febcl
      t_febre   = t_febre
      t_ftclear = t_ftclear
      t_ftpost  = t_ftpost
      t_fttax   = t_fttax.

* Kontierung für kred. Lastschriften kommt aus der Mittelvormerkung (Allg.AO)
  CALL FUNCTION '/THKR/FEB_KONTIERNG_ALLGAO_902'
    EXPORTING
      i_auglv   = i_auglv
      i_febep   = i_febep
      i_febko   = i_febko
      i_area    = '2'                " Buchungsbereich 2
    TABLES
      t_febcl   = t_febcl
      t_febre   = t_febre
      t_ftclear = t_ftclear
      t_ftpost  = t_ftpost
      t_fttax   = t_fttax.



ENDFUNCTION.
