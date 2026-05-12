FUNCTION /thkr/aif_amap_pso_xml_mb_up .
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
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_MV_UP
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_PSM_MV_UP_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  "Datensatz aus KBLE und KBLP wird durch Schleife hinzugefügt.
  DATA: lv_sum_new_kble_wtabb_ges TYPE fmwtsupp VALUE IS INITIAL.   "Summe neuer KBLE-Datensätze (noch nicht gebuchter Wertanpassungen)
  DATA: lv_sum_booked_kble_wtabb_ges TYPE fmwtsupp VALUE IS INITIAL. "Summe alter KBLE-Datensätze (bereits gebuchte Wertanpassungen)
  append_flag = abap_false.


  LOOP AT raw_struct-values-items[ key-belnr = raw_line-belnr ]-lt_kblp ASSIGNING FIELD-SYMBOL(<ls_kblp>) WHERE belnr = raw_line-belnr.

    /thkr/cl_pso_xml_processing=>get_instance( )->get_mb_data(
        EXPORTING
          iv_kblnr      = raw_line-belnr                 " Belegnummer Mittelvormerkung
          is_kblk       = raw_line                 " Belegkopf: Manuelle Belegerfassung
          iv_fipex      = <ls_kblp>-fipex
          iv_fistl      = <ls_kblp>-fistl
          iv_blpos      = <ls_kblp>-blpos
        IMPORTING
          ev_mb_in_file = DATA(lv_mb_in_file)                 " allgemeines flag
        CHANGING
          ct_msgs       = dest_line-msg
        ).
    READ TABLE dest_line-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      "Es konnte keine Mittelbindung gefunden werden. Mapping der Finanzdaten nicht möglich
      "Bearbeitung beenden.
      RETURN.
    ELSE.

      IF lv_mb_in_file = abap_false.
        "die Wertanpassung kann nur erfolgen, wenn die Mittelbindung auf auf der Datenbank existiert.
        "wenn das Flag lv_mb_in_file = abap_true ist, bedeutet dass, dass keine Mittelbindung von der Datenbank ermittelt werden konnte
        "Belegnummer, Finanzposition und Finanzstelle werden zur Ermittlung verwendet.
*****************************************************************************
*                   BLPOS - Belegposition Mittelvormerkung der Wertanpassung*
*****************************************************************************
        dest_line-blpos = COND kblpos( WHEN raw_line-blart = 'NB' THEN /thkr/cl_pso_xml_processing=>get_instance( )->get_bpos(
                                                                                                                       iv_fipex = /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-fipex                 " Finanzposition
                                                                                                                       iv_fistl = /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-fistl                 " Finanzstelle
                                                                                                                       iv_belnr = <ls_kblp>-belnr
                                                                                                                       iv_bpos = <ls_kblp>-blpos                 " Belegnummer eines Buchhaltungsbeleges
                                                                                                                     )
                                       ELSE <ls_kblp>-blpos ).
        DATA(lv_do_not_process) = /thkr/cl_pso_xml_processing=>get_instance( )->check_mb_bpos_exists(
                                                                               is_data_struct = raw_struct
                                                                               is_data_line   = raw_line                 " Belegkopf: Manuelle Belegerfassung
                                                                               iv_belnr       = <ls_kblp>-belnr                 " Belegnummer eines Buchhaltungsbeleges
                                                                               iv_bpos        = dest_line-blpos                 " Belegposition Mittelvormerkung
                                                                               iv_fistl       = /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-fistl
                                                                               iv_fipex       = /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-fipex
                                                                             ).
        IF lv_do_not_process = abap_false.

***************************************************************************
*                   EP - Einzelplan                                       *
***************************************************************************
          dest_line-ep = <ls_kblp>-fipex(2).
