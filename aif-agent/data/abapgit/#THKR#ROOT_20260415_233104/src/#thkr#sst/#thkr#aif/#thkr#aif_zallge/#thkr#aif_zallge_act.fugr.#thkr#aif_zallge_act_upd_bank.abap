FUNCTION /thkr/aif_zallge_act_upd_bank .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_GP
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "Bei der Aktualisierung des Geschäftspartners wird die externe Bank-ID nicht bei bestehenden
  "Bankverbindungen aktualisiert. Daher wird hier die Bankverbindung explizit um die externe Bank-ID aktualisiert.
  "Die Aktualisierung findet nur statt, wenn beim Geschäftspartner das Feld BKVID gefüllt wurde.

  DATA: lt_bankdetails TYPE STANDARD TABLE OF bapibus1006_bankdetails.
  DATA: ls_bankdetail_X TYPE bapibus1006_bankdetail_x.
  DATA: ls_bankdetail TYPE bapibus1006_bankdetail.
  DATA: lt_return TYPE STANDARD TABLE OF bapiret2. "lokale Fehlertabelle, weil die Funktionsbausteine die RETURN_TAB überschreiben.

  success = 'N'.
*"----------------------------------------------------------------------
  IF curr_line IS NOT INITIAL.
*"----------------------------------------------------------------------
    APPEND VALUE #( id         = 'KM'
                     number     = 418
                     type       = 'I'
                     message_v1 = '/THKR/AIF_ZALLGE_ACT_UPD_BANK' ) TO return_tab.
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
    IF curr_line-bkvid IS NOT INITIAL.
      "Es wurde beim Geschäftspartner eine externe Bankverbindung angegeben.
      IF curr_line-iban IS NOT INITIAL.
        "Bankdaten holen
        CALL FUNCTION 'BAPI_BUPA_BANKDETAILS_GET'
          EXPORTING
            businesspartner = curr_line-partner
*           VALID_DATE      = SY-DATLO
          TABLES
            bankdetails     = lt_bankdetails
            return          = lt_return.

        "anhand der IBAN die richtige Bankverbindung ermitteln
        READ TABLE lt_bankdetails WITH KEY iban = curr_line-iban ASSIGNING FIELD-SYMBOL(<ls_bank>).
        IF sy-subrc = 0.
          IF <ls_bank>-externalbankid IS INITIAL.
            MOVE-CORRESPONDING <ls_bank> TO ls_bankdetail.
            ls_bankdetail-externalbankid = curr_line-bkvid.
            ls_bankdetail_x-externalbankid = abap_true.

            "Bankdaten aktualisieren.
            CALL FUNCTION 'BAPI_BUPA_BANKDETAIL_CHANGE'
              EXPORTING
                businesspartner  = curr_line-partner
                bankdetailid     = <ls_bank>-bankdetailid
                bankdetaildata   = ls_bankdetail
                bankdetaildata_x = ls_bankdetail_x
              TABLES
                return           = lt_return.

            "Gesammelte Meldungen bei Bankenaktualisieurng ans AIF übergeben
            APPEND LINES OF lt_return TO return_tab.
            READ TABLE lt_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              success = 'N'.
            ELSE.
              IF 1 = 0. MESSAGE s075(/thkr/sst) WITH curr_line-bkvid <ls_bank>-bankdetailid curr_line-partner.ENDIF.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true
*                 IMPORTING
*                 RETURN        =
                .

              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     type = 'S'
                                     number = 075
                                     message_v1 = curr_line-bkvid
                                     message_v2 = <ls_bank>-bankdetailid
                                     message_v3 = curr_line-partner ) TO return_tab.
              success = 'Y'.
            ENDIF.
          ELSE.
            IF <ls_bank>-externalbankid <> curr_line-bkvid.
              IF 1 = 0. MESSAGE e073(/thkr/sst) WITH <ls_bank>-bankdetailid <ls_bank>-externalbankid curr_line-bkvid.ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     type = 'E'
                                     number = 073
                                     message_v1 = <ls_bank>-bankdetailid
                                     message_v2 = <ls_bank>-externalbankid
                                     message_v3 = curr_line-bkvid ) TO return_tab.
            ENDIF.

            IF <ls_bank>-externalbankid = curr_line-bkvid.
              IF 1 = 0. MESSAGE s076(/thkr/sst) WITH <ls_bank>-bankdetailid curr_line-partner.ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     type = 'S'
                                     number = 076
                                     message_v1 = <ls_bank>-bankdetailid
                                     message_v2 = curr_line-partner ) TO return_tab.
              success = 'Y'.
            ENDIF.
          ENDIF.
        ELSE.
          "angegebene IBAN am Geschäftspartner nicht gefunden.
          IF 1 = 0. MESSAGE e074(/thkr/sst) WITH curr_line-iban curr_line-partner.ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                       type = 'E'
                       number = 074
                       message_v1 = curr_line-iban
                       message_v2 = curr_line-partner ) TO return_tab.
        ENDIF.
      ELSE. "curr_line-iban is not initial
        success = 'Y'.
        IF 1 = 0. MESSAGE i077(/thkr/sst) WITH curr_line-partner curr_line-bu_bpext.ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                     type = 'I'
                     number = 077
                     message_v1 = curr_line-partner
                     message_v2 = curr_line-bu_bpext ) TO return_tab.
      ENDIF.  "curr_line-iban is not initial
    ENDIF.  "curr_line-bkvid IS NOT INITIAL.
  ENDIF.  "curr_line IS NOT INITIAL.
ENDFUNCTION.
*"----------------------------------------------------------------------
