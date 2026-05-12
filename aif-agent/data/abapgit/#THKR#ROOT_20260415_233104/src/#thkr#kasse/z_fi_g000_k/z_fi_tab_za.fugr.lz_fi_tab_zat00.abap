*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_ZA..........................................*
DATA:  BEGIN OF STATUS_ZFI_ZA                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_ZA                        .
CONTROLS: TCTRL_ZFI_ZA
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFI_ZA                        .
TABLES: ZFI_ZA                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
