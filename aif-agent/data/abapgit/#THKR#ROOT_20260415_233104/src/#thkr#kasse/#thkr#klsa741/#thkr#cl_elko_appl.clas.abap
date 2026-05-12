class /THKR/CL_ELKO_APPL definition
  public
  create public .

public section.

  types:
    BEGIN OF TS_TEILZAHLUNG,
           belnr TYPE belnr_d,
           gjahr TYPE gjahr,
           wrbtr TYPE wrbtr,
           dzdel TYPE char1,
         end   of ts_teilzahlung .
  types:
    tt_teilzahlung TYPE STANDARD TABLE OF ts_teilzahlung .
  types:
    BEGIN OF ts_beleg,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
             buzei TYPE buzei,
           END OF ts_beleg .

  class-data GC_VGINT_1005 type VGINT_EB value '1005' ##NO_TEXT.
  class-data GC_VGINT_0018 type VGINT_EB value '0018' ##NO_TEXT.
  class-data GC_VGINT_0019 type VGINT_EB value '0019' ##NO_TEXT.
  class-data GC_VGINT_1008 type VGINT_EB value '1008' ##NO_TEXT.
  class-data GC_VGINT_0014 type VGINT_EB value '0014' ##NO_TEXT.
  class-data GC_VGINT_1020 type VGINT_EB value '1020' ##NO_TEXT.

  methods CHECK_AVIP_KBLK
    changing
      !XT_AVIP_OUT type AVIP_TT
      !XT_KBLK type /THKR/TT_KBLK .
  methods CHECK_PRUEFZIFFERN
    changing
      !XT_KASSZ type /THKR/TT_XBLNR .
  methods CONSTRUCTOR .
  methods CREATE_KASSENZ_KETTE
    importing
      !IT_KETTE type /THKR/TT_LSA_KASSZ_KETTE
    raising
      /THKR/CX_ELKO .
  methods FREE_MEMORY_ID .
  methods GET_BSID_AUS_KASSENZ
    importing
      !IT_KASSZ type /THKR/TT_XBLNR
      !IV_GEBKZ type CHAR1
    changing
      !XT_BSID type /THKR/TT_ELKO_ITEMS .
  methods GET_BSID_AUS_REFERENZ
    importing
      !IT_BSID type /THKR/TT_ELKO_ITEMS
      !IT_KASSZ type /THKR/TT_XBLNR
      !IV_GEBKZ type CHAR1
    changing
      !XT_BSID_TEILZ type /THKR/TT_ELKO_ITEMS .
  methods GET_BSIK_AUS_KASSENZ
    importing
      !IT_KASSZ type /THKR/TT_XBLNR
    changing
      !XT_BSIK type BSIK_TT .
  methods GET_KASSENZ_AUS_FEBRE
    importing
      !IV_VWEZW type ANY optional
    changing
      !XT_KASSZ type /THKR/TT_XBLNR
    raising
      /THKR/CX_ELKO .
  methods GET_KASSENZ_AUS_GEBKZ
    importing
      !IV_KUKEY type KUKEY_EB optional
      !IV_ESNUM type ESNUM_EB optional
    changing
      !XT_KASSZ type /THKR/TT_XBLNR optional
      !XV_GEBKZ type CHAR1 optional
      !XV_ACCTMP type FEB_ACCTMP optional
    raising
      /THKR/CX_ELKO .
  methods GET_KASSENZ_SUCHM
    importing
      !IV_VWEZW type ANY optional
    changing
      !XT_KASSZ type /THKR/TT_XBLNR
    raising
      /THKR/CX_ELKO .
  methods GET_KBLK_901_KASSENZ
    importing
      !IT_KASSZ type /THKR/TT_XBLNR
      !IT_BSID type /THKR/TT_ELKO_ITEMS
    changing
      !XT_KBLK type /THKR/TT_KBLK .
  methods GET_KBLK_902_KASSENZ
    importing
      !IT_KASSZ type /THKR/TT_XBLNR
      !IT_BSIK type BSIK_TT
    changing
      !XT_KBLK type /THKR/TT_KBLK .
  methods READ_ELKO_TABELLEN
    changing
      !XS_FEBKO type FEBKO optional
      !XS_FEBEP type FEBEP optional
    raising
      /THKR/CX_ELKO .
  methods SAVE_AVIS_DB
    importing
      !IS_FEBEP type FEBEP
      !IS_FEBKO type FEBKO
      !IV_TESTRUN type XFLAG .
  methods SET_AVIP_901_OUT
    importing
      !IV_VWEZW type STRING
      !IT_BSID type /THKR/TT_ELKO_ITEMS
      !IT_BSID_TEILZ type /THKR/TT_ELKO_ITEMS
    changing
      !XV_UEBERZ type CHAR1
      !XT_AVIP_OUT type AVIP_TT
    raising
      /THKR/CX_ELKO .
  methods SET_AVIP_902_OUT
    importing
      !IT_BSIK type BSIK_TT
    changing
      !XT_AVIP_OUT type AVIP_TT
    raising
      /THKR/CX_ELKO .
  methods SET_BAPI_BELEG_BUCHEN
    importing
      !IS_FEBKO type FEBKO
      !IS_FEBEP type FEBEP
      !IS_BELEG type TS_BELEG
    changing
      !XT_RETURN type BAPIRET2_T .
  methods SET_BUKRS_SEGMENT_FOR_T999
    importing
      !IV_KRED type CHAR1 optional
      !IV_KUNNR type KUNNR optional
      !IV_LIFNR type LIFNR optional
      !IV_BUKRS type BUKRS
    changing
      !XT_BAPIRET type BAPIRET2_T .
  methods SET_CREATE_KASSENZ
    importing
      !IV_ACCTMP type FEB_ACCTMP
    changing
      !XS_FEBEP type FEBEP
    raising
      /THKR/CX_ELKO .
  methods SET_SGTXT_FROM_VWEZW
    importing
      !IS_FEBEP type FEBEP
    changing
      !XV_SGTXT type GHO_TEMP_FILE_CONT .
  methods SET_FEBEP_AUS_KBLK
    importing
      !IT_KBLK type /THKR/TT_KBLK
      !IV_VGINT type VGINT_EB
      !IV_KRED type CHAR1 optional
    raising
      /THKR/CX_ELKO .
  methods SET_FTPOST_AUS_ACCTMP
    importing
      !IV_KUKEY type KUKEY_EB
      !IV_ESNUM type ESNUM_EB
    changing
      !XT_FTPOST type FEB_T_FTPOST
    raising
      /THKR/CX_ELKO .
  methods SET_FTPOST_FROM_KONTIER_K
    importing
      !IV_BUKRS type BUKRS
      !IV_HKONT type HKONT
      !IV_BUDAT type BUDAT optional
      !IV_COUNT type COUNT_PI optional
      !IV_TABIX type SY-TABIX optional
      !IV_MWSKZ type MWSKZ optional
    changing
      !XT_FTPOST type FAGL_T_FTPOST .
  methods SET_FTPOST_SOLL
    importing
      !IS_FEBKO type FEBKO
      !IS_FEBEP type FEBEP
    changing
      !XT_FTPOST type FAGL_T_FTPOST
      !XV_COUNT type COUNT_PI
      !XV_HKONT type HKONT .
  methods SET_FTPOST_XBLNR
    importing
      !IV_KUKEY type KUKEY_EB
      !IV_ESNUM type ESNUM_EB
    changing
      !XT_FTPOST type FEB_T_FTPOST
    raising
      /THKR/CX_ELKO .
  methods SET_HKONT_LEITWEG
    importing
      !IS_FEBKO type FEBKO
      !IS_FEBEP type FEBEP
    changing
      !XV_HKONT type HKONT .
  class-methods SET_IBAN_2_INTO_GRPNR
    changing
      !XS_FEBEP type FEBEP .
  methods SET_KONTIERUNG
    importing
      !IS_FEBEP type FEBEP
      !IS_FEBKO type FEBKO
    changing
      !XT_FEBCL type FEB_T_FEBCL .
  methods SET_KONTIERVORLAGE
    importing
      !IV_KUKEY type KUKEY_EB
      !IV_ESNUM type ESNUM_EB
      !IV_ACCTMP type FEB_ACCTMP
    changing
      !XT_ASSIGN_LINE type FEBY_BSPROC_ACC_ASSIGN
    raising
      /THKR/CX_ELKO
      CX_FEB .
  methods SET_REFRESH_ITAB
    changing
      !XV_GEBKZ type CHAR1 optional
      !XV_UEBERZ type CHAR1 optional
      !XT_KASSZ type /THKR/TT_XBLNR
      !XT_BSID type /THKR/TT_ELKO_ITEMS optional
      !XT_BSIK type TT_BSIK optional
      !XT_KBLK type /THKR/TT_KBLK
      !XT_AVIP_OUT type AVIP_TT .
  methods SET_SGTXT_TO_FEBEP
    importing
      !IV_FTPOST type CHAR1 optional
      !IV_VWEZW type GHO_TEMP_FILE_CONT
    changing
      !XT_FTPOST type FAGL_T_FTPOST optional .
  methods SET_TILGUNGSFOLGE_BSID
    changing
      !XT_BSID type /THKR/TT_ELKO_ITEMS .
  methods SEARCH_KASSENZ_UEB_BELNR
    importing
      !IV_VWEZW type CHAR30K
    changing
      !XT_KASSZ type /THKR/TT_XBLNR_UEB .
  PROTECTED SECTION.
private section.

  data MESSAGES type BAPIRET2_TAB .

  methods CHECK_KREDITOR
    importing
      !IV_LIFNR type LIFNR
    returning
      value(RV_VORHANDEN) type CHAR1 .
  methods CHECK_DEBITOR
    importing
      !IV_KUNNR type KUNNR
    returning
      value(RV_VORHANDEN) type CHAR1 .
  methods CONVERT_VERWENDUNGSZWECK_ANUM
    changing
      !XV_VWEZW type CHAR30K .
  methods CONVERT_VERWENDUNGSZWECK_NUM
    importing
      !IV_SUCHM type CHAR1 optional
    changing
      !XV_VWEZW type CHAR30K .
  methods ENTSPERRE_KASSZ_KETT
    raising
      /THKR/CX_ELKO .
  methods GET_KREDITOR_FROM_LFB1
    importing
      !IV_LIFNR type LIFNR
      !IV_BUKRS type BUKRS
    changing
      !XT_LFB1 type TY_LFB1 .
  methods GET_DEBITOR_FROM_KNB1
    importing
      !IV_KUNNR type KUNNR
      !IV_BUKRS type BUKRS
    changing
      !XT_KNB1 type TRTY_KNB1 .
  methods GET_GEBKZ
    importing
      !IS_FEBKO type FEBKO
      !IS_FEBEP type FEBEP
    changing
      !XT_KASSZ type /THKR/TT_XBLNR optional
      !XV_GEBKZ type CHAR1 optional
      !XV_ACCTMP type FEB_ACCTMP optional .
  methods INSERT_FEB_ACCNT_SAVE
    importing
      !IV_KUKEY type KUKEY_EB
      !IV_ESNUM type ESNUM_EB
      !IV_ACCTMP type FEB_ACCTMP
    changing
      !XT_ASSIGN_LINE type FEBY_BSPROC_ACC_ASSIGN
    raising
      /THKR/CX_ELKO
      CX_FEB .
  methods SEARCH_KASSENZ_ALPHANUM
    importing
      !IV_VWEZW type CHAR30K
    changing
      !XT_KASSZ type /THKR/TT_XBLNR .
  methods SEARCH_KASSENZ_AUS_KETTE
    changing
      !XT_KASSZ type /THKR/TT_XBLNR .
  methods SEARCH_KASSENZ_NUMERIC
    importing
      !IV_VWEZW type CHAR30K
    changing
      !XT_KASSZ type /THKR/TT_XBLNR .
  methods SET_AVIP_901_TEILZAHLUNG
    importing
      !IT_BSID type /THKR/TT_ELKO_ITEMS
    changing
      !XT_AVIP_OUT type AVIP_TT
      !XS_FEBEP type FEBEP
      !XV_UEBERZ type CHAR1 .
  methods SET_AVIP_901_VOLLAUSGLEICH
    importing
      !IT_BSID type /THKR/TT_ELKO_ITEMS
    changing
      !XT_AVIP_OUT type AVIP_TT
      !XV_VOLL_KZ type CHAR1
      !XS_FEBEP type FEBEP
      !XV_UEBERZ type CHAR1 .
  methods SET_AVIP_902_VOLLAUSGLEICH
    importing
      !IT_BSIK type BSIK_TT
    changing
      !XT_AVIP_OUT type AVIP_TT
      !XS_FEBEP type FEBEP .
  methods SET_BAPI_ACCOUNT
    importing
      !IS_BELEG type TS_BELEG
    changing
      !XT_ACCOUNT type BAPIACGL09_TAB .
  methods SET_BAPI_CURRENCY
    importing
      !IS_FEBEP type FEBEP
      !IS_BELEG type TS_BELEG
    changing
      !XT_CURRENCY type BAPIACCR09_TAB .
  methods SET_BAPI_DEBITOR
    importing
      !IS_BELEG type TS_BELEG
    changing
      !XT_DEBITOR type BAPIACAR09_TAB .
  methods SET_BAPI_HEADER
    importing
      !IS_FEBKO type FEBKO
      !IS_BELEG type TS_BELEG
      !IV_BLART type BLART
      !IS_FEBEP type FEBEP
    changing
      !XS_HEADER type BAPIACHE09 .
  methods SET_BAPI_KREDITOR
    importing
      !IS_BELEG type TS_BELEG
    changing
      !XT_KREDITOR type BAPIACAP09_TAB .
  methods SET_BSID_AVIP_OUT
    importing
      !IT_BSID type /THKR/TT_ELKO_ITEMS
      !IT_BSID_TEILZ type /THKR/TT_ELKO_ITEMS
    changing
      !XT_AVIP_OUT type AVIP_TT
      !XS_FEBEP type FEBEP
      !XV_UEBERZ type CHAR1 .
  methods SET_BSIK_AVIP_OUT
    importing
      !IT_BSIK type BSIK_TT
    changing
      !XT_AVIP_OUT type AVIP_TT
      !XS_FEBEP type FEBEP .
  methods SET_ZAHLBETRAG_KWBTR
    importing
      !IS_FEBEP type FEBEP
    changing
      !XV_KWBTR type KWBTR .
  methods SPERRE_KASSZ_KETT
    raising
      /THKR/CX_ELKO .
  methods SET_ZAHLUNGS_ABZUG
    importing
      !IS_FEBEP type FEBEP optional
    changing
      !XT_BSID type /THKR/TT_ELKO_ITEMS .
ENDCLASS.



CLASS /THKR/CL_ELKO_APPL IMPLEMENTATION.


  METHOD constructor.
  ENDMETHOD.


  METHOD create_kassenz_kette.
*Methodenaufruf im Rahmen des Fubas /THKR/KASSZ_KETTE_CREATE. Dieser ist für die Anlage von Kassenzeichenketten verantwortlich.

    DATA: lt_insert TYPE /thkr/tt_lsa_kassz_kette.

    LOOP AT it_kette ASSIGNING FIELD-SYMBOL(<ls_kette>).
      AT NEW id.
        DATA(ls_id) = <ls_kette>.
      ENDAT.
* Tabelle für das Einfügen füllen
      IF     ( <ls_kette>-id     IS NOT INITIAL
      AND      <ls_kette>-fkassz IS NOT INITIAL
      AND      <ls_kette>-wkassz IS NOT INITIAL )
      AND    ( <ls_kette>-id     EQ ls_id-id
      AND      <ls_kette>-fkassz EQ ls_id-fkassz ).
        APPEND <ls_kette> TO lt_insert.
        DATA(lv_check_ok) = abap_true.
* Die Einträge der Tabelle sollen gelöscht werden.
      ELSEIF ( <ls_kette>-id     IS NOT INITIAL
      AND      <ls_kette>-fkassz IS INITIAL
      AND      <ls_kette>-wkassz IS INITIAL ).
        CLEAR: lv_check_ok.
        DATA(lv_del_ok) = abap_true.
      ELSE.
        DATA(type) = 'E'.
        me->messages = VALUE #( BASE me->messages ( id = '/THKR/ELKO' number = 000 type = type message = 'Fehler im Kassenkettenaufbau erkannt'(003) ) ).
        IF me->messages IS NOT INITIAL.
          RAISE EXCEPTION TYPE /thkr/cx_elko EXPORTING bapiret2_tab = me->messages.
        ENDIF.
        CONTINUE.
      ENDIF.

      AT END OF id.
        SELECT COUNT(*) FROM /thkr/kassz_kett
               WHERE id EQ <ls_kette>-id.
        IF     sy-subrc EQ 0 AND lv_check_ok EQ abap_true.
