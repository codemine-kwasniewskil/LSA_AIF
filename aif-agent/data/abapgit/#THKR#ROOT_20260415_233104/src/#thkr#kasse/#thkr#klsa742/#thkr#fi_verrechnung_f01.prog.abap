*&---------------------------------------------------------------------*
*& Include /THKR/FI_VERRECHNUNG_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
************************************************************************
* Routinen                                                  *
************************************************************************
*&---------------------------------------------------------------------*
*& Form CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_authority .
* siehe Include .... F124_MERGE (Ausgleichprogramm)
* dort Buchungskreis und Kontoart hier nur Buchungskreis
*
  DATA: ls_bukrs     TYPE ty_bukrs,
        l_auth_activ TYPE fm_authact.
  IF p_list  EQ gc_on.
    l_auth_activ = c_auth_activ_03.
  ENDIF.
  IF p_buch  EQ gc_on.
    l_auth_activ = c_auth_activ_10.
  ENDIF.

  SELECT bukrs FROM t001 INTO TABLE @gt_bukrs
    WHERE bukrs IN @s_bukrs.
  SORT gt_bukrs.
  LOOP AT gt_bukrs INTO ls_bukrs.
* Company Code-Beleg:
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'ACTVT' FIELD l_auth_activ
     ID 'BUKRS' FIELD ls_bukrs-bukrs.
    IF sy-subrc NE 0 .
      DELETE gt_bukrs.
      MESSAGE w107 WITH ls_bukrs-bukrs.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form AUSAO_LESEN
*&---------------------------------------------------------------------*
*& ermittelt die AuszahlungsAO und stellt diese in gt_beleg
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ausao_lesen .

  DATA: lv_augbl_init TYPE augbl,
        lv_stblg_init TYPE stblg.


  DATA: ls_beleg TYPE ty_beleg.
  DATA: lv_number TYPE i,
        lv_ref    TYPE xblnr.

  DATA: ls_xblnr TYPE ty_xblnr,
        ls_lifnr TYPE ty_lifnr.
  CLEAR: lv_augbl_init,
         lv_stblg_init.


  IF gt_bukrs[] IS NOT INITIAL.
    SELECT
             kopf~bukrs,
             kopf~belnr,
             kopf~gjahr,
             kopf~blart,
             kopf~bldat,
             kopf~budat,
             kopf~cpudt,
             kopf~cputm,
*          kopf~bvorg "selten gefüllt
             kopf~xblnr,
*           kopf~stblg
             kopf~bktxt,
             kopf~waers,
             kopf~hwaer,
             op~lifnr,
             op~augdt,
             op~augbl,
             op~buzei,
             op~shkzg,
             op~wrbtr,
             op~dmbtr,
             op~zfbdt,
             op~zterm,
             op~zlsch,
             op~zlspr,
             op~rebzg,
             op~rebzj,
             op~rebzz

       FROM bsik_view AS op
       INNER JOIN bkpf AS kopf
       ON
          op~bukrs =  kopf~bukrs
            AND  op~belnr = kopf~belnr
             AND op~gjahr = kopf~gjahr
      FOR ALL ENTRIES IN @gt_bukrs
*    where op~bukrs in @s_bukrs
       WHERE op~bukrs = @gt_bukrs-bukrs
        AND op~lifnr IN @s_lifnr
        AND op~gjahr IN @s_gjahr
*Repro_ROC20210108      and op~belnr in @s_belnr
        AND op~budat IN @s_budat
        AND op~cpudt IN @s_cpudt  " wird geändert mit Buchung !
        AND op~xblnr IN @s_xblnr "Repro_ROC20210108
        AND op~zlsch = @p_zlsch
*      and op~zlspr = @gc_init_zlspr "REPRO-ROC
*   hier auch nur echte AuszahlungsAO nehmen
*      and kopf~psoty = gc_psoty_01
       AND  kopf~bstat = @gc_off " nur gebuchte
       AND  kopf~stblg IS INITIAL    "REPRO-ROC
           INTO CORRESPONDING FIELDS OF TABLE @gt_beleg.
  ENDIF.
* erfasst = cpudt ist das Datum an dem nach Freigabe - Buchen gewählt wird

* das Referenzkassenzeichen aus der Annahme
* steht im Kopftext (Konzeptversion LSA) "geä. js

  LOOP AT gt_beleg INTO ls_beleg WHERE bktxt IS NOT INITIAL. "geä. js
     condense ls_beleg-bktxt no-gaps. "geä. js
     ls_beleg-xblnr_ann = ls_beleg-bktxt. "geä. js
     modify gt_beleg from ls_beleg transporting xblnr_ann . "geä. js
     ls_xblnr-xblnr = ls_beleg-xblnr_ann. "geä. js
*   ls_xblnr-xblnr = ls_beleg-xblnr. "geä. js
    COLLECT ls_xblnr INTO gt_xblnr.
    MOVE-CORRESPONDING  ls_beleg TO  ls_lifnr.
    COLLECT ls_lifnr INTO gt_lifnr.
  ENDLOOP.
* Tabelle mit den Referenzen: gt_xblnr
ENDFORM.
*
*&---------------------------------------------------------------------*
*& Form ANN_LESEN
*&---------------------------------------------------------------------*
*& liest die Annahmeanordnungen
*& hier allerdings keine
*& * brauchen nciht prüfen, dass der Beleg in einem Zahllauf steckt,
*&  da der Zahlweg I nicht in den Zahllauf geht
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ann_lesen .
* die sind erst einmal vorhanden
* brauchen anschließend die Daten aus BSID
* hier kann auch so einiges verloren gehen, ggf R

  DATA: lv_augbl_init TYPE augbl,
        lv_stblg_init TYPE stblg.
  CLEAR: lv_augbl_init.
  DATA: ls_beleg    TYPE ty_beleg,
        ls_beleg_az TYPE ty_beleg,
        lv_number   TYPE i,
        lv_ref      TYPE xblnr,
        ls_head     TYPE /thkr/fi_verr_head,
        ls_kunnr    TYPE ty_kunnr.

  DATA: BEGIN OF ls_message,
          xblnr    TYPE xblnr,
          messages TYPE STANDARD TABLE OF ty_msg.
  DATA: END OF ls_message.
  DATA: ls_mess TYPE ty_msg .

  DATA: l_auth_activ TYPE fm_authact .

  IF p_list  EQ gc_on.
    l_auth_activ = c_auth_activ_03.
  ENDIF.
  IF p_buch  EQ gc_on.
    l_auth_activ = c_auth_activ_10.
  ENDIF.


  IF gt_xblnr[] IS NOT INITIAL.
    SELECT
            kopf~bukrs
            kopf~belnr
            kopf~gjahr
            kopf~blart
            kopf~bldat
            kopf~budat
            kopf~cpudt
            kopf~cputm
            kopf~bvorg
            kopf~xblnr
            kopf~stblg
            kopf~bktxt
            kopf~waers
            kopf~hwaer
            op~kunnr
            op~augdt
            op~augbl
            op~buzei
            op~shkzg
            op~wrbtr
            op~dmbtr
            op~zfbdt
            op~zterm
            op~zlsch
            op~rebzg
            op~rebzj
            op~rebzz
      FROM bsid AS op
      INNER JOIN bkpf AS kopf
      ON
            op~bukrs =  kopf~bukrs
           AND  op~belnr = kopf~belnr
            AND op~gjahr = kopf~gjahr
     INTO CORRESPONDING FIELDS OF TABLE gt_beleg_ann
      FOR ALL ENTRIES IN gt_xblnr
     WHERE kopf~xblnr = gt_xblnr-xblnr
*   keine Stornos - obwohl diese ja zu einem Ausgleich führen
      AND  kopf~stblg = lv_stblg_init  "001
      AND  kopf~bstat = gc_off. " nur gebuchte

  ENDIF.

  SORT gt_beleg_ann BY xblnr cpudt cputm .

  LOOP AT gt_beleg_ann INTO ls_beleg .
