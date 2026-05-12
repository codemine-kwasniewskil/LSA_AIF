*&---------------------------------------------------------------------*
*& Include          /THKR/CHK_MIG_DUBLETTE_EGP_TOP                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& TOP-Include für Definitionen                                        *
*& Prüfung von Z001 - Einmal-GP zur Archivierung                       *
*& Prüfung von Z009 - MIG-Einmal-GP und Dubletten                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        25.02.2026                                            *
*&                                                                     *
*& l. Änderung:  10.03.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*

************************************************************************
* Globale TABLES                                                       *
************************************************************************
TABLES: kblk.

************************************************************************
* Gloable TYPEN - Daklaration                                          *
************************************************************************
TYPES: BEGIN OF ty_dbbut,
         partner      TYPE bu_partner,
         type         TYPE bu_type,
         bpkind       TYPE bu_bpkind,
         bpext        TYPE bu_bpext,
         bu_sort1     TYPE bu_sort1,
         /thkr/gsber  TYPE /thkr/dte_bu_gsber,
         /thkr/sst    TYPE /thkr/dte_bu_sst,
         name_last    TYPE bu_namep_l,
         name_first   TYPE bu_namep_f,
         name_org1    TYPE bu_nameor1,
         name_org2    TYPE bu_nameor2,
         partner_guid TYPE bu_partner_guid,
         not_avail    TYPE xchar,
       END OF ty_dbbut.

************************************************************************
* Gloable interne Tabellen                                             *
************************************************************************
DATA: gt_dbbut TYPE TABLE OF ty_dbbut.

************************************************************************
* Gloable Struktur                                                     *
************************************************************************
DATA: gs_dbbut  TYPE ty_dbbut.

************************************************************************
* Gloable Variablen                                                    *
************************************************************************
DATA: gv_string TYPE string,
      gv_tstmsg TYPE string,
      gv_maxsel TYPE i.

************************************************************************
* Gloable Feldsymbole                                                  *
************************************************************************
FIELD-SYMBOLS: <gfs_dbbut> TYPE ty_dbbut.

************************************************************************
* Gloable Konstantene                                                  *
************************************************************************
CONSTANTS: gc_tren(3) TYPE c VALUE ' | '.
