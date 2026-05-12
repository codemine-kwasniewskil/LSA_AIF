*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_FB02_JUS................................*
DATA:  BEGIN OF STATUS_/THKR/C_FB02_JUS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_FB02_JUS              .
CONTROLS: TCTRL_/THKR/C_FB02_JUS
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /THKR/C_TPBR_PAR................................*
DATA:  BEGIN OF STATUS_/THKR/C_TPBR_PAR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_TPBR_PAR              .
CONTROLS: TCTRL_/THKR/C_TPBR_PAR
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /THKR/DB_VE_MAP.................................*
DATA:  BEGIN OF STATUS_/THKR/DB_VE_MAP               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/DB_VE_MAP               .
CONTROLS: TCTRL_/THKR/DB_VE_MAP
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: */THKR/C_FB02_JUS              .
TABLES: */THKR/C_TPBR_PAR              .
TABLES: */THKR/DB_VE_MAP               .
TABLES: /THKR/C_FB02_JUS               .
TABLES: /THKR/C_TPBR_PAR               .
TABLES: /THKR/DB_VE_MAP                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