*&---------------------------------------------------------------------*
* für beide Belegarten (AnnAO unnd AusAO) wird ein Schlüsselfeld benötigt
* zur Verbindung von Kopf und Beleg benötigt
*&---------------------------------------------------------------------*
*    ls_beleg-xblnr_ann = ls_beleg-xblnr.
*    modify gt_beleg_ann from ls_beleg transporting xblnr_ann.
*&---------------------------------------------------------------------*
* Referenztabelle
*&---------------------------------------------------------------------*
    ls_head-xblnr = ls_beleg-xblnr.
    COLLECT ls_head INTO gt_head.
  ENDLOOP.

* Tabelle mit den Referenzen: gt_xblnr


  LOOP AT gt_head INTO ls_head.
    CLEAR lv_number.
*   LOOP AT gt_beleg INTO ls_beleg_az WHERE xblnr = ls_head-xblnr .	"geä. js
    LOOP AT gt_beleg INTO ls_beleg_az WHERE xblnr_ann = ls_head-xblnr .	"geä. js
      lv_number = lv_number + 1.
    ENDLOOP.
    CLEAR ls_message-messages[].
*&---------------------------------------------------------------------*
* Fehler : AuszahlungsAO nicht eindeutig
*&---------------------------------------------------------------------*
    IF  lv_number NE 1.
      CLEAR ls_mess.
      ls_mess-msgid  = gc_arbgb.
      ls_mess-msgno =  '102'.
      ls_mess-msgty = gc_char_e.
      ls_mess-msgv1 = ls_head-xblnr.
      CALL FUNCTION 'K_MESSAGE_TRANSFORM'
        EXPORTING
          par_msgid         = ls_mess-msgid
          par_msgno         = ls_mess-msgno
          par_msgty         = ls_mess-msgty
          par_msgv1         = ls_mess-msgv1
        IMPORTING
          par_msgtx         = ls_mess-msgtx
        EXCEPTIONS
          no_message_found  = 1
          par_msgid_missing = 2
          par_msgno_missing = 3
          par_msgty_missing = 4
          OTHERS            = 5.
      IF sy-subrc <> 0.
        ls_mess-msgtx = TEXT-e10.
      ENDIF.
      APPEND ls_mess TO ls_message-messages.
      ls_message-xblnr = ls_head-xblnr.
      APPEND ls_message TO gt_messages.
      ls_head-fehler = gc_on.
      MODIFY gt_head FROM ls_head TRANSPORTING fehler.
      IF 1 = 2.
        MESSAGE e102(z_fi_nachr).
      ENDIF.

    ELSE.
*&---------------------------------------------------------------------*
* Fehler : Zahlsperre als Fehler - Änderung 001
*&---------------------------------------------------------------------*
      IF  ls_beleg_az-zlspr NE gc_init_zlspr. "
        CLEAR ls_mess.
        ls_mess-msgid  = gc_arbgb.
        ls_mess-msgno =  '106'.
        ls_mess-msgty = gc_char_e.
        CALL FUNCTION 'K_MESSAGE_TRANSFORM'
          EXPORTING
            par_msgid         = ls_mess-msgid
            par_msgno         = ls_mess-msgno
            par_msgty         = ls_mess-msgty
            par_msgv1         = ls_mess-msgv1
            par_msgv2         = ls_mess-msgv2
          IMPORTING
            par_msgtx         = ls_mess-msgtx
          EXCEPTIONS
            no_message_found  = 1
            par_msgid_missing = 2
            par_msgno_missing = 3
            par_msgty_missing = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          ls_mess-msgtx = TEXT-e10.
        ENDIF.
        APPEND ls_mess TO ls_message-messages.
        ls_message-xblnr = ls_head-xblnr.
        APPEND ls_message TO gt_messages.
        ls_head-fehler = gc_on.
        MODIFY gt_head FROM ls_head TRANSPORTING fehler.
        IF 1 = 2.
          MESSAGE e106(z_fi_nachr).
        ENDIF.
      ENDIF.
      CLEAR lv_number.

*&---------------------------------------------------------------------*
*hier werden alle anderen Fälle gelöscht
*
*&---------------------------------------------------------------------*
      LOOP AT gt_beleg_ann TRANSPORTING NO FIELDS  WHERE xblnr = ls_head-xblnr
                             AND  dmbtr NE  ls_beleg_az-dmbtr.
        DELETE gt_beleg_ann.
      ENDLOOP.
*      loop at gt_beleg_ann transporting no fields where xblnr = ls_head-xblnr .
*&---------------------------------------------------------------------*
* Suchen eine Annahme-Anordnung mit dem gleichen Betrag
*&---------------------------------------------------------------------*
      LOOP AT gt_beleg_ann INTO ls_beleg WHERE xblnr = ls_head-xblnr
                             AND  dmbtr =  ls_beleg_az-dmbtr.
*&---------------------------------------------------------------------*
* Frage: muss hier noch das ls_beleg_az-gjahr (Fortschreibung nach budat)
* gegen das Fälligkeitsdatum  der AnnahmeAO geprüft werden?
*&---------------------------------------------------------------------*
        lv_number = lv_number + 1.
*&---------------------------------------------------------------------*
*   Kundentabelle
*&---------------------------------------------------------------------*
        MOVE-CORRESPONDING  ls_beleg TO  ls_kunnr.
        COLLECT ls_kunnr INTO gt_kunnr.
      ENDLOOP.
*&---------------------------------------------------------------------*
* Fehler : keine Ann.AO
*&---------------------------------------------------------------------*
      IF  sy-subrc NE 0.
        CLEAR ls_mess.
        ls_mess-msgid  = gc_arbgb.
        ls_mess-msgno =  '103'.
        ls_mess-msgty = gc_char_e.
        ls_mess-msgv1 = ls_head-xblnr.
        WRITE ls_beleg_az-dmbtr TO ls_mess-msgv2.
        CALL FUNCTION 'K_MESSAGE_TRANSFORM'
          EXPORTING
            par_msgid         = ls_mess-msgid
            par_msgno         = ls_mess-msgno
            par_msgty         = ls_mess-msgty
            par_msgv1         = ls_mess-msgv1
            par_msgv2         = ls_mess-msgv2
          IMPORTING
            par_msgtx         = ls_mess-msgtx
          EXCEPTIONS
            no_message_found  = 1
            par_msgid_missing = 2
            par_msgno_missing = 3
            par_msgty_missing = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          ls_mess-msgtx = TEXT-e10.
        ENDIF.
        APPEND ls_mess TO ls_message-messages.
        ls_message-xblnr = ls_head-xblnr.
        APPEND ls_message TO gt_messages.
        ls_head-fehler = gc_on.
        MODIFY gt_head FROM ls_head TRANSPORTING fehler.
        IF 1 = 2.
          MESSAGE e103(z_fi_nachr).
        ENDIF.
      ELSE.
*&---------------------------------------------------------------------*
* Fehler : AnnAO nicht eindeutig
*&---------------------------------------------------------------------*
        IF  lv_number NE 1.
          CLEAR ls_mess.
          ls_mess-msgid  = gc_arbgb.
          ls_mess-msgno =  '102'.
          ls_mess-msgty = gc_char_e.
          ls_mess-msgv1 = ls_head-xblnr.
          CALL FUNCTION 'K_MESSAGE_TRANSFORM'
            EXPORTING
              par_msgid         = ls_mess-msgid
              par_msgno         = ls_mess-msgno
              par_msgty         = ls_mess-msgty
              par_msgv1         = ls_mess-msgv1
            IMPORTING
              par_msgtx         = ls_mess-msgtx
            EXCEPTIONS
              no_message_found  = 1
              par_msgid_missing = 2
              par_msgno_missing = 3
              par_msgty_missing = 4
              OTHERS            = 5.
          IF sy-subrc <> 0.
            ls_mess-msgtx = TEXT-e10.
          ENDIF.
          APPEND ls_mess TO ls_message-messages.
          ls_message-xblnr = ls_head-xblnr.
          APPEND ls_message TO gt_messages.
          IF 1 = 2.
            MESSAGE e102(z_fi_nachr).
          ENDIF.
          ls_head-fehler = gc_on.
          MODIFY gt_head FROM ls_head TRANSPORTING fehler.
        ENDIF.
