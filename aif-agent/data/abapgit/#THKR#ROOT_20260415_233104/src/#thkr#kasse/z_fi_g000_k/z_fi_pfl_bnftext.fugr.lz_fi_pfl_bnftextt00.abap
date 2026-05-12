*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_CU_BN_FTEXT.................................*
DATA:  BEGIN OF STATUS_ZFI_CU_BN_FTEXT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_CU_BN_FTEXT               .
CONTROLS: TCTRL_ZFI_CU_BN_FTEXT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_CU_BN_FTEXT               .
TABLES: ZFI_CU_BN_FTEXT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
