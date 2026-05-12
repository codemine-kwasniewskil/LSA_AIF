*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/MIG_MAP_01................................*
DATA:  BEGIN OF STATUS_/THKR/MIG_MAP_01              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/MIG_MAP_01              .
CONTROLS: TCTRL_/THKR/MIG_MAP_01
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/MIG_MAP_01              .
TABLES: /THKR/MIG_MAP_01               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
