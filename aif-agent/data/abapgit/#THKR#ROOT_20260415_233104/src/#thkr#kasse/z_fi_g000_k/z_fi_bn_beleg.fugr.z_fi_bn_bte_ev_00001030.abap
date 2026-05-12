FUNCTION z_fi_bn_bte_ev_00001030.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BKDF) LIKE  BKDF STRUCTURE  BKDF
*"     VALUE(I_UF05A) LIKE  UF05A STRUCTURE  UF05A
*"     VALUE(I_XVBUP) LIKE  OFIWA-XVBUP DEFAULT 'X'
*"  TABLES
*"      T_AUSZ1 STRUCTURE  AUSZ1 OPTIONAL
*"      T_AUSZ2 STRUCTURE  AUSZ2 OPTIONAL
*"      T_AUSZ3 STRUCTURE  AUSZ_CLR OPTIONAL
*"      T_BKP1 STRUCTURE  BKP1
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEC STRUCTURE  BSEC
*"      T_BSED STRUCTURE  BSED
*"      T_BSEG STRUCTURE  BSEG
*"      T_BSET STRUCTURE  BSET
*"      T_BSEU STRUCTURE  BSEU
*"----------------------------------------------------------------------
* Zu Lauf 3.2 müssen auch Zahlungsanzeigen auf Allg. AO erstellt werden
* das bedeutet: Es müssen auch Ausgleiche zu einer ZA führen, aber
* es werden nur Ausgleiche mit mind. einer Zahlung berücksichtigt
* (nicht beliebige Guschriften)
* bei der Behandlung von Mahnbereich 90:
* Zahlungsmitteilung soll erstellt werden, wenn ein beliebiger Beleg
* zu dem Kassenzeichen mindestens die Mahnstufe 3 hat.
*----------------------------------------------------------------------
* Gjahr der Zahlung einbauen
*
* Belegart ZM wird nicht berücksichtig, da der Zahllauf - Debit.
* Lastschrift bereits Informationen über Zahlungseingänge enthält
*
* für alle Belege eines Kassenzeichens kann es nur einen Mahnbereich
* geben (Festlegung im Fachkonzept)
* Es wird auch davon ausgegangen, dass Ursprungsbelege nur einen
* Debitor enthalten
*
* wird der Ausgleichsbeleg benötigt für den Storno - aktuell nicht
* Tabelle T_XRAGL enthält die hinterlegten Belege
*----------------------------------------------------------------------
  FIELD-SYMBOLS: <fs_ausz1>   TYPE ausz1,
                 <fs_ausz3>   TYPE  ausz_clr,
                 <fs_bseg>    TYPE bseg,
                 <fs_bkpf>    TYPE bkpf,
                 <fs_bseg_do> TYPE bseg.

  CONSTANTS:
    c_hash     TYPE c VALUE '#',
    c_on       TYPE xfeld VALUE 'X',
    c_off      TYPE xfeld VALUE ' ',
    c_char_y   TYPE xfeld VALUE 'Y',
    c_zz_009_1 TYPE c VALUE '1',
    c_f_200    TYPE char03 VALUE '200',
    c_f_201    TYPE char03 VALUE '201',
    c_blart_dz TYPE blart VALUE 'DZ',
    c_nf_blart TYPE char50 VALUE 'MG#MO#SG#SN#VK#VO#EL#HB#HO#AH#AN#AW#GK#GO#HA#'. "2025-08-20 js: NF-Belegarten lt. Liste A_B_NF



  DATA: lt_bseg TYPE STANDARD TABLE OF bseg.
  DATA: lt_bseg_dz TYPE STANDARD TABLE OF bseg.

  DATA: ls_bkpf    TYPE bkpf,
        ls_bkpf_dz TYPE bkpf,
        lt_bkpf    TYPE STANDARD TABLE OF bkpf,
        lt_bkpf_dz TYPE STANDARD TABLE OF bkpf.
  DATA: ls_zfi_bn TYPE zfi_bn_nachricht.
  DATA: lt_zfi_bn TYPE STANDARD TABLE OF  zfi_bn_nachricht.

* >>(INS)Reiner Gerdes, BTC AG
  DATA:
*    ls_bkpf      TYPE bkpf,
    lt_bseg_save TYPE STANDARD TABLE OF bseg.


  READ TABLE t_bkpf INTO ls_bkpf INDEX 1.