* Eintrag mit ID bereits vorhanden, daher Änderung
          sperre_kassz_kett( ).

          DELETE FROM /thkr/kassz_kett WHERE id EQ <ls_kette>-id.
          MODIFY /thkr/kassz_kett FROM TABLE lt_insert.

          entsperre_kassz_kett( ).

        ELSEIF sy-subrc NE 0 AND lv_check_ok EQ abap_true.
* Eintrag wird neu angelegt.
          sperre_kassz_kett( ).

          MODIFY /thkr/kassz_kett FROM TABLE lt_insert.

          entsperre_kassz_kett( ).
        ELSEIF sy-subrc EQ 0 AND lv_del_ok EQ abap_true.
* Eintrag wird gelöscht.
          sperre_kassz_kett( ).
          DELETE FROM /thkr/kassz_kett WHERE id EQ <ls_kette>-id.
        ENDIF.
        CLEAR: ls_id,
               lv_check_ok,
               lv_del_ok,
               lt_insert.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.


  METHOD entsperre_kassz_kett.
    CALL FUNCTION 'DEQUEUE_/THKR/E_KASSZKET'
      EXPORTING
        mandt          = sy-mandt.
  ENDMETHOD.


  METHOD sperre_kassz_kett.
    CALL FUNCTION 'ENQUEUE_/THKR/E_KASSZKET'
      EXPORTING
        mandt          = sy-mandt
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      DATA(type) = 'W'.
      me->messages = VALUE #( BASE me->messages ( id = '/THKR/ELKO' number = 000 type = type message = 'Tabelle /THKR/KASSZ_KETT konnte nicht gesperrt werden'(001) ) ).
      EXIT.
    ENDIF.
    IF me->messages IS NOT INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_elko EXPORTING bapiret2_tab = me->messages.
    ENDIF.

  ENDMETHOD.


  METHOD check_avip_kblk.
* Methode zur Überprüfung von Inhalten im Rahmen der Kontoauszugsverabeitung
* Die int. Tabellen XT_AVIP_OUT und XT_KBLK dürfen nicht gleichzeitig gefüllt sein, daher Clear auf beide Tabelleninhalte.
    IF xt_avip_out IS NOT INITIAL AND xt_kblk IS NOT INITIAL.
      CLEAR: xt_avip_out,
             xt_kblk.
    ENDIF.
  ENDMETHOD.


  METHOD check_debitor.
    DATA: lv_count TYPE i.
    CLEAR: lv_count.
    SELECT COUNT(*) FROM knb1 INTO lv_count
           WHERE bukrs EQ 'T999'
           AND   kunnr EQ iv_kunnr.
    IF lv_count NE 0.
      rv_vorhanden = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD CHECK_KREDITOR.
    DATA: lv_count TYPE i.
    CLEAR: lv_count.
    SELECT COUNT(*) FROM lfb1 INTO lv_count
           WHERE bukrs EQ 'T999'
           AND   lifnr EQ iv_lifnr.
    IF lv_count NE 0.
      rv_vorhanden = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD check_pruefziffern.
* Methode zur Prüfung auf gültige Prüfziffern
    DATA: lv_pruefziffer TYPE c,
          lv_kassenz     TYPE /thkr/d_kassenzeichen,
          lv_strlen      TYPE i.
* Die int. Tabelle enthält alle potentiellen Kassenzeichen, nur gültige dürfen in die weitere Verarbeitung gehen.
    IF xt_kassz IS NOT INITIAL.
      LOOP AT xt_kassz ASSIGNING FIELD-SYMBOL(<ls_kassz>).
* Nur numerische Kassenzeichen werden geprüft.
        CHECK <ls_kassz>-xblnr(13) CO '0123456789'.
        CLEAR: lv_pruefziffer, lv_kassenz, lv_strlen.
        lv_strlen = strlen( <ls_kassz> ).
        lv_kassenz = <ls_kassz>-xblnr.
        CHECK lv_strlen LT 13.

        /thkr/cl_kassenzeichen=>get_pruefziffer( EXPORTING i_kaz         = lv_kassenz
                                                 IMPORTING e_pruefziffer = lv_pruefziffer ).
        IF lv_pruefziffer IS NOT INITIAL.
          DATA(lv_anzahl) = strlen( lv_kassenz ).
          lv_anzahl = lv_anzahl - 1.
          IF lv_pruefziffer NE lv_kassenz+lv_anzahl(1).
* Ungültige Kassenzeichen werden entfernt.
            DELETE TABLE xt_kassz FROM <ls_kassz>.
            CLEAR: lv_anzahl.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD CONVERT_VERWENDUNGSZWECK_ANUM.
* Konvertierungsmethode bei alphanumerischen Einträge im Verwendungszweck
    DATA(lv_convert2) = /thkr/cl_elko_helpers=>convert_string( iv_convert_name   = 'CONVERT2' ).
    TRANSLATE xv_vwezw USING lv_convert2.
    CONDENSE  xv_vwezw NO-GAPS.
  ENDMETHOD.


  METHOD convert_verwendungszweck_num.
* Konvertierungsmethode bei numerischen Einträge im Verwendungszweck
    IF iv_suchm IS INITIAL.
      DATA(lv_convert1) = /thkr/cl_elko_helpers=>convert_string( iv_convert_name   = 'CONVERT1' ).
      TRANSLATE xv_vwezw USING lv_convert1.
      DATA(lv_convert2) = /thkr/cl_elko_helpers=>convert_string( iv_convert_name   = 'CONVERT2' ).
      TRANSLATE xv_vwezw USING lv_convert2.
    ELSE.
      DATA(lv_convert3) = /thkr/cl_elko_helpers=>convert_string( iv_convert_name   = 'CONVERT3' ).
      TRANSLATE xv_vwezw USING lv_convert3.
      CONDENSE  xv_vwezw NO-GAPS.
    ENDIF.
  ENDMETHOD.


  METHOD free_memory_id.
* Methode zum Initialisieren von Memorys, diese wurden im Rahmen der Einzelverarbeitung von Kontoauszugsvorgängen gefüllt.
* Es soll sichgestellt werden, dass keine Inhalte auf folgende Verarbeitungsschritte ungewollt übertragen werden.
    FREE MEMORY ID 'ELKO_OK'.
    FREE MEMORY ID 'AVIP_OUT'.
    FREE MEMORY ID 'LT_BSID'.
    FREE MEMORY ID 'ELKO_KBLK'.
    FREE MEMORY ID 'ELKO_UEBERZ'.
    FREE MEMORY ID 'ZAHLBETRAG'.
    FREE MEMORY ID 'TEILZ_DEBI'.
    FREE MEMORY ID 'ITEM_ANZ'.
    FREE MEMORY ID 'DISPLAY'.
    FREE MEMORY ID 'VWEZW'.
ENDMETHOD.


  METHOD get_bsid_aus_kassenz.
* Methode zur Ermittlung von offenen debitorischen Posten auf Basis gefundener Kassenzeichen.

    CHECK iv_gebkz IS INITIAL.
    CLEAR: xt_bsid.
* Die Kassenzeichen wurden im Vorfeld gefunden und auf Plausibilität geprüft.
    IF it_kassz IS NOT INITIAL.
      SELECT kunnr,
             bukrs,
             belnr,
             gjahr,
             buzei,
             manst,
             maber,
             blart,
             budat,
             shkzg,
             wrbtr,
             waers,
             xblnr,
             zfbdt,
             rebzg,
             rebzj,
             rebzz
             FROM  bsid_view INTO CORRESPONDING FIELDS OF TABLE @xt_bsid
             FOR ALL ENTRIES IN @it_kassz
             WHERE xblnr = @it_kassz-xblnr
             AND blart <> 'DZ'
             AND zlspr <> 'E'
             AND umskz <> 'A'.
      IF sy-subrc EQ 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_bsid_aus_referenz.
* Methode zur Ermittlung von bereits getätigten Teilzahlungen.
* Von Relevanz sind hier offene Posten der Belegart DZ
    CHECK iv_gebkz IS INITIAL.
    DATA(lt_bsid) = it_bsid.
    IF lt_bsid IS NOT INITIAL AND it_kassz IS NOT INITIAL.
      SELECT kunnr,
             bukrs,
             belnr,
             gjahr,
             buzei,
             manst,
             maber,
             blart,
             budat,
             shkzg,
             wrbtr,
             waers,
             xblnr,
             zfbdt,
             rebzg,
             rebzj,
             rebzz
             FROM  bsid_view APPENDING CORRESPONDING FIELDS OF TABLE @xt_bsid_teilz
             FOR ALL ENTRIES IN @lt_bsid
             WHERE bukrs = @lt_bsid-bukrs
             AND   rebzg = @lt_bsid-belnr
             AND   rebzj = @lt_bsid-gjahr
             AND   rebzz = @lt_bsid-buzei
             AND   blart EQ 'DZ'
             AND   zlspr NE 'E'.
    ENDIF.
    IF sy-subrc EQ 0.
      LOOP AT xt_bsid_teilz ASSIGNING FIELD-SYMBOL(<ls_bsid>).
        READ TABLE it_kassz TRANSPORTING NO FIELDS
                   WITH KEY  xblnr = <ls_bsid>-xblnr.
        IF sy-subrc NE 0.
          DELETE xt_bsid_teilz.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD get_bsik_aus_kassenz.
* Methode zur Ermittlung von offenen kreditorischen Posten auf Basis gefundener Kassenzeichen.

    CLEAR: xt_bsik.
* Die Kassenzeichen wurden im Vorfeld gefunden und auf Plausibilität geprüft.

    IF it_kassz IS NOT INITIAL.
      SELECT lifnr,
             bukrs,
             belnr,
             gjahr,
             buzei,
             manst,
             maber,
             blart,
             budat,
             shkzg,
             wrbtr,
             waers,
             xblnr,
             zfbdt,
             rebzg,
             rebzj,
             rebzz
             FROM  bsik_view
             INTO CORRESPONDING FIELDS OF TABLE @xt_bsik
             FOR ALL ENTRIES IN @it_kassz
             WHERE xblnr EQ @it_kassz-xblnr
             AND   umskz NE 'A'.
      IF sy-subrc EQ 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_debitor_from_knb1.
    CLEAR: xt_knb1.
    IF iv_bukrs EQ 'T999' OR iv_bukrs IS INITIAL.
      SELECT * FROM knb1 INTO TABLE xt_knb1
                   UP TO 1 ROWS
                   WHERE kunnr EQ iv_kunnr.
    ELSE.
      SELECT * FROM knb1 INTO TABLE xt_knb1
             UP TO 1 ROWS
             WHERE bukrs EQ iv_bukrs
             AND   kunnr EQ iv_kunnr.
    ENDIF.
  ENDMETHOD.


  METHOD get_gebkz.
* Methode zur Ermittlung des Kassenzeichens (XBLNR) oder der Kontiervorlage ACCTMP auf Basis von Einträgen in der
* DB-Tabelle /thkr/verw_kz
    DATA:
      lv_xblnr  TYPE xblnr,
      lv_vozei2 TYPE vozpm_eb.

    CLEAR: xv_gebkz, xv_acctmp.

    IF is_febep-epvoz = 'S'.
      lv_vozei2 = '-'.
    ELSE.
      lv_vozei2 = '+'.
    ENDIF.

    SELECT SINGLE xblnr
                  acctmp
                        FROM /thkr/verw_kz INTO (lv_xblnr,xv_acctmp)
                        WHERE bukrs  = is_febko-bukrs AND
                              hbkid  = is_febko-hbkid AND
                              hktid  = is_febko-hktid AND
                              vgext  = is_febep-vgext AND
                              vozpm  = lv_vozei2.
    IF sy-subrc NE 0.
      CLEAR: lv_xblnr, xv_acctmp.
* Ist schon eine Kontiervorlage vorhanden?
      IF    is_febko-kukey IS NOT INITIAL
      AND   is_febep-esnum IS NOT INITIAL.
        SELECT acctmp FROM feb_accnt_save INTO xv_acctmp
                    UP TO 1 ROWS
                    WHERE kukey EQ is_febko-kukey
                    AND   esnum EQ is_febep-esnum.
        ENDSELECT.
      ENDIF.
    ELSE.
      IF lv_xblnr IS NOT INITIAL AND xv_acctmp IS INITIAL.
        APPEND lv_xblnr TO xt_kassz.
        xv_gebkz = abap_true.
      ELSEIF lv_xblnr IS INITIAL AND xv_acctmp IS NOT INITIAL.
        CLEAR: xv_gebkz.
      ENDIF.
    ENDIF.

    SORT xt_kassz.
    DELETE ADJACENT DUPLICATES FROM xt_kassz.
  ENDMETHOD.


  METHOD get_kassenz_aus_febre.
* Methode zum Extrahieren von Kassenzeichen aus dem Verwendungszweck. Der Verwendungszweck befindet sich im String des Übergabeparameters iv_vwezw.
* In der Übergabe können sich keine, ein oder mehrere Kassenzeichen unterschiedlichen Formates befinden.
    DATA: lv_vwezw TYPE char30k.

    lv_vwezw = iv_vwezw.

* 1. replace strange characters
    CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
      EXPORTING
        intext  = lv_vwezw
      IMPORTING
        outtext = lv_vwezw
      EXCEPTIONS
        OTHERS  = 01.
    IF sy-subrc EQ 0.
      TRANSLATE lv_vwezw TO UPPER CASE.
    ENDIF.


*2. Numerische Kassenzeichen ermitteln
    search_kassenz_numeric( EXPORTING iv_vwezw = lv_vwezw
                            CHANGING  xt_kassz = xt_kassz ).

*3. Alphanumerische Kassenzeichen ermitteln
    search_kassenz_alphanum( EXPORTING iv_vwezw = lv_vwezw
                             CHANGING  xt_kassz = xt_kassz ).

* 3 Zusätzliche Kassenzeichen aus Tabelle /THKR/T_KASSZ_KETT übernehmen
    search_kassenz_aus_kette( CHANGING  xt_kassz = xt_kassz ).


  ENDMETHOD.


  METHOD get_kassenz_aus_gebkz.
* Methode hat zweierlei Funktionen 1. Ermittlung des Kassenzeichens (XBLNR), falls dieses in der Tabelle /thkr/verw_kz gespeichert wurde und
* 2. Ermittlung der Kontiervorlage.
    DATA: ls_febko TYPE febko,
          ls_febep TYPE febep.
    IF iv_kukey IS NOT INITIAL.
      SELECT * FROM febko INTO ls_febko
               UP TO 1 ROWS
               WHERE kukey = iv_kukey.
      ENDSELECT.

      SELECT * FROM febep INTO ls_febep
               UP TO 1 ROWS
               WHERE  kukey = iv_kukey
               and    esnum = iv_esnum.
      ENDSELECT.
    ELSE.
      read_elko_tabellen( CHANGING xs_febko = ls_febko
                                   xs_febep = ls_febep ).
    ENDIF.

    get_gebkz( EXPORTING is_febko  = ls_febko
                         is_febep  = ls_febep
               CHANGING  xt_kassz  = xt_kassz
                         xv_gebkz  = xv_gebkz
                         xv_acctmp = xv_acctmp ).
  ENDMETHOD.


  METHOD get_kassenz_suchm.
* Methode zur Ermittlung von Kassenzeichen (XBLNR) anhand von Suchmustern. In der DB-Tabelle /THKR/ELKO_SUCHM werden die Suchstrings definiert, mittels derer der Verwendungszweck durchsucht wird.
* Bei entsprechend gefundenen Kassenzeichen, werde diese in die int. Tabelle XT_KASSZ übertragen.

    DATA: lv_vwezw TYPE char30k,
          lv_vlen  TYPE i,
          lv_blen  TYPE i,
          lv_klen  TYPE i,
          lv_start TYPE i,
          lv_res   TYPE i,
          lv_kz    TYPE xfeld,
          lv_kassz TYPE string,
          ls_suchm TYPE /thkr/elko_suchm,
          ls_kassz TYPE /thkr/s_kassenz.

    CONSTANTS:
          c_convert1 TYPE char6 VALUE './-'.

    lv_vwezw = iv_vwezw.

* 1. replace strange characters
    CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
      EXPORTING
        intext  = lv_vwezw
      IMPORTING
        outtext = lv_vwezw
      EXCEPTIONS
        OTHERS  = 01.
    IF sy-subrc EQ 0.
      TRANSLATE lv_vwezw TO UPPER CASE.
    ENDIF.

    convert_verwendungszweck_num( EXPORTING iv_suchm = abap_true
                                  CHANGING  xv_vwezw = lv_vwezw ).

    SELECT * FROM /thkr/elko_suchm INTO TABLE @DATA(lt_suchm).

    lv_vlen = strlen( lv_vwezw ).
    LOOP AT lt_suchm ASSIGNING FIELD-SYMBOL(<ls_sm>).

      IF <ls_sm>-begriff = '?' .
        ls_suchm = <ls_sm>.
        CONTINUE.
      ELSE.
