*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/C_CONVERTS................................*
DATA:  BEGIN OF STATUS_/THKR/C_CONVERTS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/C_CONVERTS              .
CONTROLS: TCTRL_/THKR/C_CONVERTS
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /THKR/KASSPRAEFI................................*
DATA:  BEGIN OF STATUS_/THKR/KASSPRAEFI              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KASSPRAEFI              .
CONTROLS: TCTRL_/THKR/KASSPRAEFI
            TYPE TABLEVIEW USING SCREEN '0009'.
*...processing: /THKR/KASSZ_KETT................................*
DATA:  BEGIN OF STATUS_/THKR/KASSZ_KETT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KASSZ_KETT              .
CONTROLS: TCTRL_/THKR/KASSZ_KETT
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /THKR/KB_BETR...................................*
DATA:  BEGIN OF STATUS_/THKR/KB_BETR                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KB_BETR                 .
CONTROLS: TCTRL_/THKR/KB_BETR
            TYPE TABLEVIEW USING SCREEN '0010'.
*...processing: /THKR/KB_BLART..................................*
DATA:  BEGIN OF STATUS_/THKR/KB_BLART                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KB_BLART                .
CONTROLS: TCTRL_/THKR/KB_BLART
            TYPE TABLEVIEW USING SCREEN '0012'.
*...processing: /THKR/KB_BUCH...................................*
DATA:  BEGIN OF STATUS_/THKR/KB_BUCH                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KB_BUCH                 .
CONTROLS: TCTRL_/THKR/KB_BUCH
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: /THKR/KB_CO.....................................*
DATA:  BEGIN OF STATUS_/THKR/KB_CO                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KB_CO                   .
CONTROLS: TCTRL_/THKR/KB_CO
            TYPE TABLEVIEW USING SCREEN '0011'.
*...processing: /THKR/KONTIERG_K................................*
DATA:  BEGIN OF STATUS_/THKR/KONTIERG_K              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KONTIERG_K              .
CONTROLS: TCTRL_/THKR/KONTIERG_K
            TYPE TABLEVIEW USING SCREEN '0013'.
*...processing: /THKR/KONTIERUNG................................*
DATA:  BEGIN OF STATUS_/THKR/KONTIERUNG              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/KONTIERUNG              .
CONTROLS: TCTRL_/THKR/KONTIERUNG
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: /THKR/TILG_MABER................................*
DATA:  BEGIN OF STATUS_/THKR/TILG_MABER              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/TILG_MABER              .
CONTROLS: TCTRL_/THKR/TILG_MABER
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: /THKR/TILG_RANGF................................*
DATA:  BEGIN OF STATUS_/THKR/TILG_RANGF              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/TILG_RANGF              .
CONTROLS: TCTRL_/THKR/TILG_RANGF
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /THKR/VERW_BR...................................*
DATA:  BEGIN OF STATUS_/THKR/VERW_BR                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/VERW_BR                 .
CONTROLS: TCTRL_/THKR/VERW_BR
            TYPE TABLEVIEW USING SCREEN '0008'.
*...processing: /THKR/VERW_KZ...................................*
DATA:  BEGIN OF STATUS_/THKR/VERW_KZ                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/VERW_KZ                 .
CONTROLS: TCTRL_/THKR/VERW_KZ
            TYPE TABLEVIEW USING SCREEN '0005'.
*.........table declarations:.................................*
TABLES: */THKR/C_CONVERTS              .
TABLES: */THKR/KASSPRAEFI              .
TABLES: */THKR/KASSZ_KETT              .
TABLES: */THKR/KB_BETR                 .
TABLES: */THKR/KB_BLART                .
TABLES: */THKR/KB_BUCH                 .
TABLES: */THKR/KB_CO                   .
TABLES: */THKR/KONTIERG_K              .
TABLES: */THKR/KONTIERUNG              .
TABLES: */THKR/TILG_MABER              .
TABLES: */THKR/TILG_RANGF              .
TABLES: */THKR/VERW_BR                 .
TABLES: */THKR/VERW_KZ                 .
TABLES: /THKR/C_CONVERTS               .
TABLES: /THKR/KASSPRAEFI               .
TABLES: /THKR/KASSZ_KETT               .
TABLES: /THKR/KB_BETR                  .
TABLES: /THKR/KB_BLART                 .
TABLES: /THKR/KB_BUCH                  .
TABLES: /THKR/KB_CO                    .
TABLES: /THKR/KONTIERG_K               .
TABLES: /THKR/KONTIERUNG               .
TABLES: /THKR/TILG_MABER               .
TABLES: /THKR/TILG_RANGF               .
TABLES: /THKR/VERW_BR                  .
TABLES: /THKR/VERW_KZ                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
