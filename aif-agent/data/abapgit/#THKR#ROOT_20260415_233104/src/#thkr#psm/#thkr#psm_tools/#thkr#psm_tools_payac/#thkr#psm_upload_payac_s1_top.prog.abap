*&---------------------------------------------------------------------*
*& Include /THKR/PSM_UPLOAD_PAYAC_S1_TOP
*&---------------------------------------------------------------------*

* Variablen
DATA: gv_fehler TYPE xfeld.

* Type-Pools
TYPE-POOLS: icon.

* Typen
TYPES: gts_upload TYPE /thkr/psm_upl_payac,
       gtt_upload TYPE TABLE OF gts_upload.

* Strukturen
DATA: gs_upload TYPE /thkr/psm_upl_payac.

* Tabellen
DATA: gt_upload TYPE gtt_upload.

* Konstanten
CONSTANTS: gc_fikrs TYPE fikrs VALUE '1000',   "Finanzkreis
           gc_ktopl TYPE ktopl VALUE 'VKP'.    "Kontenplan

CONSTANTS: gc_green  TYPE icon_d VALUE '@08@', "grüne Ampel
           gc_yellow TYPE icon_d VALUE '@09@', "gelbe Ampel
           gc_red    TYPE icon_d VALUE '@0A@'. "rote Ampel

*
DATA: gv_upl_tmp TYPE sydbcnt.
