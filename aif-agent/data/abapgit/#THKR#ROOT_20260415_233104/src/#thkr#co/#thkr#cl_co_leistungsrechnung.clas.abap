class /THKR/CL_CO_LEISTUNGSRECHNUNG definition
  public
  final
  create public .

public section.

  constants CO_KOKRS type KOKRS value 1000 ##NO_TEXT.
  class-data GV_MAPPENNAME type APQ_GRPN .
  class-data GV_CHECK_LV type CHAR1 .
  class-data GV_AK_LGEO type /THKR/CO_AK_ANTEIL .
  class-data GV_AK_JUS type /THKR/CO_AK_ANTEIL .
  class-data GT_LART type /THKR/T_CO_LEIST_L .

  class-methods DATEI_EINLESEN
    importing
      value(I_DATEINAME) type STRING
    exporting
      value(E_RECIN) type /THKR/T_CO_LEIST_INPUT
      value(E_DATEI) type STRING
      value(E_RC) type CHAR1 .
  class-methods CHECK_USER
    importing
      value(I_DIENSTSTELLE) type CHAR4
    exporting
      value(E_RC) type CHAR1 .
  class-methods BELEGE_BUCHEN
    importing
      value(I_DIENSTSTELLE) type CHAR4
    exporting
      value(E_RC) type CHAR1
    changing
      value(C_RECIN) type /THKR/T_CO_LEIST_INPUT .
  class-methods CHECK_DATEN
    importing
      value(I_DIENSTSTELLE) type CHAR4
    exporting
      value(E_RC) type CHAR1
    changing
      value(C_RECIN) type /THKR/T_CO_LEIST_INPUT .
  class-methods SCHREIBEN_PROTOKOLL
    importing
      value(I_DATEINAME) type STRING optional .
protected section.
private section.

  class-data GT_BDCDATA type CK_T_BDCDATA .
  class-data GV_DATEI type STRING .

  class-methods CHECK_DATEN_ALLGEMEIN
    importing
      value(I_DIENSTSTELLE) type CHAR4
      value(I_HERKUNFT) type CHAR1
    exporting
      value(E_RC) type CHAR1
    changing
      value(C_RECIN) type /THKR/T_CO_LEIST_INPUT .
  class-methods BDC_DYNPRO
    importing
      value(E_PROGRAM) type BDCDATA-PROGRAM
      value(E_DYNPRO) type BDCDATA-DYNPRO .
  class-methods BDC_FIELD
    importing
      value(E_FNAM) type C
      value(E_FVAL) type ANY .
ENDCLASS.



CLASS /THKR/CL_CO_LEISTUNGSRECHNUNG IMPLEMENTATION.


  method BDC_DYNPRO.

* ...
  data: l_bdcdata type bdcdata.

  clear l_bdcdata.
  l_bdcdata-program  = e_program.
  l_bdcdata-dynpro   = e_dynpro.
  l_bdcdata-dynbegin = 'X'.
  append l_bdcdata to gt_bdcdata.

  endmethod.


  METHOD bdc_field.

    DATA: l_bdcdata TYPE bdcdata.

    CLEAR l_bdcdata.
    l_bdcdata-fnam = e_fnam.
    l_bdcdata-fval = e_fval.
    APPEND l_bdcdata TO gt_bdcdata.

  ENDMETHOD.


  METHOD belege_buchen.

    TYPES: BEGIN OF ty_beleg,
             status(1)       TYPE c,
             belnr           TYPE co_belnr,
             dienststelle(4) TYPE    c,
             ma_nummer(4)    TYPE    c,
             besold_gr(6)    TYPE    c,
             meng1(6)        TYPE    c,
             kostl(10)       TYPE    c,
             iauftr(12)      TYPE    c.
    TYPES: END OF ty_beleg.

    DATA: gs_recin     TYPE /thkr/co_leist_input,
          lv_ekz(1)    TYPE n,
          lv_summe     TYPE p DECIMALS 3,
          lv_menge1    TYPE p DECIMALS 3,
          lv_wert(6)   TYPE c,
          lv_besold(3) TYPE c,
          lv_iauftr    TYPE aufnr,
          lv_kostl     TYPE kostl,
          lt_leist     TYPE TABLE OF /thkr/co_leist,
          ls_leist     TYPE /thkr/co_leist,
          lv_ak_anteil TYPE /thkr/co_ak_anteil,
          lv_faktor    TYPE /thkr/co_ak_anteil,
          lt_lart      TYPE TABLE OF /thkr/co_leist_l,
          ls_lart      TYPE /thkr/co_leist_l,
          lt_beleg     TYPE TABLE OF ty_beleg,
          ls_beleg     TYPE ty_beleg,
          lv_text(50)  type c.

    DATA: lv_cnt      TYPE i,
          lv_menge2   TYPE p DECIMALS 3,
          lv_kz       TYPE i,
          lv_leinh(3) TYPE c.

    DATA: gv_besoldgr(8) TYPE c,
          gv_postxt(30)  TYPE c VALUE 'Leistungsverrechnung',
          gv_menge3(12)  TYPE c,
          gv_bltxt       TYPE co_bltxt,
          gv_tbtxt(12)   TYPE c,
          gs_leist       TYPE /thkr/co_leist,
          gv_bemot       TYPE bemot,
          gv_first_map   TYPE i VALUE 0,
          gv_datum(8)    TYPE c,
          gv_bldat       TYPE d,
          gv_skostl(10)  TYPE c,
          gv_herkft(1)   TYPE c.

    DATA: lt_return TYPE TABLE OF bdcmsgcoll,
          ls_return TYPE bdcmsgcoll.

