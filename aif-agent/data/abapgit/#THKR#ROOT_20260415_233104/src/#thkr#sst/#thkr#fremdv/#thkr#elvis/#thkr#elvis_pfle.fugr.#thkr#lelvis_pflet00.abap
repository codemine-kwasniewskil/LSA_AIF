*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CU_SST_WM.................................*
DATA:  BEGIN OF STATUS_/THKR/CU_SST_WM               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CU_SST_WM               .
CONTROLS: TCTRL_/THKR/CU_SST_WM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CU_SST_WM               .
TABLES: /THKR/CU_SST_WM                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
