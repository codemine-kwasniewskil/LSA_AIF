*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/AO_US2SST.................................*
DATA:  BEGIN OF STATUS_/THKR/AO_US2SST               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/AO_US2SST               .
CONTROLS: TCTRL_/THKR/AO_US2SST
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: /THKR/CBLART2TXT................................*
DATA:  BEGIN OF STATUS_/THKR/CBLART2TXT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CBLART2TXT              .
CONTROLS: TCTRL_/THKR/CBLART2TXT
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /THKR/CWFAOSSTUS................................*
DATA:  BEGIN OF STATUS_/THKR/CWFAOSSTUS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CWFAOSSTUS              .
CONTROLS: TCTRL_/THKR/CWFAOSSTUS
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /THKR/WFAO_EXCEP................................*
DATA:  BEGIN OF STATUS_/THKR/WFAO_EXCEP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/WFAO_EXCEP              .
CONTROLS: TCTRL_/THKR/WFAO_EXCEP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/AO_US2SST               .
TABLES: */THKR/CBLART2TXT              .
TABLES: */THKR/CWFAOSSTUS              .
TABLES: */THKR/WFAO_EXCEP              .
TABLES: /THKR/AO_US2SST                .
TABLES: /THKR/CBLART2TXT               .
TABLES: /THKR/CWFAOSSTUS               .
TABLES: /THKR/WFAO_EXCEP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
