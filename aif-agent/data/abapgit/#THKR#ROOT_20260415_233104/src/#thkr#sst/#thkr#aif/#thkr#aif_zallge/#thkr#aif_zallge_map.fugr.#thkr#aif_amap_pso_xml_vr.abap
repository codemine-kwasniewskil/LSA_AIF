FUNCTION /thkr/aif_amap_pso_xml_vr .
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
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_VR
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_PSM_VR_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <ls_items> TYPE /thkr/s_de_pso_xml.
  "Lese er Anordnung (Jede Anordnung ist auf Ebene ITEM zu finden)
  READ TABLE raw_struct-values-items WITH KEY key-lotkz = raw_line-lotkz
                                              key-belnr = raw_line-belnr ASSIGNING <ls_items>.
  IF sy-subrc = 0.

    "Lesen der Sachkontenzeile pso02s für jede Belegposition (pso02)
    LOOP AT <ls_items>-lt_pso02s  ASSIGNING FIELD-SYMBOL(<ls_pso02s>) WHERE lotkz = <ls_items>-key-lotkz
                                                                        AND itabkey = raw_line-itabkey.
      CASE <ls_pso02s>-shkzg.
        WHEN: 'H'.
          "Senderzeile für Umbuchung
          /thkr/cl_pso_xml_processing=>get_instance( )->map_dest_line_vr_sender(
            EXPORTING
              is_pso02s    = <ls_pso02s>                " Struktur Zahlungsanordnung - Sachkonteninformation
            CHANGING
              cs_dest_line = dest_line                 " AIF SAP Struktur für Anordnungen
          ).
        WHEN: 'S'.
          "Empfängerzeile für Umbuchung
          APPEND INITIAL LINE TO dest_line-t_sender_kont ASSIGNING FIELD-SYMBOL(<ls_t_kont>).
          /thkr/cl_pso_xml_processing=>get_instance( )->map_dest_line_vr_receiver(
            EXPORTING
              is_pso02s    = <ls_pso02s>                 " Struktur Zahlungsanordnung - Sachkonteninformation
              iv_psoty     = dest_line-psoty                 " Belegtyp Zahlungsanordnungen
              iv_blart     = dest_line-blart                 " Belegart
            CHANGING
              cs_dest_line = <ls_t_kont>                  " AIF SAP Struktur für Anordnungen
          ).
      ENDCASE.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
