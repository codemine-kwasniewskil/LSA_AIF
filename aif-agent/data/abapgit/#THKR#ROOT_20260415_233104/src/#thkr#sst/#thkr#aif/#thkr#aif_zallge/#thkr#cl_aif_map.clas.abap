class /THKR/CL_AIF_MAP definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_s_partner_iban_bvtyp,
        partner TYPE bu_partner,
        bpext   TYPE BU_BPEXT,
        iban    TYPE iban,
        BVTyP   TYPE bu_bkvid,
      END OF ty_s_partner_iban_bvtyp .
  types:
    TY_T_partner_iban_bvtyp TYPE STANDARD TABLE OF ty_s_partner_iban_bvtyp .
  types:
    BEGIN OF ty_s_partner_bank_sln_bvtyp,
        partner TYPE bu_partner,
        bpext   TYPE BU_BPEXT,
        BANKS   TYPE BANKS,
        BANKL   TYPE BANKK,
        BANKN   TYPE BANKN35,
        BVTyP   TYPE bu_bkvid,
      END OF ty_s_partner_bank_sln_bvtyp .
  types:
    TY_T_partner_bank_sln_bvtyp TYPE STANDARD TABLE OF ty_s_partner_bank_sln_bvtyp .

  class-data MO_INSTANCE type ref to /THKR/CL_AIF_MAP .
  constants GC_BKVID_0001 type BVTYP value '0001' ##NO_TEXT.

  class-methods GET_INSTANCE
    returning
      value(RO_INSTANCE) type ref to /THKR/CL_AIF_MAP .
  methods GET_BVTYP_BY_IBAN
    importing
      !IV_PARTNER type BU_PARTNER
      !IV_IBAN type IBAN
      !IV_BPEXT type BU_BPEXT
    returning
      value(RV_BVTYP) type STRING .
  methods GET_BVTYP_BY_BANKS_BANKN_BANKK
    importing
      !IV_PARTNER type BU_PARTNER
      !IV_BANKS type BANKS
      !IV_BANKL type BANKK
      !IV_BANKN type BANKN35
      !IV_BPEXT type BU_BPEXT
    returning
      value(RV_BVTYP) type STRING .
  methods CHECK_ZLSCHL_REQUIRES_BVTYP
    importing
      !IV_ZLSCH type DZLSCH
    returning
      value(RV_BVTYP_REQUIRED) type FLAG .
  methods GET_NEXT_BVTYP_FOR_PARTNER
    importing
      !IV_PARTNER type BU_PARTNER
    returning
      value(RV_BVTYP) type BU_BKVID .
  methods GET_BU_TYPE
    importing
      !IV_38_RES4 type STRING
      !IV_46_NAME2 type STRING
    returning
      value(RV_BU_TYPE) type BU_TYPE .
  methods GET_BU_TYPE_PSO_XML
    importing
      !IV_ANRED type AD_TITLETX
      !IV_NAME1 type STRING
      !IV_NAME2 type STRING
      !IV_NAME3 type STRING
      !IV_NAME4 type STRING
      !IV_STKZN type STKZN
    returning
      value(RV_BU_TYPE) type BU_TYPE .
  methods CHECK_IBAN
    importing
      !IV_IBAN type IBAN
    returning
      value(RV_IBAN_IS_VALID) type FLAG .
  methods GET_BANKN_VIA_IBAN
    importing
      !IV_IBAN type IBAN
    returning
      value(RV_BANKN) type BANKN35 .
  methods GET_FIXVALUES_FOR_HKONT
    importing
      !IV_FIELDNAME type STRING
    returning
      value(RV_VALUE_FIXVALUE) type STRING .
  methods GET_BVTYP_FROM_PARTNER
    importing
      !IV_PARTNER type BU_PARTNER
      !IV_BVNR type BVTYP
    returning
      value(RV_BVTYP) type BVTYP .
