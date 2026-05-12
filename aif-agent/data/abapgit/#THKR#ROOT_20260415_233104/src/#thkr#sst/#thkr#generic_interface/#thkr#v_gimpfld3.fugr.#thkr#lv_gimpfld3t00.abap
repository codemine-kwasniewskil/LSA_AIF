*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GIMPFLD3................................*
TABLES: /THKR/V_GIMPFLD3, */THKR/V_GIMPFLD3. "view work areas
CONTROLS: TCTRL_/THKR/V_GIMPFLD3
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GIMPFLD3. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GIMPFLD3.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GIMPFLD3_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPFLD3.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPFLD3_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GIMPFLD3_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPFLD3.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPFLD3_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GIMPFLD                .
