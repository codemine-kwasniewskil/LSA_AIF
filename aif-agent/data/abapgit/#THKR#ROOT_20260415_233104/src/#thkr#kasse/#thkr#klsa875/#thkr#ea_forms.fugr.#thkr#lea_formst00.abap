*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/EA_FO.....................................*
DATA:  BEGIN OF STATUS_/THKR/EA_FO                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/EA_FO                   .
CONTROLS: TCTRL_/THKR/EA_FO
            TYPE TABLEVIEW USING SCREEN '0010'.
*...processing: /THKR/EA_FO_ABS.................................*
DATA:  BEGIN OF STATUS_/THKR/EA_FO_ABS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/EA_FO_ABS               .
CONTROLS: TCTRL_/THKR/EA_FO_ABS
            TYPE TABLEVIEW USING SCREEN '0030'.
*...processing: /THKR/EA_FO_TB..................................*
DATA:  BEGIN OF STATUS_/THKR/EA_FO_TB                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/EA_FO_TB                .
CONTROLS: TCTRL_/THKR/EA_FO_TB
            TYPE TABLEVIEW USING SCREEN '0020'.
*...processing: /THKR/EA_FO_TYPE................................*
DATA:  BEGIN OF STATUS_/THKR/EA_FO_TYPE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/EA_FO_TYPE              .
CONTROLS: TCTRL_/THKR/EA_FO_TYPE
            TYPE TABLEVIEW USING SCREEN '0050'.
*...processing: /THKR/EA_FO_ZU..................................*
DATA:  BEGIN OF STATUS_/THKR/EA_FO_ZU                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/EA_FO_ZU                .
CONTROLS: TCTRL_/THKR/EA_FO_ZU
            TYPE TABLEVIEW USING SCREEN '0040'.
*.........table declarations:.................................*
TABLES: */THKR/EA_FO                   .
TABLES: */THKR/EA_FO_ABS               .
TABLES: */THKR/EA_FO_TB                .
TABLES: */THKR/EA_FO_TYPE              .
TABLES: */THKR/EA_FO_ZU                .
TABLES: /THKR/EA_FO                    .
TABLES: /THKR/EA_FO_ABS                .
TABLES: /THKR/EA_FO_TB                 .
TABLES: /THKR/EA_FO_TYPE               .
TABLES: /THKR/EA_FO_ZU                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
