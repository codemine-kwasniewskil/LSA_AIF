*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/GPSSTTXT..................................*
DATA:  BEGIN OF STATUS_/THKR/GPSSTTXT                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/GPSSTTXT                .
CONTROLS: TCTRL_/THKR/GPSSTTXT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/GPSSTTXT                .
TABLES: /THKR/GPSSTTXT                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
