*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_TITELGRP................................*
DATA:  BEGIN OF STATUS_/THKR/C_TITELGRP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_TITELGRP              .
CONTROLS: TCTRL_/THKR/C_TITELGRP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/C_TITELGRP              .
TABLES: /THKR/C_TITELGRP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