*art_cust:
*01	max. Arbeitskraftanteil (Justiz) pro Mitarbeiter
*02	max. Arbeitskraftanteil (LvermGeo) pro Mitarbeiter
*03	Umrechnungsfaktor (Justiz)
*04	Umrechnungsfaktor (LvermGeo)
*05	Prüfung für LvermGeo einschalten (X)
*06	Berechnungsmotiv

    SELECT * FROM /thkr/co_leist INTO TABLE lt_leist
      WHERE art_cust = '01' OR art_cust = '02' OR art_cust = '03' OR art_cust = '04'.

* 1. Transaktionsruf ( Leistungsart aus Besoldungsgruppe)
    LOOP AT c_recin INTO gs_recin.

      CLEAR:     ls_beleg, lt_beleg.

* feststellen, woher der Datensatz ist:
*    - Justiz, wenn gs_recin-MA_NUMMER gefüllt,
*    - LvermGeo, wenn gs_recin-LG_MA_NUMMER gefüllt
      gv_herkft = 'J'.
      IF NOT gs_recin-lg_ma_nummer IS INITIAL OR gs_recin-lg_ma_nummer <> '     '.
        gv_herkft = 'L'.
      ENDIF.

* Faktor ermitteln:
*    - Justiz, dann den Betrag aus Feld WERT, wenn /THKR/CO_LEIST-ART_CUST = '03'
*    - LvermGeo, dann den Betrag aus Feld WERT, wenn /THKR/CO_LEIST-ART_CUST = '04'
      IF gv_herkft = 'J'.
        READ TABLE lt_leist WITH KEY art_cust = '03' INTO ls_leist.
      ENDIF.
      IF gv_herkft = 'L'.
        READ TABLE lt_leist WITH KEY art_cust = '04' INTO ls_leist.
      ENDIF.
      lv_faktor = ls_leist-wert.

      gv_besoldgr = space.
      gv_besoldgr = gs_recin-besold_gr.

      gv_postxt+22 = '      '.
      gv_postxt+22 = gv_besoldgr.

      lv_wert = gs_recin-meng1.
      IF lv_wert CS ','.
        REPLACE ALL OCCURRENCES OF '.' IN lv_wert WITH ''.
        REPLACE ALL OCCURRENCES OF ',' IN lv_wert WITH '.'.
      ENDIF.
      lv_menge1 = lv_wert.

*      lv_menge1 = gs_recin-meng1.
*      lv_menge2 = ( 251 * 8 ) / 12.
*      lv_menge2 = lv_menge2 * lv_menge1.
      lv_menge2 = lv_menge1 * lv_faktor.
      gv_menge3 = lv_menge2.
      REPLACE '.' WITH ',' INTO gv_menge3.

* ermitteln der Leistungseinheit der Leistungsart
      lv_leinh = 'STD'.
      SELECT SINGLE leinh FROM csla INTO lv_leinh
        WHERE lstar = gv_besoldgr.

* Check ob abordnende Dienststelle.
      IF gs_recin-abord IS INITIAL OR gs_recin-abord = gs_recin-dienststelle.
        gv_bltxt = 'Leistungsverrechnung'.
      ELSE.
        CONCATENATE 'Abordnung von' gs_recin-abord INTO gv_bltxt SEPARATED BY space.
      ENDIF.

