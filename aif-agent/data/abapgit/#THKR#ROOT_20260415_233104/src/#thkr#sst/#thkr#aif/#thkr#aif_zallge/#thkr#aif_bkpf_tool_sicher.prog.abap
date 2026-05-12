*&---------------------------------------------------------------------*
* Gereon Koks  2.3.2026  T-Systems
*&---------------------------------------------------------------------*
* Analyse BKPF und Update.
* Reihenfolge immer DR,DG,D1
*&---------------------------------------------------------------------*
*& Report /THKR/AIF_BKPF_TOOL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/aif_bkpf_tool_sicher LINE-SIZE 400.
*&---------------------------------------------------------------------*
TABLES: bkpf.
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_bkpf_neu.
         INCLUDE TYPE bkpf.
TYPES:   kunnr TYPE kunnr,
         rebzg TYPE rebzg,
         rebzj TYPE rebzj,
         rebzz TYPE rebzz,
         nr    TYPE i.
TYPES: END OF ty_bkpf_neu.
*&---------------------------------------------------------------------*
* DR
DATA: ls_bkpf1     TYPE ty_bkpf_neu,
* DG
      ls_bkpf2     TYPE ty_bkpf_neu,
* D1
      ls_bkpf3     TYPE ty_bkpf_neu,
* Zwischenspeicher
      ls_bkpf      TYPE ty_bkpf_neu,

      ls_bseg      TYPE bseg,

* DG
      lt_bkpf2     TYPE TABLE OF ty_bkpf_neu,
* D1
      lt_bkpf3     TYPE TABLE OF ty_bkpf_neu,

* Bündel
      lv_anz       TYPE i,
* Treffer (der wievielte ?)
      lv_trf       TYPE i,

      lv_nr1       TYPE i,
      lv_nr2       TYPE i,
      lv_nr3       TYPE i,

      lv_anz_bkpf2 TYPE i,
      lv_anz_bkpf3 TYPE i,

* DG dabei ?
      lv_flg2,
* D1 dabei ?
      lv_flg3,
      lv_awkey     TYPE awkey.
*&---------------------------------------------------------------------*
PARAMETERS: ak_tst AS CHECKBOX DEFAULT 'X'.
* Nur Treffer listen
PARAMETERS: ak_trf AS CHECKBOX.
* Prüfen, ob XBLNR leer
PARAMETERS: ak_chk AS CHECKBOX.
SELECT-OPTIONS so_bukrs FOR bkpf-bukrs.
SELECT-OPTIONS so_belnr FOR bkpf-belnr.
SELECT-OPTIONS so_gjahr FOR bkpf-gjahr.
SELECT-OPTIONS so_usnam FOR bkpf-usnam.
* Start Annahmeanordnung (DR)
SELECT-OPTIONS so_blar1 FOR bkpf-blart.
* Absetzungs-Annahmeanordnung (DG,6600...,2400...)
SELECT-OPTIONS so_blar2 FOR bkpf-blart.
* Annahmeanordnung (D1,6000...,2100...)
SELECT-OPTIONS so_blar3 FOR bkpf-blart.
SELECT-OPTIONS so_bldat FOR bkpf-bldat.
SELECT-OPTIONS so_lotkz FOR bkpf-lotkz.
*&---------------------------------------------------------------------*
* DR lesen
SELECT * FROM bkpf INTO ls_bkpf1
  WHERE bukrs IN so_bukrs
    AND belnr IN so_belnr
    AND gjahr IN so_gjahr
    AND usnam IN so_usnam
    AND blart IN so_blar1
    AND bldat IN so_bldat
    AND lotkz IN so_lotkz.

  IF ak_chk = 'X'.
    IF ls_bkpf1-xblnr IS INITIAL.
      CONTINUE.
    ENDIF.
  ENDIF.

  CLEAR: lv_flg2,
         lv_flg3,
         lt_bkpf2,
         lt_bkpf3,
         lv_nr2,
         lv_nr3.

  ADD 1 TO lv_anz.
*&---------------------------------------------------------------------*
* DG lesen (abhängig von DR)
  SELECT * FROM bkpf INTO TABLE lt_bkpf2
    WHERE bukrs =  ls_bkpf1-bukrs
      AND blart IN so_blar2
      AND bktxt =  ls_bkpf1-xblnr.

  IF sy-subrc = 0.
    lv_flg2 = 'X'.
  ENDIF.

  SORT lt_bkpf2 BY belnr.
  DESCRIBE TABLE lt_bkpf2 LINES lv_anz_bkpf2.
