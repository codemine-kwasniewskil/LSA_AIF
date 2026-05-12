*&---------------------------------------------------------------------*
*& Report /THKR/CHK_U_SET_AUGRP                                        *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& Prüfung der BUT000-AUGRP, ob diese gesetzt ist.                     *
*& Die Prüfung erfolgt pro GP-Rolle.                                   *
*&                                                                     *
*& Zweite Prüfung, ob die GP-Rolle und AUGRP zusammen passen.          *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        10.02.2026                                            *
*&                                                                     *
*& l. Änderung:  10.04.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/chk_u_set_augrp.

************************************************************************
* Globale Variablen                                                    *
************************************************************************
DATA: gv_msgstr TYPE string,
      gv_augrp  TYPE bu_augrp,
      gv_bpkind TYPE bu_bpkind.

************************************************************************
* Struktur-Typen                                                       *
************************************************************************
DATA: gs_z000 TYPE but000.

************************************************************************
* Tabellen-Typen                                                       *
************************************************************************
DATA: gt_z001 TYPE trty_but000,
      gt_z002 TYPE trty_but000,
      gt_z003 TYPE trty_but000,
      gt_z004 TYPE trty_but000,
      gt_z006 TYPE trty_but000,
      gt_z007 TYPE trty_but000,
      gt_z0o8 TYPE trty_but000, "Alle ausser Schnittstelle KDPR und SMRS
      gt_z0s8 TYPE trty_but000, "Nur aus Schnittstelle KDPR
      gt_z0m8 TYPE trty_but000, "Nur aus Schnittstelle SMRS
      gt_z009 TYPE trty_but000,
      gt_z011 TYPE trty_but000,
      gt_z012 TYPE trty_but000,
      gt_z013 TYPE trty_but000,
      gt_z051 TYPE trty_but000,
      gt_z052 TYPE trty_but000.

DATA: gt_c001 TYPE trty_but000,
      gt_c002 TYPE trty_but000,
      gt_c003 TYPE trty_but000,
      gt_c004 TYPE trty_but000,
      gt_c006 TYPE trty_but000,
      gt_c007 TYPE trty_but000,
      gt_c0o8 TYPE trty_but000, "Alle ausser Schnittstelle KDPR und SMRS
      gt_c0s8 TYPE trty_but000, "Nur aus Schnittstelle KDPR
      gt_c0m8 TYPE trty_but000, "Nur aus Schnittstelle SMRS
      gt_c009 TYPE trty_but000,
      gt_c011 TYPE trty_but000,
      gt_c012 TYPE trty_but000,
      gt_c013 TYPE trty_but000,
      gt_c051 TYPE trty_but000,
      gt_c052 TYPE trty_but000.

************************************************************************
* Selection-Screen                                                     *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE a1_titel.
  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
    PARAMETERS: p_z001 TYPE xchar AS CHECKBOX,
                p_z002 TYPE xchar AS CHECKBOX,
                p_z003 TYPE xchar AS CHECKBOX,
                p_z004 TYPE xchar AS CHECKBOX,
                p_z006 TYPE xchar AS CHECKBOX,
                p_z007 TYPE xchar AS CHECKBOX,
                p_z008 TYPE xchar AS CHECKBOX,
                p_z009 TYPE xchar AS CHECKBOX,
                p_z011 TYPE xchar AS CHECKBOX,
                p_z012 TYPE xchar AS CHECKBOX,
                p_z013 TYPE xchar AS CHECKBOX,
                p_z051 TYPE xchar AS CHECKBOX,
                p_z052 TYPE xchar AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
    PARAMETERS: p_chk  TYPE xchar AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK bl2.

  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-f03.
    PARAMETERS: p_test  TYPE xchar AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK bl3.
SELECTION-SCREEN END OF BLOCK a1.

