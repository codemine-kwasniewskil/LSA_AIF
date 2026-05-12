*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Anordnung"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_ref_zw_x .
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
                     message_v1 = '/THKR/AIF_ZALLGE_ACT_REF_ZW_X' ) TO return_tab.
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


    success = 'Y'.

*"----------------------------------------------------------------------
    IF curr_line-annao_ref_zhlwg_x IS NOT INITIAL.
      "Wenn das Feld annao_ref_zhlwg_x gefüllt ist, gibt es Verrechnungen (Zahlweg x)
      "Muss aktiv im AIF gemappt werden.


      "Für Auszahlungsanordnung mit Referenz auf Einnahmesollstellung
      " Es wird aus einem FUA Datensatz sowohl die Annahme- als auch die Auszahlungsanordnung erzeugt
      " Nach Anlage der Annahmeanordnung muss die Referenz in die entsprechende Auszahlungsanordnung geschrieben werden.
      DATA(lv_count) = 0.


      "Sondermechanismus für BIENE, um die Annahme- bzw. Auszahlungsanordnung des Landes(01) mit der des Bundes (03) und Kommune (02) zu verknüpfen.
      "In diesem Fall wird das Kassenzeichen der allg. Annahmeanordnung sowohl im Belegkopftext als auch in das Referenzfeld geschrieben (sind also gleich)
      "SAMBA benötigt diese Regelung nicht. Hier dürfen die erzeugen Annahmeanordnung nicht miteinander verkettet werden.
      "SAMBA liefert im Belegkopftext das Kassenzeichen der allg. Annahmeanordnung und im Referenzfeld die eindeutige Zeilenidentifikation
      IF curr_line-bktxt = curr_line-annao_ref_zhlwg_x.
        "Verknüpfung der Annahme- oder Auszahlungsanordnung für das Land (01)
        "mit Annahmeanorndung für Bund (03) und Kommune (02) (Im Rahmen der Verrechnung)
        LOOP AT data-ao ASSIGNING FIELD-SYMBOL(<ls_annao>)
                       WHERE bktxt = curr_line-bktxt
                       AND annao_ref_zhlwg_x <> curr_line-bktxt
                       AND   psoty = 02.

          "Ermittlung des Kassenzeichen für die Annahmeanordnung
          SELECT SINGLE xblnr
             FROM bkpf
             WHERE bukrs = @curr_line-bukrs
               AND belnr = @curr_line-belnr
               AND gjahr = @curr_line-gjahr
               INTO @<ls_annao>-bktxt.
          IF sy-subrc = 0.
            lv_count += 1.
            "Übernehme Kassenzeichen der Annahmeanordnung in Belegzeile
            curr_line-xblnr = <ls_annao>-bktxt.

            IF 1 = 0. MESSAGE s067(/thkr/sst) WITH curr_line-lotkz curr_line-xblnr. ENDIF.
            APPEND VALUE #( id         = '/THKR/SST'
                             number     = 067
                             type       = 'S'
                             message_v1 = curr_line-lotkz
                             message_v2 = |{ CONV string( lv_count ) ALPHA = OUT }|
                             message_v3 = curr_line-xblnr ) TO return_tab.
          ELSE.
            IF 1 = 0. MESSAGE e066(/thkr/sst) WITH curr_line-bukrs curr_line-gjahr curr_line-belnr. ENDIF.
            APPEND VALUE #( id         = '/THKR/SST'
                             number     = 066
                             type       = 'E'
                             message_v1 = curr_line-bukrs
                             message_v2 = curr_line-gjahr
                             message_v3 = curr_line-belnr ) TO return_tab.
            "Keine AnnAO auf der Datenbank.
            "Also Schleife verlassen.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      "Verknüpfung Annahmeanordung von Bund (03) und Kommune (02) zu Auszahlungsannordnung Bund (03) und Kommune (02)
      lv_count = 0.
      IF curr_line-psoty = 02.
        "Verknüpfung nur anlegen, sofern es sich um die Annahmeanordnung handelt.
        "Sofern die Verarbeitung an der Auszahlungsanordnung dran ist, muss hier nichts mehr verknüpft werden.
        LOOP AT data-ao ASSIGNING FIELD-SYMBOL(<ls_ausao>)
                           WHERE annao_ref_zhlwg_x = curr_line-annao_ref_zhlwg_x
                           AND   psoty = 01
                           AND   zlsch = 'X'.

          "Ermittlung des Kassenzeichen für die Annahmeanordnung
          SELECT SINGLE xblnr
             FROM bkpf
             WHERE bukrs = @curr_line-bukrs
               AND belnr = @curr_line-belnr
               AND gjahr = @curr_line-gjahr
               INTO @<ls_ausao>-bktxt.
          IF sy-subrc = 0.
            lv_count += 1.
            "Übernehme Kassenzeichen der Annahmeanordnung in Belegzeile
            curr_line-xblnr = <ls_ausao>-bktxt.

            IF 1 = 0. MESSAGE s065(/thkr/sst) WITH curr_line-lotkz curr_line-xblnr. ENDIF.
            APPEND VALUE #( id         = '/THKR/SST'
                             number     = 065
                             type       = 'S'
                             message_v1 = curr_line-lotkz
                             message_v2 = |{ CONV string( lv_count ) ALPHA = OUT }|
                             message_v3 = curr_line-xblnr ) TO return_tab.
          ELSE.
            IF 1 = 0. MESSAGE e066(/thkr/sst) WITH curr_line-bukrs curr_line-gjahr curr_line-belnr. ENDIF.
            APPEND VALUE #( id         = '/THKR/SST'
                             number     = 066
                             type       = 'E'
                             message_v1 = curr_line-bukrs
                             message_v2 = curr_line-gjahr
                             message_v3 = curr_line-belnr ) TO return_tab.
            "Keine AnnAO auf der Datenbank.
            "Also Schleife verlassen.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

*"----------------------------------------------------------------------
      curr_line-msg = return_tab[].
    ENDIF.
  ENDIF.
*"----------------------------------------------------------------------
* Über AIF Customizing
*  COMMIT WORK AND WAIT.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
