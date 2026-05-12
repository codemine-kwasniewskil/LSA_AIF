class /THKR/CL_MIG_RK definition
  public
  final
  create private .

public section.

  data DEF type ref to /THKR/CL_MIG_DEF read-only .

  class-methods GET_INSTANCE
    exporting
      !E_INSTANCE type ref to /THKR/CL_MIG_RK
    returning
      value(R_INSTANCE) type ref to /THKR/CL_MIG_RK .
  methods CONSTRUCTOR .
  methods FB_RK
    importing
      !I_XBLNR type /THKR/MIG_RK_KASS_ZEICHEN
    exporting
      !E_ALLGEMEIN type /THKR/S_MIG_RK_ALLG
      !E_WEITERESCHULDNER type /THKR/S_MIG_RK_WEIT_SCHULDN
      !ET_AMTSHILFE type /THKR/T_MIG_RK_AHE_FB
      !ET_ADRESS_RK type /THKR/T_MIG_RK_ADRH
      !ET_VERKETT_RK type /THKR/T_MIG_RK_KZ_VERKETTET
    raising
      /THKR/CX_MIG .
  methods FB_RKN
    importing
      !I_XBLNR type /THKR/MIG_RK_KASS_ZEICHEN
    exporting
      !ET_NOTIZEN type /THKR/T_MIG_RK_NOTIZ
    raising
      /THKR/CX_MIG .
  methods FB_RKV
    importing
      !I_XBLNR type /THKR/MIG_RK_KASS_ZEICHEN
    exporting
      !ET_SCHULDNERHISTORIE_RVK type /THKR/T_THKR_RK_RFC_WVT_RKV_RK
      !ET_WVLTERMINE_STANDARD type /THKR/T_THKR_RK_RFC_WVT_ST_RK
      !ET_RKV type /THKR/T_MIG_AVVISO_RKV
      !ET_RKFA type /THKR/T_MIG_AVVISO_RKFA
      !ET_BORH type /THKR/T_MIG_AVVISO_BORH
    raising
      /THKR/CX_MIG .
  methods FB_RK_FI_DOCUMENT_READ
    importing
      !I_BUKRS type BUKRS optional
      !I_BELNR type BELNR_D optional
      !I_GJAHR type GJAHR optional
      !I_XBLNR type /THKR/MIG_RK_KASS_ZEICHEN optional
    exporting
      !ET_BELEG type /THKR/T_RK_BELEG
    raising
      /THKR/CX_MIG .
  methods GET_DTO_MIG_AO
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID optional
      !I_XBLNR type XBLNR optional
      !I_XBLNR_POS_NR type /THKR/RK_POS_NR optional
      !I_HAUPT_NEBENFORDERUNG type /THKR/MIG_HF_NF optional
    exporting
      !E_DTO type /THKR/S_DTO_MIG_AO_SAP .
  methods GET_DTO_MIG_RK
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID optional
      !I_XBLNR type /THKR/MIG_RK_KASS_ZEICHEN optional
    exporting
      !E_DTO type /THKR/S_DTO_MIG_RK_SAP
    raising
      /THKR/CX_MIG .
  methods GET_DTO_MIG_RKFAEL_POS
    importing
      !I_XBLNR type /THKR/MIG_RK_KASS_ZEICHEN
      !I_FAELLIG type DATS
      !I_HF_NF type /THKR/MIG_HF_NF
    exporting
      !E_DTO type /THKR/S_DTO_MIG_RKFAEL_POS
    raising
      /THKR/CX_MIG .
  methods GET_DTO_MIG_RK_POS
    importing
      !I_XBLNR type /THKR/MIG_RK_KASS_ZEICHEN
      !I_POS_NR type /THKR/RK_POS_NR
      !I_HAUSHALTSJAHR type GJAHR optional
    exporting
      !E_DTO type /THKR/S_DTO_MIG_RKFAEL_POS
    raising
      /THKR/CX_MIG .
  methods GET_EXECUTE_DAY
    importing
      value(I_ZAHLWEISE) type CHAR01
      value(I_DATE) type SY-DATUM
      value(I_FACTORY_CALENDAR_ID) type SCAL-FCALID
    exporting
      value(E_DAY) type CHAR02 .
  methods GET_SATZ_ID_KASS_OP
    importing
      !I_XBLNR type /THKR/MIG_RK_KASS_ZEICHEN
      !I_POS_NR type /THKR/RK_POS_NR
      !I_HF_NF type /THKR/MIG_HF_NF
      !I_SSTW type FLAG optional
    exporting
      !E_SATZ_ID type /THKR/DE_SATZ_ID .
  methods GET_TDTO_MIG_AO
    importing
      !I_SELECTION type /THKR/S_MIG_AO_SAP_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_MIG_AO_SAP .
  methods GET_TDTO_MIG_RK
    importing
      !I_SELECTION type /THKR/S_MIG_RK_SAP_SELECTION
    exporting
      !ET_DTO type /THKR/T_DTO_MIG_RK_SAP .
  methods INIT_KASS_OP
    importing
      !I_SATZ_ID type /THKR/DE_SATZ_ID
    raising
      /THKR/CX_MIG .
  methods INIT_KASS_OPS
    importing
      !I_SELECTION type /THKR/S_MIG_RK_SAP_SELECTION .
protected section.

  data SELECTION type /THKR/S_MIG_RK_SAP_SELECTION .
private section.

  class-data INSTANCE type ref to /THKR/CL_MIG_RK .
  data HELPERS type ref to /THKR/CL_HELPERS .
ENDCLASS.



CLASS /THKR/CL_MIG_RK IMPLEMENTATION.


  method CONSTRUCTOR.

    def = /thkr/cl_mig_def=>get_instance( ).
    helpers = /thkr/cl_helpers=>get_instance( ).

  endmethod.


  METHOD fb_rk.
**********************************************************************
* Änderungen:
* Auftrag/Incident        Datum     Benutzer (ÄnderungsKz.)
* Beschreibung
* 4000000796/INC08849269 09.03.2026 ZHM000000379 (gb01)
* Wenn kein Zahlungspartner ein Gläubiger ist, muss dieser auch
* gefunden werden ansonsten steht der falsche Zahlungspartner in der Rückgabe
**********************************************************************

    get_dto_mig_ao(
      EXPORTING
        i_xblnr = i_xblnr
      IMPORTING
        e_dto   = DATA(l_dto_ao) ).

    get_dto_mig_rk(
      EXPORTING
        i_xblnr = i_xblnr
      IMPORTING
        e_dto   = DATA(l_dto_rk) ).


**  E_Allgemein
    e_allgemein-aktenzeichen = l_dto_rk-aktenzeichen.
    e_allgemein-kassenzeichen = l_dto_rk-kassenzeichen.
*    Todo: Klärung
*   e_allgemein-dat_letz_mahnung =  in Fälligkeitpositionen mehrfach 1:n
*   e_allgemein-dat_vollstreckung = in Fälligkeitspositionen mehrfach 1:n
*   e_allgemein-zinsschluessel =  ist in Soll_Ist 1:n:n:n
    LOOP AT l_dto_rk-t_rk_faell INTO DATA(l_rk_faell).
      LOOP AT l_rk_faell-t_rk_pos INTO DATA(l_rk_pos).
        IF l_rk_pos-dat_letz_mahnung GT e_allgemein-dat_letz_mahnung.
          e_allgemein-dat_letz_mahnung = l_rk_pos-dat_letz_mahnung.
        ENDIF.
        IF l_rk_pos-dat_vollstreckung GT e_allgemein-dat_vollstreckung.
          e_allgemein-dat_vollstreckung = l_rk_pos-dat_vollstreckung.
        ENDIF.
        IF e_allgemein-dat_letz_mahnung = '0'.
          e_allgemein-dat_letz_mahnung = '00000000'.
        ENDIF.
        LOOP AT l_rk_pos-t_rk_sol_ist INTO DATA(l_rk_soll_ist).
*         Todo: Nach welcher Logik wird der richtige Zinsschlüssel ermittelt
          IF e_allgemein-zinsschluessel <> space.
            e_allgemein-zinsschluessel =  l_rk_soll_ist-zins_schluessel.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

** Verkette Konten ausgeben
    et_verkett_rk = VALUE #( ( kez_kett_kennz = l_dto_rk-kez_kett_kennz kez_name = l_dto_rk-kez_name ) ).

**  Weitere Schuldner
    e_weitereschuldner-weitere_schuldner = l_dto_rk-zp-weitere_schuldner.

* aktuellesten Eintrag zuerst, sollte eine 0 haben
    SORT l_dto_rk-t_rka BY bis_datum.

