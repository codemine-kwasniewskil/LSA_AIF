FUNCTION-POOL /thkr/fi_apar_sepa_mandate.   "MESSAGE-ID ..

CONSTANTS:
* BOR Objects
  BEGIN OF gc_bor,
    araccount   TYPE swo_objtyp VALUE 'BUS3007',   " Debitor
    companycode TYPE swo_objtyp VALUE 'BUS0002',   " Buchungskreis
    bseg        TYPE swo_objtyp VALUE 'BSEG',      " Belegreferenz
  END OF gc_bor,

* Mandate status
  BEGIN OF gc_status,
    created  TYPE c VALUE '0',
    active   TYPE c VALUE '1',
    wait     TYPE c VALUE '2',   " Wait for approval
    blocked  TYPE c VALUE '3',
    canceled TYPE c VALUE '4',
    obsolete TYPE c VALUE '5',
    closed   TYPE c VALUE '6',
  END OF gc_status,

* Miscellaneous
  gc_dfpm_numb_obj(6) TYPE c          VALUE 'BF_MND',
  gc_anwnd_fi         TYPE sepa_anwnd VALUE 'F'.

DATA:
  gs_fix_data TYPE sepa_mandate.   " Unchangeable fields

DATA:
  gh_kunnr  TYPE kunnr,        " Debtor number
  gh_zbukr  TYPE dzbukr,       " Paying company code
  gh_docref TYPE fsepa_ref_belnr. "document reference, note 1611602

DATA:
  go_badi        TYPE REF TO fi_sepa_mandate.
* INCLUDE /THKR/LFI_APAR_SEPA_MANDATED...    " Local class definition