************************************************************************
* Start-Of-Selektion                                                   *
************************************************************************
START-OF-SELECTION.

  IF NOT p_z001 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z001'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z001.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0001'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z001.
    SELECT * FROM but000 WHERE bpkind EQ '0001'
                         AND   bu_group EQ '0001'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z001.
  ENDIF.

  IF NOT p_z002 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z002'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z002.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0002'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z002.
    SELECT * FROM but000 WHERE bpkind EQ '0001'
                         AND   bu_group EQ '0002'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z002.
    SELECT * FROM but000 WHERE bpkind EQ '0002'
                         AND   bu_group EQ '0002'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z002.
  ENDIF.

  IF NOT p_z003 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z003'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z003.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0003'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z003.
    SELECT * FROM but000 WHERE bpkind EQ '0003'
                         AND   bu_group EQ '0003'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z003.
  ENDIF.

  IF NOT p_z004 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z004'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z004.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0004'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z004.
    SELECT * FROM but000 WHERE bpkind EQ '0004'
                         AND   bu_group EQ '0004'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z004.
  ENDIF.

  IF NOT p_z006 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z006'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z006.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '06'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z006.
    SELECT * FROM but000 WHERE ( bpkind EQ '0006' OR
                                 bpkind EQ '06' )
                         AND   bu_group EQ '06'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z006.
  ENDIF.

  IF NOT p_z007 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z007'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z007.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0007'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z007.
    SELECT * FROM but000 WHERE bpkind   EQ '0007'
                         AND   bu_group EQ '0007'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z007.
  ENDIF.

  IF NOT p_z008 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind    EQ 'Z008'
                         AND   augrp IS INITIAL
                         AND   /thkr/sst NE 'KDPR'
                         AND   /thkr/sst NE 'SMRS'
             INTO TABLE @gt_z0o8.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group  EQ '0008'
                         AND   /thkr/sst NE 'KDPR'
                         AND   /thkr/sst NE 'SMRS'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z0o8.

    SELECT * FROM but000 WHERE bpkind    EQ 'Z008'
                         AND   augrp IS INITIAL
                         AND   /thkr/sst EQ 'KDPR'
             INTO TABLE @gt_z0s8.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group  EQ '0008'
                         AND   /thkr/sst EQ 'KDPR'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z0s8.

    SELECT * FROM but000 WHERE bpkind    EQ 'Z008'
                         AND   augrp IS INITIAL
                         AND   /thkr/sst EQ 'SMRS'
             INTO TABLE @gt_z0m8.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group  EQ '0008'
                         AND   /thkr/sst EQ 'SMRS'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z0m8.

    SELECT * FROM but000 WHERE bpkind    EQ '0008'
                         AND   bu_group  EQ '0008'
                         AND   /thkr/sst EQ 'KDPR'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z0s8.
    SELECT * FROM but000 WHERE bpkind    EQ '0008'
                         AND   bu_group  EQ '0008'
                         AND   /thkr/sst NE 'KDPR'
                         AND   /thkr/sst NE 'SMRS'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z0o8.
    SELECT * FROM but000 WHERE bpkind    EQ '0008'
                         AND   bu_group  EQ '0008'
                         AND   /thkr/sst EQ 'SMRS'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z0m8.
  ENDIF.

  IF NOT p_z009 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z009'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z009.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0009'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z009.
    SELECT * FROM but000 WHERE bpkind   EQ '0009'
                         AND   bu_group EQ '0009'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z009.
  ENDIF.

  IF NOT p_z011 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z011'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z011.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0011'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z011.
    SELECT * FROM but000 WHERE bpkind   EQ '0011'
                         AND   bu_group EQ '0011'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z011.
  ENDIF.

  IF NOT p_z012 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z012'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z012.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0012'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z012.
    SELECT * FROM but000 WHERE bpkind   EQ '0012'
                         AND   bu_group EQ '0012'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z012.
  ENDIF.

  IF NOT p_z013 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z013'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z013.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0013'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z013.
    SELECT * FROM but000 WHERE bpkind   EQ '0013'
                         AND   bu_group EQ '0013'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z013.
  ENDIF.

  IF NOT p_z051 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z051'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z051.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0051'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z051.
    SELECT * FROM but000 WHERE bpkind   EQ '0051'
                         AND   bu_group EQ '0051'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z051.
  ENDIF.

  IF NOT p_z052 IS INITIAL.
    SELECT * FROM but000 WHERE bpkind EQ 'Z052'
                         AND   augrp IS INITIAL
             INTO TABLE @gt_z052.
    SELECT * FROM but000 WHERE bpkind IS INITIAL
                         AND   bu_group EQ '0052'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z052.
    SELECT * FROM but000 WHERE bpkind   EQ '0052'
                         AND   bu_group EQ '0052'
                         AND   augrp IS INITIAL
             APPENDING TABLE @gt_z052.
  ENDIF.

  IF NOT p_chk IS INITIAL.
    IF NOT p_z001 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z001'
                           AND   augrp  NE '0001'
                INTO TABLE @gt_c001.
      SELECT * FROM but000 WHERE bpkind   EQ '0001'
                           AND   bu_group EQ '0001'
                 APPENDING TABLE @gt_c001.
      SELECT * FROM but000 WHERE bpkind IS INITIAL
                           AND   bu_group EQ '0001'
                 APPENDING TABLE @gt_c001.
      IF NOT gt_c001[] IS INITIAL.
        DELETE gt_c001 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z002 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z002'
                           AND   augrp  NE '0002'
                INTO TABLE @gt_c002.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0002'
                 APPENDING TABLE @gt_c002.
      SELECT * FROM but000 WHERE bpkind   EQ '0001'
                           AND   bu_group EQ '0002'
                 APPENDING TABLE @gt_c002.
      SELECT * FROM but000 WHERE bpkind   EQ '0002'
                           AND   bu_group EQ '0002'
                 APPENDING TABLE @gt_c002.
      IF NOT gt_c002[] IS INITIAL.
        DELETE gt_c002 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z003 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z003'
                           AND   augrp  NE '0003'
                INTO TABLE @gt_c003.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0003'
                 APPENDING TABLE @gt_c003.
      SELECT * FROM but000 WHERE bpkind   EQ '0003'
                           AND   bu_group EQ '0003'
                 APPENDING TABLE @gt_c003.
      IF NOT gt_c003[] IS INITIAL.
        DELETE gt_c003 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z004 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z004'
                           AND   augrp  NE '0004'
                INTO TABLE @gt_c004.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0004'
                 APPENDING TABLE @gt_c004.
      SELECT * FROM but000 WHERE bpkind   EQ '0004'
                           AND   bu_group EQ '0004'
                 APPENDING TABLE @gt_c004.
      IF NOT gt_c004[] IS INITIAL.
        DELETE gt_c004 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z006 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z006'
                           AND   augrp  NE '06'
                INTO TABLE @gt_c006.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '06'
                 APPENDING TABLE @gt_c006.
      SELECT * FROM but000 WHERE ( bpkind EQ '0006' OR
                                   bpkind EQ '06' )
                           AND   bu_group EQ '06'
                 APPENDING TABLE @gt_c006.
      IF NOT gt_c006[] IS INITIAL.
        DELETE gt_c006 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z007 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z007'
                           AND   augrp  NE '0007'
                INTO TABLE @gt_c007.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0007'
                 APPENDING TABLE @gt_c007.
      SELECT * FROM but000 WHERE bpkind   EQ '0007'
                           AND   bu_group EQ '0007'
                 APPENDING TABLE @gt_c007.
      IF NOT gt_c007[] IS INITIAL.
        DELETE gt_c007 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z008 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind    EQ 'Z008'
                           AND   augrp     NE '0008'
                           AND   /thkr/sst NE 'KDPR'
                           AND   /thkr/sst NE 'SMRS'
                INTO TABLE @gt_c0o8.
      SELECT * FROM but000 WHERE bpkind    IS INITIAL
                           AND   bu_group  EQ '0008'
                           AND   /thkr/sst NE 'KDPR'
                           AND   /thkr/sst NE 'SMRS'
                 APPENDING TABLE @gt_c0o8.
      SELECT * FROM but000 WHERE bpkind    EQ '0008'
                           AND   bu_group  EQ '0008'
                           AND   /thkr/sst NE 'KDPR'
                           AND   /thkr/sst NE 'SMRS'
                 APPENDING TABLE @gt_c0o8.
      IF NOT gt_c0o8[] IS INITIAL.
        DELETE gt_c0o8 WHERE augrp IS INITIAL.
      ENDIF.

      SELECT * FROM but000 WHERE bpkind    EQ 'Z008'
                           AND   augrp     NE '0004'
                           AND   /thkr/sst EQ 'KDPR'
                INTO TABLE @gt_c0s8.
      SELECT * FROM but000 WHERE bpkind    IS INITIAL
                           AND   bu_group  EQ '0008'
                           AND   /thkr/sst EQ 'KDPR'
                 APPENDING TABLE @gt_c0s8.
      SELECT * FROM but000 WHERE bpkind    EQ '0008'
                           AND   bu_group  EQ '0008'
                           AND   /thkr/sst EQ 'KDPR'
                 APPENDING TABLE @gt_c0s8.
      IF NOT gt_c0s8[] IS INITIAL.
        DELETE gt_c0s8 WHERE augrp IS INITIAL.
      ENDIF.

      SELECT * FROM but000 WHERE bpkind    EQ 'Z008'
                           AND   augrp     NE '0052'
                           AND   /thkr/sst EQ 'SMRS'
                INTO TABLE @gt_c0m8.
      SELECT * FROM but000 WHERE bpkind    EQ 'Z052'
                           AND   augrp     NE '0052'
                           AND   /thkr/sst EQ 'SMRS'
                 APPENDING TABLE @gt_c0m8.
      SELECT * FROM but000 WHERE bpkind    IS INITIAL
                           AND   bu_group  EQ '0008'
                           AND   /thkr/sst EQ 'SMRS'
                 APPENDING TABLE @gt_c0m8.
      SELECT * FROM but000 WHERE bpkind    EQ '0008'
                           AND   bu_group  EQ '0008'
                           AND   /thkr/sst EQ 'SMRS'
                 APPENDING TABLE @gt_c0m8.
      IF NOT gt_c0m8[] IS INITIAL.
        DELETE gt_c0m8 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z009 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z009'
                           AND   augrp  NE '0009'
                INTO TABLE @gt_c009.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0009'
                 APPENDING TABLE @gt_c009.
      SELECT * FROM but000 WHERE bpkind   EQ '0009'
                           AND   bu_group EQ '0009'
                 APPENDING TABLE @gt_c009.
      IF NOT gt_c009[] IS INITIAL.
        DELETE gt_c009 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z011 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z011'
                           AND   augrp  NE '0011'
                INTO TABLE @gt_c011.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0011'
                 APPENDING TABLE @gt_c011.
      SELECT * FROM but000 WHERE bpkind   EQ '0011'
                           AND   bu_group EQ '0011'
                 APPENDING TABLE @gt_c011.
      IF NOT gt_c011[] IS INITIAL.
        DELETE gt_c011 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z012 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z012'
                           AND   augrp  NE '0012'
                INTO TABLE @gt_c012.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0012'
                 APPENDING TABLE @gt_c012.
      SELECT * FROM but000 WHERE bpkind   EQ '0012'
                           AND   bu_group EQ '0012'
                 APPENDING TABLE @gt_c012.
      IF NOT gt_c012[] IS INITIAL.
        DELETE gt_c012 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z013 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z013'
                           AND   augrp  NE '0013'
                INTO TABLE @gt_c013.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0013'
                 APPENDING TABLE @gt_c013.
      SELECT * FROM but000 WHERE bpkind   EQ '0013'
                           AND   bu_group EQ '0013'
                 APPENDING TABLE @gt_c013.
      IF NOT gt_c013[] IS INITIAL.
        DELETE gt_c013 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z051 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind EQ 'Z051'
                           AND   augrp  NE '0051'
                INTO TABLE @gt_c051.
      SELECT * FROM but000 WHERE bpkind   IS INITIAL
                           AND   bu_group EQ '0051'
                 APPENDING TABLE @gt_c051.
      SELECT * FROM but000 WHERE bpkind   EQ '0051'
                           AND   bu_group EQ '0051'
                 APPENDING TABLE @gt_c051.
      IF NOT gt_c051[] IS INITIAL.
        DELETE gt_c051 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.

    IF NOT p_z052 IS INITIAL.
      SELECT * FROM but000 WHERE bpkind    EQ 'Z052'
                           AND   augrp     NE '0052'
                           AND   /thkr/sst NE 'SMRS'
                INTO TABLE @gt_c052.
      SELECT * FROM but000 WHERE bpkind    IS INITIAL
                           AND   bu_group  EQ '0052'
                           AND   /thkr/sst NE 'SMRS'
                 APPENDING TABLE @gt_c052.
      SELECT * FROM but000 WHERE bpkind    EQ '0052'
                           AND   bu_group  EQ '0052'
                           AND   /thkr/sst NE 'SMRS'
                 APPENDING TABLE @gt_c052.
      IF NOT gt_c052[] IS INITIAL.
        DELETE gt_c052 WHERE augrp IS INITIAL.
      ENDIF.
    ENDIF.
  ENDIF.