*&---------------------------------------------------------------------*
* Berechtigung: Prüfung Buchungskreis Ann-AO
*&---------------------------------------------------------------------*
        IF  lv_number = 1.

          AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
          ID 'ACTVT' FIELD l_auth_activ
          ID 'BUKRS' FIELD ls_beleg-bukrs.

          IF sy-subrc NE 0 .
            CLEAR ls_mess.
            ls_mess-msgid  = gc_arbgb.
            ls_mess-msgno =  '108'.
            ls_mess-msgty = gc_char_e.
            ls_mess-msgv1 = ls_head-xblnr.
            ls_mess-msgv2 = ls_beleg-bukrs.
            CALL FUNCTION 'K_MESSAGE_TRANSFORM'
              EXPORTING
                par_msgid         = ls_mess-msgid
                par_msgno         = ls_mess-msgno
                par_msgty         = ls_mess-msgty
                par_msgv1         = ls_mess-msgv1
                par_msgv2         = ls_mess-msgv2
              IMPORTING
                par_msgtx         = ls_mess-msgtx
              EXCEPTIONS
                no_message_found  = 1
                par_msgid_missing = 2
                par_msgno_missing = 3
                par_msgty_missing = 4
                OTHERS            = 5.
            IF sy-subrc <> 0.
              ls_mess-msgtx = TEXT-e10.
            ENDIF.
            APPEND ls_mess TO ls_message-messages.
            ls_message-xblnr = ls_head-xblnr.
            APPEND ls_message TO gt_messages.
            IF 1 = 2.
              MESSAGE e108(z_fi_nachr).
            ENDIF.
            ls_head-fehler = gc_on.
            MODIFY gt_head FROM ls_head TRANSPORTING fehler.
          ENDIF. "Berechtigungsfehler

        ENDIF. "lv_number = 1
      ENDIF.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADRS_GET_KNA1
*&---------------------------------------------------------------------*
*& ermittelt die Kurz-Adresse für lifnr or kunnr
*& macht daraus ADDR_SHORT in der gt_kunnr und der gt_lifnr
*& Die Adresse wird nicht weiter verwendet, dient nur der Info
*& hier alles nur für Inland - da Verrechnung
*& hier könnte noch andere Aufbereitungen geben
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM adrs_get_kna1 .
  TYPES: BEGIN OF lty_kna1,

           kunnr      TYPE kna1-kunnr,
           land1      TYPE  kna1-land1,
           name1      TYPE  kna1-name1,
           name2      TYPE  kna1-name2,
           ort01      TYPE  kna1-ort01,
           pstlz      TYPE  kna1-pstlz,
           regio      TYPE  kna1-regio,
           stras      TYPE  kna1-stras,
           xcpdk      TYPE  kna1-xcpdk, "001 CPD_Adresse
           pfach      TYPE  kna1-pfach,
           pfort      TYPE  kna1-pfort,
           pstl2      TYPE  kna1-pstl2,
           addr_short TYPE ad_line_s.
  TYPES: END OF lty_kna1.
  DATA: lt_kna1 TYPE STANDARD TABLE OF lty_kna1.
  DATA: ls_kna1 TYPE lty_kna1.
  DATA: ls_kunnr TYPE ty_kunnr.
  DATA: ls_beleg_ann    TYPE ty_beleg.

  IF gt_kunnr[] IS NOT INITIAL.
    SELECT kunnr
           land1
           name1
           name2
           ort01
           pstlz
           regio
           stras
           xcpdk
           pfach
           pfort
           pstl2
         FROM kna1 INTO CORRESPONDING FIELDS OF TABLE lt_kna1
          FOR ALL ENTRIES IN gt_kunnr  WHERE kunnr  = gt_kunnr-kunnr.


  ENDIF.
*&---------------------------------------------------------------------*
* Trennung in Nicht - CPD-Adressen
*&---------------------------------------------------------------------*
  LOOP AT lt_kna1 INTO ls_kna1 WHERE   xcpdk = gc_off.

    CLEAR adrs.
    adrs-name1 = ls_kna1-name1.
    adrs-name2 = ls_kna1-name2.
    adrs-stras = ls_kna1-stras .
    adrs-pfach = ls_kna1-pfach .
    adrs-pstl2 = ls_kna1-pstl2.
    adrs-land1 = ls_kna1-land1 .
    adrs-pstlz = ls_kna1-pstlz .
    adrs-pfort = ls_kna1-pfort .
    adrs-ort01 = ls_kna1-ort01 .
    adrs-pstl2 = ls_kna1-pstl2 .
    adrs-regio = ls_kna1-regio.
    adrs-inlnd = 'DE' .  "t001-land1'.
    adrs-anzzl = 2.

    CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
      EXPORTING
        adrswa_in            = adrs
      IMPORTING
        adrswa_out           = adrs
        address_short_form_s = ls_kna1-addr_short.

    MODIFY lt_kna1 FROM ls_kna1 TRANSPORTING addr_short.
    LOOP AT gt_kunnr INTO ls_kunnr WHERE kunnr = ls_kna1-kunnr.
      ls_kunnr-addr_short = ls_kna1-addr_short.
      MODIFY gt_kunnr FROM ls_kunnr TRANSPORTING addr_short.
    ENDLOOP.
  ENDLOOP.
*&---------------------------------------------------------------------*
* Trennung  CPD-Adressen
*&---------------------------------------------------------------------*
  LOOP AT lt_kna1 INTO ls_kna1 WHERE   xcpdk = gc_on.
    LOOP AT gt_kunnr INTO ls_kunnr WHERE kunnr = ls_kna1-kunnr.
      LOOP AT gt_beleg_ann INTO ls_beleg_ann WHERE bukrs = ls_kunnr-bukrs
                           AND   xblnr = ls_kunnr-xblnr
                           AND   kunnr = ls_kunnr-kunnr.
        CLEAR adrs.
        SELECT SINGLE
               name1
               name2
               ort01
               pstlz
               regio
               stras
               pfach
*           pfort
               pstl2
             FROM bsec INTO CORRESPONDING FIELDS OF adrs
             WHERE bukrs = ls_beleg_ann-bukrs
              AND belnr = ls_beleg_ann-belnr
              AND gjahr = ls_beleg_ann-gjahr
              AND buzei = ls_beleg_ann-buzei.


        adrs-pfort = adrs-ort01. "pfort nicht in bsec
        adrs-inlnd = 'DE' .  "t001-land1'.
        adrs-anzzl = 2.

        CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
          EXPORTING
            adrswa_in            = adrs
          IMPORTING
            adrswa_out           = adrs
            address_short_form_s = ls_kunnr-addr_short.

        EXIT.
      ENDLOOP.
      MODIFY gt_kunnr FROM ls_kunnr TRANSPORTING addr_short.
    ENDLOOP.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form ADRS_GET_LFA1
