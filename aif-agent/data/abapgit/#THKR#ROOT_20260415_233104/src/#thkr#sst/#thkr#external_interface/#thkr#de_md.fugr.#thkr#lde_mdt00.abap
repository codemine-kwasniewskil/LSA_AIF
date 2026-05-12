*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/DE_MD.....................................*
DATA:  BEGIN OF STATUS_/THKR/DE_MD                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/DE_MD                   .
*.........table declarations:.................................*
TABLES: */THKR/DE_MD                   .
TABLES: /THKR/DE_MD                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