*       Suche nach Begriff
        IF lv_vlen = 0.
          EXIT.
        ENDIF.

        IF <ls_sm>-begriff CA '%'.
          lv_kz = 'X'.
          TRANSLATE <ls_sm>-begriff USING '% '.  "numofchar
        ELSE.
          CLEAR lv_kz.
        ENDIF.

        lv_res = find( val  = lv_vwezw
                       sub  = <ls_sm>-begriff
                       off  = lv_start
                       len  = lv_vlen
                       occ  = 1
                       case = abap_false ).
        IF lv_res = -1.
          CONTINUE.
        ENDIF.
        lv_blen = strlen( <ls_sm>-begriff ).
        lv_res = lv_res + lv_blen.

        IF lv_kz = 'X'.
          WHILE lv_vwezw+lv_res(1) NA '0123456789'.
            lv_res = lv_res + 1.
            IF lv_res >= lv_vlen.
              EXIT.
            ENDIF.
          ENDWHILE.
        ENDIF.
      ENDIF.

*     Kassenzeichen:
      CLEAR lv_kassz.
      WHILE lv_vwezw+lv_res(1) CA '0123456789 .-/'.
        CONCATENATE lv_kassz lv_vwezw+lv_res(1) INTO lv_kassz.
        lv_res = lv_res + 1.
        IF lv_res >= lv_vlen.
          EXIT.
        ENDIF.
      ENDWHILE.

* ggf sind mehrere Leerzeichen vorhanden, die werden ignoriert
      TRANSLATE lv_kassz USING c_convert1.
      CONDENSE lv_kassz NO-GAPS.

      lv_klen = strlen( lv_kassz ).
      IF lv_klen < <ls_sm>-kzlmin OR lv_klen > <ls_sm>-kzlmax.
        CLEAR: lv_klen, lv_kassz.
        CONTINUE.
      ELSE.
*--------------------------------------------------------------------------*
* Kassenzeichen aus Begriff und Ziffernfolge
*--------------------------------------------------------------------------*
        IF lv_kassz IS NOT INITIAL.
          ls_kassz-xblnr = lv_kassz.
          APPEND ls_kassz TO xt_kassz.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SORT xt_kassz.
    DELETE ADJACENT DUPLICATES FROM xt_kassz.

  ENDMETHOD.


  METHOD get_kblk_901_kassenz.
* Methode zum Selektieren von Annahmeanordnungen. Belegart AN
    CLEAR: xt_kblk.
    IF it_kassz IS NOT INITIAL.
      SELECT belnr,
             blart,
             xblnr FROM kblk
                   FOR ALL ENTRIES IN @it_kassz
                   WHERE  xblnr = @it_kassz-xblnr
                   AND  ( blart = 'AN'
                   OR     blart = 'V0' )
                   AND    wkapk = 'X'
                   AND    fexec IS INITIAL
             INTO TABLE @xt_kblk.
      IF sy-subrc NE 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD GET_KBLK_902_KASSENZ.
* Methode zum Selektieren von Annahmeanordnungen.Belegart AU
    CLEAR: xt_kblk.
    IF it_kassz IS NOT INITIAL.
      SELECT belnr,
             blart,
             xblnr FROM kblk
                   FOR ALL ENTRIES IN @it_kassz
                   WHERE xblnr = @it_kassz-xblnr
                   AND  ( blart = 'AU'
                   OR     blart = 'A0' )  " 2026-03-16 js INC08893587: auch für blart = 'A0'
                   and   wkapk = 'X'
                   AND   fexec IS INITIAL
             INTO TABLE @xt_kblk.
      IF sy-subrc NE 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_kreditor_from_lfb1.
    CLEAR: xt_lfb1.
    IF iv_bukrs EQ 'T999' OR iv_bukrs IS INITIAL.
      SELECT * FROM lfb1 INTO TABLE xt_lfb1
                   UP TO 1 ROWS
                   WHERE lifnr EQ iv_lifnr.
    ELSE.
      SELECT * FROM lfb1 INTO TABLE xt_lfb1
             UP TO 1 ROWS
             WHERE bukrs EQ iv_bukrs
             AND   lifnr EQ iv_lifnr.
    ENDIF.
  ENDMETHOD.


  METHOD insert_feb_accnt_save.
* Methode zur Speicher von Kontierungsvorlagen

    DATA: ls_accnt          TYPE feb_bsproc_acc_assign,
          ls_feb_accnt_save TYPE feb_accnt_save,
          lt_feb_accnt_save TYPE TABLE OF feb_accnt_save.

    IF iv_acctmp IS NOT INITIAL.
      CHECK cl_feb_bsproc_acc_ass_storage=>check_existing_data( EXPORTING i_kukey = iv_kukey
                                                                          i_esnum = iv_esnum ) = abap_false.
      CLEAR: lt_feb_accnt_save.

      SELECT * FROM feb_act INTO @DATA(ls_feb_act)
        UP TO 1 ROWS
        WHERE acctmp = @iv_acctmp.

        CLEAR: ls_feb_accnt_save.
        MOVE-CORRESPONDING ls_feb_act TO ls_feb_accnt_save.
        SELECT SINGLE kwbtr FROM febep INTO ls_feb_accnt_save-wrbtr
                            WHERE kukey = iv_kukey
                            AND   esnum = iv_esnum.

        APPEND ls_feb_accnt_save TO lt_feb_accnt_save.

        cl_feb_bsproc_acc_ass_storage=>delete_data( i_kukey = iv_kukey
                                                    i_esnum = iv_esnum ).

        cl_feb_bsproc_acc_ass_storage=>insert_data( it_acc_assign_line = lt_feb_accnt_save ).

        IF lt_feb_accnt_save IS NOT INITIAL.
          LOOP AT lt_feb_accnt_save ASSIGNING FIELD-SYMBOL(<ls_accnt>).
            CLEAR: ls_accnt.
            MOVE-CORRESPONDING <ls_accnt> TO ls_accnt.
            APPEND ls_accnt TO xt_assign_line.
          ENDLOOP.
        ENDIF.
      ENDSELECT.
    ENDIF.
  ENDMETHOD.


  METHOD read_elko_tabellen.
* Methode für die Ermittlung der Kontoauszugstabellen FEBKÓ und FEBEP
* Zwei Möglichkeiten
* 1. Ermittlung im Rahmen des Echtlaufes, also beim Einlesen oder Nachbearbeiten eines Kontoauszuges. In diesem Fall findet die Ermittlung über den Befehl '(RFEBBU10)feb##' statt
* 2. Ermittlung während des Testlaufes, als Aufruf aus dem Testreport. Hierfür werden die Memorys ausgelesen
    DATA: lv_data TYPE char70,
          lv_test TYPE char1,
          lv_elko TYPE char1.

* Access to FEBEP because of missing in the interface
    FIELD-SYMBOLS: <ls_febko> TYPE febko,
                   <ls_febep> TYPE febep.

    CLEAR: xs_febko, xs_febep.
    import_memory test lv_test  'ELKO_TEST'.
    import_memory elko lv_elko  'ELKO_TAB'.

    IF lv_test IS INITIAL.
      lv_data = '(RFEBBU10)febep'.
      ASSIGN (lv_data) TO <ls_febep>.
      lv_data = '(RFEBBU10)febko'.
      ASSIGN (lv_data) TO <ls_febko>.
      IF <ls_febep> IS NOT ASSIGNED.
        DATA(type) = 'E'.
        me->messages = VALUE #( BASE me->messages ( id = '/THKR/ELKO' number = 000 type = type message = 'Fehler in der Zuweisung der Struktur <LS_FEBEP>'(002) ) ).
      ELSE.
        xs_febko = <ls_febko>.
        xs_febep = <ls_febep>.
      ENDIF.
    ELSE.
      IF lv_elko IS NOT INITIAL.
        import_memory febko xs_febko 'FEBKO_901'.
        import_memory febep xs_febep 'FEBEP_901'.
      ENDIF.
    ENDIF.

    CLEAR xs_febep-avkon.   "2026-03-18 Ketten müssen über mehrere Deb. gelesen werden
    CLEAR xs_febep-xblnr.   "2026-04-10 Kassenzeichen zwecks Neubestimmung leer machen
  ENDMETHOD.


  METHOD save_avis_db.
* Methode zur Anlage eines Zahlungsavises bei Teilzahlungen. Der Methodenaufruf erfolgt über den User-Exit des Fuba's EXIT_RFEBBU10_001 und dem inkludierten Report ZXF01U01
* Die Ausführung erlolgt lediglich beim Einlesen einer Umsatzdatei mittels Transaktion FF_5 im Echtlauf.
* Vorrangiges Ergebnis ist die Erstellung der Avisenunner, diese wird für spätere Verabeitungsschritte von hoher Relevanz.

    DATA: lv_elko   TYPE c,
          lv_teilz  TYPE c,
          lv_data   TYPE char70,
          ls_avik   TYPE avik,
          ls_avir   TYPE avir,
          lt_avip   TYPE avip_tt,
          lt_avir   TYPE avir_tt,
          lv_kwbtr  TYPE kwbtr,
          ls_rfradc TYPE rfradc.

    FIELD-SYMBOLS: <ls_febep> TYPE febep.

    CONSTANTS: lc_tcode TYPE sy-tcode    VALUE 'FF5_TEILZ',
               lc_avsrt TYPE avik-avsrt  VALUE '03'.

* Durchlauf nur beim Einlesen des Kontoauszuges und Teilzahlung im Echtlauf.
    import_memory elko_ok lv_elko   'ELKO_OK'.
    import_memory lt_avip lt_avip   'AVIP_OUT'.
    import_memory lv_teilz lv_teilz 'TEILZ_DEBI'.
    import_memory lv_zahlb lv_kwbtr 'ZAHLBETRAG'.

    CHECK lt_avip IS NOT INITIAL AND lv_teilz IS NOT INITIAL.

    IF  lv_elko        EQ abap_true
    AND lt_avip        IS NOT INITIAL
    AND lv_teilz       IS NOT INITIAL
    AND is_febep-avsid IS INITIAL.
* AVIK füllen
      READ TABLE lt_avip ASSIGNING FIELD-SYMBOL(<ls_avip>)
                 INDEX 1.
      IF sy-subrc EQ 0.
        CLEAR: ls_avik.
        ls_avik-bukrs = <ls_avip>-bukrs.
        ls_avik-koart = <ls_avip>-koart.
        ls_avik-konto = <ls_avip>-konto.
        ls_avik-tcode = lc_tcode.
        ls_avik-waers = <ls_avip>-waers.
        ls_avik-rwbtr = lv_kwbtr.
        ls_avik-ernam = sy-uname.
        ls_avik-erdat = sy-datum.
        ls_avik-avsrt = lc_avsrt.

        DESCRIBE TABLE lt_avip LINES sy-tfill.
        CLEAR ls_rfradc.
        MOVE-CORRESPONDING ls_avik TO ls_rfradc.            "#EC ENHOK
        ls_rfradc-avspo = sy-tfill.
        ls_rfradc-xdark = abap_true.
        ls_rfradc-xintn = abap_true.
      ENDIF.

      LOOP AT lt_avip ASSIGNING <ls_avip>
            WHERE diffw NE 0.
        CLEAR: ls_avir.
        ls_avir-bukrs = <ls_avip>-bukrs.
        ls_avir-koart = <ls_avip>-koart.
        ls_avir-konto = <ls_avip>-konto.
        ls_avir-avspo = <ls_avip>-avspo.
        ls_avir-avsup = '00001'.
        ls_avir-restn = <ls_avip>-diffw.
        ls_avir-restb = <ls_avip>-diffw.
        APPEND ls_avir TO lt_avir.
      ENDLOOP.
      IF ls_avik IS NOT INITIAL AND lt_avip IS NOT INITIAL AND lt_avir IS NOT INITIAL.
* Speichern der DB-Tabellen AVIK, AVIP
        CALL FUNCTION 'REMADV_INSERT'
          EXPORTING
            i_avik              = ls_avik
            i_rfradc            = ls_rfradc
          TABLES
            t_avip              = lt_avip
*           T_AVIR              =
          EXCEPTIONS
            error               = 1
            no_number_entered   = 2
            no_authority        = 3
            already_existing    = 4
            company_not_defined = 5
            country_not_defined = 6
            OTHERS              = 7.
        IF sy-subrc EQ 0.
* Commit Work, um DB-Inhalte auf der Datenbank zu speichern.
          CALL FUNCTION 'REMADV_SAVE_DB_ALL'
            EXPORTING
              i_dialog_update = 'X'
              i_commit        = 'X'.

          READ TABLE lt_avip ASSIGNING <ls_avip>
                     INDEX 1.
          IF sy-subrc EQ 0.
            lv_data = '(RFEBBU10)febep'.
            ASSIGN (lv_data) TO <ls_febep>.
            <ls_febep>-avsid = <ls_avip>-avsid.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD search_kassenz_alphanum.
* Ermittlung von potentiellen Kassenzeichen mit alpanumerischem Aufbau des Verwendungszweckes
    DATA: lv_len     TYPE char30,
          lv_moff    TYPE i,
          lv_places  TYPE i,
          ls_kassz   TYPE /thkr/s_kassenz,
          ls_kasspra TYPE /thkr/kasspraefi,
          lv_regex   TYPE string,
          lt_matches TYPE TABLE OF match_result,
          lv_praefix TYPE char2,
          lv_zahl1   TYPE string,
          lv_zahl2   TYPE string,
          lv_substr  TYPE string,
          lt_kasspra TYPE TABLE OF /thkr/kasspraefi.

    DATA(lv_vwezw) = iv_vwezw.
* ED Belege filtern.
    me->convert_verwendungszweck_anum( CHANGING xv_vwezw = lv_vwezw ).

    DO.
      lv_len = strlen( lv_vwezw ).
      IF lv_len EQ 0.
        EXIT.
      ENDIF.
      FIND PCRE 'ED-[0-9]{8}[-A-Za-z]{1}[0-9]{4}' IN lv_vwezw MATCH OFFSET lv_moff.
      IF sy-subrc EQ 0.
        DATA(lv_xblnr) = lv_vwezw+lv_moff(16).
        ls_kassz-xblnr = lv_xblnr.
        APPEND ls_kassz TO xt_kassz.
        lv_places = lv_moff + 16.
        SHIFT lv_vwezw BY lv_places PLACES.
        CLEAR: lv_xblnr,
               lv_places,
               lv_moff,
               ls_kassz.
      ELSE.
        SHIFT lv_vwezw BY 1 PLACES.
        CONTINUE.
      ENDIF.
    ENDDO.

* Dynamische Belege filtern.
    CLEAR:  lv_vwezw.
    lv_vwezw = iv_vwezw.
    me->convert_verwendungszweck_anum( CHANGING xv_vwezw = lv_vwezw ).

    SELECT * FROM /thkr/kasspraefi INTO TABLE lt_kasspra.

    LOOP AT lt_kasspra INTO ls_kasspra.
      SPLIT ls_kasspra-praefix AT ';' INTO lv_praefix
                                           lv_zahl1
                                           lv_zahl2.

      " Beispiel: Präfix + '-' + 4 Ziffern + '-' + 6 Ziffern
      " Die 4 und 6 stammen aus den Feldern in der Tabelle, Beispiel 4 und 6
      " Dynamischen regulären Ausdruck erzeugen:
      lv_regex = lv_praefix && '-' && '\d{' && lv_zahl1 && '}' && '-' && '\d{' && lv_zahl2 && '}'.

      " Nun Suche mit PCRE
      FIND ALL OCCURRENCES OF REGEX lv_regex IN lv_vwezw
           RESULTS lt_matches.

      " Gefundene Einträge in interne Tabelle speichern
      LOOP AT lt_matches ASSIGNING FIELD-SYMBOL(<ls_match>).
        lv_substr = lv_vwezw+<ls_match>-offset(<ls_match>-length).
        ls_kassz-xblnr = lv_substr.
        APPEND ls_kassz TO xt_kassz.
      ENDLOOP.
      CLEAR: lv_praefix, lv_zahl1, lv_zahl2.
    ENDLOOP.


    DO.
      lv_len = strlen( lv_vwezw ).
      IF lv_len EQ 0.
        EXIT.
      ENDIF.
      FIND PCRE 'AA-[0-9]{4}\-[0-9]{6}' IN lv_vwezw MATCH OFFSET lv_moff.
      IF sy-subrc EQ 0.
        lv_xblnr       = lv_vwezw+lv_moff(14).
        ls_kassz-xblnr = lv_xblnr.
        APPEND ls_kassz TO xt_kassz.
        lv_places = lv_moff + 14.
        SHIFT lv_vwezw BY lv_places PLACES.
        CLEAR: lv_xblnr,
               lv_places,
               lv_moff,
               ls_kassz.
      ELSE.
        SHIFT lv_vwezw BY 1 PLACES.
        CONTINUE.
      ENDIF.
    ENDDO.

