*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_GIRECFLD................................*
DATA:  BEGIN OF STATUS_/THKR/C_GIRECFLD              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_GIRECFLD              .
CONTROLS: TCTRL_/THKR/C_GIRECFLD
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_GIRECFLD              .
TABLES: /THKR/C_GIRECFLD               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
