*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CROLLE_GRP................................*
DATA:  BEGIN OF STATUS_/THKR/CROLLE_GRP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CROLLE_GRP              .
CONTROLS: TCTRL_/THKR/CROLLE_GRP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CROLLE_GRP              .
TABLES: /THKR/CROLLE_GRP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
