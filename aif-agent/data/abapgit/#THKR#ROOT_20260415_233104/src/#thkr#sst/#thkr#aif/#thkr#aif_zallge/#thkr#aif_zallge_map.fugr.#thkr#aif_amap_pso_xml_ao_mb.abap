FUNCTION /thkr/aif_amap_pso_xml_ao_mb .
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
  DATA: lv_idx_pos  TYPE i value 0.

  "Lese er Anordnung (Jede Anordnung ist auf Ebene ITEM zu finden)

  READ TABLE raw_struct-values-items WITH KEY key-lotkz = raw_line-lotkz
                                              key-belnr = raw_line-belnr ASSIGNING <ls_items>.
  IF sy-subrc = 0.
    "Lesen der Sachkontenzeile pso02s für jede Belegposition (pso02)
    LOOP AT <ls_items>-lt_pso02s  ASSIGNING FIELD-SYMBOL(<ls_pso02s>) WHERE lotkz = <ls_items>-key-lotkz
                                                                        AND itabkey = raw_line-itabkey.
      lv_idx_pos += 1.
      IF sy-subrc = 0.
        "Auslesen der Finanzdaten aus Mittelbindung

        "Prüfung, ob sich die Mittelbindung in der selben Datenlieferung befindet
        LOOP AT raw_struct-values-items ASSIGNING FIELD-SYMBOL(<ls_item_kblk>).
          TRY.
              DATA(ls_kplk) = <ls_item_kblk>-lt_kblk[ belnr = <ls_pso02s>-kblnr ].
              DATA(lt_kblp) = <ls_item_kblk>-lt_kblp.
              "Mittelbindung gefunden.
              "Schleife verlassen.
              EXIT.
            CATCH cx_sy_itab_line_not_found.
              "Keine Daten in der Lieferung.
              CLEAR: ls_kplk, lt_kblp.
          ENDTRY.
        ENDLOOP.

        /thkr/cl_pso_xml_processing=>get_instance( )->get_mb_data(
          EXPORTING
            iv_kblnr      = <ls_pso02s>-kblnr                 " Belegnummer Mittelvormerkung
            is_kblk       = ls_kplk                 " Belegkopf: Manuelle Belegerfassung
            iv_fistl      = <ls_pso02s>-fistl
            iv_fipex      = <ls_pso02s>-fipex
          IMPORTING
            ev_mb_in_file = DATA(lv_mb_in_file)                 " allgemeines flag
          CHANGING
            ct_msgs       = dest_line-msg
        ).
        IF dest_line-msg IS NOT INITIAL.
          "Es konnte keine Mittelbindung gefunden werden. Mapping der Finanzdaten nicht möglich
          "Bearbeitung beenden.
          RETURN.
        ENDIF.

        IF lv_mb_in_file = abap_false.
          "Daten zur Mittelbindung kommen von der Datenbank.
          /thkr/cl_pso_xml_processing=>get_instance( )->map_dest_line_ao_with_db(
            CHANGING
              cs_dest_line = dest_line                 " AIF SAP Struktur für Anordnungen
          ).
        ELSE.
          "Daten zur Mittelbindung kommen aus der Datei
          /thkr/cl_pso_xml_processing=>get_instance( )->map_dest_line_ao_with_file(
          EXPORTING
            iv_kblnr = <ls_pso02s>-kblnr
            iv_kblpos = <ls_pso02s>-kblpos
            is_kblk = ls_kplk
            it_kblp = lt_kblp
          CHANGING
                cs_dest_line = dest_line
                ).
        ENDIF.
***************************************************************************
*                   SGTXT - Positionstext                                 *
***************************************************************************
        dest_line-t_kont[ lv_idx_pos ]-sgtxt = |*{ <ls_items>-lt_pso02[ itabkey = <ls_pso02s>-itabkey ]-sgtxt }|.
***************************************************************************
*                   WRBTR - Betrag in Belegwährung                        *
***************************************************************************
        dest_line-t_kont[ lv_idx_pos ]-wrbtr = <ls_pso02s>-wrbtr.
***************************************************************************
*                   ERLKz - Erledigungskennzeichen  für offene Posten     *
***************************************************************************
        dest_line-t_kont[ lv_idx_pos ]-erlkz = <ls_pso02s>-erlkz.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