**  Amtshilfeersuchen zum RK
    LOOP AT l_dto_rk-t_rk_ahe INTO DATA(ls_rk_ahe).
      APPEND INITIAL LINE TO et_amtshilfe ASSIGNING FIELD-SYMBOL(<ahe>).
      " RK_AHE-DATUM_AHE    => ERFASSUNGSDATUM      => Profiskal: RKFA DatumRKangelegt
      <ahe>-datumamtshilfe = ls_rk_ahe-datum_ahe.
      <ahe>-fremdkassenzeichen = ls_rk_ahe-fremd_kassenzeichen.
      <ahe>-geschaeftspartnernummer = l_dto_ao-partner.
      " Wenn Gläubiger, dann diesen Partner selektieren
      IF l_dto_rk-zp_v-kennz_vertreter = 'G'.
        SELECT SINGLE partner FROM but000 INTO <ahe>-geschaeftspartnernummer
          WHERE bu_sort1 = l_dto_rk-zp_v-zp_nummer.
        IF sy-subrc NE 0.                         "ins gb01
          CLEAR <ahe>-geschaeftspartnernummer.    "ins gb01
        ENDIF.                                    "ins gb01
      ENDIF.

      " 1. /aktuellesten Eintrag nutzen
      READ TABLE l_dto_rk-t_rka INTO DATA(ls_dto_rk_adrh_1) INDEX 1.
      IF sy-subrc = 0.
        " RKA-KENNZ_VERTRETER  =>KENNZ_VERTRETER     => ProFiskal: RKA KennzeichenVertreter
        <ahe>-kennz_vertreter = ls_dto_rk_adrh_1-kennz_vertreter.
        " RKA-VERTRETER_SCHLU  => VERTRETERSCHLUESSEL => ProFiskal: RKA KASSVertreterSchluessel
        <ahe>-vertreterschluessel = ls_dto_rk_adrh_1-vertreter_schlu. "RKKASSVertreterSchluessel
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0 AND l_dto_ao-nuller_kassenzeichen = abap_true.
      APPEND INITIAL LINE TO et_amtshilfe ASSIGNING <ahe>.
      " Sonderlösung für Amtshilfe die nicht als solche am Typ erkennbar sind und daher keine Originären AHE Daten haben
      <ahe>-geschaeftspartnernummer = l_dto_ao-partner.
      IF l_dto_rk-zp_v-kennz_vertreter = 'G'.
        SELECT SINGLE partner FROM but000 INTO <ahe>-geschaeftspartnernummer
          WHERE bu_sort1 = l_dto_rk-zp_v-zp_nummer.
        IF sy-subrc NE 0.                         "ins gb01
          CLEAR <ahe>-geschaeftspartnernummer.    "ins gb01
        ENDIF.                                    "ins gb01
      ENDIF.
      " 1. /aktuellesten Eintrag nutzen
      READ TABLE l_dto_rk-t_rka INTO ls_dto_rk_adrh_1 INDEX 1.
      IF sy-subrc = 0.
        " RKA-KENNZ_VERTRETER  =>KENNZ_VERTRETER     => ProFiskal: RKA KennzeichenVertreter
        <ahe>-kennz_vertreter = ls_dto_rk_adrh_1-kennz_vertreter.
        " RKA-VERTRETER_SCHLU  => VERTRETERSCHLUESSEL => ProFiskal: RKA KASSVertreterSchluessel
        <ahe>-vertreterschluessel = ls_dto_rk_adrh_1-vertreter_schlu. "RKKASSVertreterSchluessel
      ENDIF.
    ENDIF.

**  Adresshistorie zum Schuldner
    LOOP AT l_dto_rk-t_rka INTO DATA(ls_dto_rk_adrh).
      APPEND INITIAL LINE TO et_adress_rk ASSIGNING FIELD-SYMBOL(<adrh>).
      <adrh>-bisdatum = ls_dto_rk_adrh-bis_datum.
      IF ls_dto_rk_adrh-dat_rk_angelegt <> 0.
        <adrh>-dat_rk_angelegt = ls_dto_rk_adrh-dat_rk_angelegt.
      ELSE.
        <adrh>-dat_rk_angelegt = '00000000'.
      ENDIF.
      <adrh>-laenderkennzeichen = ls_dto_rk_adrh-laenderkennzeichen.
      <adrh>-namezeile1 = ls_dto_rk_adrh-name_zeile1.
      <adrh>-namezeile2 = ls_dto_rk_adrh-name_zeile2.
      <adrh>-namezeile3 = ls_dto_rk_adrh-name_zeile3.
      <adrh>-ort = ls_dto_rk_adrh-ort.
      <adrh>-plz = ls_dto_rk_adrh-plz.
      <adrh>-strasse = ls_dto_rk_adrh-strasse.
      IF ls_dto_rk_adrh-geburtstag <> 0.
        <adrh>-geburtstag = ls_dto_rk_adrh-geburtstag.
      ELSE.
        <adrh>-geburtstag = '00000000'.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD fb_rkn.

    get_dto_mig_rk(
      EXPORTING
        i_xblnr = i_xblnr
      IMPORTING
        e_dto   = DATA(l_dto_rk) ).

    LOOP AT l_dto_rk-t_rkn INTO DATA(l_rkn).
      APPEND INITIAL LINE TO et_notizen ASSIGNING FIELD-SYMBOL(<notizen>).
      <notizen>-rknzeile   = l_rkn-zeile. " Zeilennummer der Notiz
      <notizen>-rkntext    = l_rkn-text.  "	Text der Notiz
      <notizen>-bearbeiter = l_rkn-login_name. " Charakter 100
      <notizen>-datum      = l_rkn-datum.  "  Character Feld der Länge 8
      <notizen>-zeit       = l_rkn-zeit.

    ENDLOOP.

  ENDMETHOD.


  METHOD fb_rkv.

    get_dto_mig_rk(
      EXPORTING
        i_xblnr = i_xblnr
      IMPORTING
        e_dto   = DATA(l_dto_rk) ).

    LOOP AT l_dto_rk-t_rkv INTO DATA(l_rkv).

      APPEND INITIAL LINE TO et_rkv ASSIGNING FIELD-SYMBOL(<e_rkv>).
      <e_rkv>-lauf_vorgangsnr     = l_rkv-lauf_vorgangsnr.
      <e_rkv>-kassenzeichen       = l_rkv-kassenzeichen.
      <e_rkv>-vorgangsschluessel  = l_rkv-vorgang_schl.
      <e_rkv>-mahnbetrag          = l_rkv-mahnbetrag.
      <e_rkv>-ausfuehrungsdatum   = COND #( WHEN l_rkv-aus_datum > 0 THEN l_rkv-aus_datum ).
      <e_rkv>-ausfuehrungszeit    = l_rkv-aus_zeit.
      IF strlen( <e_rkv>-ausfuehrungszeit ) = 3.
        <e_rkv>-ausfuehrungszeit = '0' && <e_rkv>-ausfuehrungszeit.
      ENDIF.

      <e_rkv>-faelligkeitsdatum   = COND #( WHEN l_rkv-falligkeitsdatum > 0 THEN l_rkv-falligkeitsdatum ).
      <e_rkv>-plandatum           = COND #( WHEN l_rkv-plandatum > 0 THEN l_rkv-plandatum ).

    ENDLOOP.

    LOOP AT l_dto_rk-t_rk_pos INTO DATA(l_rk_pos).
      APPEND INITIAL LINE TO et_rkfa ASSIGNING FIELD-SYMBOL(<e_rkfa>).
      <e_rkfa>-kassenzeichen        = l_dto_rk-kassenzeichen.
      <e_rkfa>-belnr_mig            = l_rk_pos-pos_nr.
      <e_rkfa>-haupt_nebenforderung = l_rk_pos-haup_nebenforderung.
      <e_rkfa>-nefschluessel        = l_rk_pos-nefschluessel.
      <e_rkfa>-faelligkeitsdatum    = COND #( WHEN l_rk_pos-faellig > 0 THEN l_rk_pos-faellig ).
      <e_rkfa>-bearbeitungsstatus   = l_rk_pos-bearbeitungsstatus.
      <e_rkfa>-mahnstatus           = l_rk_pos-mahnstatus.
      <e_rkfa>-vollstreckungsstatus = l_rk_pos-vollstr_status.
      <e_rkfa>-stundungsende        = COND #( WHEN l_rk_pos-dat_stundung_ende > 0 THEN l_rk_pos-dat_stundung_ende ).
      <e_rkfa>-adf_schluessel       = l_dto_rk-adf_key.

    ENDLOOP.

    LOOP AT l_dto_rk-t_bore INTO DATA(l_bore).
      APPEND INITIAL LINE TO et_borh ASSIGNING FIELD-SYMBOL(<e_borh>).
      <e_borh>-kassenzeichen = l_dto_rk-kassenzeichen.
      <e_borh>-reportname    = l_bore-repotname.
      <e_borh>-datum         = COND #( WHEN l_bore-datum > 0 THEN l_bore-datum ).
      <e_borh>-zeit          = l_bore-zeit.
      <e_borh>-nutzer        = l_bore-nutzer.
    ENDLOOP.

******************************** soll ab hier weg **************************
    LOOP AT l_dto_rk-t_rkv INTO l_rkv.
      APPEND INITIAL LINE TO et_schuldnerhistorie_rvk ASSIGNING FIELD-SYMBOL(<schuldnerhistorie_rvk>).
      <schuldnerhistorie_rvk>-faellig_dtu	 =  l_rkv-falligkeitsdatum.  " Character Feld der Länge 8
      <schuldnerhistorie_rvk>-mahnbetrag   =  l_rkv-mahnbetrag.  " Char 15

      APPEND INITIAL LINE TO et_wvltermine_standard ASSIGNING FIELD-SYMBOL(<wvltermine>).
      <wvltermine>-kassenzeichen        =  l_rkv-kassenzeichen. "	Feld der Länge 16
      <wvltermine>-vorgangsschluessel   =  l_rkv-vorgang_schl.  " Char 20
      <wvltermine>-ausfuehrungsdatum    =  l_rkv-aus_datum.     "	Character Feld der Länge 8

    ENDLOOP.

  ENDMETHOD.


  METHOD fb_rk_fi_document_read.
    TYPES: BEGIN OF ty_lauf_id,
             lauf_id TYPE int4,
           END OF ty_lauf_id.

    DATA:
      lv_no_dkw          TYPE flag,
      lv_tabix           TYPE sy-tabix,
      lt_laufid          TYPE TABLE OF ty_lauf_id,
      lt_soll_ist        TYPE /thkr/t_mig_rksoll_ist,
      l_mig_ao_selection TYPE /thkr/s_mig_ao_sap_selection,
      l_belnr_mig_hf     TYPE /thkr/rk_pos_nr,
      l_xblnr            TYPE xblnr.


    SELECT SINGLE budat FROM /thkr/mig_md INTO @DATA(lv_budat).
    DATA(lv_gjahr) = lv_budat+0(4).


    IF i_belnr IS NOT INITIAL.
      l_mig_ao_selection-bukrs = i_bukrs.
      l_mig_ao_selection-gjahr = i_gjahr.
      l_mig_ao_selection-belnr = i_belnr.

    ELSEIF i_xblnr IS NOT INITIAL.
      l_mig_ao_selection-xblnr = i_xblnr.
      l_xblnr =  i_xblnr.
    ELSE.
      ASSERT 1 = 2.
    ENDIF.

    "Migrierte Belege zum Kassenzeichen oder Beleg ermitteln
    APPEND INITIAL LINE TO l_mig_ao_selection-r_status ASSIGNING FIELD-SYMBOL(<r_status>).
    <r_status>-sign   = 'I'.
    <r_status>-option = 'GE'.
    <r_status>-low    = '40'. "AO-Beleg erzeugt

    get_tdto_mig_ao(
      EXPORTING
        i_selection = l_mig_ao_selection
      IMPORTING
        et_dto      = DATA(lt_dto_mig_ao) ).


    IF i_xblnr IS INITIAL.
      " Hauptforderungen werden nicht aus RK migriert, daher keine direkte Zuordnung aktuell möglich
      " Wenn also direkt mit Belegnummer gesucht, dann nur diese Daten zurückgeben
