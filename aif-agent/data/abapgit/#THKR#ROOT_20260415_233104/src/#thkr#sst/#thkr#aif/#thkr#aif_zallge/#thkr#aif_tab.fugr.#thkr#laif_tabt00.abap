*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: /THKR/ANO_FIELDS................................*
DATA:  BEGIN OF STATUS_/THKR/ANO_FIELDS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/ANO_FIELDS              .
CONTROLS: TCTRL_/THKR/ANO_FIELDS
            TYPE TABLEVIEW USING SCREEN '9120'.
*...processing: /THKR/ANO_SET...................................*
DATA:  BEGIN OF STATUS_/THKR/ANO_SET                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/ANO_SET                 .
CONTROLS: TCTRL_/THKR/ANO_SET
            TYPE TABLEVIEW USING SCREEN '9030'.
*...processing: /THKR/ANO_SYSTEM................................*
DATA:  BEGIN OF STATUS_/THKR/ANO_SYSTEM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/ANO_SYSTEM              .
CONTROLS: TCTRL_/THKR/ANO_SYSTEM
            TYPE TABLEVIEW USING SCREEN '9040'.
*...processing: /THKR/ANO_ZUORD.................................*
DATA:  BEGIN OF STATUS_/THKR/ANO_ZUORD               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/ANO_ZUORD               .
CONTROLS: TCTRL_/THKR/ANO_ZUORD
            TYPE TABLEVIEW USING SCREEN '9020'.
*...processing: /THKR/AO_REF_BLA................................*
DATA:  BEGIN OF STATUS_/THKR/AO_REF_BLA              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/AO_REF_BLA              .
CONTROLS: TCTRL_/THKR/AO_REF_BLA
            TYPE TABLEVIEW USING SCREEN '9140'.
*...processing: /THKR/CHK_BTYP..................................*
DATA:  BEGIN OF STATUS_/THKR/CHK_BTYP                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/CHK_BTYP                .
CONTROLS: TCTRL_/THKR/CHK_BTYP
            TYPE TABLEVIEW USING SCREEN '9010'.
*...processing: /THKR/FILE_ASSGM................................*
DATA:  BEGIN OF STATUS_/THKR/FILE_ASSGM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/FILE_ASSGM              .
CONTROLS: TCTRL_/THKR/FILE_ASSGM
            TYPE TABLEVIEW USING SCREEN '9090'.
*...processing: /THKR/FILE_FLDS.................................*
DATA:  BEGIN OF STATUS_/THKR/FILE_FLDS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/FILE_FLDS               .
CONTROLS: TCTRL_/THKR/FILE_FLDS
            TYPE TABLEVIEW USING SCREEN '9100'.
*...processing: /THKR/FILE_PPROP................................*
DATA:  BEGIN OF STATUS_/THKR/FILE_PPROP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/FILE_PPROP              .
CONTROLS: TCTRL_/THKR/FILE_PPROP
            TYPE TABLEVIEW USING SCREEN '9070'.
*...processing: /THKR/FILE_PRFL.................................*
DATA:  BEGIN OF STATUS_/THKR/FILE_PRFL               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/FILE_PRFL               .
CONTROLS: TCTRL_/THKR/FILE_PRFL
            TYPE TABLEVIEW USING SCREEN '9060'.
*...processing: /THKR/GENERATION................................*
DATA:  BEGIN OF STATUS_/THKR/GENERATION              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/GENERATION              .
CONTROLS: TCTRL_/THKR/GENERATION
            TYPE TABLEVIEW USING SCREEN '9130'.
*...processing: /THKR/MAP_BLART.................................*
DATA:  BEGIN OF STATUS_/THKR/MAP_BLART               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/MAP_BLART               .
CONTROLS: TCTRL_/THKR/MAP_BLART
            TYPE TABLEVIEW USING SCREEN '9000'.
*...processing: /THKR/MAP_MWSKZ.................................*
DATA:  BEGIN OF STATUS_/THKR/MAP_MWSKZ               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/MAP_MWSKZ               .
CONTROLS: TCTRL_/THKR/MAP_MWSKZ
            TYPE TABLEVIEW USING SCREEN '9110'.
*...processing: /THKR/T_PROT_MSD................................*
DATA:  BEGIN OF STATUS_/THKR/T_PROT_MSD              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/THKR/T_PROT_MSD              .
CONTROLS: TCTRL_/THKR/T_PROT_MSD
            TYPE TABLEVIEW USING SCREEN '9050'.
*.........table declarations:.................................*
TABLES: */THKR/ANO_FIELDS              .
TABLES: */THKR/ANO_SET                 .
TABLES: */THKR/ANO_SYSTEM              .
TABLES: */THKR/ANO_ZUORD               .
TABLES: */THKR/AO_REF_BLA              .
TABLES: */THKR/CHK_BTYP                .
TABLES: */THKR/FILE_ASSGM              .
TABLES: */THKR/FILE_FLDS               .
TABLES: */THKR/FILE_PPROP              .
TABLES: */THKR/FILE_PRFL               .
TABLES: */THKR/GENERATION              .
TABLES: */THKR/MAP_BLART               .
TABLES: */THKR/MAP_MWSKZ               .
TABLES: */THKR/T_PROT_MSD              .
TABLES: /THKR/ANO_FIELDS               .
TABLES: /THKR/ANO_SET                  .
TABLES: /THKR/ANO_SYSTEM               .
TABLES: /THKR/ANO_ZUORD                .
TABLES: /THKR/AO_REF_BLA               .
TABLES: /THKR/CHK_BTYP                 .
TABLES: /THKR/FILE_ASSGM               .
TABLES: /THKR/FILE_FLDS                .
TABLES: /THKR/FILE_PPROP               .
TABLES: /THKR/FILE_PRFL                .
TABLES: /THKR/GENERATION               .
TABLES: /THKR/MAP_BLART                .
TABLES: /THKR/MAP_MWSKZ                .
TABLES: /THKR/T_PROT_MSD               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