*&---------------------------------------------------------------------*
* D1 lesen (abhängig von DR)
  SELECT * FROM bkpf INTO TABLE lt_bkpf3
    WHERE bukrs =  ls_bkpf1-bukrs
      AND blart IN so_blar3
      AND bktxt =  ls_bkpf1-xblnr.

  IF sy-subrc = 0.
    lv_flg3 = 'X'.
  ENDIF.

  SORT lt_bkpf3 BY belnr.
  DESCRIBE TABLE lt_bkpf3 LINES lv_anz_bkpf3.
*&---------------------------------------------------------------------*
  IF ak_trf IS INITIAL.
* Alle listen (auch die nicht Treffer)
    WRITE: /1 '###############################################################################################################################################'.
* DR
    PERFORM bkpf_write USING lv_anz ls_bkpf1.
* DG
    LOOP AT lt_bkpf2 INTO ls_bkpf2.
      ADD 1 TO lv_nr2.
      ls_bkpf2-nr = lv_nr2.
      PERFORM bkpf_write USING lv_anz ls_bkpf2.
      MODIFY lt_bkpf2 FROM ls_bkpf2.
    ENDLOOP.
* D1
    LOOP AT lt_bkpf3 INTO ls_bkpf3.
      ADD 1 TO lv_nr3.
      ls_bkpf3-nr = lv_nr3.
      PERFORM bkpf_write USING lv_anz ls_bkpf3.
      MODIFY lt_bkpf3 FROM ls_bkpf3.
    ENDLOOP.
*&---------------------------------------------------------------------*
  ELSE.
* Nur die Treffer listen (DG und D1 gefunden)
    IF lv_flg2 = 'X' AND
       lv_flg3 = 'X' AND
       lv_anz_bkpf2 >= 2 AND
       lv_anz_bkpf3 >= 2.

* Treffer hochzählen
      ADD 1 TO lv_trf.

      WRITE: /1 '###############################################################################################################################################'.
* DR
      PERFORM bkpf_write USING lv_anz ls_bkpf1.
* DG
      LOOP AT lt_bkpf2 INTO ls_bkpf2.
        ADD 1 TO lv_nr2.
        ls_bkpf2-nr = lv_nr2.
        PERFORM bkpf_write USING lv_anz ls_bkpf2.
        MODIFY lt_bkpf2 FROM ls_bkpf2.
      ENDLOOP.
* D1
      LOOP AT lt_bkpf3 INTO ls_bkpf3.
        ADD 1 TO lv_nr3.
        ls_bkpf3-nr = lv_nr3.
        PERFORM bkpf_write USING lv_anz ls_bkpf3.
        MODIFY lt_bkpf3 FROM ls_bkpf3.
      ENDLOOP.
*&---------------------------------------------------------------------*
* Umsortieren (nur wenn es ein Treffer ist)
      CLEAR lv_nr1.

      ULINE.
      WRITE: /1 'Umsortieren'.
      ULINE.
*&---------------------------------------------------------------------*
* DR
      PERFORM bkpf_write USING lv_anz ls_bkpf1.
*&---------------------------------------------------------------------*
      WHILE sy-subrc = 0.
        ADD 1 TO lv_nr1.
*&---------------------------------------------------------------------*
* DG
        READ TABLE lt_bkpf2 INTO ls_bkpf2 WITH KEY nr = lv_nr1.
        CHECK sy-subrc = 0.
        PERFORM bkpf_write USING lv_anz ls_bkpf2.
* AWKEY vom D1 davor muss verwendet werden
        IF lv_nr1 >= 2.
          CONCATENATE ls_bkpf3-belnr ls_bkpf3-bukrs ls_bkpf3-gjahr INTO lv_awkey.
          WRITE: '=> AWKEY:', lv_awkey.
          WRITE: '=> KUNNR:'.

          FORMAT INTENSIFIED ON.
          WRITE: ls_bkpf3-kunnr.
          FORMAT INTENSIFIED OFF.

          WRITE: '=> REBZG:'.

          FORMAT INTENSIFIED ON.
          WRITE: ls_bkpf3-belnr.
          FORMAT INTENSIFIED OFF.

          WRITE: '=> REBZJ:', ls_bkpf3-gjahr.
          WRITE: '=> REBZZ: 001'.

