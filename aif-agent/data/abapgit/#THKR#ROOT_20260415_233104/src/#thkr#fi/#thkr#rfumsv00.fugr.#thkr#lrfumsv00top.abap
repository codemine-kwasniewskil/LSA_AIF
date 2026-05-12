FUNCTION-POOL /thkr/rfumsv00.               "MESSAGE-ID ..
DATA: h_nvv(01) TYPE c.                                     "gaa150222
DATA: fs_glflex   LIKE  fagl_bseg_ext.
DATA: fs_glflexm  LIKE  fagl_bseg_ext.
TYPES:

 BEGIN OF ty_bkpf_bset.
TYPES:
  bktxt     TYPE bktxt,
  xmwst     TYPE xmwst,
  xblnr     TYPE xblnr1,
  kursf     TYPE kursf,
  xblnr_alt TYPE xblnr_alt,
  vatdate   TYPE vatdate,
  reindat   TYPE reindat,                                   "2438600
  txkrs     TYPE txkrs_bkpf,                                "2616036
  ctxkrs    TYPE txkrs_bkpf,                                "2616036
  monat     TYPE monat,
  awtyp     TYPE awtyp,
  awkey     TYPE awkey,
  awsys     TYPE logsystem,
  stblg     TYPE stblg,
  stjah     TYPE stjah,
  tcode     TYPE tcode,
  stgrd     TYPE stgrd,
  numpg     TYPE j_1anopg,
  xref1_hd  TYPE xref1_hd,
  blart     TYPE blart,
  budat     TYPE budat,
  bldat     TYPE bldat,
  waers     TYPE waers,
  bukrs     TYPE bset-bukrs,
  belnr     TYPE  bset-belnr,
  gjahr     TYPE  bset-gjahr,
  buzei     TYPE  bset-buzei,
  mwskz     TYPE  bset-mwskz,
  hkont     TYPE  bset-hkont,
  txgrp     TYPE  bset-txgrp,
  shkzg     TYPE  bset-shkzg,
  egbld     TYPE  bset-egbld,
  eglld     TYPE  bset-eglld,
  hwbas     TYPE  bset-hwbas,
  fwbas     TYPE  bset-fwbas,
  hwste     TYPE  bset-hwste,
  fwste     TYPE  bset-fwste,
  ktosl     TYPE  bset-ktosl,
  stceg     TYPE  bset-stceg,
  kschl     TYPE  bset-kschl,
  stmdt     TYPE  bset-stmdt,
  stmti     TYPE  bset-stmti,
  kbetr     TYPE  bset-kbetr,
  lstml     TYPE  bset-lstml,
  lwste     TYPE  bset-lwste,
  bupla     TYPE  bset-bupla,
  taxps     TYPE  bset-taxps,
  lwbas     TYPE  bset-lwbas.
TYPES END OF ty_bkpf_bset.