***************************************************************************
*                   DST_OLD - alte Dienststelle                           *
***************************************************************************
          dest_line-dst_old = <ls_kblp>-fistl.
          "Es gibt manuelle Abbausätze (KBLE)
          TRY.
              LOOP AT raw_struct-values-items[ key-belnr = raw_line-belnr ]-lt_kble ASSIGNING FIELD-SYMBOL(<ls_kble>) WHERE belnr = raw_line-belnr
                                                                                                                      AND   blpos = <ls_kblp>-blpos
                                                                                                                      AND   vrgng = 'KMAN'.
                "Meldungen des Vorgängersatzes löschen
                CLEAR: dest_line-msg.
                /thkr/cl_pso_xml_processing=>get_instance( )->map_mv_up_by_kble(
                   EXPORTING
                     is_kble      = <ls_kble>                 " Belegpositionsentwicklung: Manuelle Belegerfassung
                   CHANGING
                     cs_dest_line = dest_line                 " AIF SAP Struktur für Wertanpassung
                 ).
                IF dest_line-wtsupp IS INITIAL.
                  "Summe bereits gebuchter Wertanpassung.
                  lv_sum_booked_kble_wtabb_ges += <ls_kble>-wtabb.
                ELSE.
                  "Summe neuer Wertanpassungen merken.
                  lv_sum_new_kble_wtabb_ges += dest_line-wtsupp.
                ENDIF.
                "Es haben sich Beträge in den Abbausätzen geändert. Daten hinzufügen.
                APPEND dest_line TO dest_table.

              ENDLOOP.
              IF <ls_kblp>-wtges = /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-wtges
                AND <ls_kblp>-erlkz IS INITIAL
                AND lv_sum_new_kble_wtabb_ges IS INITIAL.
                "Wert der Mittelbindungsposition zwischen Lieferung und Datenbank sind gleich.
                "Keine Änderung.
                CONTINUE.
              ENDIF.
              IF  ( ( <ls_kblp>-wtges <> /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-wtges + lv_sum_booked_kble_wtabb_ges )
                OR ( <ls_kblp>-wtges = /thkr/cl_pso_xml_processing=>get_instance( )->ms_mb_data-wtges AND <ls_kblp>-erlkz IS NOT INITIAL ) ).
                "Meldungen des Vorgängersatzes löschen
                CLEAR: dest_line-msg.


                "Es gab eine Wertanpassung der Belegpositon (KBLP-WTGES).
                "Allerdings muss noch der zuvor bereits abgebuchte Betrag abgezogen werden.
                "Andernfalls wird zu der Betrag für die  Wertanpassung falsch berechnet.
                "Beispiel:
                "1.) Mittelbindung mit 5.000 EUR angelegt.
                "2.) Reduzierung der Mittelbindung via manuelle Abbausätze um 1.000 -> Neuer Wert: 4.000
                "3.) Erhöhung der Mittelbindung beim Partner um 2.000 (WTGES = 7.000)
                "3.1)  4.000 - 7.000 = - 3.000 => Erhöhung um 3.000 = WTGES = 7.000 -> Der Betrag wurde nicht um 2.000, sondern um 3.000 Erhöht.
                "                                                                      Es fehlt nun der bereits abgezogene Betrag.
                "3.2)  4.000 - ( 7.000 - 1.000) = -2.000 => Erhöhung um 2.000 = WTGES = 6.000 -> Betrag wurde um 2.000 erhöht.

                /thkr/cl_pso_xml_processing=>get_instance( )->map_mv_up_by_kblp(
                   EXPORTING
                     is_kblp      = <ls_kblp>                 " Belegpositionsentwicklung: Manuelle Belegerfassung
                     iv_booked_kble_wtapp_ges = lv_sum_booked_kble_wtabb_ges
                   CHANGING
                     cs_dest_line = dest_line                 " AIF SAP Struktur für Wertanpassung
                     ).
                APPEND dest_line TO dest_table.

              ENDIF.



            CATCH cx_sy_itab_line_not_found.
              "Keine Mittelbindung gefunden.
              IF 1 = 0. MESSAGE e048(/thkr/sst) WITH raw_line-belnr. ENDIF.
              APPEND VALUE bapiret2( type = 'E'
                                     id = /thkr/cl_pso_xml_processing=>get_instance( )->gc_msgid
                                     number = 48
                                     message_v1 = raw_line-belnr ) TO dest_line-msg.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
