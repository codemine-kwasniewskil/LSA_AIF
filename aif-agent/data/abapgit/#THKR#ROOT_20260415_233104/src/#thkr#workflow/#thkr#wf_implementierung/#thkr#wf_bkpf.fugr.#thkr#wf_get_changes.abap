FUNCTION /thkr/wf_get_changes.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_BUKRS) TYPE  BUKRS
*"     REFERENCE(IV_BELNR) TYPE  BELNR_D
*"     REFERENCE(IV_GJAHR) TYPE  GJAHR
*"  EXPORTING
*"     REFERENCE(ET_CHANGES) TYPE  /THKR/T_WF_CHANGEDATEN
*"----------------------------------------------------------------------

  " Konstanten
  CONSTANTS: lc_neu  TYPE char04 VALUE 'Neu:',
             lc_alt  TYPE char04 VALUE 'Alt:',
             lc_leer TYPE char10 VALUE '(leer)'.

  " Datendeklaration
  DATA: lt_cdata     TYPE /thkr/t_wf_changedaten,
        lt_bvt       TYPE fi_bvtyp_string,
        lt_field     TYPE dfies_table,
        lv_buzei     TYPE buzei,
        lv_anz       TYPE i,
        lv_value_alt TYPE char30,
        lv_value_neu TYPE char30,
        lt_fb02_text TYPE STANDARD TABLE OF /thkr/fb02c_text.



  " Ermittlung der Änderungsdaten aus der ZFI_FB02
  SELECT bukrs, lfdnr, belnr, gjahr, buzei, bktxt, xblnr, zterm, zfbdt, zlspr,
    zlsch_k, zbd1t, zbd1p, zbd2t, zbd2p, zbd3t, bvtyp, zuonr, sgtxt,
     mansp, madat, manst, mschl, maber, hbkid, zlsch_d
         INTO TABLE @DATA(lt_fb02)
         FROM /thkr/fb02c
         WHERE bukrs = @iv_bukrs
           AND belnr = @iv_belnr
           AND gjahr = @iv_gjahr.
  IF sy-subrc = 0.

    " Ermitteln relevanten Satz
    SORT lt_fb02 BY buzei lfdnr DESCENDING.
    DATA(lt_fb02_new) = lt_fb02[].
    FREE: lt_fb02, lv_buzei.
    " Filtern der relevanten Sätze
    LOOP AT lt_fb02_new ASSIGNING FIELD-SYMBOL(<ls_fb02>).
      " Nur immer den neusten Satz übernehmen
      IF lv_buzei IS INITIAL OR lv_buzei <> <ls_fb02>-buzei.
        APPEND <ls_fb02> TO lt_fb02.
      ENDIF.
      lv_buzei = <ls_fb02>-buzei.
    ENDLOOP.

    " Lesen der Belegdaten
    SELECT k~bktxt, k~xblnr,
           p~buzei, p~koart, p~zlspr, p~zlsch, p~mansp, p~manst, p~bvtyp, p~lifnr, p~empfb,
           p~zterm, p~zfbdt, p~zbd1t, p~zbd1p, p~zbd2t, p~zbd2p, p~zbd3t, p~sgtxt, p~zuonr,
           p~madat, p~mschl, p~maber, p~hbkid
           INTO TABLE @DATA(lt_beleg)
           FROM bkpf AS k
           INNER JOIN bseg AS p
           ON p~bukrs = k~bukrs
           AND p~belnr = k~belnr
           AND p~gjahr = k~gjahr
           FOR ALL ENTRIES IN @lt_fb02
           WHERE k~belnr = @lt_fb02-belnr
             AND k~bukrs = @lt_fb02-bukrs
             AND k~gjahr = @lt_fb02-gjahr.
