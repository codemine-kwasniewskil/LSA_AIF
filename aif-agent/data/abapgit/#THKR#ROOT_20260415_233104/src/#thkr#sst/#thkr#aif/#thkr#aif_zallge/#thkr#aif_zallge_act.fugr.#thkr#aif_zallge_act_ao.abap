*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Anordnung"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_ao .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_AO
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA:
    mo_cut             TYPE REF TO /thkr/cl_psm_ao_appl,
    ls_document_number TYPE /thkr/s_psm_ao_document_number,
    ls_dto_psm_ao      TYPE /thkr/s_dto_psm_ao_bel_create,
    ls_gp              TYPE /thkr/s_aif_sap_gp.
*"----------------------------------------------------------------------
  success = 'N'.
*"----------------------------------------------------------------------
  IF curr_line IS NOT INITIAL.
*"----------------------------------------------------------------------
    APPEND VALUE #( id         = 'KM'
                     number     = 418
                     type       = 'I'
                     message_v1 = '/THKR/AIF_ZALLGE_ACT_AO' ) TO return_tab.
*"----------------------------------------------------------------------
* Check if Actions are allowed.
    CALL FUNCTION '/THKR/AIF_ZALLGE_ACT_OFF'
      TABLES
        return_tab = return_tab
      EXCEPTIONS
        off        = 1
        OTHERS     = 2.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "Prüfung, ob es aus dem Mapping Fehler gibt. (Zum Beispiel Anordnung oder Mittelbindung nicht gefunden)
    READ TABLE curr_line-msg WITH KEY type = 'E' TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      "Es fehlen relvante Daten für die Buchung.
      "Fehlermeldungen ans AIF - Log übergeben
      APPEND LINES OF curr_line-msg TO return_tab[].
    ELSE.

      IF curr_line-t_kont IS NOT INITIAL.
        IF curr_line-t_kont[ 1 ]-kblnr <> ''.
          DATA(original_kblnr) = curr_line-t_kont[ 1 ]-kblnr.
          "Die KBLNR kann auch die richtige SAP Belegnummer besitzen.
          "Daher erst prüfen, ob ein Beleg zur Nummer passt.
          SELECT COUNT( * )
            FROM kblk
           WHERE belnr = @original_kblnr
            AND bukrs = @curr_line-bukrs.
          "sy-subrc = 0
          "SAP Belegnummer existiert. KBLNR beibehalten.
          IF sy-subrc <> 0.
            "Es handelt sich nicht um die richtige SAP Belegnummer, sondern um das URkassenzeichen
            DATA belnr TYPE kblnr.
            SELECT SINGLE belnr FROM kblk INTO @belnr WHERE ktext = @original_kblnr.
            curr_line-t_kont[ 1 ]-kblnr = belnr.
          ENDIF.
        ENDIF.
      ENDIF.
*"----------------------------------------------------------------------
      TRY.
* Wenn der Geschäftspartner neu ist, wird PARTNER erst durch die Anlage
* des Geschäftspartner gefüllt.
* D.h.: Im Mapping ist er noch nicht vorhanden.
          curr_line-ao_proc_status = 'E'.

* Wenn es den Geschäftspartner schon gibt und PARTNER daher gefüllt ist,
* muss man ihn hier nicht nochmal lesen.
          IF curr_line-partner IS INITIAL.
            READ TABLE data-gp ASSIGNING FIELD-SYMBOL(<gp>) WITH KEY bu_bpext = curr_line-ao_bpext.

            IF sy-subrc <> 0.
              APPEND VALUE #( id         = '/CPD/SS_MESSAGES'
                              number     = 346
                              type       = 'E'
                              message_v1 = curr_line-ao_bpext ) TO return_tab.
              curr_line-ao_proc_status = 'E'.
              RETURN.
            ENDIF.

            curr_line-partner = <gp>-partner.
          ENDIF.
*"----------------------------------------------------------------------
          MOVE-CORRESPONDING curr_line TO ls_dto_psm_ao.