* Bestimme Berechnungsmotiv
      CLEAR: gs_leist, gv_bemot.
      IF NOT gs_recin-abord IS INITIAL.
        SELECT SINGLE * FROM /thkr/co_leist INTO gs_leist
          WHERE art_cust = '06' AND
                gsber    = gs_recin-abord.
        IF sy-subrc NE 0.
          gv_bemot = '03'.           " kein berechnungsmotiv gefunden --> 03
        ELSE.
          gv_bemot = gs_leist-bemot. " aus Tabelle übernehmen
        ENDIF.
      ENDIF.


      lv_cnt = 0.  lv_kz = 1.
      DO.
        IF gv_datei+lv_cnt(1) EQ ' '.
          lv_kz = 1.
          EXIT.
        ENDIF.
        IF gv_datei+lv_cnt(5) CP 'leist'.
          lv_kz = 0.
          EXIT.
        ENDIF.
        lv_cnt = lv_cnt + 1.
      ENDDO.
      lv_cnt = lv_cnt + 5.
      gv_datum+4(4) = gv_datei+lv_cnt(4).
      lv_cnt = lv_cnt + 4.
      gv_datum+2(2) = gv_datei+lv_cnt(2).
      gv_datum(2) = '01'.

      WRITE sy-datum TO gv_bldat.

      gv_skostl = space.
      CONCATENATE i_dienststelle '090001' INTO gv_skostl.

      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_dynpro
        EXPORTING
          e_program = 'SAPLSPO4'
          e_dynpro  = '0300'.

      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'BDC_CURSOR'
          e_fval = 'SVALD-VALUE(01)'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'BDC_OKCODE'
          e_fval = '=FURT'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'SVALD-VALUE(01)'
          e_fval = /thkr/cl_co_leistungsrechnung=>co_kokrs.   "'1200'.

      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_dynpro
        EXPORTING
          e_program = 'SAPLK23F1'
          e_dynpro  = '1200'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'BDC_OKCODE'
          e_fval = '/00'.

      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'COHEADER-SEND_REC_REL'
          e_fval = '10SAP'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-STATUS'
          e_fval = 'S'.

      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_dynpro
        EXPORTING
          e_program = 'SAPLK23F1'
          e_dynpro  = '1200'.

      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'BDC_OKCODE'
          e_fval = 'POST'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'COHEADER-SEND_REC_REL'
          e_fval = '10SAP'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-STATUS'
          e_fval = 'S'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'COHEADER-BLDAT'
          e_fval = gv_bldat.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'COHEADER-BUDAT'
          e_fval = gv_datum.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'COHEADER-BLTXT'
          e_fval = gv_bltxt.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-MBGBTR'
          e_fval = gv_menge3.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-MEINB'
          e_fval = lv_leinh.         "'STD'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-WAERS'
          e_fval = 'EUR'.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-SGTXT'
          e_fval = gv_tbtxt.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-SKOSTL'
          e_fval = gv_skostl.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-SLSTAR'
          e_fval = gv_besoldgr.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-EKOSTL'
          e_fval = gs_recin-kostl.
      IF NOT gs_recin-iauftr IS INITIAL.
        CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
          EXPORTING
            e_fnam = 'RK23F-EAUFNR'
            e_fval = gs_recin-iauftr.
      ENDIF.
*  IF NOT recin-pauftr IS INITIAL.
*    PERFORM bdc_field       USING 'RK23F-Eprznr'
*                                  recin-pauftr.
*  ENDIF.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>bdc_field
        EXPORTING
          e_fnam = 'RK23F-EBEMOT'
          e_fval = gv_bemot.

      CALL TRANSACTION 'KB21N'
              USING       gt_bdcdata
             MODE        'N'
             UPDATE      'S'
             MESSAGES INTO lt_return.
      IF sy-subrc NE 0.
        IF gv_first_map EQ 0.

*          PERFORM open_group.
          CALL FUNCTION 'BDC_OPEN_GROUP'
            EXPORTING
              client = sy-mandt
              group  = /thkr/cl_co_leistungsrechnung=>gv_mappenname
              user   = sy-uname
              keep   = ' '.
          gv_first_map = 1.
        ENDIF.
*        PERFORM bdc_transaction USING 'KB21N'.
        CALL FUNCTION 'BDC_INSERT'
          EXPORTING
            tcode     = 'KB21N'
          TABLES
            dynprotab = gt_bdcdata.

        ls_beleg-status = 'F'.
        MOVE-CORRESPONDING gs_recin TO ls_beleg.
        APPEND ls_beleg TO lt_beleg.

      ELSE.
*        MSGID = 'BK', MSGNR = '003', MSGV1 = Belegnummer
*        'Beleg wird unter der Nummer & gebucht'
        LOOP AT lt_return INTO ls_return
           WHERE msgid = 'BK' AND
                 msgnr = '003'.

          ls_beleg-status = 'B'.
          ls_beleg-belnr = ls_return-msgv1(10).
          MOVE-CORRESPONDING gs_recin TO ls_beleg.
          APPEND ls_beleg TO lt_beleg.

        ENDLOOP.
      ENDIF.

      CLEAR:    gt_bdcdata, lt_return.
      REFRESH:  gt_bdcdata, lt_return.


    ENDLOOP.

    IF gv_first_map NE 0.
