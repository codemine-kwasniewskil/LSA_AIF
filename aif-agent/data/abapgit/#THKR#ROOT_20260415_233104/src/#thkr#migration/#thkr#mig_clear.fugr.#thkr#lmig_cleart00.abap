*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/MIGDAOR...................................*
DATA:  BEGIN OF STATUS_/THKR/MIGDAOR                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/MIGDAOR                 .
CONTROLS: TCTRL_/THKR/MIGDAOR
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /THKR/MIG_AO_SAP................................*
DATA:  BEGIN OF STATUS_/THKR/MIG_AO_SAP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/MIG_AO_SAP              .
CONTROLS: TCTRL_/THKR/MIG_AO_SAP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/MIGDAOR                 .
TABLES: */THKR/MIG_AO_SAP              .
TABLES: /THKR/MIGDAOR                  .
TABLES: /THKR/MIG_AO_SAP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
