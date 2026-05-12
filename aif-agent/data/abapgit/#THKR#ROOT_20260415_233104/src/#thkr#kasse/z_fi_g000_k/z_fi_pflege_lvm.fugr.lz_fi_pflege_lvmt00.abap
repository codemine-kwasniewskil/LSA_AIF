*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_BNKA........................................*
DATA:  BEGIN OF STATUS_ZFI_BNKA                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_BNKA                      .
CONTROLS: TCTRL_ZFI_BNKA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_BNKA                      .
TABLES: ZFI_BNKA                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
