*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_/THKR/KLSA646_TF
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_/THKR/KLSA646_TF   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