* Update ?
          IF ak_tst IS INITIAL.
* BKPF Update
            SELECT * FROM bkpf INTO ls_bkpf
              WHERE bukrs = ls_bkpf2-bukrs
                AND belnr = ls_bkpf2-belnr
                AND gjahr = ls_bkpf2-gjahr.

              ls_bkpf-awkey = lv_awkey.

              MODIFY bkpf FROM ls_bkpf.

              IF sy-subrc = 0.
                WRITE: '=> BKPF OK'.
              ELSE.
                WRITE: '=> BKPF ERROR'.
              ENDIF.
            ENDSELECT.
* BSEG Update
            SELECT * FROM bseg INTO ls_bseg
              WHERE bukrs = ls_bkpf2-bukrs
                AND belnr = ls_bkpf2-belnr
                AND gjahr = ls_bkpf2-gjahr
                AND buzei = '001'.

              ls_bseg-kunnr = ls_bkpf3-kunnr.
* Rechnungsbezug steht nicht in BSEG von D1 sondern muss zusammengebaut werden
              ls_bseg-rebzg = ls_bkpf3-belnr.
              ls_bseg-rebzj = ls_bkpf3-gjahr.
              ls_bseg-rebzz = '001'.

              MODIFY bseg FROM ls_bseg.

              IF sy-subrc = 0.
                WRITE: '=> BSEG OK'.
              ELSE.
                WRITE: '=> BSEG ERROR'.
              ENDIF.
            ENDSELECT.
          ENDIF.
        ENDIF.
*&---------------------------------------------------------------------*
* D1
        READ TABLE lt_bkpf3 INTO ls_bkpf3 WITH KEY nr = lv_nr1.
        CHECK sy-subrc = 0.
        PERFORM bkpf_write USING lv_anz ls_bkpf3.
*&---------------------------------------------------------------------*
      ENDWHILE.
    ENDIF.
  ENDIF.
*&---------------------------------------------------------------------*
ENDSELECT.

IF sy-subrc <> 0.
  WRITE: /1 'Kein Treffer gefunden !'.
ENDIF.
*&---------------------------------------------------------------------*
*& Form bkpf_write
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_BKPF2
*&---------------------------------------------------------------------*
FORM bkpf_write  USING    p_lv_anz TYPE i
                          p_ls_bkpf TYPE ty_bkpf_neu.
*&---------------------------------------------------------------------*
  DATA: ls_bseg TYPE bseg.
*&---------------------------------------------------------------------*
  WRITE: /1 p_lv_anz,
            lv_trf,
            p_ls_bkpf-nr,
            p_ls_bkpf-blart,
            p_ls_bkpf-psoty,
            'LOTKZ:', p_ls_bkpf-lotkz,
            'BELNR:'.

  IF p_ls_bkpf-blart IN so_blar3.
    FORMAT INTENSIFIED ON.
  ENDIF.

  WRITE:    p_ls_bkpf-belnr.

  IF p_ls_bkpf-blart IN so_blar3.
    FORMAT INTENSIFIED OFF.
  ENDIF.

  WRITE:    p_ls_bkpf-bukrs,
            p_ls_bkpf-gjahr,
            'XBLNR:', p_ls_bkpf-xblnr,
           'BKTXT:', p_ls_bkpf-bktxt.
*&---------------------------------------------------------------------*
  SELECT * FROM bseg INTO ls_bseg
    WHERE bukrs = p_ls_bkpf-bukrs
      AND belnr = p_ls_bkpf-belnr
      AND gjahr = p_ls_bkpf-gjahr
      AND buzei = '001'.

    WRITE: 'KUNNR:'.

    IF p_ls_bkpf-blart IN so_blar3.
      FORMAT INTENSIFIED ON.
    ENDIF.

    WRITE: ls_bseg-kunnr.

    IF p_ls_bkpf-blart IN so_blar3.
      FORMAT INTENSIFIED OFF.
    ENDIF.

    WRITE: 'REBZG:', ls_bseg-rebzg,
           'REBZJ:', ls_bseg-rebzj,
           'REBZZ:', ls_bseg-rebzz.

    p_ls_bkpf-kunnr = ls_bseg-kunnr.
  ENDSELECT.
*&---------------------------------------------------------------------*
ENDFORM.
