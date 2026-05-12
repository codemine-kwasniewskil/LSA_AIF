*&---------------------------------------------------------------------*
*& Report /THKR/GP_CHANGE_COUNTRY                                      *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& Daten von Geschäftspartnern suchen und ggf. das Länderkennzeichen   *
*& lt dem Selektionsbildschirm anpassen.                               *
*&                                                                     *
*& Ausgabe bei Dialog in einer Liste auf dem Bildschirmprotokoll.      *
*& Wird der Batchprozess genommen, wird der Eintrag im Jobllog         *
*& protokolliert.                                                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        20.03.2026                                            *
*&                                                                     *
*& l. Änderung:  24.03.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/gp_change_country.

TABLES: but000.

************************************************************************
* Globale Variable                                                     *
************************************************************************
DATA: gv_trenner TYPE c LENGTH 3 VALUE ' | ',
      gv_taus    TYPE string,
      gv_strmsg  TYPE string,
      gv_stras   TYPE stras_gp,
      gv_length  TYPE i.

************************************************************************
* Globale Tabellentypen                                                *
************************************************************************
DATA: gt_but  TYPE TABLE OF but000,
      gt_b20  TYPE TABLE OF but020,
      gt_adr  TYPE TABLE OF adrc,
      gt_adro TYPE TABLE OF adrc,
      gt_kna  TYPE TABLE OF kna1,
      gt_lfa  TYPE TABLE OF lfa1.

************************************************************************
* Globale Strukturen                                                   *
************************************************************************
DATA: gs_but  TYPE but000,
      gs_b20  TYPE but020,
      gs_adr  TYPE adrc,
      gs_adro TYPE adrc,
      gs_kna  TYPE kna1,
      gs_lfa  TYPE lfa1.

************************************************************************
* Selection-Screen                                                     *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE a1_titel.
  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
    PARAMETERS: p_radgp TYPE xchar RADIOBUTTON GROUP s1 USER-COMMAND rad,
                p_radst TYPE xchar RADIOBUTTON GROUP s1 DEFAULT 'X',
                p_radad TYPE xchar RADIOBUTTON GROUP s1.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
    SELECT-OPTIONS: so_partn FOR but000-partner MODIF ID bp,
                    so_sst   FOR but000-/thkr/sst NO INTERVALS MODIF ID sst.
  SELECTION-SCREEN END OF BLOCK bl2.

  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-f03.
    PARAMETERS: p_sland TYPE land1_gp OBLIGATORY DEFAULT 'YT',
                p_nland TYPE land1_gp OBLIGATORY DEFAULT 'DE'.
  SELECTION-SCREEN END OF BLOCK bl3.

  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK bl4 WITH FRAME TITLE TEXT-f04.
    PARAMETERS: p_test  TYPE xchar AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN END OF BLOCK bl4.
SELECTION-SCREEN END OF BLOCK a1.

DATA gs_so_partn LIKE LINE OF so_partn.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF p_radgp IS INITIAL.
      IF screen-group1 EQ 'BP'.
        screen-active = 0.
      ENDIF.

      IF screen-group1 EQ 'SST'.
        screen-active = 1.
      ENDIF.

      MODIFY SCREEN.
    ENDIF.

    IF p_radst IS INITIAL.
      IF screen-group1 EQ 'BP'.
        screen-active = 1.
      ENDIF.

      IF screen-group1 EQ 'SST'.
        screen-active = 0.
      ENDIF.

      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
************************************************************************
* Start-Of-Selektion                                                   *
************************************************************************
START-OF-SELECTION.

