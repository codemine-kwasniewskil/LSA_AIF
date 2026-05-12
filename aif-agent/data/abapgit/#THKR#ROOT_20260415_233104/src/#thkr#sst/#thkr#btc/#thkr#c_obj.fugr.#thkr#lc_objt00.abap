*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_OBJ.....................................*
DATA:  BEGIN OF STATUS_/THKR/C_OBJ                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_OBJ                   .
CONTROLS: TCTRL_/THKR/C_OBJ
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_OBJ                   .
TABLES: /THKR/C_OBJ                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