************************************************************************
* Ende der Datenselektion                                              *
************************************************************************
END-OF-SELECTION.

************************************************************************
* Verarbeitrung der Internen - Tabellen                                *
* Z001                                                                 *
************************************************************************
  gv_augrp  = '0001'.
  gv_bpkind = 'Z001'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z001
                               'Z001: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z002                                                                 *
************************************************************************
  gv_augrp  = '0002'.
  gv_bpkind = 'Z002'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z002
                               'Z002: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z003                                                                 *
************************************************************************
  gv_augrp  = '0003'.
  gv_bpkind = 'Z003'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z003
                               'Z003: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z004                                                                 *
************************************************************************
  gv_augrp  = '0004'.
  gv_bpkind = 'Z004'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z004
                               'Z004: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z006                                                                 *
************************************************************************
  gv_augrp  = '06'.
  gv_bpkind = 'Z006'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z006
                               'Z006: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z007                                                                 *
************************************************************************
  gv_augrp  = '0007'.
  gv_bpkind = 'Z007'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z007
                               'Z007: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z008 - nicht Schnittstelle KDPR und SMRS                             *
************************************************************************
  gv_augrp  = '0008'.
  gv_bpkind = 'Z008'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z0o8
                               'Z008: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z008 - nur   Schnittstelle KDPR                                      *