************************************************************************
* Selektion aus der BUT000 nach den Selektionsparametern               *
************************************************************************
  IF NOT p_radgp IS INITIAL.
    IF NOT so_partn IS INITIAL .
      SELECT * FROM but000 INTO TABLE gt_but
                    WHERE partner IN so_partn
                    ORDER BY partner ASCENDING.
    ELSE.
      MESSAGE 'Es wurden keine Geschäftspartner eingegrenzt!' TYPE 'I'.
    ENDIF.
  ENDIF.

  IF NOT p_radst IS INITIAL.
    IF NOT so_sst IS INITIAL .
      SELECT * FROM but000 INTO TABLE gt_but
                    WHERE /thkr/sst IN so_sst
                    ORDER BY partner ASCENDING.
*************************************************************************
*   SO_PARTN setzen                                                     *
*************************************************************************
      CLEAR so_partn[].
      gs_so_partn-sign = 'I'.
      gs_so_partn-option = 'EQ'.
      LOOP AT gt_but INTO gs_but.
        gs_so_partn-low = gs_but-partner.
        APPEND gs_so_partn TO so_partn.
      ENDLOOP.
    ELSE.
      MESSAGE 'Es wurden keine Schnittstellen eingegrenzt!' TYPE 'I'.
    ENDIF.
  ENDIF.

  IF NOT p_radad IS INITIAL.
    SELECT * FROM adrc INTO TABLE gt_adr
              WHERE country EQ p_sland
             ORDER BY addrnumber ASCENDING.
    LOOP AT gt_adr INTO gs_adro.
      SELECT SINGLE * FROM but020 INTO gs_b20
                    WHERE addrnumber EQ gs_adro-addrnumber.
      IF 0 NE sy-subrc.
        APPEND gs_adro TO gt_adro.
      ENDIF.
    ENDLOOP.
    CLEAR: gt_adr[], gs_b20.
  ENDIF.

*************************************************************************
* BUT020, KNA1 und LFA1 setzen                                          *
*************************************************************************
  IF NOT so_partn[] IS INITIAL.
* BUT20
    SELECT * FROM but020 INTO TABLE gt_b20
                  WHERE partner IN so_partn
                 ORDER BY partner ASCENDING.
* KNA1
    SELECT * FROM kna1 INTO TABLE gt_kna
                  WHERE kunnr IN so_partn
                  AND   land1 EQ p_sland
                 ORDER BY kunnr ASCENDING.
* LFA1
    SELECT * FROM lfa1 INTO TABLE gt_lfa
                  WHERE lifnr IN so_partn
                  AND   land1 EQ p_sland
                 ORDER BY lifnr ASCENDING.
* ADRC
    IF NOT gt_b20 IS INITIAL.
      CLEAR gt_adr.
      LOOP AT gt_b20 INTO gs_b20.
        SELECT * FROM adrc APPENDING TABLE gt_adr
                 WHERE addrnumber EQ gs_b20-addrnumber
                 AND  country     EQ p_sland.
      ENDLOOP.
    ENDIF.
  ENDIF.

************************************************************************
* Hartes Update auf die DB-Tabellen durchführen                        *
************************************************************************
  IF p_test IS INITIAL.
    MOVE 'GEAENDERT' TO gv_taus.
