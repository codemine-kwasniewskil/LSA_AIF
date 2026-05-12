*&---------------------------------------------------------------------*
*& Include          /THKR/FI_IST_REPORT_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&       TABLES
*&---------------------------------------------------------------------*
TABLES: fmifiit.

*&---------------------------------------------------------------------*
*&       TYPES
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_alv_data,
    fmbelnr	TYPE fm_belnr,
    fikrs	  TYPE fikrs,
    fmbuzei	TYPE fm_buzei,
    btart	  TYPE fm_btart,
    rldnr	  TYPE rldnr,
    gjahr	  TYPE gjahr,
    stunr	  TYPE fm_stunr,
    fonds   TYPE bp_geber,
    kapitel	TYPE /thkr/fipos_kapitel,  "char4,
    titel	  TYPE /thkr/fipos_titel, "char5,
    trbtr	  TYPE fm_trbtr,
    twaer   TYPE twaer,
    monat   TYPE char6,
    hsart	  TYPE fm_hsart,
    unplan  TYPE boolean,
    zz_fkz  TYPE /thkr/fkz,
    text1	  TYPE fm_beschr0,
    text2	  TYPE fm_beschr2,
    text3	  TYPE fm_beschr3,
  END OF ty_alv_data,
  tt_alv_data TYPE TABLE OF ty_alv_data.

TYPES:
  BEGIN OF ty_alv_vein_hvw,
    belnr	      TYPE kblnr,
    blpos       TYPE kblpos,
    erdat	      TYPE kblerdat,
    fipos	      TYPE fipos_xpo,
    erldat      TYPE kblerldat,
    fdatk	      TYPE kblfdatk,
    wtges	      TYPE kblwtg,
    waers	      TYPE twaer,
    fikrs	      TYPE fikrs,
    gjahr	      TYPE gjahr,             "Jahr
    fipex       TYPE fm_fipex,          "Haushaltsstelle
    bezeichnung TYPE /thkr/fm_beschr,   "Titelbezeichnung
    zz_fkz      TYPE /thkr/fkz,         "Funktionsziffer
    betrag      TYPE ftb_amount,        "Betrag
    flagapl     TYPE /thkr/dte_flagapl, "FlagAPL,
  END OF ty_alv_vein_hvw,
  tt_alv_vein_hvw TYPE TABLE OF ty_alv_vein_hvw.

TYPES:
  BEGIN OF ty_alv_hvwng_data,
    fikrs	      TYPE fikrs,
    gjahr	      TYPE gjahr,             "Jahr
    fipex       TYPE fm_fipex,          "Haushaltsstelle
    bezeichnung TYPE /thkr/fm_beschr,   "Titelbezeichnung
    zz_fkz      TYPE /thkr/fkz,         "Funktionsziffer
    betrag      TYPE ftb_amount,        "Betrag
    flagapl     TYPE /thkr/dte_flagapl, "FlagAPL,
  END OF ty_alv_hvwng_data,
  tt_alv_hvwng_data TYPE TABLE OF ty_alv_hvwng_data.

TYPES:
  BEGIN OF ty_vein_pos,
    fdatk	 TYPE kblfdatk,
    fipex  TYPE fipex,
    belnr	 TYPE kblnr,
    blpos  TYPE kblpos,
    erdat	 TYPE kblerdat,
    fipos	 TYPE fipos_xpo,
    erldat TYPE kblerldat,
    wtges	 TYPE kblwtg,
    waers	 TYPE twaer,
  END OF ty_vein_pos,

  BEGIN OF ty_alv_vein,
    belnr	 TYPE kblnr,
    blpos  TYPE kblpos,
    erdat	 TYPE kblerdat,
    fipos	 TYPE fipos_xpo,
    text1  TYPE fm_beschr0,
    text2  TYPE fm_beschr2,
    text3  TYPE fm_beschr3,
    erldat TYPE kblerldat,
    fdatk	 TYPE kblfdatk,
    wtges	 TYPE kblwtg,
    waers	 TYPE twaer,
  END OF ty_alv_vein,
  tt_alv_vein TYPE TABLE OF ty_alv_vein,
  tt_vein_pos TYPE TABLE OF ty_vein_pos.

