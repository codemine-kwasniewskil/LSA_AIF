"Name: \PR:RFEBBU00\FO:FBRA_POSTING\SE:END\EI
ENHANCEMENT 0 Z_FI_FBRA_RFEBBU00_E1.
*

TYPES: BEGIN OF ts_beleg,
         bukrs TYPE bukrs,
         belnr TYPE belnr_d,
         gjahr TYPE gjahr,
         buzei TYPE buzei,
       END OF ts_beleg.

DATA: lt_beleg  TYPE TABLE OF ts_beleg,
      lt_return TYPE bapiret2_t.
DATA: ls_beleg TYPE ts_beleg,
      ls_augbl TYPE ts_beleg.
DATA: lt_028x  TYPE TABLE OF t028x.

IF gv_lines > 0.
  ikofi = gs_ikofi.
*---------------------------------------------------------------------
* REPRO-ROC  24.02.2021
* nach aktueller Anpassung von Z_FI_FBRA_RFEBBU00_S1, sollten keine
* Sätze in xfebcl1 stehen
*---------------------------------------------------------------------
  LOOP AT xfebcl1 WHERE ( selfd = 'BELNR' )
                      AND selvon NE '*'.

    CLEAR augbl.
    belns = xfebcl1-selvon(10).

    SELECT * FROM bkpf
      WHERE bukrs = febko-bukrs
      AND   belnr = xfebcl1-selvon
      ORDER BY PRIMARY KEY.
    ENDSELECT.

    EXIT.
  ENDLOOP.

  IF sy-subrc = 0 OR mode = 'A' OR mode = 'E'.
    CLEAR: subrc, msgid, msgty, msgno, msgv1, msgv2, msgv3, msgv4."45B

    IF open = false.
      PERFORM posting_interface_start(rfebbu00).
    ENDIF.

    IF testl NE 'X'.
      IF function = 'B'                 "batch input, Depner 270597
        OR mode = 'A' OR mode = 'E'.                        "n1321162

        IF function = 'B'.                                  "n2370994
*--------------------------- start of note 313962 ---------------------
* For batch input, check if there is withholding tax in
* the original document. If so, disallow the posting
          SELECT SINGLE * FROM bseg
            WHERE bukrs = febko-bukrs                       "hw313962
            AND belnr = bkpf-belnr                          "hw313962
            AND gjahr = bkpf-gjahr                          "hw313962
            AND qsshb <> 0.                                 "hw313962
          IF sy-subrc = 0.                                  "hw313962
            CLEAR vb_error.                                 "hw313962
            vb_error-anwnd = febko-anwnd.                   "hw313962
            vb_error-absnd = febko-absnd.                   "hw313962
            vb_error-azidt = febko-azidt.                   "hw313962
            vb_error-ktonr = febko-ktonr.                   "hw313962
            vb_error-aznum = febko-aznum.                   "hw313962
            vb_error-esnum = febep-esnum.                   "hw313962
            vb_error-buber = bereich.                       "hw313962
            vb_error-zeile = TEXT-090.                      "hw313962
            APPEND vb_error.                                "hw313962
            statist-error = statist-error + 1.              "hw313962
            EXIT.                                           "hw313962
          ENDIF.                                            "hw313962
*----------------------------end of note 313962-----------------------
        ENDIF.                                              "n2370994
