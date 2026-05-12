*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/CGRP2AUGRP................................*
DATA:  BEGIN OF STATUS_/THKR/CGRP2AUGRP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CGRP2AUGRP              .
CONTROLS: TCTRL_/THKR/CGRP2AUGRP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */THKR/CGRP2AUGRP              .
TABLES: /THKR/CGRP2AUGRP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