* Belegdaten zurückgeben
      LOOP AT lt_dto_mig_ao ASSIGNING FIELD-SYMBOL(<fs_mig_ao>) WHERE haup_nebenforderung <> 'N'.
        APPEND VALUE #(
                        blart          = <fs_mig_ao>-haup_nebenforderung
                        xblnr          = <fs_mig_ao>-xblnr
*                        awkey = l_rk_sol_ist-lauf_vorgang
                        belnr_mig      = <fs_mig_ao>-rk_pos_nr
                        zfbdt          = <fs_mig_ao>-fealligkeit
                        dmbtr          = <fs_mig_ao>-betragoffen
                        bschl          = '01' "Forderungen
                        bukrs          = <fs_mig_ao>-bukrs
                        belnr          = <fs_mig_ao>-belnr
                        gjahr          = <fs_mig_ao>-gjahr
                        kunnr          = <fs_mig_ao>-partner
                        koart          = 'D' " Kontoart
                        sgtxt          = <fs_mig_ao>-verwendungszweck
*                        manst     = l_rk_pos-mahnstatus "  Mahnstufe
*                        maber     = 'ABC' " Mahnbereich
*                       quelle = l_rk_sol_ist-quelle
                        zinsschluessel = <fs_mig_ao>-zinsschluessel
        ) TO et_beleg.
        RETURN. "gibt nur ein DTO Obj. zu einem Beleg
      ENDLOOP.

    ENDIF.

* suchen über Kassenzeichen in den RK  und anschließend ggf. Eingrenzung auf BELNR
    IF l_xblnr IS INITIAL AND lt_dto_mig_ao IS NOT INITIAL.
      l_xblnr = lt_dto_mig_ao[ 1 ]-xblnr.
    ENDIF.

* Alle RK Positionen zum Kassenzeichen
    get_dto_mig_rk(
      EXPORTING
        i_xblnr = l_xblnr
      IMPORTING
        e_dto   = DATA(l_dto_rk) ).

    LOOP AT l_dto_rk-t_rk_faell INTO DATA(l_rk_faell).
      SORT l_rk_faell-t_rk_pos BY pos_nr.
      CLEAR lv_no_dkw. " pro Fälligkeit gibt es AHE Fä#lle mit mit Querverweisen außerhalb der RK Daten
      LOOP AT l_rk_faell-t_rk_pos INTO DATA(l_rk_pos).
*        SORT l_rk_pos-t_rk_sol_ist BY lauf_vorgang. " kleinste Nummer zuerst
        " Sort geht nicht, da LAUF_VORGANG C20 ist
        CLEAR: lt_laufid, lt_soll_ist.
        LOOP AT l_rk_pos-t_rk_sol_ist ASSIGNING FIELD-SYMBOL(<fs_sol_ist>).
          IF lt_soll_ist IS INITIAL.
            INSERT <fs_sol_ist> INTO lt_soll_ist INDEX 1.
            INSERT VALUE #( lauf_id = <fs_sol_ist>-lauf_vorgang ) INTO lt_laufid INDEX 1.
            CONTINUE.
          ENDIF.

          LOOP AT lt_laufid INTO DATA(ls_tabix) WHERE lauf_id < <fs_sol_ist>-lauf_vorgang.
            lv_tabix = sy-tabix.
          ENDLOOP.
          IF sy-subrc = 0.
            ADD 1 TO lv_tabix.
          ELSE.
            lv_tabix = 1.
          ENDIF.
          INSERT <fs_sol_ist> INTO lt_soll_ist INDEX lv_tabix.
          INSERT VALUE #( lauf_id = <fs_sol_ist>-lauf_vorgang ) INTO lt_laufid INDEX lv_tabix.
        ENDLOOP.

        LOOP AT lt_soll_ist INTO DATA(l_rk_sol_ist).
          DATA(lv_sytabix) = sy-tabix.
          APPEND INITIAL LINE TO et_beleg ASSIGNING FIELD-SYMBOL(<beleg>).

          <beleg>-belnr_mig = l_rk_pos-pos_nr.
          <beleg>-buzei_mig = l_rk_sol_ist-lauf_vorgang.
          IF l_rk_pos-haup_nebenforderung = 'H'.
            l_belnr_mig_hf = <beleg>-belnr_mig.
            <beleg>-blart  = l_rk_pos-haup_nebenforderung.
          ELSE.
            <beleg>-blart = l_rk_pos-nefschluessel.
          ENDIF.
          <beleg>-awkey = l_rk_sol_ist-lauf_vorgang.
          <beleg>-xblnr = l_dto_rk-kassenzeichen.

          IF l_rk_sol_ist-soll <> '0'.
            "Es handelt sich um eine Sollstellung
            DATA(lv_betrag_soll) = CONV dmbtr( l_rk_sol_ist-soll ).
            IF lv_betrag_soll > 0.
              <beleg>-dmbtr = l_rk_sol_ist-soll.  " Betrag in Hauswährung
              <beleg>-bschl = '01'.    "Forderungen
            ELSE.
              <beleg>-dmbtr = abs( l_rk_sol_ist-soll ).  " Betrag in Hauswährung
              <beleg>-bschl = '11'.    "Gutschrift
            ENDIF.


            IF <beleg>-blart = 'H'.  "Hauptforderung
              <beleg>-zfbdt = l_rk_pos-faellig."HF soll Fälligkeistdatum des RK haben "l_rk_sol_ist-dat_nf_gueltig_ab.
              "Migrierte Hauptforderung lesen
              DATA(lv_posnr_dkw) = CONV /thkr/rk_pos_nr( l_rk_sol_ist-posnr_dkw ).
              LOOP AT lt_dto_mig_ao INTO DATA(l_dto_mig_ao) "bei Dauer AO gibt es mehrere HF gleichberechtigt nebeneinander
                WHERE haup_nebenforderung <> 'N' AND rk_pos_nr = lv_posnr_dkw AND migrationsobjekt <> 'SSTW'.   "offene Posten der Kasse /SSTW nur Hüllen, daher außen vor lassen
                "migrierter OP gefunden
                <beleg>-bukrs = l_dto_mig_ao-bukrs.
                <beleg>-belnr = l_dto_mig_ao-belnr.
                <beleg>-gjahr = l_dto_mig_ao-gjahr.
                <beleg>-kunnr = l_dto_mig_ao-partner. "  Geschäftspartnernummer
                EXIT.
              ENDLOOP.
              IF sy-subrc <> 0.
                " wenn HF, aber dkw Nummer nicht vorhanden, dann RKSI_POSITION nutzen
                LOOP AT lt_dto_mig_ao INTO l_dto_mig_ao "bei Dauer AO gibt es mehrere HF gleichberechtigt nebeneinander
                  WHERE haup_nebenforderung <> 'N' AND rk_pos_nr = l_rk_sol_ist-rksi_position AND migrationsobjekt <> 'SSTW'.   "offene Posten der Kasse /SSTW nur Hüllen, daher außen vor lassen
                  "migrierter OP gefunden
                  <beleg>-bukrs = l_dto_mig_ao-bukrs.
                  IF l_dto_mig_ao-belnr IS NOT INITIAL.
                    <beleg>-belnr = l_dto_mig_ao-belnr.
                  ELSE.
                    <beleg>-belnr = l_dto_mig_ao-belnr_fb. "Bei Gutschriften/Minderungen aus RK
                  ENDIF.
                  <beleg>-gjahr = l_dto_mig_ao-gjahr.
                  <beleg>-kunnr = l_dto_mig_ao-partner. "  Geschäftspartnernummer
                  " diesen Fall für den Rechnungsbezug merken
                  lv_no_dkw = abap_true.
                  EXIT.
                ENDLOOP.
                IF sy-subrc <> 0. " passiert wenn wir keine HF zu einer NF haben
                  lv_no_dkw = abap_true.
                ENDIF.
              ENDIF.

            ELSE.
              "Nebenforderung
              <beleg>-zfbdt = l_rk_sol_ist-dat_nf_gueltig_ab.

              "Migrierte Nebenforderung lesen
              LOOP AT lt_dto_mig_ao INTO l_dto_mig_ao
                WHERE rk_pos_nr = l_rk_pos-pos_nr.
                "migrierte Nebenforderung gefunden
                <beleg>-bukrs = l_dto_mig_ao-bukrs.
                IF l_dto_mig_ao-belnr IS NOT INITIAL.
                  <beleg>-belnr = l_dto_mig_ao-belnr.
                ELSE.
                  <beleg>-belnr = l_dto_mig_ao-belnr_fb. "Bei Gutschriften/Minderungen aus RK
                ENDIF.
                <beleg>-gjahr = l_dto_mig_ao-gjahr.
                <beleg>-kunnr = l_dto_mig_ao-partner. "  Geschäftspartnernummer

                EXIT.
              ENDLOOP.

            ENDIF.
          ELSEIF l_rk_sol_ist-ist <> '0'.
            DATA(lv_betrag_ist) = CONV dmbtr( l_rk_sol_ist-ist ).
            lv_betrag_soll      = CONV dmbtr( l_rk_sol_ist-soll ).
            IF lv_betrag_ist > 0.
              <beleg>-bschl = '15'.    "Zahlungen
              <beleg>-dmbtr = l_rk_sol_ist-ist.         " Betrag in Hauswährung
            ELSE.
              <beleg>-bschl = '05'.    "Zahlungsausgang
              <beleg>-dmbtr = abs( l_rk_sol_ist-ist ).         " Betrag in Hauswährung
            ENDIF.
            <beleg>-zfbdt = l_rk_sol_ist-dat_einzahl. "  Basisdatum für Fälligkeitsberechnung

            " negative Beträge werden teilweise als Absetzungen gebucht.
            " in der SOll/IST Zeile kann das Ist dabei Positiv oder Negativ sein, Die Summe auf Position iist dann negativ
            LOOP AT lt_dto_mig_ao INTO l_dto_mig_ao WHERE rk_pos_nr = l_rk_pos-pos_nr AND rk_abs = abap_true AND belnr_fb IS NOT INITIAL.
              <beleg>-bukrs = l_dto_mig_ao-bukrs.
              <beleg>-belnr = l_dto_mig_ao-belnr_fb.
              <beleg>-gjahr = l_dto_mig_ao-gjahr.
              <beleg>-kunnr = l_dto_mig_ao-partner.

              EXIT.
            ENDLOOP.
          ENDIF.

          <beleg>-koart = 'D'.       " Kontoart
          <beleg>-sgtxt  = l_rk_sol_ist-grund. " Positionstext