*--- FBRA nur bei ausgeglichenen Beleg ausführen !!!
        IF NOT gv_augbl IS INITIAL.
          CLEAR: ls_augbl.
          SELECT bukrs belnr gjahr FROM bseg INTO CORRESPONDING FIELDS OF ls_augbl
                                   UP TO 1 ROWS
                                   WHERE bukrs = febko-bukrs
                                   AND   augbl = belns
                                   AND   gjahr = bkpf-gjahr.
          ENDSELECT.

          tcode = 'FBRA'.
          CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR'
            EXPORTING
              i_tcode                  = tcode
              i_augbl                  = belns
              i_bukrs                  = febko-bukrs
              i_gjahr                  = bkpf-gjahr
            IMPORTING
              e_subrc                  = subrc
              e_msgid                  = msgid
              e_msgty                  = msgty
              e_msgno                  = msgno
              e_msgv1                  = msgv1
              e_msgv2                  = msgv2
              e_msgv3                  = msgv3
              e_msgv4                  = msgv4
            EXCEPTIONS
              transaction_code_invalid = 1.
          IF sy-subrc NE 0.
            MESSAGE e776 WITH tcode.
            CLEAR: msgv1.
            MOVE tcode TO msgv1.
            CLEAR gv_kukey_str.                             "n1950441
            CONCATENATE 'KUKEY' febep-kukey INTO gv_kukey_str. "n1950441
            PERFORM bapi_message(rfebbu10)
               TABLES _t_bapiret2
               USING  'FB' 'E' '776'  msgv1 space space space
                      space '0' gv_kukey_str.               "n1950441
          ELSE.
            UPDATE febep SET xblnr = space
                             WHERE kukey = febep-kukey
                             AND   esnum = febep-esnum.

          ENDIF.
        ENDIF.
        IF subrc = '0'.
*--- DRUCK_FBRA_ZEILE  nur bei ausgeglichenen Beleg ausführen !!!
          IF NOT gv_augbl IS INITIAL.
            augbl = belns.
            PERFORM druck_fbra_zeile CHANGING xt_fb01.
          ENDIF.
          tcode = 'FB08'.
          IF xtrwpr = 'X' AND function = 'C'.               "n1649340
            EXPORT bereich
              febep-kukey
              febep-esnum
              komk
              xakon
              r_csnum
              febep-pform                                   "n1814932
              vbkep
              xfebcl
              TO MEMORY ID 'FEBA_POST'.
          ENDIF.
          CALL FUNCTION 'POSTING_INTERFACE_REVERSE_DOC'
            EXPORTING
              i_tcode                  = tcode
              i_belns                  = belns
              i_bukrs                  = febko-bukrs
              i_stgrd                  = ikofi-stgrd
            IMPORTING
              e_subrc                  = subrc
              e_msgid                  = msgid
              e_msgty                  = msgty
              e_msgno                  = msgno
              e_msgv1                  = msgv1
              e_msgv2                  = msgv2
              e_msgv3                  = msgv3
              e_msgv4                  = msgv4
            TABLES
              t_blntab                 = xblntab
            EXCEPTIONS
              transaction_code_invalid = 1.
          IF sy-subrc NE 0.
*                PERFORM bapi_message(rfebbu10)
*                    TABLES _t_bapiret2
*                    USING  sy-msgid  sy-msgty  sy-msgno sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                           space '0' space.
            IF xtrwpr = 'X' AND function = 'C'.             "n1649340
              FREE MEMORY ID 'FEBA_POST'.                   "n1649340
            ENDIF.                                          "n1649340
            MESSAGE e776 WITH tcode.
            CLEAR: msgv1.
            MOVE tcode TO msgv1.
            CLEAR gv_kukey_str.                             "n1950441
            CONCATENATE 'KUKEY' febep-kukey INTO gv_kukey_str. "n1950441
            PERFORM bapi_message(rfebbu10)
              TABLES _t_bapiret2
              USING  'FB' 'E' '776'  msgv1 space space space
                     space '0' gv_kukey_str.                "n1950441
          ENDIF.
          IF xtrwpr = 'X' AND function = 'C'.               "n1649340
            FREE MEMORY ID 'FEBA_POST'.                     "n1649340
          ENDIF.                                            "n1649340

          IF subrc = '0'.
            PERFORM druck_fb08_zeile(rfebbu00) CHANGING xt_fb01.
