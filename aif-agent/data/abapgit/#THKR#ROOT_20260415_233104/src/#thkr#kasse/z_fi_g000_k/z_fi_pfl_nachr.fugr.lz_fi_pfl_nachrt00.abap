*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_BN_NACHRICHT................................*
DATA:  BEGIN OF STATUS_ZFI_BN_NACHRICHT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_BN_NACHRICHT              .
CONTROLS: TCTRL_ZFI_BN_NACHRICHT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_BN_NACHRICHT              .
TABLES: ZFI_BN_NACHRICHT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