*          <beleg>-sgtxt  = l_rk_pos-grund. " Positionstext

          <beleg>-manst = l_rk_pos-mahnstatus. "  Mahnstufe
          <beleg>-maber = 'ABC'.  " Mahnbereich

          <beleg>-quelle = l_rk_sol_ist-quelle.
          <beleg>-zinsschluessel = l_rk_pos-zins_schluessel.

          " Logik für Rechnungsbezug
          SHIFT l_rk_sol_ist-rksi_position LEFT DELETING LEADING '0'.
          SHIFT l_rk_sol_ist-posnr_dkw LEFT DELETING LEADING '0'.
          IF l_rk_sol_ist-posnr_dkw <> l_rk_sol_ist-rksi_position AND lv_no_dkw IS INITIAL.
            " alle HF und NF die sich auf eine andere Forderung beziehen
            <beleg>-rebzg = CONV /thkr/rk_pos_nr( l_rk_sol_ist-posnr_dkw ).
          ELSE.
            " eigene POS_Nr und Verwender gleich, dann
            IF lv_sytabix = 1 AND l_rk_pos-haup_nebenforderung = 'H'.
              " 1. HF bleibt leer, weil führend
              <beleg>-rebzg = ''.
            ELSEIF lv_sytabix = 1 AND l_rk_pos-haup_nebenforderung = 'N'.
              " 1. NF bezieht sich immer auf HF gleicher Fälligkeit
              " können mehrere Zeilen sein, dann haben die aber immer gleiche POS_NR
              READ TABLE l_rk_faell-t_rk_pos INTO DATA(ls_pos_hf) WITH KEY haup_nebenforderung = 'H'.
              IF sy-subrc = 0.
                <beleg>-rebzg = CONV /thkr/rk_pos_nr( ls_pos_hf-pos_nr ).
              ENDIF.
            ELSE. "  lv_sytabix > 1 und egal ob H und N
              " jede weitere Forderung beziegt sich auf Ursprung
              IF lv_no_dkw IS INITIAL.
                <beleg>-rebzg = CONV /thkr/rk_pos_nr( l_rk_sol_ist-posnr_dkw ).
              ELSE.
                <beleg>-rebzg = CONV /thkr/rk_pos_nr( l_rk_sol_ist-rksi_position ).
              ENDIF.
            ENDIF.
          ENDIF.

*         Sicherstellen, dass Geschäftsjahr immer gesetzt ist.
          IF <beleg>-belnr IS NOT INITIAL AND <beleg>-gjahr IS INITIAL OR <beleg>-gjahr = '0000'.
            <beleg>-gjahr = lv_gjahr.
          ENDIF.

        ENDLOOP. " t_rk_sol_ist
      ENDLOOP. " t_rk_pos
    ENDLOOP. " t_rk_faell

* NF ohne Beleg noch einmal prüfen, ob ein Fälligkeiten übergreifende Beziehung besteht. (Stundungsketten)
* Beim Rechnungsbezug wurden diese Ketten aufgebaut
    LOOP AT et_beleg ASSIGNING FIELD-SYMBOL(<fs_beleg>) WHERE belnr IS INITIAL AND blart <> 'H'.
      LOOP AT et_beleg INTO DATA(ls_pos_rebz) WHERE rebzg = <fs_beleg>-belnr_mig AND ( buzei_mig <> <fs_beleg>-buzei_mig OR belnr_mig <> <fs_beleg>-belnr_mig ) AND belnr IS NOT INITIAL.
        <fs_beleg>-belnr = ls_pos_rebz-belnr.
        <fs_beleg>-gjahr = ls_pos_rebz-gjahr.
        <fs_beleg>-bukrs = ls_pos_rebz-bukrs.
      ENDLOOP.
    ENDLOOP.

* Wenn Belegnummer vorgegeben, dann nur die Positionen aus dem RK übernehmen die der Beleg entsprechen
    IF i_belnr IS NOT INITIAL.
      LOOP AT et_beleg INTO DATA(ls_beleg) WHERE NOT ( belnr = i_belnr AND gjahr = i_gjahr AND bukrs = i_bukrs ).
        DELETE TABLE et_beleg FROM ls_beleg.
      ENDLOOP.
    ENDIF.



  ENDMETHOD.


  METHOD get_dto_mig_ao.

    DATA: l_selection TYPE /thkr/s_mig_ao_sap_selection,
          lv_date     TYPE sy-datum,
          lv_stichtag TYPE budat.

    CLEAR: e_dto.