*                VB_BELNR  = XBLNTAB-BELNR.
*                VB_OK     = 'X'.
            statist-fb01  = statist-fb01  + 1.
            PERFORM update_febep_status(rfebbu00).
          ELSE.
            MESSAGE ID msgid  TYPE msgty  NUMBER msgno
                       WITH msgv1 msgv2 msgv3 msgv4.
            CLEAR gv_kukey_str.                             "n1950441
            CONCATENATE 'KUKEY' febep-kukey INTO gv_kukey_str. "n1950441
            PERFORM bapi_message(rfebbu10)                         "\LA EhP6
              TABLES _t_bapiret2
              USING  msgid msgty msgno msgv1 msgv2 msgv3 msgv4
                     space '0' gv_kukey_str.                "n1950441
            statist-error = statist-error + 1.
          ENDIF.
        ELSE.
          MESSAGE ID msgid  TYPE msgty  NUMBER msgno
                     WITH msgv1 msgv2 msgv3 msgv4.
          CLEAR gv_kukey_str.                               "n1950441
          CONCATENATE 'KUKEY' febep-kukey INTO gv_kukey_str. "n1950441
          PERFORM bapi_message(rfebbu10)                         "\LA EhP6
            TABLES _t_bapiret2
            USING  msgid msgty msgno msgv1 msgv2 msgv3 msgv4
                   space '0' gv_kukey_str.                  "n1950441
          statist-error = statist-error + 1.
        ENDIF.
      ELSE.                              "call transaction
        IF xtrwpr = 'X' AND function = 'C'.                 "hw426052
          EXPORT bereich                                    "hw426052
                 febep-kukey                                "hw426052
                 febep-esnum                                "hw426052
                 komk                                       "hw426052
                 xakon                                      "hw426052
                 r_csnum                                    "hw426052
                 febep-pform                                "n1814932
                 vbkep                                      "hw426052
                 xfebcl                                     "hw426052
                 TO MEMORY ID 'FEBA_POST'.                  "hw426052
        ENDIF.                                              "hw426052
*            CALL FUNCTION 'J_1B_FBRA_POSTING_AUFRUFEN'
*              EXPORTING
*                i_augbl           = bkpf-belnr
*                i_bukrs           = bkpf-bukrs
*                i_gjahr           = bkpf-gjahr
*                i_stgrd           = ikofi-stgrd
*              EXCEPTIONS
*                not_possible_fbra = 1
*                not_possible_fb08 = 2.
        IF NOT gv_augbl IS INITIAL.
          CALL FUNCTION 'CALL_FBRA'
            EXPORTING
              i_bukrs      = bkpf-bukrs
              i_augbl      = bkpf-belnr    " gv_AUGBL existiert
              i_gjahr      = bkpf-gjahr
*             I_STODT      = STODT
*             I_STOMO      = STOMO
            EXCEPTIONS
              not_possible = 4.
        ENDIF.
        CALL FUNCTION 'CALL_FB08'
          EXPORTING
            i_bukrs      = bkpf-bukrs
            i_belnr      = bkpf-belnr
            i_gjahr      = bkpf-gjahr
            i_stgrd      = ikofi-stgrd
          EXCEPTIONS
            not_possible = 1.

        subrc = sy-subrc.                                   "n972881
        IF xtrwpr = 'X' AND function = 'C'.                 "n972881
          FREE MEMORY ID 'FEBA_POST'.                       "n972881
        ENDIF.                                              "n972881

        IF subrc <> 0.                                      "n972881
          IF p_bupro = 'X'.
            IF subrc = 4.                                   "n972881
              augbl = belns.
              PERFORM druck_fbra_zeile(rfebbu00) CHANGING xt_fb01.
            ENDIF.
            msgid = sy-msgid.
            msgno = sy-msgno.
            msgv1 = sy-msgv1.
            msgv2 = sy-msgv2.
            msgv3 = sy-msgv3.
            msgv4 = sy-msgv4.
            PERFORM druck_message(rfebbu00) CHANGING xt_fb01.
          ENDIF.
          statist-error = statist-error + 1.
        ELSE.
          msgid = sy-msgid.                                   "45B
          msgno = sy-msgno.                                   "45B
          msgv1 = sy-msgv1.                                   "45B
          msgv2 = sy-msgv2.                                   "45B
          msgv3 = sy-msgv3.                                   "45B
          msgv4 = sy-msgv4.                                   "45B
          IF p_bupro = 'X'.
            augbl = belns.
            PERFORM druck_fbra_zeile(rfebbu00) CHANGING xt_fb01.
            PERFORM druck_fb08_zeile(rfebbu00) CHANGING xt_fb01.
            statist-fb01  = statist-fb01  + 2.
          ENDIF.                                              "45B
          PERFORM update_febep_status(rfebbu00).
