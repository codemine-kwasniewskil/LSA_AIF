*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: Z_MAINT_PAYAC01.................................*
TABLES: Z_MAINT_PAYAC01, *Z_MAINT_PAYAC01. "view work areas
CONTROLS: TCTRL_Z_MAINT_PAYAC01
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_Z_MAINT_PAYAC01. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_Z_MAINT_PAYAC01.
* Table for entries selected to show on screen
DATA: BEGIN OF Z_MAINT_PAYAC01_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE Z_MAINT_PAYAC01.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF Z_MAINT_PAYAC01_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF Z_MAINT_PAYAC01_TOTAL OCCURS 0010.
INCLUDE STRUCTURE Z_MAINT_PAYAC01.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF Z_MAINT_PAYAC01_TOTAL.

*.........table declarations:.................................*
TABLES: PAYAC01                        .