*
*          IF ls_dto_psm_ao-t_kont IS NOT INITIAL.
*            IF ls_dto_psm_ao-t_kont[ 1 ]-kblnr <> ''.
*              ASSIGN ls_dto_psm_ao-t_kont[ 1 ]-kblnr TO FIELD-SYMBOL(<belnr>).
*              DATA(urkassz) = ls_dto_psm_ao-t_kont[ 1 ]-kblnr.
*              SELECT SINGLE belnr FROM kblk INTO @<belnr> WHERE ktext = @urkassz.
*            ENDIF.
*          ENDIF.

          "Für Sollzugang mit Dateibezug (Datensatz nicht auf der Datenbank, sondern in der Datei)
          "Belegnummer wäre sonst gefüllt (Datensatz würde von der Datenbank gelesen werden)
          IF ls_dto_psm_ao-rebzg IS INITIAL
         AND ls_dto_psm_ao-psoty = '02' "Annahmeanordnung
         AND ls_dto_psm_ao-blart = 'DE'."Sollzugang
            TRY.
                "Lese Belegnummer aus Anordnung.
                ls_dto_psm_ao-rebzg = data-ao[ xblnr = ls_dto_psm_ao-bktxt psoty = '02' ]-belnr.
                IF ls_dto_psm_ao-rebzj IS INITIAL.
                  ls_dto_psm_ao-rebzj = data-ao[ xblnr = ls_dto_psm_ao-bktxt psoty = '02' ]-gjahr.
                ENDIF.
                IF ls_dto_psm_ao-rebzt IS INITIAL.
                  ls_dto_psm_ao-rebzt = 'F'.
                ENDIF.
                "Prüfen ob Belegnummer immer noch leer ist.
                "Denn dann konnte die Anordnung zum Sollzugang nicht erzeugt werden.
                "Fehlermeldung schreiben.
                IF ls_dto_psm_ao-rebzg IS INITIAL.
                  IF 1 = 0. MESSAGE e039(/thkr/sst) WITH ls_dto_psm_ao-bktxt.ENDIF.
                  APPEND VALUE #( id         = '/THKR/SST'
                               number     = 039
                               type       = 'E'
                               message_v1 = ls_dto_psm_ao-bktxt ) TO return_tab.
                ENDIF.
              CATCH cx_sy_itab_line_not_found.
                IF 1 = 0. MESSAGE e038(/thkr/sst) WITH ls_dto_psm_ao-bktxt.ENDIF.
                APPEND VALUE #( id         = '/THKR/SST'
                             number     = 038
                             type       = 'E'
                             message_v1 = ls_dto_psm_ao-bktxt ) TO return_tab.
            ENDTRY.

          ENDIF.

          /thkr/cl_psm_ao_appl=>get_instance( )->create_psm_ao_beleg(
            EXPORTING
              i_dto_psm_ao_bel_create  = ls_dto_psm_ao
            IMPORTING
              e_psm_ao_document_number = ls_document_number ).

          IF curr_line-is_sammel_ao = abap_true.
            "Für Sammelanordnungen müssen alle Belege in einer Anordnung erfasst werden.
            "Dazu muss die Anordnungsnummer in alle betroffenen Belege aufgenommen werden.
            "Feld für Gruppierung der Sammelanordnung über AIF-Mapping in Struktur geschrieben
            "Kennzeichen für Sammelanordnung aus Feld Merkmal.
            IF curr_line-sammel_ao_gr IS NOT INITIAL.
              LOOP AT data-ao ASSIGNING FIELD-SYMBOL(<ls_ao>) WHERE sammel_ao_gr = curr_line-sammel_ao_gr
                                                                AND is_sammel_ao = abap_true.
                <ls_ao>-lotkz = ls_document_number-lotkz.
              ENDLOOP.
            ENDIF.
          ENDIF.
          curr_line-ao_proc_status = 'S'.
          curr_line-belnr = ls_document_number-belnr.
          curr_line-lotkz = ls_document_number-lotkz.
          IF curr_line-long_text-lines IS NOT INITIAL.
            "Hinzfügen des Schlüssels für Langtexte.
            "Belegnummer erst nach Buchung im System.
            curr_line-long_text-header-tdname = |{ curr_line-bukrs }{ curr_line-belnr }{ curr_line-gjahr }|.
          ENDIF.
          success = 'Y'.
          IF 1 = 0. MESSAGE s823(fq) WITH ls_document_number-lotkz ls_document_number-belnr. ENDIF.
          APPEND VALUE #( id         = 'FQ'
                           number     = 823
                           type       = 'S'
                           message_v1 = ls_document_number-lotkz
                           message_v2 = ls_document_number-belnr ) TO return_tab.
          "Das AIF kriegt in manchen Fällen das COMMIT nicht sauber hin.
          "Also muss es hier einfach ausgelöst werden
          "Ohne dieses COMMIT WORK kommt es zu Folgefehlern beim Aktualisieren des XREF1_HD-Feldes
          COMMIT WORK AND WAIT.
*"----------------------------------------------------------------------
          "Für Auszahlungsanordnung mit Referenz auf Einnahmesollstellung
          " Es wird aus einem FUA Datensatz sowohl die Annahme- als auch die Auszahlungsanordnung erzeugt
          " Nach Anlage der Annahmeanordnung muss die Referenz in die entsprechende Auszahlungsanordnung geschrieben werden.
*          LOOP AT data-ao ASSIGNING FIELD-SYMBOL(<ls_ausao>)
*                             WHERE glblid = curr_line-glblid
*                             AND   psoty = 01
*                             AND   zlsch = 'X'.
*            "Die Annahmeanordnung wird nicht auf die Datenbank geschrieben. Ohne diese kann das Kassenzeichen nicht ermittelt werden.
*            COMMIT WORK AND WAIT.
*            SELECT SINGLE xblnr
*               FROM bkpf
*               WHERE bukrs = @curr_line-bukrs
*                 AND belnr = @curr_line-belnr
*                 AND gjahr = @curr_line-gjahr
*                 INTO @<ls_ausao>-bktxt.
*
*              "Übernehme Kassenzeichen der Annahmeanordnung in Belegzeile
*              curr_line-xblnr = <ls_ausao>-bktxt.
*          ENDLOOP.
*"----------------------------------------------------------------------
        CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_ao).
          IF lxc_ao->bapiret2_tab IS NOT INITIAL.
            APPEND LINES OF lxc_ao->bapiret2_tab TO return_tab.
          ELSE.
            APPEND VALUE #( id         = lxc_ao->if_t100_message~t100key-msgid
                            number     = lxc_ao->if_t100_message~t100key-msgno
                            type       = lxc_ao->if_t100_dyn_msg~msgty
                            message_v1 = lxc_ao->if_t100_dyn_msg~msgv1
                            message_v2 = lxc_ao->if_t100_dyn_msg~msgv2
                            message_v3 = lxc_ao->if_t100_dyn_msg~msgv3
                            message_v4 = lxc_ao->if_t100_dyn_msg~msgv4 ) TO return_tab.
          ENDIF.
      ENDTRY.
    ENDIF.
*"----------------------------------------------------------------------
    curr_line-msg = return_tab[].
  ENDIF.
*"----------------------------------------------------------------------

*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
