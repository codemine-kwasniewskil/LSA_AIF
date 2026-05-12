*&---------------------------------------------------------------------*
*& Report /THKR/FI_ELKO_KETT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/fi_elko_kett LINE-SIZE 80.

************************************************************************
* ELKO: Hilfprogramm zum Aktualisieren des Ketten-Kennzeichens (ZZ_AVVISO)
************************************************************************
* Beschreibung:
*
* Das Programm soll bei Kontoauszügen in FEBEP das Ketten-Kennzeichen
* aktualisieren, wenn die Zahlung auf das Haupt-Kassenzeichen einer
* Kette erkannt wurde
*
* Das Programm ist für die einmalige Ausführung gedacht. (Änd. 20286/2026 FEBAN)
*
************************************************************************
* Autor: Jörg Seifert
* Firma: BTC
************************************************************************

TABLES:
  febep, febko, t012k, /thkr/kassz_kett.

SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
  s_anwnd FOR febko-anwnd DEFAULT '0001',
  s_azdat FOR febko-azdat,
  s_aznum FOR febko-aznum,
  s_hbkid FOR t012k-hbkid,
  s_hktid FOR t012k-hktid,
  s_bukrs FOR t012k-bukrs,
  s_curr  FOR febko-waers.
SELECTION-SCREEN END OF BLOCK 1.

SELECTION-SCREEN BEGIN OF BLOCK 2 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS:
  s_kukey FOR febep-kukey,
  s_esnum FOR febep-esnum.
SELECTION-SCREEN END OF BLOCK 2.


START-OF-SELECTION.

  UPDATE febep
     SET zz_avviso = 'K'      "Kette
   WHERE kukey = ANY
       (
       SELECT kukey
         FROM febko
        WHERE anwnd IN @s_anwnd
          AND bukrs IN @s_bukrs
          AND hbkid IN @s_hbkid
          AND hktid IN @s_hktid
          AND aznum IN @s_aznum
          AND azdat IN @s_azdat
          AND waers IN @s_curr
          AND kukey IN @s_kukey
       )
     AND esnum IN @s_esnum
     AND xblnr IN ( SELECT fkassz FROM /thkr/kassz_kett ).

  WRITE: / TEXT-004, sy-dbcnt.

  COMMIT WORK AND WAIT.
*&---------------------------------------------------------------------*
