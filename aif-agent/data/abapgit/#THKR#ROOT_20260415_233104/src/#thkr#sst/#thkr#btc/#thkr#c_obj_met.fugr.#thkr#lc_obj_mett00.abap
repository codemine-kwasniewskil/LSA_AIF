*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_OBJ_MET.................................*
DATA:  BEGIN OF STATUS_/THKR/C_OBJ_MET               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_OBJ_MET               .
CONTROLS: TCTRL_/THKR/C_OBJ_MET
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_OBJ_MET               .
TABLES: /THKR/C_OBJ_MET                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