*              ENDIF.                                                    "45B
        ENDIF.
      ENDIF.
    ELSE.
*          beim Testlauf erfolgreiche Buchung simulieren
      sy-subrc = 0.
    ENDIF.
* Initialisation - new with 4.6A
    bkpf_komk_ok   = false.
    bseg_komk_s_ok = false.
    bseg_komk_h_ok = false.
    CLEAR ikofi.
    CLEAR komk.
    REFRESH: vbkep.
    CLEAR:   vbkep.
    REFRESH:  ftpost, ftclear, fttax.                       "n1370152
    CLEAR:   ftpost, ftclear, fttax.                        "n1370152
    REFRESH: xblntab.
    CLEAR:   xblntab.

  ELSE.
    CLEAR vb_error.
    vb_error-anwnd = febko-anwnd.                           "hw313962
    vb_error-absnd = febko-absnd.                           "hw313962
    vb_error-azidt = febko-azidt.                           "hw313962
    vb_error-ktonr = febko-ktonr.                           "hw313962
    vb_error-aznum = febko-aznum.                           "hw313962
    vb_error-esnum = febep-esnum.                           "hw313962
    vb_error-buber = bereich.                               "hw313962
    vb_error-zeile = TEXT-034.                              "hw313962
    APPEND vb_error.                                        "hw313962
    statist-error = statist-error + 1.                      "hw313962
  ENDIF.

  LOOP AT xfebcl1 WHERE ( selfd = 'AUGBL'
                       OR selfd = 'BELNR' )
                      AND selvon NE '*'.                    "n1622292
    APPEND xfebcl1 TO xfebcl.
  ENDLOOP.
  LOOP AT xfebcl2 WHERE ( selfd = 'AUGBL'
                       OR selfd = 'BELNR' )
                      AND selvon NE '*'.                    "n1622292
    APPEND xfebcl2 TO xfebcl.
  ENDLOOP.
  REFRESH: xfebcl1, xfebcl2.
ENDIF.
*---------------------------------------------------------------------------
* Febep gerade ziehen für Rückläufer
*---------------------------------------------------------------------------
IF gs_ikofi-eigr2 = '2' AND
gs_ikofi-attr2 = '9' AND
gs_ikofi-stgrd IS NOT INITIAL.
*---------------------------------------------------------------------------
* welche Belegnummer steht in febep? ggf Überschreiben
*---------------------------------------------------------------------------
  DATA: lv_stblg TYPE stblg,
        lv_stjah TYPE stjah,
        lv_nbbln TYPE belnr_d.

  SELECT SINGLE  stblg stjah INTO ( lv_stblg,  lv_stjah )
    FROM bkpf
    WHERE bukrs = febko-bukrs AND
          belnr = gv_belnr_orig AND
          gjahr = gv_gjahr_orig.
*----------------------------------------------------------------
*  Beleg gebucht und Stornobeleg vorhanden
*----------------------------------------------------------------
  IF sy-subrc = 0 AND lv_stblg IS NOT INITIAL.
    SELECT SINGLE nbbln FROM febep INTO lv_nbbln
      WHERE kukey = febep-kukey
        AND esnum = febep-esnum.
*----------------------------------------------------------------
*  bereits  nbbln eingetragen aus Standard
*----------------------------------------------------------------
*      nbbln   füllen
* ggf NBBLN_GJAHR füllen
*----------------------------------------------------------------
    IF sy-subrc = 0 AND lv_nbbln IS NOT INITIAL.

      IF  lv_nbbln NE lv_stblg.
        UPDATE febep SET   nbbln = lv_stblg
                           nbbln_gjahr = lv_stjah
                  WHERE kukey = febep-kukey
                  AND   esnum = febep-esnum.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