************************************************************************
  gv_augrp  = '0004'.
  gv_bpkind = 'Z008'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z0s8
                               'Z008: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z008 - nur   Schnittstelle SMRS                                      *
************************************************************************
  gv_augrp  = '0052'.
  gv_bpkind = 'Z052'.
  IF sy-batch IS INITIAL.
    WRITE: /4 '=================================='.
    WRITE: /5 'Z008: BUT000 SETZEN AUGRP: ', gv_augrp.
  ELSE.
    CONCATENATE 'Z008: BUT000 SETZEN AUGRP: ' gv_augrp INTO gv_msgstr RESPECTING BLANKS.
    MESSAGE gv_msgstr TYPE 'S'.
  ENDIF.
  LOOP AT gt_z0m8 INTO gs_z000.
    IF p_test IS INITIAL.
      UPDATE but000 SET augrp   = gv_augrp
                        bpkind  = gv_bpkind
                  WHERE partner = gs_z000-partner.
      IF 0 EQ sy-subrc.
        IF sy-batch IS INITIAL.
          WRITE: /5 gs_z000-partner,
                    ' | ',
                    gs_z000-bpkind,
                    ' | ',
                    gs_z000-bu_group,
                    ' | ',
                    gs_z000-augrp,
                    ' | ',
                    gv_augrp,
                    ' - GEÄNDERT'.
        ELSE.
          CONCATENATE gs_z000-partner  ' | '
                      gs_z000-bpkind   ' | '
                      gs_z000-bu_group ' | '
                      gs_z000-augrp    ' | '
                      gv_augrp         ' - GEÄNDERT'
                   INTO gv_msgstr RESPECTING BLANKS.
          MESSAGE gv_msgstr TYPE 'S'.
        ENDIF.
      ELSE.
        IF sy-batch IS INITIAL.
          WRITE: /5 gs_z000-partner,
                    ' | ',
                    gs_z000-bpkind,
                    ' | ',
                    gs_z000-bu_group,
                    ' | ',
                    gs_z000-augrp,
                    ' | ',
                    gv_augrp,
                    ' - ERROR beim Update!'.
        ELSE.
          CONCATENATE gs_z000-partner  ' | '
                      gs_z000-bpkind   ' | '
                      gs_z000-bu_group ' | '
                      gs_z000-augrp    ' | '
                      gv_augrp         ' - ERROR beim Update!'
                   INTO gv_msgstr RESPECTING BLANKS.
          MESSAGE gv_msgstr TYPE 'W'.
        ENDIF.
      ENDIF.
    ELSE.
      IF sy-batch IS INITIAL.
        WRITE: /5 gs_z000-partner,
                  ' | ',
                  gs_z000-bpkind,
                  ' | ',
                  gs_z000-bu_group,
                  ' | ',
                  gs_z000-augrp,
                  ' | ',
                  gv_augrp,
                  ' - TEST'.
      ELSE.
        CONCATENATE gs_z000-partner  ' | '
                    gs_z000-bpkind   ' | '
                    gs_z000-bu_group ' | '
                    gs_z000-augrp    ' | '
                    gv_augrp         ' - TEST'
                 INTO gv_msgstr RESPECTING BLANKS.
        MESSAGE gv_msgstr TYPE 'S'.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF sy-batch IS INITIAL.
    WRITE: /.
  ENDIF.
  IF NOT gt_z0m8[] IS INITIAL AND
     p_test IS INITIAL.
    COMMIT WORK.
  ENDIF.