*{   INSERT         EH1K900217                                        1
  DATA lt_bseg_old TYPE STANDARD TABLE OF bseg.
  lt_bseg_old[] = t_bseg[].
*}   INSERT

  CALL FUNCTION 'Z_FI_ALE_CHANGE_DOCUMENT'
    EXPORTING
      i_bkpf_old = ls_bkpf
      i_bkpf_new = ls_bkpf
*     I_MANL     = ' '
    TABLES
*{   REPLACE        EH1K900217                                        2
*\      t_bseg_old             = t_bseg
      t_bseg_old = lt_bseg_old
*}   REPLACE
      t_bseg_new = t_bseg
      t_bsed_old = t_bsed
      t_bsed_new = t_bsed
      t_bsec_old = t_bsec
      t_bsec_new = t_bsec
      t_bset_old = t_bset
      t_bset_new = t_bset.
* Begin AH001+
*IDOC Aufbauen-OVVISO AH001+

  CALL FUNCTION 'Z_FI_ALE_CHG_DOCUMENT_OVVISO'
    EXPORTING
      i_bkpf_old = ls_bkpf
      i_bkpf_new = ls_bkpf
*     I_MANL     = ' '
    TABLES
      t_bseg_old = t_bseg
      t_bseg_new = t_bseg
      t_bsed_old = t_bsed
      t_bsed_new = t_bsed
      t_bsec_old = t_bsec
      t_bsec_new = t_bsec
      t_bset_old = t_bset
      t_bset_new = t_bset.
* End   AH001+

  IF t_bseg[] IS INITIAL.
    CALL FUNCTION 'ZF_GET_POSITION_GLOBAL'
      TABLES
        et_bseg = lt_bseg_save.
  ELSE.
    lt_bseg_save[] = t_bseg[].

  ENDIF.


* Erweiterung Kunde in Vollstreckung  AH001+ 080618
  CALL FUNCTION 'Z_TRIGGER_FOR_CUSTOMER'
    TABLES
*     it_bseg = t_bseg
      it_bseg = lt_bseg_save.

  CALL FUNCTION 'Z_TRIGGER_FOR_CUSTOMER_MANSP'
    TABLES
      it_bseg = lt_bseg_save.

* <<(INS)Reiner Gerdes, BTC AG
" 2025-08-19 js: auch für leeren MABER (Allg.AnnAo) eine ZA erzeugen
*--------------------------------------------------------------------
*bei Teilzahlung - z.B.
  CHECK t_ausz1[] IS NOT INITIAL.
*--------------------------------------------------------------------
* Der Zahlungsbeleg ex. noch nicht (commit fehlt noch)
* haben wir überhaupt eine Zahlung
* Prüfung auf t_bseg-xzahl evtl nicht ok, weil Buschl der SHBKZ nicht
* als Zahlungsvorgang gepflegt
*--------------------------------------------------------------------
  LOOP AT t_bkpf WHERE blart  = c_blart_dz.
    EXIT.
  ENDLOOP.

*--------------------------------------------------------------------
* Zahlung wird benötigt- falls aktuell eine Zahlung gebucht wird, die
* zum Ausgleich führt - wird diese genommen
*--------------------------------------------------------------------
  IF sy-subrc = 0.
    lt_bkpf_dz[] = t_bkpf[].
    lt_bseg_dz[] = t_bseg[].
*--------------------------------------------------------------------
*  falls nicht - muss mindestens einer der auszugleichenden Belege
*  eine Zahlung sein
*  aktuell gibt es ggf.Teilzahlungen und die letzte Zahlung führt
*  zum Augsleich -> IF "erfüllt"
*  bei Allg. AO gibt es genau eine Zahlung
*  falls mehrere Zahlungen und dann Ausgleich->Priorisierung notwendig
*
*--------------------------------------------------------------------
  ELSE.
    LOOP AT  t_ausz3 ASSIGNING <fs_ausz3> WHERE shkzg = c_char_h
      AND  clrin = c_off. "Vollausgleich


      CALL FUNCTION 'FI_DOCUMENT_READ1'
        EXPORTING
          i_docno   = <fs_ausz3>-belnr
          i_byear   = <fs_ausz3>-gjahr
          i_compy   = <fs_ausz3>-bukrs
        IMPORTING
