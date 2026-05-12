FUNCTION-POOL /THKR/BP_SHLP              MESSAGE-ID SV.

TYPES: BEGIN OF t_ex.
         INCLUDE TYPE /thkr/cbpf4stdex.
TYPES: not_exist TYPE flag,
       END OF t_ex.

DATA: std_exits TYPE TABLE OF t_ex with key mandt, suchhilfe.

DATA: gv_backup_max TYPE i.

* INCLUDE /THKR/LBP_SHLPD...                 " Local class definition
  INCLUDE LSVIMDAT                                . "general data decl.
  INCLUDE /THKR/LBP_SHLPT00                       . "view rel. data dcl.