*             AND p~buzei = @lt_fb02-buzei.
    IF sy-subrc = 0.

      " Aufbau der Tabelle der Änderungsdaten
      SORT lt_beleg BY buzei.
      LOOP AT lt_fb02 ASSIGNING <ls_fb02>.
          SELECT * FROM /thkr/fb02c_text
       INTO TABLE @lt_fb02_text
       WHERE bukrs = @iv_bukrs
           AND belnr = @iv_belnr
           AND gjahr = @iv_gjahr
           and lfdnr = @<ls_fb02>-lfdnr
      ORDER BY buzei ASCENDING.

        " Lesen zugehörige Belegdaten
        READ TABLE lt_beleg ASSIGNING FIELD-SYMBOL(<ls_beleg>) WITH KEY buzei = <ls_fb02>-buzei.
        IF <ls_beleg> IS NOT ASSIGNED.
          APPEND INITIAL LINE TO lt_beleg ASSIGNING <ls_beleg>.
          <ls_beleg>-buzei = <ls_fb02>-buzei.
        ENDIF.
        " Aufbau der Tabelle
        " Buchungszeile
        APPEND INITIAL LINE TO lt_cdata ASSIGNING FIELD-SYMBOL(<ls_cdata>).
        CONCATENATE 'Buchungszeile____________________:' <ls_fb02>-buzei INTO <ls_cdata> SEPARATED BY space.
        " Kopftext
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        IF <ls_beleg>-bktxt IS INITIAL. <ls_beleg>-bktxt = lc_leer. ENDIF.
        IF <ls_fb02>-bktxt IS INITIAL. <ls_fb02>-bktxt = lc_leer. ENDIF.
        CONCATENATE 'Belegkopftext____________________:' lc_alt <ls_beleg>-bktxt lc_neu <ls_fb02>-bktxt INTO <ls_cdata> SEPARATED BY space.
        "Referenz-Belegnummer
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        IF <ls_beleg>-xblnr IS INITIAL. <ls_beleg>-xblnr = lc_leer. ENDIF.
        IF <ls_fb02>-xblnr IS INITIAL. <ls_fb02>-xblnr = lc_leer. ENDIF.
        CONCATENATE 'Referenz-Belegnummer_____________:' lc_alt <ls_beleg>-xblnr lc_neu <ls_fb02>-xblnr INTO <ls_cdata> SEPARATED BY space.
        "BIS HIER HIN PASST ALLES
        "Zahlungsbedingungsschlüssel
        IF <ls_beleg>-zterm IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zterm. ENDIF.
        IF <ls_fb02>-zterm IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zterm. ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Zahlungsbedingungsschlüssel______:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
        "Basisdatum für Fälligkeitsberechnung
        IF <ls_beleg>-zfbdt IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zfbdt. ENDIF.
        IF <ls_fb02>-zfbdt IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zfbdt. ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Basisdatum für Fälligkeit________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

        " Zahlungssperre
        CLEAR: lv_value_alt, lv_value_neu.
        IF <ls_beleg>-zlspr IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zlspr. ENDIF.
        IF <ls_fb02>-zlspr IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zlspr. ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Schlüssel für Zahlungssperre_____:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

        "Tag 1:
        CLEAR: lv_value_alt, lv_value_neu.
        IF <ls_beleg>-zbd1t IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zbd1t. ENDIF.
        IF <ls_fb02>-zbd1t IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zbd1t. ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Tag 1____________________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
        "Prozent 1
        CLEAR: lv_value_alt, lv_value_neu.
        IF <ls_beleg>-zbd1p IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zbd1p. ENDIF.
        IF <ls_fb02>-zbd1p IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zbd1p. ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Prozent 1________________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
        "Tag 2:
        CLEAR: lv_value_alt, lv_value_neu.
        IF <ls_beleg>-zbd2t IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zbd2t. ENDIF.
        IF <ls_fb02>-zbd2t IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zbd2t. ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Tag 2____________________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

        "Prozent 2
        CLEAR: lv_value_alt, lv_value_neu.
        IF <ls_beleg>-zbd2p IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zbd2p. ENDIF.
        IF <ls_fb02>-zbd2p IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zbd2p. ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Prozent 2________________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

        "Tag 3
        CLEAR: lv_value_alt, lv_value_neu.
        IF <ls_beleg>-zbd3t IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zbd3t. ENDIF.
        IF <ls_fb02>-zbd3t IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zbd3t. ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Frist für Nettokondition_________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

        " Partnerbank
        " Ermitteln der IBAN zur Partnerbank
        IF <ls_beleg>-empfb IS INITIAL. DATA(lv_lifnr) = <ls_beleg>-lifnr. ELSE. lv_lifnr = <ls_beleg>-empfb. ENDIF.
        CALL FUNCTION 'FI_F4_BVTYP'
          EXPORTING
            i_lifnr        = lv_lifnr
            i_no_popup     = 'X'
          IMPORTING
            e_bvttab       = lt_bvt
            e_fieldtab     = lt_field
          EXCEPTIONS
            no_bvtyp_found = 1
            invalid_call   = 2
            OTHERS         = 3.
        IF sy-subrc = 0.
          " Ermitteln Position Patnerbanktyp und IBAN
          READ TABLE lt_field ASSIGNING FIELD-SYMBOL(<ls_field>) WITH KEY fieldname = 'BVTYP'.
          IF sy-subrc = 0.
            DATA(lv_fld_bvtyp) = sy-tabix.
            UNASSIGN <ls_field>.
            READ TABLE lt_field ASSIGNING <ls_field> WITH KEY fieldname = 'IBAN'.
            IF sy-subrc = 0. DATA(lv_fld_iban) = sy-tabix. ENDIF.
          ENDIF.
          IF lv_fld_bvtyp > 0 AND lv_fld_iban > 0.
            DO.
              READ TABLE lt_bvt ASSIGNING FIELD-SYMBOL(<ls_bvtyp>) INDEX lv_fld_bvtyp.
              IF sy-subrc = 0.
                IF <ls_bvtyp> = <ls_beleg>-bvtyp OR <ls_bvtyp> = <ls_fb02>-bvtyp.
                  " Lesen IBAN zum Parnerbanktyp
                  READ TABLE lt_bvt ASSIGNING FIELD-SYMBOL(<ls_iban>) INDEX lv_fld_iban.
                  IF sy-subrc = 0 AND <ls_bvtyp> = <ls_beleg>-bvtyp.
                    DATA(lv_iban_alt) = <ls_iban>.
                  ELSEIF sy-subrc = 0 AND <ls_bvtyp> = <ls_fb02>-bvtyp.
                    DATA(lv_iban_neu) = <ls_iban>.
                  ENDIF.
                ENDIF.
                " Nächster Partnerbanktyp
                ADD lv_fld_iban TO lv_fld_bvtyp.
                ADD lv_fld_iban TO lv_fld_iban.
              ELSE.
                EXIT.
              ENDIF.
            ENDDO.
            IF lv_iban_alt IS INITIAL AND <ls_beleg>-bvtyp IS INITIAL.
              lv_value_alt = lc_leer.
            ELSEIF lv_iban_alt IS INITIAL AND <ls_beleg>-bvtyp IS NOT INITIAL.
              lv_value_alt = <ls_beleg>-bvtyp.
            ELSE.
              CONCATENATE <ls_beleg>-bvtyp '(' lv_iban_alt ')' INTO lv_value_alt.
            ENDIF.
            IF lv_iban_neu IS INITIAL.
              lv_value_neu = lc_leer.
            ELSE.
              CONCATENATE <ls_fb02>-bvtyp '(' lv_iban_neu ')' INTO lv_value_neu.
            ENDIF.
          ELSE.
            IF <ls_beleg>-bvtyp IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-bvtyp. ENDIF.
            IF <ls_fb02>-bvtyp IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-bvtyp. ENDIF.
          ENDIF.
        ELSE.
          IF <ls_beleg>-bvtyp IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-bvtyp. ENDIF.
          IF <ls_fb02>-bvtyp IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-bvtyp. ENDIF.
        ENDIF.
        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        CONCATENATE 'Partnerbank______________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

        IF <ls_beleg>-koart = 'K'.    "kreditorisch

          " Zahlweg
          IF <ls_beleg>-zlsch IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zlsch. ENDIF.
          IF <ls_fb02>-zlsch_k IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zlsch_k. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE 'Zahlweg Kreditor_________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

        ELSEIF <ls_beleg>-koart = 'D'.     "debitorisch
          " Mahnsperre
          CLEAR: lv_value_alt, lv_value_neu.
          IF <ls_beleg>-mansp IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-mansp. ENDIF.
          IF <ls_fb02>-mansp IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-mansp. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE 'Mahnsperre_______________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
          " Datum der letzten Mahnung
          CLEAR: lv_value_alt, lv_value_neu.
          IF <ls_beleg>-madat IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-madat. ENDIF.
          IF <ls_fb02>-madat IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-madat. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE 'Datum der letzten Mahnung________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
          " Mahnstufe
          CLEAR: lv_value_alt, lv_value_neu.
          IF <ls_beleg>-manst IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-manst. ENDIF.
          IF <ls_fb02>-manst IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-manst. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE 'Mahnstufe________________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
          "Mahnschlüssel
          CLEAR: lv_value_alt, lv_value_neu.
          IF <ls_beleg>-mschl IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-mschl. ENDIF.
          IF <ls_fb02>-mschl IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-mschl. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE 'Mahnschlüssel____________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
          "Mahnbereich
          CLEAR: lv_value_alt, lv_value_neu.
          IF <ls_beleg>-maber IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-maber. ENDIF.
          IF <ls_fb02>-maber IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-maber. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE 'Mahnbereich______________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
          "Hausbank