* falls wir die
          e_bkpf    = ls_bkpf_dz
        TABLES
          t_bseg    = lt_bseg_dz
*         T_BSEC    =
*         T_BSET    =
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
*--------------------------------------------------------------------
* Q-Gate 3.2 Festlegung : 02/2021
*--------------------------------------------------------------------
      IF  ls_bkpf_dz-blart  = c_blart_dz.
        APPEND ls_bkpf_dz TO lt_bkpf_dz.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF   lt_bkpf_dz[] IS NOT INITIAL.
*--------------------------------------------------------------------
* relevante Mahnbereiche ermitteln
*--------------------------------------------------------------------
    IF gv_za_string IS INITIAL.
      IF gt_zfi_za[] IS INITIAL.
        SELECT maber FROM zfi_za INTO TABLE gt_zfi_za.
        CONCATENATE LINES OF gt_zfi_za INTO gv_za_string SEPARATED BY c_hash.
        CONCATENATE c_hash gv_za_string INTO gv_za_string.
      ENDIF.
    ENDIF.
*--------------------------------------------------------------------
* t_ausz3 enthält die auszuziffernden Zeilen
* nehmen nur die auszuziffernden Belege, die auch einen relevanten Mahnbereich haben
* Mahnbereich haben oder z009
*--------------------------------------------------------------------
    LOOP AT t_ausz3 ASSIGNING <fs_ausz3> WHERE shkzg = c_char_s
      AND clrin = c_off.   "Ausgleich

      CLEAR ls_zfi_bn.
*--------------------------------------------------------------------
* eine Zeile hat den Mahnbereich die andere die FISTL
*--------------------------------------------------------------------
      CALL FUNCTION 'FI_DOCUMENT_READ1'
        EXPORTING
          i_docno   = <fs_ausz3>-belnr
          i_byear   = <fs_ausz3>-gjahr
          i_compy   = <fs_ausz3>-bukrs
        IMPORTING
* falls wir die
          e_bkpf    = ls_bkpf
        TABLES
          t_bseg    = lt_bseg
*         T_BSEC    =
*         T_BSET    =
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
*--------------------------------------------------------------------
* hat der U-Beleg das ZZ_009 Feld mit 1 (ZA erforderlich) gefüllt
* ggf. wird die Fehlernummer wegen Mahnbereich überschrieben
*--------------------------------------------------------------------
      IF ls_bkpf-z_009 = c_zz_009_1.  "ZA erforderlich (papierhaft)
        ls_zfi_bn-herk = c_char_y.
        ls_zfi_bn-fehlernr = c_f_200.
      ENDIF.
*--------------------------------------------------------------------
*  hat der U-Beleg den richtigen Mahnbereich?
*  es werden Zeilen eines U-Beleges ausgeglichen
*--------------------------------------------------------------------
      LOOP AT lt_bseg ASSIGNING <fs_bseg> WHERE buzei = <fs_ausz3>-buzei
        AND  koart = c_char_d.
*       AND  maber IS NOT INITIAL.  " 2025-08-19 js: auch für leeren MABER (Allg.AnnAo) eine ZA erzeugen


        CONCATENATE c_hash <fs_bseg>-maber INTO DATA(ls_search).
*--------------------------------------------------------------------
* Mahnbereich vorhanden
*--------------------------------------------------------------------
        IF  gv_za_string CS ls_search .
          IF <fs_bseg>-maber = c_maber_90.
            IF <fs_bseg>-manst GE 3.
              ls_zfi_bn-herk = c_char_y.
              ls_zfi_bn-fehlernr = c_f_201.
            ELSE.
*--------------------------------------------------------------------
*  für den Fall von Mahnbereich 90 - müssen alle Belege zur Referenz
*  auf Mahnstufe 3 untersucht werden
*--------------------------------------------------------------------
              SELECT @abap_true INTO @DATA(exists) FROM bsid
                            WHERE bukrs = @ls_bkpf-bukrs
                              AND kunnr = @<fs_bseg>-kunnr
                              AND augbl = ' '
                              AND xblnr = @ls_bkpf-xblnr
                              AND shkzg = 'S'
                              AND manst GE 3
                              AND maber = @c_maber_90.
                EXIT.
              ENDSELECT.
              IF exists = abap_true.
                ls_zfi_bn-herk = c_char_y.
                ls_zfi_bn-fehlernr = c_f_201.
              ENDIF.
            ENDIF.

          ELSE.
            IF ls_bkpf-z_009 IS INITIAL.  "Kennzeichen nicht gesetzt
              "aber rel. Mahnbereich
              ls_zfi_bn-herk = c_char_y.
              ls_zfi_bn-fehlernr = c_f_200.
            ENDIF.
          ENDIF.
        ENDIF.
