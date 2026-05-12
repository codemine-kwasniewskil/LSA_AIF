*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/MIG_MAP_02................................*
DATA:  BEGIN OF STATUS_/THKR/MIG_MAP_02              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/MIG_MAP_02              .
CONTROLS: TCTRL_/THKR/MIG_MAP_02
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/MIG_MAP_02              .
TABLES: /THKR/MIG_MAP_02               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
