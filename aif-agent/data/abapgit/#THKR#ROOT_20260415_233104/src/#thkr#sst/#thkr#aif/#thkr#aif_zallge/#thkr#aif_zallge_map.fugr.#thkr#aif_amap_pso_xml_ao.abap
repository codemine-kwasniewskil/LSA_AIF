FUNCTION /thkr/aif_amap_pso_xml_ao .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"     REFERENCE(RAW_LINE) TYPE  PSO02
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_AO
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_PSM_AO_BEL_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <ls_items> TYPE /thkr/s_de_pso_xml.

  DATA(lo_chk_mand_blart) = NEW /thkr/cl_aif_chk( ).

  "Prüfung, ob alle notwendigen Belege in der Datenlieferung enthalten sind.
  lo_chk_mand_blart->check_mandatory_blart(
            EXPORTING
              is_raw_line  = raw_line                " AIF SAP Struktur für Anordnungen
              is_raw_struc  = raw_struct                " XML Struktur für Aufruf interne Schnittstelle
            CHANGING
              cs_dest_line       = dest_line                 " Output Struktur
          ).

  "ZUONR und Kassenzeichen XBLNR identisch sind
  "Dann handelt es sich um die erste Anordnung. Dann muss nicht geprüft werden, ob das Urkassenzeichen existiert.
  "Das weicht von den bisherigen BIC-Dateien ab, weil es kein gelieferten Belegkopftext gab. Mit PSO-XML schon.
  IF raw_line-zuonr <> raw_line-xblnr.
    "Prüfung, ob Referenzierter Beleg der Anordung existiert.
    IF /thkr/cl_pso_xml_processing=>get_instance( )->check_ao_ref_exists( iv_urkass = CONV xblnr( dest_line-bktxt ) ) = abap_false.
      IF 1 = 0. MESSAGE e033(/thkr/sst) WITH dest_line-bktxt.ENDIF.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                             number = 033
                             type = 'E'
                             message_v1 = dest_line-bktxt ) TO dest_line-msg.
    ENDIF.
  ENDIF.
  "Lese er Anordnung (Jede Anordnung ist auf Ebene ITEM zu finden)
  READ TABLE raw_struct-values-items WITH KEY key-lotkz = raw_line-lotkz
                                              key-belnr = raw_line-belnr ASSIGNING <ls_items>.
  IF sy-subrc = 0.
    "Auslesen der Finanzdaten aus Anordnung
    "Wird nur gebraucht, um zu prüfen, ob bei Absetzungen der Beleg bereits ausgeglichen wird.
    "in diesem Fall wird die Absetzung nicht gebucht, aber die neue Anordnung mit gleichen Kassenzeichen.
    /thkr/cl_pso_xml_processing=>get_instance( )->get_ao_data(
      EXPORTING
        iv_kassz      = CONV xblnr( raw_line-zuonr )                 " Referenz-Belegnummer
        is_out_struct = out_struct                 " XML Struktur für Aufruf interne Schnittstelle
        i_ns          = smap-ns
        i_ifname      = smap-ifname
        i_ifversion   = smap-ifversion
      CHANGING
        ct_msgs       = dest_line-msg
    ).
    IF dest_line-msg IS NOT INITIAL.
      "referenierte Anordnung zum Kassenzeichen konnte nicht gefunden werden. Wird auch nicht benötigt.
      "Nachricht löschen. Abfrage wird nur für die Prüfung, ob es bereits ausgeglichene Belege gibt benötigt.
      CLEAR: dest_line-msg.
    ENDIF.
    IF /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-augdt IS NOT INITIAL.
      "referenzierte Anordnung enthält Ausgleichsbelege.
      "Keine Änderung durch Schnittstelle.
      "Erzeuge Fehlermeldung und breche die Verarbeitung ab
      IF 1 = 0. MESSAGE e040(/thkr/sst) WITH /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-belnr /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-augdt /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-augbl.ENDIF.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                             number = 040
                             type = 'E'
                             message_v1 = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-belnr
                             message_v2 = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-augdt
                             message_v3 = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-augbl ) TO dest_line-msg.
      RETURN.
    ENDIF.

    "Lesen der Sachkontenzeile pso02s für jede Belegposition (pso02)
    LOOP AT <ls_items>-lt_pso02s  ASSIGNING FIELD-SYMBOL(<ls_pso02s>) WHERE lotkz = <ls_items>-key-lotkz
                                                                        AND itabkey = raw_line-itabkey.
      IF sy-subrc = 0.
***************************************************************************
*                   EP - Einzelplan                                       *
***************************************************************************
        dest_line-ep = <ls_pso02s>-fipex(2).
***************************************************************************
*                   DST_OLD - Dienststelle                                *
***************************************************************************
        dest_line-dst_old = <ls_pso02s>-fistl(4).
