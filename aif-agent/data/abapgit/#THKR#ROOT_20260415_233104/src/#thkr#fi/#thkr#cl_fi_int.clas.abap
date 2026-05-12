class /THKR/CL_FI_INT definition
  public
  final
  create public .

public section.

  methods GET_TDTO_FI_DOCUMENT
    importing
      !I_SELECTION type /THKR/S_FI_DOCUMENT_SELECTION
      !I_RAISE_EXCEPTIONS type XFELD optional
    exporting
      !ET_DTO type /THKR/T_DTO_FI_DOCUMENT .
protected section.
private section.

  methods FILL_DTO_FI_DOCUMENT
    importing
      !I_SELECTION type /THKR/S_FI_DOCUMENT_SELECTION
      !I_RAISE_EXCEPTIONS type XFELD
    exporting
      !E_DELETE_LINE type XFELD
    changing
      !C_DTO type /THKR/S_DTO_FI_DOCUMENT
    raising
      /THKR/CX_FI .
ENDCLASS.



CLASS /THKR/CL_FI_INT IMPLEMENTATION.


  METHOD fill_dto_fi_document.
*
*    DATA: l_helpers      TYPE REF TO /THKR/CL_helpers,
*          l_zcx_FI       TYPE REF TO /thkr/cx_fi,
*          l_str_bukrs    TYPE string,
*          l_str_cpudt    TYPE string,
**          l_gbkzg        TYPE zjva_fi_gbk,
*          l_shkzg        TYPE shkzg,
*          l_is_teilsknto TYPE xfeld,
*          l_shkzg_dk     TYPE xfeld,  "Soll/Haben-Kennzeichen der Debitor/Kreditor-Zeile
*          l_sknto        TYPE dmbtr,
*          l_is_ige       TYPE xfeld.  "Kennzeichen Innergemeinschaftlicher Erwerb
*
*    DATA: l_sktoprz        TYPE dzbd1p.
*    DATA: l_bas_sknto      TYPE dmbtr.
*    DATA: l_sum_sknto      TYPE dmbtr.
*    DATA: l_dif_sknto      TYPE dmbtr.
*    DATA: l_sum_btrg       TYPE dmbtr.
*    DATA: l_dif_btrg       TYPE dmbtr.
*    DATA: l_bel_btrg       TYPE dmbtr.
*    DATA: l_bel_fbtrg      TYPE dmbtr.
*    DATA: l_zeile(3)       TYPE n.
*    DATA: l_bkdf           TYPE bkdf.
*    DATA: l_months         TYPE i.
*    DATA: l_tage           TYPE dzbd1t.
*    DATA: l_zfbdt_1        TYPE dzfbdt.
*
*    DATA: l_bldat(10) TYPE c,
*          l_kunnr(10) TYPE c,
*          l_lifnr(10) TYPE c.
*
**    DATA: l_dto_kreditor  TYPE zsjva_dto_kreditor.
*    DATA: l_t001 TYPE t001.
*
*    CLEAR e_delete_line.
*
*    l_helpers =  /THKR/CL_helpers=>get_instance( ).
*
*    CLEAR l_t001.
*    SELECT * INTO CORRESPONDING FIELDS OF l_t001
*      UP TO 1 ROWS
*      FROM t001
*      WHERE bukrs EQ c_dto-bukrs.
*    ENDSELECT.
*
**    CONCATENATE c_dto-awref_rev c_dto-aworg_rev INTO c_dto-awkey_rev.
*
**    get_id_fi_document(
**      EXPORTING
**        i_bukrs = c_dto-bukrs
**        i_gjahr = c_dto-gjahr
**        i_belnr = c_dto-belnr
**      IMPORTING
**        e_id    = c_dto-document_id ).
**
**    "Buchungskennzeichen/ PK-Nr.
**    determine_bkz_pk_nr(
**      EXPORTING
**        i_xref1_hd = c_dto-xref1_hd
**        i_xref2_hd = c_dto-xref2_hd
**      IMPORTING
**        e_bkz      = c_dto-bkz
**        e_pk_nr    = c_dto-pk_nr ).
*
*    "Dauerbuchungsbeleg - Fälligkeiten ermitteln
*    CLEAR l_bkdf.
*    SELECT * INTO CORRESPONDING FIELDS OF l_bkdf
*      UP TO 1  ROWS
*      FROM bkdf
*      WHERE bukrs EQ c_dto-dbblg_bukrs
*        AND belnr EQ c_dto-dbblg
*        AND gjahr EQ c_dto-dbblg_gjahr
*        ORDER BY PRIMARY KEY.
*    ENDSELECT.
*    IF sy-subrc EQ 0.
*      "Erste Fälligkeit: Tag des Monats lt. Dauerbuchungsbeleg
*      "Grundlage ist das Buchungsdatum
*      c_dto-dbbdt = c_dto-budat.
*
*      "Letzte Fälligkeit
*      "Grundlage erste Fälligkeit
*      TRY.
*          l_months = l_bkdf-dbmon.
*          c_dto-dbedt = cl_bs_period_toolset_basics=>add_months_to_date( iv_date = c_dto-dbbdt
*                                                                            iv_months = l_months ).
*        CATCH cx_bs_period_toolset_basics.
*          "offen.
*      ENDTRY.
*    ENDIF.
*
*    "Belegzeilen
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE @c_dto-t_line
*      FROM bseg
*      WHERE bukrs = @c_dto-bukrs
*      AND   belnr = @c_dto-belnr
*      AND   gjahr = @c_dto-gjahr
*      ORDER BY buzei.
*
*    CLEAR: l_bel_btrg, l_bel_fbtrg, l_sktoprz, l_zfbdt_1.
*
*    LOOP AT c_dto-t_line ASSIGNING FIELD-SYMBOL(<line>).
*
*      IF <line>-koart = 'D' OR <line>-koart = 'K'.
*        "Bei Personenzeilen
*        l_bel_btrg  = <line>-dmbtr. "Hauswährung
*        l_bel_fbtrg = <line>-wrbtr. "Belegwährung
*
*        l_shkzg_dk = <line>-shkzg.  "Soll/Haben-Kennzeichen der Debitor/Kreditor-Zeile
*
*        IF <line>-lifnr IS NOT INITIAL.
*          "Merke Liferanten-Nr. auf Kopfebene
*          c_dto-lifnr = <line>-lifnr.
*
**          "Ermittlung Kontonummer beim Lieferanten
**          CLEAR l_dto_kreditor.
**
**          me->get_dto_kreditor(
**            EXPORTING
**              i_bukrs          = c_dto-bukrs
**              i_lifnr          = <line>-lifnr
**            IMPORTING
**              e_dto            = l_dto_kreditor ).
**
**          IF l_dto_kreditor-abwze IS NOT INITIAL.
**            c_dto-zempf = l_dto_kreditor-abwze.
**          ELSE.
**            c_dto-zempf = <line>-lifnr.
**          ENDIF.
*
*          "Aufbereitung Belegsegmenttext --> IHV Verwendungszweck
*          "Das Feld Verwendungszweck in IHV entspricht dem Feld Verwendungszweck bei einer normalen Überweisung,
*          "diese Daten erscheinen am Ende beim Lieferanten auf seinem Kontoauszug.
*          CLEAR: l_bldat, l_kunnr, l_lifnr.
*
**          IF l_dto_kreditor-eikto IS INITIAL.
**            WRITE <line>-lifnr TO l_lifnr NO-ZERO.
**          ELSE.
**            WRITE l_dto_kreditor-eikto TO l_lifnr NO-ZERO.
**          ENDIF.
*          CONDENSE l_lifnr NO-GAPS.
*          WRITE c_dto-bldat TO l_bldat DD/MM/YYYY.
**          CONCATENATE 'KdNr:' l_lifnr
**                      'ReNr:' c_dto-xblnr
**                      'vom'  l_bldat
**                      INTO <line>-sgtxt_jva SEPARATED BY space.
*
*          "Prüfung Bankverbindung im Beleg
*          IF <line>-bvtyp IS INITIAL.
**            "Wenn kein BVTYP (Partnerbanktyp) im Beleg angegeben ist,
**            SORT l_dto_kreditor-t_bankdetail BY bvtyp ASCENDING.
**            LOOP AT l_dto_kreditor-t_bankdetail INTO DATA(l_bankdetail).
**              "wird die erste Bankverbindung mit gültiger IBAN vorbelegt
**              IF NOT l_bankdetail-iban IS INITIAL.
**                <line>-bvtyp = l_bankdetail-bvtyp.
**                EXIT.
**              ENDIF.
**            ENDLOOP.
*          ENDIF.
*
*          "Merke Zahlungsbedingung % ZBD1P
*          "Prüfung Skontoabzug (vergangene Zeit bis aktuellen Tag)
*          "Skontobasisbetrag wird später ermittelt.
*          "Skontobasisbetrag aus der Kreditorenzeile berücksichtigt nicht, ob eine
*          "Position skontorelevant ist oder nicht
*          TRY.
*              IF i_selection-calc_discount = abap_true.    "Option, um stets Skonto unter Berücksichitigung der Rundungsdifferenzen ermitteln zu können
*                "Grundlage für die verbuchung der Zahlungsinformationen
*                l_sktoprz = <line>-zbd1p.                  "Skonto wird gewährt auf alle relevanten Positionen
*              ELSE.
*                CLEAR l_tage.
*                l_tage    = sy-datum - <line>-zfbdt.       "Anzahl der Tage = aktuelles Datum - Basisdatum der Fälligkeit
*                l_zfbdt_1 = <line>-zfbdt + <line>-zbd1t.   "Fälligkeit der ersten Zahlungsbedingung (=Skontoziel)
*
*                "Prüfen ob Skontoziel (Datum) noch nicht überschritten ist.
*                IF l_tage LE <line>-zbd1t.
*                  l_sktoprz = <line>-zbd1p. "Skonto wird gewährt auf alle relevanten Positionen
*                ENDIF.
*
*              ENDIF.
*            CATCH cx_sy_arithmetic_error.
*              "Bei Rechnenfehlern (falsches Basisdatum) gibt es kein Skonto
*          ENDTRY.
*
*        ELSE.                                    "Faktura
*
*          "Merke Kunden-Nr. auf Kopfebene
*          c_dto-kunnr = <line>-kunnr.
*
*          "Aufbereitung Belegsegmenttext --> IHV Verwendungszweck
*          WRITE <line>-kunnr TO l_kunnr NO-ZERO.
*          CONDENSE l_kunnr NO-GAPS.
*          WRITE c_dto-bldat TO l_bldat DD/MM/YYYY.
*          CONCATENATE 'KdNr:' l_kunnr
*                      'ReNr:' c_dto-xblnr
*                      'vom'   l_bldat
*                      INTO <line>-sgtxt SEPARATED BY space.
*        ENDIF.
*
*        "LZB-Kennziffern bei Personenzeile
*        "Bezeichner ermitteln
*        SELECT * INTO @DATA(l_t015l)
*          UP TO 1 ROWS
*          FROM t015l
*          WHERE lzbkz = @<line>-lzbkz
*          ORDER BY PRIMARY KEY.
*        ENDSELECT.
*        IF sy-subrc EQ 0.
*          <line>-lzbkz_zwck1 = l_t015l-zwck1.
*          <line>-lzbkz_zwck2 = l_t015l-zwck2.
*        ENDIF.
*
*      ELSEIF <line>-koart = 'S' AND <line>-buzid = 'T'.
*        "Steuerzeile
*        IF <line>-shkzg = l_shkzg_dk. "Steuerzeile hat gleiches S/H-Kennzeichen wie Forderung/Verbindlichkeit
*          "Der Gesamtbetrag des Beleges muss um den Betrag der Steuerzeile ergänzt werden.
*          ADD <line>-dmbtr TO l_bel_btrg. "Hauswährung
*          ADD <line>-wrbtr TO l_bel_fbtrg. "Belegwährung
*          l_is_ige = 'X'.   "Innergemeinschaftlicher Erwerb, d.h. Steuer geht nicht an Kreditor
*        ELSE.
*          "Der Gesamtbetrag des Beleges muss um den Betrag der Steuerzeile vermindert werden.
*          SUBTRACT <line>-dmbtr FROM l_bel_btrg. "Hauswährung
*          SUBTRACT <line>-wrbtr FROM l_bel_fbtrg. "Belegwährung
*        ENDIF.
*      ENDIF.
*
*      "Ermittlung Nettofälligkeit (IHV)
*      "Wenn Skonto gewährt wird: Nettofälligkeit = Skontofälligkeit
*      IF c_dto-lifnr IS NOT INITIAL AND l_sktoprz NE 0.    "Skonto wurde gewährt
*        <line>-netdt = l_zfbdt_1.
*      ELSE.
*        "Wenn Skonto nicht gewährt wird: Nettofälligkeit lt. Zahlungsbedingungen
*        SELECT netdt INTO @<line>-netdt
*          FROM acdoca
*          WHERE rbukrs = @c_dto-bukrs
*          AND   belnr  = @c_dto-belnr
*          AND   gjahr  = @c_dto-gjahr
*          AND   buzei  = @<line>-buzei.
*        ENDSELECT.
*      ENDIF.
*
*      "Aggregation Sachkontenzeilen mit Berücksichtigung des Steuerkennzeichens
*      IF <line>-koart EQ 'S' OR <line>-koart = 'A'.
*        IF <line>-buzid NE 'Z' AND    "Skonto
*           <line>-buzid NE 'T'.       "Steuer
*
**          CLEAR: l_gbkzg.
*
*
*          IF <line>-xskrl IS NOT INITIAL.
*            "Kennzeichen 'Ohne Skonto' ist gesetzt
*            l_is_teilsknto = 'X'.
*          ENDIF.
*
**          "Kennzeichen Gutschrift / Belastung setzen (Abhängig vom Kontotyp (Bilanzkonto/Erfolgskonto) und Soll-/Haben-Kennzeichen)
**          "Relevant bei Umbuchungen und Umbuchungen barer Verwahreinzahlungen
**          IF <line>-xbilk = 'X'.    "Bestandskonto
**            IF <line>-shkzg = 'S'.
**              l_gbkzg = 'G'.
**            ELSE.
**              l_gbkzg = 'B'.
**            ENDIF.
**          ELSE.
**            IF <line>-shkzg = 'S'.
**              l_gbkzg = 'B'.
**            ELSE.
**              l_gbkzg = 'G'.
**            ENDIF.
**          ENDIF.
**
**          IF <line>-gvtyp = 'X'.    "Erfolgskontotyp ???
**            IF <line>-shkzg = 'S'.
**              l_gbkzg = 'B'.
**            ELSE.
**              l_gbkzg = 'G'.
**            ENDIF.
**          ELSE.
**            IF <line>-shkzg = 'S'.
**              l_gbkzg = 'G'.
**            ELSE.
**              l_gbkzg = 'B'.
**            ENDIF.
**          ENDIF.
**
**          READ TABLE c_dto-t_line_aggr_tax
**            WITH KEY fipos = <line>-fipos
**                     fistl = <line>-fistl
**                     mwskz = <line>-mwskz
**                     prctr = <line>-prctr
**                     kostl = <line>-kostl
**                     geber = <line>-geber
**            ASSIGNING FIELD-SYMBOL(<line_aggr_tax>).
**
**          "Aggregation unterdrücken - Sonderfall Sachkontenbuchung mit Titelzusatz
**          IF i_selection-no_aggr = abap_true OR c_dto-blart = 'ST'.
**            APPEND INITIAL LINE TO c_dto-t_line_aggr_tax ASSIGNING <line_aggr_tax>.
**
**            MOVE-CORRESPONDING <line> TO <line_aggr_tax>.
**            <line_aggr_tax>-bnett = <line>-txbhw.
**            <line_aggr_tax>-gbkzg = l_gbkzg.
**            "Währungsschlüssel aus den Belegkopf (!)
**            "Da bei Sachkontenzeilen nur in Hauswährung fortgeschrieben wird
**            <line_aggr_tax>-waers = c_dto-waers.
**            IF <line>-xskrl IS INITIAL.
**              "Wenn Kennzeichen 'Ohne Skonto' nicht gesetzt ist:
**              <line_aggr_tax>-sknto_base = <line>-dmbtr.
**              <line_aggr_tax>-skfbt      = <line>-wrbtr.
**            ENDIF.
**          ELSE.
**            "Aggregation der Buchungszeilen nach Steuerkennzeichen und CO-Kontierung:
**            "Finanzposition
**            "Finanzstelle
**            "Mehrwertsteuerkennzeichen
**            "Profitcenter
**            "Kostenstelle
**            "Fonds
**            IF sy-subrc <> 0.
**              APPEND INITIAL LINE TO c_dto-t_line_aggr_tax ASSIGNING <line_aggr_tax>.
**
**              MOVE-CORRESPONDING <line> TO <line_aggr_tax>.
**              <line_aggr_tax>-bnett = <line>-txbhw.
**              <line_aggr_tax>-gbkzg = l_gbkzg.
**              "Währungsschlüssel aus den Belegkopf (!)
**              "Da bei Sachkontenzeilen nur in Hauswährung fortgeschrieben wird
**              <line_aggr_tax>-waers = c_dto-waers.
**              IF <line>-xskrl IS INITIAL.
**                "Wenn Kennzeichen 'Ohne Skonto' nicht gesetzt ist:
**                <line_aggr_tax>-sknto_base = <line>-dmbtr.
**                <line_aggr_tax>-skfbt      = <line>-wrbtr.
**              ENDIF.
**            ELSE.
*****         IF <line_aggr_tax>-gbkzg = l_gbkzg.
**              IF <line_aggr_tax>-shkzg = <line>-shkzg.
**                ADD <line>-dmbtr TO <line_aggr_tax>-dmbtr.
**                ADD <line>-wrbtr TO <line_aggr_tax>-wrbtr.
**                ADD <line>-skfbt TO <line_aggr_tax>-skfbt.
**                ADD <line>-sknto TO <line_aggr_tax>-sknto.
**                ADD <line>-wskto TO <line_aggr_tax>-wskto.
**                ADD <line>-txbhw TO <line_aggr_tax>-bnett.
**                IF <line>-xskrl IS INITIAL.
**                  "Wenn Kennzeichen 'Ohne Skonto' nicht gesetzt ist:
**                  ADD <line>-dmbtr TO <line_aggr_tax>-sknto_base.
**                  ADD <line>-wrbtr TO <line_aggr_tax>-skfbt.
**                ENDIF.
**              ELSE.
**                CLEAR <line_aggr_tax>-bschl.  "weil Zeilen mit untersch. Buchungsschlüsseln addiert werden
**
**                <line_aggr_tax>-dmbtr -= <line>-dmbtr.
**                <line_aggr_tax>-wrbtr -= <line>-wrbtr.
**                <line_aggr_tax>-skfbt -= <line>-skfbt.
**                <line_aggr_tax>-sknto -= <line>-sknto.
**                <line_aggr_tax>-wskto -= <line>-wskto.
**                <line_aggr_tax>-bnett -= <line>-txbhw.
**                IF <line>-xskrl IS INITIAL.
**                  "Wenn Kennzeichen 'Ohne Skonto' nicht gesetzt ist:
**                  <line_aggr_tax>-sknto_base -= <line>-dmbtr.
**                  <line_aggr_tax>-skfbt      -= <line>-wrbtr.
**                ENDIF.
**              ENDIF.
**              IF <line_aggr_tax>-koart <> <line>-koart.
**                "Unterschiedliche Kontoarten
**                CLEAR <line_aggr_tax>-koart.
**              ENDIF.
**              IF <line_aggr_tax>-hkont <> <line>-hkont.
**                "Unterschiedliche Hauptbuchkonten
**                CLEAR <line_aggr_tax>-hkont.
**              ENDIF.
**
**            ENDIF.
**          ENDIF.
*        ENDIF.
*      ENDIF.
*
*    ENDLOOP.
**
**    LOOP AT c_dto-t_line_aggr_tax ASSIGNING <line_aggr_tax> WHERE dmbtr < '0.00'.
**      "Wenn der aggregierte Betrag negativ ist: Soll/Haben & Gutschrift/Belastung umdrehen
**      IF <line_aggr_tax>-gbkzg = 'B'.
**        <line_aggr_tax>-gbkzg = 'G'.
**      ELSE.
**        <line_aggr_tax>-gbkzg = 'B'.
**      ENDIF.
**
**      IF <line_aggr_tax>-shkzg = 'S'.
**        <line_aggr_tax>-shkzg = 'H'.
**      ELSE.
**        <line_aggr_tax>-shkzg = 'S'.
**      ENDIF.
**
**      <line_aggr_tax>-dmbtr      *= -1.
**      <line_aggr_tax>-wrbtr      *= -1.
**      <line_aggr_tax>-skfbt      *= -1.
**      <line_aggr_tax>-sknto      *= -1.
**      <line_aggr_tax>-wskto      *= -1.
**      <line_aggr_tax>-bnett      *= -1.
**      <line_aggr_tax>-sknto_base *= -1.
**      <line_aggr_tax>-skfbt      *= -1.
**    ENDLOOP.
**
**    "Prüfung aggregierte Sachkontenzeilen: nur "echte" Finanzpositionen / Finanzstellen verarbeiten
**    IF i_selection-no_tech_fipo = 'X'.
**      DELETE c_dto-t_line_aggr_tax WHERE fipos CP 'T*' AND
**                                         fistl CP 'T*'.
**      IF lines( c_dto-t_line_aggr_tax ) = 0.
**        "Beleg irrelevant
**        e_delete_line = 'X'.
**        RETURN.
**      ENDIF.
**    ENDIF.
*
**    "Pro aggregierter Sachkontenzeile ist der Bruttobetrag zu ermitteln
**    "Zusätzlich sind mögliche Rundungsdifferenzen zu berücksichtigen
**    CLEAR: l_sum_btrg, l_dif_btrg, l_gbkzg, l_shkzg.
**
**    LOOP AT c_dto-t_line_aggr_tax ASSIGNING <line_aggr_tax>.
**
**      "Zeilen-Nr. für aggregierte Datensätze setzen (reorg)
**      l_zeile = sy-tabix.
**      <line_aggr_tax>-zeile = l_zeile.
**
**      IF l_shkzg IS INITIAL.
**        l_shkzg = <line_aggr_tax>-shkzg.
**      ENDIF.
**
**      IF <line_aggr_tax>-bnett <> '0.00'.     "IHV-bezogener Nettobetrag in HW
**        <line_aggr_tax>-bbrut = <line_aggr_tax>-dmbtr.
**        <line_aggr_tax>-bmwst = <line_aggr_tax>-bbrut - <line_aggr_tax>-bnett.
**      ENDIF.
**
**      IF l_t001-waers EQ <line_aggr_tax>-waers.
**        "in Hauswährung
**
**        IF <line_aggr_tax>-bnett = '0.00'.
**          "Nettobetrag
**          <line_aggr_tax>-bnett = <line_aggr_tax>-dmbtr.
**          IF <line_aggr_tax>-mwskz IS NOT INITIAL.
**            TRY.
**                calculate_tax_nettamount(
**                  EXPORTING
**                    i_bukrs = c_dto-bukrs
**                    i_mwskz = <line_aggr_tax>-mwskz
**                    i_waers = l_t001-waers
**                    i_wrbtr = <line_aggr_tax>-bnett
**                  IMPORTING
**                    e_bmwst = <line_aggr_tax>-bmwst ).
**              CATCH zcx_jva INTO l_zcx_jva.
**                IF i_raise_exceptions IS NOT INITIAL.
**                  RAISE EXCEPTION l_zcx_jva.
**                ENDIF.
**            ENDTRY.
**          ENDIF.
**
**          "Bruttobetrag
**          <line_aggr_tax>-bbrut = <line_aggr_tax>-bnett + <line_aggr_tax>-bmwst.
**
**          "Steuer zu Skonto-Basisbetrag in Hauswährung hinzufügen
**          IF <line_aggr_tax>-mwskz IS NOT INITIAL.
**            TRY.
**                calculate_tax_nettamount(
**                  EXPORTING
**                    i_bukrs = c_dto-bukrs
**                    i_mwskz = <line_aggr_tax>-mwskz
**                    i_waers = l_t001-waers
**                    i_wrbtr = CONV #( <line_aggr_tax>-sknto_base )
**                  IMPORTING
**                    e_bmwst = DATA(l_bmwst) ).
**              CATCH zcx_jva INTO l_zcx_jva.
**                IF i_raise_exceptions IS NOT INITIAL.
**                  RAISE EXCEPTION l_zcx_jva.
**                ENDIF.
**            ENDTRY.
**          ENDIF.
**          <line_aggr_tax>-sknto_base += l_bmwst.
**        ENDIF.
**
**        IF <line_aggr_tax>-shkzg = l_shkzg.
**          l_sum_btrg += <line_aggr_tax>-bbrut.
**        ELSE.
**          l_sum_btrg -= <line_aggr_tax>-bbrut.
**        ENDIF.
**
**      ELSE.
**        "Belegwährung (Fremdwährung)
**        "Annahme: Bei Fremdwährung keine Steuerberechnung (das ist zu hinterfragen!)
**        "<line_aggr_tax>-bbrut = <line_aggr_tax>-dmbtr.  "in Hauswährung
**        "<line_aggr_tax>-bnett = <line_aggr_tax>-dmbtr.  "in Hauswährung
**
**        <line_aggr_tax>-fnett = <line_aggr_tax>-wrbtr.
**        <line_aggr_tax>-fbrut = <line_aggr_tax>-fnett.
**
**        IF <line_aggr_tax>-shkzg = l_shkzg.
**          l_sum_btrg += <line_aggr_tax>-fbrut.
**        ELSE.
**          l_sum_btrg -= <line_aggr_tax>-fbrut.
**        ENDIF.
**
**      ENDIF.
**
**    ENDLOOP.
*
*    IF l_sum_btrg < 0.
*      "Je nachdem, welche Zeile zuerst berücksichtigt wurde, kann die Summe negativ sein.
*      l_sum_btrg *= -1.
*    ENDIF.
*
*    "Prüfung auf Rundungsdifferenzen
*    "Bei Kreditoren / Debitoren
*    IF c_dto-lifnr IS NOT INITIAL OR
*       c_dto-kunnr IS NOT INITIAL.
*
*      IF c_dto-kursf IS INITIAL.
*        "Hauswährung
*        l_dif_btrg = l_bel_btrg - l_sum_btrg.
*      ELSE.
*        "Belegwährung
*        l_dif_btrg = l_bel_fbtrg - l_sum_btrg.
*      ENDIF.
*
**      "Korrektur Rundungsdifferenz
**      IF l_dif_btrg <> 0.
**        "1. Zeile
**        READ TABLE c_dto-t_line_aggr_tax ASSIGNING <line_aggr_tax> INDEX 1.
**        IF sy-subrc EQ 0.
**
**          "Bruttbetrag (Übergabebetrag an IHV) wird angepasst
**          IF l_t001-waers EQ <line_aggr_tax>-waers.
**            "Hauswährung
**            <line_aggr_tax>-bbrut = <line_aggr_tax>-bbrut + l_dif_btrg.
**
**            "Anteilige Steuer neu rechnen
**            IF <line_aggr_tax>-mwskz IS NOT INITIAL.
**              TRY.
**                  calculate_tax_grossamount(
**                    EXPORTING
**                      i_bukrs = c_dto-bukrs
**                      i_mwskz = <line_aggr_tax>-mwskz
**                      i_waers = l_t001-waers
**                      i_bbrut = <line_aggr_tax>-bbrut
**                    IMPORTING
**                      e_bmwst = <line_aggr_tax>-bmwst ).
**
**                CATCH zcx_jva INTO l_zcx_jva.
**                  IF i_raise_exceptions IS NOT INITIAL.
**                    RAISE EXCEPTION l_zcx_jva.
**                  ENDIF.
**              ENDTRY.
**            ENDIF.
**
**            <line_aggr_tax>-bnett = <line_aggr_tax>-bbrut - <line_aggr_tax>-bmwst.
**
**          ELSE.
**            "Belegwährung
**            <line_aggr_tax>-fbrut = <line_aggr_tax>-fbrut - l_dif_btrg.
**            <line_aggr_tax>-fnett = <line_aggr_tax>-fbrut.
**          ENDIF.
**
**        ENDIF.
**      ENDIF.
*    ENDIF.
*
*    "-------------------------
*    "Ausgaben Sonderfall Skonto:
*    "-------------------------
*    "Skonto wird bei Rechnungsbuchung nur für Aufwandzeilen, bei Buchung mit Steuer aber nicht für die Steuerzeilen ausgewiesen.
*    "1. Fall mit Skonto, aber ohne Steuer:
*    "Skontobetrag von der Gesamtbelegsumme abziehen
*
*    "2. Fall mit Skonto und Steuer:
*    "Skontobetrag von der Gesamtbelegsumme abziehen.
*    "Skonto von Steuerzeilen berechnen und von der Gesamtbelegsumme abziehen
*
*    "Zusätzlich: Falls auf unterschiedliche Fipos oder Fistl gebucht wurde, muss der Skontoabzug und die Skontoberechnung
*    "der Steuerzeilen im Verhältnis der Aufwandzeilen aufgeteilt werden.
*    "Um Rundungsfehler aufgrund der manuellen Berechnungen im Zahlbetrag zu vermeiden, sollte noch eine Prüfung erfolgen,
*    "ob der errechnete Betrag der Einzelbelegpositionen dem Betrag der Zeile mit Buchungsschlüssel 31 abzüglich Skonto (inkl.
*    "Skonto der steuer) entspricht.
*    CLEAR: l_bas_sknto,
*           l_sum_sknto,
*           l_dif_sknto.
*
*    IF c_dto-lifnr IS NOT INITIAL AND l_sktoprz NE 0.              "Skonto wurde gewährt
*
**      LOOP AT c_dto-t_line_aggr_tax ASSIGNING <line_aggr_tax>.
**
**        IF l_t001-waers EQ <line_aggr_tax>-waers.
**          "in Hauswährung
**          IF l_is_ige IS INITIAL.    "Kein Innergemeinschaftlicher Erwerb.
**            <line_aggr_tax>-sknto = ( <line_aggr_tax>-sknto_base * l_sktoprz ) / 100.
**            l_bas_sknto = l_bas_sknto + <line_aggr_tax>-sknto_base.
**
**            IF <line_aggr_tax>-sknto = 0.
**              CONTINUE.
**            ENDIF.
**
**            "Bruttobetrag (exkl. Skonto)
**            <line_aggr_tax>-bbrut = <line_aggr_tax>-bbrut - <line_aggr_tax>-sknto.
**            l_sum_sknto = l_sum_sknto + <line_aggr_tax>-sknto.
**
**            "Anteilige Steuer neu rechnen
**
**            IF <line_aggr_tax>-mwskz IS NOT INITIAL.
**              TRY.
**                  calculate_tax_grossamount(
**                    EXPORTING
**                      i_bukrs = c_dto-bukrs
**                      i_mwskz = <line_aggr_tax>-mwskz
**                      i_waers = l_t001-waers
**                      i_bbrut = <line_aggr_tax>-bbrut
**                    IMPORTING
**                      e_bmwst = <line_aggr_tax>-bmwst ).
**
**                CATCH zcx_jva INTO l_zcx_jva.
**                  IF i_raise_exceptions IS NOT INITIAL.
**                    RAISE EXCEPTION l_zcx_jva.
**                  ENDIF.
**              ENDTRY.
**            ENDIF.
**
**            <line_aggr_tax>-bnett = <line_aggr_tax>-bbrut - <line_aggr_tax>-bmwst.
**
**          ELSE.
**            "Innergemeinschaftlicher Erwerb
*****         l_sknto = ( <line_aggr_tax>-bnett * l_sktoprz ) / 100.
*****         l_sum_sknto = l_sum_sknto + l_sknto.
**            <line_aggr_tax>-sknto = ( <line_aggr_tax>-bnett * l_sktoprz ) / 100.
**            l_sum_sknto = l_sum_sknto + <line_aggr_tax>-sknto.
**            l_bas_sknto = l_bas_sknto + <line_aggr_tax>-bnett.
**            <line_aggr_tax>-bnett = <line_aggr_tax>-bnett - <line_aggr_tax>-sknto.
**
**            TRY.
**                "Steuerbetrag aus Netto berechnen
**                calculate_tax_nettamount(
**                  EXPORTING
**                    i_bukrs = c_dto-bukrs
**                    i_mwskz = <line_aggr_tax>-mwskz
**                    i_waers = l_t001-waers
**                    i_wrbtr = <line_aggr_tax>-bnett
**                  IMPORTING
**                    e_bmwst = <line_aggr_tax>-bmwst ).
**
**              CATCH zcx_jva INTO l_zcx_jva.
**                IF i_raise_exceptions IS NOT INITIAL.
**                  RAISE EXCEPTION l_zcx_jva.
**                ENDIF.
**            ENDTRY.
**            <line_aggr_tax>-bmwst *= -1.
**            <line_aggr_tax>-bbrut = <line_aggr_tax>-bnett + <line_aggr_tax>-bmwst.
*****         <line_aggr_tax>-sknto = <line_aggr_tax>-sknto_base - <line_aggr_tax>-bbrut.
**
**          ENDIF.
**
**        ELSE.
**          <line_aggr_tax>-wskto = ( <line_aggr_tax>-skfbt * l_sktoprz ) / 100.
**          l_bas_sknto = l_bas_sknto + <line_aggr_tax>-skfbt.
**
**          IF <line_aggr_tax>-wskto = 0.
**            CONTINUE.
**          ENDIF.
**
**          "Annahme: Bei Auslandswährungen erfolgt keine Steuerberechnung (ist wahrscheinlich nicht korrekt!)
**          l_sum_sknto = l_sum_sknto + <line_aggr_tax>-wskto.
**          <line_aggr_tax>-fbrut = <line_aggr_tax>-fbrut - <line_aggr_tax>-wskto.
**          <line_aggr_tax>-fnett = <line_aggr_tax>-fbrut.
**
**        ENDIF.
**
**      ENDLOOP.
*
*      "Skontobetrag (Grundlage tatsächliche Skontobasis (Brutto))
*      c_dto-lifnr_sknto = ( l_bas_sknto * l_sktoprz ) / 100.
*
*      "Prüfung Skonto-Differenz
*      "Bei Kreditorenbuchungen
*      IF c_dto-lifnr IS NOT INITIAL AND
*         c_dto-lifnr_sknto NE 0.
*
*        l_dif_sknto = c_dto-lifnr_sknto - l_sum_sknto.
*
*        "Korrektur Skonto-Differenz
*        IF l_dif_sknto <> 0.
**          "1. Zeile
**          READ TABLE c_dto-t_line_aggr_tax ASSIGNING <line_aggr_tax> INDEX 1.
**          IF sy-subrc EQ 0.
**
**            IF l_t001-waers EQ <line_aggr_tax>-waers.
**              "Hauswährung
**              IF l_dif_sknto > 0.
**                "Skontobetrag errechnet über alle Position < als Skontobetrag zur Kreditorenzeile
**                "Skontobetrag zur Position wird angepasst - zufügen
**                <line_aggr_tax>-sknto = <line_aggr_tax>-sknto + l_dif_sknto.
**                "Bruttobetrag anpassen
**                <line_aggr_tax>-bbrut = <line_aggr_tax>-bbrut - l_dif_sknto.
**              ELSE.
**                "Skontobetrag errechnet über alle Position > als Skontobetrag zur Kreditorenzeile
**                "Skontobetrag zur Position wird angepasst - Abzug
**                l_dif_sknto = l_dif_sknto * -1.
**                <line_aggr_tax>-sknto = <line_aggr_tax>-sknto - l_dif_sknto.
**                "Bruttobetrag anpassen
**                <line_aggr_tax>-bbrut = <line_aggr_tax>-bbrut + l_dif_sknto.
**              ENDIF.
**
**              "Anteilige Steuer neu rechnen
**              IF <line_aggr_tax>-mwskz IS NOT INITIAL.
**                TRY.
**                    calculate_tax_grossamount(
**                      EXPORTING
**                        i_bukrs = c_dto-bukrs
**                        i_mwskz = <line_aggr_tax>-mwskz
**                        i_waers = l_t001-waers
**                        i_bbrut = <line_aggr_tax>-bbrut
**                      IMPORTING
**                        e_bmwst = <line_aggr_tax>-bmwst ).
**
**                  CATCH zcx_jva INTO l_zcx_jva.
**                    IF i_raise_exceptions IS NOT INITIAL.
**                      RAISE EXCEPTION l_zcx_jva.
**                    ENDIF.
**                ENDTRY.
**              ENDIF.
**
**              IF <line_aggr_tax>-bmwst > 0.
**                <line_aggr_tax>-bnett = <line_aggr_tax>-bbrut - <line_aggr_tax>-bmwst.
**              ELSE.
**                <line_aggr_tax>-bnett = <line_aggr_tax>-bbrut + <line_aggr_tax>-bmwst.
**              ENDIF.
**
**            ELSE.
**              "Belegwährung
**              <line_aggr_tax>-wskto = <line_aggr_tax>-wskto + l_dif_sknto.
**              IF l_dif_sknto > 0.
**                <line_aggr_tax>-fbrut = <line_aggr_tax>-fbrut - l_dif_sknto.
**              ELSE.
**                <line_aggr_tax>-fbrut = <line_aggr_tax>-fbrut + l_dif_sknto.
**              ENDIF.
**              <line_aggr_tax>-fnett = <line_aggr_tax>-fbrut.
**            ENDIF.
**
**          ENDIF.
*        ENDIF.
*      ENDIF.
*
*    ENDIF.
*
*    "Aggregation der Buchungszeilen nach Steuerkennzeichen und CO-Kontierung:
*    "Finanzposition
*    "Finanzstelle
*
*    "Merke: Aggregation der Belegzeilen OHNE Berücksichtigung des Steuerkennzeichens
*
**    LOOP AT c_dto-t_line_aggr_tax INTO l_line_aggr_tax.
**      READ TABLE c_dto-t_line_aggr
**        WITH KEY fipos = l_line_aggr_tax-fipos
**                 fistl = l_line_aggr_tax-fistl
**        ASSIGNING FIELD-SYMBOL(<line_aggr>).
**
**      "Aggregation unterdrücken - Sonderfall Sachkontenbuchungen mit Titelzusatz (D321TZU)
**      IF i_selection-no_aggr = abap_true OR c_dto-blart = 'ST'.
**        APPEND INITIAL LINE TO c_dto-t_line_aggr ASSIGNING <line_aggr>.
**        MOVE-CORRESPONDING l_line_aggr_tax TO <line_aggr>.
**
**        l_gbkzg                = <line_aggr>-gbkzg.
**        <line_aggr>-is_ige_13b = get_is_ige_13b( l_line_aggr_tax-mwskz ).
**
**        CLEAR <line_aggr>-zeile.  "Zeilennummer löschen, wird später neu vergeben
**      ELSE.
**
**        IF sy-subrc <> 0.
**          APPEND INITIAL LINE TO c_dto-t_line_aggr ASSIGNING <line_aggr>.
**          MOVE-CORRESPONDING l_line_aggr_tax TO <line_aggr>.
**
**          l_gbkzg                = <line_aggr>-gbkzg.
**          <line_aggr>-is_ige_13b = get_is_ige_13b( l_line_aggr_tax-mwskz ).
**
**          CLEAR <line_aggr>-zeile.  "Zeilennummer löschen, wird später neu vergeben
**        ELSE.
*****     IF l_line_aggr_tax-gbkzg = l_gbkzg.
**          IF l_line_aggr_tax-shkzg = <line_aggr>-shkzg.
**            ADD l_line_aggr_tax-dmbtr TO <line_aggr>-dmbtr.
**            ADD l_line_aggr_tax-wrbtr TO <line_aggr>-wrbtr.
**
**            ADD l_line_aggr_tax-skfbt TO <line_aggr>-skfbt.
**            ADD l_line_aggr_tax-sknto TO <line_aggr>-sknto.
**            ADD l_line_aggr_tax-wskto TO <line_aggr>-wskto.
**
**            ADD l_line_aggr_tax-bnett TO <line_aggr>-bnett.
**            ADD l_line_aggr_tax-bmwst TO <line_aggr>-bmwst.
**            ADD l_line_aggr_tax-bbrut TO <line_aggr>-bbrut.
**            ADD l_line_aggr_tax-fnett TO <line_aggr>-fnett.
**            ADD l_line_aggr_tax-fbrut TO <line_aggr>-fbrut.
**          ELSE.
**            CLEAR <line_aggr>-bschl.
**
**            <line_aggr>-dmbtr -= l_line_aggr_tax-dmbtr.
**            <line_aggr>-wrbtr -= l_line_aggr_tax-wrbtr.
**
**            <line_aggr>-skfbt -= l_line_aggr_tax-skfbt.
**            <line_aggr>-sknto -= l_line_aggr_tax-sknto.
**            <line_aggr>-wskto -= l_line_aggr_tax-wskto.
**
**            <line_aggr>-bnett -= l_line_aggr_tax-bnett.
**            <line_aggr>-bmwst -= l_line_aggr_tax-bmwst.
**            <line_aggr>-bbrut -= l_line_aggr_tax-bbrut.
**            <line_aggr>-fnett -= l_line_aggr_tax-fnett.
**            <line_aggr>-fbrut -= l_line_aggr_tax-fbrut.
**          ENDIF.
**
**          IF <line_aggr>-koart <> l_line_aggr_tax-koart.
**            CLEAR <line_aggr>-koart.
**          ENDIF.
**
**          IF <line_aggr>-prctr <> l_line_aggr_tax-prctr.
**            CLEAR <line_aggr>-prctr.
**            c_dto-prctr = 'U'.    "Undefined, da mehrer Proficenter verwendet
**          ENDIF.
**
**          IF <line_aggr>-kostl <> l_line_aggr_tax-kostl.
**            CLEAR <line_aggr>-kostl.
**          ENDIF.
**
**          IF <line_aggr>-geber <> l_line_aggr_tax-geber.
**            CLEAR <line_aggr>-geber.
**          ENDIF.
**
**          IF <line_aggr>-mwskz <> l_line_aggr_tax-mwskz.
**            <line_aggr>-mwskz = 'U'.    "Undefined, da mehrere Steuerkennzeichen
**          ENDIF.
**
**          IF <line_aggr>-is_ige_13b <> get_is_ige_13b( l_line_aggr_tax-mwskz ).
**            <line_aggr>-is_ige_13b = 'U'.  "Undefined, einige Zeilen IGE/§13b, andere nicht
**          ENDIF.
**
**        ENDIF.
**
**        IF c_dto-prctr IS INITIAL.
**          c_dto-prctr = <line_aggr>-prctr.
**        ELSEIF c_dto-prctr <> <line_aggr>-prctr.
**          c_dto-prctr = 'U'.    "Undefined, da mehrer Proficenter verwendet
**        ENDIF.
**
**      ENDIF.
**
**    ENDLOOP.
*
**    LOOP AT c_dto-t_line_aggr ASSIGNING <line_aggr>
**      WHERE dmbtr < '0.00'.
**      "Soll/Haben & Gutschrift/Belastung umdrehen
**      IF <line_aggr>-gbkzg = 'B'.
**        <line_aggr>-gbkzg = 'G'.
**      ELSE.
**        <line_aggr>-gbkzg = 'B'.
**      ENDIF.
**
**      IF <line_aggr>-shkzg = 'S'.
**        <line_aggr>-shkzg = 'H'.
**      ELSE.
**        <line_aggr>-shkzg = 'S'.
**      ENDIF.
**
**      <line_aggr>-dmbtr *= -1.
**      <line_aggr>-wrbtr *= -1.
**
**      <line_aggr>-skfbt *= -1.
**      <line_aggr>-sknto *= -1.
**      <line_aggr>-wskto *= -1.
**
**      <line_aggr>-bnett *= -1.
**      <line_aggr>-bmwst *= -1.
**      <line_aggr>-bbrut *= -1.
**      <line_aggr>-fnett *= -1.
**      <line_aggr>-fbrut *= -1.
**
**    ENDLOOP.
**
**    LOOP AT c_dto-t_line_aggr INTO l_line_aggr.
**      "Zeilen-Nr. für aggregierte Datensätze setzen (reorg)
**      l_zeile = sy-tabix.
**      l_line_aggr-zeile = l_zeile.
**      MODIFY c_dto-t_line_aggr FROM l_line_aggr INDEX l_zeile.
**    ENDLOOP.
  ENDMETHOD.


  method GET_TDTO_FI_DOCUMENT.

