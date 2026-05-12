*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_GI_REC..................................*
DATA:  BEGIN OF STATUS_/THKR/C_GI_REC                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_GI_REC                .
CONTROLS: TCTRL_/THKR/C_GI_REC
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: */THKR/C_GI_REC                .
TABLES: /THKR/C_GI_REC                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
