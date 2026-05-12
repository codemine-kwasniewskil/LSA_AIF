FUNCTION /thkr/aif_amap_pso_xml_anord .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_DE_PSO_XML
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_PSO_XML_SAP
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_PSO_XML_SAP_OBJECTS
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_PSO_XML_ANORDNUNGEN
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  LOOP AT out_struct-werte-anordnungen ASSIGNING FIELD-SYMBOL(<ls_existing_ao>).
    "Wenn ein Datensatz in der Zielstruktur gefunden wurde, wird das append_flag auf abap_false gesetzt.
    "Dann muss auch nicht weitere Anordnungen geprüft werden.
    IF append_flag = abap_true.
      LOOP AT <ls_existing_ao>-ao ASSIGNING FIELD-SYMBOL(<ls_ao>).
        "Anordnung gefunden.
        "Belegdaten zu Anordnung dazupacken
        TRY.
            IF dest_line-ao IS NOT INITIAL.
              "Nur Zusammenpacken, wenn auch schon Anordnungen vorhanden sind.
              "Andernfalls ist es die erste Zeile. Diese muss hinzugefügt werden.
              IF <ls_ao>-glblid+4(10) = dest_line-ao[ 1 ]-glblid+4(10).
                APPEND LINES OF dest_line-gp TO <ls_existing_ao>-gp.
                APPEND LINES OF dest_line-ao TO <ls_existing_ao>-ao.
                APPEND LINES OF dest_line-mb TO <ls_existing_ao>-mb.
                Append VALUE ZFI_R_BLART( sign = 'I'
                                          option = 'EQ'
                                          low = raw_line-key-blart ) to <ls_existing_ao>-blart_seltab.
                append_flag = abap_false.
                EXIT.
              ELSE.
                append_flag = abap_true.
              ENDIF.
            ELSE.
              append_flag = abap_true.
            ENDIF.
          CATCH cx_sy_itab_line_not_found.
            IF 1 = 0. MESSAGE e029(/thkr/sst) WITH <ls_ao>-gjahr <ls_ao>-lotkz.ENDIF.
            APPEND VALUE bapiret2(  id = '/THKR/SST'
                                    number = 029
                                    type =  'E'
                                    message_v1 = <ls_ao>-gjahr
                                    message_v2 = <ls_ao>-lotkz ) TO <ls_ao>-msg.
        ENDTRY.
      ENDLOOP.

      "Polizei liefert einzelne Ratenzahlungen
      "In der Internen Schnittstelle wird nur eine benötigt.
      "daher nur einmalig hinzufügen.
      IF dest_line-ao_stu IS NOT INITIAL.
        IF <ls_existing_ao>-ao_stu IS INITIAL.
          append_flag = abap_true.
        ELSE.
          append_flag = abap_false.
        ENDIF.
      ENDIF.
*      LOOP AT <ls_existing_ao>-ao_stu ASSIGNING FIELD-SYMBOL(<ls_ao_stu>).
*        TRY.
*            "Stundung gefunden.
*            "Belegdaten zu Stundungsanordnung dazupacken
*            IF dest_line-ao_stu IS NOT INITIAL.
*              IF <ls_ao_stu>-glblid+4(10) = dest_line-ao_stu[ 1 ]-glblid+4(10).
*                APPEND LINES OF dest_line-gp TO <ls_existing_ao>-gp.
*                APPEND LINES OF dest_line-ao_stu TO <ls_existing_ao>-ao_stu.
*                append_flag = abap_false.
*                EXIT.
*              ELSE.
*                append_flag = abap_true.
*              ENDIF.
*            ELSE.
*              append_flag = abap_true.
*            ENDIF.
*          CATCH cx_sy_itab_line_not_found.
*            IF 1 = 0. MESSAGE e029(/thkr/sst) WITH <ls_ao_stu>-gjahr <ls_ao_stu>-lotkz.ENDIF.
*            APPEND VALUE bapiret2(  id = '/THKR/SST'
*                                    number = 029
*                                    type =  'E'
*                                    message_v1 = <ls_ao_stu>-gjahr
*                                    message_v2 = <ls_ao_stu>-lotkz ) TO <ls_ao_stu>-msg.
*        ENDTRY.
*      ENDLOOP.
    ENDIF.
  ENDLOOP.

  "Es werden Protokollzeilen pro Annordnungsnummer, Geschäftsjahr angelegt.
  "Bei der Mittelbindung gibt es aber keine Anordnung, weshalb immer alle Zeilen
  "aus KBLP in die Protokolltabelle übernommen werden. Daher werden falsche Zeilen
  "Aus der Protokolltabelle entfernt.
  LOOP AT dest_line-mb ASSIGNING FIELD-SYMBOL(<ls_mb>).
    DELETE dest_line-txt_prot WHERE glblid <> <ls_mb>-glblid.
  ENDLOOP.

    LOOP AT dest_line-mb_up ASSIGNING FIELD-SYMBOL(<ls_mb_up>).
    DELETE dest_line-txt_prot WHERE glblid <> <ls_mb_up>-glblid.
  ENDLOOP.

  LOOP AT dest_line-storno ASSIGNING FIELD-SYMBOL(<ls_storno>).
    DELETE dest_line-txt_prot WHERE glblid <> <ls_storno>-glblid.
  ENDLOOP.

  LOOP AT dest_line-ao_stu ASSIGNING FIELD-SYMBOL(<ls_ao_stu>).
    DELETE dest_line-txt_prot WHERE glblid <> <ls_ao_stu>-glblid.
  ENDLOOP.


ENDFUNCTION.
