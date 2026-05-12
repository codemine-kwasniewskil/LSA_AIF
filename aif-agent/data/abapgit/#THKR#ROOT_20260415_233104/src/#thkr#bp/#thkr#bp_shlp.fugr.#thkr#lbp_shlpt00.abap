*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CBPF4STDEX................................*
DATA:  BEGIN OF STATUS_/THKR/CBPF4STDEX              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CBPF4STDEX              .
CONTROLS: TCTRL_/THKR/CBPF4STDEX
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CBPF4STDEX              .
TABLES: /THKR/CBPF4STDEX               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
