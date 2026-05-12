*&---------------------------------------------------------------------*
*& Report /THKR/FI_ELKO_GVC_CHANGE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/fi_elko_gvc_change LINE-SIZE 80.

************************************************************************
* ELKO: Hilfprogramm zum Ändern von GVC und Buchungsregel
************************************************************************
* Beschreibung: (VORSICHT / DANGER / Nur ausführen, wenn Experte!!!!
*
* Das Programm soll fehlerhaft gelieferten Kontoauszügen den GVC, die
* Buchungsregel und etliche weitere Parameter ändern,
* damit die Umsatzposition mit der korrekten Buchungsregel gebucht werden
* kann. Vorher müssen die falschen Belege über Masenstorno storniert
* werden.
* Das Programm soll für genau einen KuKey und mehrere ESNr aufrufbar sein.
*
************************************************************************
* Autor: Jörg Seifert
* Firma: BTC
************************************************************************

TABLES:
  t012k, febko, febep.

SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
  p_kukey LIKE febep-kukey.
  SELECT-OPTIONS:
  s_esnum FOR febep-esnum.
SELECTION-SCREEN END OF BLOCK 1.

SELECTION-SCREEN BEGIN OF BLOCK 2 WITH FRAME TITLE TEXT-002.
  PARAMETERS:
  p_eperl LIKE febep-eperl,
  p_vb1ok LIKE febep-vb1ok,
  p_vb2ok LIKE febep-vb2ok,
  p_pipre LIKE febep-pipre,
  p_vgext LIKE febep-vgext,
  p_vgint LIKE febep-vgint,
  p_intag LIKE febep-intag.
SELECTION-SCREEN END OF BLOCK 2.


START-OF-SELECTION.

  UPDATE febep
     SET eperl = @p_eperl,   "Einzelposten erledigt?
         vb1ok = @p_vb1ok,   "Verbuchung 1 ok?
         vb2ok = @p_vb2ok,   "Verbuchung 2 ok?
         pipre = @p_pipre,   "interpretiert?
         vgext = @p_vgext,   "Externer Vorgang
         vgint = @p_vgint,   "Buchungsregel
         intag = @p_intag    "Interpretationsalgorithmus
   WHERE kukey = @p_kukey
     AND esnum IN @s_esnum.

  UPDATE febko
     SET astat = '7',        "Auszug unvollständig verbucht
         dstat = @space,     "Druckstatus unvollständig
         vb1ok = @space,     "BB1 unvollständig
         vb2ok = @space,     "BB2 unvollständig
         kipre = @space      "nicht interpretiert
   WHERE kukey = @p_kukey.

  COMMIT WORK AND WAIT.
*&---------------------------------------------------------------------*
