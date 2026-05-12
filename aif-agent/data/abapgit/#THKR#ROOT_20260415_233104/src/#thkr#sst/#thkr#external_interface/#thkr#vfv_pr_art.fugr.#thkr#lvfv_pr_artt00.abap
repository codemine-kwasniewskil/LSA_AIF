*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/VFV_PR_ART................................*
TABLES: /THKR/VFV_PR_ART, */THKR/VFV_PR_ART. "view work areas
CONTROLS: TCTRL_/THKR/VFV_PR_ART
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/VFV_PR_ART. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/VFV_PR_ART.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/VFV_PR_ART_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/VFV_PR_ART.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/VFV_PR_ART_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/VFV_PR_ART_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/VFV_PR_ART.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/VFV_PR_ART_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/CFV                      .
TABLES: /THKR/CFV_PR_ART               .