************************************************************************
*   Protokollausgabe auf BS bzw. JobLog                                *
************************************************************************
*   KNA1                                                               *
************************************************************************
    IF sy-batch IS INITIAL.
      WRITE: /5 'Protokoll - KNA1'.
    ELSE.
      MESSAGE 'Protokoll - KNA1' TYPE 'S'.
    ENDIF.
    LOOP AT gt_kna INTO gs_kna.
      CLEAR gv_stras.
      SELECT SINGLE * FROM adrc INTO gs_adr
                   WHERE addrnumber EQ gs_kna-adrnr.
      IF 0 EQ sy-subrc.
        CLEAR: gv_length.
        gv_length = strlen( gs_adro-street ).
        IF gv_length > 0.
          CONCATENATE gs_adr-street+0(gv_length) ' ' gs_adr-house_num1 INTO gv_stras RESPECTING BLANKS.
        ENDIF.
      ENDIF.
      IF gv_stras IS INITIAL.
        UPDATE kna1 SET land1 = p_nland
                    WHERE kunnr = gs_kna-kunnr.
      ELSE.
        UPDATE kna1 SET land1 = p_nland
                        stras = gv_stras
                    WHERE kunnr = gs_kna-kunnr.
      ENDIF.
      IF 0 EQ sy-subrc.
        IF sy-batch IS INITIAL.
          WRITE: /5 gs_kna-kunnr,
                 gv_trenner,
                 gs_kna-land1,
                 gv_trenner,
                 p_nland,
                 gv_trenner,
                 gv_taus.
        ELSE.
          CONCATENATE gs_kna-kunnr gv_trenner
                      gs_kna-land1 gv_trenner
                      p_nland      gv_trenner
                      gv_taus INTO gv_strmsg RESPECTING BLANKS.
          MESSAGE gv_strmsg TYPE 'S'.
        ENDIF.
      ELSE.
        IF sy-batch IS INITIAL.
          WRITE: /5 'KNA1-Update: Fehler KUNNR ', gv_trenner, gs_kna-kunnr.
        ELSE.
          CONCATENATE 'KNA1-Update: Fehler KUNNR ' gv_trenner
                       gs_kna-kunnr INTO gv_strmsg RESPECTING BLANKS.
          MESSAGE gv_strmsg TYPE 'S'.
        ENDIF.
      ENDIF.
    ENDLOOP.

************************************************************************
*   LFA1                                                               *
************************************************************************
    IF sy-batch IS INITIAL.
      WRITE: /5 'Protokoll - LFA1'.
    ELSE.
      MESSAGE 'Protokoll - LFA1' TYPE 'S'.
    ENDIF.
    LOOP AT gt_lfa INTO gs_lfa.
      CLEAR gv_stras.
      SELECT SINGLE * FROM adrc INTO gs_adr
                   WHERE addrnumber EQ gs_lfa-adrnr.
      IF 0 EQ sy-subrc.
        CLEAR: gv_length.
        gv_length = strlen( gs_adro-street ).
        IF gv_length > 0.
          CONCATENATE gs_adr-street+0(gv_length) ' ' gs_adr-house_num1 INTO gv_stras RESPECTING BLANKS.
        ENDIF.
      ENDIF.
      IF gv_stras IS INITIAL.
        UPDATE lfa1 SET land1 = p_nland
                    WHERE lifnr = gs_lfa-lifnr.
      ELSE.
        UPDATE lfa1 SET land1 = p_nland
                        stras = gv_stras
                    WHERE lifnr = gs_lfa-lifnr.
      ENDIF.
      IF 0 EQ sy-subrc.
        IF sy-batch IS INITIAL.
          WRITE: /5 gs_lfa-lifnr,
                 gv_trenner,
                 gs_lfa-land1,
                 gv_trenner,
                 p_nland,
                 gv_trenner,
                 gv_taus.
        ELSE.
          CONCATENATE gs_lfa-lifnr gv_trenner
                      gs_lfa-land1 gv_trenner
                      p_nland      gv_trenner
                      gv_taus INTO gv_strmsg RESPECTING BLANKS.
          MESSAGE gv_strmsg TYPE 'S'.
        ENDIF.
      ELSE.
        IF sy-batch IS INITIAL.
          WRITE: /5 'LFA1-Update: Fehler LIFNR ', gv_trenner, gs_lfa-lifnr.
        ELSE.
          CONCATENATE 'LFA1-Update: Fehler LIFNR ' gv_trenner
                       gs_lfa-lifnr INTO gv_strmsg RESPECTING BLANKS.
          MESSAGE gv_strmsg TYPE 'S'.
        ENDIF.
      ENDIF.
    ENDLOOP.

