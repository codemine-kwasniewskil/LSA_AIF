*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C4A_AWGRP1................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_AWGRP1              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_AWGRP1              .
CONTROLS: TCTRL_/THKR/C4A_AWGRP1
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /THKR/C4A_AWGRP2................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_AWGRP2              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_AWGRP2              .
CONTROLS: TCTRL_/THKR/C4A_AWGRP2
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /THKR/C4A_BSCHL.................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_BSCHL               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_BSCHL               .
CONTROLS: TCTRL_/THKR/C4A_BSCHL
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: /THKR/C4A_BUKRSA................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_BUKRSA              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_BUKRSA              .
CONTROLS: TCTRL_/THKR/C4A_BUKRSA
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: /THKR/C4A_FLEXG1................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_FLEXG1              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_FLEXG1              .
CONTROLS: TCTRL_/THKR/C4A_FLEXG1
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: /THKR/C4A_FLEXG2................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_FLEXG2              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_FLEXG2              .
CONTROLS: TCTRL_/THKR/C4A_FLEXG2
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: /THKR/C4A_KTOIN1................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_KTOIN1              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_KTOIN1              .
CONTROLS: TCTRL_/THKR/C4A_KTOIN1
            TYPE TABLEVIEW USING SCREEN '0008'.
*...processing: /THKR/C4A_KTOIN2................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_KTOIN2              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_KTOIN2              .
CONTROLS: TCTRL_/THKR/C4A_KTOIN2
            TYPE TABLEVIEW USING SCREEN '0009'.
*...processing: /THKR/C4A_TAGRP1................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_TAGRP1              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_TAGRP1              .
CONTROLS: TCTRL_/THKR/C4A_TAGRP1
            TYPE TABLEVIEW USING SCREEN '0010'.
*...processing: /THKR/C4A_TAGRP2................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_TAGRP2              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_TAGRP2              .
CONTROLS: TCTRL_/THKR/C4A_TAGRP2
            TYPE TABLEVIEW USING SCREEN '0011'.
*...processing: /THKR/C4A_TCONTR................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_TCONTR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_TCONTR              .
CONTROLS: TCTRL_/THKR/C4A_TCONTR
            TYPE TABLEVIEW USING SCREEN '0012'.
*...processing: /THKR/C4A_USEREX................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_USEREX              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_USEREX              .
CONTROLS: TCTRL_/THKR/C4A_USEREX
            TYPE TABLEVIEW USING SCREEN '0013'.
*...processing: /THKR/C4A_VORGA1................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_VORGA1              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_VORGA1              .
CONTROLS: TCTRL_/THKR/C4A_VORGA1
            TYPE TABLEVIEW USING SCREEN '0014'.
*...processing: /THKR/C4A_VORGA2................................*
DATA:  BEGIN OF STATUS_/THKR/C4A_VORGA2              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C4A_VORGA2              .
CONTROLS: TCTRL_/THKR/C4A_VORGA2
            TYPE TABLEVIEW USING SCREEN '0015'.
*...processing: /THKR/CSSUBSTBAD................................*
DATA:  BEGIN OF STATUS_/THKR/CSSUBSTBAD              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CSSUBSTBAD              .
CONTROLS: TCTRL_/THKR/CSSUBSTBAD
            TYPE TABLEVIEW USING SCREEN '0016'.
*.........table declarations:.................................*
TABLES: */THKR/C4A_AWGRP1              .
TABLES: */THKR/C4A_AWGRP2              .
TABLES: */THKR/C4A_BSCHL               .
TABLES: */THKR/C4A_BUKRSA              .
TABLES: */THKR/C4A_FLEXG1              .
TABLES: */THKR/C4A_FLEXG2              .
TABLES: */THKR/C4A_KTOIN1              .
TABLES: */THKR/C4A_KTOIN2              .
TABLES: */THKR/C4A_TAGRP1              .
TABLES: */THKR/C4A_TAGRP2              .
TABLES: */THKR/C4A_TCONTR              .
TABLES: */THKR/C4A_USEREX              .
TABLES: */THKR/C4A_VORGA1              .
TABLES: */THKR/C4A_VORGA2              .
TABLES: */THKR/CSSUBSTBAD              .
TABLES: /THKR/C4A_AWGRP1               .
TABLES: /THKR/C4A_AWGRP2               .
TABLES: /THKR/C4A_BSCHL                .
TABLES: /THKR/C4A_BUKRSA               .
TABLES: /THKR/C4A_FLEXG1               .
TABLES: /THKR/C4A_FLEXG2               .
TABLES: /THKR/C4A_KTOIN1               .
TABLES: /THKR/C4A_KTOIN2               .
TABLES: /THKR/C4A_TAGRP1               .
TABLES: /THKR/C4A_TAGRP2               .
TABLES: /THKR/C4A_TCONTR               .
TABLES: /THKR/C4A_USEREX               .
TABLES: /THKR/C4A_VORGA1               .
TABLES: /THKR/C4A_VORGA2               .
TABLES: /THKR/CSSUBSTBAD               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