*          CLEAR: lv_value_alt, lv_value_neu.
*          IF <ls_beleg>-hbkid IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-hbkid. ENDIF.
*          IF <ls_fb02>-hbkid IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-hbkid. ENDIF.
*          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
*          CONCATENATE 'Hausbank_________________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

          " Zahlweg
          CLEAR: lv_value_alt, lv_value_neu.
          IF <ls_beleg>-zlsch IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <ls_beleg>-zlsch. ENDIF.
          IF <ls_fb02>-zlsch_d IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <ls_fb02>-zlsch_d. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE 'Zahlweg Debitor__________________:' lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
        ENDIF.
*        " Kommentarzeilen
*        IF <ls_fb02>-zz_k1 IS INITIAL. <ls_fb02>-zz_k1 = lc_leer. ENDIF.
*        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
*        CONCATENATE 'Kommentarzeile 1_________________:' <ls_fb02>-zz_k1 INTO <ls_cdata> SEPARATED BY space.
*        IF <ls_fb02>-zz_k2 IS INITIAL. <ls_fb02>-zz_k2 = lc_leer. ENDIF.
*        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
*        CONCATENATE 'Kommentarzeile 2_________________:' <ls_fb02>-zz_k2 INTO <ls_cdata> SEPARATED BY space.
*        IF <ls_fb02>-zz_k3 IS INITIAL. <ls_fb02>-zz_k3 = lc_leer. ENDIF.
*        APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
*        CONCATENATE 'Kommentarzeile 3_________________:' <ls_fb02>-zz_k3 INTO <ls_cdata> SEPARATED BY space.

      ENDLOOP.
    ENDIF.
  ELSE.
    FREE: lt_fb02, lt_fb02_new.
  ENDIF.

  APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
        Move 'Positionstexte und Zuordnungen:' to <ls_cdata>.

         Loop at lt_fb02_text ASSIGNING FIELD-SYMBOL(<fs_text>).
           READ TABLE lt_beleg with key buzei = <fs_text>-buzei ASSIGNING FIELD-SYMBOL(<fs_beleg>).
            if sy-subrc  = 0.
           DATA(lv_string) = |Position { <fs_text>-buzei }_____________________:|.
           CLEAR: lv_value_alt, lv_value_neu.
          IF <fs_beleg>-sgtxt IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <fs_beleg>-sgtxt. ENDIF.
          IF <fs_text>-sgtxt IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <fs_text>-sgtxt. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE lv_string lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.

           lv_string = |Zuordnung { <fs_text>-buzei }____________________:|.
           CLEAR: lv_value_alt, lv_value_neu.
          IF <fs_beleg>-zuonr IS INITIAL. lv_value_alt = lc_leer. ELSE. lv_value_alt = <fs_beleg>-zuonr. ENDIF.
          IF <fs_text>-zuonr IS INITIAL. lv_value_neu = lc_leer. ELSE. lv_value_neu = <fs_text>-zuonr. ENDIF.
          APPEND INITIAL LINE TO lt_cdata ASSIGNING <ls_cdata>.
          CONCATENATE lv_string lc_alt lv_value_alt lc_neu lv_value_neu INTO <ls_cdata> SEPARATED BY space.
          ENDIF.
           ENDLOOP.


  " Übergabe der aufbereiteten Änderungen
  et_changes[] = lt_cdata[].




ENDFUNCTION.