*&---------------------------------------------------------------------*
*& ermittelt die Kurz-Adresse für lifnr or kunnr
*& macht daraus ADDR_SHORT in der gt_kunnr und der gt_lifnr
*& Die Adresse wird nicht weiter verwendet, dient nur der Info
*& hier alles nur für Inland - da Verrechnung
*& hier könnte noch andere Aufbereitungen geben
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM adrs_get_lfa1 .
  TYPES: BEGIN OF lty_lfa1,

           lifnr      TYPE lfa1-lifnr,
           land1      TYPE  lfa1-land1,
           name1      TYPE  lfa1-name1,
           name2      TYPE  lfa1-name2,
           ort01      TYPE  lfa1-ort01,
           pstlz      TYPE  lfa1-pstlz,
           regio      TYPE  lfa1-regio,
           stras      TYPE  lfa1-stras,
           xcpdk      TYPE  lfa1-xcpdk,
           pfach      TYPE  lfa1-pfach,
           pfort      TYPE  lfa1-pfort,
           pstl2      TYPE  lfa1-pstl2,
           addr_short TYPE ad_line_s.
  TYPES: END OF lty_lfa1.
  DATA: lt_lfa1 TYPE STANDARD TABLE OF lty_lfa1.
  DATA: ls_lfa1 TYPE lty_lfa1.
  DATA: ls_lifnr TYPE ty_lifnr,
        ls_beleg TYPE ty_beleg.


  IF gt_lifnr[] IS NOT INITIAL.
    SELECT lifnr
           land1
           name1
           name2
           ort01
           pstlz
           regio
           stras
           xcpdk
           pfach
           pfort
           pstl2
         FROM lfa1 INTO CORRESPONDING FIELDS OF TABLE lt_lfa1
          FOR ALL ENTRIES IN gt_lifnr  WHERE lifnr  = gt_lifnr-lifnr.


  ENDIF.

  LOOP AT lt_lfa1 INTO ls_lfa1 WHERE   xcpdk = gc_off.


    CLEAR adrs.
    adrs-name1 = ls_lfa1-name1.
    adrs-name2 = ls_lfa1-name2.
    adrs-stras = ls_lfa1-stras .
    adrs-pfach = ls_lfa1-pfach .
    adrs-pstl2 = ls_lfa1-pstl2.
    adrs-land1 = ls_lfa1-land1 .
    adrs-pstlz = ls_lfa1-pstlz .
    adrs-pfort = ls_lfa1-pfort .
    adrs-ort01 = ls_lfa1-ort01 .
    adrs-pstl2 = ls_lfa1-pstl2 .
    adrs-regio = ls_lfa1-regio.
    adrs-inlnd = 'DE' .  "t001-land1'.
    adrs-anzzl = 2.
    CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
      EXPORTING
        adrswa_in            = adrs
      IMPORTING
        adrswa_out           = adrs
        address_short_form_s = ls_lfa1-addr_short.

    MODIFY lt_lfa1 FROM ls_lfa1 TRANSPORTING addr_short.
    LOOP AT gt_lifnr INTO ls_lifnr WHERE lifnr = ls_lfa1-lifnr.
      ls_lifnr-addr_short = ls_lfa1-addr_short.
      MODIFY gt_lifnr FROM ls_lifnr TRANSPORTING addr_short.
    ENDLOOP.
  ENDLOOP.
*&---------------------------------------------------------------------*
* Trennung  CPD-Adressen
*&---------------------------------------------------------------------*
  LOOP AT lt_lfa1 INTO ls_lfa1 WHERE  xcpdk = gc_on.

    LOOP AT gt_lifnr INTO ls_lifnr WHERE lifnr = ls_lfa1-lifnr.

      LOOP AT gt_beleg INTO ls_beleg  WHERE bukrs = ls_lifnr-bukrs
*                           and   xblnr_ann = ls_lifnr-xblnr_ann
                           AND   xblnr = ls_lifnr-xblnr
                           AND   lifnr = ls_lifnr-lifnr.
        CLEAR adrs.
        SELECT SINGLE
               name1
               name2
               ort01
               pstlz
               regio
               stras
               pfach
*           pfort
               pstl2
             FROM bsec INTO CORRESPONDING FIELDS OF adrs
             WHERE bukrs = ls_beleg-bukrs
              AND belnr = ls_beleg-belnr
              AND gjahr = ls_beleg-gjahr
              AND buzei = ls_beleg-buzei.


        adrs-pfort = adrs-ort01. "pfort nicht in bsec
        adrs-inlnd = 'DE' .  "t001-land1'.
        adrs-anzzl = 2.

        CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
          EXPORTING
            adrswa_in            = adrs
          IMPORTING
            adrswa_out           = adrs
            address_short_form_s = ls_lifnr-addr_short.

        EXIT.
      ENDLOOP.
      MODIFY gt_lifnr FROM ls_lifnr TRANSPORTING addr_short.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*--------------------------------------------------------------------------------
*
* in Anlehnung an top_of_page_132(RFZ30FOR)
*--------------------------------------------------------------------------------
FORM top_of_page.                                           "#EC CALLED

  DATA: lc_laufd(10) TYPE c,
        lc_text(100) TYPE c,
        lc_title1    LIKE rfpdo-allgline.
  .

  DATA: li_len  TYPE i,
        li_len2 TYPE i,
        li_len3 TYPE i,
        li_pos  TYPE i,
        li_pos2 TYPE i,
        li_pos3 TYPE i.
*        li_pos4 TYPE i.
  DATA: l_time TYPE i.

*-----------------------------------------------------
* fill the central title lines
*-----------------------------------------------------
  IF p_list EQ gc_on.
    lc_text = TEXT-l10.
  ELSEIF p_buch EQ gc_on.
    IF p_test EQ gc_on.
      lc_text = TEXT-l30.
    ELSE.
      lc_text = TEXT-l20.
    ENDIF.
  ENDIF.

*hier
*  lc_title2 = p_title2.

  FORMAT INTENSIFIED ON.

* calculate output positions
  PERFORM output_length USING TEXT-l04 li_len.
  PERFORM output_length USING TEXT-l05 li_len2.
  IF li_len2 < li_len.
    li_len2 = li_len.
  ENDIF.
  PERFORM output_length USING TEXT-l06 li_len.
  IF li_len2 < li_len.
    li_len2 = li_len.
  ENDIF.                        " li_len2 = maxlen( text-004, 005, 006)

  li_len3 = strlen( sy-uname ).
  IF li_len3 LT 10.                    " username shorter than date
    li_len3 = 10.
  ENDIF.

  li_pos2 = 126 - li_len3 - li_len2.   " position for text-004, 005, 006
  li_pos3 = 130 - li_len3.             " position for name, date, time

*  if gx_noexpa eq 'X'." Hier kürzer gemacht
  li_pos2 = li_pos2 - 10. "???
  li_pos3 = li_pos3 - 10. "???
*  endif.

  PERFORM output_length USING lc_text li_len.
  li_pos  = 60 - ( li_len / 2 ).

***  PERFORM output_length USING lc_title2 li_len.
***  li_pos4 = 60 - ( li_len / 2 ).


  WRITE AT li_pos(75) lc_text .
  WRITE: AT li_pos2 sy-datum DD/MM/YYYY, '/ '.

  l_time = li_pos3 - li_pos2.
  IF l_time < 12 .
    l_time = li_pos2 + 13.
    WRITE AT l_time(li_len3) sy-uzeit.
  ELSE.
    WRITE AT li_pos3(li_len3) sy-uzeit.
  ENDIF.
  NEW-LINE.

* second line
  lc_title1 = sy-title.
  IF lc_title1 NE space.
    PERFORM output_length USING lc_title1 li_pos.
    li_pos = 60 - li_pos / 2.
    WRITE AT li_pos lc_title1.
  ENDIF.
  WRITE AT li_pos2(li_len2) TEXT-l04.
  WRITE AT li_pos3(li_len3) sy-uname.
  NEW-LINE.

* third line.

  WRITE: AT 1(*) TEXT-l51, sy-mandt.
  WRITE: AT li_pos2 TEXT-l50, AT li_pos3 sy-pagno LEFT-JUSTIFIED.
* lc_t
*  WRITE AT li_pos4 lc_title2.


ENDFORM.                    "top_of_page
*---------------------------------------------------------------------*
*       FORM OUTPUT_LENGTH                                            *
*---------------------------------------------------------------------*
*       Get output length of texts from textpool                      *
*       Get correct values for double-byte characters also            *
*---------------------------------------------------------------------*
*  -->  P_TEXT                                                        *
*  <--  P_LENGTH                                                      *
*---------------------------------------------------------------------*
FORM output_length USING p_text p_length.

  CALL METHOD cl_abap_list_utilities=>dynamic_output_length
    EXPORTING
      field = p_text
    RECEIVING
      len   = p_length.

ENDFORM.                    "output_length
*---------------------------------------------------------------------*
*       FORM after_line_output                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  rs_lineinfo                                                   *
*---------------------------------------------------------------------*
FORM after_line_output USING rs_lineinfo TYPE slis_lineinfo. "#EC CALLED


* is the actual line an item line
  IF rs_lineinfo-tabname EQ g_tabname_header.
    PERFORM message_output USING rs_lineinfo.
    PERFORM adress_write USING rs_lineinfo.
