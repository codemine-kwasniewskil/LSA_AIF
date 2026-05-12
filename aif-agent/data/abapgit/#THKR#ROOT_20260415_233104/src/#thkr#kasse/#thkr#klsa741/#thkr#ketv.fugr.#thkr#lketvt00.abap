*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/KASSZ_KETV................................*
TABLES: /THKR/KASSZ_KETV, */THKR/KASSZ_KETV. "view work areas
CONTROLS: TCTRL_/THKR/KASSZ_KETV
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/KASSZ_KETV. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/KASSZ_KETV.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/KASSZ_KETV_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/KASSZ_KETV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/KASSZ_KETV_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/KASSZ_KETV_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/KASSZ_KETV.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/KASSZ_KETV_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/KASSZ_KETT               .