*--------------------------------------------------------------------
* Aufnahme Belegdaten - Ursprungsbeleg auch  Betrag
*--------------------------------------------------------------------
        IF <fs_bseg>-shkzg = c_char_s.
          ls_zfi_bn-wrbtr =  ls_zfi_bn-wrbtr + <fs_bseg>-wrbtr.
        ELSE.
          ls_zfi_bn-wrbtr =  ls_zfi_bn-wrbtr - <fs_bseg>-wrbtr.
        ENDIF.

*--------------------------------------------------------------------
*   Debitor /Kreditor --
*--------------------------------------------------------------------
        ls_zfi_bn-kunnr =  <fs_bseg>-kunnr.
        ls_zfi_bn-maber =  <fs_bseg>-maber.
*--------------------------------------------------------------------
* Faktura-SD-Auftrag-Position
*--------------------------------------------------------------------
        IF <fs_bseg>-vbeln IS NOT INITIAL.
          ls_zfi_bn-vbeln = <fs_bseg>-vbeln.
        ENDIF.

      ENDLOOP.
*--------------------------------------------------------------------
* Nebenforderungen sollen keine Zahlungsanzeige erzeugen " 2025-08-20 js
*--------------------------------------------------------------------
      IF c_nf_blart CS ls_bkpf-blart. " MG#MO#SG#SN#VK#VO#EL#HB#HO#AH#AN#AW#GK#GO#HA#
        CLEAR ls_zfi_bn-herk.
      ENDIF.

*-----------------------------------------------------------------------
* Ende-hier haben wir nur eine Zeile
*-----------------------------------------------------------------------
      CHECK ls_zfi_bn-kunnr IS NOT INITIAL.
      CHECK ls_zfi_bn-herk = 'Y'.
*-----------------------------------------------------------------------
*   Ursprungsbeleg
*-----------------------------------------------------------------------
      ls_zfi_bn-belnr = <fs_ausz3>-belnr.
      ls_zfi_bn-buzei = <fs_ausz3>-buzei.
      ls_zfi_bn-bukrs = <fs_ausz3>-bukrs.
      ls_zfi_bn-gjahr = <fs_ausz3>-gjahr.
*--------------------------------------------------------------------
*  nehmen diese Angaben vom Ursprungsbeleg (wie bei den Allg. Anordnungen)
*--------------------------------------------------------------------
      ls_zfi_bn-waers  =  ls_bkpf-waers.
      ls_zfi_bn-blart  = ls_bkpf-blart.
      ls_zfi_bn-xblnr  = ls_bkpf-xblnr.
      ls_zfi_bn-zz_009 = ls_bkpf-z_009.
      ls_zfi_bn-zz_011 = ls_bkpf-psofn.   " 2025-08-20 js: Aktenzeichen
*--------------------------------------------------------------------
* Finanzstelle, Fipo aus der Sachkontenzeile des U-Beleges
*--------------------------------------------------------------------
      LOOP AT lt_bseg ASSIGNING <fs_bseg_do>
      WHERE
      bukrs = <fs_ausz3>-bukrs
      AND belnr = <fs_ausz3>-belnr
      AND gjahr = <fs_ausz3>-gjahr
      AND buzid = c_off
      AND koart = c_char_s.
        IF <fs_bseg_do>-fipos(1) NE c_char_t
        AND <fs_bseg_do>-fistl IS NOT INITIAL.
          ls_zfi_bn-fistl =  <fs_bseg_do>-fistl.
          ls_zfi_bn-fipos = <fs_bseg_do>-fipos.
        ENDIF.
      ENDLOOP.