* Einmalig für die Gesamtsummen die Listbreite merken
    IF gv_once = gc_off.
      gv_linsz = rs_lineinfo-linsz.
      gv_once = gc_on.
    ENDIF.
  ENDIF.



ENDFORM.                    "after_line_output
*&---------------------------------------------------------------------*
*& Form MESSAGE_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RS_LINEINFO
*&---------------------------------------------------------------------*
FORM message_output    USING is_lineinfo TYPE slis_lineinfo.
  DATA: ls_head TYPE /thkr/fi_verr_head.
  DATA: ls_messages LIKE LINE OF gt_messages.
  DATA: ls_message TYPE ty_msg,
        lv_linsz   TYPE i,
        lv_len     TYPE i.

  IF NOT is_lineinfo-tabindex IS INITIAL.
* Zum Index die Referenz lesen
    READ TABLE gt_head INTO ls_head INDEX is_lineinfo-tabindex.
    IF sy-subrc EQ 0 .
      lv_linsz = is_lineinfo-linsz - 1.
      READ TABLE gt_messages INTO ls_messages  WITH TABLE KEY xblnr = ls_head-xblnr.
      IF ls_messages-xblnr  = ls_head-xblnr.
        lv_len = strlen( ls_message-msgtx ).
* neues Format
        FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
**   Leerzeile--------------------------------------------
        NEW-LINE.
        WRITE: sy-vline.
        WRITE: AT 2 TEXT-l60.
        WRITE AT is_lineinfo-linsz sy-vline.
* Zeile mit Kreditor
        LOOP AT gt_messages INTO ls_messages  WHERE xblnr = ls_head-xblnr.
          LOOP AT ls_messages-messages INTO ls_message .
            NEW-LINE.
            WRITE: sy-vline.
            WRITE: AT 2 ls_message-msgtx(lv_linsz).
            WRITE AT is_lineinfo-linsz sy-vline.
            lv_len = lv_len - lv_linsz.
*&---------------------------------------------------------------------*
* falls - Meldungstext länger als Liste--> weiter
*&---------------------------------------------------------------------*
            IF lv_len GT 0.
              NEW-LINE.
              WRITE: sy-vline.
              WRITE: AT 2 ls_message-msgtx+lv_linsz(lv_linsz).
              WRITE AT is_lineinfo-linsz sy-vline.
              lv_len = lv_len - lv_linsz.
            ENDIF.
*&---------------------------------------------------------------------*
* falls - Meldungstext länger --> weiter
*&---------------------------------------------------------------------*
            IF lv_len GT 0.
              NEW-LINE.
              WRITE: sy-vline.
              WRITE: AT 2 ls_message-msgtx+lv_linsz(lv_linsz).
              WRITE AT is_lineinfo-linsz sy-vline.
              lv_len = lv_len - lv_linsz.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADRESS_WRITE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RS_LINEINFO
*&---------------------------------------------------------------------*
FORM adress_write    USING is_lineinfo TYPE slis_lineinfo.
  DATA: ls_head TYPE /thkr/fi_verr_head.
  DATA: ls_lifnr TYPE ty_lifnr,
        ls_kunnr TYPE ty_kunnr.

  IF NOT is_lineinfo-tabindex IS INITIAL.
* Zum Index die Referenz lesen
    READ TABLE gt_head INTO ls_head INDEX is_lineinfo-tabindex.
    IF sy-subrc EQ 0.
* neues Format
      FORMAT COLOR COL_BACKGROUND INTENSIFIED OFF.
**   Leerzeile--------------------------------------------
      NEW-LINE.
      WRITE: sy-vline.
      WRITE: AT 2 TEXT-l40.
      WRITE AT is_lineinfo-linsz sy-vline.
* Zeile mit Kreditor
*      loop at gt_lifnr into ls_lifnr where xblnr_ann = ls_head-xblnr.
      LOOP AT gt_lifnr INTO ls_lifnr WHERE xblnr = ls_head-xblnr.
        NEW-LINE.
        WRITE: sy-vline.
        WRITE: AT 2 ls_lifnr-bukrs,
              AT 10 ls_lifnr-lifnr,
              AT 25 'K', " hier fest setzen, am besten wenn Anschrift
              AT 30 ls_lifnr-addr_short.
        WRITE AT is_lineinfo-linsz sy-vline.
      ENDLOOP.
* Zeile mit Debitor
      LOOP AT gt_kunnr INTO ls_kunnr WHERE xblnr = ls_head-xblnr.
        NEW-LINE.
        WRITE: sy-vline.
        WRITE: AT 2 ls_kunnr-bukrs,
              AT 10 ls_kunnr-kunnr,
              AT 25 'D', " hier fest setzen, am besten wenn Anschrift
              AT 30 ls_kunnr-addr_short.
        WRITE AT is_lineinfo-linsz sy-vline.
      ENDLOOP.
**   Leerzeile--------------------------------------------
      NEW-LINE.
      WRITE: sy-vline.
      WRITE AT is_lineinfo-linsz sy-vline.

    ENDIF.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM END_OF_LIST                                              *
*---------------------------------------------------------------------*
****       Als Summen in diesem Protokoll  werden vorgesehen:
***	 Gesamtanzahl der Fälle
***	 Anzahl der verarbeiteten Fälle
***  Falls wir mit Mappen arbeiten - Anzahl der Buchungen in der Mappe
***  ausgeben
***	 Anzahl der Fehler
***	 Gesamtbetrag der verarbeiteten Fälle
***	 Betragssummen (Einnahme/Ausgabe) je Buchungskreis
***                                                      *
*---------------------------------------------------------------------*
FORM end_of_list.                                           "#EC CALLED

  DATA: ls_sum_list TYPE ty_sum_list.
  DATA: lv_number2 TYPE i.

*falls keine Listausgabe -
  IF gv_linsz = 0.
    gv_linsz = 100.
  ENDIF.
*
  lv_number2 = gv_number - gv_number_error.
  FORMAT COLOR COL_BACKGROUND INTENSIFIED OFF.
  NEW-LINE.
  WRITE: sy-uline(gv_linsz).
  NEW-LINE.
  WRITE: sy-vline.
  WRITE: AT 2 TEXT-s01.
  WRITE AT gv_linsz sy-vline.
  WRITE: / sy-vline.
  WRITE: AT 2  TEXT-s02.
  WRITE: AT 35 gv_number.
  WRITE AT gv_linsz sy-vline.

*Sätze in der BI-Mappe
  IF p_mode = gc_char_b.
    WRITE: / sy-vline.
    WRITE: AT 2  TEXT-s09.
    WRITE: AT 35 gv_bi_cnt_tcode.
    WRITE AT gv_linsz sy-vline.
  ELSE.
    WRITE: / sy-vline.
    WRITE: AT 2  TEXT-s03.
    WRITE: AT 35 lv_number2.
    WRITE AT gv_linsz sy-vline.
  ENDIF.

  WRITE: / sy-vline.
  WRITE: AT 2  TEXT-s04.
  WRITE: AT 35 gv_number_error.
  WRITE AT gv_linsz sy-vline.
* Sätze wegen Fehler in der Mappe
  IF p_mode = gc_char_c.
    WRITE: / sy-vline.
    WRITE: AT 2  TEXT-s09.
    WRITE: AT 35 gv_bi_cnt_tcode.
    WRITE AT gv_linsz sy-vline.
  ENDIF.
  NEW-LINE.
  WRITE: sy-uline(gv_linsz).
* Überschrift Buchungkreis

  FORMAT COLOR COL_TOTAL INTENSIFIED ON.

  WRITE: / sy-vline.
  WRITE: AT 2  TEXT-s05.
  WRITE: AT 15 sy-vline.
  WRITE: AT 29  TEXT-s06.
  WRITE AT 47 sy-vline.
  WRITE: AT 62  TEXT-s07.
  WRITE AT 79 sy-vline.
  NEW-LINE.

