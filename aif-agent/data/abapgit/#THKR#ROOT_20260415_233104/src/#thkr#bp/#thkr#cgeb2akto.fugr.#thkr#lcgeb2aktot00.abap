*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CGEB2AKTO.................................*
DATA:  BEGIN OF STATUS_/THKR/CGEB2AKTO               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CGEB2AKTO               .
CONTROLS: TCTRL_/THKR/CGEB2AKTO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CGEB2AKTO               .
TABLES: /THKR/CGEB2AKTO                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
