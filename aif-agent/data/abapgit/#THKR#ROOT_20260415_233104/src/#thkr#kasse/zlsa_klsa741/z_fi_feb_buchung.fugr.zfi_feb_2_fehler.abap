FUNCTION zfi_feb_2_fehler .
*"----------------------------------------------------------------------
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
*"----------------------------------------------------------------------


  CALL FUNCTION 'ZFI_FEB_2_BUCHUNG'
    EXPORTING
      i_auglv   = i_auglv
      i_febep   = i_febep
      i_febko   = i_febko
    TABLES
      t_febcl   = t_febcl
      t_febre   = t_febre
      t_ftclear = t_ftclear
      t_ftpost  = t_ftpost
      t_fttax   = t_fttax.


ENDFUNCTION.