************************************************************************
*   ADRC                                                               *
************************************************************************
    IF sy-batch IS INITIAL.
      WRITE: /5 'Protokoll - ADRC'.
    ELSE.
      MESSAGE 'Protokoll - ADRC' TYPE 'S'.
    ENDIF.
    LOOP AT gt_adr INTO gs_adr.
      UPDATE adrc SET country = p_nland
                      langu   = 'D'
                  WHERE addrnumber = gs_adr-addrnumber.
      IF 0 EQ sy-subrc.
        IF sy-batch IS INITIAL.
          WRITE: /5 gs_adr-addrnumber,
                 gv_trenner,
                 gs_adr-country,
                 gv_trenner,
                 p_nland,
                 gv_trenner,
                 gv_taus.
        ELSE.
          CONCATENATE gs_adr-addrnumber gv_trenner
                      gs_adr-country    gv_trenner
                      p_nland           gv_trenner
                      gv_taus INTO gv_strmsg RESPECTING BLANKS.
          MESSAGE gv_strmsg TYPE 'S'.
        ENDIF.
      ELSE.
        IF sy-batch IS INITIAL.
          WRITE: /5 'ADRC-Update: Fehler ADRNR ', gv_trenner, gs_adr-addrnumber.
        ELSE.
          CONCATENATE 'ADRC-Update: Fehler ADRNR ' gv_trenner
                       gs_adr-addrnumber INTO gv_strmsg RESPECTING BLANKS.
          MESSAGE gv_strmsg TYPE 'S'.
        ENDIF.
      ENDIF.
    ENDLOOP.

************************************************************************
*   ADRCO                                                              *
************************************************************************
    IF sy-batch IS INITIAL.
      WRITE: /5 'Protokoll - ADRCO'.
    ELSE.
      MESSAGE 'Protokoll - ADRCO' TYPE 'S'.
    ENDIF.
    LOOP AT gt_adro INTO gs_adro.
      UPDATE adrc SET country = p_nland
                      langu   = 'D'
                  WHERE addrnumber = gs_adro-addrnumber.
      IF 0 EQ sy-subrc.
        CLEAR: gv_stras, gv_length.
        gv_length = strlen( gs_adro-street ).
        IF gv_length > 0.
          CONCATENATE gs_adro-street+0(gv_length) ' ' gs_adro-house_num1 INTO gv_stras RESPECTING BLANKS.

          UPDATE kna1 SET land1 = p_nland
                          stras = gv_stras
                      WHERE adrnr = gs_adro-addrnumber.
          UPDATE lfa1 SET land1 = p_nland
                          stras = gv_stras
                      WHERE adrnr = gs_adro-addrnumber.
        ELSE.
          UPDATE kna1 SET land1 = p_nland
                      WHERE adrnr = gs_adro-addrnumber.
          UPDATE lfa1 SET land1 = p_nland
                      WHERE adrnr = gs_adro-addrnumber.
        ENDIF.

        IF sy-batch IS INITIAL.
          WRITE: /5 gs_adro-addrnumber,
                 gv_trenner,
                 gs_adro-country,
                 gv_trenner,
                 p_nland,
                 gv_trenner,
                 gv_taus.
        ELSE.
          CONCATENATE gs_adro-addrnumber gv_trenner
                      gs_adro-country    gv_trenner
                      p_nland           gv_trenner
                      gv_taus INTO gv_strmsg RESPECTING BLANKS.
          MESSAGE gv_strmsg TYPE 'S'.
        ENDIF.
      ELSE.
        IF sy-batch IS INITIAL.
          WRITE: /5 'ADRCO-Update: Fehler ADRNR ', gv_trenner, gs_adro-addrnumber.
        ELSE.
          CONCATENATE 'ADRCO-Update: Fehler ADRNR ' gv_trenner
                       gs_adro-addrnumber INTO gv_strmsg RESPECTING BLANKS.
          MESSAGE gv_strmsg TYPE 'S'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ELSE.
    MOVE 'TEST'      TO gv_taus.
