*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/WF_CONTROL................................*
DATA:  BEGIN OF STATUS_/THKR/WF_CONTROL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/WF_CONTROL              .
CONTROLS: TCTRL_/THKR/WF_CONTROL
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /THKR/WF_FUNKT..................................*
DATA:  BEGIN OF STATUS_/THKR/WF_FUNKT                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/WF_FUNKT                .
CONTROLS: TCTRL_/THKR/WF_FUNKT
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /THKR/WF_TYPEN..................................*
DATA:  BEGIN OF STATUS_/THKR/WF_TYPEN                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/WF_TYPEN                .
CONTROLS: TCTRL_/THKR/WF_TYPEN
            TYPE TABLEVIEW USING SCREEN '0003'.
*.........table declarations:.................................*
TABLES: */THKR/WF_CONTROL              .
TABLES: */THKR/WF_FUNKT                .
TABLES: */THKR/WF_TYPEN                .
TABLES: /THKR/WF_CONTROL               .
TABLES: /THKR/WF_FUNKT                 .
TABLES: /THKR/WF_TYPEN                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
