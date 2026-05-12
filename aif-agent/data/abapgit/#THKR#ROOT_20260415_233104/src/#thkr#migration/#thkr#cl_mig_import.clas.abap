class /THKR/CL_MIG_IMPORT definition
  public
  inheriting from /THKR/CL_BFW_PROCESS
  final
  create public .

public section.

  data TDTO_MIG_AO type /THKR/T_DTO_MIG_AO read-only .

  methods CONSTRUCTOR
    importing
      value(I_PROCESS_TYPE) type /THKR/PROCESS_TYPE optional
      value(I_SAVE_PROC) type XDEFAULT optional .
  methods PROCESS
    importing
      !I_MIGRATIONSOBJEKT type /THKR/MIGRATIONSOBJEKT
      !I_FILENAME type /THKR/FILE_W_PATH
      !I_DIRECTORY type STRING
      !I_FRONTEND type XFELD optional
      !I_EPL type /THKR/MIG_EPL optional
      !I_ARCHIV_DIRECTORY type /THKR/FILE_W_PATH optional
      !I_MOVE_ARCHIV type XFELD optional
      !I_PROT_DETAIL type XFELD optional
      !I_UPDATE_ALLOWED type XFELD optional .

  methods SAVE
    redefinition .
  PROTECTED SECTION.

    DATA attr TYPE /thkr/s_mig_imp .
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_MIG_IMPORT IMPLEMENTATION.


  METHOD constructor.

*    data l_process_type TYPE /thkr/process_type.
*    l_process_type = /thkr/cl_mig_def=>get_instance( )->process_type-mig_anordnung.

    super->constructor(
      i_process_type = i_process_type
      i_save_proc    = 'X' ).

  ENDMETHOD.


  METHOD process.

    TYPES lty_result TYPE x LENGTH 1024.

    DATA:
      lv_count        TYPE int4,
      lv_update       TYPE int4,
      lv_continue     TYPE int4,
      lt_result       TYPE STANDARD TABLE OF lty_result,
      l_cstring       TYPE string,
      l_xmlstr        TYPE xstring,
      l_satz_id       TYPE /thkr/de_satz_id,
      l_mig_ao        TYPE /thkr/s_mig_ao_file,
      l_message       TYPE string,
      l_mig_ao_sap    TYPE /thkr/mig_ao_sap,
      l_migdao        TYPE /thkr/migdao,
      l_migdzp        TYPE /thkr/migdzp,
      lt_migdaor      TYPE STANDARD TABLE OF /thkr/migdaor,
      l_migdaor       TYPE /thkr/migdaor,
      l_mig_rk        TYPE /thkr/s_mig_rk_file,
      l_migd_rk       TYPE /thkr/migd_rk,
      l_mig_rk_zp     TYPE /thkr/s_mig_rk_zp_k,
      l_migd_rk_zp    TYPE /thkr/migd_rk_zp,
      l_mig_rk_fa     TYPE /thkr/s_mig_rk_fa,
      l_migd_rk_fa    TYPE /thkr/migd_rk_fa,
      l_mig_rk_fap    TYPE /thkr/s_mig_rk_fap_k,
      l_migd_rk_fap   TYPE /thkr/migd_rkfap,
      l_mig_rk_si     TYPE /thkr/s_mig_rksoll_rkist_k,
      l_migd_rk_si    TYPE /thkr/migd_rk_si,
      l_mig_rk_sap    TYPE /thkr/mig_rk_sap,
      lt_rkn          TYPE /thkr/t_mig_rkn,
      l_rkn           LIKE LINE OF lt_rkn,
      l_kassenzeichen LIKE l_rkn-kassenzeichen,
      lt_rkv          TYPE /thkr/t_mig_rkv,
      l_rkv           LIKE LINE OF lt_rkv,
      l_migd_rkn      TYPE /thkr/migd_rkn,
      l_migd_rkv      TYPE /thkr/migd_rkv,
      lt_ahe          TYPE /thkr/t_mig_ahe,
      l_ahe           LIKE LINE OF lt_ahe,
      l_migd_ahe      TYPE /thkr/migd_ahe,
      lt_rka          TYPE /thkr/t_mig_rka,
      l_rka           LIKE LINE OF lt_rka,
      l_migd_rka      TYPE /thkr/migd_rka,
      lt_mvw          TYPE /thkr/t_mig_mvw,
      l_migd_mvw      TYPE /thkr/migd_mvw,
      l_mvw_sap       TYPE /thkr/mig_mvw_sp,
      lt_lif          TYPE /thkr/t_mig_lif,
      l_migd_lif      TYPE /thkr/migd_lif,
      lt_bore         TYPE /thkr/t_mig_bore,
      l_bore          LIKE LINE OF lt_bore,
      l_migd_bore     TYPE /thkr/migd_bore,
      l_migd_camt     TYPE /thkr/migd_camt,
      l_migd_vsa_svz  TYPE /thkr/migdvsasvz,
      lt_mig_vsa_svz  TYPE /thkr/t_mig_vsa_svz,
      lt_split_ao     TYPE STANDARD TABLE OF /thkr/migdaos,
      l_split_ao      TYPE /thkr/migdaos.


    attr-migrationsobjekt = i_migrationsobjekt.
    attr-filename         = i_filename.
    attr-epl              = i_epl.

