*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_CU_BN_EMPF..................................*
DATA:  BEGIN OF STATUS_ZFI_CU_BN_EMPF                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_CU_BN_EMPF                .
CONTROLS: TCTRL_ZFI_CU_BN_EMPF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_CU_BN_EMPF                .
TABLES: ZFI_CU_BN_EMPF                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
