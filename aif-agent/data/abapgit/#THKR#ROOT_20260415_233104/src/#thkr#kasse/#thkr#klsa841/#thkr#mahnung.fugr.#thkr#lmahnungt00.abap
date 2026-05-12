*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/ANZ_MAHNDR................................*
DATA:  BEGIN OF STATUS_/THKR/ANZ_MAHNDR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/ANZ_MAHNDR              .
CONTROLS: TCTRL_/THKR/ANZ_MAHNDR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/ANZ_MAHNDR              .
TABLES: /THKR/ANZ_MAHNDR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