protected section.
private section.

  constants GC_BU_TYPE_PERS type BU_TYPE value '1' ##NO_TEXT.
  constants GC_BU_TYPE_ORG type BU_TYPE value '2' ##NO_TEXT.
  constants GC_NS_ZALLGE type /AIF/NS value 'ZALLGE' ##NO_TEXT.
  data MT_PARTNER_IBAN_BVTYP type TY_T_PARTNER_IBAN_BVTYP .
  data MT_PARTNER_BANK_SLN_BVTYP type TY_T_PARTNER_BANK_SLN_BVTYP .

  methods GET_BU_TYPE_VIA_DATA
    importing
      !IV_46_NAME2 type STRING
    returning
      value(RV_BU_TYPE) type BU_TYPE .
  methods GET_BU_TYPE_VIA_NAME
    importing
      !IV_38_RES4 type STRING
      !IV_46_NAME2 type STRING
    returning
      value(RV_BU_TYPE) type BU_TYPE .
  methods GET_BU_TYPE_VIA_DATA_PSO_XML
    importing
      !IV_ANRED type AD_TITLETX
    returning
      value(RV_BU_TYPE) type BU_TYPE .
  methods GET_BU_TYPE_VIA_NAME_PSO_XML
    importing
      !IV_NAME1 type STRING
      !IV_NAME2 type STRING
      !IV_NAME3 type STRING
      !IV_NAME4 type STRING
    returning
      value(RV_BU_TYPE) type BU_TYPE .
  methods GET_BVTYP_BANK_SLN_FOR_FILE
    importing
      !IV_PARTNER type BU_PARTNER
      !IV_BANKS type BANKS
      !IV_BANKL type BANKK
      !IV_BANKN type BANKN35
      !IV_BPEXT type BU_BPEXT
      !IV_BVTYP type BVTYP
    returning
      value(RV_BVTYP) type STRING .
ENDCLASS.



CLASS /THKR/CL_AIF_MAP IMPLEMENTATION.


  METHOD check_iban.
    CALL FUNCTION 'CHECK_IBAN'
      EXPORTING
        i_iban    = iv_iban
*       I_MOD97_CHECK_ONLY       =
*       I_ACCEPT_GAPS            =
      EXCEPTIONS
        not_valid = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      rv_iban_is_valid = abap_false.
    ELSE.
      rv_iban_is_valid = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD check_zlschl_requires_bvtyp.
    "Ermittlung, ob der Zahlweg eine Bankverbindung benötigt.
    "Siehe Transaktion OB28 für das Regelwerk
    "Werte werden im AIF-Mapping konfiguriert.
    SELECT SINGLE int_value
      FROM /aif/t_vmapval
     WHERE ns = 'ZALLGE'
       AND vmapname = 'MAP_ZLSCH_REQ_BVTYP'
       AND ext_value = @iv_zlsch
      INTO @rv_bvtyp_required.
    IF sy-subrc <> 0.
      "Keinen Eintrag gefunden. Keine Bankverbindung notwendig.
      rv_bvtyp_required = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD get_bankn_via_iban.

    CALL FUNCTION 'CONVERT_IBAN_2_BANK_ACCOUNT'
      EXPORTING
        i_iban         = iv_iban
*       I_POPUP        =
*       I_ACCNO_UNKNOWN          =
*       I_XIBAN_ONLY   =
*       I_BANKS        =
*       I_XCONVERT_ONLY          =
      IMPORTING
        e_bank_account = rv_bankn
*       E_BANK_CONTROL_KEY       =
*       E_BANK_COUNTRY =
*       E_BANK_NUMBER  =
      EXCEPTIONS
        no_conversion  = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      CLEAR: rv_bankn.
    ENDIF.
ENDMETHOD.


  METHOD get_bu_type.

    "Ermittlung des Geschäfspartnertyps anhand der Schnitstellendaten
    "Feld 55 in 46_NAME2
    rv_bu_type = get_bu_type_via_data( iv_46_name2 = iv_46_name2 ).
    IF rv_bu_type IS INITIAL.
      "Kein Kennzeichen geliefert.
      "Textvergleich.
      "Beide Namensfelder zusammenziehen und nach Organisationskennzeichen durchsuchen.
      rv_bu_type = get_bu_type_via_name(
                     iv_38_res4  = iv_38_res4
                     iv_46_name2 = iv_46_name2
                   ).
    ENDIF.
  ENDMETHOD.


  METHOD get_bu_type_pso_xml.


    "BU_TYPE anhand des FLAGS "natürliche Person" ermitteln.
    rv_bu_type = /thkr/cl_pso_xml_processing=>get_instance( )->map_bu_type( iv_stkzn = iv_stkzn ).
