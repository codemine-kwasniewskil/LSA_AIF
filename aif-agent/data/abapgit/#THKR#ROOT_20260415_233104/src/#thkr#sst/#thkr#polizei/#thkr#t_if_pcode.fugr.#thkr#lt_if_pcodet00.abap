*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/T_IF_PCODE................................*
DATA:  BEGIN OF STATUS_/THKR/T_IF_PCODE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/T_IF_PCODE              .
CONTROLS: TCTRL_/THKR/T_IF_PCODE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/T_IF_PCODE              .
TABLES: /THKR/T_IF_PCODE               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