***** Schritt 1: Datei einlesen *****
    TRY.

        IF i_frontend IS NOT INITIAL.
          "Datei vom Frontend laden
          cl_gui_frontend_services=>gui_upload(
            EXPORTING
              filename = CONV #( attr-filename )
              filetype = 'BIN'
            CHANGING
              data_tab = lt_result ).

          LOOP AT lt_result INTO DATA(l_result).
            CONCATENATE l_xmlstr l_result INTO l_xmlstr IN BYTE MODE.
          ENDLOOP.

        ELSE.
          "Datei im Server-Verzeichnis
          OPEN DATASET attr-filename IN BINARY MODE FOR INPUT.

          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE /thkr/cx_ext_if
              MESSAGE e001(/thkr/eif) WITH attr-filename.
          ENDIF.

          READ DATASET attr-filename INTO l_xmlstr.
          CLOSE DATASET attr-filename.

        ENDIF.

      CATCH cx_root INTO DATA(l_oerror).
        add_event(
          EXPORTING
            i_exception = l_oerror ).
    ENDTRY.

    IF 1 = 2.
      CALL FUNCTION 'DISPLAY_XML_STRING'
        EXPORTING
          xml_string = l_xmlstr.
    ENDIF.

    save( ).    "damit wird auch die Laufnummer vergeben

***** Schritt 2: Dateiinhalt nach /thkr/s_mig_ao_file transformieren *****
    TRY.
        CASE attr-migrationsobjekt.

          WHEN 'SEE_A'. " Allgemeine Annahmeanordnung Kasse

            CALL TRANSFORMATION /thkr/see_a_to_abap
            SOURCE XML l_xmlstr
            RESULT file = l_mig_ao.

          WHEN 'SEA_A'. " Allgemeine Auszahlungsanordnung Kasse

            CALL TRANSFORMATION /thkr/sea_a_to_abap
            SOURCE XML l_xmlstr
            RESULT file = l_mig_ao.

          WHEN 'SEE_E'. " Einzel-Annahmeanordnung Kasse

            CALL TRANSFORMATION /thkr/see_e_to_abap
            SOURCE XML l_xmlstr
            RESULT file = l_mig_ao.

          WHEN 'SSTE'." Einzel-Annahmeanordnungen

            CALL TRANSFORMATION /thkr/sste_to_abap
              SOURCE XML l_xmlstr
              RESULT file = l_mig_ao.

          WHEN 'SSTS'." Split-Annahmeanordnungen

            CALL TRANSFORMATION /thkr/ssts_to_abap
              SOURCE XML l_xmlstr
              RESULT file = l_mig_ao.

          WHEN 'AWD'.

            CALL TRANSFORMATION /thkr/awd_to_abap
              SOURCE XML l_xmlstr
              RESULT file = l_mig_ao.

          WHEN 'SSTW'.  "Dauer-AnnAO

            CALL TRANSFORMATION /thkr/sstw_to_abap
               SOURCE XML l_xmlstr
               RESULT file = l_mig_ao.

          WHEN 'ALL'.  "Allgemeine AuszAO

            CALL TRANSFORMATION /thkr/all_to_abap
              SOURCE XML l_xmlstr
              RESULT file = l_mig_ao.

          WHEN 'SSTA'.  "Allgemeine Anordnungen

            BREAK zhm000000144. "Schulz zum Testen

            CALL TRANSFORMATION /thkr/ssta_to_abap
               SOURCE XML l_xmlstr
               RESULT file = l_mig_ao.

          WHEN 'IOS'.  "Offene Einzelverwahrungen

            CALL TRANSFORMATION /thkr/ios_to_abap
               SOURCE XML l_xmlstr
               RESULT file = l_mig_ao.

          WHEN 'VSA'.  "Offene Einzelvorschüsse

            CALL TRANSFORMATION /thkr/vsa_to_abap
               SOURCE XML l_xmlstr
               RESULT file = l_mig_ao.


          WHEN 'RK'. "********** Rückstandskonten ************

            CALL TRANSFORMATION /thkr/rk_to_abap
              SOURCE XML l_xmlstr
              RESULT file = l_mig_rk.

          WHEN 'RKN'.  "RKNotizen

            CALL TRANSFORMATION /thkr/rkn_to_abap
               SOURCE XML l_xmlstr
               RESULT table = lt_rkn.

          WHEN 'RKV'.  "RKVorgänge

            CALL TRANSFORMATION /thkr/rkv_to_abap
               SOURCE XML l_xmlstr
               RESULT table = lt_rkv.

          WHEN 'AHE'.  "Amtshilfeersuchen

            CALL TRANSFORMATION /thkr/ahe_to_abap
               SOURCE XML l_xmlstr
               RESULT table = lt_ahe.

          WHEN 'RKA'.  "RKAdressenhistorie

            CALL TRANSFORMATION /thkr/rka_to_abap
               SOURCE XML l_xmlstr
               RESULT table = lt_rka.

          WHEN 'MVW'.  "(Sepa-)Lastschriftmandate

            CALL TRANSFORMATION /thkr/mvw_to_abap
               SOURCE XML l_xmlstr
               RESULT table = lt_mvw.

          WHEN 'LIF'.  "Zahlungspartner

            CALL TRANSFORMATION /thkr/lif_to_abap
               SOURCE XML l_xmlstr
               RESULT table = lt_lif.

          WHEN 'BORE'.  "BOReporthistorie

            CALL TRANSFORMATION /thkr/bore_to_abap
               SOURCE XML l_xmlstr
               RESULT table = lt_bore.

          WHEN 'VSA_SVZ'.

            CALL TRANSFORMATION /thkr/vsa_svz_to_abap
               SOURCE XML l_xmlstr
               RESULT table = lt_mig_vsa_svz.

        ENDCASE.

      CATCH cx_root INTO l_oerror.
        add_event( i_exception = l_oerror ).
        "Ausnahmen aus der Transformationen bedürfen meist einer Programmkorrektur und sind so vielfältig,
        "dass an dieser Stelle eine manuelle Analyse stattfinden muss.
        IF sy-batch IS INITIAL.
          /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
        ENDIF.
        RETURN.
    ENDTRY.

