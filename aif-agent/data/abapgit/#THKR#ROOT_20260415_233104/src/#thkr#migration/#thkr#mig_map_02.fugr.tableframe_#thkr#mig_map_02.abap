*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/THKR/MIG_MAP_02
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/THKR/MIG_MAP_02   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
