*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_FKZ.....................................*
DATA:  BEGIN OF STATUS_/THKR/C_FKZ                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_FKZ                   .
CONTROLS: TCTRL_/THKR/C_FKZ
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_FKZ                   .
TABLES: /THKR/C_FKZ                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