*    IF rv_bu_type IS INITIAL.
*      "Ermittlung des Geschäfspartnertyps anhand der Schnitstellendaten
*      "Feld 55 in 46_NAME2
*      rv_bu_type = get_bu_type_via_data_pso_xml( iv_anred = iv_anred ).
*      IF rv_bu_type IS INITIAL.
*        "Kein Kennzeichen geliefert.
*        "Textvergleich.
*        "Namensfelder zusammenziehen und nach Organisationskennzeichen durchsuchen.
*        rv_bu_type = get_bu_type_via_name_pso_xml(
*                       iv_name1 = iv_name1
*                       iv_name2 = iv_name2
*                       iv_name3 = iv_name3
*                       iv_name4 = iv_name4
*                     ).
*      ENDIF.
*    ENDIF.
  ENDMETHOD.


  METHOD get_bu_type_via_data.
    CONSTANTS: lc_vmapname TYPE /aif/vmapname VALUE 'MAP_BU_TYPE_BIC_TYPE'.
    Try.
    "Check whether the BU Type given by partner system
    "exists in AIF Vvalue mapping
    SELECT SINGLE int_value
      FROM /aif/t_vmapval
     WHERE ns = @gc_ns_zallge
       AND vmapname = @lc_vmapname
       AND ext_value = @iv_46_name2+54(1)
    INTO @rv_bu_type.
    IF sy-subrc <> 0.
      CLEAR: rv_bu_type.
    ENDIF.
    catch cx_sy_range_out_of_bounds.
      "46_NAME2 ist leer.
      "Kein Kennzeichen für den Organisationstyp
      clear: rv_bu_type.
    ENDTRY.
  ENDMETHOD.


  METHOD GET_BU_TYPE_VIA_DATA_PSO_XML.
    CONSTANTS: lc_vmapname TYPE /aif/vmapname VALUE 'MAP_ANRED_TO_BU_TYPE'.
    Try.
    "Check whether the BU Type given by partner system
    "exists in AIF Vvalue mapping
    SELECT SINGLE int_value
      FROM /aif/t_vmapval
     WHERE ns = @gc_ns_zallge
       AND vmapname = @lc_vmapname
       AND ext_value = @iv_anred
    INTO @rv_bu_type.
    IF sy-subrc <> 0.
      CLEAR: rv_bu_type.
    ENDIF.
    catch cx_sy_range_out_of_bounds.
      "iv_anred ist leer.
      "Kein Kennzeichen für den Organisationstyp
      clear: rv_bu_type.
    ENDTRY.
  ENDMETHOD.


  METHOD get_bu_type_via_name.
    CONSTANTS: lc_fixvaluename TYPE /aif/fixvaluename VALUE 'FVT_BU_TYPE_2_NAMES'.

    DATA(lv_name) = iv_38_res4 && iv_46_name2.
    rv_bu_type = gc_bu_type_pers.

    "Get name indicators for organisations.
    SELECT fieldvalue
      FROM /aif/t_tfix
     WHERE ns = @gc_ns_zallge
       AND fixvaluename = @lc_fixvaluename
    INTO TABLE @DATA(lt_org).

    IF sy-subrc = 0.
      LOOP AT lt_org ASSIGNING FIELD-SYMBOL(<ls_org>).
        find FIRST OCCURRENCE OF <ls_org> in lv_name MATCH COUNT FINAL(lc_count).
        IF lc_count > 0.
          "Part of company indicator found in name
          "Leave loop
          "Set BU_TYPE to 2 in condition or field mapping
          rv_bu_type = gc_bu_type_org.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
      "keine Kennzeichen für Organisationen hinterlegt.
      "Setze GP auf Person.
      rv_bu_type = gc_bu_type_pers.
    ENDIF.
  ENDMETHOD.


  METHOD GET_BU_TYPE_VIA_NAME_PSO_XML.
    CONSTANTS: lc_fixvaluename TYPE /aif/fixvaluename VALUE 'FVT_BU_TYPE_2_NAMES'.

    DATA(lv_name) = iv_name1 && iv_name2 && iv_name3 && iv_name4.
    rv_bu_type = gc_bu_type_pers.

    "Get name indicators for organisations.
    SELECT fieldvalue
      FROM /aif/t_tfix
     WHERE ns = @gc_ns_zallge
       AND fixvaluename = @lc_fixvaluename
    INTO TABLE @DATA(lt_org).

    IF sy-subrc = 0.
      LOOP AT lt_org ASSIGNING FIELD-SYMBOL(<ls_org>).
        IF lv_name CS <ls_org>.
          "Part of company indicator found in name
          "Leave loop
          "Set BU_TYPE to 2 in condition or field mapping
          rv_bu_type = gc_bu_type_org.
          EXIT.
        ENDIF.
      ENDLOOP.
    ELSE.
      "keine Kennzeichen für Organisationen hinterlegt.
      "Setze GP auf Person.
      rv_bu_type = gc_bu_type_pers.
    ENDIF.
  ENDMETHOD.


  METHOD get_bvtyp_bank_sln_for_file.

    DATA: lv_bvtyp TYPE bu_bkvid VALUE '0000'.
    SORT mt_partner_bank_sln_bvtyp BY partner ASCENDING bpext ASCENDING bvtyp ASCENDING.
    "Tabelle nach Partner und Bankverbindungstyp sortieren
    "zuletzt verwendete Bankverbindung steht beim Partner als 1.
    SORT mt_partner_bank_sln_bvtyp BY partner ASCENDING bpext ASCENDING bvtyp DESCENDING.
    READ TABLE mt_partner_bank_sln_bvtyp WITH KEY partner = iv_partner
                                              bpext = iv_bpext
                                              bvtyp = iv_bvtyp TRANSPORTING NO FIELDS.

    IF sy-subrc <> 0.
      "Bankverbindung wurde noch nicht verarbeitet.
      rv_bvtyp = iv_bvtyp.
      APPEND VALUE ty_s_partner_bank_sln_bvtyp( partner = iv_partner
                                                  bpext = iv_bpext
                                                  banks = iv_banks
                                                  bankl = iv_bankl
                                                  bankn = iv_bankn
                                                  bvtyp = rv_bvtyp ) TO mt_partner_bank_sln_bvtyp.
    ELSE.
      "Bankverbindung wurde bereits verarbeitet.
      "Prüfung, ob mehrere Bankverbindung für selben Geschäftspartner innerhalb der Datei vorliegen
      "in der Tabelle stimmen alle Werte überein, wenn es sich um die selbe Bankverbindung handelt.
      "Wenn Partner und BVTYP gleich sind, aber die IBAN abweicht,
      "Dann gibt es eine weitere Bankverbindung in der Datenlieferung. Dann muss der Zähler weiter hochgezählt werden
      READ TABLE mt_partner_bank_sln_bvtyp WITH KEY partner = iv_partner
                                                bpext = iv_bpext
                                                bvtyp = rv_bvtyp
                                                banks = iv_banks
                                                bankl = iv_bankl
                                                bankn = iv_bankn TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        "Wenn neue Bankverbindungen in der Datenlieferung existieren,
        "erhalten alle neuen Bankverbindung den BVTYP basierend vom letzten Stand der Datenbank.
        "Auf DB: BVTYP = 0001
        "erste neue IBAN in Datei: BVTYP = 0002
        "zweite neue IBAN in Datei: BVTYP =0002 --> Hier muss aber 0003 verwendet werden.
        "Daher reicht DB auslesen nicht aus. Es muss auch geprüft werden, was bereits in der Datei vorhanden war.
        LOOP AT mt_partner_bank_sln_bvtyp ASSIGNING FIELD-SYMBOL(<ls_bvtyp>) WHERE partner = iv_partner
                                                                           AND bpext = iv_bpext.

          "bereits eine Bankverbindung für BP verarbeitet.
          lv_bvtyp = <ls_bvtyp>-bvtyp.

          "Schleife verlassen
          EXIT.
        ENDLOOP.
        rv_bvtyp = |{ CONV bu_bkvid( lv_bvtyp + 1 ) ALPHA = IN }|.
        APPEND VALUE ty_s_partner_bank_sln_bvtyp( partner = iv_partner
                                                  bpext = iv_bpext
                                                  banks = iv_banks
                                                  bankl = iv_bankl
                                                  bankn = iv_bankn
                                                  bvtyp = rv_bvtyp ) TO mt_partner_bank_sln_bvtyp.


      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_bvtyp_by_banks_bankn_bankk.


    IF /thkr/cl_pso_xml_processing=>get_instance( )->check_bp_is_cpd(
                                                    EXPORTING
                                                      iv_bpex   = iv_bpext                 " Geschäftspartnernummer im externen System
                                                  ) = abap_true.
      "CPD -> immer auf 001
      rv_bvtyp = gc_bkvid_0001.
    ELSE.

      SORT mt_partner_bank_sln_bvtyp BY partner ASCENDING bpext ASCENDING banks ASCENDING bankl ASCENDING bankn ASCENDING.
      TRY.
          rv_bvtyp = |{ CONV bu_bkvid( mt_partner_bank_sln_bvtyp[ partner = iv_partner bpext = iv_bpext banks = iv_banks bankl = iv_bankl bankn = iv_bankn ]-bvtyp ) ALPHA = IN }|.
        CATCH cx_sy_itab_line_not_found.

          SELECT bkvid, banks, bankl, bankn, iban
                FROM but0bk
               WHERE partner = @iv_partner
                ORDER BY bkvid
                INTO TABLE @DATA(lt_bank).
          IF sy-subrc = 0.

            LOOP AT lt_bank ASSIGNING FIELD-SYMBOL(<ls_bank>).
              "SAP schneidet mal vorne mal hinten Nullen bei der Kontonummer beim Speichern ab.
              "Deshalb ein Contain String - Vergleich
              IF iv_banks = <ls_bank>-banks
              AND iv_bankl = <ls_bank>-bankl
              AND iv_bankn CS <ls_bank>-bankn.
                rv_bvtyp = <ls_bank>-bkvid.
              ENDIF.
            ENDLOOP.
            IF rv_bvtyp IS NOT INITIAL.
              APPEND VALUE ty_s_partner_bank_sln_bvtyp( partner = iv_partner
                                                        bpext = iv_bpext
                                                        banks = iv_banks
                                                        bankl = iv_bankl
                                                        bankn = iv_bankn
                                                        bvtyp = rv_bvtyp ) TO mt_partner_bank_sln_bvtyp.
              EXIT.
            ELSE.
              "Wieder nichts gefunden, dann nimm den letzten Wert und zähle ihn hoch.
              rv_bvtyp = | { CONV bu_bkvid( CONV i( lt_bank[ lines( lt_bank ) ]-bkvid ) + 1 ) ALPHA = IN } |.
              SHIFT rv_bvtyp LEFT DELETING LEADING space.
              "SLN = bankS, bankL und bankN
              rv_bvtyp = get_bvtyp_bank_sln_for_file(
                EXPORTING
                  iv_partner = iv_partner                 " Geschäftspartnernummer
                  iv_banks   = iv_banks                 " Bank Länder-/Regionenschlüssel
                  iv_bankl   = iv_bankl                 " Bankschlüssel
                  iv_bankn   = iv_bankn                 " Bankkontonummer
                  iv_bpext   = iv_bpext                 " Geschäftspartnernummer im externen System
                  iv_bvtyp   = CONV bvtyp( rv_bvtyp )
              ).

            ENDIF.

          ELSE.
            "Noch keine Bankinformation hinterlegt.
            rv_bvtyp = gc_bkvid_0001.
            rv_bvtyp = get_bvtyp_bank_sln_for_file(
              EXPORTING
                iv_partner = iv_partner                 " Geschäftspartnernummer
                iv_banks   = iv_banks                 " Bank Länder-/Regionenschlüssel
                iv_bankl   = iv_bankl                 " Bankschlüssel
                iv_bankn   = iv_bankn                 " Bankkontonummer
                iv_bpext   = iv_bpext                 " Geschäftspartnernummer im externen System
                iv_bvtyp   = CONV bvtyp( rv_bvtyp )
            ).
          ENDIF.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD get_bvtyp_by_iban.
    "IBAN geliefert.
    "Parnter geliefert.
    "Ermittlung Bankverbindung über TIBAN und BUT0BK
    DATA: lv_bvtyp TYPE bu_bkvid VALUE '0000'.
    SORT mt_partner_iban_bvtyp BY partner ASCENDING bpext ASCENDING iban ASCENDING.
    TRY.
        rv_bvtyp = |{ CONV bu_bkvid( mt_partner_iban_bvtyp[ partner = iv_partner bpext = iv_bpext iban = iv_iban ]-bvtyp ) ALPHA = IN }|.
      CATCH cx_sy_itab_line_not_found.
        "Bankverbindung wurde noch nicht verarbeitet.
        "Also von DB suchen.
        DATA(lv_iban) = iv_iban.
        CONDENSE lv_iban NO-GAPS.
        SELECT SINGLE bk~bkvid
            FROM but0bk AS bk
            INNER JOIN tiban AS t
            ON t~banks = bk~banks
            AND t~bankl = bk~bankl
            AND t~bankn = bk~bankn
            WHERE bk~partner = @iv_partner
            AND  t~iban = @lv_iban
            INTO @rv_bvtyp.

        IF sy-subrc = 0.
          "IBAN existert auf DB.
          "Merken.
          APPEND VALUE ty_s_partner_iban_bvtyp( partner = iv_partner
                                                iban = iv_iban
                                                bpext = iv_bpext
                                                bvtyp = rv_bvtyp ) TO mt_partner_iban_bvtyp.
        ELSE.
          "Keine Bankverbindung anhand der IBAN und dem Geschäftspartner gefunden.
          "Letzte Bankverbindungs-ID ermitteln und um 1 hochzählen.
          rv_bvtyp = get_next_bvtyp_for_partner(
                       iv_partner = iv_partner                 " Geschäftspartnernummer
                     ).

          "Tabelle nach Partner und Bankverbindungstyp sortieren
          "zuletzt verwendete Bankverbindung steht beim Partner als 1.
          SORT mt_partner_iban_bvtyp BY partner ASCENDING bpext ASCENDING bvtyp DESCENDING.
          READ TABLE mt_partner_iban_bvtyp WITH KEY partner = iv_partner
                                                    bpext = iv_bpext
                                                    bvtyp = rv_bvtyp TRANSPORTING NO FIELDS.

          IF sy-subrc <> 0.
            "Bankverbindung wurde noch nicht verarbeitet.
            APPEND VALUE ty_s_partner_iban_bvtyp( partner = iv_partner
                                               iban = iv_iban
                                               bpext = iv_bpext
                                               bvtyp = rv_bvtyp ) TO mt_partner_iban_bvtyp.
          ELSE.
            "Bankverbindung wurde bereits verarbeitet.
            "Prüfung, ob mehrere Bankverbindung für selben Geschäftspartner innerhalb der Datei vorliegen
            "in der Tabelle stimmen alle Werte überein, wenn es sich um die selbe Bankverbindung handelt.
            "Wenn Partner und BVTYP gleich sind, aber die IBAN abweicht,
            "Dann gibt es eine weitere Bankverbindung in der Datenlieferung. Dann muss der Zähler weiter hochgezählt werden
            READ TABLE mt_partner_iban_bvtyp WITH KEY partner = iv_partner
                                                      bpext = iv_bpext
                                                      bvtyp = rv_bvtyp
                                                      iban = iv_iban TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              "Wenn neue Bankverbindungen in der Datenlieferung existieren,
              "erhalten alle neuen Bankverbindung den BVTYP basierend vom letzten Stand der Datenbank.
              "Auf DB: BVTYP = 0001
              "erste neue IBAN in Datei: BVTYP = 0002
              "zweite neue IBAN in Datei: BVTYP =0002 --> Hier muss aber 0003 verwendet werden.
              "Daher reicht DB auslesen nicht aus. Es muss auch geprüft werden, was bereits in der Datei vorhanden war.
              LOOP AT mt_partner_iban_bvtyp ASSIGNING FIELD-SYMBOL(<ls_bvtyp>) WHERE partner = iv_partner
                                                                                 AND bpext = iv_bpext.

                "bereits eine IBAN für BP verarbeitet.
                lv_bvtyp = <ls_bvtyp>-bvtyp.

                "Schleife verlassen
                EXIT.
              ENDLOOP.
              rv_bvtyp = |{ CONV bu_bkvid( lv_bvtyp + 1 ) ALPHA = IN }|.
              APPEND VALUE ty_s_partner_iban_bvtyp( partner = iv_partner
                                                     bpext = iv_bpext
                                                    iban = iv_iban
                                                    bvtyp = rv_bvtyp ) TO mt_partner_iban_bvtyp.


            ENDIF.
          ENDIF.
        ENDIF.
    ENDTRY.
  ENDMETHOD.


  METHOD get_bvtyp_from_partner.
    SELECT bkvid, bkext
      FROM but0bk
     WHERE partner = @iv_partner
  ORDER BY bkvid ASCENDING
      INTO TABLE @DATA(lt_bvtyp).
    IF sy-subrc = 0.
      "Die Bankverbindung kommt aus der BIC-Datei
      "Feld 25_BVNR
      TRY.
          rv_bvtyp = lt_bvtyp[ bkext = iv_bvnr ]-bkvid.
        CATCH cx_sy_itab_line_not_found.
          "angegebene Bankverbindung existiert nicht.
          "Anordnung muss auf Fehler laufen.
          "Damit klar ist, welche Bankverbindung fehlschlägt,
          "wird die in der Datei angegebene Verbindung zurückgegeben.
          rv_bvtyp = |{ CONV bvtyp( iv_bvnr ) ALPHA = IN }|.
      ENDTRY.
    ELSE.
      "es gibt keine Bankverbindungen am Geschäftspartner
      "Nicht bei jedem Zahlweg ist eine Bankverbindung notwendig.
      "Also muss bleibt die Bankverbindung leer.

      CLEAR rv_bvtyp.
    ENDIF.
  ENDMETHOD.


  METHOD get_fixvalues_for_hkont.
    CONSTANTS: lc_ns_fremdv TYPE /AIF/ns VALUE 'FREMDV'.

    DATA: lv_ns TYPE /AIF/ns.
    DATA: lv_ifname TYPE /AIF/ifname.
    DATA: lv_ifversion TYPE /AIF/ifversion.

    "Laufzeitvariablen abrufen
    CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
      IMPORTING
        ns        = lv_ns
        ifname    = lv_ifname
        ifversion = lv_ifversion.
    SELECT SINGLE int_value
      FROM /AIF/T_VMAPval5
     WHERE ns = @lc_ns_fremdv
      AND ext_value1 = @lv_ns
      AND ext_value2 = @lv_ifname
      AND ext_value3 = @iv_fieldname
      INTO @DATA(lv_fixvalue_name).
    IF sy-subrc = 0.

      SELECT single fieldvalue
        FROM /aif/t_ffix
       WHERE ns = @lv_ns
        AND fixvaluename = @lv_fixvalue_name
        INTO @rv_value_fixvalue .

    ELSE.
      CLEAR: rv_value_fixvalue.
    ENDIF.

  ENDMETHOD.


  METHOD get_instance.
    IF mo_instance IS INITIAL.
      mo_instance = NEW #( ).
    ENDIF.

    ro_instance = mo_instance.
  ENDMETHOD.


  METHOD get_next_bvtyp_for_partner.
    IF iv_partner IS NOT INITIAL.
      SELECT MAX( bkvid )
            FROM but0bk
           WHERE partner = @iv_partner
            INTO @DATA(lv_bkvid).
      IF sy-subrc = 0.
        rv_bvtyp = |{ CONV bu_bkvid( lv_bkvid + 1 ) ALPHA = IN }|.
      ELSE.
        rv_bvtyp = gc_bkvid_0001.
      ENDIF.
    ELSE.
      "Partnernummer leer.
      "d.h. Partner existiert noch nicht im System.
      "Es wurde aber eine IBAN mitgeschickt --> 1. Bankverbindung
      rv_bvtyp = gc_bkvid_0001.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