* NUR MUSTER DER AUSGABE
***  lv_wrbtr = '10.90'.
***  lv_wrbtr2 = '100010.88'.
  LOOP AT gt_sum INTO ls_sum_list.
    FORMAT COLOR COL_BACKGROUND INTENSIFIED OFF.
    WRITE: / sy-vline.
    WRITE: ls_sum_list-bukrs UNDER TEXT-s05.
    WRITE: AT 15 sy-vline.
    WRITE: AT 17 ls_sum_list-wrbtra CURRENCY gv_waers .
    WRITE AT 47 sy-vline.
    WRITE: AT 49 ls_sum_list-wrbtre CURRENCY gv_waers ."ändern
    WRITE AT 79 sy-vline.
    WRITE: / sy-uline(79).  "???
  ENDLOOP.
  NEW-LINE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F30_CALL
*&---------------------------------------------------------------------*
*&  Call Transaktion Aufruf für die Verrechnung
*&  Falls Call nicht erfolgreich wird der Satz in die Batch-Input Mappe gestellt
*&  ??? sollten auch das Geschäftsjahr eingeben...
*&  kommt aus dem Buchungsdatum - FI_PERIOD_DETERMINE
*&---------------------------------------------------------------------*
*& -->  p_test entscheidet, ob nur Simulation
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f30_call .
  DATA: ls_beleg   TYPE ty_beleg,
        ls_xblnr   TYPE ty_xblnr,
        ls_item    TYPE /thkr/fi_verr_item,
        ls_head    TYPE /thkr/fi_verr_head,
        lv_xblnr   TYPE bkpf-xblnr,
        lv_bktxt   TYPE bkpf-bktxt,
        lv_belnr_d TYPE bkpf-belnr,
        lv_belnr_k TYPE bkpf-belnr,
        lv_bukrs_d TYPE bkpf-bukrs,
        lv_bukrs_k TYPE bkpf-bukrs,
        lv_kunnr   TYPE kunnr,
        lv_lifnr   TYPE lifnr,
*Ausgleichsdaten -----------------------------------
        lv_belnr_a TYPE bkpf-belnr,
        lv_bukrs_a TYPE bkpf-bukrs.


  DATA: ls_return TYPE bapiret2.
  DATA: lv_mode(1) TYPE c.
  DATA: lv_error  TYPE xfeld,
        lv_error2 TYPE xfeld,
        ls_sum1   TYPE ty_sum_list,
        ls_sum2   TYPE ty_sum_list.
  lv_mode = 'N'.

  DATA: lv_dynbegin LIKE gc_on,
        lv_program  TYPE bdcdata-program,
        lv_dynpro   TYPE bdcdata-dynpro.


  DATA: lt_messtab TYPE TABLE OF bdcmsgcoll,
        ls_messtab TYPE bdcmsgcoll.
  CLEAR gt_bdctab[].

  LOOP AT gt_head INTO ls_head WHERE fehler = gc_off.

*----------------------------------------------------------------------*
    "* Über die Annahme-AO, die diese Referenz haben
*----------------------------------------------------------------------*
    LOOP AT gt_beleg_ann INTO ls_beleg WHERE xblnr = ls_head-xblnr.

      lv_dynbegin = gc_on.
      lv_dynpro = '0122'.
      lv_program = 'SAPMF05A'.
      PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
      lv_dynbegin = gc_off.
      PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '=SL'.
      PERFORM dynpro USING lv_dynbegin  'BKPF-BLDAT' p_bldat.
      PERFORM dynpro USING lv_dynbegin  'BKPF-BUDAT' p_budat.
      PERFORM dynpro USING lv_dynbegin  'BKPF-BLART' p_blart.
      PERFORM dynpro USING lv_dynbegin  'BKPF-WAERS' gv_waers.
* ???---------------------------------------------------------------
*     Gjahr übernehmen?
* ???---------------------------------------------------------------


* Bleiben im Buchungskreis der Einnahme
      CONCATENATE ls_beleg-belnr ls_beleg-bukrs ls_beleg-gjahr+2(2) INTO lv_xblnr.
* Belegnummer auf Deb-Seite
      lv_belnr_d = ls_beleg-belnr.
      lv_bukrs_d = ls_beleg-bukrs.
      lv_kunnr = ls_beleg-kunnr.

      PERFORM dynpro USING lv_dynbegin  'BKPF-BUKRS' ls_beleg-bukrs.
      PERFORM dynpro USING lv_dynbegin  'BKPF-XBLNR' lv_xblnr.

      CLEAR ls_sum2.
      ls_sum2-bukrs = ls_beleg-bukrs.
      ls_sum2-wrbtre = ls_beleg-wrbtr.
    ENDLOOP.
*----------------------------------------------------------------------*
* Auszahlungen
*----------------------------------------------------------------------*
     loop at gt_beleg into ls_beleg where xblnr_ann = ls_head-xblnr. "geä. js
*   LOOP AT gt_beleg INTO ls_beleg WHERE xblnr = ls_head-xblnr. "geä. js
      CONCATENATE ls_beleg-belnr ls_beleg-bukrs ls_beleg-gjahr+2(2) INTO lv_bktxt.
      lv_belnr_k = ls_beleg-belnr.
      lv_bukrs_k = ls_beleg-bukrs.
      lv_lifnr = ls_beleg-lifnr.
      PERFORM dynpro USING lv_dynbegin  'BKPF-BKTXT' lv_bktxt.
      CLEAR ls_sum1.
      ls_sum1-bukrs = ls_beleg-bukrs.
      ls_sum1-wrbtra = ls_beleg-wrbtr.
    ENDLOOP.


*Dynpro Belegnummer eingeben----------------------
* ggf. kann hier noch geprüft werden, ob die Belegnummer an der 3. Pos steht
*
    lv_dynbegin = gc_on.
    lv_dynpro = '0710'.
    lv_program = 'SAPMF05A'.
    PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '/00'.
    PERFORM dynpro USING lv_dynbegin  'RF05A-AGBUK' lv_bukrs_d.
    PERFORM dynpro USING lv_dynbegin  'RF05A-AGKOA' gc_char_d.
    PERFORM dynpro USING lv_dynbegin  'RF05A-AGKON' lv_kunnr.  "Repro-ROC 20200623
    PERFORM dynpro USING lv_dynbegin  'RF05A-XNOPS' gc_on.
    PERFORM dynpro USING lv_dynbegin 'RF05A-XPOS1(01)' gc_off.
    PERFORM dynpro USING lv_dynbegin 'RF05A-XPOS1(03)'  gc_on.



    lv_dynbegin = gc_on.
    lv_dynpro = '0731'.
    lv_program = 'SAPMF05A'.
    PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '/00'.
    PERFORM dynpro USING lv_dynbegin  'RF05A-SEL01(01)' lv_belnr_d.

    lv_dynbegin = gc_on.
    lv_dynpro = '0731'.
    lv_program = 'SAPMF05A'.
    PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '=SLK'.

    lv_dynbegin = gc_on.
    lv_dynpro = '0710'.
    lv_program = 'SAPMF05A'.
    PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '/00'.
    PERFORM dynpro USING lv_dynbegin  'RF05A-AGBUK' lv_bukrs_k.
    PERFORM dynpro USING lv_dynbegin  'RF05A-AGKOA' gc_char_k.
    PERFORM dynpro USING lv_dynbegin  'RF05A-AGKON' lv_lifnr. "Repro-ROC 20200623
    PERFORM dynpro USING lv_dynbegin  'RF05A-XNOPS' gc_on.
    PERFORM dynpro USING lv_dynbegin 'RF05A-XPOS1(01)' gc_off.
    PERFORM dynpro USING lv_dynbegin 'RF05A-XPOS1(03)'  gc_on.


    lv_dynbegin = gc_on.
    lv_dynpro = '0731'.
    lv_program = 'SAPMF05A'.
    PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '=PA'.
    PERFORM dynpro USING lv_dynbegin  'RF05A-SEL01(01)' lv_belnr_k.



* das ist die Simulation
    lv_dynbegin = gc_on.
    lv_dynpro = '3100'.
    lv_program = 'SAPDF05X'.
    PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '=BS'.

*----------------------------------------------------------------------*
* Buchungen
*----------------------------------------------------------------------*
    IF p_test = gc_off.
