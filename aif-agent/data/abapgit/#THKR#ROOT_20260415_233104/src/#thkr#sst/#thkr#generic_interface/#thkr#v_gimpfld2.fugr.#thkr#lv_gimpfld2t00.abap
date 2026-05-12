*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GIMPFLD2................................*
TABLES: /THKR/V_GIMPFLD2, */THKR/V_GIMPFLD2. "view work areas
CONTROLS: TCTRL_/THKR/V_GIMPFLD2
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GIMPFLD2. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GIMPFLD2.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GIMPFLD2_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPFLD2.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPFLD2_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GIMPFLD2_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPFLD2.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPFLD2_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GIMPFLD                .
TABLES: /THKR/C_GIMPTAB                .