*--------------------------------------------------------------------
* Ursprungsbelege behandeln
*--------------------------------------------------------------------
LOOP AT xfebcl ASSIGNING <fs_xfebcl> WHERE selfd = 'BELNR' AND selvon NE '*'.
  IF <fs_xfebcl>-selvon+14(1) NE 'A'.
*--------------------------------------------------------------------
* Die Ermittlung der Belege findet vor den Stornos statt, solange
* der Ausgleich noch ausgelesen werden kann-> Tabelle lt_bel_orig
*--------------------------------------------------------------------
    LOOP AT lt_bel_orig ASSIGNING <fs_bel_orig>  WHERE selfd = <fs_xfebcl>-selfd AND
      selvon = <fs_xfebcl>-selvon.
***************************
      LOOP AT <fs_bel_orig>-belege ASSIGNING <fs_bel_orig_fb>.

        IF NOT <fs_bel_orig_fb>-belnr  IS INITIAL.
*     IF NOT gv_belnr is initial.
          tcode = 'FB09'.
          IF function = 'B'.
            PERFORM bdc_dynpro USING 'SAPMF05L' '0102'.
            PERFORM bdc_field  USING 'RF05L-BELNR' <fs_bel_orig_fb>-belnr. "gv_belnr.
            PERFORM bdc_field  USING 'RF05L-BUKRS' <fs_bel_orig_fb>-bukrs. "gv_bukrs.
            PERFORM bdc_field  USING 'RF05L-GJAHR' <fs_bel_orig_fb>-gjahr. "gv-gjahr
            PERFORM bdc_field  USING 'RF05L-BUZEI' <fs_bel_orig_fb>-buzei. "gv_buzei
            PERFORM bdc_field  USING 'BDC_OKCODE'  '/00'.
            IF <fs_bel_orig_fb>-koart = 'K'.
              PERFORM bdc_dynpro USING 'SAPMF05L' '0302'.
            ELSEIF <fs_bel_orig_fb>-koart = 'D'.
              PERFORM bdc_dynpro USING 'SAPMF05L' '0301'.
            ENDIF.
            PERFORM bdc_field  USING 'BSEG-ZLSPR'  'W'.     " W statt R
            PERFORM bdc_field  USING 'BDC_OKCODE'  '=AE'.
            IF NOT testl = 'X'.
              CALL FUNCTION 'BDC_INSERT'
                EXPORTING
                  tcode     = tcode
                TABLES
                  dynprotab = bdcdata.
            ENDIF.
            REFRESH bdcdata.
          ELSE.
            READ TABLE lt_beleg TRANSPORTING NO FIELDS
                       WITH KEY bukrs = <fs_bel_orig_fb>-bukrs
                                belnr = <fs_bel_orig_fb>-belnr
                                gjahr = <fs_bel_orig_fb>-gjahr
                                buzei = <fs_bel_orig_fb>-buzei.
            CHECK sy-subrc NE 0.

            CALL FUNCTION '/THKR/FEB_CALL_FB09'
              EXPORTING
                i_bukrs      = <fs_bel_orig_fb>-bukrs
                i_belnr      = <fs_bel_orig_fb>-belnr
                i_gjahr      = <fs_bel_orig_fb>-gjahr
                i_buzei      = <fs_bel_orig_fb>-buzei
                i_koart      = <fs_bel_orig_fb>-koart
