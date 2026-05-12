*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_GI......................................*
DATA:  BEGIN OF STATUS_/THKR/C_GI                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_GI                    .
CONTROLS: TCTRL_/THKR/C_GI
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_GI                    .
TABLES: /THKR/C_GI                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
