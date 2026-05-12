FUNCTION /thkr/aif_amap_pso_xml_ao_ref .
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
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_PSO_XML_SAP
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

  "Lese er Anordnung (Jede Anordnung ist auf Ebene ITEM zu finden)
  READ TABLE raw_struct-values-items WITH KEY key-lotkz = raw_line-lotkz
                                              key-belnr = raw_line-belnr ASSIGNING <ls_items>.
  IF sy-subrc = 0.
    "Lesen der Sachkontenzeile pso02s für jede Belegposition (pso02)
    LOOP AT <ls_items>-lt_pso02s  ASSIGNING FIELD-SYMBOL(<ls_pso02s>) WHERE lotkz = <ls_items>-key-lotkz
                                                                        AND itabkey = raw_line-itabkey.
      IF sy-subrc = 0.
        "Auslesen der Finanzdaten aus Anordnung
        /thkr/cl_pso_xml_processing=>get_instance( )->get_ao_data(
          EXPORTING
*            iv_kassz      = CONV xblnr( dest_line-bktxt )                 " Referenz-Belegnummer
* Gereon Koks  TSI  10.3.2026
*            iv_kassz      = CONV xblnr( dest_line-xblnr )                 " Referenz-Belegnummer
            iv_kassz      = CONV xblnr( dest_line-zuonr )                 " Referenz-Belegnummer
            is_out_struct = out_struct                 " XML Struktur für Aufruf interne Schnittstelle
* Gereon Koks  TSI  23.2.2026
            i_ns          = smap-ns
            i_ifname      = smap-ifname
            i_ifversion   = smap-ifversion
          CHANGING
            ct_msgs       = dest_line-msg
        ).

        IF dest_line-msg IS NOT INITIAL.
          "Es konnte keine Anordnung gefunden werden. Mapping der Finanzdaten nicht möglich
          "Bearbeitung beenden.
          RETURN.
        ENDIF.
        IF /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-augdt IS NOT INITIAL.
          "Anordnung enthält Ausgleichsbelege.
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
***************************************************************************
*                   BUKRS - Buchungskreis                                 *
***************************************************************************
        dest_line-bukrs = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-bukrs.

        "Aufbau Sachkonto-Zeile in AO-Struktur.
        APPEND INITIAL LINE TO dest_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_t_cont>).
***************************************************************************
*                   Partner - Partner                                     *
***************************************************************************
        dest_line-partner = COND bu_partner( WHEN /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-kunnr IS NOT INITIAL THEN /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-kunnr
                                             WHEN /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-lifnr IS NOT INITIAL THEN /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-lifnr ).
***************************************************************************
*                   SGTXT - Positionstext                                 *
***************************************************************************
        <ls_t_cont>-sgtxt = |*{ <ls_items>-lt_pso02[ lotkz = <ls_items>-key-lotkz itabkey = raw_line-itabkey ]-sgtxt }|.
***************************************************************************
*                   FIKRS - Finanzkreis                                   *
***************************************************************************
        <ls_t_cont>-fikrs = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-fikrs.
***************************************************************************
*                   FIPEX - Finanzposition                                *
***************************************************************************
        <ls_t_cont>-fipex = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-fipex.
***************************************************************************
*                   FISTL - Finanzstelle                                  *
***************************************************************************
        <ls_t_cont>-fistl = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-fistl.
***************************************************************************
*                   HKONT - Sachkonto                                     *
***************************************************************************
        <ls_t_cont>-hkont = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-saknr.
***************************************************************************
*                   MSKZ - Mehrwehrtsteuerkennzeichen                     *
***************************************************************************
        <ls_t_cont>-mwskz = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-zz_mwskz.
***************************************************************************
*                   WRBTR - Betrag in Belegwährung                        *
***************************************************************************
        CASE dest_line-psoty.
          WHEN: '06'.
            "Für Stundung nimm Betrag aus Anordnung
            <ls_t_cont>-wrbtr = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-wrbtr.
          WHEN: OTHERS.
            <ls_t_cont>-wrbtr = <ls_pso02s>-wrbtr.
        ENDCASE.
***************************************************************************
*                   KOSTL - Kostenstelle                                  *
***************************************************************************
        <ls_t_cont>-kostl = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-kostl.
***************************************************************************
*                   GSBER - Geschäftsbereich                              *
***************************************************************************
        <ls_t_cont>-gsber = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-gsber.

***************************************************************************
*                   REBZG - Belegnummer                                   *
***************************************************************************
        dest_line-rebzg = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-belnr.
***************************************************************************
*                   REBZJ - Geschäftsjahr der zugehörigen Rechnung (bei Gutschrift)                                   *
***************************************************************************
* Gereon Koks  TSI 24.2.2026
*        dest_line-rebzj = dest_line-gjahr.
        dest_line-rebzj = /thkr/cl_pso_xml_processing=>get_instance( )->ms_ao_ref-gjahr.
***************************************************************************
*                   REBZZ - Buchungsposition in der zugehörigen Rechnung  *
***************************************************************************
        dest_line-rebzz = 1.
***************************************************************************
*                   REBZT - Art des Folgebelegs                           *
***************************************************************************
        dest_line-rebzt = 'F'.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
