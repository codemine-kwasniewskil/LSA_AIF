FUNCTION-POOL /thkr/f0kc MESSAGE-ID f4.                  "MESSAGE-ID ..

* ---- Tables: --------------------------------------------------------*
TABLES: vbkpf,
        vbsegs,
        vbsegk,
        vbsegd,
        rsdsexpr,
        bkpf,
        bseg,
        bsis,
        bsik,
        bsak,
        bsid,
        bsad,
        psokpf,
        psosegs,
        psosegd,
        psosegk,
        rfdt,
        dd03l,
        tnro,
        nriv.

DATA: c_vbkpf,
      c_vbsegs,
      c_vbsegk,
      c_vbsegd,
      c_bkpf,
      c_bsis,
      c_bsik,
      c_bsak,
      c_bsid,
      c_bsad.

* ---- Type-Pools:*----------------------------------------------------*
TYPE-POOLS: fipso,       "/fuer Zahlungsanordnungen
            kkblo,       "/fuer List-Tool 3.x: Beleganzeige
            slis ,       "/fuer List-Tool 4.x: Beleganzeige
            rsds,        "/fuer FREE_SELECTION (Tool Belegliste)
            fmfi,        "/fuer Grundeinstellungen Fortschreibung
            shlp.        "/fuer Suchhilfe

* ---- Typen fuer die Funktionsgruppe:*--------------------------------*
TYPES: t_rsdstabs   LIKE rsdstabs  OCCURS 0,
       t_rsdsfields LIKE rsdsfields  OCCURS 0,
       BEGIN OF t_seltabs,
         vbkpf      LIKE boole-boole,
         vbkpf_orig LIKE boole-boole,
         bkpf       LIKE boole-boole,
         bkpf_orig  LIKE boole-boole,
         sach       LIKE boole-boole,
         vbsegs     LIKE  boole-boole,
         bsis       LIKE  boole-boole,
         kred       LIKE boole-boole,
         vbsegk     LIKE  boole-boole,
         bsik       LIKE  boole-boole,
         bsak       LIKE  boole-boole,
         debi       LIKE boole-boole,
         vbsegd     LIKE  boole-boole,
         bsid       LIKE  boole-boole,
         bsad       LIKE  boole-boole,
         psokpf     LIKE boole-boole,
         psosegs    LIKE boole-boole,
         psosegk    LIKE boole-boole,
         psosegd    LIKE boole-boole,
       END  OF t_seltabs.

* ---- constants: -----------------------------------------------------*
CONSTANTS:
  con_more TYPE c                    VALUE '+',
  con_star TYPE c                    VALUE '*'.

* ---- (global) internal tables: --------------------------------------*
DATA: g_t_psoxx_sel LIKE psoxx  OCCURS  0 WITH HEADER LINE,
      g_t_dd03p     LIKE dd03p  OCCURS  0 WITH HEADER LINE.

* ---- global data: ---------------------------------------------------*
DATA: g_activity LIKE tact-actvt,   "/Activity
      g_psotyp   LIKE psotp-psotyp.

DATA  okcode    LIKE sy-ucomm.
*-------------------------------------------------------------------------
* Gereon Koks  6.2.2026  TSI
TYPES: BEGIN OF t_iban,
         banks TYPE banks,
         bankl TYPE bankk,
         bankn TYPE bankn,
         bkont TYPE bkont,
         bkref TYPE bkref,
         swift TYPE swift,
         iban  TYPE iban,
       END OF t_iban.

DATA: g_iban   TYPE t_iban,
      g_t_iban TYPE TABLE OF t_iban.
*-------------------------------------------------------------------------
INCLUDE ififmkao.
INCLUDE ififmcon_fi.
INCLUDE lf0kcf02.
