*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/V_GIFRULE.................................*
TABLES: /THKR/V_GIFRULE, */THKR/V_GIFRULE. "view work areas
CONTROLS: TCTRL_/THKR/V_GIFRULE
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/THKR/V_GIFRULE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_GIFRULE.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_GIFRULE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIFRULE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIFRULE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_GIFRULE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_GIFRULE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_GIFRULE_TOTAL.

*.........table declarations:.................................*
TABLES: /THKR/C_GIFRULE                .
