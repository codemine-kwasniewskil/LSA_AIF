*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CGRP2AKTO.................................*
DATA:  BEGIN OF STATUS_/THKR/CGRP2AKTO               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CGRP2AKTO               .
CONTROLS: TCTRL_/THKR/CGRP2AKTO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CGRP2AKTO               .
TABLES: /THKR/CGRP2AKTO                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
