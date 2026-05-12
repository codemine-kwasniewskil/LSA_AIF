*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GIMPTAB.................................*
TABLES: /THKR/V_GIMPTAB, */THKR/V_GIMPTAB. "view work areas
CONTROLS: TCTRL_/THKR/V_GIMPTAB
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GIMPTAB. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GIMPTAB.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GIMPTAB_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPTAB.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPTAB_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GIMPTAB_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIMPTAB.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIMPTAB_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GIMPTAB                .
TABLES: /THKR/C_GI_MC                  .
