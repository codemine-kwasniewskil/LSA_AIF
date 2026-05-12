*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/KF_DSRC...................................*
DATA:  BEGIN OF STATUS_/THKR/KF_DSRC                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KF_DSRC                 .
CONTROLS: TCTRL_/THKR/KF_DSRC
            TYPE TABLEVIEW USING SCREEN '2001'.
*...processing: /THKR/KF_FG_FLD.................................*
DATA:  BEGIN OF STATUS_/THKR/KF_FG_FLD               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KF_FG_FLD               .
CONTROLS: TCTRL_/THKR/KF_FG_FLD
            TYPE TABLEVIEW USING SCREEN '2010'.
*...processing: /THKR/KF_KF.....................................*
DATA:  BEGIN OF STATUS_/THKR/KF_KF                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KF_KF                   .
CONTROLS: TCTRL_/THKR/KF_KF
            TYPE TABLEVIEW USING SCREEN '2015'.
*...processing: /THKR/KF_KFDSRC.................................*
DATA:  BEGIN OF STATUS_/THKR/KF_KFDSRC               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KF_KFDSRC               .
CONTROLS: TCTRL_/THKR/KF_KFDSRC
            TYPE TABLEVIEW USING SCREEN '2007'.
*...processing: /THKR/KF_REPT_01................................*
TABLES: /THKR/KF_REPT_01, */THKR/KF_REPT_01. "view work areas
CONTROLS: TCTRL_/THKR/KF_REPT_01
TYPE TABLEVIEW USING SCREEN '2020'.
DATA: BEGIN OF STATUS_/THKR/KF_REPT_01. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/KF_REPT_01.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/KF_REPT_01_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/KF_REPT_01.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/KF_REPT_01_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/KF_REPT_01_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/KF_REPT_01.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/KF_REPT_01_TOTAL.

*...processing: /THKR/KF_REPT_02................................*
TABLES: /THKR/KF_REPT_02, */THKR/KF_REPT_02. "view work areas
CONTROLS: TCTRL_/THKR/KF_REPT_02
TYPE TABLEVIEW USING SCREEN '2025'.
DATA: BEGIN OF STATUS_/THKR/KF_REPT_02. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/KF_REPT_02.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/KF_REPT_02_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/KF_REPT_02.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/KF_REPT_02_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/KF_REPT_02_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/KF_REPT_02.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/KF_REPT_02_TOTAL.

*...processing: /THKR/KF_REPT_03................................*
TABLES: /THKR/KF_REPT_03, */THKR/KF_REPT_03. "view work areas
CONTROLS: TCTRL_/THKR/KF_REPT_03
TYPE TABLEVIEW USING SCREEN '2030'.
DATA: BEGIN OF STATUS_/THKR/KF_REPT_03. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/THKR/KF_REPT_03.
* Table for entries selected to show on screen
DATA: BEGIN OF /THKR/KF_REPT_03_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /THKR/KF_REPT_03.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/KF_REPT_03_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /THKR/KF_REPT_03_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /THKR/KF_REPT_03.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /THKR/KF_REPT_03_TOTAL.

*.........table declarations:.................................*
TABLES: */THKR/KF_DSRC                 .
TABLES: */THKR/KF_FG_FLD               .
TABLES: */THKR/KF_KF                   .
TABLES: */THKR/KF_KFDSRC               .
TABLES: */THKR/KF_KF_T                 .
TABLES: /THKR/KF_DSRC                  .
TABLES: /THKR/KF_FG_FLD                .
TABLES: /THKR/KF_KF                    .
TABLES: /THKR/KF_KFDSRC                .
TABLES: /THKR/KF_KF_T                  .
TABLES: /THKR/KF_REPTERM               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