TYPES:
  BEGIN OF ty_alv_vaus,
    erdat  TYPE gjahr,
    fipex  TYPE char10,  "fm_fipex,          "Haushaltsstelle
    erldat TYPE gjahr,
    fdatk  TYPE gjahr,
    wtges	 TYPE char15,  "kblwtg,
  END OF ty_alv_vaus,
  tt_alv_vaus TYPE TABLE OF ty_alv_vaus,
  ts_alv_vaus TYPE ty_alv_vaus.

************************************************************************
* Type-Definition für die Summerung per Collect bei VE                 *
************************************************************************
TYPES:
  BEGIN OF ty_col_vaus,
    erdat  TYPE gjahr,
    fipex  TYPE char10,  "fm_fipex,          "Haushaltsstelle
    erldat TYPE gjahr,
    fdatk  TYPE gjahr,
    wtges	 TYPE kblwtg,
  END OF ty_col_vaus,
  tt_col_vaus TYPE TABLE OF ty_col_vaus,
  ts_col_vaus TYPE ty_col_vaus.

TYPES:
  BEGIN OF ty_persokh_data,
    fonds       TYPE char2,
    kapitel	    TYPE char4,
    titel	      TYPE char5,
    bezeichnung TYPE char255,
    trbtr	      TYPE fm_trbtr,
    monat       TYPE char6,
  END OF ty_persokh_data,
  tt_persokh_data TYPE TABLE OF ty_persokh_data.

TYPES:
  BEGIN OF ty_csv_persokh_data,
    fonds       TYPE char2,
    kapitel	    TYPE char4,
    titel	      TYPE char5,
    bezeichnung TYPE char255,
    trbtr	      TYPE char13,
    monat       TYPE char6,
  END OF ty_csv_persokh_data,
  tt_csv_persokh_data TYPE TABLE OF ty_csv_persokh_data.

TYPES:
  BEGIN OF ty_havweb_data,
    gjahr       TYPE gjahr,
    finpos      TYPE char10, "fm_fipex,
    bezeichnung TYPE /thkr/fm_beschr, "char255,
    zz_fkz      TYPE /thkr/fkz,
    trbtr	      TYPE fm_trbtr,
    unplan      TYPE boolean,
  END OF ty_havweb_data,
  tt_havweb_data TYPE TABLE OF ty_havweb_data.

TYPES:
  BEGIN OF ty_vein_data,
    erdat  TYPE gjahr,
    fdatk	 TYPE kblfdatk,
*    fipos  TYPE char10,
    fipex	 TYPE fipex,
    text1  TYPE fm_beschr0,
    text2  TYPE fm_beschr2,
    text3  TYPE fm_beschr3,
    erldat TYPE gjahr,
    wtges	 TYPE kblwtg,
    waers	 TYPE twaer,
  END OF ty_vein_data,
  tt_vein_data TYPE TABLE OF ty_vein_data.

TYPES:
  BEGIN OF ty_fmci_data,
    fikrs	 TYPE fikrs,
    gjahr	 TYPE gjahr,
    fipex	 TYPE fm_fipex,
    hsart  TYPE fm_hsart,
    zz_fkz TYPE /thkr/fkz,
    text1	 TYPE fm_beschr0,
    text2	 TYPE fm_beschr2,
    text3	 TYPE fm_beschr3,
  END OF ty_fmci_data.

TYPES:
  BEGIN OF ty_havweb_ng_data,
    gjahr	      TYPE gjahr,             "Jahr
    fipex       TYPE fm_fipex,          "Haushaltsstelle
    bezeichnung TYPE /thkr/fm_beschr,   "Titelbezeichnung
    zz_fkz      TYPE /thkr/fkz,         "Funktionsziffer
    betrag      TYPE ftb_amount,        "Betrag
    flagapl     TYPE /thkr/dte_flagapl, "FlagAPL,
  END OF ty_havweb_ng_data,
  tt_havweb_ng_data TYPE TABLE OF ty_havweb_ng_data.
