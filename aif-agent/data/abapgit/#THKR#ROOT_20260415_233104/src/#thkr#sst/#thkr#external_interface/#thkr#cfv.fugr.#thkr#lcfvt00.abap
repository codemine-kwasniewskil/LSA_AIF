*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CFV.......................................*
DATA:  BEGIN OF STATUS_/THKR/CFV                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CFV                     .
CONTROLS: TCTRL_/THKR/CFV
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CFV                     .
TABLES: /THKR/CFV                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