* Hamissa Kassenzeichen filtern
    CLEAR: lv_vwezw.
    lv_vwezw = iv_vwezw.
    me->convert_verwendungszweck_anum( CHANGING xv_vwezw = lv_vwezw ).

    DO.
      lv_len = strlen( lv_vwezw ).
      IF lv_len EQ 0.
        EXIT.
      ENDIF.
      FIND PCRE '[0-9]{4}\-[0-9]{6}\-[0-9]{1}' IN lv_vwezw MATCH OFFSET lv_moff.
      IF sy-subrc EQ 0.
        lv_xblnr       = lv_vwezw+lv_moff(13).
        ls_kassz-xblnr = lv_xblnr.
        APPEND ls_kassz TO xt_kassz.
        lv_places = lv_moff + 13.
        SHIFT lv_vwezw BY lv_places PLACES.
        CLEAR: lv_xblnr,
               lv_places,
               lv_moff,
               ls_kassz.
      ELSE.
        SHIFT lv_vwezw BY 1 PLACES.
        CONTINUE.
      ENDIF.
    ENDDO.

    CLEAR: lv_vwezw.
    lv_vwezw = iv_vwezw.
    me->convert_verwendungszweck_anum( CHANGING xv_vwezw = lv_vwezw ).

    DO.
      lv_len = strlen( lv_vwezw ).
      IF lv_len EQ 0.
        EXIT.
      ENDIF.
      FIND PCRE '[0-9]{4}\-[A-Z][0-9]{5}\-[0-9]{1}' IN lv_vwezw MATCH OFFSET lv_moff.
      IF sy-subrc EQ 0.
        lv_xblnr       = lv_vwezw+lv_moff(13).
        ls_kassz-xblnr = lv_xblnr.
        APPEND ls_kassz TO xt_kassz.
        lv_places = lv_moff + 13.
        SHIFT lv_vwezw BY lv_places PLACES.
        CLEAR: lv_xblnr,
               lv_places,
               lv_moff,
               ls_kassz.
      ELSE.
        SHIFT lv_vwezw BY 1 PLACES.
        CONTINUE.
      ENDIF.
    ENDDO.

    SORT xt_kassz.
    DELETE ADJACENT DUPLICATES FROM xt_kassz.
  ENDMETHOD.


  METHOD search_kassenz_aus_kette.
* Ermittlung von potentiellen verketteten Kassenzeichen
    DATA: lv_data  TYPE char70,
          lv_test  TYPE char1,
          ls_kassz TYPE /thkr/s_kassenz.
***    LOOP AT xt_kassz ASSIGNING FIELD-SYMBOL(<ls_kassz>).
***      CLEAR: ls_kassz.
***      MOVE-CORRESPONDING <ls_kassz> TO ls_kassz.
***
***      SELECT wkassz FROM /thkr/kassz_kett INTO ls_kassz-xblnr
***               WHERE fkassz = <ls_kassz>-xblnr.
***        APPEND ls_kassz TO xt_kassz.
***      ENDSELECT.
***    ENDLOOP.
* 2025-09-23 jseifert > Umstellung auf mengenorientiertes Select
*                       (ohne Gefahr einer Endlosschleife)
    IF xt_kassz[] IS NOT INITIAL.
      SELECT wkassz AS xblnr
        FROM /thkr/kassz_kett
         FOR ALL ENTRIES IN @xt_kassz
       WHERE fkassz = @xt_kassz-xblnr
        INTO TABLE @DATA(lt_wkassz).
      IF sy-subrc = 0.
        APPEND LINES OF lt_wkassz TO xt_kassz.

*       2026-03-18 js INC08889312 - Änd. 20286/2026 FEBAN - Anzeige der Kette auf FEBEP-ZZ_AVVISO
        import_memory test lv_test  'ELKO_TEST'.

        FIELD-SYMBOLS: <ls_febep> TYPE febep.
        IF lv_test IS INITIAL.
          lv_data = '(RFEBBU10)febep'.
          ASSIGN (lv_data) TO <ls_febep>.
          IF <ls_febep> IS ASSIGNED.
            <ls_febep>-zz_avviso = 'K'.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD search_kassenz_numeric.
* Ermittlung von potentiellen Kassenzeichen mit numerischem Aufbau des Verwendungszweckes
    DATA: lv_len      TYPE char30,
          lv_moff     TYPE i,
          lv_places   TYPE i,
          lv_xblnr    TYPE xblnr,
          ls_kassz    TYPE /thkr/s_kassenz.

    DATA(lv_vwezw) = iv_vwezw.
    me->convert_verwendungszweck_num( CHANGING xv_vwezw = lv_vwezw ).
* Rein numerische Kassenzeichen
    DO.
      lv_len = strlen( lv_vwezw ).
      IF lv_len EQ 0.
        EXIT.
      ENDIF.
      FIND PCRE '[0-9]{13}' IN lv_vwezw MATCH OFFSET lv_moff.
      IF sy-subrc EQ 0 AND lv_vwezw+0(13) CO '0123456789'.
        lv_xblnr       = lv_vwezw+lv_moff(13).
        ls_kassz-xblnr = lv_xblnr.
        APPEND ls_kassz TO xt_kassz.
        lv_places = lv_moff + 1.
        SHIFT lv_vwezw BY lv_places PLACES.
        CLEAR: lv_xblnr,
               lv_places,
               lv_moff,
               ls_kassz.
      ELSE.
        SHIFT lv_vwezw BY 1 PLACES.
        CONTINUE.
      ENDIF.
    ENDDO.
* 93 er Belege filtern.
    CLEAR lv_vwezw.
    lv_vwezw = iv_vwezw.
    me->convert_verwendungszweck_num( CHANGING xv_vwezw = lv_vwezw ).

    DO.
      lv_len = strlen( lv_vwezw ).
      IF lv_len EQ 0.
        EXIT.
      ENDIF.
      FIND PCRE '93[0-9]{11}' IN lv_vwezw MATCH OFFSET lv_moff.
      IF sy-subrc EQ 0 AND lv_vwezw+lv_moff(13) CO '0123456789'.
        lv_xblnr       = lv_vwezw+lv_moff(13).
        ls_kassz-xblnr = lv_xblnr.
        APPEND ls_kassz TO xt_kassz.
        lv_places = lv_moff + 13.
        SHIFT lv_vwezw BY lv_places PLACES.
        CLEAR: lv_xblnr,
               lv_places,
               lv_moff,
               ls_kassz.
      ELSE.
        SHIFT lv_vwezw BY 1 PLACES.
        CONTINUE.
      ENDIF.
    ENDDO.
    SORT xt_kassz.
    DELETE ADJACENT DUPLICATES FROM xt_kassz.
  ENDMETHOD.


  METHOD search_kassenz_ueb_belnr.
* Ermittlung von potentiellen Kassenzeichen mit alpanumerischem Aufbau des Verwendungszweckes
    DATA: lv_len    TYPE char30,
          lv_moff   TYPE i,
          lv_places TYPE i,
          lv_str    TYPE char30.
    DATA: BEGIN OF ls_str,
            bez  TYPE char2,
            num1 TYPE char2,
            num2 TYPE char2,
          END   OF ls_str.

    DATA: lv_vwezw TYPE char30k,
          lv_xblnr TYPE char18.

    CLEAR: lv_vwezw.
    lv_vwezw = iv_vwezw.
    me->convert_verwendungszweck_anum( CHANGING xv_vwezw = lv_vwezw ).

    DO.
      lv_len = strlen( lv_vwezw ).
      IF lv_len EQ 0.
        EXIT.
      ENDIF.
      FIND PCRE 'T[0-9]{17}' IN lv_vwezw MATCH OFFSET lv_moff.
      IF sy-subrc EQ 0.
        lv_xblnr       = lv_vwezw+lv_moff(18).
        IF lv_xblnr+0(1) EQ 'T'.
          APPEND lv_xblnr TO xt_kassz.
        ENDIF.
        lv_places = lv_moff + 18.
        SHIFT lv_vwezw BY lv_places PLACES.
        CLEAR: lv_xblnr,
               lv_places,
               lv_moff.

      ELSE.
        SHIFT lv_vwezw BY 1 PLACES.
        CONTINUE.
      ENDIF.
    ENDDO.

    SORT xt_kassz.
    DELETE ADJACENT DUPLICATES FROM xt_kassz.
  ENDMETHOD.


  METHOD set_avip_901_out.
* Die Methode ermittelt auf Basis offener debitorischer offenen Posten die dazugehörigen AVIP-Einträge und schreibt diese in die interne Tabelle XT_AVIP_OUT.
* Die Inhalte der internen Tabelle bestimmen den weiteren Verlauf Logik des Interpretationalgorithmuses 901.
    DATA: lv_data     TYPE char70,
          lv_test     TYPE char1,
          ls_febko    TYPE febko,
          ls_febep    TYPE febep,
          lt_bsid_ges LIKE it_bsid.

    DATA(lt_bsid) = it_bsid.

    CHECK lt_bsid IS NOT INITIAL.
* Inhalte der Strukturen ls_febko und ls_febep
    read_elko_tabellen( CHANGING xs_febko = ls_febko
                                 xs_febep = ls_febep ).

    import_memory test lv_test  'ELKO_TEST'.

* Ermittlung der Tilgungsreihenfolge der offenen deb. Posten
    set_tilgungsfolge_bsid(       CHANGING  xt_bsid = lt_bsid ).

    set_bsid_avip_out( EXPORTING it_bsid       = lt_bsid
                                 it_bsid_teilz = it_bsid_teilz
                       CHANGING  xs_febep      = ls_febep
                                 xt_avip_out   = xt_avip_out
                                 xv_ueberz     = xv_ueberz ).
    IF xv_ueberz IS NOT INITIAL.
      FIELD-SYMBOLS: <ls_febep> TYPE febep.
      IF lv_test IS INITIAL.
        lv_data = '(RFEBBU10)febep'.
        ASSIGN (lv_data) TO <ls_febep>.
        IF <ls_febep>-budat NE '20251231'.
          <ls_febep>-zz_over = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
    IF xt_avip_out IS NOT INITIAL.
      DATA(lv_elko)  = abap_true.
      DATA(lv_vwezw) = iv_vwezw.
      APPEND LINES OF it_bsid         TO lt_bsid_ges.
      APPEND LINES OF it_bsid_teilz   TO lt_bsid_ges.
      export_memory elko_ok lv_elko     'ELKO_OK'.
      export_memory lt_avip xt_avip_out 'AVIP_OUT'.
      export_memory lt_bsid lt_bsid_ges 'LT_BSID'.
      export_memory vwezw lv_vwezw      'VWEZW'.
      IF lv_test IS INITIAL.
        lv_data = '(RFEBBU10)febep'.
        ASSIGN (lv_data) TO <ls_febep>.
**        SELECT fkassz FROM /thkr/kassz_kett INTO <ls_febep>-xblnr
**                      UP TO 1 ROWS
**          WHERE wkassz = <ls_febep>-xblnr.
**        ENDSELECT.
      ENDIF.
      CLEAR: lv_elko,
             lt_bsid_ges.
    ENDIF.
  ENDMETHOD.


  METHOD set_avip_901_teilzahlung.
* Ermittlung von Teilzahlungen aus der Tabelle BSID und der Belegart DZ. Gefundene Teilzahlungsbeträge werden in die int. Tabelle XT_AVIP_OUT geschrieben.
    DATA:ls_avip_out   TYPE avip,
         lv_rest       TYPE dmbtr,
         lv_wrbtr      TYPE wrbtr,
         lv_end        TYPE c,
         lv_test       TYPE c,
         lv_teilz      TYPE c,
         lv_zahlbetrag TYPE kwbtr,
         lv_dz_betrag  TYPE kwbtr,
         lv_data       TYPE char70.

    FIELD-SYMBOLS: <ls_febep> TYPE febep.

    CLEAR: xt_avip_out, lv_test.
    DATA(lt_bsid) = it_bsid.

    SORT lt_bsid BY rangf ASCENDING
                    zfbdt ASCENDING
                    belnr
                    rebzg ASCENDING.

    set_zahlungs_abzug( EXPORTING is_febep       = xs_febep
                        CHANGING  xt_bsid        = lt_bsid ).


    LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<ls_bsid>).
      AT FIRST.
* Zahlbetrag laut Kontoauszug
        set_zahlbetrag_kwbtr( EXPORTING is_febep = xs_febep
                              CHANGING  xv_kwbtr = lv_zahlbetrag ).

      ENDAT.

      IF lv_end IS INITIAL.
        IF <ls_bsid>-shkzg EQ 'S'.
          lv_wrbtr = <ls_bsid>-wrbtr.
        ELSE.
          lv_wrbtr = <ls_bsid>-wrbtr * -1.
        ENDIF.

        lv_zahlbetrag = lv_zahlbetrag - lv_wrbtr.

* Loop über die offenen Posten bis ein Restbetrag für die Teilzahlung übrig bleibt.
        IF  lv_wrbtr      GT 0
        AND ( lv_zahlbetrag LE 0 OR ( lv_zahlbetrag GE 0 AND xs_febep-budat EQ '20251231' ) )
        AND lv_end        IS INITIAL.
          lv_rest  = lv_zahlbetrag * -1.
          lv_wrbtr = lv_wrbtr - lv_rest.
          DATA(lv_diff) = abap_true.
        ENDIF.

        IF  lv_zahlbetrag GE 0
        OR  lv_rest       IS NOT INITIAL
        AND lv_end        IS INITIAL.
          ls_avip_out-avspo          = ls_avip_out-avspo + 1.
          ls_avip_out-bukrs          = <ls_bsid>-bukrs.
          ls_avip_out-abwbu          = <ls_bsid>-bukrs.
          ls_avip_out-koart          = 'D'.
          ls_avip_out-sfeld          = 'BELNR'.
          ls_avip_out-swert          = <ls_bsid>-belnr.
          ls_avip_out-swert+10(4)    = <ls_bsid>-gjahr.
          ls_avip_out-xakts          = abap_true.
          ls_avip_out-xaktp          = abap_true.
          ls_avip_out-xblnr          = <ls_bsid>-xblnr.
          ls_avip_out-waers          = <ls_bsid>-waers.
          ls_avip_out-belnr          = <ls_bsid>-belnr.
          ls_avip_out-gjahr          = <ls_bsid>-gjahr.
          ls_avip_out-abwko          = xs_febep-avkon.
          ls_avip_out-abwka          = 'D'.
          ls_avip_out-konto          = <ls_bsid>-kunnr.
          ls_avip_out-wrbtr          = <ls_bsid>-wrbtr.

          IF lv_diff IS NOT INITIAL AND lv_rest NE 0.
* Bei Teilzahlungen muss die FEBEP mit zusätzlichen Informationen versorgt werden.
            ls_avip_out-diffw        = lv_rest.
            ls_avip_out-xppmt        = abap_true.
            import_memory test lv_test  'ELKO_TEST'.
            lv_end   = abap_true.
            IF lv_test IS INITIAL.
              lv_data = '(RFEBBU10)febep'.
              ASSIGN (lv_data) TO <ls_febep>.
              <ls_febep>-fkoa1 = '3'.  "3.Zeile Buchungsbereich 2
              <ls_febep>-fnam1 = 'BSEG-REBZG'.
              <ls_febep>-fval1 = <ls_bsid>-belnr.
              <ls_febep>-fkoa2 = '3'.  "3.Zeile Buchungsbereich 2
              <ls_febep>-fnam2 = 'BSEG-REBZJ'.
              <ls_febep>-fval2 = <ls_bsid>-gjahr.
              <ls_febep>-fkoa3 = '3'.  "3.Zeile Buchungsbereich 2
              <ls_febep>-fnam3 = 'BSEG-REBZZ'.
              <ls_febep>-fval3 = '001'.
              <ls_febep>-xblnr = <ls_bsid>-xblnr.
              lv_teilz         = abap_true.
              export_memory lv_teilz lv_teilz 'TEILZ_DEBI'.
            ENDIF.
          ENDIF.
          IF lv_zahlbetrag EQ 0.
            lv_end = abap_true.
          ENDIF.
          APPEND ls_avip_out TO xt_avip_out.
        ENDIF.

        CLEAR: lv_wrbtr,
               lv_rest,
               lv_diff.
      ENDIF.

      AT LAST.
        IF lv_zahlbetrag GT 0.
          xv_ueberz = abap_true.
        ENDIF.
      ENDAT.

    ENDLOOP.
    CLEAR: lv_end,ls_avip_out, lt_bsid.
  ENDMETHOD.


  METHOD set_avip_901_vollausgleich.
* Ermittlung aller offenen debitorischen Posten bis zum Auffüllen eines Vollausgleiches. Teilzahlungen dürfen hierbei nicht vorkommen.
* Die int. Tabelle XT_AVIP_OUT wird entsprechend mit Werten gefüllt.
* Betrifft nur den Verarbeitungsalgorithmus 901
    DATA:ls_avip_out   TYPE avip,
         lv_rest       TYPE dmbtr,
         lv_wrbtr      TYPE wrbtr,
         lv_end        TYPE c,
         lv_zahlbetrag TYPE kwbtr,
         lv_data       TYPE char70,
         lv_test       TYPE c.

    FIELD-SYMBOLS: <ls_febep> TYPE febep.

    CLEAR: xv_ueberz, lv_test.
    xv_voll_kz = abap_true.

    LOOP AT it_bsid ASSIGNING FIELD-SYMBOL(<ls_bsid>).
      AT FIRST.
