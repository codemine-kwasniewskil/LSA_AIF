*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/T_EDAS_OWR................................*
DATA:  BEGIN OF STATUS_/THKR/T_EDAS_OWR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/T_EDAS_OWR              .
CONTROLS: TCTRL_/THKR/T_EDAS_OWR
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /THKR/T_RKO_ERR.................................*
DATA:  BEGIN OF STATUS_/THKR/T_RKO_ERR               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/T_RKO_ERR               .
CONTROLS: TCTRL_/THKR/T_RKO_ERR
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: */THKR/T_EDAS_OWR              .
TABLES: */THKR/T_RKO_ERR               .
TABLES: /THKR/T_EDAS_OWR               .
TABLES: /THKR/T_RKO_ERR                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
