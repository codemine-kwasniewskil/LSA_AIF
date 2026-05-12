*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GI_PAR..................................*
TABLES: /THKR/V_GI_PAR, */THKR/V_GI_PAR. "view work areas
CONTROLS: TCTRL_/THKR/V_GI_PAR
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GI_PAR. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GI_PAR.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GI_PAR_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GI_PAR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GI_PAR_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GI_PAR_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GI_PAR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GI_PAR_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GI_PAR                 .
