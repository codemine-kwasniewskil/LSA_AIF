*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CO_LEIST..................................*
DATA:  BEGIN OF STATUS_/THKR/CO_LEIST                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CO_LEIST                .
CONTROLS: TCTRL_/THKR/CO_LEIST
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /THKR/CO_LEIST_D................................*
DATA:  BEGIN OF STATUS_/THKR/CO_LEIST_D              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CO_LEIST_D              .
CONTROLS: TCTRL_/THKR/CO_LEIST_D
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /THKR/CO_LEIST_L................................*
DATA:  BEGIN OF STATUS_/THKR/CO_LEIST_L              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CO_LEIST_L              .
CONTROLS: TCTRL_/THKR/CO_LEIST_L
            TYPE TABLEVIEW USING SCREEN '0003'.
*.........table declarations:.................................*
TABLES: */THKR/CO_LEIST                .
TABLES: */THKR/CO_LEIST_D              .
TABLES: */THKR/CO_LEIST_L              .
TABLES: /THKR/CO_LEIST                 .
TABLES: /THKR/CO_LEIST_D               .
TABLES: /THKR/CO_LEIST_L               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