*--------------------------------------------------------------------
* hier verlassen, falls keine Finanzstelle ermittelt werden kann
* zum Beispiel bei Teilzahlung
*--------------------------------------------------------------------
      IF ls_zfi_bn-fistl IS NOT INITIAL.
* falls Fistl aus anderen Gründen noch fehlt
* GET_FISTL_FMFIIT aus ZCL_FI_BN_NACHRICHTEN
*
*--------------------------------------------------------------------
* Zahlungsbeleg
*--------------------------------------------------------------------
        LOOP AT lt_bkpf_dz ASSIGNING <fs_bkpf>  WHERE bukrs = <fs_ausz3>-bukrs.
* Zahlungsbeleg
          ls_zfi_bn-vblnr = <fs_bkpf>-belnr.
*--------------------------------------------------------------------
* Feld ex. nicht - notwendig??
*            ls_zfi_bn-gjahrz = <fs_bkpf>-gjahr.
*-------------------------------------------------------------------
* der ZahlungsBeleg m u s s aus dem Buchungskreis der
* allg AO kommen- alles andere paßt nicht bei den
* Listen usw.-> kein eigener Buchungskreis
*-----------------------------------------------
          ls_zfi_bn-uname  = <fs_bkpf>-usnam.
          ls_zfi_bn-vname  = <fs_bkpf>-ppnam.
          ls_zfi_bn-bldat  = <fs_bkpf>-bldat.
          ls_zfi_bn-budat  = <fs_bkpf>-budat.
          ls_zfi_bn-psobt =  <fs_bkpf>-psobt.
*-----------------------------------------------
* für die Daten aus dem 2. Buchungskreis
*-----------------------------------------------
          ls_zfi_bn-bvorg = <fs_bkpf>-bvorg.
*-----------------------------------------------
* für die weitere Suche nach FEBKO-Informationen
* der Belegkopftext sieht in beiden Belegen so aus
*-----------------------------------------------
          IF  <fs_bkpf>-bktxt(13) CO '0123456789'.
            ls_zfi_bn-kukey = <fs_bkpf>-bktxt+0(8).
            ls_zfi_bn-esnum = <fs_bkpf>-bktxt+8(5).
          ENDIF.
        ENDLOOP.
*--------------------------------------------------------------------
* Valutadatum-> es dürfte genau eine Zeile mit Valutadatum geben,
* die steht in Buchungskreis 7000
*--------------------------------------------------------------------
        LOOP AT lt_bseg_dz ASSIGNING <fs_bseg>  WHERE valut IS NOT INITIAL.
          ls_zfi_bn-valut = <fs_bseg>-valut.
          EXIT.
        ENDLOOP.
*--------------------------------------------------------------------
*  z. B. bei allg AO haben wir nicht die Zeile mit BUKRS 7000
*  aber die Zahlung sollte BVORG enthalten
*  -> SUCHEN
*--------------------------------------------------------------------
        IF sy-subrc NE 0 AND
         ls_zfi_bn-bvorg IS NOT INITIAL.

          SELECT a~valut  FROM acdoca AS a
            INNER JOIN  bkpf AS b
              ON  a~rbukrs   = b~bukrs
              AND a~belnr = b~belnr
              AND a~gjahr = b~gjahr
            WHERE
              b~bvorg = @ls_zfi_bn-bvorg
              AND b~xreversing EQ @c_off
              AND b~xreversed  EQ @c_off
              AND a~rldnr  EQ '0L'
              AND a~valut IS NOT INITIAL
            INTO @ls_zfi_bn-valut.
            EXIT.
          ENDSELECT.
        ENDIF.
*-------------------------------------------------------------------

        APPEND ls_zfi_bn TO lt_zfi_bn.
      ENDIF.
    ENDLOOP.
  ENDIF.

*--------------------------------------------------------------------
* Verdichten falls Zahlungsbeleg und Forderung und Kundennummer
* übereinstimmen
*--------------------------------------------------------------------

  IF lt_zfi_bn[] IS NOT INITIAL.
    CALL FUNCTION 'Z_FI_BN_NACHRICHT_UPDATE' IN UPDATE TASK
      TABLES
        t_fi_bn_nachricht = lt_zfi_bn
* EXCEPTIONS
*       FEHLER            = 1
*       OTHERS            = 2
      .
* bei update task - gibt es keine Rückmeldung
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
ENDFUNCTION.