*     DATA: l_select_clause TYPE string,
*          l_where_clause  TYPE string,
*          l_from_clause   TYPE string,
*          l_and           TYPE string,
*          l_or            TYPE string,
*          l_helpers       TYPE REF TO /THKR/CL_helpers,
*          l_str_bukrs     TYPE string,
*          l_str_cpudt     TYPE string,
*          l_zcx_FI       TYPE REF TO /thkr/cx_fi,
*          l_delete_line   TYPE xfeld.
*
*    DATA: lt_mwdat         TYPE STANDARD TABLE OF rtax1u15.
*    DATA: ls_mwdat         TYPE rtax1u15.
*    DATA: ls_t007b         TYPE t007b.
*    DATA: l_sktoprz        TYPE dzbd1p.
*    DATA: l_sum_sknto      TYPE dmbtr.
*    DATA: l_dif_sknto      TYPE dmbtr.
*    DATA: l_sum_btrg       TYPE dmbtr.
*    DATA: l_dif_btrg       TYPE dmbtr.
*    DATA: l_bel_btrg       TYPE dmbtr.
*    DATA: l_txjcd          TYPE txjcd.
*    DATA: l_zeile(3)       TYPE n.
*    DATA: l_bkdf           TYPE bkdf.
*    DATA: l_months         TYPE i.
*    DATA: l_tage           TYPE dzbd1t.
*
*    DATA: l_bldat(10) TYPE c,
*          l_kunnr(10) TYPE c,
*          l_lifnr(10) TYPE c.
*
**    DATA: l_dto_kreditor  TYPE zsjva_dto_kreditor.
*    DATA: l_t001 TYPE t001.
*
*    l_helpers =  /THKR/CL_helpers=>get_instance( ).
*
*    l_helpers->get_select_clause_from_struct(
*      EXPORTING
*        i_structure        = '/THKR/S_DTO_FI_BKPF'
*        i_prefix           = 'A'
*        i_comma_separation = 'X'
*      CHANGING
*        c_select_clause    = l_select_clause ).
*
*    l_from_clause = 'bkpf as a'.
*
**    IF i_selection-ao_sap_excl_ready IS NOT INITIAL.
**      CONCATENATE l_from_clause
**        'left outer join ztjva_ao_sap as s on a~bukrs = s~sap_bukrs and a~belnr = s~sap_belnr and a~gjahr = s~sap_gjahr'
**        INTO l_from_clause SEPARATED BY space.
**      CONCATENATE l_select_clause
**        ', s~confirmation as ao_confirmation'
**        INTO l_select_clause SEPARATED BY space.
**
**    ENDIF.
*
*    "Buchungskreis
*    IF i_selection-r_bukrs IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~bukrs in @i_selection-r_bukrs'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ELSEIF i_selection-bukrs IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~bukrs = @i_selection-bukrs'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Geschäftsjahr
*    IF i_selection-gjahr IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~gjahr = @i_selection-gjahr'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Belegnummer
*    IF i_selection-r_belnr IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~belnr in @i_selection-r_belnr'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Belegart
*    IF i_selection-blart IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~blart = @i_selection-blart'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ELSEIF i_selection-r_blart IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~blart in @i_selection-r_blart'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Belegstatus
*    IF i_selection-r_bstat IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~bstat in @i_selection-r_bstat'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Buchungsdatum
*    IF i_selection-r_budat IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~budat in @i_selection-r_budat'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Erfassungsdatum
*    IF i_selection-r_cpudt IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~cpudt in @i_selection-r_cpudt'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ELSEIF i_selection-cpudt IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~cpudt = @i_selection-cpudt'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Referenzschlüssel_1 intern zum Belegkopf
*    IF i_selection-xref1_hd IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~xref1_hd = @i_selection-xref1_hd'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Referenzschlüssel_2 intern zum Belegkopf
*    IF i_selection-xref2_hd IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~xref2_hd = @i_selection-xref2_hd'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
*    "Referenzschlüssel
*    IF i_selection-awkey IS NOT INITIAL.
*      CONCATENATE l_where_clause l_and 'a~awkey = @i_selection-awkey'
*        INTO l_where_clause SEPARATED BY space.
*      l_and = 'and'.
*    ENDIF.
*
**    IF i_selection-t_start_cpudt IS NOT INITIAL.
**      CLEAR l_or.
**      CONCATENATE l_where_clause l_and '(' INTO l_where_clause SEPARATED BY space.
**      LOOP AT i_selection-t_start_cpudt INTO DATA(l_stb).
**        CONCATENATE '''' l_stb-bukrs '''' INTO l_str_bukrs.
**        CONCATENATE '''' l_stb-cpudt '''' INTO l_str_cpudt.
**        CONCATENATE l_where_clause l_or '( a~bukrs = ' l_str_bukrs 'and a~cpudt >= ' l_str_cpudt ' )'
**          INTO l_where_clause SEPARATED BY space.
**        l_or = 'or'.
**      ENDLOOP.
**      CONCATENATE l_where_clause ')' INTO l_where_clause SEPARATED BY space.
**    ENDIF.
*
*    TRY.
*        SELECT (l_select_clause) INTO CORRESPONDING FIELDS OF TABLE @et_dto
*          FROM (l_from_clause)
*          WHERE (l_where_clause).
*      CATCH cx_root INTO DATA(l_oerror).
*        ASSERT 1 = 2.
*    ENDTRY.
*
*    LOOP AT et_dto ASSIGNING FIELD-SYMBOL(<header>).
*
**      IF i_selection-ao_sap_excl_ready IS NOT INITIAL.
**        IF <header>-ao_confirmation = 'P'    "Verarbeitet
**          OR <header>-ao_confirmation = 'N'  "Kein Export
**          OR <header>-ao_confirmation = 'I'  "Unzulässig
**          OR <header>-ao_confirmation = 'M'. "Ungültig (man.)
**          "Erfolgreich verarbeitete oder nicht Exportrelevante Belege ausschließen
**          "(aus Performance-Gründen)
**          DELETE et_dto.
**          CONTINUE.
**        ENDIF.
**      ENDIF.
*
*      fill_dto_fi_document(
*        EXPORTING
*          i_selection        = i_selection
*          i_raise_exceptions = i_raise_exceptions
*        IMPORTING
*          e_delete_line      = l_delete_line
*        CHANGING
*          c_dto              = <header> ).
*
*      IF l_delete_line = 'X'.
*        DELETE et_dto.
*      ENDIF.
*
*    ENDLOOP.

  endmethod.
ENDCLASS.
