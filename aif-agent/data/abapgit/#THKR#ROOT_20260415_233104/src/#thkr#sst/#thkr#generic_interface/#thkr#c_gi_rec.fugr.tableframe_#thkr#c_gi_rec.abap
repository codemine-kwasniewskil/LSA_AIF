*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/THKR/C_GI_REC
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/THKR/C_GI_REC     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