*      BREAK zhm000000144.

    IF i_satz_id IS NOT INITIAL.
      APPEND INITIAL LINE TO l_selection-r_satz_id ASSIGNING FIELD-SYMBOL(<satz_id>).
      <satz_id>-low    = i_satz_id.
      <satz_id>-sign   = 'I'.
      <satz_id>-option = 'EQ'.
    ELSEIF i_xblnr IS NOT INITIAL.
      l_selection-xblnr = i_xblnr.
      l_selection-xblnr_pos_nr = i_xblnr_pos_nr.
      IF i_haupt_nebenforderung IS NOT INITIAL.
        l_selection-haupt_nebenforderung = VALUE #( ( sign = 'I' option = 'EQ' low = i_haupt_nebenforderung ) ).
        IF i_haupt_nebenforderung = 'H'. "Notlösung KH1 Tests bis zum nächsten Import aller Daten
          l_selection-haupt_nebenforderung = VALUE #( ( sign = 'I' option = 'EQ' low = '' ) ( sign = 'I' option = 'EQ' low = 'H' )  ).
        ENDIF.
      ENDIF.
    ELSE.
      ASSERT i_satz_id IS NOT INITIAL.
    ENDIF.

    l_selection-flag_select_message = 'X'.
    l_selection-flag_select_details = 'X'.


    get_tdto_mig_ao(
      EXPORTING
        i_selection = l_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

    READ TABLE lt_dto INDEX 1 INTO e_dto.

    IF NOT e_dto-t_rate IS INITIAL.

      IF e_dto-migrationsobjekt = 'SSTW'.
*	Wiederkehrende Anordnungen, nur anlegen wenn es Raten an/nach dem Stichtag gibt.

        SELECT SINGLE budat INTO lv_stichtag FROM /thkr/mig_md.

        e_dto-naehsterabrechtermin = space.

        LOOP AT e_dto-t_rate ASSIGNING FIELD-SYMBOL(<rate_sstw>).
          IF <rate_sstw>-ratenistbetrag EQ '0.00' AND <rate_sstw>-faelligkeitrate >= lv_stichtag .
            e_dto-naehsterabrechtermin = <rate_sstw>-faelligkeitrate.
            e_dto-letzteratesollbetrag = <rate_sstw>-ratensollbetrag.
            EXIT. "nur 1. offene Position nach Stichtag / Sortierung  aus SAP = letzte Fälligkeit zuerst
          ENDIF.
        ENDLOOP.

* AO nicht anlegen,wenn keine Rate nach Stichtag vorhanden ist
* => e_dto-naehsterabrechtermin = space.
* Abfrage in der Methode PROCESS_MIG_AO, wenn naehsterabrechtermin initial ist


      ELSE.

* 1. DBATR, nächsten Abrechnungstermin der Dauerbuchung ergänzen
* DBATR = wenn Ist Betrag = 0
        LOOP AT e_dto-t_rate ASSIGNING FIELD-SYMBOL(<rate>).
          IF <rate>-ratenistbetrag EQ '0.00'.
            e_dto-naehsterabrechtermin = <rate>-faelligkeitrate.
            e_dto-letzteratesollbetrag = <rate>-ratensollbetrag.
            e_dto-erstefaelligkeit     = <rate>-FaelligkeitRate.
            EXIT. "nur 1. offene Position / Sortierung  aus SAP = letzte Fälligkeit zuerst
          ENDIF.
        ENDLOOP.

      ENDIF.

    ENDIF.


* Tag der Ausführung bestimmen, für SSTW und AWD
* Berechnung anhand der der Zahlweis V,1-9, ......

    IF NOT e_dto-kennzeichenzahlweise IS INITIAL.
*      e_dto-tagderausfuehrung = 'NN'.  "01-31 !

      lv_date = e_dto-erstefaelligkeit.

      get_execute_day(
        EXPORTING
          i_zahlweise           = e_dto-kennzeichenzahlweise
          i_date                = lv_date
          i_factory_calendar_id = '01'
        IMPORTING
          e_day                 = DATA(lv_day) ).

      e_dto-tagderausfuehrung = lv_day.

    ENDIF.


  ENDMETHOD.


  METHOD get_dto_mig_rk.

    DATA: l_selection TYPE /thkr/s_mig_rk_sap_selection.

    CLEAR: e_dto.

    IF i_satz_id IS NOT INITIAL.
      APPEND INITIAL LINE TO l_selection-r_satz_id ASSIGNING FIELD-SYMBOL(<satz_id>).
      <satz_id>-low    = i_satz_id.
      <satz_id>-sign   = 'I'.
      <satz_id>-option = 'EQ'.
    ELSEIF i_xblnr IS NOT INITIAL.
      l_selection-kassenzeichen = i_xblnr.
    ELSE.
      ASSERT 1 = 2.
    ENDIF.

    l_selection-flag_select_details = 'X'.

    get_tdto_mig_rk(
      EXPORTING
        i_selection = l_selection
      IMPORTING
        et_dto      = DATA(lt_dto) ).

    READ TABLE lt_dto INDEX 1 INTO e_dto.



    IF sy-subrc <> 0.
      IF i_satz_id IS NOT INITIAL.
        RAISE EXCEPTION TYPE /thkr/cx_mig
          MESSAGE e008(/thkr/mig) WITH i_satz_id.
      ELSE.
        RAISE EXCEPTION TYPE /thkr/cx_mig
          MESSAGE e008(/thkr/mig) WITH i_xblnr.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD get_dto_mig_rkfael_pos.


    get_dto_mig_rk(
      EXPORTING
        i_xblnr = i_xblnr
      IMPORTING
        e_dto   = DATA(l_dto) ).

    MOVE-CORRESPONDING  l_dto TO e_dto.




    READ TABLE l_dto-t_rk_faell WITH KEY faellig_dtu = i_faellig INTO DATA(l_fael).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_mig
      MESSAGE e009(/thkr/mig) WITH i_xblnr i_faellig.
    ENDIF.

    READ TABLE l_fael-t_rk_pos WITH KEY haup_nebenforderung = i_hf_nf INTO DATA(l_pos).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_mig
      MESSAGE e010(/thkr/mig) WITH i_xblnr i_faellig i_hf_nf.
    ENDIF.

    MOVE-CORRESPONDING l_pos TO e_dto.


  ENDMETHOD.


  METHOD get_dto_mig_rk_pos.

    DATA:
          lv_lauf_vorgang TYPE num20.


    get_dto_mig_rk(
      EXPORTING
        i_xblnr = i_xblnr
      IMPORTING
        e_dto   = DATA(l_dto) ).

    MOVE-CORRESPONDING  l_dto TO e_dto.
    IF i_haushaltsjahr IS INITIAL.
      READ TABLE l_dto-t_rk_pos WITH KEY pos_nr = i_pos_nr INTO DATA(l_pos).
    ELSE.
      READ TABLE l_dto-t_rk_pos WITH KEY pos_nr = i_pos_nr haushaltsjahr = i_haushaltsjahr INTO l_pos.
    ENDIF.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_mig
        MESSAGE e015(/thkr/mig) WITH i_xblnr i_pos_nr.
    ENDIF.

    MOVE-CORRESPONDING l_pos TO e_dto.
    READ TABLE l_dto-t_rk_ahe WITH KEY pos_nr = i_pos_nr INTO e_dto-ahe.


    LOOP AT l_pos-t_rk_sol_ist ASSIGNING FIELD-SYMBOL(<fs_rk_pos>).
      IF <fs_rk_pos>-dat_nf_gueltig_ab IS NOT INITIAL AND <fs_rk_pos>-dat_nf_gueltig_ab <> 0 AND <fs_rk_pos>-dat_nf_gueltig_ab <> '00000000'.
        " Da LAuf_Vorgang CHAR20 Feld funktioniert Sortierung nicht
        IF lv_lauf_vorgang IS INITIAL OR lv_lauf_vorgang > <fs_rk_pos>-lauf_vorgang.
          e_dto-dat_nf_gueltig_ab = <fs_rk_pos>-dat_nf_gueltig_ab.
          lv_lauf_vorgang = <fs_rk_pos>-lauf_vorgang.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF e_dto-dat_nf_gueltig_ab IS INITIAL.
      " bei Fällen wo kein Datum vorhanden ist, nehmen wir das Fälligkeitsdatum aus der Fälligkeit.
      " Vorher AHE Fälle prüfen und von dort nehmen
      READ TABLE l_dto-t_rk_ahe ASSIGNING FIELD-SYMBOL(<fs_ahe>) WITH KEY pos_nr = i_pos_nr.
      IF sy-subrc = 0 AND <fs_ahe>-haup_neben_for = 'N' AND <fs_ahe>-dat_faelligkeit_nf IS NOT INITIAL.
        e_dto-dat_nf_gueltig_ab = <fs_ahe>-dat_faelligkeit_nf.
      ELSEIF sy-subrc = 0 AND <fs_ahe>-haup_neben_for = 'H' AND <fs_ahe>-dat_faelligkeit_hf IS NOT INITIAL.
        e_dto-dat_nf_gueltig_ab = <fs_ahe>-dat_faelligkeit_hf.
      ELSE.
        e_dto-dat_nf_gueltig_ab = l_pos-faellig.
      ENDIF.

    ENDIF.

    IF e_dto-epl IS INITIAL AND e_dto-einzelplan IS NOT INITIAL.
      e_dto-epl = e_dto-einzelplan.
    ENDIF.

  ENDMETHOD.


  METHOD GET_EXECUTE_DAY.


* Umgesetzte Zahlweisen:
* V    gleiche Kalendertag
* 1-9, Werktag des Monats
* P    5 Tage vor Monatsende
* Q    4 Tage vor Monatsende
* R    3 Tage vor Monatsende
* S    2 Tage vor Monatsende
* T    1 Tag vor Monatsende
* U    am Monatsende
* H    füngletzter Arbeitstag im Monat
* I    viertletzter Arbeitstag im Monat
* J    drittletzter Arbeitstag im Monat
* K    vorletzter Arbeitstag im Monat
* L    letzter Arbeitstag im Monat




    DATA: lv_datum    TYPE sydatum,
          lv_count    TYPE n,
          lv_ende     TYPE n,
          lv_last_day TYPE sydatum.


    CONSTANTS: c_h TYPE n VALUE '5',
               c_i TYPE n VALUE '4',
               c_j TYPE n VALUE '3',
               c_k TYPE n VALUE '2',
               c_l TYPE n VALUE '1'.





*    BREAK zhm000000144.
    lv_datum = i_date.


    TRANSLATE i_zahlweise TO UPPER CASE.


    CASE i_zahlweise.
      WHEN '1' OR '2' OR '3' OR '4' OR '5' OR '6' OR '7' OR '8' OR '9'.
* 1-9 Werktag des Monats ******************************************************

* Start am 1. hochzählen entsprechend der Zahlweise und prüfen ob es ein Werktag/Arbeitstag ist
        lv_datum+6(2) = '01'.

        DO.
          CALL FUNCTION 'DATE_CHECK_WORKINGDAY'
            EXPORTING
              date                = lv_datum
              factory_calendar_id = i_factory_calendar_id
              message_type        = 'I'
            EXCEPTIONS
              OTHERS              = 1.

          IF sy-subrc NE 0.
*           keine Arbeitstag
          ELSE.
*           Arbeitstag
*           Anzahl Werktage ab dem 1. :
            ADD 1 TO lv_count.
          ENDIF.

          IF lv_count = i_zahlweise.
*           Zahlweise erreicht
            EXIT.
          ENDIF.

*         Tage hochzählen
          ADD  1 TO lv_datum.
        ENDDO.

        e_day = lv_datum+6(2).


      WHEN 'V' OR 'v'.
* gleicher Kalendertag ********************************************************
        e_day = lv_datum+6(2).


      WHEN 'P' OR 'Q' OR 'R' OR 'S' OR 'T' OR 'U' .
* x Tage vor Monatsende *******************************************************

* Monatsende bestimmen
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lv_datum
          IMPORTING
            last_day_of_month = lv_last_day
          EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.

        IF sy-subrc = 0.
* Tage abziehen entsprechend dem Parameter (Monatstage)
          IF i_zahlweise  EQ 'P'.
            SUBTRACT 5 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'Q'.
            SUBTRACT 4 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'R'.
            SUBTRACT 3 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'S'.
            SUBTRACT 2 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'T'.
            SUBTRACT 1 FROM lv_last_day.
            e_day = lv_last_day+6(2).
          ELSEIF
             i_zahlweise  EQ 'U'.
            e_day = lv_last_day+6(2).
          ENDIF.
        ENDIF.


      WHEN 'H' OR 'I' OR 'J' OR 'K' OR'L'.
* Tage abziehen entsprechend dem Parameter (Werktage) *************************

        IF i_zahlweise  EQ 'H'.
          lv_ende = c_h.
        ELSEIF
           i_zahlweise  EQ 'I'.
          lv_ende = c_i.
        ELSEIF
           i_zahlweise  EQ 'J'.
          lv_ende = c_j.
        ELSEIF
          i_zahlweise  EQ 'K'.
          lv_ende = c_k.
        ELSEIF
          i_zahlweise  EQ 'L'.
          lv_ende = c_l.
        ENDIF.
        CHECK lv_ende IS NOT INITIAL.

* Monatsende bestimmen
        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
          EXPORTING
            day_in            = lv_datum
          IMPORTING
            last_day_of_month = lv_last_day
          EXCEPTIONS
            day_in_no_date    = 1
            OTHERS            = 2.

        IF sy-subrc = 0.
          DO.
* prüfen ob es ein Werktag ist
            CALL FUNCTION 'DATE_CHECK_WORKINGDAY'
              EXPORTING
                date                = lv_last_day
                factory_calendar_id = i_factory_calendar_id
                message_type        = 'I'
              EXCEPTIONS
                OTHERS              = 1.

            IF sy-subrc NE 0.
*           keine Arbeitstag
            ELSE.
*           Arbeitstag
*           Anzahl Werktage ab dem 1. :
              ADD 1 TO lv_count.
            ENDIF.

            IF lv_count = lv_ende.
*           Zahlweise erreicht
              EXIT.
            ENDIF.

*           Tage runter zählen
            SUBTRACT  1 FROM  lv_last_day.

          ENDDO.

          e_day = lv_last_day+6(2).
        ENDIF.


      WHEN OTHERS.
        e_day = space.

    ENDCASE.


  ENDMETHOD.


  METHOD GET_INSTANCE.

    IF instance IS INITIAL.

      CREATE OBJECT instance.

    ENDIF.

    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.


  METHOD get_satz_id_kass_op.

    IF i_sstw IS INITIAL.
      CONCATENATE 'RKP' i_xblnr i_pos_nr i_hf_nf INTO e_satz_id SEPARATED BY '_'.
    ELSE.
      CONCATENATE 'STW' i_xblnr i_pos_nr i_hf_nf INTO e_satz_id SEPARATED BY '_'.
    ENDIF.


  ENDMETHOD.


  METHOD get_tdto_mig_ao.

    DATA: l_select_clause         TYPE string,
          l_where_clause          TYPE string,
          l_select_clause_nf      TYPE string,
          l_select_clause_camt    TYPE string,
          l_select_clause_vsa_svz TYPE string,
          l_select_clause_ssts    TYPE string,
          l_where_clause_nf       TYPE string,
          l_where_clause_nf_sstw  TYPE string,
          l_and                   TYPE string,
          l_mo_nf                 TYPE c LENGTH 8,
          l_rk_pos_nr             TYPE /thkr/mig_ao_sap-rk_pos_nr,
          l_satz_id_rkp           TYPE string,
          l_satz_id_stw           TYPE string,
          l_eins                  TYPE i.

    DATA:
      lt_dto_edas     TYPE /thkr/t_dto_mig_ao_sap,
      ls_sstw_uez_dto TYPE /thkr/s_dto_mig_ao_sap.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_satz_id_rkp = 'RKP%'.
    l_satz_id_stw = 'STW%'.
    l_eins = 1.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_AO_SAP_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    CONCATENATE l_select_clause ', @l_eins as eins'
      INTO l_select_clause SEPARATED BY space.

    l_select_clause_nf = l_select_clause.

    CONCATENATE l_select_clause_nf ', ''NF'' as migrationsobjekt'
      INTO l_select_clause_nf SEPARATED BY space.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_AO'
        i_prefix           = 'b'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

* Zusatzdaten für AWD
    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_AO1'
        i_prefix           = 'b'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

* Zusatzdaten für SEPA - Mandate
    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_MANDAT'
        i_prefix           = 'b'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_ZP'
        i_prefix           = 'c'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_CAMT_SRC'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause_camt ).

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_VSA_SVZ'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause_vsa_svz ).

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_AO_SPLIT_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause_ssts ).