***************************************************************************
*                   BUKRS - Buchungskreis                                 *
***************************************************************************

        /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
          iv_ep  = dest_line-ep                 " Einzelplan
          iv_oeh = CONV /thkr/mig_oeh_old( <ls_pso02s>-fistl )                " OEH  alt
          iv_kapitel = CONV /thkr/mig_kapitel( <ls_pso02s>-fipex+2(4) )
          iv_titel = CONV /thkr/mig_titel( <ls_pso02s>-fipex+6(5) )
          ).

        dest_line-bukrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-bukrs.

        "Aufbau Sachkonto-Zeile in AO-Struktur.
        APPEND INITIAL LINE TO dest_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_t_cont>).
***************************************************************************
*                   SGTXT - Positionstext                                 *
***************************************************************************
        <ls_t_cont>-sgtxt = |*{ <ls_items>-lt_pso02[ itabkey = <ls_pso02s>-itabkey ]-sgtxt }|.
***************************************************************************
*                   FIKRS - Finanzkreis                                   *
***************************************************************************
        <ls_t_cont>-fikrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fikrs.
***************************************************************************
*                   FIPEX - Finanzposition                                *
***************************************************************************
        "<ls_t_cont>-fipex = <ls_pso02s>-fipex+2(9).
        /thkr/cl_pso_xml_processing=>get_instance( )->get_fipex(
  EXPORTING
    iv_kapitel = CONV string( <ls_pso02s>-fipex+2(4) )                " Kapitel
    iv_titel   = CONV string( <ls_pso02s>-fipex+6(5) )                " Titel
    iv_ep      = CONV string( <ls_pso02s>-fipex(2) )                  " Einzelplan
    iv_uk      = CONV string( <ls_pso02s>-fipex+11 )                  " Unterkonto
  CHANGING
    cv_fipex   = <ls_t_cont>-fipex
).
***************************************************************************
*                   FISTL - Finanzstelle                                  *
***************************************************************************
        <ls_t_cont>-fistl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fistl.
***************************************************************************
*                   HKONT - Sachkonto                                     *
***************************************************************************
        <ls_t_cont>-hkont = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-saknr.
        IF <ls_t_cont>-hkont IS INITIAL.
          "Ableitung Sachkonto für HHM-Kontierung
          <ls_t_cont>-hkont = /thkr/cl_pso_xml_processing=>get_instance( )->get_hkont(
                                                                           iv_gjahr = dest_line-gjahr                 " Geschäftsjahr
                                                                           iv_bukrs = dest_line-bukrs                 " Buchungskreis
                                                                           iv_fipex = <ls_t_cont>-fipex                 " Finanzposition
                                                                           iv_fistl = <ls_t_cont>-fistl                 " Finanzstelle
                                                                           iv_psoty = dest_line-psoty                 " Belegtyp Zahlungsanordnungen
                                                                           iv_blart = dest_line-blart                 " Belegart
                                                                         ).
        ENDIF.
***************************************************************************
*                   MSKZ - Mehrwehrtsteuerkennzeichen                     *
***************************************************************************
        <ls_t_cont>-mwskz = /thkr/cl_pso_xml_processing=>get_instance( )->get_mwskz(
                                                                         iv_blart = dest_line-blart                  " Belegart
                                                                         iv_bukrs = dest_line-bukrs                 " Buchungskreis
                                                                         iv_saknr = <ls_t_cont>-hkont                 " Nummer des Sachkontos
                                                                         iv_btyp = ''
                                                                         iv_bkz = ''
                                                                       ).

***************************************************************************
*                   GSBER - Geschäftsbereich                              *
***************************************************************************
        <ls_t_cont>-gsber = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-gsber.
*        "Wird wegen Sammelauftrag und Sammelkostenstelle auf 9998 festgelegt
*        <ls_t_cont>-gsber = '9998'.
***************************************************************************
*                   AUFNR - Innenauftrag                                  *
***************************************************************************
*        IF <ls_pso02s>-aufnr IS NOT INITIAL.
*          HRK nutzt für die Polizei einen Innenauftragsammler.
*          Entweder Kostenstelle oder Innenauftrag.
*          für Polizei existiert ein Sammelinnenauftrag.
*          <ls_t_cont>-aufnr = '310100000000'.
*          <ls_t_cont>-aufnr = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-aufnr.
*        ENDIF.
***************************************************************************
*                   KOSTL - Kostenstelle                                  *
***************************************************************************
*        IF <ls_pso02s>-kostl IS NOT INITIAL.
*          "HRK nutzt für die Polizei einen Kostenstellensammler.
*          "Entweder Kostenstelle oder Innenauftrag.
*          "für Polizei existiert eine Sammelkostenstelle
*          <ls_t_cont>-kostl = 'D_SST-POL'.
**          <ls_t_cont>-kostl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-kostl.
*        ENDIF.
        <ls_t_cont>-kostl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-kostl.
***************************************************************************
*                   WRBTR - Betrag in Belegwährung                        *
***************************************************************************
        <ls_t_cont>-wrbtr = <ls_pso02s>-wrbtr.

      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
