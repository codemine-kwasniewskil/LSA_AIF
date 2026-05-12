*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GIMCPAR.................................*
TABLES: /THKR/V_GIMCPAR, */THKR/V_GIMCPAR. "view work areas
CONTROLS: TCTRL_/THKR/V_GIMCPAR
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GIMCPAR. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GIMCPAR.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GIMCPAR_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMCPAR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMCPAR_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GIMCPAR_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMCPAR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMCPAR_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GIMCPAR                .
TABLES: /THKR/C_GI_MC                  .