************************************************************************
* Z009                                                                 *
************************************************************************
  gv_augrp  = '0009'.
  gv_bpkind = 'Z009'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z009
                               'Z009: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z011                                                                 *
************************************************************************
  gv_augrp  = '0011'.
  gv_bpkind = 'Z011'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z011
                               'Z011: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z012                                                                 *
************************************************************************
  gv_augrp  = '0012'.
  gv_bpkind = 'Z012'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z012
                               'Z012: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z013                                                                 *
************************************************************************
  gv_augrp  = '0013'.
  gv_bpkind = 'Z013'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z013
                               'Z013: BUT000 SETZEN AUGRP: '
                               p_test.


************************************************************************
* Z051                                                                 *
************************************************************************
  gv_augrp  = '0051'.
  gv_bpkind = 'Z051'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z051
                               'Z051: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Z052                                                                 *
************************************************************************
  gv_augrp  = '0052'.
  gv_bpkind = 'Z052'.
  PERFORM set_but000_new USING gv_augrp
                               gv_bpkind
                               gt_z052
                               'Z052: BUT000 SETZEN AUGRP: '
                               p_test.

************************************************************************
* Verarbeitrung der Internen - Tabellen                                *
* C001                                                                 *
************************************************************************
  gv_augrp  = '0001'.
  gv_bpkind = 'Z001'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c001
                               'Z001: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C002                                                                 *
