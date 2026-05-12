*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CBPDEFCTRY................................*
DATA:  BEGIN OF STATUS_/THKR/CBPDEFCTRY              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CBPDEFCTRY              .
CONTROLS: TCTRL_/THKR/CBPDEFCTRY
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CBPDEFCTRY              .
TABLES: /THKR/CBPDEFCTRY               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
