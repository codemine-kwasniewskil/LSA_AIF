*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_FB02_TOP
*&---------------------------------------------------------------------*

TABLES: rf05l, bseg, bkpf, kna1, lfa1, T001, T042, t020.   "20210324_BTO

DATA: gs_bkpf TYPE bkpf,
      gs_bseg TYPE bseg,
      gt_texte type STANDARD TABLE OF bseg,
      gt_texte_changed type STANDARD TABLE OF bseg,
      gt_texte_helper type STANDARD TABLE OF bseg,
      gs_fb02 TYPE /THKR/FB02C,
      gt_fb02 TYPE TABLE OF /THKR/FB02C.

DATA: ok-code(5)   TYPE c.             "OK Code (Funktionscode)

DATA: gv_change TYPE xfeld,            "Änderung durch Benutzer
      gv_fehler TYPE xfeld,            "Eingaben sind fehlerhaft  24.03.2021_BTO
      gv_buzei  TYPE buzei.            "Aktuelle Buchungszeile

*DATA: gs_kommentar TYPE zfi_smfr_kmmnt_incl.
DATA gs_chdoc_ind TYPE c LENGTH 1.
DATA: lr_alv2 type REF TO cl_gui_alv_grid,
      lr_container2 TYPE REF TO cl_gui_custom_container.

*** begin of #001 ***
CONSTANTS: gc_tcode     TYPE sytcode VALUE '/THKR/FB02',
           "in BaWü
           gc_tcode_lok TYPE sytcode VALUE 'Z_FI_FB02_LOK',
           "in LSA
           gc_tcode_lhk TYPE sytcode VALUE '/THKR/FB02_LHK',

           gc_tcode_justiz TYPE sytcode VALUE '/THKR/FB02_JUS'.
*** end of #001 ***