* Felder für NF ****************************************
    CONCATENATE l_select_clause_nf ', b~dienststelle, b~org_einheit as organisationseinheit, b~aktenzeichen'
        ', c~einzelplan, c~kapitel, c~titel, c~unterkonto'
      INTO l_select_clause_nf SEPARATED BY space.


* Where clause *****************************************
    IF i_selection-xblnr IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~xblnr = @i_selection-xblnr'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-xblnr_pos_nr IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~rk_pos_nr = @i_selection-xblnr_pos_nr'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-haupt_nebenforderung IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~haup_nebenforderung in @i_selection-haupt_nebenforderung'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.


    IF i_selection-bukrs IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~bukrs = @i_selection-bukrs'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-gjahr IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~gjahr = @i_selection-gjahr'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-belnr IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~belnr = @i_selection-belnr'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-r_satz_id IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~satz_id in @i_selection-r_satz_id'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-r_kassenzeichen IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~xblnr in @i_selection-r_kassenzeichen'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-r_status IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~status in @i_selection-r_status'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-einzelplan IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~epl = @i_selection-einzelplan'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-flag_ueberz_forderung IS NOT INITIAL AND NOT i_selection-migrationsobjekt = 'NF'.
      IF i_selection-migrationsobjekt IS NOT INITIAL.
        CONCATENATE l_where_clause l_and 'b~BETRAGOFFEN LIKE ''-%'''
          INTO l_where_clause SEPARATED BY space.
      ELSE.
        CONCATENATE l_where_clause l_and '( b~migrationsobjekt = ''SSTE'' or b~migrationsobjekt = ''SEE_E'' or b~migrationsobjekt = ''SSTE'' ) and b~BETRAGOFFEN LIKE ''-%'''
          INTO l_where_clause SEPARATED BY space.
      ENDIF.
      l_and = 'and'.
    ENDIF.

    IF i_selection-flag_betrag_0 IS NOT INITIAL AND NOT i_selection-migrationsobjekt = 'NF'.
      IF i_selection-migrationsobjekt IS NOT INITIAL.
        CONCATENATE l_where_clause l_and ' ( b~BETRAGOFFEN = ''0.00''' 'OR b~BETRAGOFFEN = ''0'' )'
         INTO l_where_clause SEPARATED BY space.
      ELSE.
        CONCATENATE l_where_clause l_and '( b~migrationsobjekt = ''SSTE'' or b~migrationsobjekt = ''SEE_E'' or b~migrationsobjekt = ''SSTS'') and ( b~BETRAGOFFEN = ''0''' 'OR b~BETRAGOFFEN = ''0'' )'
          INTO l_where_clause SEPARATED BY space.
      ENDIF.
      l_and = 'and'.
    ENDIF.

    l_where_clause_nf = l_where_clause.

* Ab hier getrennte where clauses ************************************************************

    CONCATENATE l_where_clause_nf l_and
       '( a~satz_id like @l_satz_id_rkp OR a~satz_id like @l_satz_id_stw )'
       INTO l_where_clause_nf SEPARATED BY space.

***********************************************************************************************
    IF i_selection-migrationsobjekt IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
       'b~migrationsobjekt = @i_selection-migrationsobjekt'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-process_id IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
       'a~process_id = @i_selection-process_id'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-sstwuz IS NOT INITIAL.

      CONCATENATE l_where_clause_nf l_and
       'a~SSTW_UEBERZAHLUNG = @i_selection-sstwuz'
        INTO l_where_clause_nf SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-rk_abs IS NOT INITIAL.

      CONCATENATE l_where_clause_nf l_and
       'a~rk_abs = @i_selection-rk_abs'
        INTO l_where_clause_nf SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

**********************************************************************
* Sonerfall SSTW Nebenforderungen, keine RK vorhanden
*    IF i_selection-sstwuz IS NOT INITIAL.
*      CONCATENATE l_where_clause_nf_sstw l_and
*       'SSTW_UEBERZAHLUNG = @i_selection-sstwuz'
*        INTO l_where_clause_nf_sstw SEPARATED BY space.
    l_where_clause_nf_sstw = |SSTW_UEBERZAHLUNG = 'X'|.
    l_and = 'and'.
*    ENDIF.
    IF i_selection-r_satz_id IS NOT INITIAL.
      CONCATENATE l_where_clause_nf_sstw l_and
        'satz_id in @i_selection-r_satz_id'
        INTO l_where_clause_nf_sstw SEPARATED BY space.
      l_and = 'and'.
    ENDIF.
    IF i_selection-r_kassenzeichen IS NOT INITIAL.
      CONCATENATE l_where_clause_nf_sstw l_and
        'xblnr in @i_selection-r_kassenzeichen'
        INTO l_where_clause_nf_sstw SEPARATED BY space.
      l_and = 'and'.
    ENDIF.
**********************************************************************



    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/mig_ao_sap AS a
      INNER JOIN /thkr/migdao AS b
        ON a~satz_id = b~satz_id
      INNER JOIN /thkr/migdzp AS c
        ON a~satz_id = c~satz_id
      WHERE (l_where_clause).

    IF ( i_selection-migrationsobjekt IS INITIAL
        OR i_selection-migrationsobjekt = 'NF' )   "Nebenforderung
      AND i_selection-process_id IS INITIAL        "Nebenforderungen sind keinem Importprozess zugeordnet
      AND i_selection-flag_no_kass_ops IS INITIAL.
      "Für Nebenforderungen gibt es (aktuell) keine Daten in /thkr/migdau ff.

      SELECT (l_select_clause_nf)
        FROM /thkr/mig_ao_sap AS a
        INNER JOIN /thkr/migd_rk AS b       "Rückstandskonto
          ON a~xblnr = b~kassenzeichen
        INNER JOIN /thkr/migd_rkfap AS c    "Rückstandskonto-Position
          ON b~satz_id = c~satz_id AND a~rk_pos_nr = c~pos_nr
        WHERE (l_where_clause_nf)
        APPENDING CORRESPONDING FIELDS OF TABLE @et_dto.

      SORT et_dto BY satz_id.
      DELETE ADJACENT DUPLICATES FROM et_dto COMPARING satz_id."bei SSTW kann es auf Grund mehrere Jahre zu Dopplungen kommen

    ENDIF.

    IF l_where_clause_nf_sstw IS NOT INITIAL.
      " SSTW fehlende Raten in 2025 haben ggf. kein RK , aber werden als NF Fälle erkannt
      SELECT *
         FROM /thkr/mig_ao_sap
         WHERE (l_where_clause_nf_sstw)
        INTO @DATA(ls_sstw_uez_ao_sap).
        READ TABLE et_dto TRANSPORTING NO FIELDS WITH KEY satz_id = ls_sstw_uez_ao_sap-satz_id.
        IF sy-subrc <> 0.
          " abhängige Daten aus original SSTW laden
          SELECT SINGLE b~*, c~*
             INTO @DATA(ls_migdao_uez)
             FROM /thkr/mig_ao_sap AS a
             INNER JOIN /thkr/migdao AS b
               ON a~satz_id = b~satz_id
             INNER JOIN /thkr/migdzp AS c
               ON a~satz_id = c~satz_id
             WHERE b~kassenzeichen = @ls_sstw_uez_ao_sap-xblnr AND b~migrationsobjekt = 'SSTW'.
          MOVE-CORRESPONDING ls_migdao_uez-b TO ls_sstw_uez_dto.
          MOVE-CORRESPONDING ls_migdao_uez-c TO ls_sstw_uez_dto.
          MOVE-CORRESPONDING ls_sstw_uez_ao_sap TO ls_sstw_uez_dto.
          ls_sstw_uez_dto-migrationsobjekt = 'SSTW'.
          APPEND ls_sstw_uez_dto TO et_dto.
        ENDIF.
      ENDSELECT.
    ENDIF.

