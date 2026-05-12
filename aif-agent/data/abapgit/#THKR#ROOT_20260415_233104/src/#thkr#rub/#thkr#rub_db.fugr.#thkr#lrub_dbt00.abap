*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/PSM_V_ACT.................................*
DATA:  BEGIN OF STATUS_/THKR/PSM_V_ACT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/PSM_V_ACT               .
CONTROLS: TCTRL_/THKR/PSM_V_ACT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/PSM_V_ACT               .
TABLES: /THKR/PSM_V_ACT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
