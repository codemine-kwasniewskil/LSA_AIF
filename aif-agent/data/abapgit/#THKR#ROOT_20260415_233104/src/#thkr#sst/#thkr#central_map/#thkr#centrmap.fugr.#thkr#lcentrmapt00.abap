*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CENTRALMAP................................*
DATA:  BEGIN OF STATUS_/THKR/CENTRALMAP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CENTRALMAP              .
CONTROLS: TCTRL_/THKR/CENTRALMAP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CENTRALMAP              .
TABLES: /THKR/CENTRALMAP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
