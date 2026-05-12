FUNCTION /thkr/aif_amap_pso_xml_gp .
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

  FIELD-SYMBOLS: <ls_items> TYPE /thkr/s_de_pso_xml.

  TRY.
      READ TABLE raw_struct-values-items WITH KEY key-belnr = raw_line-bsec-belnr
                                              key-gjahr = raw_line-bsec-gjahr ASSIGNING <ls_items>.

      IF sy-subrc = 0.
        "Anordnung
        DATA(lv_fipex) = <ls_items>-lt_pso02s[ lotkz = <ls_items>-key-lotkz gjahr = <ls_items>-key-gjahr ]-fipex.
        DATA(lv_fistl) = <ls_items>-lt_pso02s[ lotkz = <ls_items>-key-lotkz gjahr = <ls_items>-key-gjahr ]-fistl.

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
        IF <ls_items>-ls_sepa_mnd IS NOT INITIAL.
          APPEND INITIAL LINE TO dest_line-t_mandate ASSIGNING FIELD-SYMBOL(<ls_mandate>).
          MOVE-CORRESPONDING <ls_items>-ls_sepa_mnd TO <ls_mandate>.
          <ls_mandate>-sepa_anwnd = <ls_items>-ls_sepa_mnd-anwnd.
          <ls_mandate>-sepa_mndid = <ls_items>-ls_sepa_mnd-mndid.
          <ls_mandate>-sepa_val_from_date = <ls_items>-ls_sepa_mnd-val_from_date.
          <ls_mandate>-sepa_val_to_date = <ls_items>-ls_sepa_mnd-val_to_date.
          <ls_mandate>-sepa_sign_city = <ls_items>-ls_sepa_mnd-sign_city.
          <ls_mandate>-sepa_sign_date = <ls_items>-ls_sepa_mnd-sign_date.
          <ls_mandate>-sepa_status = <ls_items>-ls_sepa_mnd-status.
          "Kassenzeichen nur bei Einmalmandaten füllen
          <ls_mandate>-/thkr/xblnr = COND #( WHEN <ls_items>-ls_sepa_mnd-pay_type = '1' THEN <ls_items>-lt_pso02[ belnr = <ls_items>-key-belnr ]-xblnr
                                             WHEN <ls_items>-ls_sepa_mnd-pay_type = 'N' THEN '' ).
          <ls_mandate>-/thkr/gsber = dest_line-/thkr/gsber.
          <ls_mandate>-sepa_crdid = <ls_items>-ls_sepa_mnd-rec_crdid.
        ENDIF.
      ENDIF.
    CATCH cx_sy_itab_line_not_found.
      IF 1 = 0. MESSAGE e029(/thkr/sst) WITH <ls_items>-key-gjahr <ls_items>-key-lotkz.ENDIF.
      APPEND VALUE bapiret2(  id = '/THKR/SST'
                              number = 029
                              type =  'E'
                              message_v1 = <ls_items>-key-gjahr
                              message_v2 = <ls_items>-key-lotkz ) TO dest_line-msg.
  ENDTRY.
ENDFUNCTION.