************************************************************************
*   Protokollausgabe auf BS bzw. JobLog                                *
************************************************************************
*   KNA1                                                               *
************************************************************************
    IF sy-batch IS INITIAL.
      WRITE: /5 'Protokoll - KNA1'.
    ELSE.
      MESSAGE 'Protokoll - KNA1' TYPE 'S'.
    ENDIF.
    LOOP AT gt_kna INTO gs_kna.
      IF sy-batch IS INITIAL.
        WRITE: /5 gs_kna-kunnr,
               gv_trenner,
               gs_kna-land1,
               gv_trenner,
               p_nland,
               gv_trenner,
               gv_taus.
      ELSE.
        CONCATENATE gs_kna-kunnr gv_trenner
                    gs_kna-land1 gv_trenner
                    p_nland      gv_trenner
                    gv_taus INTO gv_strmsg RESPECTING BLANKS.
        MESSAGE gv_strmsg TYPE 'S'.
      ENDIF.
    ENDLOOP.

************************************************************************
*   LFA1                                                               *
************************************************************************
    IF sy-batch IS INITIAL.
      WRITE: /5 'Protokoll - LFA1'.
    ELSE.
      MESSAGE 'Protokoll - LFA1' TYPE 'S'.
    ENDIF.
    LOOP AT gt_lfa INTO gs_lfa.
      IF sy-batch IS INITIAL.
        WRITE: /5 gs_lfa-lifnr,
               gv_trenner,
               gs_lfa-land1,
               gv_trenner,
               p_nland,
               gv_trenner,
               gv_taus.
      ELSE.
        CONCATENATE gs_lfa-kunnr gv_trenner
                    gs_lfa-land1 gv_trenner
                    p_nland      gv_trenner
                    gv_taus INTO gv_strmsg RESPECTING BLANKS.
        MESSAGE gv_strmsg TYPE 'S'.
      ENDIF.
    ENDLOOP.

************************************************************************
*   ADRC                                                               *
************************************************************************
    IF sy-batch IS INITIAL.
      WRITE: /5 'Protokoll - ADRC'.
    ELSE.
      MESSAGE 'Protokoll - ADRC' TYPE 'S'.
    ENDIF.
    LOOP AT gt_adr INTO gs_adr.
      IF sy-batch IS INITIAL.
        WRITE: /5 gs_adr-addrnumber,
               gv_trenner,
               gs_adr-country,
               gv_trenner,
               p_nland,
               gv_trenner,
               gv_taus.
      ELSE.
        CONCATENATE gs_adr-addrnumber gv_trenner
                    gs_adr-country    gv_trenner
                    p_nland           gv_trenner
                    gv_taus INTO gv_strmsg RESPECTING BLANKS.
        MESSAGE gv_strmsg TYPE 'S'.
      ENDIF.
    ENDLOOP.

************************************************************************
*   ADRCO                                                              *
************************************************************************
    IF sy-batch IS INITIAL.
      WRITE: /5 'Protokoll - ADRCO'.
    ELSE.
      MESSAGE 'Protokoll - ADRCO' TYPE 'S'.
    ENDIF.
    LOOP AT gt_adro INTO gs_adro.
      IF sy-batch IS INITIAL.
        WRITE: /5 gs_adro-addrnumber,
               gv_trenner,
               gs_adro-country,
               gv_trenner,
               p_nland,
               gv_trenner,
               gv_taus.
      ELSE.
        CONCATENATE gs_adro-addrnumber gv_trenner
                    gs_adro-country    gv_trenner
                    p_nland            gv_trenner
                    gv_taus INTO gv_strmsg RESPECTING BLANKS.
        MESSAGE gv_strmsg TYPE 'S'.
      ENDIF.
    ENDLOOP.
  ENDIF.

************************************************************************
* Ende der Datenselektion                                              *
************************************************************************
END-OF-SELECTION.

************************************************************************
* Initialisierung Selektions-Title                                     *
************************************************************************
  a1_titel = TEXT-t01.
