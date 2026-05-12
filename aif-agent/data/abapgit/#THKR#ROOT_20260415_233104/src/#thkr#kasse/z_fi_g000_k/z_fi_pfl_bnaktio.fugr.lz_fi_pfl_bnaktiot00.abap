*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_CU_BN_AKTION................................*
DATA:  BEGIN OF STATUS_ZFI_CU_BN_AKTION              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_CU_BN_AKTION              .
CONTROLS: TCTRL_ZFI_CU_BN_AKTION
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_CU_BN_AKTION              .
TABLES: ZFI_CU_BN_AKTION               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
