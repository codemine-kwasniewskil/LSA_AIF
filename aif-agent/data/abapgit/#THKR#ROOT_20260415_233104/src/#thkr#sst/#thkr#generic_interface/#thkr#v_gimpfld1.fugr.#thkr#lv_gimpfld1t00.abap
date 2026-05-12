*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GIMPFLD1................................*
TABLES: /THKR/V_GIMPFLD1, */THKR/V_GIMPFLD1. "view work areas
CONTROLS: TCTRL_/THKR/V_GIMPFLD1
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GIMPFLD1. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GIMPFLD1.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GIMPFLD1_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPFLD1.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPFLD1_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GIMPFLD1_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPFLD1.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPFLD1_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GI                     .
TABLES: /THKR/C_GIMPFLD                .
TABLES: /THKR/C_GI_MC                  .
