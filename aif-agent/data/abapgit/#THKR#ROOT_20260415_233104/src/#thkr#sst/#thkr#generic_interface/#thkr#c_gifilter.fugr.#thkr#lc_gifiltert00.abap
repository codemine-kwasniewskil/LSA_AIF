*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_GIFILTER................................*
DATA:  BEGIN OF STATUS_/THKR/C_GIFILTER              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_GIFILTER              .
CONTROLS: TCTRL_/THKR/C_GIFILTER
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_GIFILTER              .
TABLES: /THKR/C_GIFILTER               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
