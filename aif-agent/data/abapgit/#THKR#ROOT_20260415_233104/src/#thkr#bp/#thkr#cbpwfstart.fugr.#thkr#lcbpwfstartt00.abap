*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CBPWFCHGDC................................*
DATA:  BEGIN OF STATUS_/THKR/CBPWFCHGDC              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CBPWFCHGDC              .
CONTROLS: TCTRL_/THKR/CBPWFCHGDC
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /THKR/CBPWFSTART................................*
DATA:  BEGIN OF STATUS_/THKR/CBPWFSTART              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CBPWFSTART              .
CONTROLS: TCTRL_/THKR/CBPWFSTART
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: /THKR/V_ACTFIELD................................*
TABLES: /THKR/V_ACTFIELD, */THKR/V_ACTFIELD. "view work areas
CONTROLS: TCTRL_/THKR/V_ACTFIELD
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF STATUS_/THKR/V_ACTFIELD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/V_ACTFIELD.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/V_ACTFIELD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_ACTFIELD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_ACTFIELD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/V_ACTFIELD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/V_ACTFIELD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/V_ACTFIELD_TOTAL.

*.........table declarations:.................................*
TABLES: */THKR/CBPWFCHGDC              .
TABLES: */THKR/CBPWFSTART              .
TABLES: /THKR/CBACTFIELD               .
TABLES: /THKR/CBPWFCHGDC               .
TABLES: /THKR/CBPWFSTART               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