*      PERFORM close_group.
      CALL FUNCTION 'BDC_CLOSE_GROUP'.
      uline.
      SKIP 1.
      concatenate 'Es wurde die Fehlermappe' /thkr/cl_co_leistungsrechnung=>gv_mappenname 'erstellt.' into lv_text SEPARATED BY space.
      WRITE: / lv_text COLOR 6.
      WRITE: / '   -> bitte führen Sie die TA /nSM35 aus'.
      WRITE: / '   -> wählen Sie die o.g. Mappe aus'.
      WRITE: / '   -> wählen Sie >>Abspielen<< aus'.
      WRITE: / '   -> wählen Sie >>Nur Fehler anzeigen<< aus'.
      WRITE: / '   -> Korrigieren Sie, den als Fehler angezeigten Wert'.
      SKIP 1.
      uline.
      SKIP 1.
      WRITE: / 'Die Buchung von Belegen zu folgenden Datensätzen war fehlerhaft (siehe Fehlermappe)'.
      WRITE: /.
      WRITE: / 'DST  MAnr Besold Menge  Kostenst.  Auftrag'.

      LOOP AT lt_beleg INTO ls_beleg
        WHERE status = 'F'.

        WRITE: / ls_beleg-dienststelle, ls_beleg-ma_nummer, ls_beleg-besold_gr,
                 ls_beleg-meng1, ls_beleg-kostl, ls_beleg-iauftr.
      ENDLOOP.

    ENDIF.

    READ TABLE lt_beleg INTO ls_beleg WITH KEY status = 'B'.

    IF sy-subrc = 0.
      uline.
      SKIP 1.
      WRITE: / 'Die Buchung von Belegen zu folgenden Datensätzen war erfolgreich'.
      WRITE: /.
      WRITE: / 'CO-Belegnr DST  MAnr Besold Menge  Kostenst.  Auftrag'.

      LOOP AT lt_beleg INTO ls_beleg
        WHERE status = 'B'.
        WRITE: / ls_beleg-belnr COLOR 5,
                 ls_beleg-dienststelle, ls_beleg-ma_nummer, ls_beleg-besold_gr,
                 ls_beleg-meng1, ls_beleg-kostl, ls_beleg-iauftr.
      ENDLOOP.
      SKIP 1.
      uline.

    ENDIF.

  ENDMETHOD.


  METHOD check_daten.

    DATA: lt_recin_jus TYPE table of /thkr/co_leist_input,
          lt_recin_lv  TYPE table of /thkr/co_leist_input,
          ls_recin     TYPE /thkr/co_leist_input,
          lv_ekz(1)    TYPE n,
          lv_summe     TYPE p DECIMALS 3,
          lv_menge1    TYPE p DECIMALS 3,
          lv_besold(3) TYPE c,
          lv_iauftr    TYPE aufnr,
          lv_kostl     TYPE kostl,
          lv_ak_anteil TYPE /thkr/co_ak_anteil,
          ls_lart      TYPE /thkr/co_leist_l.

*art_cust:
*01	max. Arbeitskraftanteil (Justiz) pro Mitarbeiter
*02	max. Arbeitskraftanteil (LvermGeo) pro Mitarbeiter
*03	Umrechnungsfaktor (Justiz)
*04	Umrechnungsfaktor (LvermGeo)
*05	Prüfung für LvermGeo einschalten (X)
*06	Berechnungsmotiv


*    DELETE c_recin INDEX 1.              "Überschrift löschen

    SELECT SINGLE wert FROM /thkr/co_leist INTO gv_ak_jus
      WHERE art_cust = '01'.
    IF sy-subrc <> 0 OR gv_ak_jus = 0.
      WRITE: / 'Bitte pflegen Sie den max. Arbeitskraftanteil (Justiz) pro Mitarbeiter.' COLOR 3.
      WRITE: / 'in der Tabelle /THKR/CO_LEIST (Art = 01)'  COLOR 3.
      e_rc = 8.
      lv_ekz = 1.
      EXIT.
    ENDIF.

    SELECT SINGLE wert FROM /thkr/co_leist INTO gv_ak_lgeo
      WHERE art_cust = '02'.

    SELECT * FROM /thkr/co_leist_l INTO TABLE gt_lart.
    IF lines( gt_lart ) = 0.
      WRITE: / 'Keine Prüfung der Leistungsart gegen die 1.Stelle Mitarbeiternummer möglich.' COLOR 3.
      WRITE: / 'Bitte pflegen Sie die Tabelle /THKR/CO_LEIST_L'  COLOR 3.
      e_rc = 8.
      lv_ekz = 1.
      EXIT.
    ENDIF.

*   Lesen der Einstellungen (Schalter) für die Prüfungen für LvermGeo
    SELECT SINGLE schalter_lv FROM /thkr/co_leist INTO gv_check_lv
      WHERE art_cust = '05'.

    lv_summe = 0.

*   Ermitteln der Art Datensätze und Aufteilung für die spätere Prüfung in check_daten_allgemein
*   für LvermGeo die Mitarbeiternummer für die Prüfung in das Feld ma_nummer schreiben
    LOOP AT c_recin INTO ls_recin.

      IF NOT ls_recin-ma_nummer IS INITIAL.
        APPEND ls_recin TO lt_recin_jus.
      ELSEIF not ls_recin-lg_ma_nummer IS INITIAL.
        ls_recin-ma_nummer = ls_recin-lg_ma_nummer.
        APPEND ls_recin TO lt_recin_lv.
      ENDIF.

    ENDLOOP.