* Zahlbetrag laut Kontoauszug
        set_zahlbetrag_kwbtr( EXPORTING is_febep = xs_febep
                              CHANGING  xv_kwbtr = lv_zahlbetrag ).
      ENDAT.

      IF lv_end IS INITIAL.
        IF <ls_bsid>-shkzg EQ 'S'.
          lv_wrbtr = <ls_bsid>-wrbtr.
        ELSE.
          lv_wrbtr = <ls_bsid>-wrbtr * -1.
        ENDIF.
        lv_zahlbetrag = lv_zahlbetrag - lv_wrbtr.

* Loop über die offenen Posten bis ein Restbetrag für die Teilzahlung übrig bleibt.
        IF    lv_wrbtr      GT 0
        AND   lv_zahlbetrag LE 0
        AND   lv_end        IS INITIAL.
          lv_rest  = lv_zahlbetrag * -1.
          lv_wrbtr = lv_wrbtr - lv_rest.
          DATA(lv_diff) = abap_true.
        ENDIF.

        IF  lv_zahlbetrag GE 0
        OR  lv_rest       IS NOT INITIAL
        AND lv_end        IS INITIAL.
          ls_avip_out-avspo          = ls_avip_out-avspo + 1.
          ls_avip_out-bukrs          = <ls_bsid>-bukrs.
          ls_avip_out-abwbu          = <ls_bsid>-bukrs.
          ls_avip_out-koart          = 'D'.
          ls_avip_out-sfeld          = 'BELNR'.
          ls_avip_out-swert          = <ls_bsid>-belnr.
          ls_avip_out-swert+10(4)    = <ls_bsid>-gjahr.
          ls_avip_out-gjahr          = <ls_bsid>-gjahr.
          ls_avip_out-xakts          = abap_true.
          ls_avip_out-xaktp          = abap_true.
          ls_avip_out-xblnr          = <ls_bsid>-xblnr.
          ls_avip_out-waers          = <ls_bsid>-waers.
          ls_avip_out-belnr          = <ls_bsid>-belnr.
          ls_avip_out-abwko          = xs_febep-avkon.
          ls_avip_out-abwka          = 'D'.
          ls_avip_out-konto          = <ls_bsid>-kunnr.
          ls_avip_out-wrbtr          = <ls_bsid>-wrbtr.

          import_memory test lv_test  'ELKO_TEST'.
          IF lv_test IS INITIAL.
            lv_data = '(RFEBBU10)febep'.
            ASSIGN (lv_data) TO <ls_febep>.
            <ls_febep>-xblnr = <ls_bsid>-xblnr.
          ENDIF.

          IF lv_diff IS NOT INITIAL AND lv_rest NE 0.
            ls_avip_out-diffw        = lv_rest.
            ls_avip_out-xppmt        = abap_true.
            lv_end   = abap_true.
            CLEAR: xv_voll_kz.
          ENDIF.

          IF lv_zahlbetrag EQ 0.
            lv_end = abap_true.
            DATA(lv_belnr) = <ls_bsid>-belnr.
            DATA(lv_gjahr) = <ls_bsid>-gjahr.
          ENDIF.
          APPEND ls_avip_out TO xt_avip_out.
        ENDIF.
        CLEAR: lv_wrbtr,
               lv_rest,
               lv_diff.
      ENDIF.

      AT LAST.
        xs_febep-xblnr = ls_avip_out-xblnr.
        IF lv_zahlbetrag GT 0.
          IF xs_febep-budat NE '20251231'.
            xv_ueberz = abap_true.
          ELSE.
            CLEAR: xt_avip_out.
            CLEAR: xv_voll_kz.
          ENDIF.
        ENDIF.
      ENDAT.
    ENDLOOP.
* Falls zur Belegnummer noch offene DZ-Belege vorhanden sind, erst einmal kein Vollausgleich
    LOOP AT it_bsid ASSIGNING <ls_bsid>
            WHERE rebzg EQ lv_belnr
            AND   rebzj EQ lv_gjahr
            AND   blart EQ 'DZ'.
      DATA(lv_dzvorh) = abap_true.
      AT LAST.
        CLEAR: xt_avip_out.
        CLEAR: xv_voll_kz.
        CLEAR: lv_dzvorh.
      ENDAT.
    ENDLOOP.

    CLEAR: lv_end,ls_avip_out, lv_belnr, lv_gjahr.
  ENDMETHOD.


  METHOD set_avip_902_out.
* Die Methode ermittelt auf Basis offener kreditorischer offenen Posten die dazugehörigen AVIP-Einträge und schreibt diese in die interne Tabelle XT_AVIP_OUT.
* Die Inhalte der internen Tabelle bestimmen den weiteren Verlauf Logik des Interpretationalgorithmuses 902.
    DATA: ls_febko TYPE febko,
          ls_febep TYPE febep.

    DATA(lt_bsik) = it_bsik.

    CHECK lt_bsik IS NOT INITIAL.

    read_elko_tabellen( CHANGING xs_febko = ls_febko
                                 xs_febep = ls_febep ).


    set_bsik_avip_out( EXPORTING it_bsik     = lt_bsik
                       CHANGING  xs_febep    = ls_febep
                                 xt_avip_out = xt_avip_out ).

    IF xt_avip_out IS NOT INITIAL.
      DATA(lv_elko) = abap_true.
      APPEND LINES OF it_bsik         TO lt_bsik.
      export_memory elko_ok lv_elko     'ELKO_OK'.
      export_memory lt_avip xt_avip_out 'AVIP_OUT'.
      export_memory lt_bsik lt_bsik     'LT_BSIK'.
      CLEAR: lv_elko,
             lt_bsik.
    ENDIF.
  ENDMETHOD.


  METHOD set_avip_902_vollausgleich.
* Ermittlung aller offenen kreditorischen Posten bis zum Auffüllen eines Vollausgleiches. Teilzahlungen dürfen hierbei nicht vorkommen.
* Die int. Tabelle XT_AVIP_OUT wird entsprechend mit Werten gefüllt.
* Betrifft nur den Verarbeitungsalgorithmus 902

    DATA:ls_avip_out   TYPE avip,
         lv_rest       TYPE dmbtr,
         lv_wrbtr      TYPE wrbtr,
         lv_end        TYPE c,
         lv_zahlbetrag TYPE kwbtr,
         lv_test       TYPE c,
         lv_data       TYPE char70.

    FIELD-SYMBOLS: <ls_febep> TYPE febep.

    CLEAR: lv_test.
    LOOP AT it_bsik ASSIGNING FIELD-SYMBOL(<ls_bsik>).
      AT FIRST.
* Zahlbetrag laut Kontoauszug
        set_zahlbetrag_kwbtr( EXPORTING is_febep = xs_febep
                              CHANGING  xv_kwbtr = lv_zahlbetrag ).
      ENDAT.

      IF lv_end IS INITIAL.
        IF <ls_bsik>-shkzg EQ 'S'.
          lv_wrbtr = <ls_bsik>-wrbtr.
        ELSE.
          lv_wrbtr = <ls_bsik>-wrbtr * -1.
        ENDIF.
        lv_zahlbetrag = lv_zahlbetrag - lv_wrbtr.

* Loop über die offenen Posten bis ein Restbetrag für die Teilzahlung übrig bleibt.
        IF  lv_wrbtr      GT 0
        AND lv_zahlbetrag LE 0
        AND lv_end        IS INITIAL.
          lv_rest  = lv_zahlbetrag * -1.
          lv_wrbtr = lv_wrbtr - lv_rest.
          DATA(lv_diff) = abap_true.
        ENDIF.

        IF  lv_zahlbetrag GE 0
        OR  lv_rest       IS NOT INITIAL
        AND lv_end        IS INITIAL.
          ls_avip_out-avspo          = ls_avip_out-avspo + 1.
          ls_avip_out-bukrs          = <ls_bsik>-bukrs.
          ls_avip_out-abwbu          = <ls_bsik>-bukrs.
          ls_avip_out-koart          = 'K'.
          ls_avip_out-sfeld          = 'BELNR'.
          ls_avip_out-swert          = <ls_bsik>-belnr.
          ls_avip_out-swert+10(4)    = <ls_bsik>-gjahr.
          ls_avip_out-gjahr          = <ls_bsik>-gjahr.
          ls_avip_out-xakts          = abap_true.
          ls_avip_out-xaktp          = abap_true.
          ls_avip_out-xblnr          = <ls_bsik>-xblnr.
          ls_avip_out-waers          = <ls_bsik>-waers.
          ls_avip_out-belnr          = <ls_bsik>-belnr.
          ls_avip_out-abwko          = xs_febep-avkon.
          ls_avip_out-abwka          = 'K'.
          ls_avip_out-konto          = <ls_bsik>-lifnr.
          ls_avip_out-wrbtr          = <ls_bsik>-wrbtr.

          import_memory test lv_test  'ELKO_TEST'.
          IF lv_test IS INITIAL.
            lv_data = '(RFEBBU10)febep'.
            ASSIGN (lv_data) TO <ls_febep>.
            <ls_febep>-xblnr = <ls_bsik>-xblnr.
          ENDIF.

          IF lv_diff IS NOT INITIAL AND lv_rest NE 0.
            ls_avip_out-diffw        = lv_rest.
            ls_avip_out-xppmt        = abap_true.
            lv_end   = abap_true.
          ENDIF.
          IF lv_zahlbetrag EQ 0.
            lv_end = abap_true.
          ENDIF.
          APPEND ls_avip_out TO xt_avip_out.
        ENDIF.
        CLEAR: lv_wrbtr,
               lv_rest,
               lv_diff.
      ENDIF.
    ENDLOOP.
    CLEAR: lv_end,ls_avip_out.
  ENDMETHOD.


  METHOD set_bapi_account.
    DATA:  ls_accountgl TYPE bapiacgl09.
    CLEAR: ls_accountgl,
           xt_account.

* Habenposition
    ls_accountgl-itemno_acc  = '2'.
    SELECT konth FROM t030 INTO ls_accountgl-gl_account
      UP TO 1 ROWS
      WHERE ktopl = 'VKP'
      AND   ktosl = 'BSP'.
    ENDSELECT.
    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM /thkr/kontierg_k INTO @DATA(ls_kontierg_k)
                    WHERE bukrs EQ @is_beleg-bukrs
                    AND   hkont EQ @ls_accountgl-gl_account.

      IF sy-subrc EQ 0.
        ls_accountgl-acct_type   = 'S'.
        ls_accountgl-comp_code   = ls_kontierg_k-bukrs.
        ls_accountgl-cmmt_item   = ls_kontierg_k-fipex.
        ls_accountgl-fund        = ls_kontierg_k-geber.
        ls_accountgl-func_area   = ls_kontierg_k-fkber.
      ENDIF.

      SELECT * FROM bseg INTO @DATA(ls_bseg)
        UP TO 1 ROWS
        WHERE bukrs  EQ @is_beleg-bukrs
          AND belnr  EQ @is_beleg-belnr
          AND gjahr  EQ @is_beleg-gjahr
          AND koart  EQ 'S'.
      ENDSELECT.

      IF sy-subrc EQ 0.
        ls_accountgl-bus_area    = ls_bseg-gsber.
        ls_accountgl-profit_ctr  = ls_bseg-prctr.
        ls_accountgl-costcenter  = ls_bseg-kostl.
        ls_accountgl-funds_ctr   = ls_bseg-fistl.
        ls_accountgl-item_text   = TEXT-004.
        APPEND ls_accountgl TO xt_account.
        CLEAR: ls_bseg, ls_accountgl.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_bapi_beleg_buchen.
    DATA: ls_header   TYPE bapiache09,
          lt_account  TYPE bapiacgl09_tab,
          lt_debitor  TYPE bapiacar09_tab,
          lt_kreditor TYPE bapiacap09_tab,
          lt_currency TYPE bapiaccr09_tab,
          lv_fehler   TYPE char1.

    set_bapi_header( EXPORTING is_febko  = is_febko
                               is_febep  = is_febep "2026-03-05 js für BUDAT
                               is_beleg  = is_beleg
                               iv_blart  = 'SG'
                     CHANGING  xs_header = ls_header ).

    set_bapi_debitor( EXPORTING is_beleg   = is_beleg
                      CHANGING  xt_debitor = lt_debitor ).

    set_bapi_kreditor( EXPORTING is_beleg    = is_beleg
                       CHANGING  xt_kreditor = lt_kreditor ).


    set_bapi_account( EXPORTING is_beleg   = is_beleg
                      CHANGING  xt_account = lt_account ).

    set_bapi_currency( EXPORTING is_febep    = is_febep
                                 is_beleg    = is_beleg
                       CHANGING  xt_currency = lt_currency ).


    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader    = ls_header
      TABLES
        accountgl         = lt_account
        accountreceivable = lt_debitor
        accountpayable    = lt_kreditor
        currencyamount    = lt_currency
        return            = xt_return.

    LOOP AT xt_return ASSIGNING FIELD-SYMBOL(<ls_return>).
      lv_fehler = abap_true.
      IF <ls_return>-type = 'S' AND <ls_return>-id   = 'RW' AND <ls_return>-number = '614'.
        CLEAR: lv_fehler.
      ENDIF.
    ENDLOOP.
    IF lv_fehler IS INITIAL.
      CLEAR: xt_return.
      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader    = ls_header
        TABLES
          accountgl         = lt_account
          accountreceivable = lt_debitor
          accountpayable    = lt_kreditor
          currencyamount    = lt_currency
          return            = xt_return.
    ENDIF.

    SORT xt_return BY message.
    DELETE ADJACENT DUPLICATES FROM xt_return COMPARING message.
*
    LOOP AT xt_return ASSIGNING <ls_return>.
      IF     <ls_return>-type = 'S' AND <ls_return>-id   = 'RW' AND <ls_return>-number = '605'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD set_bapi_currency.
    DATA: ls_currency  TYPE bapiaccr09,
          lv_dmbtr_str TYPE string,
          lv_dmbtr     TYPE dmbtr.

    CLEAR: ls_currency,
           xt_currency.
    SELECT SINGLE * FROM bseg INTO @DATA(ls_bseg)
                    WHERE bukrs EQ @is_beleg-bukrs
                    AND   belnr EQ @is_beleg-belnr
                    AND   gjahr EQ @is_beleg-gjahr
                    AND   shkzg EQ 'S'.
    IF sy-subrc EQ 0.
* Sollbetrag
      ls_currency-itemno_acc = ls_bseg-buzei.
      DATA(lv_betrag) = is_febep-spesk.

      lv_dmbtr_str = lv_betrag.
      REPLACE ',' WITH '.' INTO lv_dmbtr_str.
      lv_dmbtr = lv_dmbtr_str.
      ls_currency-amt_doccur = lv_dmbtr.
      ls_currency-currency   = ls_bseg-pswsl.
      APPEND ls_currency TO xt_currency.
*Habenbetrag
      CLEAR: lv_betrag, lv_dmbtr_str, lv_dmbtr, ls_currency.
      ls_currency-itemno_acc = '2'.
      lv_betrag = is_febep-spesk.

      lv_dmbtr_str = lv_betrag * -1.
      REPLACE ',' WITH '.' INTO lv_dmbtr_str.
      lv_dmbtr = lv_dmbtr_str.
      ls_currency-amt_doccur = lv_dmbtr.
      ls_currency-currency   = ls_bseg-pswsl.
      APPEND ls_currency TO xt_currency.

      CLEAR: ls_bseg,
             ls_currency,
             lv_dmbtr_str,
             lv_dmbtr.

    ENDIF.
  ENDMETHOD.


  METHOD set_bapi_debitor.
    DATA:  ls_debitor TYPE bapiacar09.
    CLEAR: ls_debitor,
           xt_debitor.

* Sollposition
    SELECT SINGLE * FROM bseg INTO @DATA(ls_bseg)
                    WHERE bukrs EQ @is_beleg-bukrs
                    AND   belnr EQ @is_beleg-belnr
                    AND   gjahr EQ @is_beleg-gjahr
                    AND   shkzg EQ 'S'
                    AND   koart EQ 'D'.
    IF sy-subrc EQ 0.
      ls_debitor-itemno_acc  = '1'.
      ls_debitor-customer     = ls_bseg-kunnr.
      ls_debitor-comp_code    = ls_bseg-bukrs.
