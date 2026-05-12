*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/MIG_MAP_03................................*
DATA:  BEGIN OF STATUS_/THKR/MIG_MAP_03              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/MIG_MAP_03              .
CONTROLS: TCTRL_/THKR/MIG_MAP_03
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/MIG_MAP_03              .
TABLES: /THKR/MIG_MAP_03               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
