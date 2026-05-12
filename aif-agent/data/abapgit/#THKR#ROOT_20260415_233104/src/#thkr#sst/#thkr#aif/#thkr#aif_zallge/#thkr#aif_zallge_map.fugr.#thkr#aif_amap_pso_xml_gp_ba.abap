FUNCTION /thkr/aif_amap_pso_xml_gp_ba .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_DE_PSO_FMBSEC
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_PSO_XML_SAP
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_GP
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_BP_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------

*  FIELD-SYMBOLS: <ls_items> TYPE /thkr/s_de_pso_xml.
*  DATA: lv_BA_found TYPE flag.
*
*    lv_BA_found = abap_false.
*    "Geschäftspartner ohne BLART, BELNR, GJAHR oder LOTKZ
*    "Es gibt keinen Bezug zwischen Geschäftspartner und Betragsloser Anordnung.
*    LOOP AT raw_struct-values-items ASSIGNING <ls_items>.
*
*      "Positionen der Bargeldlosen Anordnung im Datensatz ermitteln
*      LOOP AT  <ls_items>-lt_kblk ASSIGNING FIELD-SYMBOL(<ls_kblk>) WHERE blart = 'BA'.
*
*        "Prüfen, ob Belegnummer bereits in Zielstruktur vorhanden ist.
*        LOOP AT out_struct-werte-anordnungen ASSIGNING FIELD-SYMBOL(<ls_ao>).
*          READ TABLE <ls_ao>-gp WITH KEY  src_belnr = <ls_kblk>-belnr TRANSPORTING NO FIELDS.
*          IF sy-subrc = 0.
*            "Belegnummer bereits übernommen.
*            "gehe zum nächsten Datensatz.
*            lv_BA_found = abap_false.
*            CONTINUE.
*          ELSE.
*            "Belegnummer ist noch nicht übernommen.
*            READ TABLE raw_struct-values-items WITH KEY key-belnr = <ls_kblk>-belnr ASSIGNING <ls_items>.
*            IF sy-subrc = 0.
*              "Zeile in Datenlieferung Identifiziert
*              "Belegnummer speichern und Schleife Verlassen
*              dest_line-src_belnr = <ls_kblk>-belnr.
*              lv_BA_found = abap_true.
*              EXIT.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.
*        IF sy-subrc <> 0.
*          "Es gibt noch keine Anordnungen in der Zielstruktur.
*          "Belegnummer speichern und Schleife Verlassen
*          dest_line-src_belnr = <ls_kblk>-belnr.
*          lv_BA_found = abap_true.
*        ENDIF.
*      ENDLOOP.
*      IF lv_BA_found = abap_true.
*        "Betragslose Anordnung gefunden. Kein weitere Schleifenlauf notwendig.
*        EXIT.
*      ENDIF.
*    ENDLOOP.
  TRY.
      DATA(lv_fipex) = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-lt_kblp[ belnr = raw_line-bsec-belnr blpos = raw_line-bsec-buzei ]-fipex.
      DATA(lv_fistl) = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-lt_kblp[ belnr = raw_line-bsec-belnr blpos = raw_line-bsec-buzei ]-fistl.

      IF sy-subrc = 0.

***************************************************************************
*                   EP - Einzelplan                                       *
***************************************************************************
        dest_line-ep = lv_fipex(2).
***************************************************************************
*                   DST_OLD - Dienststelle                                *
***************************************************************************
        dest_line-dst_old = lv_fistl(4).
***************************************************************************
*                   /thkr/gsber - Geschäftsbereich                        *
***************************************************************************
        /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
             iv_ep  = dest_line-ep                 " Einzelplan
             iv_oeh = CONV /thkr/mig_oeh_old( lv_fistl )                " OEH  alt
             iv_kapitel = CONV /thkr/mig_kapitel( lv_fipex+2(4) )
             iv_titel = CONV /thkr/mig_titel( lv_fipex+6(5) )
             ).

        dest_line-/thkr/gsber = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-gsber.

***************************************************************************
*                   BURKS - Buchungskreis                                 *
***************************************************************************
        APPEND INITIAL LINE TO dest_line-customer-t_customer_company ASSIGNING FIELD-SYMBOL(<ls_s_cust>).
        APPEND INITIAL LINE TO dest_line-vendor-t_vendor_company ASSIGNING FIELD-SYMBOL(<ls_s_vend>).
        <ls_s_cust>-bukrs = <ls_s_vend>-bukrs = /thkr/cl_fi_central_mapping=>get_instance( )->ms_central_map-bukrs.
***************************************************************************
*                   BURKS - Buchungskreis                                 *
***************************************************************************
        <ls_s_cust>-zuawa = <ls_s_vend>-zuawa = |001|.
***************************************************************************
*                   AKONT - Abstimmkonto                                  *
***************************************************************************
        <ls_s_cust>-akont = /thkr/cl_pso_xml_processing=>get_instance( )->get_akont(
                                                                      iv_/thkr/sst = dest_line-/thkr/sst                 " BP: Schnittstellenpartner
                                                                      iv_koart     = 'D'                 " Kontoart
                                                                    ).
        <ls_s_vend>-akont = /thkr/cl_pso_xml_processing=>get_instance( )->get_akont(
                                                                      iv_/thkr/sst = dest_line-/thkr/sst                 " BP: Schnittstellenpartner
                                                                      iv_koart     = 'K'                 " Kontoart
                                                                    ).
***************************************************************************
*                   T_MANDATE - Mandate                                   *
***************************************************************************
        IF raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd IS NOT INITIAL.
          APPEND INITIAL LINE TO dest_line-t_mandate ASSIGNING FIELD-SYMBOL(<ls_mandate>).
          MOVE-CORRESPONDING raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd TO <ls_mandate>.
          <ls_mandate>-sepa_anwnd = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-anwnd.
          <ls_mandate>-sepa_mndid = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-mndid.
          <ls_mandate>-sepa_val_from_date = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-val_from_date.
          <ls_mandate>-sepa_val_to_date = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-val_to_date.
          <ls_mandate>-sepa_sign_city = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-sign_city.
          <ls_mandate>-sepa_sign_date = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-sign_date.
          <ls_mandate>-sepa_status = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-status.
          "Kassenzeichen nur bei Einmalmandaten füllen
          <ls_mandate>-/thkr/xblnr = COND #( WHEN raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-pay_type = '1'
                                             THEN raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-lt_kblk[ belnr = raw_line-bsec-belnr ]-xblnr
                                             WHEN raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-pay_type = 'N' THEN '' ).
          <ls_mandate>-/thkr/gsber = dest_line-/thkr/gsber.
          <ls_mandate>-sepa_crdid = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-ls_sepa_mnd-rec_crdid.
        ENDIF.
      ENDIF.
    CATCH cx_sy_itab_line_not_found.
      IF 1 = 0. MESSAGE e055(/thkr/sst) WITH raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-key-belnr
                                             raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-key-gjahr
                                             raw_line-bsec-buzei.ENDIF.
      APPEND VALUE bapiret2(  id = '/THKR/SST'
                              number = 055
                              type =  'E'
                              message_v1 = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-key-belnr
                              message_v2 = raw_struct-values-items[ key-belnr = raw_line-bsec-belnr key-gjahr = raw_line-bsec-gjahr ]-key-gjahr
                              message_v3 = raw_line-bsec-buzei ) TO dest_line-msg.
  ENDTRY.
ENDFUNCTION.
