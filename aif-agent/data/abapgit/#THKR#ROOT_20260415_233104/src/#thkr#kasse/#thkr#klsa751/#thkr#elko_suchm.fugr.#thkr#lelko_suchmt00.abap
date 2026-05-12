*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/ELKO_SUCHM................................*
DATA:  BEGIN OF STATUS_/THKR/ELKO_SUCHM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/ELKO_SUCHM              .
CONTROLS: TCTRL_/THKR/ELKO_SUCHM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/ELKO_SUCHM              .
TABLES: /THKR/ELKO_SUCHM               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
