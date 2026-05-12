*&---------------------------------------------------------------------*
*& Include Z_PSM_DOWNLOAD_PAYACTOP
*&---------------------------------------------------------------------*

*
TABLES: payac01,
        fmci.

* View
DATA: gt_payac01_d_v TYPE STANDARD TABLE OF /thkr/psmpayac01.

* Download: Tabelle
DATA: gt_dl_paya_01 TYPE /thkr/t_psm_dl_paya_01.

* Download: SUBRC
DATA: gv_dl_subrc TYPE sysubrc.

* Alle Treffer im View gem. Selektion
DATA: gv_dbcnt_alle TYPE sydbcnt.
