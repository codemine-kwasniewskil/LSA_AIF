FUNCTION /thkr/aif_amap_pso_xml_mb .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"     REFERENCE(RAW_LINE) TYPE  KBLK
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_MV
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_PSM_MV_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------


  FIELD-SYMBOLS: <ls_items> TYPE /thkr/s_de_pso_xml.

  READ TABLE raw_struct-values-items WITH KEY key-belnr = raw_line-belnr ASSIGNING <ls_items>.
  IF sy-subrc = 0.
    LOOP AT <ls_items>-lt_kblp ASSIGNING FIELD-SYMBOL(<ls_kblp>) WHERE belnr = <ls_items>-key-belnr.
      IF sy-subrc = 0.
***************************************************************************
*                   EP - Einzelplan                                       *
***************************************************************************
        dest_line-ep = <ls_kblp>-fipex(2).
***************************************************************************
*                   DST_OLD - Dienststelle                                *
***************************************************************************
        dest_line-dst_old = <ls_kblp>-fistl(4).
***************************************************************************
*                   BUKRS - Buchungskreis                                 *
***************************************************************************

        /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
          iv_ep  = dest_line-ep                 " Einzelplan
          iv_oeh = CONV /thkr/mig_oeh_old( <ls_kblp>-fistl )                " OEH  alt
          iv_kapitel = CONV /thkr/mig_kapitel( <ls_kblp>-fipex+2(4) )
          iv_titel = CONV /thkr/mig_titel( <ls_kblp>-fipex+6(5) )
        ).


        dest_line-bukrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-bukrs.
***************************************************************************
*                   WAERS - Währungsschlüssel                             *
***************************************************************************
        dest_line-waers = /thkr/cl_pso_xml_processing=>get_instance( )->get_waers(
                                                                       iv_waers = raw_line-waers                 " Währungsschlüssel
                                                                       iv_bukrs = dest_line-bukrs                 " Buchungskreis
                                                                     ) .
***************************************************************************
*                   KTXT - Belegkopftext                                  *
***************************************************************************
        dest_line-ktxt = <ls_kblp>-belnr.
***************************************************************************
*                   FIKRS - Finanzkreis                                   *
***************************************************************************

        APPEND INITIAL LINE TO dest_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_t_kont>).
        <ls_t_kont>-fikrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fikrs.
***************************************************************************
*                   FIPEX - Finanzposition                                *
***************************************************************************
        "<ls_t_kont>-fipex = <ls_kblp>-fipos+2(9).
        /thkr/cl_pso_xml_processing=>get_instance( )->get_fipex(
          EXPORTING
            iv_kapitel = CONV string( <ls_kblp>-fipex+2(4) )                " Kapitel
            iv_titel   = CONV string( <ls_kblp>-fipex+6(5) )                " Titel
            iv_ep      = CONV string( <ls_kblp>-fipex(2) )                  " Einzelplan
            iv_uk      = CONV string( <ls_kblp>-fipex+11 )                  " Unterkonto
          CHANGING
            cv_fipex   = <ls_t_kont>-fipex
        ).
        <ls_t_kont>-fipos = /thkr/cl_pso_xml_processing=>get_instance( )->get_fipos( iv_fipex = <ls_t_kont>-fipex ).
***************************************************************************
*                   FISTL - Finanzstelle                                  *
***************************************************************************
        <ls_t_kont>-fistl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-fistl.
***************************************************************************
*                   HKONT - Sachkonto                                     *
***************************************************************************
        <ls_t_kont>-hkont = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-saknr.
        IF <ls_t_kont>-hkont IS INITIAL.
          "Ableitung Sachkonto für HHM-Kontierung
          <ls_t_kont>-hkont = /thkr/cl_pso_xml_processing=>get_instance( )->get_hkont(
                                                                           iv_gjahr = COND gjahr( WHEN dest_line-budat IS INITIAL THEN dest_line-bldat(4)
                                                                                                  ELSE dest_line-budat(4) )                 " Geschäftsjahr
                                                                           iv_bukrs = dest_line-bukrs                 " Buchungskreis
                                                                           iv_fipex = <ls_t_kont>-fipex                 " Finanzposition
                                                                           iv_fistl = <ls_t_kont>-fistl                 " Finanzstelle
                                                                           iv_psoty = ''                 " Belegtyp Zahlungsanordnungen
                                                                           iv_blart = dest_line-blart                 " Belegart
                                                                         ).
        ENDIF.
***************************************************************************
*                   MSKZ - Mehrwehrtsteuerkennzeichen                     *
***************************************************************************
        <ls_t_kont>-zz_mwskz = /thkr/cl_pso_xml_processing=>get_instance( )->get_mwskz(
                                                                            iv_blart = dest_line-blart                  " Belegart
                                                                            iv_bukrs = dest_line-bukrs                 " Buchungskreis
                                                                            iv_saknr = <ls_t_kont>-hkont                 " Nummer des Sachkontos
                                                                            iv_btyp = ''                                "Feld aus BIC-Datei nicht relevant für XML
                                                                            iv_bkz = ''                                 "Feld aus BIC-Datei nicht relevant für XML
                                                                          ).
***************************************************************************
*                   GSBER - Geschäftsbereich                              *
***************************************************************************
        <ls_t_kont>-gsber = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-gsber.
***************************************************************************
*                   AUFNR - Innenauftrag                                  *
***************************************************************************
*        <ls_t_kont>-aufnr = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-aufnr.
***************************************************************************
*                   KOSTL - Kostenstelle                                  *
***************************************************************************
        <ls_t_kont>-kostl = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-kostl.