*               I_XSIMU      = ' '
*               I_UPDATE     = 'S'
*               I_MODE       = 'N'
                i_no_auth    = 'X'                        " Solman 2000002700 REPRO-GANZ
              EXCEPTIONS
                not_possible = 1
                OTHERS       = 2.
            IF sy-subrc <> 0.
              DATA(lv_kein_zahlsp) = abap_true.
              CLEAR: ls_beleg.
              ls_beleg-bukrs = <fs_bel_orig_fb>-bukrs.
              ls_beleg-belnr = <fs_bel_orig_fb>-belnr.
              ls_beleg-gjahr = <fs_bel_orig_fb>-gjahr.
              ls_beleg-buzei = <fs_bel_orig_fb>-buzei.
              APPEND ls_beleg TO lt_beleg.
            ELSE.
              CLEAR: ls_beleg, lv_kein_zahlsp.
              ls_beleg-bukrs = <fs_bel_orig_fb>-bukrs.
              ls_beleg-belnr = <fs_bel_orig_fb>-belnr.
              ls_beleg-gjahr = <fs_bel_orig_fb>-gjahr.
              ls_beleg-buzei = <fs_bel_orig_fb>-buzei.
              APPEND ls_beleg TO lt_beleg.
            ENDIF.
            SORT lt_beleg.
            DELETE ADJACENT DUPLICATES FROM lt_beleg COMPARING ALL FIELDS.
          ENDIF.
*--- Druck der FB09-Zeile
          DATA: ls_fb09 TYPE fagl_acc_s_rfebbu00_alv.
          IF p_bupro = 'X'.
            IF lv_kein_zahlsp EQ abap_true.
              char80 = 'Beleg & Zahlsperre konnte nicht geändert werden.'.
            ELSE.
              char80 = 'Beleg & wird bzgl. Zahlsperre geändert.'.
            ENDIF.
*         REPLACE '&' WITH gv_belnr INTO char80.
            REPLACE '&' WITH <fs_bel_orig_fb>-belnr INTO char80.
            CLEAR ls_fb09.
            ls_fb09-esnum  = febep-esnum.
            ls_fb09-vgint = febep-vgint.
            ls_fb09-vgext = febep-vgext.
            ls_fb09-tcode = tcode.
            ls_fb09-msg   = char80.
            ls_fb09-bername    = bername.
*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
            ls_fb09-bankl  = gs_header-bankl.
            ls_fb09-ktonr  = gs_header-ktonr.
            ls_fb09-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
            ls_fb09-kukey     = febko-kukey.                "n853370
            ls_fb09-mappe     = mappe.

            APPEND ls_fb09 TO xt_fb01.
          ENDIF.
        ENDIF.
      ENDLOOP.
*   endloop. --> nach Rückläufer Benachrichtiung

*--------------------------------------------------------------------
* Rückläufer für Benachrichtigung speichern
*--------------------------------------------------------------------
*******************************  DATA: l_zbeleg TYPE ZFI_F_ZBELEG,
*******************************        l_bnfeb  TYPE ZFI_F_BNFEB.
*******************************
*******************************  IF testl NE 'X' AND subrc = 0.
*******************************
********************************   Zahlungsbeleg / Ausgleichsbeleg
*******************************    l_zbeleg-bukrs = bkpf-bukrs.
*******************************    l_zbeleg-belnr = bkpf-belnr.
*******************************    l_zbeleg-gjahr = bkpf-gjahr.
********************************   Kontoauszugsdaten
*******************************    l_bnfeb-ANWND = FEBKO-ANWND.
*******************************    l_bnfeb-ABSND = FEBKO-ABSND.
*******************************    l_bnfeb-AZIDT = FEBKO-AZIDT.
*******************************    l_bnfeb-AZNUM = FEBKO-AZNUM.
*******************************    l_bnfeb-KUKEY = FEBKO-KUKEY.
*******************************    l_bnfeb-HBKID = FEBKO-HBKID.
*******************************    l_bnfeb-HKTID = FEBKO-HKTID.
*******************************    l_bnfeb-ESNUM = FEBEP-ESNUM.
*******************************    l_bnfeb-VGINT = FEBEP-VGINT.
*******************************    l_bnfeb-VGEXT = FEBEP-VGEXT.
*******************************    l_bnfeb-KWAER = FEBEP-KWAER.
*******************************    l_bnfeb-KWBTR = FEBEP-KWBTR.
*******************************
*******************************    zcl_fi_bn_nachrichten=>get_instance( )->add_beleg_rl(
*******************************      EXPORTING
*******************************        i_zbeleg = l_zbeleg
*******************************        i_bnfeb  = l_bnfeb
********************************        i_postab = lt_postab ).
*******************************       i_origpostab = <fs_bel_orig>-belege
*******************************       i_zbelegtab  = <fs_bel_orig>-zbelege ).
*******************************
*******************************  ENDIF.
    ENDLOOP.