**** Schritt 3: Eingelesene Daten persistieren

    CASE attr-migrationsobjekt.

      WHEN 'RK'." Rückstandskonto

        LOOP AT l_mig_rk-tdto_rk ASSIGNING FIELD-SYMBOL(<rk>).

          CLEAR:
            l_migd_rk, l_migd_rk_zp, l_migd_rk_fa,l_migd_rk_fap, l_migd_rk_si,
            l_mig_rk_fa, l_mig_rk_fap, l_mig_rk_si, l_mig_rk_sap.

          "Satz ID bestimmen
          /thkr/cl_mig_appl=>get_instance( )->get_mig_rk_satz_id(
               EXPORTING
                 i_mig_rk = <rk>
               IMPORTING
                 e_satz_id = l_satz_id ).

          "Prüfen, ob Satz bereits vorhanden ist
          SELECT SINGLE * INTO @l_mig_rk_sap
            FROM /thkr/mig_rk_sap
            WHERE satz_id = @l_satz_id.

          " Wenn noch nicht vorhanden, dann Satz anlegen
          IF sy-subrc <> 0 OR i_update_allowed = 'X'.

            "Migrationsobjekt Rückstandskonto
            l_mig_rk_sap-satz_id    = l_satz_id.
            l_mig_rk_sap-process_id = process_id.
            l_mig_rk_sap-s_kassenzeichen  = <rk>-kassenzeichen.
            l_mig_rk_sap-s_dienststelle   = <rk>-dienststelle.
            MODIFY /thkr/mig_rk_sap FROM l_mig_rk_sap.
            ADD 1 TO lv_count.
            IF i_prot_detail = abap_true.
              MESSAGE i025(/thkr/mig) WITH l_satz_id attr-migrationsobjekt i_epl l_mig_rk_sap-s_kassenzeichen INTO l_message.
              add_event(
                i_event_category = 'I'
                i_mess           = CONV #( l_message ) ).
            ENDIF.

            "RK-Kopfdaten
            MOVE-CORRESPONDING <rk> TO l_migd_rk.
            l_migd_rk-satz_id          = l_satz_id.
            l_migd_rk-migrationsobjekt = attr-migrationsobjekt.
            MODIFY /thkr/migd_rk FROM l_migd_rk.
            "Zahlungspartner
            MOVE-CORRESPONDING <rk>-zp TO l_migd_rk_zp.
            l_migd_rk_zp-zp_rolle = |H|.
            l_migd_rk_zp-satz_id  = l_satz_id.
            MODIFY /thkr/migd_rk_zp FROM l_migd_rk_zp.
            IF <rk>-zp_v-zp_nummer IS NOT INITIAL.
              "Vertreter Zahlungspartner
              MOVE-CORRESPONDING <rk>-zp_v TO l_migd_rk_zp.
              l_migd_rk_zp-zp_rolle = |V|.
              l_migd_rk_zp-satz_id  = l_satz_id.
              MODIFY /thkr/migd_rk_zp FROM l_migd_rk_zp.
            ENDIF.

          ENDIF.
          " Faelligkeiten und davon abhängige Daten immer ergänzen

          "Fälligkeitstermine
          LOOP AT <rk>-t_rk_faell ASSIGNING FIELD-SYMBOL(<rk_faell>).
            MOVE-CORRESPONDING <rk_faell> TO l_migd_rk_fa.
            l_migd_rk_fa-satz_id = l_satz_id.
            MODIFY /thkr/migd_rk_fa FROM l_migd_rk_fa.
            "Fälligkeits-Positionen
            LOOP AT <rk_faell>-t_rk_pos ASSIGNING FIELD-SYMBOL(<rk_pos>).
              MOVE-CORRESPONDING <rk_pos> TO l_migd_rk_fap.
              l_migd_rk_fap-satz_id = l_satz_id.
              l_migd_rk_fap-faellig_dtu = <rk_faell>-faellig_dtu.
              "Einzelplan übernehmen
              IF l_mig_rk_sap-epl IS INITIAL
                OR <rk_pos>-haup_nebenforderung = 'H'.
                l_mig_rk_sap-epl = condense( <rk_pos>-einzelplan ).
              ENDIF.

              MODIFY /thkr/migd_rkfap FROM l_migd_rk_fap.
              "Positionen Soll-Ist Buchungen
              " erst alle löschen und dann mit neuen Schlüssel einbuchen
              DELETE FROM /thkr/migd_rk_si WHERE satz_id = l_migd_rk_fap-satz_id AND rksi_position = l_migd_rk_fap-pos_nr AND rksi_haujahr = l_migd_rk_fap-haushaltsjahr.
              LOOP AT <rk_pos>-t_rk_sol_ist ASSIGNING FIELD-SYMBOL(<rk_si>).
                DATA(lv_tabix) = sy-tabix.
                MOVE-CORRESPONDING <rk_si> TO l_migd_rk_si.
                l_migd_rk_si-satz_id = l_satz_id.
                l_migd_rk_si-pos_nr = <rk_pos>-pos_nr.
                l_migd_rk_si-lauf_vorgang_2 = lv_tabix. "Zusatzschlüssel, aus Vorverfahren nicht eindeutig
                MODIFY /thkr/migd_rk_si FROM l_migd_rk_si.
              ENDLOOP.
            ENDLOOP.
          ENDLOOP.

          MODIFY /thkr/mig_rk_sap FROM l_mig_rk_sap. "Für Einzelplan
          COMMIT WORK.


        ENDLOOP.
******************  Ende Rückstandskonto ************************

      WHEN 'RKN'. "RKNotizen

        SORT lt_rkn BY kassenzeichen dienststelle zeile.

        LOOP AT lt_rkn ASSIGNING FIELD-SYMBOL(<rkn>).

          IF l_kassenzeichen = <rkn>-kassenzeichen.
            CONTINUE.
          ELSEIF l_rkn-kassenzeichen <> <rkn>-kassenzeichen.
            "Gruppenwechsel: Neues Kassenzeichen
            CLEAR: l_mig_rk_sap.

            "Satz ID bestimmen
            /thkr/cl_mig_appl=>get_instance( )->get_mig_rk_satz_id(
                 EXPORTING
                   i_mig_rkn = <rkn>
                 IMPORTING
                   e_satz_id = l_satz_id ).

            "Prüfen, ob Satz bereits vorhanden ist
            SELECT SINGLE * INTO @l_mig_rk_sap
              FROM /thkr/mig_rk_sap
              WHERE satz_id = @l_satz_id.

            IF  sy-subrc = 0
              AND l_mig_rk_sap-process_id_rkn > 0.

              MESSAGE i000(/thkr/mig) WITH l_satz_id INTO l_message.
              add_event(
                i_event_category = 'I'
                i_mess           = CONV #( l_message ) ).

              l_kassenzeichen = <rkn>-kassenzeichen. "aktuelles Kassenzeichen merken

            ELSEIF sy-subrc <> 0.
              l_mig_rk_sap-satz_id    = l_satz_id.
              l_mig_rk_sap-s_kassenzeichen  = <rkn>-kassenzeichen.
              l_mig_rk_sap-s_dienststelle   = <rkn>-dienststelle.


              "Migrationsobjekt RKNotizen
              l_mig_rk_sap-process_id_rkn = process_id.
              MODIFY /thkr/mig_rk_sap FROM l_mig_rk_sap.

              IF i_prot_detail = abap_true.
                MESSAGE i025(/thkr/mig) WITH l_satz_id attr-migrationsobjekt i_epl l_mig_rk_sap-s_kassenzeichen INTO l_message.
                add_event(
                  i_event_category = 'I'
                  i_mess           = CONV #( l_message ) ).
              ENDIF.

            ENDIF.

          ENDIF.

          "RKN-Zeilen zum Kassenzeichen
          MOVE-CORRESPONDING <rkn> TO l_migd_rkn.
          l_migd_rkn-satz_id         = l_satz_id.
          MODIFY /thkr/migd_rkn FROM l_migd_rkn.

          ADD 1 TO lv_count.
          l_rkn = <rkn>.


        ENDLOOP.

******************  Ende RKNotizen ******************

      WHEN 'RKV'. "RKVorgänge

        SORT lt_rkv BY kassenzeichen dienststelle lauf_vorgangsnr falligkeitsdatum.

        LOOP AT lt_rkv ASSIGNING FIELD-SYMBOL(<rkv>).

          IF l_kassenzeichen = <rkv>-kassenzeichen.
            CONTINUE.
          ELSEIF l_rkv-kassenzeichen <> <rkv>-kassenzeichen.
            "Gruppenwechsel: Neues Kassenzeichen
            CLEAR: l_mig_rk_sap.

            "Satz ID bestimmen
            /thkr/cl_mig_appl=>get_instance( )->get_mig_rk_satz_id(
                 EXPORTING
                   i_mig_rkv = <rkv>
                 IMPORTING
                   e_satz_id = l_satz_id ).

            "Prüfen, ob Satz bereits vorhanden ist
            SELECT SINGLE * INTO @l_mig_rk_sap
              FROM /thkr/mig_rk_sap
              WHERE satz_id = @l_satz_id.

            IF  sy-subrc = 0
              AND l_mig_rk_sap-process_id_rkv > 0.

              MESSAGE i000(/thkr/mig) WITH l_satz_id INTO l_message.
              add_event(
                i_event_category = 'I'
                i_mess           = CONV #( l_message ) ).

              l_kassenzeichen = <rkv>-kassenzeichen. "aktuelles Kassenzeichen merken

            ELSEIF sy-subrc <> 0.
              l_mig_rk_sap-satz_id    = l_satz_id.
              l_mig_rk_sap-s_kassenzeichen  = <rkv>-kassenzeichen.
              l_mig_rk_sap-s_dienststelle   = <rkv>-dienststelle.

              "Migrationsobjekt RKVorgänge
              l_mig_rk_sap-process_id_rkv = process_id.
              MODIFY /thkr/mig_rk_sap FROM l_mig_rk_sap.

            ENDIF.

            IF i_prot_detail = abap_true.
              MESSAGE i025(/thkr/mig) WITH l_satz_id attr-migrationsobjekt i_epl l_mig_rk_sap-s_kassenzeichen INTO l_message.
              add_event(
                i_event_category = 'I'
                i_mess           = CONV #( l_message ) ).
            ENDIF.

          ENDIF.


          "RKV-Zeilen zum Kassenzeichen
          MOVE-CORRESPONDING <rkv> TO l_migd_rkv.
          l_migd_rkv-satz_id         = l_satz_id.
          MODIFY /thkr/migd_rkv FROM l_migd_rkv.

          ADD 1 TO lv_count.
          l_rkv = <rkv>.

        ENDLOOP.

******************  Ende RKVorgänge ******************

      WHEN 'AHE'. "Amtshilfeersuchen zum Rückstandskonten

        SORT lt_ahe BY kassenzeichen dienststelle pos_nr.

        LOOP AT lt_ahe ASSIGNING FIELD-SYMBOL(<ahe>).

          IF l_kassenzeichen = <ahe>-kassenzeichen.
            CONTINUE.
          ELSEIF l_ahe-kassenzeichen <> <ahe>-kassenzeichen.
            "Gruppenwechsel: Neues Kassenzeichen
            CLEAR: l_mig_rk_sap.

            "Satz ID bestimmen
            /thkr/cl_mig_appl=>get_instance( )->get_mig_rk_satz_id(
                 EXPORTING
                   i_mig_ahe = <ahe>
                 IMPORTING
                   e_satz_id = l_satz_id ).

            "Prüfen, ob Satz bereits vorhanden ist (Fehlermeldung und überspringen)
            SELECT SINGLE * INTO @l_mig_rk_sap
              FROM /thkr/mig_rk_sap
              WHERE satz_id = @l_satz_id.
*              AND process_id_ahe > 0.

            IF  sy-subrc = 0  AND l_mig_rk_sap-process_id_ahe > 0.

              MESSAGE i000(/thkr/mig) WITH l_satz_id INTO l_message.
              add_event(
                i_event_category = 'E'
                i_mess           = CONV #( l_message ) ).

              l_kassenzeichen = <ahe>-kassenzeichen. "aktuelles Kassenzeichen merken

              CONTINUE.

            ELSEIF sy-subrc <> 0.
              l_mig_rk_sap-satz_id    = l_satz_id.
              l_mig_rk_sap-s_kassenzeichen  = <ahe>-kassenzeichen.
              l_mig_rk_sap-s_dienststelle   = <ahe>-dienststelle.

            ENDIF.

            "Migrationsobjekt Amtshilfeersuchen
            l_mig_rk_sap-process_id_ahe = process_id.
            MODIFY /thkr/mig_rk_sap FROM l_mig_rk_sap.

          ENDIF.


          "ahe-Zeilen zum Kassenzeichen
          MOVE-CORRESPONDING <ahe> TO l_migd_ahe.
          l_migd_ahe-satz_id         = l_satz_id.
          MODIFY /thkr/migd_ahe FROM l_migd_ahe.

          l_ahe = <ahe>.

          ADD 1 TO lv_count.
          IF i_prot_detail = abap_true.
            MESSAGE i025(/thkr/mig) WITH l_satz_id attr-migrationsobjekt i_epl l_mig_rk_sap-s_kassenzeichen INTO l_message.
            add_event(
              i_event_category = 'I'
              i_mess           = CONV #( l_message ) ).
          ENDIF.
        ENDLOOP.

******************  Ende AHE ******************

      WHEN 'RKA'. "RKAdressenhistorie

        SORT lt_rka BY kassenzeichen dienststelle lauf_adressenr.

        LOOP AT lt_rka ASSIGNING FIELD-SYMBOL(<rka>).

          IF l_kassenzeichen = <rka>-kassenzeichen.
            CONTINUE.
          ELSEIF l_rka-kassenzeichen <> <rka>-kassenzeichen.
            "Gruppenwechsel: Neues Kassenzeichen
            CLEAR: l_mig_rk_sap.

            "Satz ID bestimmen
            /thkr/cl_mig_appl=>get_instance( )->get_mig_rk_satz_id(
                 EXPORTING
                   i_mig_rka = <rka>
                 IMPORTING
                   e_satz_id = l_satz_id ).

            "Prüfen, ob Satz bereits vorhanden ist (Fehlermeldung und überspringen)
            SELECT SINGLE * INTO @l_mig_rk_sap
              FROM /thkr/mig_rk_sap
              WHERE satz_id = @l_satz_id.
*              AND process_id_rka > 0.

            IF  sy-subrc = 0 AND l_mig_rk_sap-process_id_rka > 0.

              MESSAGE i000(/thkr/mig) WITH l_satz_id INTO l_message.
              add_event(
                i_event_category = 'E'
                i_mess           = CONV #( l_message ) ).

              l_kassenzeichen = <rka>-kassenzeichen. "aktuelles Kassenzeichen merken

              CONTINUE.

            ELSEIF sy-subrc <> 0.
              l_mig_rk_sap-satz_id    = l_satz_id.
              l_mig_rk_sap-s_kassenzeichen  = <rka>-kassenzeichen.
              l_mig_rk_sap-s_dienststelle   = <rka>-dienststelle.

            ENDIF.

            "Migrationsobjekt Amtshilfeersuchen
            l_mig_rk_sap-process_id_rka = process_id.
            MODIFY /thkr/mig_rk_sap FROM l_mig_rk_sap.

          ENDIF.


          "rka-Zeilen zum Kassenzeichen
          MOVE-CORRESPONDING <rka> TO l_migd_rka.
          l_migd_rka-satz_id         = l_satz_id.
          MODIFY /thkr/migd_rka FROM l_migd_rka.

          l_rka = <rka>.

          ADD 1 TO lv_count.
          IF i_prot_detail = abap_true.
            MESSAGE i025(/thkr/mig) WITH l_satz_id attr-migrationsobjekt i_epl l_mig_rk_sap-s_kassenzeichen INTO l_message.
            add_event(
              i_event_category = 'I'
              i_mess           = CONV #( l_message ) ).
          ENDIF.

        ENDLOOP.

******************  Ende RKA ******************

      WHEN 'MVW'.  "(Sepa-)Lastschriftmandate

        LOOP AT lt_mvw INTO DATA(l_mvw).

          MOVE-CORRESPONDING l_mvw TO l_migd_mvw.

          l_migd_mvw-epl            = attr-epl.
          l_migd_mvw-process_id_mvw = process_id.
          MODIFY /thkr/migd_mvw FROM l_migd_mvw.

          MOVE-CORRESPONDING l_mvw TO l_mvw_sap.

          l_mvw_sap-epl = attr-epl.
          MODIFY /thkr/mig_mvw_sp FROM l_mvw_sap.

          ADD 1 TO lv_count.
          IF i_prot_detail = abap_true.
            MESSAGE i026(/thkr/mig) WITH process_id attr-migrationsobjekt i_epl  INTO l_message.
            add_event(
              i_event_category = 'I'
              i_mess           = CONV #( l_message ) ).
          ENDIF.

        ENDLOOP.

******************  Ende MVW ******************

      WHEN 'LIF'.   "Zahlungspartner

        LOOP AT lt_lif INTO DATA(l_lif).

          CLEAR l_migd_lif.

          MOVE-CORRESPONDING l_lif TO l_migd_lif.
          l_migd_lif-epl = attr-epl.
          l_migd_lif-process_id_lif = process_id.

          MODIFY /thkr/migd_lif FROM l_migd_lif.

          ADD 1 TO lv_count.

          IF i_prot_detail = abap_true.
            MESSAGE i026(/thkr/mig) WITH process_id attr-migrationsobjekt i_epl  INTO l_message.
            add_event(
              i_event_category = 'I'
              i_mess           = CONV #( l_message ) ).
          ENDIF.
        ENDLOOP.

      WHEN 'VSA_SVZ'.
        SORT lt_mig_vsa_svz BY haushaltsjahr dienststelle kassenzeichen positionsnummer zeitbuchnummer lfd_zeilennummer.

        LOOP AT lt_mig_vsa_svz ASSIGNING FIELD-SYMBOL(<vsa_svz>).

          "Satz ID bestimmen (AO!)
          /thkr/cl_mig_appl=>get_instance( )->get_mig_ao_satz_id(
               EXPORTING
                 i_mig_vsa_svz = <vsa_svz>
               IMPORTING
                 e_satz_id = l_satz_id ) .

          MOVE-CORRESPONDING <vsa_svz> TO l_migd_vsa_svz.
          l_migd_vsa_svz-satz_id = l_satz_id.

          MODIFY /thkr/migdvsasvz FROM l_migd_vsa_svz.


          ADD 1 TO lv_count.

          IF i_prot_detail = abap_true.
            MESSAGE i026(/thkr/mig) WITH process_id attr-migrationsobjekt i_epl  INTO l_message.
            add_event(
              i_event_category = 'I'
              i_mess           = CONV #( l_message ) ).
          ENDIF.

        ENDLOOP.

******************  Ende LIF ******************

      WHEN 'BORE'. "BOReporthistorie

        SORT lt_bore BY kassenzeichen lfd_nummer.

        LOOP AT lt_bore ASSIGNING FIELD-SYMBOL(<bore>).

          IF l_kassenzeichen = <bore>-kassenzeichen.
            CONTINUE.
          ELSEIF l_bore-kassenzeichen <> <bore>-kassenzeichen.
            "Gruppenwechsel: Neues Kassenzeichen
            CLEAR: l_mig_rk_sap.

            "Satz ID bestimmen
            /thkr/cl_mig_appl=>get_instance( )->get_mig_rk_satz_id(
                 EXPORTING
                   i_mig_bore = <bore>
                 IMPORTING
                   e_satz_id = l_satz_id ).

            "Prüfen, ob Satz bereits vorhanden ist (Fehlermeldung und überspringen)
            SELECT SINGLE * INTO @l_mig_rk_sap
              FROM /thkr/mig_rk_sap
              WHERE satz_id = @l_satz_id.

            IF  sy-subrc = 0 AND l_mig_rk_sap-process_id_bore > 0.

              MESSAGE i000(/thkr/mig) WITH l_satz_id INTO l_message.
              add_event(
                i_event_category = 'E'
                i_mess           = CONV #( l_message ) ).

              l_kassenzeichen = <bore>-kassenzeichen. "aktuelles Kassenzeichen merken

              CONTINUE.

            ELSEIF sy-subrc <> 0.
              l_mig_rk_sap-satz_id    = l_satz_id.
              l_mig_rk_sap-s_kassenzeichen  = <bore>-kassenzeichen.

            ENDIF.

            "Migrationsobjekt BOreporthistorie
            l_mig_rk_sap-process_id_bore = process_id.
            MODIFY /thkr/mig_rk_sap FROM l_mig_rk_sap.

          ENDIF.

          "bore-Zeilen zum Kassenzeichen
          MOVE-CORRESPONDING <bore> TO l_migd_bore.
          l_migd_bore-satz_id         = l_satz_id.
          MODIFY /thkr/migd_bore FROM l_migd_bore.

          l_bore = <bore>.

          ADD 1 TO lv_count.
          IF i_prot_detail = abap_true.
            MESSAGE i025(/thkr/mig) WITH l_satz_id attr-migrationsobjekt i_epl l_mig_rk_sap-s_kassenzeichen INTO l_message.
            add_event(
              i_event_category = 'I'
              i_mess           = CONV #( l_message ) ).
          ENDIF.
        ENDLOOP.

*  ******************  Ende BORE ******************


      WHEN OTHERS.

        LOOP AT l_mig_ao-tdto_ao ASSIGNING FIELD-SYMBOL(<ao>).

          CLEAR: l_mig_ao_sap, l_migdao, l_migdzp, lt_migdaor.

          "Satz ID bestimmen
          /thkr/cl_mig_appl=>get_instance( )->get_mig_ao_satz_id(
               EXPORTING
                 i_mig_ao = <ao>
               IMPORTING
                 e_satz_id = l_satz_id ) .

          "Prüfen, ob Satz bereits vorhanden ist (Fehlermeldung und überspringen)
          SELECT SINGLE * INTO @l_mig_ao_sap
            FROM /thkr/mig_ao_sap
            WHERE satz_id = @l_satz_id.

          IF  sy-subrc = 0.
*           Ausnahme für IOS und VSA Importe, diese dürfen aufgrund bisher fehlender Daten akualisiert werden,
*           der aktuelle Migrationsstand (Status, etc.) darf wird bis auf die Prozess-ID nicht verändert werden.
            IF i_update_allowed IS INITIAL.
              MESSAGE i000(/thkr/mig) WITH l_satz_id INTO l_message.
              add_event(
                i_event_category = 'E'
                i_mess           = CONV #( l_message ) ).
              ADD 1 TO lv_continue.
              CONTINUE.
            ELSE.
              ADD 1 TO lv_update.
            ENDIF.

          ELSEIF <ao>-migrationsobjekt = 'SEE_E'.
            " SEE-E Resterampe Kasse, hier prüfen ob in irgendeiner anderen DATEI das KAZ schon enthalten war, ansonsten anlegen
            SELECT SINGLE * INTO @l_mig_ao_sap FROM /thkr/mig_ao_sap WHERE xblnr = @<ao>-kassenzeichen AND ( haup_nebenforderung = 'H' OR haup_nebenforderung = '' ).
            IF  sy-subrc = 0.
              "DF_1727 wenn KASSZ bei VSA dann importieren, da das der Folgebeleg dazu ist, alle anderen weiterhin ignorieren
              SELECT SINGLE migrationsobjekt FROM /thkr/migdao INTO @DATA(lv_migobj) WHERE kassenzeichen = @<ao>-kassenzeichen.
              IF sy-subrc = 0 AND lv_migobj = 'VSA'.
                l_satz_id = 'SEE_E_' && l_satz_id. " für Eindeutigkeit
                "jetzt noch prüfen ob Datei nicht schon mal so eingepsielt wurde, daher auf neue SATZ ID prüfen
                SELECT SINGLE * INTO @l_mig_ao_sap FROM /thkr/mig_ao_sap WHERE satz_id = @l_satz_id.
                IF sy-subrc = 0.
                  MESSAGE i000(/thkr/mig) WITH l_satz_id INTO l_message.
                  add_event(
                    i_event_category = 'E'
                    i_mess           = CONV #( l_message ) ).
                  ADD 1 TO lv_continue.
                  CONTINUE.
                ENDIF.

                l_mig_ao_sap-see_e_vsa = abap_true.
                ADD 1 TO lv_update.
              ELSEIF sy-subrc = 0 AND lv_migobj = 'SEE_E'.
                " Eintrag vorhanden, dann Modify ausführen
                ADD 1 TO lv_update.
              ELSEIF sy-subrc = 0 AND lv_migobj <> 'VSA' .
                " z.B. Amtshilfe Fälle die irgendwoher übernommen wurden
                MESSAGE i045(/thkr/mig) WITH l_mig_ao_sap-satz_id lv_migobj INTO l_message. "Kassenzeichen &1 bereits vorhanden lv_migobj Daher ignoriert.
                add_event(
                  i_event_category = 'E'
                  i_mess           = CONV #( l_message ) ).
                ADD 1 TO lv_continue.
                CONTINUE.
              ELSE.
                " z.B. Amtshilfe Fälle die aus dem RK übernommen werden
                MESSAGE i042(/thkr/mig) WITH l_mig_ao_sap-satz_id INTO l_message. "Kassenzeichen &1 bereits vorhanden <> VSA Daher ignoriert.
                add_event(
                  i_event_category = 'E'
                  i_mess           = CONV #( l_message ) ).
                ADD 1 TO lv_continue.
                CONTINUE.
              ENDIF.
            ELSE.
              " Eintrag noch nicht vorhanden, dann hinzufügen
              ADD 1 TO lv_update.
            ENDIF.
          ENDIF.

*     SSTE Flag für Überzahlte Forderung Soll-Ist < 0  - sollte <ao>-Betragoffen entsprechen
          l_mig_ao_sap-sste_ueberz_forderung = xsdbool( ( attr-migrationsobjekt = 'SSTE' OR attr-migrationsobjekt = 'SEE_E' ) AND ( <ao>-sollbetrag - <ao>-istbetrag < 0  ) ).
          " gilt auch für SSTS
          IF attr-migrationsobjekt = 'SSTS'.
            DATA(lv_splittbetragoffen) =  CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN <ao>-t_split NEXT x += wa-splittbetragoffen ) + <ao>-betragoffen  ).
            l_mig_ao_sap-sste_ueberz_forderung = xsdbool( lv_splittbetragoffen < 0 ).
          ENDIF.
* Alle Beträge = 0
          l_mig_ao_sap-betrag_0 = xsdbool( ( attr-migrationsobjekt = 'SSTE' OR attr-migrationsobjekt = 'SEE_E' ) AND ( <ao>-betragoffen = '0.00' ) ).
          lv_splittbetragoffen = CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN <ao>-t_split NEXT x += wa-splittbetragoffen ) + <ao>-betragoffen  ).
          l_mig_ao_sap-betrag_0 = xsdbool( lv_splittbetragoffen = 0 ).

*     Migrationsobjekt Anordnung
          l_mig_ao_sap-satz_id    = l_satz_id.
          l_mig_ao_sap-process_id = process_id.
          l_mig_ao_sap-xblnr      = <ao>-kassenzeichen.
          l_mig_ao_sap-epl        = <ao>-einzelplan.
          l_mig_ao_sap-zp_nr      = <ao>-zp_nummer.
          l_mig_ao_sap-zp_lfd_nr  = <ao>-zp_lfd_nummer.
          l_mig_ao_sap-haup_nebenforderung = 'H'.
          MODIFY /thkr/mig_ao_sap FROM l_mig_ao_sap.

*     Anordnungskopf
          MOVE-CORRESPONDING <ao> TO l_migdao.
          l_migdao-satz_id          = l_satz_id.
          l_migdao-migrationsobjekt = attr-migrationsobjekt.
          MODIFY /thkr/migdao FROM l_migdao.

          MOVE-CORRESPONDING <ao> TO l_migdzp.
          l_migdzp-satz_id = l_satz_id.
          MODIFY /thkr/migdzp FROM l_migdzp.

*     Split-Annahmeanordnungen
          MOVE-CORRESPONDING <ao>-t_split TO lt_split_ao.
          LOOP AT lt_split_ao INTO l_split_ao.
            IF l_split_ao-splittkassenzeichen IS INITIAL.
              CONTINUE.
            ENDIF.
            l_split_ao-satz_id = l_satz_id.
            l_split_ao-lfd_zeilennummer = sy-tabix.
            MODIFY /thkr/migdaos FROM l_split_ao.
          ENDLOOP.


*     Raten
          MOVE-CORRESPONDING <ao>-t_rate TO lt_migdaor.

          LOOP AT lt_migdaor INTO l_migdaor.
            l_migdaor-satz_id = l_satz_id.
            MODIFY /thkr/migdaor FROM l_migdaor.
          ENDLOOP.

*     CAMT-Daten für IOS oder VSA
          IF attr-migrationsobjekt = 'IOS' OR attr-migrationsobjekt = 'VSA'.
            IF <ao>-s_camt IS NOT INITIAL.
              MOVE-CORRESPONDING <ao>-s_camt TO l_migd_camt.
              l_migd_camt-satz_id = l_satz_id.
              MODIFY /thkr/migd_camt FROM l_migd_camt.
            ENDIF.
          ENDIF.


          COMMIT WORK.

          ADD 1 TO lv_count.
          IF i_prot_detail = abap_true.
            MESSAGE i025(/thkr/mig) WITH l_satz_id attr-migrationsobjekt i_epl l_mig_ao_sap-xblnr INTO l_message.
            add_event(
              i_event_category = 'I'
              i_mess           = CONV #( l_message ) ).
          ENDIF.
        ENDLOOP.


    ENDCASE.



* Wenn kein Fehler dann Server Datei in Archiv kopieren und original löschen.
    LOOP AT t_event TRANSPORTING NO FIELDS WHERE event_category CA 'EA'.
      EXIT.
    ENDLOOP.
    IF sy-subrc <> 0 AND i_frontend IS INITIAL AND i_move_archiv = abap_true.
      " Datei ins Archiv kopieren
      DATA(lv_len) = strlen( i_filename ) - 1 - strlen( i_directory ) . "Länge Dateiname
      DATA(lv_offset) = strlen( i_directory ).
      DATA(lv_archiv) = i_archiv_directory && i_filename+lv_offset(lv_len).
      OPEN DATASET lv_archiv FOR OUTPUT IN BINARY MODE MESSAGE l_message.
      IF sy-subrc <> 0.
        add_event(
          i_event_category = 'E'
          i_mess           = CONV #( l_message ) ).
      ELSE.
        TRANSFER l_xmlstr TO lv_archiv.
        CLOSE DATASET lv_archiv.

        " Original löschen
        DELETE DATASET attr-filename.
        IF sy-subrc <> 0.
          add_event(
            i_event_category = 'E'
            i_mess           = CONV #( l_message ) ).

        ELSE.
          MESSAGE i024(/thkr/mig) WITH attr-filename INTO l_message.
          add_event(
            i_event_category = 'I'
            i_mess           = CONV #( l_message ) ).
        ENDIF. " Datei gelöscht
      ENDIF. " Datei geöffnet

    ENDIF. " Datei ins Archiv kopieren


    IF lv_update > 0.
      MESSAGE i037(/thkr/mig) WITH lv_count lv_update INTO l_message.
      add_event(
        i_event_category = 'I'
        i_mess           = CONV #( l_message ) ).
    ELSE.
      MESSAGE i028(/thkr/mig) WITH lv_count INTO l_message.
      add_event(
        i_event_category = 'I'
        i_mess           = CONV #( l_message ) ).
    ENDIF.

    MESSAGE i043(/thkr/mig) WITH lv_continue INTO l_message.
    add_event(
      i_event_category = 'I'
      i_mess           = CONV #( l_message ) ).


    save( ).

  ENDMETHOD.


  METHOD save.
    super->save( ).

    DATA: l_mig_imp TYPE /thkr/mig_imp.

    MOVE-CORRESPONDING attr TO l_mig_imp.
    l_mig_imp-process_type = process_type.
    l_mig_imp-process_id   = process_id.

    MODIFY /thkr/mig_imp FROM l_mig_imp.

  ENDMETHOD.
ENDCLASS.
