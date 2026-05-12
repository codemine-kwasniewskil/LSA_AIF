*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GIMPVAL.................................*
TABLES: /THKR/V_GIMPVAL, */THKR/V_GIMPVAL. "view work areas
CONTROLS: TCTRL_/THKR/V_GIMPVAL
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GIMPVAL. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GIMPVAL.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GIMPVAL_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPVAL.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPVAL_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GIMPVAL_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPVAL.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPVAL_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GIMPVAL                .
