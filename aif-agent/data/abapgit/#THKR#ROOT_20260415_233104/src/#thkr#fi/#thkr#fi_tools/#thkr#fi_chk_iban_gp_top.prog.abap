*&---------------------------------------------------------------------*
*& Include          /THKR/FI_CHK_IBAN_GP_TOP                           *
*&---------------------------------------------------------------------*
*& Beschreibung:                                                       *
*&                                                                     *
*& TOP - Include für die Definition von Datenelemeten für den Bericht  *
*& von IBAN und Geschäftspartnern aus Schnittstellen                   *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:       Frank Brähler (Orexes GmbH)                            *
*& Anlage:      21.01.2026                                             *
*&                                                                     *
*& Änderer:     Frank Brähler                                          *
*& l.Datum:     05.02.2026                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

************************************************************************
* Tables (ERP nicht S4/HANA                                            *
************************************************************************
TABLES: /thkr/gpssttxt,
        bkpf.

************************************************************************
* Globale Ranges mit Zeilen                                            *
************************************************************************
DATA: gra_blart TYPE RANGE OF blart,
      gsa_blart LIKE LINE OF gra_blart.

************************************************************************
* Globale Tabellentypen                                                *
************************************************************************
DATA: gt_bkpf TYPE TABLE OF bkpf,
      gt_bseg TYPE TABLE OF bseg,
      gt_alv  TYPE /thkr/fi_tools_t_iban_gp_alv,
      gt_sum  TYPE /thkr/fi_tools_t_iban_sum.

************************************************************************
* Globale Strukturen                                                   *
************************************************************************
DATA: gs_bseg TYPE bseg,
      gs_gp   TYPE but000,
      gs_gbbk TYPE but0bk,
      gs_alv  TYPE /thkr/fi_tools_s_iban_gp_alv,
      gs_sum  TYPE /thkr/fi_tools_s_iban_sum.

************************************************************************
* Globale Variablen                                                    *
************************************************************************
DATA: gv_int       TYPE i,
      gv_bank_i    TYPE i,
      gv_partner   TYPE bu_partner,
      gv_w_message TYPE c,
      gv_iban      TYPE bu_iban.

************************************************************************
* Feldsymbole                                                          *
************************************************************************
FIELD-SYMBOLS: <gfs_bkpf> TYPE bkpf,
               <gfs_bseg> TYPE bseg,
               <gfs_alv>  TYPE /thkr/fi_tools_s_iban_gp_alv.

************************************************************************
* Objekte - Klassen                                                    *
************************************************************************
