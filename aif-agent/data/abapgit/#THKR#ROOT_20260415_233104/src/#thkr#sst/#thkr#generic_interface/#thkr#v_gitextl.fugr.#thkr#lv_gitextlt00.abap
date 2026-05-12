*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GITEXTL.................................*
TABLES: /THKR/V_GITEXTL, */THKR/V_GITEXTL. "view work areas
CONTROLS: TCTRL_/THKR/V_GITEXTL
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GITEXTL. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GITEXTL.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GITEXTL_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GITEXTL.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GITEXTL_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GITEXTL_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GITEXTL.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GITEXTL_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GITEXTL                .
TABLES: /THKR/C_GI_TEXT                .