*      ls_debitor-bus_area     = ls_bseg-gsber.
      APPEND ls_debitor TO xt_debitor.
      CLEAR: ls_bseg.
    ENDIF.
  ENDMETHOD.


  METHOD set_bapi_header.
    SELECT SINGLE * FROM bkpf INTO @DATA(ls_bkpf)
                    WHERE bukrs EQ @is_beleg-bukrs
                    AND   belnr EQ @is_beleg-belnr
                    AND   gjahr EQ @is_beleg-gjahr.
    xs_header-bus_act     = 'RFBU'.
    xs_header-username    = sy-uname.
    xs_header-comp_code   = ls_bkpf-bukrs.
    xs_header-doc_date    = is_febko-azdat.
    xs_header-pstng_date  = is_febep-budat.      "2026-03-05 js BUDAT statt AZDAT
    xs_header-fisc_year   = is_febep-budat+0(4). "2026-03-05 js BUDAT statt AZDAT
    xs_header-REF_DOC_NO  = ls_bkpf-xblnr.
    xs_header-obj_type    = 'BKPFF'.
    xs_header-obj_sys     = sy-mandt.
    xs_header-doc_type    = iv_blart.
    CLEAR: ls_bkpf.
  ENDMETHOD.


  METHOD set_bapi_kreditor.
    DATA:  ls_kreditor TYPE BAPIACAP09.
    CLEAR: ls_kreditor,
           xt_kreditor.

* Sollposition
    SELECT SINGLE * FROM bseg INTO @DATA(ls_bseg)
                    WHERE bukrs EQ @is_beleg-bukrs
                    AND   belnr EQ @is_beleg-belnr
                    AND   gjahr EQ @is_beleg-gjahr
                    AND   shkzg EQ 'S'
                    AND   koart EQ 'K'.
    IF sy-subrc EQ 0.
      ls_kreditor-itemno_acc  = '1'.
      ls_kreditor-vendor_no   = ls_bseg-lifnr.
      ls_kreditor-comp_code   = ls_bseg-bukrs.
*      ls_kreditor-bus_area     = ls_bseg-gsber.
      APPEND ls_kreditor TO xt_kreditor.
      CLEAR: ls_bseg.
    ENDIF.
  ENDMETHOD.


  METHOD set_bsid_avip_out.
* Verdichten nach Rechnungsbezug
    DATA: lv_voll_kz TYPE c.
    DATA(lt_bsid) = it_bsid.

    CHECK it_bsid IS NOT INITIAL OR it_bsid_teilz IS NOT INITIAL.

    CLEAR: xt_avip_out.
    LOOP AT it_bsid_teilz ASSIGNING FIELD-SYMBOL(<ls_teil>).
      READ TABLE it_bsid  TRANSPORTING NO FIELDS
                 WITH KEY belnr = <ls_teil>-rebzg
                          gjahr = <ls_teil>-rebzj
                          buzei = <ls_teil>-rebzz.
* Ermittlung der Teilzahlungen.
      IF sy-subrc EQ 0.
        APPEND <ls_teil> TO lt_bsid.
      ENDIF.
    ENDLOOP.

    SORT lt_bsid BY rangf ASCENDING
                    zfbdt ASCENDING
                    belnr.

    set_avip_901_vollausgleich( EXPORTING it_bsid     = lt_bsid
                                CHANGING  xt_avip_out = xt_avip_out
                                          xv_voll_kz  = lv_voll_kz
                                          xs_febep    = xs_febep
                                          xv_ueberz   = xv_ueberz ).
    IF lv_voll_kz IS INITIAL.
      set_avip_901_teilzahlung( EXPORTING it_bsid     = lt_bsid
                                CHANGING  xt_avip_out = xt_avip_out
                                          xs_febep    = xs_febep
                                          xv_ueberz   = xv_ueberz ).

    ENDIF.

  ENDMETHOD.


  METHOD SET_BSIK_AVIP_OUT.
* Verdichten nach Rechnungsbezug

    DATA(lt_bsik) = it_bsik.

    CLEAR: xt_avip_out.

    SORT lt_bsik BY blart DESCENDING
                    zfbdt ASCENDING.

    set_avip_902_vollausgleich( EXPORTING it_bsik     = lt_bsik
                                CHANGING  xt_avip_out = xt_avip_out
                                          xs_febep    = xs_febep ).
  ENDMETHOD.


  METHOD set_bukrs_segment_for_t999.
    DATA: lv_vorhanden               TYPE char1,
          ls_master_data_d           TYPE cmds_ei_main,
          ls_master_data_correct_d   TYPE cmds_ei_main,
          ls_message_correct_d       TYPE cvis_message,
          ls_master_data_defective_d TYPE cmds_ei_main,
          ls_message_defective_d     TYPE cvis_message,
          lt_customers_d             TYPE cmds_ei_extern_t,
          ls_customer_d              TYPE cmds_ei_extern,
          lt_company_d               TYPE cmds_ei_company_t,
          ls_data_d                  TYPE cmds_ei_company_data,
          ls_int_comp_d              TYPE cmds_ei_company,
          ls_company_d               TYPE cmds_ei_cmd_company,
          ls_master_data_k           TYPE vmds_ei_main,
          ls_master_data_correct_k   TYPE vmds_ei_main,
          ls_message_correct_k       TYPE cvis_message,
          ls_master_data_defective_k TYPE vmds_ei_main,
          ls_message_defective_k     TYPE cvis_message,
          lt_vendors_k               TYPE vmds_ei_extern_t,
          ls_vendors_k               TYPE vmds_ei_extern,
          lt_company_k               TYPE vmds_ei_company_t,
          ls_data_k                  TYPE vmds_ei_company_data,
          ls_int_comp_k              TYPE vmds_ei_company,
          ls_company_k               TYPE vmds_ei_vmd_company,
          lt_knb1                    TYPE TABLE OF knb1,
          lt_lfb1                    TYPE TABLE OF lfb1.

    CLEAR: xt_bapiret.
    IF iv_kred IS INITIAL.
      get_debitor_from_knb1( EXPORTING iv_kunnr = iv_kunnr
                                       iv_bukrs = iv_bukrs
                             CHANGING  xt_knb1  = lt_knb1 ).
      lv_vorhanden = me->check_debitor( iv_kunnr = iv_kunnr ).

      IF lt_knb1 IS NOT INITIAL AND lv_vorhanden EQ abap_false.
        LOOP AT lt_knb1 ASSIGNING FIELD-SYMBOL(<ls_knb1>).
          CLEAR: ls_int_comp_d,
                 ls_customer_d,
                 ls_int_comp_d,
                 ls_data_d,
                 lt_company_d,
                 lt_customers_d.
* Header füllen
          ls_customer_d-header-object_instance-kunnr = iv_kunnr.
          ls_customer_d-header-object_task  = 'U'. " I/U/D
* Buchungskreisdaten füllen
          ls_int_comp_d-task = 'I'.
          ls_int_comp_d-data_key = 'T999'.
          MOVE-CORRESPONDING <ls_knb1> TO ls_data_d.
          ls_int_comp_d-data     = ls_data_d.
          APPEND ls_int_comp_d TO lt_company_d.
          ls_company_d-company[]     = lt_company_d[].
          ls_customer_d-company_data = ls_company_d.
          APPEND ls_customer_d TO lt_customers_d.

          ls_master_data_d-customers = lt_customers_d[].

          cmd_ei_api=>initialize( ).

          LOOP AT lt_customers_d INTO ls_customer_d.
            cmd_ei_api=>lock( iv_kunnr = ls_customer_d-header-object_instance-kunnr ).
          ENDLOOP.

          CALL METHOD cmd_ei_api=>maintain_bapi
            EXPORTING
              iv_test_run              = abap_false
              iv_collect_messages      = abap_true
              is_master_data           = ls_master_data_d
            IMPORTING
              es_master_data_correct   = ls_master_data_correct_d
              es_message_correct       = ls_message_correct_d
              es_master_data_defective = ls_master_data_defective_d
              es_message_defective     = ls_message_defective_d.

          IF ls_message_defective_d IS INITIAL.
            COMMIT WORK.
          ELSE.
            xt_bapiret = ls_message_defective_d-messages.
          ENDIF.
          LOOP AT lt_customers_d INTO ls_customer_d.
            cmd_ei_api=>unlock( iv_kunnr = ls_customer_d-header-object_instance-kunnr ) .
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ELSE.
      get_kreditor_from_lfb1( EXPORTING iv_lifnr = iv_lifnr
                                        iv_bukrs = iv_bukrs
                              CHANGING  xt_lfb1  = lt_lfb1 ).
      lv_vorhanden = me->check_kreditor( iv_lifnr = iv_lifnr ).

      IF lt_lfb1 IS NOT INITIAL AND lv_vorhanden EQ abap_false.
        LOOP AT lt_lfb1 ASSIGNING FIELD-SYMBOL(<ls_lfb1>).
          CLEAR: ls_int_comp_k,
                 ls_vendors_k,
                 ls_int_comp_k,
                 ls_data_k,
                 lt_company_k,
                 lt_vendors_k.
* Header füllen
          ls_vendors_k-header-object_instance-lifnr = iv_lifnr.
          ls_vendors_k-header-object_task  = 'U'. " I/U/D
* Buchungskreisdaten füllen
          ls_int_comp_k-task = 'I'.
          ls_int_comp_k-data_key = 'T999'.
          MOVE-CORRESPONDING <ls_lfb1> TO ls_data_k.
          ls_int_comp_k-data     = ls_data_k.
          APPEND ls_int_comp_k TO lt_company_k.
          ls_company_k-company[] = lt_company_k[].
          ls_vendors_k-company_data  = ls_company_k.
          APPEND ls_vendors_k TO lt_vendors_k.

          ls_master_data_k-vendors = lt_vendors_k[].

          vmd_ei_api=>initialize( ).

          LOOP AT lt_vendors_k INTO ls_vendors_k.
            vmd_ei_api=>lock( iv_lifnr = ls_vendors_k-header-object_instance-lifnr ).
          ENDLOOP.

          CALL METHOD vmd_ei_api=>maintain_bapi
            EXPORTING
              iv_test_run              = abap_false
              iv_collect_messages      = abap_true
              is_master_data           = ls_master_data_k
            IMPORTING
              es_master_data_correct   = ls_master_data_correct_k
              es_message_correct       = ls_message_correct_k
              es_master_data_defective = ls_master_data_defective_k
              es_message_defective     = ls_message_defective_k.

          IF ls_message_defective_k IS INITIAL.
            COMMIT WORK.
          ELSE.
            xt_bapiret = ls_message_defective_k-messages.
          ENDIF.
          LOOP AT lt_vendors_k INTO ls_vendors_k.
            vmd_ei_api=>unlock( iv_lifnr = ls_vendors_k-header-object_instance-lifnr ) .
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_create_kassenz.
* Kassenzeichen ermitteln
    DATA: lv_kaz    TYPE /thkr/d_kassenzeichen,
          lv_xblnr  TYPE xblnr,
          lv_gjahr  TYPE gjahr,
          lv_rc     TYPE nrreturn,
          lv_msgnr  TYPE msgnr,
          lv_pruef  TYPE char1.

    DATA: ls_kass   TYPE /thkr/t_kass.

* Kassenzeichen ermitteln
    IF xs_febep-xblnr IS NOT INITIAL.
      CLEAR: lv_xblnr, lv_gjahr.
      lv_xblnr = xs_febep-xblnr.
      lv_gjahr = xs_febep-gjahr.
    ENDIF.

* Belegart ermitteln
    SELECT SINGLE agbuk  FROM febcl INTO @DATA(lv_bukrs)
                         WHERE kukey = @xs_febep-kukey
                         AND   esnum = @xs_febep-esnum
                         AND   csnum = '001'.
    IF sy-subrc EQ 0.
      SELECT blart FROM bkpf INTO @DATA(lv_blart)
                   UP TO 1 ROWS
                   WHERE bukrs = @lv_bukrs
                   AND xblnr = @lv_xblnr
                   AND gjahr = @lv_gjahr.
        CLEAR: lv_bukrs,
               lv_gjahr.
      ENDSELECT.
    ENDIF.
    CLEAR: ls_kass.
    SELECT SINGLE * FROM /thkr/t_kass INTO ls_kass
                    WHERE blart = lv_blart.
    /thkr/cl_kassenzeichen=>check( EXPORTING i_xblnr       = lv_xblnr
                                             is_kass       = ls_kass
                                   IMPORTING e_pruefziffer = lv_pruef ##needed
                                             e_rc          = lv_rc ).
    IF lv_rc EQ 4.
* Ermittlung des Kontiervorlageneintrages
       IF iv_acctmp IS NOT INITIAL.
* Selektion der kontierungsvorlage
        SELECT SINGLE * FROM feb_act INTO @DATA(ls_kontierung)
               WHERE acctmp = @iv_acctmp.

        IF ls_kontierung IS NOT INITIAL.
          IF ls_kontierung-geber IS NOT INITIAL AND ls_kontierung-gsber IS NOT INITIAL.
*** Erstellen eines kassenzeichens
            /thkr/cl_kassenzeichen=>create( EXPORTING i_fonds = ls_kontierung-geber
                                                      i_gsber = ls_kontierung-gsber
                                                      i_nrnr  = '00'
                                            IMPORTING e_kaz   = lv_kaz
                                                      e_rc    = lv_rc ).

            IF lv_rc <> 0.
              CONCATENATE '01' lv_rc INTO lv_msgnr.
              MESSAGE ID '/THKR/KLSA841'  TYPE 'E' NUMBER lv_msgnr.
              IF 1 = 2.
                MESSAGE e001(/thkr/klsa841).
              ENDIF.
            ELSE.
              xs_febep-xblnr = lv_kaz.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_febep_aus_kblk.