************************************************************************
  gv_augrp  = '0002'.
  gv_bpkind = 'Z002'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c002
                               'Z002: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C003                                                                 *
************************************************************************
  gv_augrp  = '0003'.
  gv_bpkind = 'Z003'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c003
                               'Z003: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C004                                                                 *
************************************************************************
  gv_augrp  = '0004'.
  gv_bpkind = 'Z004'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c004
                               'Z004: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C006                                                                 *
************************************************************************
  gv_augrp  = '06'.
  gv_bpkind = 'Z006'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c006
                               'Z006: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C007                                                                 *
************************************************************************
  gv_augrp  = '0007'.
  gv_bpkind = 'Z007'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c007
                               'Z007: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C008 ohne Schnittstelle KDPR und SMRS                                *
************************************************************************
  gv_augrp  = '0008'.
  gv_bpkind = 'Z008'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c0o8
                               'Z008: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C008 nur  Schnittstelle KDPR                                         *
************************************************************************
  gv_augrp  = '0004'.
  gv_bpkind = 'Z008'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c0s8
                               'Z008: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C008 nur  Schnittstelle SMRS                                         *
************************************************************************
  gv_augrp  = '0052'.
  gv_bpkind = 'Z052'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c0m8
                               'Z008: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C009                                                                 *
************************************************************************
  gv_augrp  = '0009'.
  gv_bpkind = 'Z009'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c009
                               'Z009: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C011                                                                 *