***************************************************************************
*                   PARTNER - Geschäftspartner                            *
***************************************************************************
        " Vereinbarung: Geschäftspartner wird nicht gebraucht.
        IF /thkr/cl_pso_xml_processing=>get_instance( )->check_bp_for_mb(
                                                        EXPORTING
                                                          iv_blart      = dest_line-blart           " Belegart
                                                          is_data       = out_struct                " Output Struktur
                                                          is_data_line  = dest_line                 " AIF SAP Struktur für Mittelbindung
                                                          is_data_field = 'PARTNER'                 " allgemeines flag
                                                        CHANGING
                                                          ct_return     = return_tab[]
                                                      ) = abap_true.
          <ls_t_kont>-partner = /thkr/cl_pso_xml_processing=>get_instance( )->get_partner(
                                                                             EXPORTING
                                                                              iv_blart = raw_line-blart                  " Belegart
                                                                              iv_kunnr = <ls_kblp>-kunnr                 " Debitorennummer
                                                                              iv_lifnr = <ls_kblp>-lifnr                 " Kontonummer des Lieferanten bzw. Kreditors
                                                                              iv_sst   = dest_line-mv_sst                " BP: Schnittstellenpartner
                                                                              iv_belnr = conv belnr_d( dest_line-ktxt )
                                                                              iv_gjahr = <ls_items>-key-gjahr
                                                                             IMPORTING
                                                                               ev_bpext = <ls_t_kont>-mv_bpext                 " Geschäftspartnernummer im externen System
                                                                           ).
        ENDIF.
******************************************************************************************
*                   CONSUMEKZ - Kennzeichen: Betragsänderung nur mit Wertanpassungsbelegen *
*************************************************************************** **************
        <ls_t_kont>-consumekz = <ls_kblp>-consumekz.
***************************************************************************
*                   WTORIG - Originalbetrag in Transaktionswährung        *
***************************************************************************
        <ls_t_kont>-wtorig = <ls_kblp>-wtges.

***************************************************************************
*                   FDATK - Fälligkeitsdatum Mittelbindung                *
***************************************************************************
        IF <ls_kblp>-fdatk IS NOT INITIAL OR <ls_kblp>-fdatk <> '00000000'.
          <ls_t_kont>-fdatk = <ls_kblp>-fdatk(4) && '0101'.
        ENDIF.
***************************************************************************
*                   SGTXT - Positionstext                                 *
***************************************************************************
        IF dest_line-blart = 'A1'.
          "Betragslose Auszahlungsanordung
          "Für Auslandzahlung
          <ls_t_kont>-sgtxt = |*{ dest_line-ktxt }|.
        ELSE.
          <ls_t_kont>-sgtxt = |*{ <ls_kblp>-ptext }|.
        ENDIF.
***************************************************************************
*                   pmactive - Positionstext                              *
***************************************************************************
        <ls_t_kont>-pmactive = abap_true.
***************************************************************************
*                   BLPOS - Belegposition                                 *
***************************************************************************

        <ls_t_kont>-blpos = COND kblpos( WHEN raw_line-blart = 'NB' THEN /thkr/cl_pso_xml_processing=>get_instance( )->get_bpos(
                                                                                                                       iv_fipex = <ls_t_kont>-fipex                 " Finanzposition
                                                                                                                       iv_fistl = <ls_t_kont>-fistl                 " Finanzstelle
                                                                                                                       iv_belnr = <ls_kblp>-belnr
                                                                                                                       iv_bpos = <ls_kblp>-blpos                 " Belegnummer eines Buchhaltungsbeleges
                                                                                                                     )
                                         ELSE <ls_kblp>-blpos ).

        DATA(lv_do_not_append) = /thkr/cl_pso_xml_processing=>get_instance( )->check_mb_bpos_does_not_exist(
                                                                              EXPORTING
                                                                                is_data_struct = raw_struct
                                                                                is_data_line   = raw_line                  " Belegkopf: Manuelle Belegerfassung
                                                                                iv_belnr = <ls_kblp>-belnr                 " Belegnummer eines Buchhaltungsbeleges
                                                                                iv_bpos = <ls_t_kont>-blpos                 " Belegposition Mittelvormerkung
                                                                                iv_fistl = <ls_t_kont>-fistl                  " Finanzstelle
                                                                                iv_fipex = <ls_t_kont>-fipex                 " Finanzposition
                                                                                iv_partner     = <ls_t_kont>-partner                 " Partnernummer
                                                                                iv_zz_mwskz    = <ls_t_kont>-zz_mwskz                 " Umsatzsteuerkennzeichen
                                                                                iv_consumekz   = <ls_t_kont>-consumekz                 " Verbrauch darf reservierten Betrag unbegrenzt überschreiten
                                                                                iv_blart       = dest_line-blart                 " Belegart
                                                                              CHANGING
                                                                                ct_return      = return_tab[]
                                                                       ).
        IF lv_do_not_append = abap_false.
          append_flag  = abap_true.
        ELSE.
          IF append_flag = abap_true.
            "Es gibt mindestens eine neue Position.
            "Also anhängen
            append_flag = abap_true.
          ELSE.
            "Nichts neues. also Mittelbindung nicht anpassen.
            append_flag = abap_false.
          ENDIF.
          "Belegposition existiert bereits
          "keine Aufnahme in die Mittelbindung
          DELETE TABLE dest_line-t_kont FROM <ls_t_kont>.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