*   Prüfung der Daten aus der Justiz
    IF lines( lt_recin_jus ) > 0.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>check_daten_allgemein
        EXPORTING
          i_dienststelle = i_dienststelle
          i_herkunft     = 'J'
        IMPORTING
          e_rc           = e_rc
        CHANGING
          c_recin        = lt_recin_jus.
    ENDIF.

*   Prüfung der Daten aus LvermGeo
    IF lines( lt_recin_lv ) > 0.
      CALL METHOD /thkr/cl_co_leistungsrechnung=>check_daten_allgemein
        EXPORTING
          i_dienststelle = i_dienststelle
          i_herkunft     = 'L'
        IMPORTING
          e_rc           = e_rc
        CHANGING
          c_recin        = lt_recin_lv.
    ENDIF.

  ENDMETHOD.


  METHOD check_daten_allgemein.

    DATA: ls_recin     TYPE /thkr/co_leist_input,
          lv_ekz(1)    TYPE n,
          lv_summe     TYPE p DECIMALS 3,
          lv_menge1    TYPE p DECIMALS 3,
          lv_besold(3) TYPE c,
          lv_iauftr    TYPE aufnr,
          lv_kostl     TYPE kostl,
          lv_ak_anteil TYPE /thkr/co_ak_anteil,
          lv_ak_jus    TYPE /thkr/co_ak_anteil,
          lv_ak_lgeo   TYPE /thkr/co_ak_anteil,
          lt_lart      TYPE TABLE OF /thkr/co_leist_l,
          ls_lart      TYPE /thkr/co_leist_l.

*art_cust:
*01	max. Arbeitskraftanteil (Justiz) pro Mitarbeiter
*02	max. Arbeitskraftanteil (LvermGeo) pro Mitarbeiter
*03	Umrechnungsfaktor (Justiz)
*04	Umrechnungsfaktor (LvermGeo)
*05	Prüfung für LvermGeo einschalten (X)
*06	Berechnungsmotiv

    SORT c_recin BY dienststelle ma_nummer.
    lv_summe = 0.

    LOOP AT c_recin INTO ls_recin.

      TRANSLATE ls_recin TO UPPER CASE.
*  REPLACE ',' WITH '.' INTO recin-koeff.
      REPLACE ',' WITH '.' INTO ls_recin-meng1.


*Check Dienststelle
      IF ls_recin-dienststelle NE i_dienststelle.
        WRITE: / 'Datensatz entspricht nicht der Dienststelle', i_dienststelle COLOR 3.
        WRITE: / 'Falsche Dienststelle:', ls_recin-dienststelle COLOR 3.
        WRITE: / ls_recin-dienststelle COLOR 3, ls_recin-ma_nummer, ls_recin-besold_gr,
                 ls_recin-meng1,  ls_recin-kostl, ls_recin-iauftr.
        e_rc = 8.
        lv_ekz = 1.
      ENDIF.

*Check Anteil größer 1
      lv_menge1 = ls_recin-meng1.
      lv_summe = lv_summe + lv_menge1.
*  x_o_w = recin-o_w.
      lv_besold = ls_recin-besold_gr.
      AT END OF ma_nummer.

        IF i_herkunft = 'J'.
          IF lv_summe GT gv_ak_jus.
            WRITE: / '*** Arbeitsanteil pro Mitarbeiter ist größer', gv_ak_jus, ',',
                     'nämlich', lv_summe COLOR 3.
            WRITE: / ls_recin-dienststelle(4), ls_recin-ma_nummer(4), lv_besold(3).
            e_rc = 8.
            lv_ekz = 1.
          ENDIF.
        ELSE.
          IF lv_summe GT gv_ak_lgeo.
            WRITE: / '*** Arbeitsanteil pro Mitarbeiter ist größer', gv_ak_lgeo, ',',
                     'nämlich', lv_summe COLOR 3.
            WRITE: / ls_recin-dienststelle(4), ls_recin-ma_nummer(4), lv_besold(3).
            e_rc = 8.
            lv_ekz = 1.
          ENDIF.
        ENDIF.
        lv_summe = 0.
      ENDAT.

*Check Dienststelle-Kostenstelle
*      IF ls_recin-dienststelle NE ls_recin-kostl+1(4).
      IF ls_recin-dienststelle NE ls_recin-kostl(4).
        WRITE: / '*** Dienststelle', ls_recin-dienststelle COLOR 3,
                   'darf Kostenstelle',
                   ls_recin-kostl COLOR 3, 'nicht bebuchen'.
        WRITE: / ls_recin-dienststelle COLOR 3, ls_recin-ma_nummer,        "recin-o_w,
              ls_recin-besold_gr, ls_recin-meng1, ls_recin-kostl COLOR 3, ls_recin-iauftr.
        e_rc = 8.
        lv_ekz = 1.
      ENDIF.

