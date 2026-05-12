*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GI_MC...................................*
TABLES: /THKR/V_GI_MC, */THKR/V_GI_MC. "view work areas
CONTROLS: TCTRL_/THKR/V_GI_MC
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GI_MC. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GI_MC.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GI_MC_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GI_MC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GI_MC_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GI_MC_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GI_MC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GI_MC_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GI                     .
TABLES: /THKR/C_GI_MC                  .
