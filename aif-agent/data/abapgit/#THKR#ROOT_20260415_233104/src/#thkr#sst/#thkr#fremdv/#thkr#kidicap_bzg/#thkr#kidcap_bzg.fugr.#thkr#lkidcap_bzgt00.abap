*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/KIDCAP_BZG................................*
DATA:  BEGIN OF STATUS_/THKR/KIDCAP_BZG              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KIDCAP_BZG              .
CONTROLS: TCTRL_/THKR/KIDCAP_BZG
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: */THKR/KIDCAP_BZG              .
TABLES: /THKR/KIDCAP_BZG               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