************************************************************************
  gv_augrp  = '0011'.
  gv_bpkind = 'Z011'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c011
                               'Z011: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C012                                                                 *
************************************************************************
  gv_augrp  = '0012'.
  gv_bpkind = 'Z012'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c012
                               'Z012: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C013                                                                 *
************************************************************************
  gv_augrp  = '0013'.
  gv_bpkind = 'Z013'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c013
                               'Z013: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C051                                                                 *
************************************************************************
  gv_augrp  = '0051'.
  gv_bpkind = 'Z051'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c051
                               'Z051: BUT000 CHECK und SET AUGRP: '
                               p_test.

************************************************************************
* C052                                                                 *
************************************************************************
  gv_augrp  = '0052'.
  gv_bpkind = 'Z052'.
  PERFORM set_but000_chg USING gv_augrp
                               gv_bpkind
                               gt_c052
                               'Z052: BUT000 CHECK und SET AUGRP: '
                               p_test.


*=======================================================================
*=======================================================================


*&---------------------------------------------------------------------*
*& Form set_but000_new
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_Z001
*&---------------------------------------------------------------------*
FORM set_but000_new  USING    pv_augrp  TYPE bu_augrp
                              pv_bpkind TYPE bu_bpkind
                              pt_but000 TYPE trty_but000
                              pv_itext  TYPE string
                              pv_test   TYPE xchar.

  DATA: lv_msgstr TYPE string.
  DATA: ls_z000   TYPE but000.

  IF sy-batch IS INITIAL.
    WRITE: /4 '=================================='.
    WRITE: /5 pv_itext, pv_augrp.
  ELSE.
    CONCATENATE pv_itext pv_augrp INTO lv_msgstr RESPECTING BLANKS.
    MESSAGE lv_msgstr TYPE 'S'.
  ENDIF.
  LOOP AT pt_but000 INTO ls_z000.
    IF pv_test IS INITIAL.
      IF ls_z000-bpkind IS INITIAL.
        UPDATE but000 SET augrp   = pv_augrp
                          bpkind  = pv_bpkind
                    WHERE partner = ls_z000-partner.
      ELSE.
        UPDATE but000 SET augrp     = pv_augrp
                      WHERE partner = ls_z000-partner.
      ENDIF.
      IF 0 EQ sy-subrc.
        IF sy-batch IS INITIAL.
          WRITE: /5 ls_z000-partner,
                    ' | ',
                    ls_z000-bpkind,
                    ' | ',
                    ls_z000-bu_group,
                    ' | ',
                    ls_z000-augrp,
                    ' | ',
                    pv_augrp,
                    ' - GEÄNDERT'.
        ELSE.
          CONCATENATE ls_z000-partner  ' | '
                      ls_z000-bpkind   ' | '
                      ls_z000-bu_group ' | '
                      ls_z000-augrp    ' | '
                      pv_augrp         ' - GEÄNDERT'
                   INTO lv_msgstr RESPECTING BLANKS.
          MESSAGE lv_msgstr TYPE 'S'.
        ENDIF.
      ELSE.
        IF sy-batch IS INITIAL.
          WRITE: /5 ls_z000-partner,
                    ' | ',
                    ls_z000-bpkind,
                    ' | ',
                    ls_z000-bu_group,
                    ' | ',
                    ls_z000-augrp,
                    ' | ',
                    pv_augrp,
                    ' - ERROR beim Update!'.
        ELSE.
          CONCATENATE ls_z000-partner  ' | '
                      ls_z000-bpkind   ' | '
                      ls_z000-bu_group ' | '
                      ls_z000-augrp    ' | '
                      pv_augrp         ' - ERROR beim Update!'
                   INTO lv_msgstr RESPECTING BLANKS.
          MESSAGE lv_msgstr TYPE 'W'.
        ENDIF.
      ENDIF.
    ELSE.
      IF sy-batch IS INITIAL.
        WRITE: /5 ls_z000-partner,
                  ' | ',
                  ls_z000-bpkind,
                  ' | ',
                  ls_z000-bu_group,
                  ' | ',
                  ls_z000-augrp,
                  ' | ',
                  pv_augrp,
                  ' - TEST'.
      ELSE.
        CONCATENATE ls_z000-partner  ' | '
                    ls_z000-bpkind   ' | '
                    ls_z000-bu_group ' | '
                    ls_z000-augrp    ' | '
                    pv_augrp         ' - TEST'
                 INTO lv_msgstr RESPECTING BLANKS.
        MESSAGE lv_msgstr TYPE 'S'.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF sy-batch IS INITIAL.
    WRITE: /.
  ENDIF.
  IF NOT pt_but000[] IS INITIAL AND
     pv_test IS INITIAL.
    COMMIT WORK.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_but000_chg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> GT_Z001
