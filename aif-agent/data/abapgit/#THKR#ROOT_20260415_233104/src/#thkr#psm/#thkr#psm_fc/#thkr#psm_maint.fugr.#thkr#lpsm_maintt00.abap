*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_FUND_DIS................................*
DATA:  BEGIN OF STATUS_/THKR/C_FUND_DIS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_FUND_DIS              .
CONTROLS: TCTRL_/THKR/C_FUND_DIS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_FUND_DIS              .
TABLES: /THKR/C_FUND_DIS               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
