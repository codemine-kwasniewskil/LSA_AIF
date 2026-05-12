*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CFV_PR_ART................................*
DATA:  BEGIN OF STATUS_/THKR/CFV_PR_ART              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CFV_PR_ART              .
CONTROLS: TCTRL_/THKR/CFV_PR_ART
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CFV_PR_ART              .
TABLES: /THKR/CFV_PR_ART               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