*Prüfung, ob Auftrag existiert.
      IF NOT ls_recin-iauftr IS INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_recin-iauftr
          IMPORTING
            output = lv_iauftr.

        SELECT COUNT( * ) FROM coas WHERE aufnr = lv_iauftr.

        IF sy-subrc NE 0.
          WRITE: / '*** Innenauftrag existiert nicht'.
          WRITE: / ls_recin-dienststelle, ls_recin-ma_nummer,
                   ls_recin-besold_gr, ls_recin-meng1, ls_recin-kostl, ls_recin-iauftr COLOR 3.
          e_rc = 8.
          lv_ekz = 1.
        ENDIF.
      ENDIF.

*Check Existenz der Kostenstelle
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_recin-kostl
        IMPORTING
          output = lv_kostl.

      SELECT COUNT( * ) FROM csks WHERE kokrs = '1000' AND kostl = lv_kostl.

      IF sy-subrc NE 0.
        WRITE: / '*** Kostenstelle existiert nicht'.
        WRITE: / ls_recin-dienststelle, ls_recin-ma_nummer, ls_recin-besold_gr,
                 ls_recin-meng1, ls_recin-kostl COLOR 3, ls_recin-iauftr.
        e_rc = 8.
        lv_ekz = 1.
      ENDIF.

*Check Gültigkeit der Mitarbeiternummer
*      CASE ls_recin-ma_nummer(1).
*        WHEN '1'.
*        WHEN '2'.
*        WHEN '3'.
*        WHEN '4'.
*        WHEN OTHERS.
*          WRITE: / '*** Mitarbeiternummer muß mit 1,2,3 oder 4 beginnen'.
*          WRITE: / ls_recin-dienststelle, ls_recin-ma_nummer COLOR 3, ls_recin-besold_gr,
*                   ls_recin-meng1, ls_recin-kostl, ls_recin-iauftr.
*          e_rc = 8.
*          lv_ekz = 1.
*      ENDCASE.

* Check Leistungsart gegen erste Stelle der Mitartbeiternummer
* (die Leistungsart steht in Tabelle CSLA)
* Prüfung für LverGeo nur durchführen, wenn auch in der Cust-Tabelle das Kennzeichen gesetzt ist
     if i_herkunft = 'J' or ( i_herkunft = 'L' and not gv_check_lv is initial ).

      READ TABLE gt_lart WITH KEY lstar = ls_recin-besold_gr INTO ls_lart.
      IF sy-subrc = 0.
        IF ls_recin-ma_nummer(1) <> ls_lart-pruefwert.
          WRITE: / 'Die Mitarbeiternummer', ls_recin-ma_nummer, 'passt nicht zur Besoldungsgruppe', ls_recin-besold_gr COLOR 3.
          WRITE: / 'Keine Buchung des Beleges.' COLOR 3.
          e_rc = 8.
          lv_ekz = 1.
        ENDIF.

      ELSE.
        WRITE: / 'Die Leistungsart ', ls_recin-besold_gr, 'ist nicht in der Tabelle /THKR/CO_LEIST_L vorhanden' COLOR 3.
        WRITE: / 'Keine Buchung des Beleges.' COLOR 3.
        e_rc = 8.
        lv_ekz = 1.
      ENDIF.


      IF lv_ekz = 1.
        ULINE.
        lv_ekz = 0.
      ENDIF.

    ENDIF.

  ENDLOOP.







*Check Innen- und(!) Prozessauftrag
*  IF NOT ls_recin-iauftr IS INITIAL
*  AND NOT recin-pauftr IS INITIAL.
*    WRITE: / '*** Es sind 2 Aufträge angegeben (nur 1 zulässig).'.
*    WRITE: / recin-dienststelle, recin-ma, recin-o_w, recin-besold,
*              recin-pnk, recin-koeff, recin-kostl, recin-iauftr COLOR 3,
*               recin-pauftr COLOR 3.
*    kz = 1. ekz = 1.
*  ENDIF.



*  IF NOT ls_recin-pauftr IS INITIAL.
*    SELECT * FROM cbpr WHERE prznr = recin-pauftr.
*    ENDSELECT.
*    IF sy-subrc NE 0.
*      WRITE: / '*** Prozessauftrag existiert nicht'.
*      WRITE: / recin-dienststelle, recin-ma, recin-o_w, recin-besold,
*                recin-pnk, recin-koeff, recin-kostl, recin-iauftr,
*                 recin-pauftr COLOR 3.
*      kz = 1.
*      ekz = 1.
*    ENDIF.
*  ENDIF.

*Check gültige Personal-Nebenkosten
*  CASE recin-pnk.
*    WHEN 'PNKE'.
*    WHEN 'PNKB'.
*    WHEN OTHERS.
*      WRITE: / '*** Personalnebenkosten (PNK) nicht oder falsch angegeben'.
*      WRITE: / recin-dienststelle, recin-ma, recin-o_w, recin-besold,
*              recin-pnk COLOR 3, recin-koeff, recin-kostl, recin-iauftr,
*                 recin-pauftr.
*      kz = 1.  ekz = 1.
*  ENDCASE.

