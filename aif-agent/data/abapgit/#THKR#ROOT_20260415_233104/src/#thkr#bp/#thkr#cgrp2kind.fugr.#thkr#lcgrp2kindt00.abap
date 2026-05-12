*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CGRP2KIND.................................*
DATA:  BEGIN OF STATUS_/THKR/CGRP2KIND               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CGRP2KIND               .
CONTROLS: TCTRL_/THKR/CGRP2KIND
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CGRP2KIND               .
TABLES: /THKR/CGRP2KIND                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
