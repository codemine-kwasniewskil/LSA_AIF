*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_GI_TEXT.................................*
DATA:  BEGIN OF STATUS_/THKR/C_GI_TEXT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_GI_TEXT               .
CONTROLS: TCTRL_/THKR/C_GI_TEXT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_GI_TEXT               .
TABLES: /THKR/C_GI_TEXT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
