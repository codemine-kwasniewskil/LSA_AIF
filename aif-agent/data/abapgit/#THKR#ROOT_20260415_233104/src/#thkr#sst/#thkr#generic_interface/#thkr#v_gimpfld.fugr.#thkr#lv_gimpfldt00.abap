*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GIMPFLD.................................*
TABLES: /THKR/V_GIMPFLD, */THKR/V_GIMPFLD. "view work areas
CONTROLS: TCTRL_/THKR/V_GIMPFLD
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GIMPFLD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GIMPFLD.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GIMPFLD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPFLD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPFLD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GIMPFLD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPFLD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPFLD_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GI                     .
TABLES: /THKR/C_GIMPFLD                .
TABLES: /THKR/C_GI_MC                  .