*----------------------------------------------------------------------*
* Fall buchungskreisübergreifend
*----------------------------------------------------------------------*
      IF lv_bukrs_d NE lv_bukrs_k.
*----------------------------------------------------------------------*
        lv_dynbegin = gc_on.
        lv_dynpro = '0701'.
        lv_program = 'SAPMF05A'.
        PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
        lv_dynbegin = gc_off.
        PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '=BU'.
*----------------------------------------------------------------------*
* falls beide GP in einem Buchungskreis
*----------------------------------------------------------------------*
      ELSE.
        lv_dynbegin = gc_on.
        lv_dynpro = '0700'.
        lv_program = 'SAPMF05A'.
        PERFORM dynpro USING lv_dynbegin lv_program lv_dynpro.
        lv_dynbegin = gc_off.
        PERFORM dynpro USING lv_dynbegin  'BDC_OKCODE' '=BU'.
      ENDIF.



    ENDIF.
    CLEAR lv_error.
    IF p_mode = gc_char_c.
      CLEAR lt_messtab[].
      CLEAR:  lv_belnr_a,
              lv_bukrs_a.
      CALL TRANSACTION gv_tcode WITH AUTHORITY-CHECK
        USING    gt_bdctab
         MODE lv_mode
* update 'S' ???
         MESSAGES INTO lt_messtab.

*      if sy-subrc <> 0.
* Alle Fehlermeldungen in die Liste
      LOOP AT lt_messtab INTO ls_messtab WHERE
                               msgtyp = 'A' OR
                               msgtyp = 'E' OR
                               msgtyp = 'X'.
        lv_error = gc_on.
        PERFORM message_append USING ls_head-xblnr
                                     ls_messtab.
      ENDLOOP.
*     endif.
*----------------------------------------------------------------------*
* im Erfolgsfall soll aus der Meldung F5(312) die Belegnummer
* ermittelt werden und mit in die Liste gehen
*----------------------------------------------------------------------*
      IF sy-subrc NE 0.
        LOOP AT lt_messtab INTO ls_messtab WHERE
          msgid = 'F5' AND msgnr = '312'.
          SHIFT  ls_messtab-msgv1 LEFT DELETING LEADING gc_off.
          lv_belnr_a =  ls_messtab-msgv1.
          SHIFT  ls_messtab-msgv2 LEFT DELETING LEADING gc_off.
          lv_bukrs_a =  ls_messtab-msgv2.
        ENDLOOP.
*----------------------------------------------------------------------*
* bei Erfolg: Summen aktualisieren
*----------------------------------------------------------------------*
        IF  lv_belnr_a IS NOT INITIAL.
          COLLECT ls_sum1 INTO gt_sum.
          COLLECT ls_sum2 INTO gt_sum.

*----------------------------------------------------------------------*
*  Vereinheitlichung: es wir die Belegnummer aus der
*  Meldungstabelle ausgegeben, damit braucht nicht für
*  Ermittlung der übergreifenden Belegnummer gewartet werden
*----------------------------------------------------------------------*
          WAIT UP TO 1 SECONDS.

*** Belegnummer zum ausgeben
*** Beleg & wurde im Buchungskreis & gebucht
*** ggf sollen noch andere Daten ermittelt werden
**        if lv_bukrs_d ne lv_bukrs_k.
**          select single bvorg
**                 from   bkpf
**                 into   ls_head-bvorg
**                 where  bukrs = lv_bukrs_a
**                 and    belnr = lv_belnr_a
**                 and    gjahr = gv_gjahr.
***falls das  nicht gelingt --
**          if sy-subrc ne 0.
**            ls_head-bvorg = 'XXXXXXXXXXXXXXXX'.
**          endif.
***
**        else.
          CONCATENATE lv_belnr_a lv_bukrs_a gv_gjahr+2(2) INTO ls_head-bvorg.
**        endif.

          ls_head-bktxt =  lv_bktxt.
          ls_head-zxblnr = lv_xblnr.
          ls_head-bukrs = lv_bukrs_a.

          MODIFY gt_head FROM ls_head TRANSPORTING bktxt zxblnr bukrs bvorg.
*----------------------------------------------------------------------*
* falls keine Belegnummer aus der Meldung erzeugt wurde
* gibt es einen unbekannten Fehler aus dem BI
* wahrscheinlich : andere Bildfolge im BI
*----------------------------------------------------------------------*
        ELSE.
          IF p_test = gc_off.
            lv_error = gc_on.
            ls_messtab-msgtyp = gc_char_e.
            ls_messtab-msgid = gc_arbgb.
            ls_messtab-msgnr = '002'.
            ls_messtab-msgv1 = TEXT-e70.
            PERFORM message_append USING ls_head-xblnr
                                         ls_messtab.
          ENDIF.
        ENDIF.
      ENDIF. "keine Fehlermeldungen aus call

    ENDIF.
*----------------------------------------------------------------------*
* falls CALL nicht erfolgreich oder Modus für BI-Mappe
*----------------------------------------------------------------------*
    IF p_mode = gc_char_b OR lv_error = gc_on.
      CLEAR lv_error2.
* message with mappe into ct_return
      IF  gv_bci_mappe EQ gc_on.
        PERFORM bdc_insert USING ls_head-xblnr
                                 gv_tcode
                           CHANGING lv_error2.



      ELSE.
        PERFORM bdc_open_group USING ls_head-xblnr.
*----------------------------------------------------------------------*
*         falls die Mappe nicht geöffnet werden kann--Abbruch
*----------------------------------------------------------------------*
        IF  gv_bci_mappe EQ gc_off.
          EXIT.
        ENDIF.
*----------------------------------------------------------------------*
        PERFORM bdc_insert USING ls_head-xblnr
                                 gv_tcode
                           CHANGING lv_error2.

      ENDIF.
    ENDIF.

*----------------------------------------------------------------------*
*   falls nur ein Satz nicht in die Mappe geht : lv_error2
*----------------------------------------------------------------------*
    IF lv_error = gc_on OR lv_error2 = gc_on.
      ls_head-fehler = gc_on.
      MODIFY gt_head FROM ls_head TRANSPORTING fehler.
      ADD 1 TO gv_number_error.
    ENDIF.
    CLEAR gt_bdctab[].

  ENDLOOP.

*Falls eine  Mappe geöffnet wurde- muss diese geschlossen werden
  IF  gv_bci_mappe = gc_on.
    PERFORM bdc_close_group USING ls_head-xblnr.
  ENDIF.

ENDFORM.
*
*---------------------------------------------------------------------*
*       FORM DYNPRO                                                   *
*---------------------------------------------------------------------*
*e      put bdc data into bdc table                                   *
*---------------------------------------------------------------------*
*  -->  DYNBEGIN                                                      *
*  -->  NAME                                                          *
*  -->  VALUE                                                         *
*---------------------------------------------------------------------*
FORM dynpro USING p_dynbegin
                  p_name
                  p_value.

  DATA: lv_typ TYPE c,
        ls_bdc TYPE bdcdata.


  IF p_dynbegin = gc_on.
    CLEAR ls_bdc.
    MOVE: p_name  TO ls_bdc-program,
          p_value TO ls_bdc-dynpro,
          gc_on   TO ls_bdc-dynbegin.
    APPEND ls_bdc TO gt_bdctab.
  ELSE.
    CLEAR ls_bdc.
    DESCRIBE FIELD p_value TYPE lv_typ.
    MOVE  p_name   TO ls_bdc-fnam.
    CASE lv_typ.
      WHEN 'P' OR 'F' OR 'I' OR 'X'.
        WRITE p_value TO ls_bdc-fval LEFT-JUSTIFIED.
      WHEN 'D'.
        WRITE p_value TO ls_bdc-fval DD/MM/YY.
      WHEN 'T'.
        WRITE p_value TO ls_bdc-fval LEFT-JUSTIFIED.
      WHEN OTHERS.
        MOVE  p_value TO ls_bdc-fval.
    ENDCASE.
    APPEND ls_bdc TO gt_bdctab.
  ENDIF.
