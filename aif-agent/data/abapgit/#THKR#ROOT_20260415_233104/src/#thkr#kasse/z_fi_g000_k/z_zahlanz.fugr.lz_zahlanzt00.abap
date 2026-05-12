*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_CU_BN_AKTION................................*
DATA:  BEGIN OF STATUS_ZFI_CU_BN_AKTION              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_CU_BN_AKTION              .
CONTROLS: TCTRL_ZFI_CU_BN_AKTION
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZFI_CU_BN_EMPF..................................*
DATA:  BEGIN OF STATUS_ZFI_CU_BN_EMPF                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_CU_BN_EMPF                .
CONTROLS: TCTRL_ZFI_CU_BN_EMPF
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZFI_CU_BN_FTEXT.................................*
DATA:  BEGIN OF STATUS_ZFI_CU_BN_FTEXT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_CU_BN_FTEXT               .
CONTROLS: TCTRL_ZFI_CU_BN_FTEXT
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZFI_CU_BN_AKTION              .
TABLES: *ZFI_CU_BN_EMPF                .
TABLES: *ZFI_CU_BN_FTEXT               .
TABLES: ZFI_CU_BN_AKTION               .
TABLES: ZFI_CU_BN_EMPF                 .
TABLES: ZFI_CU_BN_FTEXT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
