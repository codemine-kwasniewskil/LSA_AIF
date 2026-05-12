*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CMAP_MIG..................................*
DATA:  BEGIN OF STATUS_/THKR/CMAP_MIG                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CMAP_MIG                .
CONTROLS: TCTRL_/THKR/CMAP_MIG
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CMAP_MIG                .
TABLES: /THKR/CMAP_MIG                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
