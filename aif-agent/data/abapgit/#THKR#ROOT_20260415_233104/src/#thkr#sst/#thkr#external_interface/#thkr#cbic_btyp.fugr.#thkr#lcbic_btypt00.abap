*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CBIC_BTYP.................................*
DATA:  BEGIN OF STATUS_/THKR/CBIC_BTYP               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CBIC_BTYP               .
CONTROLS: TCTRL_/THKR/CBIC_BTYP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CBIC_BTYP               .
TABLES: /THKR/CBIC_BTYP                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