* Hier lese ich die Raten zum Beispiel für AWD nach!

    IF i_selection-flag_select_details IS NOT INITIAL.

      LOOP AT et_dto ASSIGNING <dto>.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE @<dto>-t_rate
          FROM /thkr/migdaor
          WHERE satz_id = @<dto>-satz_id.

* Mail und Telefonnumer nachlesen  'ZHM000000144'
        SELECT SINGLE telefon, email
          INTO CORRESPONDING FIELDS OF @<dto>
          FROM /thkr/migd_lif
             WHERE epl            = @<dto>-epl
               AND zp_nummer      = @<dto>-zp_nr
               AND zp_lfd_nummer  = @<dto>-zp_lfd_nr.


      ENDLOOP.
    ENDIF.

*   CAMT Daten für IOS/VSA Migrationsobjekte
    LOOP AT et_dto ASSIGNING <dto> WHERE migrationsobjekt = 'IOS' OR migrationsobjekt = 'VSA'.
      SELECT SINGLE (l_select_clause_camt) INTO CORRESPONDING FIELDS OF @<dto>-s_camt
        FROM /thkr/migd_camt AS a
        WHERE satz_id = @<dto>-satz_id.
    ENDLOOP.

*   VSA-SVZ Zahlungsgründe für Vorschuss-Auszahlungen Kasse
    LOOP AT et_dto ASSIGNING <dto> WHERE migrationsobjekt = 'VSA'.
      SELECT zeitbuchnummer, lfd_zeilennummer, zahlungsgrund INTO CORRESPONDING FIELDS OF TABLE  @<dto>-t_svz
        FROM /thkr/migdvsasvz
        WHERE satz_id = @<dto>-satz_id.
    ENDLOOP.

*   SSTS - Split Annahmeanordnungen
    LOOP AT et_dto ASSIGNING <dto> WHERE migrationsobjekt = 'SSTS'.
      SELECT (l_select_clause_ssts) INTO CORRESPONDING FIELDS OF TABLE  @<dto>-t_split
        FROM /thkr/migdaos AS a
        WHERE satz_id = @<dto>-satz_id.
    ENDLOOP.

* Überzahlte Forderungen oder Beträge = 0 immer kennzeichnen und EDAS_SOll
    LOOP AT et_dto ASSIGNING <dto> WHERE ( migrationsobjekt = 'SSTE' OR migrationsobjekt = 'SEE_E' ).
      IF <dto>-betragoffen CS '-'.
        <dto>-sste_ueberz_forderung = abap_true.
      ELSEIF <dto>-betragoffen = '0.00'.
        <dto>-betrag_0 = abap_true.
      ELSEIF <dto>-betragoffen <> '0.00'.
        CLEAR <dto>-betrag_0.
      ENDIF.

      "EDAS SOLL Betrag
      IF <dto>-epl = '50' AND <dto>-sollbetrag <> '0.00' AND <dto>-istbetrag <> '0.00'.
        <dto>-edas_soll = abap_true.
      ENDIF.
    ENDLOOP.
    " gilt auch für SSTS
    LOOP AT et_dto ASSIGNING <dto> WHERE ( migrationsobjekt = 'SSTS' ).
      DATA(lv_splittbetragoffen) = CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN <dto>-t_split NEXT x += wa-splittbetragoffen ) + <dto>-betragoffen  ).
      <dto>-sste_ueberz_forderung = xsdbool( lv_splittbetragoffen < 0 ).
      <dto>-betrag_0 = xsdbool( lv_splittbetragoffen = 0 ).
    ENDLOOP.


    IF i_selection-flag_select_message IS NOT INITIAL.

      LOOP AT et_dto ASSIGNING <dto>.

        SELECT SINGLE b~mess INTO @<dto>-mess
          FROM /thkr/ln_evt AS a
          INNER JOIN /thkr/event AS b ON a~id = b~id
          WHERE a~ln_art = 'MIG_AO'
            AND a~ln_key = @<dto>-satz_id.

      ENDLOOP.
    ENDIF.

    LOOP AT et_dto ASSIGNING <dto> WHERE sstw_hauptforderung = abap_true.
      " hier ist das Feld Unterkonto leer, daher aus eigentlicher SSTW Datei setzen
      SELECT SINGLE unterkonto FROM /thkr/migdao INTO <dto>-unterkonto
        WHERE migrationsobjekt = 'SSTW' AND kassenzeichen = <dto>-xblnr.
    ENDLOOP.

    IF i_selection-p_edas_s = abap_true.
      " nur die Werte mit Soll > 0 und Ist > 0
      LOOP AT et_dto ASSIGNING <dto> WHERE sollbetrag <> '0.00' AND istbetrag <> '0.00'..
        <dto>-edas_soll = abap_true.
        APPEND <dto> TO lt_dto_edas.
      ENDLOOP.
      CLEAR et_dto.
      APPEND LINES OF lt_dto_edas TO et_dto.
    ENDIF.


  ENDMETHOD.


  METHOD get_tdto_mig_rk.

    DATA: l_select_clause TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_eins          TYPE i.

    FIELD-SYMBOLS <dto> LIKE LINE OF et_dto.

    CLEAR: et_dto.

    l_eins = 1.

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_RK_SAP_K'
        i_prefix           = 'a'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    helpers->get_select_clause_from_struct(
      EXPORTING
        i_structure        = '/THKR/S_MIG_RK'
        i_prefix           = 'c'
        i_comma_separation = 'X'
      CHANGING
        c_select_clause    = l_select_clause ).

    CONCATENATE l_select_clause ', @l_eins as eins'
      INTO l_select_clause SEPARATED BY space.

    IF i_selection-r_satz_id IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
        'a~satz_id in @i_selection-r_satz_id'
        INTO l_where_clause SEPARATED BY space.
      l_and = 'and'.
    ENDIF.

    IF i_selection-kassenzeichen IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
        'a~s_kassenzeichen = @i_selection-kassenzeichen'
        INTO l_where_clause SEPARATED BY space.
      l_and = 'and'.
    ENDIF.

    IF i_selection-r_kassenzeichen IS NOT INITIAL.
      CONCATENATE l_where_clause l_and
        'a~s_kassenzeichen in @i_selection-r_kassenzeichen'
        INTO l_where_clause SEPARATED BY space.
      l_and = 'and'.
    ENDIF.

    IF i_selection-dienststelle IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~s_dienststelle = @i_selection-dienststelle'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-epl IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~epl = @i_selection-epl'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    IF i_selection-process_id IS NOT INITIAL.

      CONCATENATE l_where_clause l_and
        'a~process_id = @i_selection-process_id'
        INTO l_where_clause SEPARATED BY space.

      l_and = 'and'.

    ENDIF.

    SELECT (l_select_clause)
      INTO CORRESPONDING FIELDS OF TABLE @et_dto
      FROM /thkr/mig_rk_sap AS a
      LEFT OUTER JOIN /thkr/migd_rk AS c
        ON a~satz_id = c~satz_id
      LEFT OUTER JOIN /thkr/migd_rk_zp AS b
        ON a~satz_id = b~satz_id AND b~zp_rolle = 'H'
      WHERE (l_where_clause).


    IF i_selection-flag_select_details IS NOT INITIAL.
      LOOP AT et_dto ASSIGNING <dto>.
        "Zahlungspartner
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF @<dto>-zp
          FROM /thkr/migd_rk_zp
          WHERE satz_id = @<dto>-satz_id
            AND zp_rolle = 'H'. "Hauptschuldner

        "Zahlungspartner Vetreter
        SELECT SINGLE *
          INTO CORRESPONDING FIELDS OF @<dto>-zp_v
          FROM /thkr/migd_rk_zp
          WHERE satz_id = @<dto>-satz_id
            AND zp_rolle = 'V'. "Hauptschuldner

        "Fälligkeiten einlesen
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE @<dto>-t_rk_faell ##TOO_MANY_ITAB_FIELDS
          FROM /thkr/migd_rk_fa
          WHERE satz_id = @<dto>-satz_id.

        "Positionen zur Fälligkeit einlesen
        LOOP AT <dto>-t_rk_faell ASSIGNING FIELD-SYMBOL(<rk_faell>).

          SELECT a~*, @<rk_faell>-faellig_dtu AS faellig
            INTO CORRESPONDING FIELDS OF TABLE @<rk_faell>-t_rk_pos ##TOO_MANY_ITAB_FIELDS
            FROM /thkr/migd_rkfap AS a
            WHERE satz_id     = @<dto>-satz_id
              AND faellig_dtu = @<rk_faell>-faellig_dtu.
          "Ist-Soll Buchungen zur Position einlesen
          LOOP AT <rk_faell>-t_rk_pos ASSIGNING FIELD-SYMBOL(<rk_pos>).
            SELECT *
              INTO CORRESPONDING FIELDS OF TABLE @<rk_pos>-t_rk_sol_ist
              FROM /thkr/migd_rk_si
              WHERE satz_id       = @<dto>-satz_id
                AND rksi_position = @<rk_pos>-pos_nr.
          ENDLOOP.

          APPEND LINES OF <rk_faell>-t_rk_pos TO <dto>-t_rk_pos.
        ENDLOOP.

        " Notizen zu RK
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE @<dto>-t_rkn
          FROM /thkr/migd_rkn
          WHERE satz_id = @<dto>-satz_id.
        " Vorgänge zu RK
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE @<dto>-t_rkv
          FROM /thkr/migd_rkv
          WHERE satz_id = @<dto>-satz_id.
        " Adresshistorie zum Schuldner
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE @<dto>-t_rka
          FROM /thkr/migd_rka
          WHERE satz_id = @<dto>-satz_id.
        " Amtshilfeersuchen zu RK
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE @<dto>-t_rk_ahe
          FROM /thkr/migd_ahe
          WHERE satz_id = @<dto>-satz_id. "Todo and positionsnummer = ?

        " BO-Reporthistorie
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE @<dto>-t_bore
          FROM /thkr/migd_bore
          WHERE satz_id = @<dto>-satz_id.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD init_kass_op.

    DATA:
      l_migdao      TYPE /thkr/migdao,
      lv_sstw       TYPE flag,
      lv_nuller_kaz TYPE flag,
      l_saldo       TYPE /thkr/amnt,
      l_soll        TYPE /thkr/amnt,
      l_ist         TYPE /thkr/amnt.

    get_dto_mig_rk(
      EXPORTING
        i_satz_id = i_satz_id
      IMPORTING
        e_dto     = DATA(l_dto_rk) ).