* Methode zur Modifikation der Tabelle FEBEP mit Daten aus der DB-Tabelle KBLK
    DATA: lv_lines   TYPE i,
          lv_data    TYPE char70,
          lv_mwskz   TYPE mwskz,
          lv_test    TYPE char1,
          ls_febep   TYPE febep,
          lt_bapiret TYPE  bapiret2_tab.

    FIELD-SYMBOLS: <ls_febep> TYPE febep.

    read_elko_tabellen( CHANGING xs_febep = ls_febep ).
    import_memory test lv_test  'ELKO_TEST'.

    DESCRIBE TABLE it_kblk LINES lv_lines.
    IF lv_lines = 1.
      IF lv_test IS INITIAL.
        lv_data = '(RFEBBU10)febep'.
        ASSIGN (lv_data) TO <ls_febep>.
      ELSE.
        ASSIGN ls_febep TO <ls_febep>.
      ENDIF.

      READ TABLE it_kblk ASSIGNING FIELD-SYMBOL(<ls_kblk>) INDEX 1. "#EC CI_NOORDER
      IF iv_kred IS INITIAL.
        SELECT SINGLE kunnr FROM kblp INTO <ls_febep>-avkon
                                       WHERE belnr = <ls_kblk>-belnr
                                       AND blpos = '001'.

        set_bukrs_segment_for_t999( EXPORTING iv_kunnr   = <ls_febep>-avkon
                                              iv_bukrs   = <ls_febep>-svbuk
                                    CHANGING  xt_bapiret = lt_bapiret ).
        IF lt_bapiret IS NOT INITIAL.
          DATA(type) = 'E'.
          READ TABLE lt_bapiret ASSIGNING FIELD-SYMBOL(<ls_bapiret>)
                     INDEX 1.
          me->messages = VALUE #( BASE me->messages ( id = '/THKR/ELKO' number = 000 type = type message = <ls_bapiret>-message ) ).
          EXIT.
        ENDIF.
        IF me->messages IS NOT INITIAL.
          RAISE EXCEPTION TYPE /thkr/cx_elko EXPORTING bapiret2_tab = me->messages.
        ENDIF.
      ELSE.
        SELECT SINGLE lifnr FROM kblp INTO <ls_febep>-avkon
                                       WHERE belnr = <ls_kblk>-belnr
                                       AND blpos = '001'.
        set_bukrs_segment_for_t999( EXPORTING iv_kred    = abap_true
                                              iv_lifnr   = <ls_febep>-avkon
                                              iv_bukrs   = <ls_febep>-svbuk
                                    CHANGING  xt_bapiret = lt_bapiret ).
        IF lt_bapiret IS NOT INITIAL.
          type = 'E'.
          READ TABLE lt_bapiret ASSIGNING <ls_bapiret>
                     INDEX 1.
          me->messages = VALUE #( BASE me->messages ( id = '/THKR/ELKO' number = 000 type = type message = <ls_bapiret>-message ) ).
          EXIT.
        ENDIF.
        IF me->messages IS NOT INITIAL.
          RAISE EXCEPTION TYPE /thkr/cx_elko EXPORTING bapiret2_tab = me->messages.
        ENDIF.

      ENDIF.

      IF NOT <ls_febep>-avkon IS INITIAL.
        IF iv_kred IS INITIAL.
          <ls_febep>-fnam1 = 'BSEG-KBLNR'.
          <ls_febep>-fval1 = <ls_kblk>-belnr.
          <ls_febep>-fkoa1 = '3'.  "3.Zeile Buchungsbereich 2
          <ls_febep>-fnam2 = 'BSEG-KBLPOS'.
          <ls_febep>-fval2 = '001'.
          <ls_febep>-fkoa2 = '3'.  "3.Zeile Buchungsbereich 2
          <ls_febep>-fnam3 = 'BSEG-MWSKZ'.
          <ls_febep>-fkoa3 = '3'.  "3.Zeile Buchungsbereich 2
          <ls_febep>-avkoa = 'D'.  "3.Zeile Buchungsbereich 2
          <ls_febep>-xblnr = <ls_kblk>-xblnr.

          CASE <ls_febep>-vgint.
            WHEN '1005'.
              <ls_febep>-vgint = iv_vgint.
            WHEN '1006'.
              <ls_febep>-vgint = '1026'.
            WHEN '1008'.
              <ls_febep>-vgint = iv_vgint.
            WHEN OTHERS.
          ENDCASE.

          CALL FUNCTION '/THKR/ELKO_READ_MWSKZ'
            EXPORTING
              i_kblnr   = <ls_kblk>-belnr
              i_blpos   = '001'
            IMPORTING
              e_mwskz   = lv_mwskz
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0 OR lv_mwskz IS INITIAL.
            <ls_febep>-fval3 = 'A0'.
          ELSE.
            <ls_febep>-fval3 = lv_mwskz.
          ENDIF.
        ELSE.
          <ls_febep>-fnam1 = 'BSEG-KBLNR'.
          <ls_febep>-fval1 = <ls_kblk>-belnr.
          <ls_febep>-fkoa1 = '1'.  "1.Zeile BB 2
          <ls_febep>-fnam2 = 'BSEG-KBLPOS'.
          <ls_febep>-fval2 = '001'.
          <ls_febep>-fkoa2 = '1'.  "1.Zeile BB 2
          <ls_febep>-fnam3 = 'BSEG-MWSKZ'.
          <ls_febep>-fkoa3 = '1'.  "1.Zeile BB 2
          <ls_febep>-avkoa = 'K'.
          <ls_febep>-xblnr = <ls_kblk>-xblnr.

          CASE <ls_febep>-vgint.
            WHEN '1005'.
              <ls_febep>-vgint = iv_vgint.
            WHEN '1006'.
              <ls_febep>-vgint = iv_vgint.
            WHEN '1008'.
              <ls_febep>-vgint = iv_vgint.
            WHEN OTHERS.
          ENDCASE.

          CALL FUNCTION 'Z_FI_ELKO_READ_MWSKZ'
            EXPORTING
              i_kblnr   = <ls_kblk>-belnr
              i_blpos   = '001'
            IMPORTING
              e_mwskz   = lv_mwskz
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0 OR lv_mwskz IS INITIAL.
            <ls_febep>-fval3 = 'V0'.
          ELSE.
            <ls_febep>-fval3 = lv_mwskz.
          ENDIF.
        ENDIF.
        DATA(lv_kblk) = abap_true.
        export_memory lv_kblk lv_kblk 'ELKO_KBLK'.

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_ftpost_aus_acctmp.
* Methode zur Aufbereitung der int. Tabelle XT_FTPOST, diese Tabelle beinhaltet nach Befüllung weitere Buchungsinfos.
* Aufruf durch Fuba /thkr/feb_2_acc_ass_kont
    DATA: lv_acctmp TYPE feb_acctmp,
          ls_ftpost TYPE ftpost.

    DATA: o_desc TYPE REF TO cl_abap_structdescr.

    me->get_kassenz_aus_gebkz( EXPORTING iv_kukey  = iv_kukey
                                         iv_esnum  = iv_esnum
                               CHANGING  xv_acctmp = lv_acctmp ).

    IF lv_acctmp IS NOT INITIAL.
      SELECT SINGLE * FROM feb_act INTO @DATA(ls_kontierung)
             WHERE acctmp = @lv_acctmp.

      IF ls_kontierung IS NOT INITIAL.
        o_desc ?= cl_abap_structdescr=>describe_by_name( 'FEB_ACT' ).
        DATA(lt_ddic_fields) = o_desc->get_ddic_field_list( ).
        CLEAR: ls_ftpost.
        ls_ftpost-fnam  = 'BSEG-WRBTR'.
        ls_ftpost-stype = 'P'.
        ls_ftpost-count = '002'.
        READ TABLE xt_ftpost ASSIGNING FIELD-SYMBOL(<ls_ftpost>)
                                        WITH KEY stype = 'P' "#EC CI_STDSEQ
                                                 count = '001'
                                                 fnam  = 'BSEG-WRBTR'.
        IF sy-subrc EQ 0.
          ls_ftpost-fval  = <ls_ftpost>-fval.
        ENDIF.
        APPEND ls_ftpost TO xt_ftpost.

        LOOP AT lt_ddic_fields INTO DATA(ls_ddic_field) WHERE fieldname <> 'MANDT' . "#EC CI_STDSEQ
          ASSIGN COMPONENT ls_ddic_field-fieldname OF STRUCTURE ls_kontierung TO FIELD-SYMBOL(<v_value>).
          IF NOT <v_value> IS INITIAL.
            CASE ls_ddic_field-fieldname.
              WHEN 'GSBER' OR
                   'PRCTR' OR
                   'FIPEX' OR
                   'FISTL' OR
                   'GEBER' OR
                   'FKBER' OR
                   'SEGMENT'.
                CONCATENATE 'COBL-' ls_ddic_field-fieldname INTO ls_ftpost-fnam.
              WHEN 'BUKRS' OR
                   'SGTXT' OR
                   'HKONT'.
                CONCATENATE 'BSEG-' ls_ddic_field-fieldname INTO ls_ftpost-fnam.
              WHEN 'SAKNR'.
                ls_ftpost-fnam = 'BSEG-HKONT'.
              WHEN 'VALUT'.
                CONCATENATE 'BSEG-' ls_ddic_field-fieldname INTO ls_ftpost-fnam.
                READ TABLE xt_ftpost ASSIGNING <ls_ftpost>
                    WITH KEY stype = 'P'                 "#EC CI_STDSEQ
                             count = '001'
                             fnam  = 'BSEG-VALUT'.
                IF sy-subrc EQ 0.
                  ls_ftpost-fval = <ls_ftpost>-fval.
                ENDIF.
              WHEN 'BSCHL'.
                CONCATENATE 'BSEG-' ls_ddic_field-fieldname INTO ls_ftpost-fnam.
                READ TABLE xt_ftpost ASSIGNING <ls_ftpost>
                     WITH KEY stype = 'P'                "#EC CI_STDSEQ
                              count = '001'
                              fnam  = 'BSEG-BSCHL'.
                IF sy-subrc EQ 0.
                  IF <ls_ftpost>-fval EQ '40'.
                    ls_ftpost-fval  = '50'.
                  ELSEIF <ls_ftpost>-fval EQ '50'.
                    ls_ftpost-fval  = '40'.
                  ENDIF.
                ENDIF.
              WHEN OTHERS.
                CLEAR: ls_ftpost.
            ENDCASE.
            IF ls_ftpost IS NOT INITIAL.
              IF ls_ftpost-fval IS INITIAL.
                ls_ftpost-fval  = <v_value>.
              ENDIF.
              ls_ftpost-stype = 'P'.
              ls_ftpost-count = '002'.
              APPEND ls_ftpost TO xt_ftpost.
              CLEAR: ls_ftpost-fval.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_ftpost_from_kontier_k.
    DATA: ls_kontierung TYPE /thkr/kontierg_k,
          ls_ftpost     TYPE ftpost,
          lv_count      TYPE count_pi.

    DATA: o_desc        TYPE REF TO cl_abap_structdescr.

    SELECT SINGLE gsber prctr fipex aufnr kostl fistl geber fkber
           INTO CORRESPONDING FIELDS OF ls_kontierung
           FROM /thkr/kontierg_k
           WHERE bukrs = iv_bukrs
             AND hkont = iv_hkont.
    CHECK: ls_kontierung IS NOT INITIAL.

    o_desc ?= cl_abap_structdescr=>describe_by_name( '/THKR/KONTIERG_K' ).
    DATA(lt_ddic_fields) = o_desc->get_ddic_field_list( ).
    IF iv_count IS INITIAL.
      lv_count = '002'.
    ELSE.
      lv_count = iv_count.
    ENDIF.
    LOOP AT lt_ddic_fields INTO DATA(ls_ddic_field) WHERE fieldname <> 'MANDT' AND fieldname <> 'BUKRS' AND fieldname <> 'HKONT'. "#EC CI_STDSEQ
      ASSIGN COMPONENT ls_ddic_field-fieldname OF STRUCTURE ls_kontierung TO FIELD-SYMBOL(<v_value>).
      IF NOT <v_value> IS INITIAL.
        CONCATENATE 'COBL-' ls_ddic_field-fieldname INTO ls_ftpost-fnam.
        ls_ftpost-fval  = <v_value>.
        ls_ftpost-stype = 'P'.
        ls_ftpost-count = lv_count.
        APPEND ls_ftpost TO xt_ftpost.
      ENDIF.
    ENDLOOP.

    IF iv_mwskz IS NOT INITIAL.
      ls_ftpost-fnam  = 'BSEG-MWSKZ'.
      ls_ftpost-fval  = iv_mwskz.
      ls_ftpost-stype = 'P'.
      ls_ftpost-count = lv_count.
      APPEND ls_ftpost TO xt_ftpost.
    ENDIF.

    IF iv_budat IS NOT INITIAL AND iv_tabix IS NOT INITIAL.
      ls_ftpost-stype = 'K'.
      ls_ftpost-count = '001'.
      ls_ftpost-fnam  = 'BKPF-WWERT'.
      WRITE iv_budat  TO ls_ftpost-fval DD/MM/YYYY.
      INSERT ls_ftpost INTO xt_ftpost INDEX iv_tabix.
    ENDIF.
  ENDMETHOD.


  METHOD set_ftpost_soll.
    DATA: ls_ftpost  TYPE ftpost,
          lv_btr_str TYPE string,
          lv_tabix   TYPE sy-tabix,
          lv_betrag  TYPE string.

* Bruttobetrag um die Bankgebühren reduzieren
    READ TABLE xt_ftpost ASSIGNING FIELD-SYMBOL(<ls_ftpost>)
               WITH KEY stype = 'P'                      "#EC CI_STDSEQ
                        count = '001'
                        fnam  = 'BSEG-WRBTR'.
    IF sy-subrc EQ 0 AND is_febep-spesk IS NOT INITIAL.
      lv_betrag = is_febep-kwbtr - is_febep-spesk.
      lv_btr_str = lv_betrag.
      TRANSLATE lv_btr_str USING '.,'.
      SHIFT lv_btr_str LEFT DELETING LEADING space.
      WRITE lv_btr_str TO <ls_ftpost>-fval.
      CLEAR: lv_betrag, lv_btr_str.
    ENDIF.

    DATA(lt_ftpost) = xt_ftpost.

    SORT lt_ftpost BY count DESCENDING.
    LOOP AT lt_ftpost ASSIGNING <ls_ftpost>
            WHERE stype EQ 'P'.
      xv_count = <ls_ftpost>-count + 1.
      EXIT.
    ENDLOOP.
    DESCRIBE TABLE lt_ftpost LINES lv_tabix.
    IF sy-subrc EQ 0.
      lv_tabix = lv_tabix + 1.
    ENDIF.
    LOOP AT xt_ftpost ASSIGNING <ls_ftpost>
            WHERE stype EQ 'P'
            AND   count EQ '1'.
      CLEAR: ls_ftpost.
      CASE <ls_ftpost>-fnam.
        WHEN 'BSEG-BSCHL'.
          ls_ftpost-fval = <ls_ftpost>-fval.
        WHEN 'BSEG-SGTXT'.
          ls_ftpost-fval = 'Rücklastschriftgebühr'(005).
        WHEN 'BSEG-WRBTR'.
* Übergabe der Bankgebühren
          lv_betrag = is_febep-spesk.
          lv_btr_str = lv_betrag.
          TRANSLATE lv_btr_str USING '.,'.
          SHIFT lv_btr_str LEFT DELETING LEADING space.
          WRITE lv_btr_str TO ls_ftpost-fval.
          CLEAR: lv_betrag, lv_btr_str.
        WHEN 'BSEG-HKONT'.
* Ermittlung des Bankspesenkontos.
          SELECT SINGLE konts FROM t030 INTO ls_ftpost-fval
                              WHERE ktopl = 'VKP'
                              AND   ktosl = 'BSP'.
          xv_hkont = ls_ftpost-fval.
        WHEN OTHERS.
          ls_ftpost-fval =  <ls_ftpost>-fval.

      ENDCASE.
      ls_ftpost-stype = 'P'.
      ls_ftpost-count = xv_count.
      ls_ftpost-fnam  = <ls_ftpost>-fnam.
      INSERT ls_ftpost INTO xt_ftpost INDEX lv_tabix.
      lv_tabix = lv_tabix + 1.
    ENDLOOP.
  ENDMETHOD.


  METHOD set_ftpost_xblnr.
    DATA: lv_acctmp     TYPE feb_acctmp,
          lv_kaz        TYPE /thkr/d_kassenzeichen,
          lv_xblnr      TYPE xblnr,
          lv_blart      TYPE blart,
          lv_rc         TYPE nrreturn,
          lv_msgnr      TYPE msgnr,
          lv_pruef      TYPE char1.


    DATA: ls_kass   TYPE /thkr/t_kass.
* Kassenzeichen ermitteln
    LOOP AT xt_ftpost ASSIGNING FIELD-SYMBOL(<ls_ftpost>)
                      WHERE stype = 'K'
                      AND   count = '001'
                      AND   fnam  = 'BKPF-XBLNR'.
      CLEAR: lv_xblnr.
      SHIFT <ls_ftpost>-fval LEFT DELETING LEADING space.
      lv_xblnr = <ls_ftpost>-fval.
      EXIT.
    ENDLOOP.

* Belegart ermitteln
    LOOP AT xt_ftpost ASSIGNING <ls_ftpost>
            WHERE stype = 'K'
            AND   count = '001'
            AND   fnam  = 'BKPF-BLART'.
      CLEAR: ls_kass, lv_blart.
      SHIFT <ls_ftpost>-fval LEFT DELETING LEADING space.
      lv_blart = <ls_ftpost>-fval.
      SELECT SINGLE * FROM /thkr/t_kass INTO ls_kass
                      WHERE blart = lv_blart.
      EXIT.
    ENDLOOP.

    /thkr/cl_kassenzeichen=>check( EXPORTING i_xblnr       = lv_xblnr
                                             is_kass       = ls_kass
                                   IMPORTING e_pruefziffer = lv_pruef ##needed
                                             e_rc          = lv_rc ).
    IF lv_rc EQ 4.
* Ermittlung des Kontiervorlageneintrages
      me->get_kassenz_aus_gebkz( EXPORTING iv_kukey  = iv_kukey
                                           iv_esnum  = iv_esnum
                                 CHANGING  xv_acctmp = lv_acctmp ).
      IF lv_acctmp IS NOT INITIAL.
* Selektion der Kontierungsvorlage
        SELECT SINGLE * FROM feb_act INTO @DATA(ls_kontierung)
               WHERE acctmp = @lv_acctmp.

        IF ls_kontierung IS NOT INITIAL.
          IF ls_kontierung-geber IS NOT INITIAL AND ls_kontierung-gsber IS NOT INITIAL.
* Erstellen eines Kassenzeichens
            /thkr/cl_kassenzeichen=>create( EXPORTING i_fonds = ls_kontierung-geber
                                                      i_gsber = ls_kontierung-gsber
                                                      i_nrnr  = '00'
                                            IMPORTING e_kaz   = lv_kaz
                                                      e_rc    = lv_rc ).

            IF lv_rc <> 0.
              CONCATENATE '01' lv_rc INTO lv_msgnr.
              MESSAGE ID '/THKR/KLSA841'  TYPE 'E' NUMBER lv_msgnr.
              IF 1 = 2.
                MESSAGE e001(/thkr/klsa841).
              ENDIF.
            ELSE.
              LOOP AT xt_ftpost ASSIGNING <ls_ftpost>
                     WHERE stype = 'K'
                     AND   count = '001'
                     AND   fnam  = 'BKPF-XBLNR'.
                <ls_ftpost>-fval = lv_kaz.
                EXIT.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
* Keine Kontierung gefunden.
        IF sy-tcode NE 'FF_5'.
***          import_memory lv_kontier lv_kontier_ok  'KONTIERUNG'.
***          IF lv_kontier_ok EQ abap_true.
***            MESSAGE e004(/thkr/klsa841).
***          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD set_hkont_leitweg.
* Ermittlung des Sachkontos auf Basis von Einträgen in der DB-Tabelle T012K.

    IF is_febep-zz_iban IS NOT INITIAL.
      CLEAR: xv_hkont.
      SELECT hkont FROM t012k INTO xv_hkont
        UP TO 1 ROWS
        WHERE bukrs EQ is_febko-bukrs
        AND   bankn EQ is_febep-zz_iban+12(10).
      ENDSELECT.
    ENDIF.
  ENDMETHOD.


  METHOD set_iban_2_into_grpnr.

    DATA(lv_line) = strlen( xs_febep-zz_iban ).
    CHECK xs_febep-zz_iban IS NOT INITIAL.
    lv_line = lv_line - 2.
    IF xs_febep-grpnr IS INITIAL OR xs_febep-grpnr = '00'. "2026-02-13 js - Kein Überschreiben manuell gesetzter Bündelungsnummern
      xs_febep-grpnr = xs_febep-zz_iban+lv_line.
    ENDIF.
  ENDMETHOD.


  METHOD set_kontierung.
