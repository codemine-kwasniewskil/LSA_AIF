*&---------------------------------------------------------------------*
*& Report /THKR/FI_ELKO_PIPRE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/fi_elko_pipre LINE-SIZE 80.

************************************************************************
* ELKO: Hilfprogramm zum Rücksetzen des "Interpretiert"-Kennzeichens
************************************************************************
* Beschreibung:
*
* Das Programm soll bei Kontoauszügen in FEBEP prüfen, ob sich im
* Buchungsbereich 2 (Nebenbuch) unverarbeitete Posten befinden
* und für diese das "interpretiert"-Kennzeichen (FEBEP-PIPRE)
* wieder auf initial setzen, damit in FEBP eine erneute Interpretation
* beim Nachbuchen von Kontoauszügen erfolgen kann.
*
************************************************************************
* Autor: Jörg Seifert
* Firma: BTC
************************************************************************

TABLES:
  t012k, febko, febep.

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
     SET pipre = @space      "nicht interpretiert
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
     AND eperl IS INITIAL    "Einzelposten noch nicht erledigt
     AND vb1ok = 'X'         "BB1 gebucht
     AND vb2ok IS INITIAL    "BB2 noch nicht gebucht
     AND pipre = 'X'.        "bereits interpretiert

  UPDATE febko
     SET kipre = @space      "nicht interpretiert
   WHERE anwnd IN @s_anwnd
     AND bukrs IN @s_bukrs
     AND hbkid IN @s_hbkid
     AND hktid IN @s_hktid
     AND aznum IN @s_aznum
     AND azdat IN @s_azdat
     AND waers IN @s_curr
     AND kukey IN @s_kukey
     AND vb1ok = 'X'         "BB1 gebucht
     AND vb2ok IS INITIAL    "BB2 noch nicht gebucht
     AND kipre = 'X'.        "bereits interpretiert

  COMMIT WORK AND WAIT.
*&---------------------------------------------------------------------*