*&---------------------------------------------------------------------*
FORM set_but000_chg  USING    pv_augrp  TYPE bu_augrp
                              pv_bpkind TYPE bu_bpkind
                              pt_but000 TYPE trty_but000
                              pv_itext  TYPE string
                              pv_test   TYPE xchar.

  DATA: lv_msgstr TYPE string.
  DATA: ls_z000   TYPE but000.

  IF sy-batch IS INITIAL.
    WRITE: /4 '========================================='.
    WRITE: /5 pv_itext, pv_augrp.
  ELSE.
    CONCATENATE pv_itext pv_augrp INTO lv_msgstr RESPECTING BLANKS.
    MESSAGE lv_msgstr TYPE 'S'.
  ENDIF.
  LOOP AT pt_but000 INTO ls_z000.
    IF pv_test IS INITIAL.
      UPDATE but000 SET augrp  = pv_augrp
                        bpkind = pv_bpkind
                    WHERE partner = ls_z000-partner.
      IF 0 EQ sy-subrc.
        IF sy-batch IS INITIAL.
          WRITE: /5 ls_z000-partner,
                    ' | ',
                    ls_z000-bpkind,
                    ' | ',
                    ls_z000-bu_group,
                    ' | ',
                    ls_z000-augrp,
                    ' | ',
                    pv_augrp,
                    ' - GEÄNDERT'.
        ELSE.
          CONCATENATE ls_z000-partner  ' | '
                      ls_z000-bpkind   ' | '
                      ls_z000-bu_group ' | '
                      ls_z000-augrp    ' | '
                      pv_augrp         ' - GEÄNDERT'
                   INTO lv_msgstr RESPECTING BLANKS.
          MESSAGE lv_msgstr TYPE 'S'.
        ENDIF.
      ELSE.
        IF sy-batch IS INITIAL.
          WRITE: /5 ls_z000-partner,
                    ' | ',
                    ls_z000-bpkind,
                    ' | ',
                    ls_z000-bu_group,
                    ' | ',
                    ls_z000-augrp,
                    ' | ',
                    pv_augrp,
                    ' - ERROR beim Update!'.
        ELSE.
          CONCATENATE ls_z000-partner  ' | '
                      ls_z000-bpkind   ' | '
                      ls_z000-bu_group ' | '
                      ls_z000-augrp    ' | '
                      pv_augrp         ' - ERROR beim Update!'
                   INTO lv_msgstr RESPECTING BLANKS.
          MESSAGE lv_msgstr TYPE 'W'.
        ENDIF.
      ENDIF.
    ELSE.
      IF sy-batch IS INITIAL.
        WRITE: /5 ls_z000-partner,
                  ' | ',
                  ls_z000-bpkind,
                  ' | ',
                  ls_z000-bu_group,
                  ' | ',
                  ls_z000-augrp,
                  ' | ',
                  pv_augrp,
                  ' - TEST'.
      ELSE.
        CONCATENATE ls_z000-partner  ' | '
                    ls_z000-bpkind   ' | '
                    ls_z000-bu_group ' | '
                    ls_z000-augrp    ' | '
                    pv_augrp         ' - TEST'
                 INTO lv_msgstr RESPECTING BLANKS.
        MESSAGE lv_msgstr TYPE 'S'.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF sy-batch IS INITIAL.
    WRITE: /.
  ENDIF.
  IF NOT pt_but000[] IS INITIAL AND
     pv_test IS INITIAL.
    COMMIT WORK.
  ENDIF.
ENDFORM.