* Methode zum Aufbau der int. Tabelle XT_FEBCL mit dem Aufruf von Kontierungsfuba's
* Der Methodenaufruf erfolgt mittels User-Exit EXIT_RFEBBU10_001 und inkludiertem Report ZXF01U01
* Die registrierten Fuba's werden zur Laufzeit dynamisch aufgerufen

    DATA: lv_flag1 TYPE t033f-attr2,
          lv_flag2 TYPE t033f-attr2,
          lv_csnum TYPE csnum_eb,
          ls_febcl TYPE febcl,
          lv_kblk  TYPE c.

*--- 1. Ermittlung der Buchungsart aus der Kontenfindung für Buchungsbereich 1 und 2
    CLEAR: lv_flag1, lv_flag2.

    SELECT SINGLE attr2 FROM t033f INTO lv_flag1 WHERE anwnd = '0001'
                                                   AND eigr1 = is_febep-vgint
                                                   AND eigr2 = '1'
                                                   AND eigr3 = space
                                                   AND eigr4 = space.
    SELECT SINGLE attr2 FROM t033f INTO lv_flag2 WHERE anwnd = '0001'
                                                   AND eigr1 = is_febep-vgint
                                                   AND eigr2 = '2'
                                                   AND eigr3 = space
                                                   AND eigr4 = space.

    import_memory lv_kblk lv_kblk 'ELKO_KBLK'.
    IF lv_kblk EQ abap_true.

      FIELD-SYMBOLS: <ls_febcl> TYPE febcl.

*--- 2. Ermittlung der höchsten CSNUM, falls mindestens eine Registrierung notwendig wird
      IF NOT ( lv_flag1 IS INITIAL AND lv_flag2 IS INITIAL ).
        CLEAR lv_csnum.
        LOOP AT xt_febcl ASSIGNING <ls_febcl>.
          IF <ls_febcl>-csnum > lv_csnum.
            lv_csnum = <ls_febcl>-csnum.
          ENDIF.
        ENDLOOP.
        lv_csnum = lv_csnum + 1.

*--- 3. Registrierung der Funktionsbausteine für die jeweiligen Buchungsbereiche
        IF lv_flag1 = '1' OR lv_flag1 = '2' OR lv_flag1 = '3'.
          READ TABLE xt_febcl ASSIGNING FIELD-SYMBOL(<ls_febcl_buk>)
                  INDEX 1.
          IF sy-subrc EQ 0.
            ls_febcl-agbuk = <ls_febcl_buk>-agbuk.
          ENDIF.
          ls_febcl-kukey  = is_febep-kukey.
          ls_febcl-esnum  = is_febep-esnum.
          ls_febcl-csnum  = lv_csnum.
          ls_febcl-selfd  = 'FB'.
          ls_febcl-selvon = '/THKR/FEB_1_KONTIERUNG'.
          APPEND ls_febcl TO xt_febcl.
          lv_csnum = lv_csnum + 1.
        ENDIF.
        IF lv_flag2 = '1' OR lv_flag2 = '2' OR lv_flag2 = '3'.
          READ TABLE xt_febcl ASSIGNING <ls_febcl_buk>
                            INDEX 1.
          IF sy-subrc EQ 0.
            ls_febcl-agbuk = <ls_febcl_buk>-agbuk.
          ENDIF.
          ls_febcl-kukey  = is_febep-kukey.
          ls_febcl-esnum  = is_febep-esnum.
          ls_febcl-csnum  = lv_csnum.
          ls_febcl-selfd  = 'FB'.
          ls_febcl-selvon = '/THKR/FEB_2_KONTIERUNG'.
          APPEND ls_febcl TO xt_febcl.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR lv_csnum.
      LOOP AT xt_febcl ASSIGNING <ls_febcl>.
        IF <ls_febcl>-csnum > lv_csnum.
          lv_csnum = <ls_febcl>-csnum.
        ENDIF.
      ENDLOOP.
      IF is_febep-vgint = gc_vgint_0014 AND ( is_febep-intag = '019' OR is_febep-intag = '020' ).
        lv_csnum = lv_csnum + 1.           " REPRO-SCJ20210713
        READ TABLE xt_febcl ASSIGNING <ls_febcl_buk>
                          INDEX 1.
        IF sy-subrc EQ 0.
          ls_febcl-agbuk = <ls_febcl_buk>-agbuk.
        ENDIF.
        ls_febcl-kukey  = is_febep-kukey.
        ls_febcl-esnum  = is_febep-esnum.
        ls_febcl-csnum  = lv_csnum.
        ls_febcl-selfd  = 'FB'.
        ls_febcl-selvon = '/THKR/FEB_1_BUCHUNG'.     " Anpassung bei Kursdifferenzen im  FB 'ZFI_FEB_1_BUCHUNG'.
        APPEND ls_febcl TO xt_febcl.
      ENDIF.
*--- 1. Ermittlung der Buchungsart aus der Kontenfindung für Buchungsbereich 2
      IF ( is_febep-intag = '901' OR is_febep-intag = '902' ).
        lv_csnum = lv_csnum + 1.
        READ TABLE xt_febcl ASSIGNING <ls_febcl_buk>
                   INDEX 1.
        IF sy-subrc EQ 0.
          ls_febcl-agbuk = <ls_febcl_buk>-agbuk.
        ENDIF.
        ls_febcl-kukey  = is_febep-kukey.
        ls_febcl-esnum  = is_febep-esnum.
        ls_febcl-csnum  = lv_csnum.
        ls_febcl-selfd  = 'FB'.
        ls_febcl-selvon = '/THKR/FEB_2_ACC_ASS_KONT'.
        APPEND ls_febcl TO xt_febcl.
      ENDIF.
* Kontierung ergänzen bei Rückläufern
      IF is_febep-vgint = gc_vgint_1020.
        lv_csnum = lv_csnum + 1.
        IF lv_flag1 = '1' OR lv_flag1 = '9'.
          READ TABLE xt_febcl ASSIGNING <ls_febcl_buk>
                            INDEX 1.
          IF sy-subrc EQ 0.
            ls_febcl-agbuk = <ls_febcl_buk>-agbuk.
          ENDIF.
          ls_febcl-kukey  = is_febep-kukey.
          ls_febcl-esnum  = is_febep-esnum.
          ls_febcl-csnum  = lv_csnum.
          ls_febcl-selfd  = 'FB'.
          ls_febcl-selvon = '/THKR/FEB_1_KONTIERUNG'.
          APPEND ls_febcl TO xt_febcl.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_kontiervorlage.
* Bei gefüllter Kontievorlagekennung wird die DB-Tabelle FEB_ACCNT_SAVE mit Inhalten gefüllt.
    IF iv_acctmp IS NOT INITIAL AND iv_kukey IS NOT INITIAL AND iv_esnum IS NOT INITIAL.
      insert_feb_accnt_save( EXPORTING iv_kukey       = iv_kukey
                                       iv_esnum       = iv_esnum
                                       iv_acctmp      = iv_acctmp
                             CHANGING  xt_assign_line = xt_assign_line ).

    ENDIF.
  ENDMETHOD.


  METHOD set_refresh_itab.
    CLEAR:   xv_gebkz,
             xv_ueberz,
             xt_kassz,
             xt_bsid,
             xt_bsik,
             xt_kblk,
             xt_avip_out.
  ENDMETHOD.


  METHOD set_sgtxt_from_vwezw.

    SELECT SINGLE * FROM febre INTO @DATA(ls_febre)
      WHERE kukey = @is_febep-kukey
        AND esnum = @is_febep-esnum
        AND rsnum = '001'.
    IF sy-subrc EQ 0.
      CLEAR: xv_sgtxt.
      xv_sgtxt = ls_febre-vwezw.
    ENDIF.
  ENDMETHOD.


  METHOD set_sgtxt_to_febep.
    DATA: lv_test   TYPE char1,
          lv_data   TYPE char70,
          ls_febep  TYPE febep,
          ls_ftpost TYPE ftpost,
          lv_vwezw  TYPE vwezw_eb.

    FIELD-SYMBOLS: <ls_febep> TYPE febep.

    import_memory test lv_test  'ELKO_TEST'.
    IF lv_test IS INITIAL.
      lv_data = '(RFEBBU10)febep'.
      ASSIGN (lv_data) TO <ls_febep>.
    ELSE.
      ASSIGN ls_febep TO <ls_febep>.
    ENDIF.
    IF <ls_febep> IS ASSIGNED.
      IF <ls_febep>-sgtxt IS INITIAL.
        CLEAR: lv_vwezw.
        SELECT vwezw FROM febre INTO lv_vwezw
          WHERE kukey = <ls_febep>-kukey
            AND esnum = <ls_febep>-esnum
            AND rsnum = '001'.
        ENDSELECT.
        IF sy-subrc EQ 0.
          <ls_febep>-sgtxt = lv_vwezw.
          CLEAR: lv_vwezw.
        ENDIF.
      ENDIF.
      IF iv_ftpost IS NOT INITIAL.
        CLEAR: ls_ftpost.
        ls_ftpost-stype = 'P'.
        ls_ftpost-count = '002'.
        ls_ftpost-fnam  = 'BSEG-SGTXT'.
        ls_ftpost-fval  = <ls_febep>-sgtxt.
        APPEND ls_ftpost TO xt_ftpost.
      ENDIF.
    ELSE.
      IF iv_ftpost IS NOT INITIAL AND iv_vwezw IS NOT INITIAL.
        CLEAR: ls_ftpost.
        ls_ftpost-stype = 'P'.
        ls_ftpost-count = '002'.
        ls_ftpost-fnam  = 'BSEG-SGTXT'.
        ls_ftpost-fval  = iv_vwezw.
        APPEND ls_ftpost TO xt_ftpost.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD set_tilgungsfolge_bsid.
* Die Tilgungsreihenfolge bestimmt die Priorität der Verbeitungsfolge.
*--- Regel des Mahnbereiches bestimmen
    LOOP AT xt_bsid ASSIGNING FIELD-SYMBOL(<ls_bsid>).
      SELECT b~rangf FROM /thkr/tilg_maber AS a INNER JOIN
                          /thkr/tilg_rangf AS b
                          ON    a~regel = b~regel
                          INTO @DATA(lv_rangf)
                          WHERE a~maber EQ @<ls_bsid>-maber
                          AND   b~blart EQ @<ls_bsid>-blart.
      ENDSELECT.
      IF sy-subrc = 0.
        <ls_bsid>-rangf = lv_rangf.
      ELSE.
        SELECT b~rangf FROM /thkr/tilg_maber AS a INNER JOIN
                            /thkr/tilg_rangf AS b
                            ON    a~regel = b~regel
                            INTO @lv_rangf
                            WHERE a~maber EQ @space
                            AND   b~blart EQ @<ls_bsid>-blart.
        ENDSELECT.
        IF sy-subrc  = 0.
          <ls_bsid>-rangf = lv_rangf.
        ELSE.
          <ls_bsid>-rangf = '0'.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_zahlbetrag_kwbtr.
* Füllen von Memorys und Aktualisierung der FEBEP
    DATA:lv_test TYPE c,
         lv_elko TYPE c.

    CLEAR: xv_kwbtr.
    import_memory test lv_test  'ELKO_TEST'.
    import_memory elko lv_elko  'ELKO_TAB'.

    IF lv_test EQ abap_true.
      IF lv_elko EQ abap_true.
        xv_kwbtr = is_febep-kwbtr.
      ELSE.
        import_memory kwbtr xv_kwbtr  'KWBTR_901'.
      ENDIF.
    ELSE.
      xv_kwbtr = is_febep-kwbtr.
    ENDIF.
    export_memory lv_zahlb xv_kwbtr  'ZAHLBETRAG'.
  ENDMETHOD.


  METHOD set_zahlungs_abzug.
    DATA: lv_zahlbetrag TYPE kwbtr,
          ls_zahl       TYPE /thkr/s_elko_items,
          lt_zahlungen  TYPE /thkr/tt_elko_items,
          lt_bsid       TYPE /thkr/tt_elko_items,
          ls_teilz      TYPE ts_teilzahlung,
          lt_teilz      TYPE tt_teilzahlung.

    CLEAR: lt_zahlungen, lt_bsid, lt_teilz.
    lt_bsid = xt_bsid.

* 1. Zahlungen und Gutschriften zuordnen (SHKZG = 'H', REBZG vorhanden)
    LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<ls_bsid>).
      IF <ls_bsid>-shkzg = 'H'.
        CLEAR: ls_zahl.
        ls_zahl = <ls_bsid>.
        APPEND ls_zahl TO  lt_zahlungen.
        DELETE lt_bsid WHERE belnr = ls_zahl-belnr
                       AND   gjahr = ls_zahl-gjahr.
      ENDIF.
    ENDLOOP.

    CLEAR: xt_bsid.
    LOOP AT lt_bsid ASSIGNING <ls_bsid>.
      LOOP AT lt_zahlungen ASSIGNING FIELD-SYMBOL(<ls_zahl>)
              WHERE rebzg EQ <ls_bsid>-belnr
              AND   rebzj EQ <ls_bsid>-gjahr.
        <ls_zahl>-rangf = <ls_bsid>-rangf.
        APPEND <ls_zahl> TO xt_bsid.
        DELETE lt_zahlungen.
      ENDLOOP.
      IF <ls_bsid>-shkzg EQ 'S'.
        APPEND <ls_bsid> TO xt_bsid.
      ENDIF.
      AT LAST.
        APPEND LINES OF lt_zahlungen TO xt_bsid.
      ENDAT.
    ENDLOOP.



*    SORT xt_bsid BY rangf ASCENDING.

* Zahlungen entfernen, wenn kein vollständiger Ausgleich möglich ist

    CLEAR: lv_zahlbetrag.
    set_zahlbetrag_kwbtr( EXPORTING is_febep = is_febep
                          CHANGING  xv_kwbtr = lv_zahlbetrag ).

    "--------------------------------------------------
    " 1. Rechnungen korrekt sammeln (nur DR, summiert)
    "--------------------------------------------------
    LOOP AT xt_bsid ASSIGNING <ls_bsid>
         WHERE blart NE 'DZ'
           AND belnr IS NOT INITIAL.

      READ TABLE lt_teilz ASSIGNING FIELD-SYMBOL(<ls_teilz>)
           WITH KEY belnr = <ls_bsid>-belnr
                    gjahr = <ls_bsid>-gjahr.
      IF sy-subrc = 0.
        <ls_teilz>-wrbtr = <ls_teilz>-wrbtr + <ls_bsid>-wrbtr.
      ELSE.
        CLEAR ls_teilz.
        ls_teilz-belnr = <ls_bsid>-belnr.
        ls_teilz-gjahr = <ls_bsid>-gjahr.
        ls_teilz-wrbtr = <ls_bsid>-wrbtr.
        ls_teilz-dzdel = abap_false.
        INSERT ls_teilz INTO TABLE lt_teilz.
      ENDIF.

    ENDLOOP.

    "--------------------------------------------------
    " 2. DZ-Beträge je Rechnung abziehen
    "--------------------------------------------------
    LOOP AT xt_bsid ASSIGNING <ls_bsid>
         WHERE blart = 'DZ'
           AND rebzg IS NOT INITIAL.

      READ TABLE lt_teilz ASSIGNING <ls_teilz>
           WITH KEY belnr = <ls_bsid>-rebzg
                    gjahr = <ls_bsid>-rebzj.

      IF sy-subrc = 0.
        <ls_teilz>-wrbtr = <ls_teilz>-wrbtr - <ls_bsid>-wrbtr.
      ENDIF.

    ENDLOOP.

    "--------------------------------------------------
    " 3. Entscheidung je Rechnung
    "--------------------------------------------------
    LOOP AT lt_teilz ASSIGNING <ls_teilz>.
      IF <ls_teilz>-wrbtr > 0
         AND lv_zahlbetrag < <ls_teilz>-wrbtr.
        <ls_teilz>-dzdel = abap_true.
      ENDIF.
    ENDLOOP.

    "--------------------------------------------------
    " 4. Nur DZ der betroffenen Rechnungen löschen
    "--------------------------------------------------
    LOOP AT xt_bsid ASSIGNING <ls_bsid>.
      IF <ls_bsid>-blart = 'DZ'
         AND <ls_bsid>-rebzg IS NOT INITIAL.

        READ TABLE lt_teilz ASSIGNING <ls_teilz>
             WITH KEY belnr = <ls_bsid>-rebzg
                      gjahr = <ls_bsid>-rebzj.

        IF sy-subrc = 0
           AND <ls_teilz>-dzdel = abap_true.
          DELETE xt_bsid.
        ENDIF.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
