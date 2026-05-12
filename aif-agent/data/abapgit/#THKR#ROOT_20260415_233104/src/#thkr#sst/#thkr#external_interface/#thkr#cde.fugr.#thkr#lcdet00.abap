*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CDE.......................................*
DATA:  BEGIN OF STATUS_/THKR/CDE                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CDE                     .
*.........table declarations:.................................*
TABLES: */THKR/CDE                     .
TABLES: /THKR/CDE                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