* wenn Satz ID schon initialisiert dann return. Es darf auf Anforderung aber überschrieben werden
    IF l_dto_rk-kass_op_initialized IS NOT INITIAL AND selection-flag_init_op_kassenzeichen IS INITIAL.
      RETURN.
    ENDIF.


    get_dto_mig_ao(
      EXPORTING
        i_xblnr                = l_dto_rk-s_kassenzeichen               " Kassenzeichen
        i_haupt_nebenforderung = 'H'
      IMPORTING
        e_dto                  = DATA(ls_ao_dto_h)                " DTO: Migration Anordnung
    ).


    SELECT SINGLE budat FROM /thkr/mig_md INTO @DATA(lv_budat).



* Folgende Offene Posten sollen aus der RK Datei erstellt werden:
* - Alle offenen Nebenforderungen
* - Alle offenen Hauptforderungen der Amtshilfe inkl. 000er Kassenzeichen ohne AHE Datei
* - Alle offenen Hauptforderungen von Daueranordnungen die vor dem Buchungsstichtag liegen


    LOOP AT l_dto_rk-t_rk_faell INTO DATA(l_rk_faell).
      LOOP AT l_rk_faell-t_rk_pos INTO DATA(l_rk_pos).
        "Definition 000er Kassenzeichen
        IF l_rk_pos-haup_nebenforderung = 'H' AND l_rk_pos-einzelplan = '93' AND l_rk_pos-kapitel = '4133'
            AND l_rk_pos-titel = '233 00' AND ( l_rk_pos-unterkonto = '00' OR l_rk_pos-unterkonto = '' ) AND
          l_dto_rk-zp_v-kennz_vertreter = 'G'.
          lv_nuller_kaz = abap_true.
        ELSE.
          CLEAR lv_nuller_kaz.
        ENDIF.

        " Defintion offene vergangene Dauer AO
        IF l_rk_pos-haup_nebenforderung = 'H' AND ls_ao_dto_h-migrationsobjekt = 'SSTW' AND l_rk_faell-faellig_dtu < lv_budat.
          lv_sstw = abap_true.
        ELSE.
          CLEAR lv_sstw.
        ENDIF.

        "Nur bei Amtshilfe auch Hauptforderungen berücksichtigen
        "oder 000er Kassenzeichen
        IF l_dto_rk-typ <> 'A' AND l_rk_pos-haup_nebenforderung = 'H' AND lv_nuller_kaz IS INITIAL AND lv_sstw IS INITIAL.
          CONTINUE.
        ENDIF.
***     WHERE haup_nebenforderung = 'N'.
        IF l_rk_pos-haup_nebenforderung = 'N'.
          l_soll = l_rk_pos-sollnf.
        ELSE.
          l_soll = l_rk_pos-sollhf.
        ENDIF.
        l_ist  = l_rk_pos-ist.
        l_saldo = l_soll - l_ist.
        IF l_saldo <= '0.00'.
          "Forderung bezahlt
          CONTINUE.
        ENDIF.

        get_satz_id_kass_op(
          EXPORTING
            i_xblnr   = l_dto_rk-s_kassenzeichen
            i_pos_nr  = l_rk_pos-pos_nr
            i_hf_nf   = l_rk_pos-haup_nebenforderung
            i_sstw    = lv_sstw
          IMPORTING
            e_satz_id = DATA(l_satz_id_rk_pos) ).

        SELECT SINGLE * INTO @DATA(l_ao_sap)
          FROM /thkr/mig_ao_sap
          WHERE satz_id = @l_satz_id_rk_pos.

        IF sy-subrc = 0 AND selection-flag_init_op_kassenzeichen IS INITIAL.
          CONTINUE.
        ENDIF.

        l_ao_sap-satz_id   = l_satz_id_rk_pos.
        l_ao_sap-xblnr     = l_dto_rk-s_kassenzeichen.
        l_ao_sap-rk_pos_nr = l_rk_pos-pos_nr.
        l_ao_sap-rk_pos_nr_haushaltsjahr = l_rk_pos-haushaltsjahr.
        l_ao_sap-epl       = l_rk_pos-einzelplan.
        l_ao_sap-zp_nr     = l_dto_rk-zp-zp_nummer.
        l_ao_sap-zp_lfd_nr = l_dto_rk-zp-zp_lfd_nummer.
        IF l_ao_sap-status  < '06'. "Status nicht überschreiben, wenn neu initialisiert
          l_ao_sap-status = '06'.
        ENDIF.
        l_ao_sap-haup_nebenforderung = l_rk_pos-haup_nebenforderung.
        IF l_rk_pos-haup_nebenforderung = 'N'.
          READ TABLE l_dto_rk-t_rk_faell ASSIGNING FIELD-SYMBOL(<fs_hf_faell>) WITH KEY faellig_dtu = ls_ao_dto_h-fealligkeit.
          IF sy-subrc = 0.
            READ TABLE <fs_hf_faell>-t_rk_pos ASSIGNING FIELD-SYMBOL(<fs_pos_h>) WITH KEY haup_nebenforderung = 'H'.
            IF sy-subrc = 0.
              l_ao_sap-pos_nr_haupforderung = <fs_pos_h>-pos_nr.
            ENDIF.
          ELSE.
            " MIG AO Ohne POS_NR_HAUPFORDERUNG
            READ TABLE l_rk_faell-t_rk_pos INTO DATA(ls_faell_h) WITH KEY haup_nebenforderung = 'H'.
            IF sy-subrc = 0.
              l_ao_sap-pos_nr_haupforderung = ls_faell_h-pos_nr.
            ELSE.
              " HF liegt in anderer Fälligkeit
              LOOP AT l_dto_rk-t_rk_faell ASSIGNING FIELD-SYMBOL(<fs_h_faell>) WHERE faellig_dtu <> l_rk_faell-faellig_dtu.
                READ TABLE <fs_h_faell>-t_rk_pos ASSIGNING FIELD-SYMBOL(<fs_faell_h>) WITH KEY haup_nebenforderung = 'H'.
                IF sy-subrc = 0.
                  l_ao_sap-pos_nr_haupforderung = <fs_faell_h>-pos_nr.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ELSE.
          l_ao_sap-pos_nr_haupforderung = l_rk_pos-pos_nr.
        ENDIF.
        l_ao_sap-nuller_kassenzeichen = lv_nuller_kaz.
        l_ao_sap-sstw_hauptforderung = lv_sstw.

        MODIFY /thkr/mig_ao_sap FROM l_ao_sap.

      ENDLOOP.

    ENDLOOP.

    UPDATE /thkr/mig_rk_sap
      SET kass_op_initialized ='X'
      WHERE satz_id = l_dto_rk-satz_id.

  ENDMETHOD.


  METHOD init_kass_ops.

    DATA: l_proc   TYPE REF TO /thkr/cl_bfw_process,
          l_ln_key TYPE /thkr/event_ln_key,
          l_ln_art TYPE /thkr/event_ln_art.

    selection = i_selection.

    "Prozess-Objekt erstellen, um Fehlermeldungen speichern zu lassen
    CREATE OBJECT l_proc
      EXPORTING
        i_process_type = 'RK_OP'.

    get_tdto_mig_rk(
      EXPORTING
        i_selection = i_selection
      IMPORTING
        et_dto      = DATA(lt_mig_rk) ).

    LOOP AT lt_mig_rk INTO DATA(l_mig_rk).

      TRY.

          "Eventuell vorhandene Meldungen zur Zeile löschen
          l_ln_art = 'RK_OP'.
          l_ln_key = l_mig_rk-satz_id.  "Satz_ID

          /thkr/cl_bfw_appl=>get_instance( )->delete_events_by_ln_key(
              i_ln_art         = l_ln_art
              i_ln_key         = l_ln_key ).

          COMMIT WORK.

          init_kass_op( i_satz_id = l_mig_rk-satz_id  ).

          COMMIT WORK.

        CATCH cx_root INTO DATA(l_oerror1).

          l_proc->add_event(
            EXPORTING
              i_event_category = 'E'
              i_exception      = l_oerror1
              i_ln_art         = l_ln_art
              i_ln_key         = l_ln_key ).

      ENDTRY.
    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
