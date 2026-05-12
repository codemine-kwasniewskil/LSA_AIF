*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/GSBER_EXCE................................*
DATA:  BEGIN OF STATUS_/THKR/GSBER_EXCE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/GSBER_EXCE              .
CONTROLS: TCTRL_/THKR/GSBER_EXCE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/GSBER_EXCE              .
TABLES: /THKR/GSBER_EXCE               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
