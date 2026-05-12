*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_FK_FO_TB....................................*
DATA:  BEGIN OF STATUS_ZFI_FK_FO_TB                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_FK_FO_TB                  .
CONTROLS: TCTRL_ZFI_FK_FO_TB
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFI_FK_FO_TB                  .
TABLES: ZFI_FK_FO_TB                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