ENDFORM.                    "DYNPRO
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
*       FORM BDC_OPEN_GROUP                                            *
*----------------------------------------------------------------------*
*de     Batch-Input-Mappe eroeffnen                                    *
*e      open batch input session                                       *
*----------------------------------------------------------------------*
FORM bdc_open_group USING u_xblnr TYPE xblnr.


  DATA: lv_bi_mandt  TYPE sy-mandt,
        lv_bi_sperre TYPE boole_d,
        lv_bi_halten TYPE boole_d.

  DATA: ls_messtab TYPE bdcmsgcoll.


  CONSTANTS: c_grpid(5) TYPE c VALUE 'VERR_'.


  lv_bi_mandt  = sy-mandt.            "Mappen-Mandant




  CLEAR gv_groupid.
*--- Name Fehlermappe
  CONCATENATE c_grpid sy-datum+2(6) INTO gv_groupid.

  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client              = lv_bi_mandt
      group               = gv_groupid
      user                = sy-uname
*      IMPORTING
*     QID                 =
    EXCEPTIONS
      client_invalid      = 1
      destination_invalid = 2
      group_invalid       = 3
      group_is_locked     = 4
      holddate_invalid    = 5
      internal_error      = 6
      queue_error         = 7
      running             = 8
      system_lock_error   = 9
      user_invalid        = 10
      OTHERS              = 11.



  IF sy-subrc IS INITIAL.
    MESSAGE s305(00) WITH  TEXT-e30 gv_groupid TEXT-e20.
*& Mappe(n) & &


    gv_bci_mappe = gc_on.          "allg. Kennung eine Mappe offen

  ELSE.

    ls_messtab-msgid = gc_arbgb.
    ls_messtab-msgnr = '105'.
    ls_messtab-msgtyp = gc_char_e.
    ls_messtab-msgv1 = TEXT-e15.
    ls_messtab-msgv2 = gv_groupid.
    IF 1 = 2.
      MESSAGE e105(z_fi_nachr).
    ENDIF.
    PERFORM message_append
      USING u_xblnr ls_messtab.


  ENDIF.
ENDFORM.                    "BDC_OPEN_GROUP

*----------------------------------------------------------------------*
*       FORM BDC_INSERT                                                *
*----------------------------------------------------------------------*
*de     Mappe aus int. Tabelle BI1 erzeugen                            *
*e      create session from internal table BI1                         *
*----------------------------------------------------------------------*
FORM bdc_insert USING u_xblnr TYPE xblnr
                      u_bi_tcode TYPE tcode
                CHANGING c_error TYPE xfeld.

  DATA: ls_messtab TYPE bdcmsgcoll.

  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode            = u_bi_tcode
*     POST_LOCAL       = NOVBLOCAL
*     PRINTING         = NOPRINT
*     SIMUBATCH        = ' '
*     CTUPARAMS        = ' '
    TABLES
      dynprotab        = gt_bdctab
    EXCEPTIONS
      internal_error   = 1
      not_open         = 2
      queue_error      = 3
      tcode_invalid    = 4
      printing_invalid = 5
      posting_invalid  = 6
      OTHERS           = 7.


  IF sy-subrc <> 0.
    c_error = gc_on.
    CLEAR ls_messtab.
    ls_messtab-msgtyp = sy-msgty.
    ls_messtab-msgid = sy-msgid.
    ls_messtab-msgnr = sy-msgno.
    ls_messtab-msgv1 = sy-msgv1.
    ls_messtab-msgv2 = sy-msgv2.
    ls_messtab-msgv3 = sy-msgv3.
    ls_messtab-msgv4 = sy-msgv4.

    PERFORM message_append
        USING u_xblnr ls_messtab.


  ELSE.
    CLEAR gt_bdctab[].
    gv_bi_cnt_tcode = gv_bi_cnt_tcode + 1.
  ENDIF.

ENDFORM.                    "BDC_INSERT

*----------------------------------------------------------------------*
*       FORM BDC_CLOSE_GROUP                                           *
*----------------------------------------------------------------------*
*de     Batch-Input-Mappe schliessen                                   *
*e      close batch input session                                      *
*----------------------------------------------------------------------*
FORM bdc_close_group USING u_xblnr TYPE xblnr.

  DATA: ls_messtab TYPE bdcmsgcoll.




  CALL FUNCTION 'BDC_CLOSE_GROUP'
    EXCEPTIONS
      not_open    = 1
      queue_error = 2
      OTHERS      = 3.


  IF sy-subrc <> 0.
    ls_messtab-msgid = gc_arbgb.
    ls_messtab-msgnr = '307'.
    ls_messtab-msgtyp = gc_char_e.
    ls_messtab-msgv1 = TEXT-e50.
    ls_messtab-msgv2 = gv_groupid.
    IF 1 = 2.
      MESSAGE e307(00).
    ENDIF.
*Fehler beim &  der Mappe  & &
    PERFORM message_append
      USING u_xblnr ls_messtab.

  ELSE.
* Meldung für Job-Protokoll
    MESSAGE s305(00) WITH  TEXT-e30 gv_groupid TEXT-e40.
*& Mappe(n) & &
  ENDIF.

ENDFORM.                    "BDC_CLOSE_GROUP

*&---------------------------------------------------------------------*
*& Form MESSAGE_APPEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_HEAD_XBLNR
*&      --> LS_MESSTAB
*&---------------------------------------------------------------------*
FORM message_append  USING    uv_head_xblnr TYPE xblnr
                              us_messtab TYPE bdcmsgcoll.
  DATA: BEGIN OF ls_message,
          xblnr    TYPE xblnr,
          messages TYPE STANDARD TABLE OF ty_msg.
  DATA: END OF ls_message.
  DATA: ls_mess TYPE ty_msg .



  ls_message-xblnr = uv_head_xblnr.
  ls_mess-msgid  = us_messtab-msgid.
  ls_mess-msgno = us_messtab-msgnr.
  ls_mess-msgty = us_messtab-msgtyp.
  ls_mess-msgv1 = us_messtab-msgv1.
  ls_mess-msgv2 = us_messtab-msgv2.
  ls_mess-msgv3 = us_messtab-msgv3.
  ls_mess-msgv4 = us_messtab-msgv4.


  CALL FUNCTION 'K_MESSAGE_TRANSFORM'
    EXPORTING
      par_msgid         = ls_mess-msgid
      par_msgno         = ls_mess-msgno
      par_msgty         = ls_mess-msgty
      par_msgv1         = ls_mess-msgv1
      par_msgv2         = ls_mess-msgv2
      par_msgv3         = ls_mess-msgv3
      par_msgv4         = ls_mess-msgv4
* über diesen Parameter kann man an den Text au
*    par_total
    IMPORTING
      par_msgtx         = ls_mess-msgtx
    EXCEPTIONS
      no_message_found  = 1
      par_msgid_missing = 2
      par_msgno_missing = 3
      par_msgty_missing = 4
      OTHERS            = 5.
  IF sy-subrc <> 0.
    ls_mess-msgtx = TEXT-e10.
  ENDIF.
  APPEND ls_mess TO ls_message-messages.
  APPEND ls_message TO gt_messages.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GJAHR_GET
*&---------------------------------------------------------------------*
*& ermitteln das Geschäftsjahr
*&---------------------------------------------------------------------*
*&      --> P_BUDAT Buchungsdatum
*&      --> p_Periv aus dem Finanzkreis
*&      <-- GV_GJAHR Geschäftsjahr
*&---------------------------------------------------------------------*
FORM gjahr_get  USING    uv_budat TYPE budat
                         uv_periv TYPE periv
                CHANGING cv_gjahr TYPE gjahr.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = uv_budat
*     I_BUKRS        = ' '
*     I_RLDNR        = ' '
      i_periv        = uv_periv
*     I_GJAHR        = 0000
*     I_MONAT        = 00
*     X_XMO16        = ' '
    IMPORTING
      e_gjahr        = cv_gjahr
*     E_MONAT        =
*     E_POPER        =
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
    MESSAGE e002 WITH TEXT-e60.
  ENDIF.


ENDFORM.