*--- Mandatssperre evtl. setzen
*--- ?? REPRO-ROC ggf wurden nicht alle
*   Sätze abgearbeitet wegen sortierten Select auf BKPF im
*   Standardteil
    DATA: l_rrint    TYPE t028x-rrint,
          ls_message TYPE bapiret1.

    DATA: lv_belnr TYPE belnr_d,
          lv_gjahr TYPE bkpf-gjahr.

    lv_belnr = <fs_xfebcl>-selvon.
    lv_gjahr = <fs_xfebcl>-selvon+10(4).
    l_rrint  = febep-kkref+27(3).

    CLEAR: lt_028x.
    SELECT * FROM t028x INTO TABLE lt_028x
      WHERE vgtyp = 'LSA'.

    READ TABLE lt_028x TRANSPORTING NO FIELDS
               WITH KEY rrint = l_rrint.
    IF sy-subrc EQ 0.
      CALL FUNCTION 'FI_APAR_MANDATE_RETURN_FR_BANK'
        EXPORTING
          iv_bukrs   = febko-bukrs
          iv_gjahr   = lv_gjahr
          iv_augbl   = lv_belnr
          iv_rrint   = l_rrint
        IMPORTING
          es_message = ls_message.
    ENDIF.
  ENDIF.
ENDLOOP.

DATA(lr_appl) = NEW /thkr/cl_elko_appl( ).

READ TABLE lt_beleg ASSIGNING FIELD-SYMBOL(<ls_beleg>)
           INDEX 1.
IF sy-subrc EQ 0.
  lr_appl->set_bapi_beleg_buchen( EXPORTING is_febko  = febko
                                            is_febep  = febep
                                            is_beleg  = <ls_beleg>
                                  CHANGING  xt_return = lt_return ).
  IF p_bupro = 'X'.
    READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<ls_return>)
               INDEX 1.
    IF  sy-subrc EQ 0 AND   ( <ls_return>-type   EQ 'S' AND <ls_return>-id     EQ 'RW' AND <ls_return>-number EQ '605').
      DATA(lv_gebucht) = abap_true.
    ELSEIF <ls_return>-type NE 'S'.
      CLEAR: lv_gebucht.
    ELSE.
      CLEAR: lv_gebucht.
    ENDIF.
    IF lv_gebucht EQ abap_true.
      char80 = 'Gebührenbeleg & wurde gebucht.'.
      CONCATENATE <ls_return>-message_v2+0(10) '/' <ls_return>-message_v2+10(4) '/' <ls_return>-message_v2+14(4) INTO DATA(ls_belnr).
      REPLACE '&' WITH ls_belnr INTO char80.
      CLEAR: ls_belnr.
    ELSE.
      char80 = 'Gebühren nicht gebucht: &'.
      DATA(ls_text) = <ls_return>-message.
      REPLACE '&' WITH ls_text INTO char80.
      CLEAR: ls_text.
    ENDIF.
    CLEAR: lv_gebucht.

    CLEAR ls_fb09.
    ls_fb09-esnum  = febep-esnum.
    ls_fb09-vgint = febep-vgint.
    ls_fb09-vgext = febep-vgext.
    ls_fb09-tcode = tcode.
    ls_fb09-msg   = char80.
    ls_fb09-bername    = bername.
*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb09-bankl  = gs_header-bankl.
    ls_fb09-ktonr  = gs_header-ktonr.
    ls_fb09-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb09-kukey     = febko-kukey.                        "n853370
    ls_fb09-mappe     = mappe.

    APPEND ls_fb09 TO xt_fb01.
  ENDIF.

ENDIF.

CLEAR: lt_beleg.


ENDENHANCEMENT.
