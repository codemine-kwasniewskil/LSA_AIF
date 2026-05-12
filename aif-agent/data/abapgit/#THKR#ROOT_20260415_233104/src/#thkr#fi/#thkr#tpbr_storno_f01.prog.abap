*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_STORNO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init .

  CLEAR: gs_storno, gv_fehler, uf05a, vbrk, ok-code, gv_modus, gv_referr.
  "gt_referenz, gt_refnr, gs_refnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form eingaben_verarbeiten
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM eingaben_verarbeiten .

  IF gs_storno-stgrd IS INITIAL.
    gv_fehler = abap_true.
    MESSAGE w364(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
    " Bitte geben Sie einen Stornogrund an.
    gv_fehler = abap_true.
  ENDIF.

  IF gs_storno-modul = 'RE'.
    " Nur Stornogründe S1 und S2 sind erlaubt
    IF gs_storno-stgrd <> 'S1' AND gs_storno-stgrd <> 'S2'.
      MESSAGE w387(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

  IF NOT gs_storno-monat CO '1234567890'.

    MESSAGE 'Die Buchungsperiode darf nur Zahlen enthalten!' TYPE 'W' DISPLAY LIKE 'E'.
    gv_fehler = abap_true.

  ENDIF.

*  IF    gs_storno-zz_k1 IS INITIAL
*    AND gs_storno-zz_k2 IS INITIAL
*    AND gs_storno-zz_k3 IS INITIAL.
*    gv_fehler = abap_true.
*    MESSAGE w361(/THKR/FI_WF_BKPF) DISPLAY LIKE 'E'.
*    " Bitte tragen Sie eine Bemerkung ein.
*    gv_fehler = abap_true.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form beleg_sichern
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM beleg_sichern .

  DATA: lv_belnr(16) TYPE c.

  IF gv_fehler IS NOT INITIAL.
    MESSAGE w370(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
    RETURN.
* Daten können nicht gesichert werden. Bitte beheben Sie zuerst die Fehler.
  ENDIF.

* Bei SD-Belegen darf das GJAHR nicht übernommen werden,
* um die Eindeutigkeit zu gewährleisten
  IF gs_storno-modul = 'SD'.
    CLEAR gs_storno-gjahr.
  ENDIF.

  IF gs_storno-modul <> 'RE'.
* vorhandene Belege prüfen und Nummer vergeben
    SELECT lfdnr FROM /thkr/stornoc UP TO 1 ROWS
      INTO gs_storno-lfdnr
       WHERE bukrs = gs_storno-bukrs
        AND  modul = gs_storno-modul
        AND  belnr = gs_storno-belnr
        AND  gjahr = gs_storno-gjahr
      ORDER BY lfdnr DESCENDING.
    ENDSELECT.
    " Neue laufende Nummer wird gesetzt
    ADD 1 TO gs_storno-lfdnr.
  ENDIF.


* Kopfdaten anreichern
  gs_storno-status = '10'.
  gs_storno-usnam = sy-uname.
  gs_storno-cpudt = sy-datum.
  gs_storno-cputm = sy-uzeit.
*
** Bei FÖBIS belegen, muss das KZ FÖBIS gesetzt werden
*  IF gv_modus = 'FB'.
*    gs_storno-zz_foebis = abap_true.
*  ELSE.
*    CLEAR gs_storno-zz_foebis.
*  ENDIF.

* Bei REFX muss das KZ REFX REFNR gesetzt werden
*  IF gv_modus = 'RE'.
*    gs_storno-zz_refx_refnr = abap_true.
*  ELSE.
*    CLEAR gs_storno-zz_refx_refnr.
*  ENDIF.

* Daten speichern
  IF gs_storno-monat IS INITIAL.
    gs_storno-monat = 00.
  ENDIF.

  INSERT /thkr/stornoc FROM gs_storno.
  IF sy-subrc NE 0.
    ROLLBACK WORK.
    MESSAGE e352(/thkr/fi_wf_bkpf).
* Die Änderungen konnten nicht gespeichert werden.
  ELSE.

    IF gv_modus = 'RE'.
*      IF gt_refnr IS NOT INITIAL.
*        " Aktualisieren der Daten in der Datenbank
*        INSERT zfi_refx_refnr FROM TABLE gt_refnr.
*      ENDIF.
*      MESSAGE s390(/THKR/FI_WF_BKPF) WITH gs_storno-bukrs gs_storno-recnnr.
    ELSE.
      CONCATENATE gs_storno-belnr ' / ' gs_storno-lfdnr
       INTO lv_belnr RESPECTING BLANKS.
      MESSAGE s323(f5) WITH lv_belnr gs_storno-bukrs.
* Document & was stored in company code &
    ENDIF.

*    Beleg an WF übergeben
    CALL FUNCTION '/THKR/WF_START_BKPF_STORNO'
      EXPORTING
        is_storno                = gs_storno
      EXCEPTIONS
        no_workflow_start        = 1
        bereits_offener_workflow = 2
        OTHERS                   = 3.

    CASE sy-subrc.
      WHEN '1'.
        MESSAGE e358(/thkr/fi_wf_bkpf).
*         Der Workflow konnte nicht gestartet werden.
      WHEN '2'.
        MESSAGE e357(/thkr/fi_wf_bkpf).
*         Zu diesem Beleg wurde bereits ein Workflow gestartet.
      WHEN '3'.
        MESSAGE e359(/thkr/fi_wf_bkpf).
*         Es ist ein unbekannter Fehler bei der
*         Workflowverarbeitung aufgetreten.
    ENDCASE.

*    " Meldung bei falschen Referenzen
*    IF gv_referr IS NOT INITIAL.
*      MESSAGE w391(/THKR/FI_WF_BKPF).
*    ENDIF.
  ENDIF.

  PERFORM init.
  IF sy-tcode = gc_tcode_k .                      "001
    CALL SCREEN '0110'.
  ELSE.
    CALL SCREEN '0100'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_storno
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_storno.

  DATA: lv_lfdnr TYPE lfdnr.

* Prüfen, ob der Beleg für Stornierung vorgesehen ist
  SELECT SINGLE lfdnr FROM /thkr/stornoc
                      INTO lv_lfdnr
                     WHERE bukrs = gs_storno-bukrs
                       AND modul = gs_storno-modul
                       AND gjahr = gs_storno-gjahr
                       AND belnr = gs_storno-belnr
                       AND ( status NE '40' AND status NE '45' ). "Abgelehnt und Abbruch durch SA

  IF sy-subrc = 0.
    gv_fehler = abap_true.
    MESSAGE w356(/thkr/fi_wf_bkpf)
       WITH gs_storno-belnr gs_storno-bukrs gs_storno-gjahr lv_lfdnr
       DISPLAY LIKE 'E'.
* Der Beleg &1/&2/&3 ist unter der Nummer &4 zum Storno vorgesehen.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form faktura_lesen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM faktura_lesen .

  DATA: lv_stgrd TYPE vbrk-stgrd.

  DATA: ls_storno_ext TYPE gty_s_storno,
        ls_fibeleg    TYPE vbrk.


  gs_storno-modul = 'SD'.

  IF NOT vbrk-stgrd IS INITIAL.
    SELECT SINGLE stgrd FROM t041c
      INTO lv_stgrd
      WHERE stgrd = vbrk-stgrd.
    IF sy-subrc <> 0.
      CLEAR: ok-code.
      gv_fehler = abap_true.
      MESSAGE w058(00) WITH vbrk-stgrd space space 'T041C'
      DISPLAY LIKE 'E'.
      RETURN.
    ELSE.
      gs_storno-stgrd = vbrk-stgrd.
    ENDIF.
  ENDIF.

  IF gs_storno-belnr IS NOT INITIAL.

    " Lesen der FI Belegdaten für Prüfung Ausgleichsbeleg
    SELECT SINGLE belnr, gjahr, bukrs INTO CORRESPONDING FIELDS OF @ls_fibeleg FROM vbrk
                                      WHERE vbeln = @gs_storno-belnr.
    IF sy-subrc = 0.

      " Prüfung ob ein Ausgleichsbeleg für den FI-Beleg existiert
      SELECT SINGLE augbl INTO @DATA(lv_augbl) FROM bseg WHERE bukrs = @ls_fibeleg-bukrs
                                                           AND belnr = @ls_fibeleg-belnr
                                                           AND gjahr = @ls_fibeleg-gjahr
                                                           AND koart = 'D'.   " Debitor
      IF sy-subrc = 0 AND lv_augbl IS NOT INITIAL.
        MESSAGE e378(/thkr/fi_wf_bkpf).
      ENDIF.
    ELSE.
      MESSAGE w368(/thkr/fi_wf_bkpf) WITH '&1' DISPLAY LIKE 'E'.
      " Kein Fakturabeleg mit der Nummer &1 vorhanden.
      gv_fehler = abap_true.
    ENDIF.

    " Lesen Fakturabeleg
    SELECT SINGLE vbeln AS belnr bukrs gjahr buchk
      FROM vbrk
      INTO CORRESPONDING FIELDS OF ls_storno_ext
      WHERE vbeln = gs_storno-belnr.

    IF sy-subrc NE 0.
      MESSAGE w368(/thkr/fi_wf_bkpf) WITH '&1' DISPLAY LIKE 'E'.
* Kein Fakturabeleg mit der Nummer &1 vorhanden.
      gv_fehler = abap_true.
    ELSE.
*** Status prüfen
      IF ls_storno_ext-buchk NE 'C'.
        MESSAGE e376(/thkr/fi_wf_bkpf).
* Buchungsstatus Faktura ungleich 'C' ist nicht erlaubt.
      ENDIF.
      MOVE ls_storno_ext-bukrs TO gs_storno-bukrs.
      MOVE ls_storno_ext-gjahr TO gs_storno-gjahr.
      PERFORM authcheck_kopf USING ls_storno_ext-bukrs.
*     Positionen für Authcheck lesen
      SELECT gsber FROM vbrp  UP TO 1 ROWS
                   INTO ls_storno_ext-gsber
                  WHERE vbeln = gs_storno-belnr
        ORDER BY PRIMARY KEY.
      ENDSELECT.

      PERFORM authcheck_gsber USING ls_storno_ext-gsber.
*      PERFORM authcheck_beleg USING ls_storno_ext.
    ENDIF.

    PERFORM check_storno_sd.

    " Prüfen ob mehrere Kostenstellen zur Verfügung
    gv_kstl_cho = abap_false.
    SELECT SINGLE gsber, kostl, aufnr, prctr, ps_psp_pnr INTO @DATA(ls_vbrp) "#EC CI_NOORDER
                                                         FROM vbrp
                                                         WHERE vbeln EQ @gs_storno-belnr.
    IF sy-subrc = 0.
      " Ermittlung Kostenstelle
      IF ls_vbrp-kostl IS NOT INITIAL.
        " Übernahme Kostenstelle aus Faktura
        DATA(lv_kostl) = ls_vbrp-kostl .
      ELSEIF ls_vbrp-aufnr IS NOT INITIAL.
        " Ermitteln Kostenstelle aus dem Auftrag
        SELECT SINGLE kostl, kostv INTO @DATA(ls_kostl)
          FROM aufk WHERE aufnr EQ @ls_vbrp-aufnr.      "#EC CI_GENBUFF
        IF sy-subrc EQ 0.
          " Übername Kostenstelle aus Auftrag
          IF ls_kostl-kostl IS NOT INITIAL.
            lv_kostl = ls_kostl-kostl.
          ELSE.
            lv_kostl = ls_kostl-kostv.
          ENDIF.
        ENDIF.
      ENDIF.
      " Selektion über Profitcenter auch bei Fehler aus Auftrag
      IF lv_kostl IS INITIAL AND ls_vbrp-prctr IS NOT INITIAL.
        " Ermitteln Kostenstelle zum Profitcenter
        SELECT kostl INTO TABLE @DATA(lt_kostl) FROM csks WHERE datbi >= @sy-datum "#EC CI_NOORDER "#EC CI_GENBUFF
                                                            AND prctr = @ls_vbrp-prctr.
        IF sy-subrc = 0.
          DESCRIBE TABLE lt_kostl LINES DATA(lv_lines).
          IF lv_lines > 1.
            gv_kstl_cho = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form beleg_lesen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM beleg_lesen .

  CLEAR: gv_fehler, gv_kstl_cho.           " 002

  CASE sy-dynnr.
    WHEN '0301'.
      PERFORM mmbeleg_lesen.
    WHEN '0302'.
      PERFORM faktura_lesen.
    WHEN '0303'.
      PERFORM fibeleg_lesen.
    WHEN '0304'.
      PERFORM fibeleg_lesen.
    WHEN '0305'.
      PERFORM refxbelege_lesen.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mmbeleg_lesen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM mmbeleg_lesen .

  DATA: ls_storno     LIKE gs_storno,
        ls_storno_ext TYPE gty_s_storno.

  DATA: lr_tab TYPE REF TO data.

  DATA: lt_itemdata       TYPE bapi_incinv_detail_item_t,
        lt_accountingdata TYPE tb_bapi_incinv_detail_account,
        lt_return         TYPE bapiret2_tab.

  FIELD-SYMBOLS: <ft_blart_range> TYPE /THKR/T_FI_blart.


  IF   gs_storno-belnr IS INITIAL
    OR gs_storno-gjahr IS INITIAL.
    gv_fehler = abap_true.
    MESSAGE w363(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
* Bitte geben Sie die Belegnummer und das Geschäftsjahr an.
  ELSE.

* Prüfung, ob ein Ausgleichsbeleg angegeben wurde
    DATA: lv_awkey TYPE bkpf-awkey.
    CONCATENATE gs_storno-belnr gs_storno-gjahr INTO lv_awkey.

    SELECT bkpf~belnr, bseg~augbl
      FROM bkpf AS bkpf
      JOIN bseg AS bseg
      ON   bkpf~bukrs EQ bseg~bukrs
      AND  bkpf~gjahr EQ bseg~gjahr
      AND  bkpf~belnr EQ bseg~belnr
      WHERE bkpf~awkey EQ @lv_awkey
      AND  bkpf~awtyp EQ 'RMRP'
      AND  bkpf~blart EQ 'RN'
      AND  bseg~koart EQ 'K'
      AND  bseg~augbl IS NOT INITIAL
      INTO TABLE @DATA(lt_beleg).

    CLEAR: lv_awkey.

    IF sy-subrc IS INITIAL AND lt_beleg IS NOT INITIAL.
      CLEAR: lt_beleg.
      MESSAGE e378(/thkr/fi_wf_bkpf).
    ENDIF.

    gs_storno-stgrd = uf05a-stgrd.
    gs_storno-modul = 'MM'.

    CHECK gs_storno-belnr IS NOT INITIAL
      AND gs_storno-gjahr IS NOT INITIAL.

    SELECT SINGLE belnr gjahr bukrs gsber rbstat blart
            FROM rbkp
            INTO CORRESPONDING FIELDS OF ls_storno_ext
           WHERE belnr = gs_storno-belnr
             AND gjahr = gs_storno-gjahr.
    IF sy-subrc NE 0.
      gv_fehler = abap_true.
      MESSAGE w366(/thkr/fi_wf_bkpf) WITH gs_storno-belnr gs_storno-gjahr
                           DISPLAY LIKE 'E'.
* Es ist kein Beleg unter der Nummer &1 im Jahr &2 vorhanden.
    ELSE.
      MOVE ls_storno_ext-bukrs TO gs_storno-bukrs.
*** Belegart prüfen
      CALL METHOD /THKR/cl_fi_helper=>get_param
        EXPORTING
          iv_programm  = 'Z_TPBR_STORNO_WF'
          iv_fieldname = 'ZMM_BLART_VIM'
          iv_entrykey  = '00000001'
        IMPORTING
          et_range     = lr_tab
        EXCEPTIONS
          no_data      = 1
          OTHERS       = 2.
      IF sy-subrc NE 0.
        MESSAGE e375(/thkr/fi_wf_bkpf).
* Fehler bei der Ermittlung gültiger Belegarten aus der Parametertabelle.
      ENDIF.
      ASSIGN lr_tab->* TO <ft_blart_range>.
      IF NOT ls_storno_ext-blart IN <ft_blart_range>.
        gv_fehler = abap_true.
        MESSAGE e374(/thkr/fi_wf_bkpf) WITH 'MM-Beleg (VIM)'(001).
* Kombination aus Referenzvorgang und Belegart ist für &1 nicht zugelassen.
      ENDIF.
*** Status prüfen
      IF ls_storno_ext-rbstat NE '5'.
        MESSAGE e373(/thkr/fi_wf_bkpf).
* Storno nur im Rechnungsbelegstatus 5 (Gebucht) erlaubt.
      ENDIF.
      " Prüfung Geschäftsbereich
      IF ls_storno_ext-gsber IS INITIAL.
        " Ermitteln Detaildaten zur Rechnung
        CALL FUNCTION 'BAPI_INCOMINGINVOICE_GETDETAIL'
          EXPORTING
            invoicedocnumber = gs_storno-belnr
            fiscalyear       = gs_storno-gjahr
          TABLES
            itemdata         = lt_itemdata
            accountingdata   = lt_accountingdata
            return           = lt_return
          EXCEPTIONS
            OTHERS           = 01.
        IF sy-subrc = 0.                             " OK
          " Übergabe Geschäftsbereich aus Kontierungsdaten
          READ TABLE lt_accountingdata ASSIGNING FIELD-SYMBOL(<fs_account>) INDEX 1.
          IF sy-subrc = 0.
            ls_storno_ext-gsber =  <fs_account>-bus_area.
          ENDIF.
        ENDIF.
      ENDIF.
      PERFORM authcheck_kopf USING ls_storno_ext-bukrs.
      PERFORM authcheck_gsber USING ls_storno_ext-gsber.
*     Positionen für Authcheck lesen
*      PERFORM authcheck_beleg USING ls_storno_ext.
    ENDIF.

    PERFORM check_storno.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fibeleg_lesen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fibeleg_lesen .

  DATA: ls_storno_ext TYPE gty_s_storno.

  DATA: ls_bseg TYPE bseg.

  DATA: lr_tab TYPE REF TO data.

  FIELD-SYMBOLS: <ft_blart_range> TYPE /THKR/T_FI_blart.

  gs_storno-stgrd = uf05a-stgrd.
  gs_storno-modul = 'FI'.

* Eingaben prüfen
  IF gs_storno-bukrs IS INITIAL
  OR gs_storno-gjahr IS INITIAL
  OR gs_storno-belnr IS INITIAL.
    gv_fehler = abap_true.
    MESSAGE w360(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
* Bitte geben Sie Belegnummer, Buchungskreis und Geschäftsjahr an.
  ENDIF.

* Prüfung, ob ein Ausgleichsbeleg angegeben wurde
  SELECT augbl
    FROM bseg
    WHERE bukrs EQ @gs_storno-bukrs
    AND   gjahr EQ @gs_storno-gjahr
    AND   belnr EQ @gs_storno-belnr
    AND   ( koart EQ 'D' OR koart EQ 'K' )
    AND   augbl IS NOT INITIAL
    INTO TABLE @DATA(lt_beleg).

  IF sy-subrc IS INITIAL AND lt_beleg IS NOT INITIAL.
    CLEAR: lt_beleg.
    MESSAGE e378(/thkr/fi_wf_bkpf).
  ENDIF.

  SELECT SINGLE bstat FROM bkpf
  INTO @DATA(ls_bkpf_vor)
  WHERE belnr = @gs_storno-belnr
    AND bukrs = @gs_storno-bukrs
    AND gjahr = @gs_storno-gjahr.
  IF sy-subrc = 0.

    IF ls_bkpf_vor = 'V'.

      MESSAGE 'Beleg ist erst vorerfasst. Keine Stornierung möglichh.'
      TYPE 'S' DISPLAY LIKE 'E'.
      gv_fehler = abap_true.
    ENDIF.

  ENDIF.

  SELECT SINGLE belnr bukrs gjahr FROM bkpf
  INTO CORRESPONDING FIELDS OF ls_storno_ext
  WHERE belnr = gs_storno-belnr
    AND bukrs = gs_storno-bukrs
    AND gjahr = gs_storno-gjahr.

  IF sy-subrc NE 0.
    gv_fehler = abap_true.
    MESSAGE w389(f5a) WITH gs_storno-belnr
                           gs_storno-bukrs
                           gs_storno-gjahr
                           DISPLAY LIKE 'E'.
  ELSE.
    MOVE-CORRESPONDING gs_storno TO ls_storno_ext.
    PERFORM authcheck_kopf USING ls_storno_ext-bukrs.

*   1. Sachkontenzeile für Authcheck lesen
    SELECT belnr gjahr buzei gsber augdt koart
           bukrs geber measure fistl fipos kunnr lifnr
      UP TO 1 ROWS
      FROM bseg
      INTO CORRESPONDING FIELDS OF ls_bseg
      WHERE bukrs = gs_storno-bukrs
        AND belnr = ls_storno_ext-belnr
        AND gjahr = ls_storno_ext-gjahr
        AND koart = 'S'
        AND kostl IS NOT NULL
     ORDER BY PRIMARY KEY.
    ENDSELECT.
    MOVE-CORRESPONDING ls_bseg TO ls_storno_ext.
    PERFORM authcheck_gsber USING ls_storno_ext-gsber.
    PERFORM authcheck_beleg USING ls_storno_ext.
    PERFORM authcheck_bupa.
    IF ls_bseg-augdt IS NOT INITIAL.
      MESSAGE e362(/thkr/fi_wf_bkpf).
* Keine Änderung möglich, Beleg ist ausgeglichen.
    ENDIF.

***   Prüfung auf Gültigkeit je Modus

    CASE gv_modus.
      WHEN 'FI'.
        IF sy-tcode = gc_tcode.               "001
          " VIM Belege
          SELECT SINGLE belnr bukrs gjahr FROM bkpf
            INTO CORRESPONDING FIELDS OF gs_storno
            WHERE belnr = gs_storno-belnr
              AND bukrs = gs_storno-bukrs
              AND gjahr = gs_storno-gjahr.
*              AND awtyp = 'AMBU'
*              AND (   blart = 'AA'
*                   OR blart = 'AX' ).
          IF sy-subrc NE 0.
            gv_fehler = abap_true.
*            MESSAGE w372(/THKR/FI_WF_BKPF) WITH 'AMBU' 'AA' 'AX' DISPLAY LIKE 'E'.
            MESSAGE 'Belegart darf nicht storniert werden.' TYPE 'S' DISPLAY LIKE 'E'.
            " PSM-Belege müssen Vorgang &1 und Belegart &2 oder &3 haben.
          ENDIF.
        ENDIF.
      WHEN 'FB'.
        IF gs_storno-bukrs = '0300' OR gs_storno-bukrs = '0900' OR
           gs_storno-bukrs = '1300'.
          " Lesen Refernzbeleg
          SELECT SINGLE belnr bukrs gjahr FROM bkpf
            INTO CORRESPONDING FIELDS OF gs_storno
            WHERE bukrs = gs_storno-bukrs
              AND belnr = gs_storno-belnr
              AND gjahr = gs_storno-gjahr
              AND awtyp = 'BKPFF'
              AND (   blart = 'KN'
                   OR blart = 'FR' ).
          IF sy-subrc NE 0.
            gv_fehler = abap_true.
            MESSAGE e374(/thkr/fi_wf_bkpf) WITH 'FI-Beleg aus FÖBIS'(002).
            " Kombination aus Referenzvorgang und Belegart ist für &1 nicht zugelassen.
          ENDIF.
          " Prüfung Eintrag in Tabelle GTRFIBILLREL
          SELECT SINGLE billdocno INTO @DATA(lv_billdocno) FROM gtrfibillrel
                                  WHERE bukrs = @gs_storno-bukrs
                                    AND belnr = @gs_storno-belnr
                                    AND gjahr = @gs_storno-gjahr.
          IF sy-subrc <> 0.
            gv_fehler = abap_true.
            MESSAGE e454(/thkr/fi_wf_bkpf).
            " Der Beleg hat keinen Eintrag in Relationship Tabelle für FÖBIS
          ENDIF.
        ELSE.
          gv_fehler = abap_true.
          MESSAGE e453(/thkr/fi_wf_bkpf) WITH gs_storno-bukrs.
          " Der Buchungskreis &1 ist nicht FÖBIS relevant
        ENDIF.
      WHEN 'AL'.
        SELECT SINGLE belnr bukrs gjahr FROM bkpf
          INTO CORRESPONDING FIELDS OF gs_storno
          WHERE belnr = gs_storno-belnr
            AND bukrs = gs_storno-bukrs
            AND gjahr = gs_storno-gjahr
            AND awtyp = 'RMRP'
            AND (   blart = 'KP'
                 OR blart = 'RM'
                 OR blart = 'RN' ).
        IF sy-subrc NE 0.
          gv_fehler = abap_true.
          MESSAGE w371(/thkr/fi_wf_bkpf) WITH 'RMRP' 'KP' 'RM' 'RN' DISPLAY LIKE 'E'.
* Anlagenbelege müssen Vorgang &1 und Belegart &2 oder &3 oder &4 haben.
        ENDIF.
      WHEN 'VI'.
        CALL METHOD /THKR/CL_FI_helper=>get_param
          EXPORTING
            iv_programm  = 'Z_TPBR_STORNO_WF'
            iv_fieldname = 'ZFI_BLART_VIM'
            iv_entrykey  = '00000001'
          IMPORTING
            et_range     = lr_tab
          EXCEPTIONS
            no_data      = 1
            OTHERS       = 2.
        IF sy-subrc NE 0.
          MESSAGE e375(/thkr/fi_wf_bkpf).
* Fehler bei der Ermittlung gültiger Belegarten aus der Parametertabelle.
        ENDIF.
        ASSIGN lr_tab->* TO <ft_blart_range>.
        SELECT SINGLE belnr bukrs gjahr FROM bkpf
          INTO CORRESPONDING FIELDS OF gs_storno
          WHERE belnr = gs_storno-belnr
            AND bukrs = gs_storno-bukrs
            AND gjahr = gs_storno-gjahr
            AND blart IN <ft_blart_range>.
        IF sy-subrc NE 0.
          gv_fehler = abap_true.
          MESSAGE e374(/thkr/fi_wf_bkpf) WITH 'FI-Beleg (VIM)'(001).
* Kombination aus Referenzvorgang und Belegart ist für &1 nicht zugelassen.
        ENDIF.
    ENDCASE.
  ENDIF.

  PERFORM check_storno.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form beleg_anzeigen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM beleg_anzeigen .

  CASE sy-dynnr.
    WHEN '0301'.
      PERFORM mm_anzeigen.
    WHEN '0302'.
      PERFORM sd_anzeigen.
    WHEN '0303'.
      PERFORM fi_anzeigen.
    WHEN '0304'.
      PERFORM fi_anzeigen.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mm_anzeigen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM mm_anzeigen .

  DATA: ls_storno LIKE gs_storno.

  IF   gs_storno-belnr IS INITIAL
    OR gs_storno-gjahr IS INITIAL.
    MESSAGE w363(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
* Bitte geben Sie die Belegnummer und das Geschäftsjahr an.
  ELSE.

    SELECT SINGLE belnr gjahr bukrs FROM rbkp
     INTO ls_storno
     WHERE belnr = gs_storno-belnr
       AND gjahr = gs_storno-gjahr.
    IF sy-subrc NE 0.
      MESSAGE w366(/thkr/fi_wf_bkpf) WITH gs_storno-belnr gs_storno-gjahr
                           DISPLAY LIKE 'E'.
* Es ist kein Beleg unter der Nummer &1 im Jahr &2 vorhanden.
    ELSE.

      SET PARAMETER ID 'BUK' FIELD gs_storno-bukrs.
      SET PARAMETER ID 'RBN' FIELD gs_storno-belnr.
      SET PARAMETER ID 'GJR' FIELD gs_storno-gjahr.

      CALL TRANSACTION 'MIR4' WITHOUT AUTHORITY-CHECK
                              AND SKIP FIRST SCREEN.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form sd_anzeigen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sd_anzeigen .

  DATA: ls_storno LIKE gs_storno.

  SELECT SINGLE vbeln AS belnr bukrs gjahr FROM vbrk
    INTO CORRESPONDING FIELDS OF ls_storno
    WHERE vbeln = gs_storno-belnr.

  IF sy-subrc NE 0.
    MESSAGE w368(/thkr/fi_wf_bkpf) WITH '&1' DISPLAY LIKE 'E'.
* Kein Fakturabeleg mit der Nummer &1 vorhanden.
  ELSE.
    SET PARAMETER ID 'BUK' FIELD ls_storno-bukrs.
    SET PARAMETER ID 'VF ' FIELD ls_storno-belnr.

    CALL TRANSACTION 'VF03' WITHOUT AUTHORITY-CHECK
                            AND SKIP FIRST SCREEN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fi_anzeigen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fi_anzeigen .


* Eingaben prüfen
  IF gs_storno-bukrs IS INITIAL
  OR gs_storno-gjahr IS INITIAL
  OR gs_storno-belnr IS INITIAL.
    MESSAGE w360(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
* Bitte geben Sie Belegnummer, Buchungskreis und Geschäftsjahr an.
  ENDIF.

  SELECT SINGLE belnr bukrs gjahr FROM bkpf
    INTO CORRESPONDING FIELDS OF gs_storno
    WHERE belnr = gs_storno-belnr
      AND bukrs = gs_storno-bukrs
      AND gjahr = gs_storno-gjahr.

  IF sy-subrc NE 0.
    MESSAGE w389(f5a) WITH gs_storno-belnr
                           gs_storno-bukrs
                           gs_storno-gjahr
                           DISPLAY LIKE 'E'.
  ELSE.

    SET PARAMETER ID 'BUK' FIELD gs_storno-bukrs.
    SET PARAMETER ID 'BLN' FIELD gs_storno-belnr.
    SET PARAMETER ID 'GJR' FIELD gs_storno-gjahr.

    CALL TRANSACTION 'FB03' WITH AUTHORITY-CHECK
                     AND SKIP FIRST SCREEN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Authcheck_beleg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_STORNO
*&---------------------------------------------------------------------*
FORM authcheck_beleg  USING    ps_storno TYPE gty_s_storno.

  DATA: lv_subrc          TYPE subrc,
        lv_auth_grp_fistl TYPE fm_authgrc,
        lv_auth_grp_hhp   TYPE fm_authgr_measure,
        lv_auth_grp_fond  TYPE fm_authgrf,
        lv_auth_grp_fipos TYPE fm_authgrp,
        lv_fipex          TYPE fm_fipex.

  CONSTANTS: lc_act TYPE fm_authact VALUE '06'.

  SELECT SINGLE augrp FROM fmfctr
           INTO lv_auth_grp_fistl
          WHERE fikrs EQ ps_storno-fikrs
            AND fictr EQ ps_storno-fistl.

  SELECT SINGLE augrp FROM fmci
           INTO lv_auth_grp_fipos
          WHERE fikrs EQ ps_storno-fikrs
            AND fipos EQ ps_storno-fipos.

  SELECT SINGLE augrp FROM fmfincode
           INTO lv_auth_grp_fond
          WHERE fincode EQ ps_storno-geber
            AND fikrs   EQ ps_storno-fikrs.

  SELECT SINGLE authgrp FROM fmmeasure
           INTO lv_auth_grp_hhp
          WHERE measure EQ ps_storno-measure
            AND fmarea  EQ ps_storno-fikrs.

  DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).
  CASE lv_object_fica.
    WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

      CLEAR lv_fipex.
      SELECT SINGLE fipex FROM fmfxpo
              INTO lv_fipex
              WHERE fipos = ps_storno-fipos.
      IF lv_fipex IS INITIAL.
        lv_fipex = ps_storno-fipos.
      ENDIF.
      CALL FUNCTION '/THKR/CHECK_FICA_UTK'
        EXPORTING
          activity           = lc_act
          fm_area            = ps_storno-fikrs
          fm_fincode_authgrp = lv_auth_grp_fond
          fm_fmfctr_authgrp  = lv_auth_grp_fistl
          fm_fipex           = lv_fipex
          fm_measure_authgrp = lv_auth_grp_hhp
*         FM_FAREA_AUTHGRP   =
        IMPORTING
          ex_subrc           = lv_subrc.

      IF lv_subrc <> 0.
        MESSAGE ID '/THKR/FI_WF_BKPF' TYPE 'E' NUMBER '201'.
      ENDIF.

    WHEN OTHERS.

      CALL FUNCTION 'Z_CHECK_FICA_TRG'
        EXPORTING
          activity           = lc_act
          fm_area            = ps_storno-fikrs
          fm_fincode_authgrp = lv_auth_grp_fond
          fm_fmfctr_authgrp  = lv_auth_grp_fistl
          fm_fipex_authgrp   = lv_auth_grp_fipos
          fm_measure_authgrp = lv_auth_grp_hhp
*         FM_FAREA_AUTHGRP   =
        IMPORTING
          ex_subrc           = lv_subrc.

      IF lv_subrc <> 0.
        MESSAGE ID '/THKR/FI_WF_BKPF' TYPE 'E' NUMBER '200'.
      ENDIF.

  ENDCASE.








ENDFORM.
*&---------------------------------------------------------------------*
*& Form authcheck_kopf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_STORNO_EXT_BUKRS
*&---------------------------------------------------------------------*
FORM authcheck_kopf  USING    pv_bukrs TYPE bukrs.

* Prüfung auf Änderungsberechtigung im Buchungskreis
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
  ID 'BUKRS' FIELD pv_bukrs
  ID 'ACTVT' FIELD '06'.
  IF sy-subrc <> 0.
    MESSAGE e133(/thkr/fi_wf_bkpf).
* Keine Berechtigung zur Bearbeitung vorhanden.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form authcheck_gsber
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_STORNO_EXT_GSBER
*&---------------------------------------------------------------------*
FORM authcheck_gsber  USING  pv_gsber TYPE gsber.

* Prüfung auf Änderungsberechtigung im Geschäftsbereich
  AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
  ID 'GSBER' FIELD pv_gsber
  ID 'ACTVT' FIELD '06'.
  IF sy-subrc <> 0.
    MESSAGE e133(/thkr/fi_wf_bkpf).
* Keine Berechtigung zur Bearbeitung vorhanden.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_storno_sd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_storno_sd .

  DATA: lv_lfdnr TYPE lfdnr.

* Prüfen, ob der Beleg für Stornierung vorgesehen ist
  SELECT SINGLE lfdnr FROM /thkr/stornoc
                      INTO lv_lfdnr
                     WHERE bukrs = gs_storno-bukrs
                       AND modul = gs_storno-modul
                       AND belnr = gs_storno-belnr
                       AND ( status NE '40' AND status NE '45' ). "Abgelehnt und Abbruch durch SA

  IF sy-subrc = 0.
    gv_fehler = abap_true.
    MESSAGE w356(/thkr/fi_wf_bkpf)
       WITH gs_storno-belnr gs_storno-bukrs '' lv_lfdnr
       DISPLAY LIKE 'E'.
* Der Beleg &1/&2/&3 ist unter der Nummer &4 zum Storno vorgesehen.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form vertrag_anzeigen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM vertrag_anzeigen .

  " Eingaben prüfen
  IF gs_storno-bukrs IS INITIAL
  OR gs_storno-recnnr IS INITIAL.
    MESSAGE w386(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
    " Bitte geben sie Buchungskreis und Vertragsnummer an.
  ENDIF.

  " Prüfen Vertrag
  SELECT SINGLE bukrs recnnr INTO CORRESPONDING FIELDS OF gs_storno
                             FROM vicncn
                             WHERE bukrs = gs_storno-bukrs
                               AND recnnr = gs_storno-recnnr.
  IF sy-subrc NE 0.

    MESSAGE w061(recaap) WITH gs_storno-bukrs gs_storno-recnnr
                         DISPLAY LIKE 'E'.
  ELSE.

    " Aufruf RECN zur Anzeige Vertrag
    SET PARAMETER ID 'BUK' FIELD gs_storno-bukrs.
    SET PARAMETER ID 'RECNNR' FIELD gs_storno-recnnr.

    CALL TRANSACTION 'RECN' WITH AUTHORITY-CHECK
                            AND SKIP FIRST SCREEN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form referenzen_sichern
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM referenzen_sichern .

*  DATA: lt_referenz TYPE STANDARD TABLE OF gty_s_referenz.
*
*  " Speichern der Referenzen wenn gefüllt
*  IF gt_referenz IS NOT INITIAL.
*
*    " Referenznummern mit Vornullen auffüllen
*    LOOP AT gt_referenz ASSIGNING FIELD-SYMBOL(<ls_referenz>).
*      DO.
*        IF <ls_referenz>-refnr+19(1) = space.
*          SHIFT <ls_referenz>-refnr RIGHT.
*          <ls_referenz>-refnr(1) = 0.
*        ELSE.
*          EXIT.
*        ENDIF.
*      ENDDO.
*      " Prüfung ob der Eintrag schon vorhanden ist
*      READ TABLE gt_refnr TRANSPORTING NO FIELDS WITH KEY refnr = <ls_referenz>-refnr.
*      IF sy-subrc <> 0.
*        READ TABLE lt_referenz TRANSPORTING NO FIELDS WITH KEY refnr = <ls_referenz>-refnr.
*        IF sy-subrc <> 0.
*          APPEND <ls_referenz> TO lt_referenz.
*        ENDIF.
*        DATA(gv_fuellen) = abap_true.
*      ENDIF.
*    ENDLOOP.
*
*    IF gv_fuellen = abap_true.
*
*      " Ermitteln der Belegnummern zu den Referenzen
*      SELECT h~bukrs, h~belnr, h~gjahr, h~awkey, p~zuonr, p~dmbtr INTO TABLE @DATA(lt_belege)
*                                                                  FROM bkpf AS h
*                                                                  INNER JOIN bseg AS p
*                                                                  ON p~gjahr = h~gjahr
*                                                                  AND p~belnr = h~belnr
*                                                                  AND p~bukrs = h~bukrs
*                                                                  FOR ALL ENTRIES IN @lt_referenz
*                                                                  WHERE h~awtyp = 'REACI'
*                                                                    AND h~awkey = @lt_referenz-refnr.
*      IF sy-subrc = 0.
*
*        " Ermitteln Betrag des Beleges
*        SELECT bukrs, belnr, gjahr, buzei, dmbtr INTO TABLE @DATA(lt_betrag) FROM bseg
*                                                 FOR ALL ENTRIES IN @lt_belege
*                                                 WHERE bukrs = @lt_belege-bukrs
*                                                   AND belnr = @lt_belege-belnr
*                                                   AND gjahr = @lt_belege-gjahr
*                                                   AND ( koart = 'K' OR koart = 'D' ).
*        IF sy-subrc = 0.
*          " Ermittlung Gesamtbetrag des Beleges für Bearbeiterfindung
*          LOOP AT lt_belege ASSIGNING FIELD-SYMBOL(<ls_belege>).
*            CLEAR <ls_belege>-dmbtr.
*            LOOP AT lt_betrag ASSIGNING FIELD-SYMBOL(<ls_betrag>).
*              ADD <ls_betrag>-dmbtr TO <ls_belege>-dmbtr.
*            ENDLOOP.
*          ENDLOOP.
*        ENDIF.
*
*        SORT lt_belege BY zuonr awkey.
*        LOOP AT lt_referenz ASSIGNING <ls_referenz>.
*          " Lesen Belegschlüssel zur Referenz
*          READ TABLE lt_belege ASSIGNING <ls_belege>
*                               WITH KEY zuonr = gs_storno-recnnr
*                                        awkey = <ls_referenz>-refnr
*                               BINARY SEARCH.
*          IF sy-subrc = 0.
*            " Neuer Eintrag
*            APPEND INITIAL LINE TO gt_refnr ASSIGNING FIELD-SYMBOL(<ls_refnr>).
*            <ls_refnr>-bukrs = gs_storno-bukrs.
*            <ls_refnr>-recnnr = gs_storno-recnnr.
*            <ls_refnr>-lfdnr = gs_storno-lfdnr.
*            <ls_refnr>-belnr = <ls_belege>-belnr.
*            <ls_refnr>-gjahr = <ls_belege>-gjahr.
*            <ls_refnr>-refnr = <ls_referenz>-refnr.
*            <ls_refnr>-dmbtr = <ls_belege>-dmbtr.
*          ELSE.
*            "Referenznummern ohne Belegzuordnung oder falschem Vertrag
*            gv_referr = abap_true.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_storno_refx
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_storno_refx .

*  DATA: lv_lfdnr TYPE lfdnr.
*
*
** Prüfen, ob der Beleg für Stornierung vorgesehen ist
*  SELECT SINGLE lfdnr FROM zfi_storno
*                      INTO lv_lfdnr
*                      WHERE bukrs = gs_storno-bukrs
*                        AND modul = gs_storno-modulv
*                        AND recnnr = gs_storno-recnnr
*                        AND ( status NE '40' AND status NE '45' ). "Abgelehnt und Abbruch durch SA
*
*  IF sy-subrc = 0.
*    gv_fehler = abap_true.
*    MESSAGE w388(/THKR/FI_WF_BKPF)
*       WITH gs_storno-bukrs gs_storno-recnnr '' lv_lfdnr
*       DISPLAY LIKE 'E'.
** Der Vertrag &1/&2/&3 ist unter der Nummer &4 zum Storno vorgesehen.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refxbelege_lesen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refxbelege_lesen .

*  DATA: ls_storno_ext TYPE gty_s_storno.
*
*  DATA: ls_bseg TYPE bseg.
*
*  DATA: lr_tab TYPE REF TO data.
*
*  FIELD-SYMBOLS: <ft_blart_range> TYPE /THKR/T_FI_blart.
*
*  gs_storno-stgrd = uf05a-stgrd.
*  gs_storno-modul = 'RE'.
*
** Eingaben prüfen
*  IF gs_storno-bukrs IS INITIAL
*  OR gs_storno-recnnr IS INITIAL.
*    gv_fehler = abap_true.
*    MESSAGE w386(/THKR/FI_WF_BKPF) DISPLAY LIKE 'E'.
** Bitte geben Sie Vertragsnummer und den Buchungskreis an.
*  ENDIF.
*
** Vertragsnummer mit Vornullen auffüllen
*  DO.
*    IF gs_storno-recnnr+12(1) = space.
*      SHIFT gs_storno-recnnr RIGHT.
*      gs_storno-recnnr(1) = 0.
*    ELSE.
*      EXIT.
*    ENDIF.
*  ENDDO.
*
**  " Löschen vorhandener Einträge in der ZFI_REFX_REFNR
**  DELETE FROM zfi_refx_refnr WHERE bukrs = gs_storno-bukrs
**                             AND recnnr = gs_storno-recnnr
**                             AND lfdnr = gs_storno-lfdnr.
**  IF sy-subrc = 0.
**    COMMIT WORK AND WAIT.
**  ENDIF.
*
*
** Referenznummer vom Selscreen an Tabelle übergeben
*  READ TABLE gt_referenz TRANSPORTING NO FIELDS WITH KEY refnr = gs_refnr-refnr.
*  IF sy-subrc <> 0.
*    APPEND gs_refnr-refnr TO gt_referenz.
*  ENDIF.
*  SORT gt_referenz.
*
*  " Prüfung der eingegeben Referenzen auf doppelte Einträge
*  PERFORM check_refernzen_unique.
*
*  " Aufbereitung für das Sichern der Referenzen in der DB
*  PERFORM referenzen_sichern.
*
** Prüfung, ob ein Beleg bereits ausgeglichen ist
*  SELECT augbl FROM bseg
*               FOR ALL ENTRIES IN @gt_refnr
*               WHERE bukrs EQ @gt_refnr-bukrs
*                 AND belnr EQ @gt_refnr-belnr
*                 AND gjahr EQ @gt_refnr-gjahr
*                 AND ( koart EQ 'D' OR koart EQ 'K' )
*                 AND augbl IS NOT INITIAL
*               INTO TABLE @DATA(lt_ausbel) .
*  IF sy-subrc IS INITIAL AND lt_ausbel IS NOT INITIAL.
*    CLEAR: lt_ausbel.
*    MESSAGE s389(/THKR/FI_WF_BKPF).
*  ENDIF.
*
*  SELECT SINGLE bukrs, recnnr INTO CORRESPONDING FIELDS OF @ls_storno_ext
*                              FROM vicncn
*                              WHERE bukrs  = @gs_storno-bukrs
*                                AND recnnr = @gs_storno-recnnr.
*  IF sy-subrc NE 0.
*    gv_fehler = abap_true.
*    MESSAGE w061(recaap) WITH gs_storno-bukrs gs_storno-recnnr
*                         DISPLAY LIKE 'E'.
*  ELSE.
*
*    MOVE-CORRESPONDING gs_storno TO ls_storno_ext.
*    PERFORM authcheck_kopf USING ls_storno_ext-bukrs.
*
*  ENDIF.
*
**  " Prüfung des Eintrages in der ZFI_STORNO           " Referenznummer sind das entscheidende !!!!!!!!!!!
**  PERFORM check_storno_refx.                          " Kriterium nicht der Vertrag !!!!!!!!!!!

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_refernzen_unique
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_refernzen_unique .

*  " Prüfen der eingegebenen Referenznummern gegen die DB
*  SELECT bukrs, recnnr, lfdnr, refnr INTO TABLE @DATA(lt_refnr_db)
*                                     FROM zfi_refx_refnr
*                                     FOR ALL ENTRIES IN @gt_referenz
*                                     WHERE refnr = @gt_referenz-refnr.
*  IF sy-subrc = 0.
*    gv_fehler = abap_true.
*    " Lesen erster Satz
*    READ TABLE lt_refnr_db ASSIGNING FIELD-SYMBOL(<ls_refnr_db>) INDEX 1.
*    IF sy-subrc = 0.
*      MESSAGE w399(/THKR/FI_WF_BKPF)
*         WITH <ls_refnr_db>-bukrs <ls_refnr_db>-recnnr <ls_refnr_db>-lfdnr <ls_refnr_db>-refnr
*         DISPLAY LIKE 'E'.
*      " Doppelte Beantragung von Referenzen im Vertrag &1 &2 &3 &4
*    ENDIF.
*  ELSE.
*    gv_fehler = abap_false.
*  ENDIF.

ENDFORM.
*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE l_ok.
    WHEN 'INSR'.                      "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE'.                      "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR 1 l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
  IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
    l_tc_new_top_line = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines
"Prüfung, ob auf Geschäftspartner berechtigt
FORM authcheck_bupa.

  SELECT SINGLE kunnr, lifnr FROM bseg
    WHERE belnr = @gs_storno-belnr
    AND bukrs = @gs_storno-bukrs
    AND gjahr = @gs_storno-gjahr
    AND ( koart = 'D' OR koart = 'K' )
    AND ( kunnr IS NOT INITIAL OR lifnr IS NOT INITIAL )
     INTO @DATA(ls_bupa).

  IF ls_bupa-kunnr IS NOT INITIAL.
    DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                            iv_partner = ls_bupa-kunnr
                            iv_type = 'D'  ).
    IF no_auth_l EQ abap_true.

      MESSAGE e010(/thkr/bp)  WITH ls_bupa-kunnr.

    ENDIF.
  ELSEIF ls_bupa-lifnr IS NOT INITIAL.
    no_auth_l = /thkr/cl_auth_check=>check_bupa_auth(
                             iv_partner = ls_bupa-lifnr
                             iv_type = 'K'  ).
    IF no_auth_l EQ abap_true.

      MESSAGE e010(/thkr/bp) WITH ls_bupa-lifnr.

    ENDIF.

  ENDIF.

ENDFORM.
