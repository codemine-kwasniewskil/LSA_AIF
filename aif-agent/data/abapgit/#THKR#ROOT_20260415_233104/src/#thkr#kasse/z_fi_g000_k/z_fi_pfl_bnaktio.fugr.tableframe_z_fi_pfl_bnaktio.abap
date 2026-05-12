*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_Z_FI_PFL_BNAKTIO
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_Z_FI_PFL_BNAKTIO   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