*Check, ob PNK und Besoldungsgruppe zusammen passen.
*  IF ( recin-besold(1) = 'A' OR
*       recin-besold(1) = 'B' OR
*       recin-besold(1) = 'R' )
*  AND recin-pnk NE 'PNKB'.
*    WRITE: / '*** PNK und Besoldung passen nicht zusammen'.
*    WRITE: / recin-dienststelle, recin-ma, recin-o_w,
*            recin-besold COLOR 3, recin-pnk COLOR 3, recin-koeff,
*            recin-kostl, recin-iauftr, recin-pauftr.
*    kz = 1.  ekz = 1.
*  ENDIF.
*
*  IF ( recin-besold(1) = 'E' OR
*       recin-besold(1) = 'S' OR
*       recin-besold(1) = 'K' )
*    AND recin-pnk NE 'PNKE'.
*    WRITE: / '*** PNK und Besoldung passen nicht zusammen'.
*    WRITE: / recin-dienststelle, recin-ma, recin-o_w,
*            recin-besold COLOR 3, recin-pnk COLOR 3, recin-koeff,
*            recin-kostl, recin-iauftr, recin-pauftr.
*    kz = 1.  ekz = 1.
*  ENDIF.
*
*  IF (  recin-besold(4) = 'WAZU' )
*   AND recin-pnk NE 'PNKE'.
*    WRITE: / '*** PNK und Besoldung passen nicht zusammen'.
*    WRITE: / recin-dienststelle, recin-ma, recin-o_w,
*            recin-besold COLOR 3, recin-pnk COLOR 3, recin-koeff,
*            recin-kostl, recin-iauftr, recin-pauftr.
*    kz = 1.   ekz = 1.
*  ENDIF.
*
*  IF (  recin-besold(1) = 'W' AND
*        recin-besold(4) NE 'WAZU' )
*        AND recin-pnk NE 'PNKB'.
*    WRITE: / '*** PNK und Besoldung passen nicht zusammen'.
*    WRITE: / recin-dienststelle, recin-ma, recin-o_w,
*            recin-besold COLOR 3, recin-pnk COLOR 3, recin-koeff,
*            recin-kostl, recin-iauftr, recin-pauftr.
*    kz = 1.   ekz = 1.
*  ENDIF.
*
**Check gültiges Ost/West-Kennzeichen
*  CASE recin-o_w.
*    WHEN 'O'.
*    WHEN 'W'.
*    WHEN 'o'.
*    WHEN 'w'.
*    WHEN OTHERS.
*      WRITE: / '*** O-W-Kennzeichen nicht oder falsch angegeben'.
*      WRITE: / recin-dienststelle, recin-ma, recin-o_w COLOR 3,
*             recin-besold,
*             recin-pnk, recin-koeff, recin-kostl, recin-iauftr,
*             recin-pauftr.
*      kz = 1.  ekz = 1.
*  ENDCASE.
ENDMETHOD.


METHOD check_user.

  DATA: lv_dummy(10) TYPE c,
        lv_accnt     TYPE xuaccnt.

  lv_dummy = space.
  CONCATENATE i_dienststelle '090001' INTO lv_dummy.

  CONCATENATE 'ZLEIST_' i_dienststelle INTO gv_mappenname.

* Berechtigung User <-> Geschäftsbereich (entspricht der vierstelligen Dienststelle aus dem Dateiname)
  AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
   ID 'GSBER' FIELD i_dienststelle
   ID 'ACTVT' FIELD '01'.                "01 - Anlegen
  IF sy-subrc NE 0.
    WRITE: / 'Keine Berechtigung für Dienststelle (Geschäftsbereich) ', i_dienststelle.       "lv_dummy.
    e_rc = '8'.
  ENDIF.


**Berechtigung User<->Kostenstelle
*  AUTHORITY-CHECK OBJECT 'K_CSKS'
*           ID 'ACTVT'  FIELD '03'
*           ID 'KOKRS'  FIELD CO_KOKRS
*           ID 'KOSTL'  FIELD lv_dummy.
*  IF sy-subrc NE 0.
*    WRITE: / 'Keine Berechtigung für Dienststelle ', lv_dummy.       "i_dienststelle.
*    e_rc = '8'.
*  ENDIF.

ENDMETHOD.


  METHOD datei_einlesen.

*   i_dateiname
*   e_recin

