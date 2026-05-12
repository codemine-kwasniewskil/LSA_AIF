*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/MIG_MD....................................*
DATA:  BEGIN OF STATUS_/THKR/MIG_MD                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/MIG_MD                  .
*.........table declarations:.................................*
TABLES: */THKR/MIG_MD                  .
TABLES: /THKR/MIG_MD                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
