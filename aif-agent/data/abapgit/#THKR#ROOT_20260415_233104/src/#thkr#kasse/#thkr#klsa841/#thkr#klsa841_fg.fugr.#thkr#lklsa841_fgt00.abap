*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/T_KASS....................................*
DATA:  BEGIN OF STATUS_/THKR/T_KASS                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/T_KASS                  .
CONTROLS: TCTRL_/THKR/T_KASS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/T_KASS                  .
TABLES: /THKR/T_KASS                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
