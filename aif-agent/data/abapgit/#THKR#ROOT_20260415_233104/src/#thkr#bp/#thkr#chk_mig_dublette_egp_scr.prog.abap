*&---------------------------------------------------------------------*
*& Include          /THKR/CHK_MIG_DUBLETTE_EGP_SCR                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& Selektionsbildschirm                                                *
*& Prüfung von Z001 - Einmal-GP zur Archivierung                       *
*& Prüfung von Z009 - MIG-Einmal-GP und Dubletten                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        25.02.2026                                            *
*&                                                                     *
*& l. Änderung:  13.04.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*

************************************************************************
* Selektionsbildschirm                                                 *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME NO INTERVALS.
  SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE b1_titel.
    PARAMETERS: p_z001 TYPE xchar AS CHECKBOX DEFAULT 'X',
                p_z009 TYPE xchar AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN: END OF BLOCK b1.
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE b3_titel.
    SELECT-OPTIONS so_blart FOR kblk-blart.
  SELECTION-SCREEN: END OF BLOCK b3.
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE b2_titel.
    PARAMETERS: p_test TYPE xchar AS CHECKBOX DEFAULT 'X',
                p_max  TYPE i DEFAULT 3000.
  SELECTION-SCREEN: END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK a1.

DATA: gs_sblart like LINE OF so_blart.
