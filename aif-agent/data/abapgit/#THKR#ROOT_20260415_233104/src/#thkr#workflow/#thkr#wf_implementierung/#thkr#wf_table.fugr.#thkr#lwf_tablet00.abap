*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/T_WF_PARAM................................*
DATA:  BEGIN OF STATUS_/THKR/T_WF_PARAM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/T_WF_PARAM              .
CONTROLS: TCTRL_/THKR/T_WF_PARAM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/T_WF_PARAM              .
TABLES: /THKR/T_WF_PARAM               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