*DATA: BEGIN OF recin OCCURS 999,
*        dienststelle(4),
*        ma(4),
*        o_w(1),
*        besold(6),
*        pnk(4),
*        koeff(4),
*        kostl(10),
*        iauftr(12),
*        pauftr(12),
*        abord(4),
*      END OF recin.

    DATA: lf_result TYPE c.

    DATA: lt_lines   TYPE string_t,
          lf_line    TYPE string,
          lf_linenum TYPE sy-index,
          lf_colnum  TYPE sy-index,
          lt_columns TYPE string_t,
          lf_column  TYPE string.

    DATA: ls_recin TYPE /thkr/co_leist_input,
          lt_datei TYPE TABLE OF /thkr/co_leist_d,
          ls_datei TYPE /thkr/co_leist_d,
          lv_cnt   TYPE i,
          lv_kz    TYPE i.


    " Check if file exists
    CALL METHOD cl_gui_frontend_services=>file_exist
      EXPORTING
        file                 = i_dateiname
      RECEIVING
        result               = lf_result
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        wrong_parameter      = 3
        not_supported_by_gui = 4
        OTHERS               = 5.

    IF sy-subrc NE 0 OR lf_result NE abap_true.
      e_rc = '1'.
      EXIT.
    ENDIF.

    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = i_dateiname
      IMPORTING
        stripped_name = e_datei
*       file_path     =
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      e_rc = '2'.
      EXIT.
    ENDIF.

    gv_datei = e_datei.

* Check auf "leist" im Dateinamen
    IF e_datei CP '*leist*'.

      lv_cnt = 0.
      lv_kz  = 1.
      DO.
        IF e_datei+lv_cnt(1) EQ ' '.
          lv_kz = 1.
          EXIT.
        ENDIF.
        IF e_datei+lv_cnt(5) CP 'leist'.
          lv_kz = 0.
          EXIT.
        ENDIF.
        lv_cnt = lv_cnt + 1.
      ENDDO.
      IF lv_kz NE 0.
        e_rc = '8'.
        EXIT.
      ENDIF.

*   GSBER, JAHR, MONAT, DATEINAME, STATUS, CPUDT, CPUTM, USNAM
*    ls_datei-dateiname = e_datei.
*    ls_datei-jahr      = e_datei+6(4).
*    ls_datei-monat     = e_datei+10(2).
*    ls_datei-gsber     = e_datei+12(4).

      SELECT * FROM /thkr/co_leist_d INTO TABLE lt_datei
        WHERE dateiname = e_datei OR
              ( jahr = e_datei+5(4) AND monat = e_datei+9(2) AND gsber = e_datei+11(4) ).

      IF sy-subrc <> 0.
*      Datei wurde noch nicht verarbeitet. Verarbeitung kann erfolgen.
      ELSE.
        LOOP AT lt_datei INTO ls_datei.
          IF ls_datei-status = 'X'.
            e_rc = '4'.
          ENDIF.
        ENDLOOP.
        IF e_rc = '4'.
          EXIT.
        ENDIF.
      ENDIF.

      CALL METHOD cl_gui_frontend_services=>gui_upload
        EXPORTING
          filename = i_dateiname
        CHANGING
          data_tab = lt_lines.

      lf_linenum = 0.
      LOOP AT lt_lines INTO lf_line.

        CLEAR ls_recin.
        lf_linenum = sy-tabix.

        CALL FUNCTION 'RSDS_CONVERT_CSV'
          EXPORTING
            i_data_sep       = ';'
            i_esc_char       = '"'
            i_record         = lf_line
            i_field_count    = 9999
          IMPORTING
            e_t_data         = lt_columns
          EXCEPTIONS
            escape_no_close  = 1
            escape_improper  = 2
            conversion_error = 3
            OTHERS           = 4.

        LOOP AT lt_columns INTO lf_column.
          CASE sy-tabix.
            WHEN 1.
              ls_recin-dienststelle = lf_column.
            WHEN 2.
              ls_recin-ma_nummer = lf_column.
            WHEN 3.
              ls_recin-lg_ma_nummer = lf_column.
            WHEN 4.
              ls_recin-besold_gr = lf_column.
            WHEN 5.
              ls_recin-meng1 = lf_column.
            WHEN 6.
              ls_recin-kostl = lf_column.
            WHEN 7.
              ls_recin-iauftr = lf_column.
            WHEN 8.
              ls_recin-abord = lf_column.
            WHEN OTHERS.
          ENDCASE.

        ENDLOOP.

        IF ls_recin-dienststelle CO '0123456789'.
          APPEND ls_recin TO e_recin.
        ELSE.
*        Überschriftzeile oder Leerzeilen nicht übernehmen
        ENDIF.

      ENDLOOP.

    ELSE.
      e_rc = '8'.
    ENDIF.

    IF 1 = 2. ENDIF.

  ENDMETHOD.


  METHOD schreiben_protokoll.

    DATA: ls_datei TYPE /thkr/co_leist_d.

*   GSBER, JAHR, MONAT, DATEINAME, STATUS, CPUDT, CPUTM, USNAM
    ls_datei-dateiname = i_dateiname.
    ls_datei-jahr      = i_dateiname+5(4).
    ls_datei-monat     = i_dateiname+9(2).
    ls_datei-gsber     = i_dateiname+11(4).
    ls_datei-status    = 'X'.
    ls_datei-cpudt     = sy-datum.
    ls_datei-cputm     = sy-uzeit.
    ls_datei-usnam     = sy-uname.

    modify /thkr/co_leist_d from ls_datei.

  ENDMETHOD.
ENDCLASS.
