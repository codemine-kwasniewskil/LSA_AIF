*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_FB02_P01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init .

  CLEAR: gs_bkpf,
         gs_bseg,
         gs_fb02,
         gt_fb02,
         gt_texte,
         gt_texte_changed,
         gt_texte_helper.
*         gs_kommentar.

  IF lr_alv2 IS BOUND.
    CALL METHOD lr_alv2->Free.
    FREE lr_alv2.
  ENDIF.

  IF lr_container2 IS BOUND.

    CALL METHOD lr_container2->free.
    FREE lr_container2.

  ENDIF.

  CLEAR: gv_change.

  GET PARAMETER ID 'BLN' FIELD rf05l-belnr.
  GET PARAMETER ID 'GJR' FIELD rf05l-gjahr.
  GET PARAMETER ID 'GJR' FIELD rf05l-ryear.
  GET PARAMETER ID 'BUK' FIELD rf05l-bukrs.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form pop_up_sichern
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM pop_up_sichern .

  DATA: lv_answer TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question  = 'Möchten Sie die Daten sichern?'
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.


  CASE lv_answer.
    WHEN '1'.
      PERFORM get_changes_form.
      IF gs_bseg-koart = 'K'.
        PERFORM Check_changes_k.
      ELSEIF gs_bseg-koart = 'D'.
        PERFORM check_changes_d.
      ENDIF.
      IF sy-tcode = gc_tcode.
        PERFORM sichern.
      ELSEIF sy-tcode = gc_tcode_justiz.
        PERFORM sichern_jus.
      ENDIF.
    WHEN '2'.
      PERFORM init.
      CALL SCREEN '0100'.
    WHEN 'A'.
      CLEAR ok-code.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form sichern
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sichern .

  DATA: ls_fb02      LIKE /thkr/fb02c,
        lv_belnr(16) TYPE c.
  DATA: lt_fb02_text TYPE STANDARD TABLE OF /thkr/fb02c_text,
        ls_fb02_text LIKE LINE OF lt_fb02_text.

  IF gv_change IS INITIAL.
    MESSAGE ID '/THKR/FI_WF_BKPF' TYPE 'S' NUMBER '351' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN sy-dynnr.
    "Message /THKR/FI_WF_BKPF
* Es wurden keine Änderungen an den Daten vorgenommen.
  ELSE.

*    IF gs_kommentar IS INITIAL.
*      MESSAGE e361(/THKR/FI_WF_BKPF).
** Bitte tragen Sie eine Bemerkung zur Änderung ein.
*    ELSE.
** Kommentare übernehmen
*      MOVE-CORRESPONDING gs_kommentar TO gs_fb02.
*    ENDIF.

* Kopfdaten anreichern
    gs_fb02-status = '10'.
    gs_fb02-usnam = sy-uname.
    gs_fb02-cpudt = sy-datum.
    gs_fb02-cputm = sy-uzeit.

* vorhandene Belege prüfen und Nummer vergeben
    SELECT MAX( lfdnr ) FROM /thkr/fb02c UP TO 1 ROWS
      INTO gs_fb02-lfdnr
       WHERE bukrs = gs_fb02-bukrs
        AND belnr = gs_fb02-belnr
        AND gjahr = gs_fb02-gjahr.
    ADD 1 TO gs_fb02-lfdnr.

    CLEAR lt_fb02_text.
    LOOP AT gt_texte_changed ASSIGNING FIELD-SYMBOL(<fs_texte>).
      ls_fb02_text-mandt = <fs_texte>-mandt.
      ls_fb02_text-bukrs = <fs_texte>-bukrs.
      ls_fb02_text-buzei = <fs_texte>-buzei.
      ls_fb02_text-belnr = <fs_texte>-belnr.
      ls_fb02_text-gjahr = <fs_texte>-gjahr.
      ls_fb02_text-lfdnr = gs_fb02-lfdnr.
      ls_fb02_text-sgtxt = <fs_texte>-sgtxt.
      ls_fb02_text-zuonr = <fs_texte>-zuonr.
      APPEND ls_fb02_text TO lt_fb02_text.
      CLEAR ls_fb02_text.
    ENDLOOP.
* Daten speichern
    INSERT /thkr/fb02c FROM gs_fb02.
    IF sy-subrc NE 0.
      ROLLBACK WORK.
      PERFORM init.
      MESSAGE e352(/thkr/fi_wf_bkpf).
* Die Änderungen konnten nicht gespeichert werden.
    ELSE.
      INSERT /thkr/fb02c_text FROM TABLE lt_fb02_text.
      IF sy-subrc <> 0.
        ROLLBACK WORK.
        PERFORM init.
        MESSAGE e352(/thkr/fi_wf_bkpf).
* Die Änderungen konnten nicht gespeichert werden.
      ELSE.
        CONCATENATE gs_fb02-belnr ' / ' gs_fb02-lfdnr
         INTO lv_belnr RESPECTING BLANKS.
        MESSAGE s323(f5) WITH lv_belnr gs_fb02-bukrs.
* Document & was stored in company code &

*** begin #001 ***
        IF sy-tcode = gc_tcode_lok.           " Z_FI_FB02_LOK

          " Änderung der Mahnstufe ohne 4 Augen Prinzip anstossen
          PERFORM sichern_lok.

        ELSE.
*** end #001  ***
*    Beleg an WF übergeben
          CALL FUNCTION '/THKR/WF_START_BKPF'
            EXPORTING
              is_fb02                  = gs_fb02
            EXCEPTIONS
              no_workflow_start        = 1
              bereits_offener_workflow = 2
              OTHERS                   = 3.
          CASE sy-subrc.
            WHEN '1'.
              MESSAGE e358(/thkr/fi_wf_bkpf).
*         Der Workflow konnte nicht gestartet werden.
            WHEN '2'.
              MESSAGE e357(/thkr/fi_wf_bkpf).
*         Zu diesem Beleg wurde bereits ein Workflow gestartet.
            WHEN '3'.
              MESSAGE e359(/thkr/fi_wf_bkpf).
*         Es ist ein unbekannter Fehler bei der
*         Workflowverarbeitung aufgetreten.
          ENDCASE.
        ENDIF.
      ENDIF.                                      " #001
    ENDIF.
  ENDIF.

*  PERFORM init.                                  " #001
*  LEAVE TO SCREEN '0100'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Position_aufrufen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM position_aufrufen .

  CASE gs_bseg-koart.
    WHEN 'D'.
*** begin of #001 ***
      IF sy-tcode = gc_tcode_justiz.
        CALL SCREEN '0401'.
      ELSE.
        CALL SCREEN '0301'.
      ENDIF.
    WHEN 'K'.
      IF sy-tcode = gc_tcode_justiz.
        CALL SCREEN '0402'.
      ELSE.
        CALL SCREEN '0302'.
      ENDIF.
*** end of #001 ***
    WHEN OTHERS.
      MESSAGE s369(/thkr/fi_wf_bkpf) WITH gs_bseg-koart DISPLAY LIKE 'E'.
      LEAVE TO SCREEN 100.
* Kontoart &1 nicht für Änderungen per Workflow zulässig.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form auth_check_buzei
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_BSEG
*&---------------------------------------------------------------------*
FORM auth_check_buzei  USING    ps_bseg TYPE bseg.

  DATA: lv_subrc          TYPE subrc,
        lv_auth_grp_fistl TYPE fm_authgrc,
        lv_auth_grp_hhp   TYPE fm_authgr_measure,
        lv_auth_grp_fond  TYPE fm_authgrf,
        lv_auth_grp_fipos TYPE fm_authgrp,
        lv_fipex          TYPE fm_fipex,
        lv_act            TYPE fm_authact.

  CONSTANTS: lc_act_lhk  TYPE fm_authact VALUE '10',
             lc_act_fb02 TYPE fm_authact VALUE '12'.


  SELECT SINGLE augrp FROM fmfctr
           INTO lv_auth_grp_fistl
          WHERE fikrs EQ gs_bkpf-fikrs
            AND fictr EQ ps_bseg-fistl.

  SELECT SINGLE augrp FROM fmci
           INTO lv_auth_grp_fipos
          WHERE fikrs EQ gs_bkpf-fikrs
            AND fipos EQ ps_bseg-fipos.

  SELECT SINGLE augrp FROM fmfincode
           INTO lv_auth_grp_fond
          WHERE fincode EQ ps_bseg-geber
            AND fikrs   EQ gs_bkpf-fikrs.

  SELECT SINGLE authgrp FROM fmmeasure
           INTO lv_auth_grp_hhp
          WHERE measure EQ ps_bseg-measure
            AND fmarea  EQ gs_bkpf-fikrs.

  IF sy-tcode = gc_tcode_lhk.
    lv_act = lc_act_lhk.
  ELSE.
    lv_act = lc_act_fb02.
  ENDIF.


  DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).
  CASE lv_object_fica.
    WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

      "Berechtigungsprüfung auf Unterkonten
      "FICA_UTK"
      CLEAR lv_fipex.

      SELECT SINGLE fipex FROM fmfxpo
            INTO lv_fipex
            WHERE fipos = ps_bseg-fipos.
      IF lv_fipex IS INITIAL.
        lv_fipex = ps_bseg-fipos.
      ENDIF.

      CALL FUNCTION '/THKR/CHECK_FICA_UTK'
        EXPORTING
          activity           = lv_act
          fm_area            = gs_bkpf-fikrs
          fm_fincode_authgrp = lv_auth_grp_fond
          fm_fmfctr_authgrp  = lv_auth_grp_fistl
          fm_fipex           = lv_fipex
          fm_measure_authgrp = lv_auth_grp_hhp
*         FM_FAREA_AUTHGRP   =
        IMPORTING
          ex_subrc           = lv_subrc.

      IF lv_subrc <> 0.
        MESSAGE ID '/THKR/FI_WF_BKPF' TYPE 'E' NUMBER '201'.
      ENDIF.

    WHEN OTHERS.

      "Brechtigungsoprüfung auf Berechtigungsgruppe der Fipos
      "FICA_TRG"
      CALL FUNCTION 'Z_CHECK_FICA_TRG'
        EXPORTING
          activity           = lv_act
          fm_area            = gs_bkpf-fikrs
          fm_fincode_authgrp = lv_auth_grp_fond
          fm_fmfctr_authgrp  = lv_auth_grp_fistl
          fm_fipex_authgrp   = lv_auth_grp_fipos
          fm_measure_authgrp = lv_auth_grp_hhp
*         FM_FAREA_AUTHGRP   =
        IMPORTING
          ex_subrc           = lv_subrc.

      IF lv_subrc <> 0.
        MESSAGE ID '/THKR/FI_WF_BKPF' TYPE 'E' NUMBER '200'.
      ENDIF.

  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form auth_check_kopf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_BKPF
*&---------------------------------------------------------------------*
FORM auth_check_kopf  USING    ps_kopf TYPE bkpf.

* Prüfung auf Änderungsberechtigung im Buchungskreis
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
  ID 'BUKRS' FIELD ps_kopf-bukrs
  ID 'ACTVT' FIELD '02'.
  IF sy-subrc <> 0.
    MESSAGE s133(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
    LEAVE TO SCREEN sy-dynnr.
* Keine Berechtigung zur Bearbeitung vorhanden.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_changes_k
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_changes_k .
  DATA: ls_kass  TYPE /thkr/t_kass,
        lv_pruef TYPE char1,
        lv_rc    TYPE nrreturn.
*
*  CALL METHOD lr_alv2->check_changed_data.
* "cl_gui_cfw=>set_new_ok_code( new_code = 'ZXY' ).
*  CALL METHOD CL_GUI_CFW=>DISPATCH
*    importing return_code = lv_ret.

  IF bkpf-bktxt NE gs_bkpf-bktxt
  OR bkpf-xblnr NE gs_bkpf-xblnr
  OR bkpf-psofn NE gs_bkpf-psofn
  OR bseg-zlspr NE gs_bseg-zlspr
  OR bseg-zlsch NE gs_bseg-zlsch
  OR bseg-bvtyp NE gs_bseg-bvtyp       "#002
*  OR bseg-sgtxt NE gs_bseg-sgtxt
  OR bseg-zterm NE gs_bseg-zterm
  OR bseg-zfbdt NE gs_bseg-zfbdt
  OR bseg-zbd1t NE gs_bseg-zbd1t
  OR bseg-zbd1p NE gs_bseg-zbd1p
  OR bseg-zbd2t NE gs_bseg-zbd2t
  OR bseg-zbd2p NE gs_bseg-zbd2p
  OR bseg-zbd3t NE gs_bseg-zbd3t

*  OR bseg-zuonr NE gs_bseg-zuonr
    OR gt_texte NE gt_texte_helper.

    gv_change = abap_true.

*   Zeilen merken
    CLEAR gs_fb02.
    gs_fb02-bukrs = gs_bkpf-bukrs.
    gs_fb02-xblnr = bkpf-xblnr.
    gs_fb02-belnr = gs_bkpf-belnr.
    gs_fb02-gjahr = gs_bkpf-gjahr.
    gs_fb02-buzei = bseg-buzei.
    gs_fb02-bktxt = bkpf-bktxt.
    gs_fb02-koart = bseg-koart.
    gs_fb02-zlspr = bseg-zlspr.
    gs_fb02-zlsch_k = bseg-zlsch.
    gs_fb02-bvtyp = bseg-bvtyp.
    gs_fb02-zterm = bseg-zterm.
    gs_fb02-zfbdt = bseg-zfbdt.
    gs_fb02-zbd1t = bseg-zbd1t.
    gs_fb02-zbd1p = bseg-zbd1p.
    gs_fb02-zbd2t = bseg-zbd2t.
    gs_fb02-zbd2p = bseg-zbd2p.
    gs_fb02-zbd3t = bseg-zbd3t.
    gs_fb02-psofn = bkpf-psofn.
*    gs_fb02-zuonr = bseg-zuonr.       "#002
    gt_texte_changed = gt_texte.

  ENDIF.

*  CLEAR: ls_kass, lv_rc, gv_fehler.
*  "Feld Referenz auf Kassenzeichen prüfen
*  SELECT SINGLE * FROM /thkr/t_kass INTO ls_kass
*  WHERE blart = gs_bkpf-blart.
*  /thkr/cl_kassenzeichen=>check( EXPORTING i_xblnr       = bkpf-xblnr
*                                       is_kass       = ls_kass
*                             IMPORTING e_pruefziffer = lv_pruef ##needed
*                                       e_rc          = lv_rc ).
*  IF lv_rc NE 0.
*    gv_fehler  = abap_true.
*    MESSAGE 'Kassenzeichen ist nicht gültig!' TYPE 'S' DISPLAY LIKE 'E'.
*
*  ENDIF.

*  PERFORM check_blart USING gs_bseg.
*
*  IF NOT gs_fb02-zlsch_k IS INITIAL.
*    PERFORM check-zahlweg.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_changes_d
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_changes_d .
  DATA: ls_kass  TYPE /thkr/t_kass,
        lv_pruef TYPE char1,
        lv_rc    TYPE nrreturn.

  IF   bkpf-bktxt NE gs_bkpf-bktxt
     OR  bkpf-xblnr NE gs_bkpf-xblnr
      OR bkpf-psofn NE gs_bkpf-psofn
    "WICHTIG555"
*    OR bkpf-zz_014 NE gs_bkpf-zz_014
    OR bseg-mansp NE gs_bseg-mansp
    OR bseg-manst NE gs_bseg-manst
    OR bseg-zlsch NE gs_bseg-zlsch
    OR bseg-zlspr NE gs_bseg-zlspr
*    OR bseg-sgtxt NE gs_bseg-sgtxt
  OR bseg-zterm NE gs_bseg-zterm
  OR bseg-zfbdt NE gs_bseg-zfbdt
  OR bseg-zbd1t NE gs_bseg-zbd1t
  OR bseg-zbd1p NE gs_bseg-zbd1p
  OR bseg-zbd2t NE gs_bseg-zbd2t
  OR bseg-zbd2p NE gs_bseg-zbd2p
  OR bseg-zbd3t NE gs_bseg-zbd3t
*  OR bseg-zuonr NE gs_bseg-zuonr
  OR bseg-madat NE gs_bseg-madat
  OR bseg-mschl NE gs_bseg-mschl
  OR bseg-maber NE gs_bseg-maber
    OR bseg-bvtyp NE gs_bseg-bvtyp
*  OR bseg-hbkid NE gs_bseg-hbkid
    OR gt_texte NE gt_texte_helper.

    gv_change = abap_true.

*   Zeilen merken
    CLEAR gs_fb02.
    gs_fb02-bukrs = gs_bkpf-bukrs.
    gs_fb02-xblnr = bkpf-xblnr.
    gs_fb02-psofn = bkpf-psofn.
    "WICHTIG555"
*    gs_fb02-zz_014 = bkpf-zz_014.
    gs_fb02-belnr = gs_bkpf-belnr.
    gs_fb02-gjahr = gs_bkpf-gjahr.
    gs_fb02-buzei = bseg-buzei.
    gs_fb02-bktxt = bkpf-bktxt.
    gs_fb02-koart = bseg-koart.
    gs_fb02-mansp = bseg-mansp.
    gs_fb02-manst = bseg-manst.
    gs_fb02-zlsch_d = bseg-zlsch.
    gs_fb02-zterm = bseg-zterm.
    gs_fb02-zfbdt = bseg-zfbdt.
    gs_fb02-zbd1t = bseg-zbd1t.
    gs_fb02-zbd1p = bseg-zbd1p.
    gs_fb02-zbd2t = bseg-zbd2t.
    gs_fb02-zbd2p = bseg-zbd2p.
    gs_fb02-zbd3t = bseg-zbd3t.
    gs_fb02-zuonr = bseg-zuonr.
    gs_fb02-madat = bseg-madat.
    gs_fb02-mschl = bseg-mschl.
    gs_fb02-maber = bseg-maber.
    gs_fb02-zlspr = bseg-zlspr.
*    gs_fb02-hbkid = bseg-hbkid.
    gt_texte_changed = gt_texte.
    gs_fb02-bvtyp = bseg-bvtyp.

  ENDIF.

*** begin of #001 ***
  CLEAR gv_fehler.
  "Fehlermeldung auskommentiert auf Wunsch von Waldemar
  " Mahnsperre darf nur SPACE oder 1 sein
*  IF bseg-mansp <> space AND bseg-mansp <> '1'.
*    gv_fehler = abap_true.
*    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*      EXPORTING
*        i_arbgb = '/THKR/FI_WF_BKPF'
*        i_dtype = 'E'
*        i_msgnr = '176'.
*  ENDIF.
  "Fehlermeldung auskommentiert auf Wunsch von Waldemar
*  IF gs_bseg-mansp <> bseg-mansp.
*    " möglich von 2, 3, 4, 5, oder 6 auf 1 (nicht auf 0)
*    IF gs_bseg-mansp CA '23456' AND bseg-mansp = space.
*      gv_fehler = abap_true.
*      CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*        EXPORTING
*          i_arbgb = '/THKR/FI_WF_BKPF'
*          i_dtype = 'E'
*          i_msgnr = '181'.
*    ENDIF.
*  ENDIF.
*** end of #001 ***

*  PERFORM check_blart USING gs_bseg.

  IF NOT gs_fb02-mansp IS INITIAL OR
     NOT gs_fb02-manst IS INITIAL.
    PERFORM check-mahnbereich.
  ENDIF.
*
*  CLEAR: ls_kass, lv_rc.
*  "Feld Referenz auf Kassenzeichen prüfen
*  SELECT SINGLE * FROM /thkr/t_kass INTO ls_kass
*  WHERE blart = gs_bkpf-blart.
*  /thkr/cl_kassenzeichen=>check( EXPORTING i_xblnr       = bkpf-xblnr
*                                       is_kass       = ls_kass
*                             IMPORTING e_pruefziffer = lv_pruef ##needed
*                                       e_rc          = lv_rc ).
*  IF lv_rc NE 0.
*    gv_fehler  = abap_true.
*    MESSAGE 'Kassenzeichen ist nicht gültig!' TYPE 'S' DISPLAY LIKE 'E'.
**    LEAVE TO SCREEN sy-dynnr.
*
*  ENDIF.


*  IF NOT gs_fb02-zlsch_d IS INITIAL.
*    PERFORM check-zahlweg.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check-Mahnbereich
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check-mahnbereich .

  DATA: ld_mahna   TYPE mahna.
  DATA: ls_t047b   TYPE t047b.
  DATA: ld_var03   TYPE maber.


*  CLEAR gv_fehler.                                       " #001
  CHECK bseg-manst <> 0.
  IF bseg-koart = 'D'.
    SELECT SINGLE mahna INTO ld_mahna FROM knb5
                       WHERE kunnr = bseg-kunnr
                       AND   bukrs = bseg-bukrs
                       AND   maber = bseg-maber.
  ELSEIF bseg-koart = 'K'.
    SELECT SINGLE mahna INTO ld_mahna FROM lfb5
                       WHERE lifnr = bseg-lifnr
                       AND   bukrs = bseg-bukrs
                       AND   maber = bseg-maber.
  ENDIF.

  SELECT SINGLE * FROM t047b INTO ls_t047b
                             WHERE mahna = ld_mahna
                             AND   mahns = bseg-manst.

  IF sy-subrc <> 0.
    gv_fehler  = abap_true.
    IF bseg-maber IS INITIAL.
      ld_var03 = '''  '''.
    ELSE.
      ld_var03 = bseg-maber.
    ENDIF.

    MESSAGE s882(fm) WITH bseg-manst ld_mahna ld_var03 DISPLAY LIKE 'E'.
*    LEAVE TO SCREEN sy-dynnr.
*    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*      EXPORTING
*        i_arbgb = 'FM'
*        i_dtype = 'E'
*        i_msgnr = '882'
*        i_var01 = bseg-manst
*        i_var02 = ld_mahna
*        i_var03 = ld_var03.
*    IF 1 = 2.
*      MESSAGE i882(fm).
*    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check-Zahlweg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check-zahlweg .

  DATA: lv_zwels   TYPE dzwels.
  DATA: lv_cpd     TYPE xcpdk.


  CHECK ok-code IS INITIAL  OR
        ok-code = 'AEND'.

*  CLEAR gv_fehler.                                                      " #001

  "Zahlwege des Geschäftspartners bestimmen
  IF bseg-kunnr IS NOT INITIAL.
    SELECT SINGLE knb1~zwels, kna1~xcpdk FROM knb1
      INNER JOIN kna1 ON kna1~kunnr = knb1~kunnr
      INTO (@lv_zwels, @lv_cpd)
      WHERE knb1~kunnr = @bseg-kunnr AND knb1~bukrs = @bseg-bukrs.
  ENDIF.
  IF bseg-lifnr IS NOT INITIAL.
    SELECT SINGLE lfb1~zwels, lfa1~xcpdk FROM lfb1
      INNER JOIN lfa1 ON lfa1~lifnr = lfb1~lifnr
      INTO (@lv_zwels, @lv_cpd)
      WHERE lfb1~lifnr = @bseg-lifnr AND lfb1~bukrs = @bseg-bukrs.
  ENDIF.

  CHECK lv_cpd <> 'X'.  "Keine Prüfung bei CPD-Geschäftspartnern!
*
  IF NOT lv_zwels CS bseg-zlsch.
*      IF lv_zahlweg = 'I' OR lv_zahlweg = 'C'. "Intern oder Eilüberweisung
*        <ls_message>-type       = 'W'.
*      ELSE.
*        <ls_message>-type       = 'E'.
*      ENDIF.
    gv_fehler  = abap_true.
    MESSAGE s013(/thkr/fi_wf_bkpf) WITH bseg-zlsch DISPLAY LIKE 'E' .
*    LEAVE TO SCREEN sy-dynnr.
* Der Zahlweg &1 ist beim Geschäftspartner nicht hinterlegt.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_blart
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_BSEG
*&---------------------------------------------------------------------*
FORM check_blart  USING    ps_bseg TYPE bseg.


  DATA: lr_tab TYPE REF TO data.

  FIELD-SYMBOLS: <ft_blart_range> TYPE /thkr/t_fi_blart.


*** Belegart prüfen
  CALL METHOD /thkr/cl_fi_helper=>get_param
    EXPORTING
      iv_programm  = '/THKR/TPBR_FB02'
      iv_fieldname = 'BLART'
      iv_entrykey  = '00000001'
    IMPORTING
      et_range     = lr_tab
    EXCEPTIONS
      no_data      = 1
      OTHERS       = 2.
  IF sy-subrc NE 0.
    MESSAGE e375(/thkr/fi_wf_bkpf).
* Fehler bei der Ermittlung gültiger Belegarten aus der Parametertabelle.
  ENDIF.
  ASSIGN lr_tab->* TO <ft_blart_range>.
*    Für angegebene Belegarten darf nur der Zahlweg C verwendet werden.
  IF ps_bseg-h_blart NOT IN <ft_blart_range>.
**     AND ps_bseg-zlsch NE 'C'.
    gv_fehler = abap_true.
    MESSAGE e377(/thkr/fi_wf_bkpf) WITH ps_bseg-h_blart.
* Für die Belegart &1 ist nur der Zahlweg 'C' zugelassen.
  ENDIF.

ENDFORM.

FORM check_changes_ausgegl.
  IF bkpf-bktxt NE gs_bkpf-bktxt.
    gv_change = abap_true.
  ENDIF.

*  CALL METHOD lr_alv2->check_changed_data.
** cl_gui_cfw=>set_new_ok_code( new_code = 'ZXY' ).
*  CALL METHOD CL_GUI_CFW=>DISPATCH
*    importing return_code = lv_ret.

  SELECT * FROM bseg INTO TABLE @DATA(lt_bseg_old) WHERE belnr = @gs_bkpf-belnr AND bukrs = @gs_bkpf-bukrs AND gjahr = @gs_bkpf-gjahr.

  IF lt_bseg NE lt_bseg_old.
    gv_change = abap_true.
  ENDIF.
  IF gv_change = abap_true.
    CLEAR gs_fb02.
    gs_fb02-bukrs = gs_bkpf-bukrs.
    gs_fb02-belnr = gs_bkpf-belnr.
    gs_fb02-gjahr = gs_bkpf-gjahr.
    gs_fb02-buzei = bseg-buzei.
    gs_fb02-bktxt = bkpf-bktxt.
    gs_fb02-koart = bseg-koart.
    gs_fb02-zlspr = bseg-zlspr.
    gs_fb02-zlsch_k = bseg-zlsch.
  ENDIF.
  cl_gui_cfw=>flush( ).
ENDFORM.

FORM sichern_ausgegl.
*  DATA: ls_fb02      LIKE zfi_fb02,
*        lv_belnr(16) TYPE c.
*
  IF gv_change IS INITIAL.
    MESSAGE e351(/thkr/fi_wf_bkpf).
* Es wurden keine Änderungen an den Daten vorgenommen.
  ELSE.
* Kopfdaten anreichern
    gs_fb02-status = '15'.
    gs_fb02-usnam = sy-uname.
    gs_fb02-cpudt = sy-datum.
    gs_fb02-cputm = sy-uzeit.

* vorhandene Belege prüfen und Nummer vergeben
    SELECT lfdnr FROM /thkr/fb02c UP TO 1 ROWS
      INTO gs_fb02-lfdnr
       WHERE bukrs = gs_bkpf-bukrs
        AND belnr = gs_bkpf-belnr
        AND gjahr = gs_bkpf-gjahr
      ORDER BY lfdnr DESCENDING.
    ENDSELECT.

    DATA objid TYPE cdobjectv.
    CONCATENATE gs_bkpf-bukrs gs_bkpf-belnr gs_bkpf-gjahr INTO objid.
    CALL FUNCTION 'CHANGEDOCUMENT_OPEN'
      EXPORTING
        objectclass             = 'BELEG'
        objectid                = objid
*       PLANNED_CHANGE_NUMBER   = ' '
        planned_or_real_changes = 'R'
      EXCEPTIONS
        sequence_invalid        = 1
        OTHERS                  = 2.
    IF bkpf-bktxt NE gs_bkpf-bktxt. "Nur Änderungszeiger schreiben, wenn tatsächlich Änderungen vorgenommen wurden an diesem Teil
      IF gs_bkpf-bktxt IS INITIAL.
        DATA(change_indicator) = 'I'.
      ELSEIF bkpf-bktxt IS INITIAL.
        change_indicator = 'D'.
      ELSE.
        change_indicator = 'U'.
      ENDIF.
      DATA(new_text) = bkpf-bktxt.
      bkpf = gs_bkpf.
      bkpf-bktxt = new_text.

      ADD 1 TO gs_fb02-lfdnr.
* Daten speichern
      INSERT /thkr/fb02c FROM gs_fb02.
      IF sy-subrc NE 0.
        ROLLBACK WORK.
        PERFORM init.
        MESSAGE e352(/thkr/fi_wf_bkpf).
      ELSE.
        CALL FUNCTION 'CHANGEDOCUMENT_SINGLE_CASE' "Änderungszeiger in CDPOS und CDHDR
          EXPORTING
            tablename        = 'BKPF'
            change_indicator = change_indicator
            workarea_old     = gs_bkpf
            workarea_new     = bkpf.
        IF sy-subrc = 0.
          MODIFY bkpf FROM bkpf.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.
    ENDIF.
    DATA: lt_bseg_old LIKE lt_bseg,
          ls_bseg_old LIKE LINE OF lt_bseg_old.
    SELECT * FROM bseg INTO TABLE @lt_bseg_old WHERE belnr = @gs_bkpf-belnr AND bukrs = @gs_bkpf-bukrs AND gjahr = @gs_bkpf-gjahr.
    IF lt_bseg NE lt_bseg_old.
      LOOP AT lt_bseg INTO DATA(ls_bseg).
        READ TABLE lt_bseg_old INDEX sy-tabix INTO ls_bseg_old.
        IF ls_bseg_old-sgtxt IS INITIAL.
          change_indicator = 'I'.
        ELSEIF ls_bseg-sgtxt IS INITIAL.
          change_indicator = 'D'.
        ELSE.
          change_indicator = 'U'.
        ENDIF.
        IF ls_bseg-sgtxt NE ls_bseg_old-sgtxt.
          ADD 1 TO gs_fb02-lfdnr.
          gs_fb02-buzei = ls_bseg-buzei.
* Daten speichern
          INSERT /thkr/fb02c FROM gs_fb02.
          IF sy-subrc NE 0.
            ROLLBACK WORK.
            PERFORM init.
            MESSAGE e352(/thkr/fi_wf_bkpf).
          ELSE.
            CALL FUNCTION 'CHANGEDOCUMENT_SINGLE_CASE' "Änderungszeiger in CDPOS und CDHDR
              EXPORTING
                tablename        = 'BSEG'
                change_indicator = change_indicator
                workarea_old     = ls_bseg_old
                workarea_new     = ls_bseg.
            IF sy-subrc = 0.
              MODIFY bseg FROM ls_bseg.
            ELSE.
              ROLLBACK WORK.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'CHANGEDOCUMENT_CLOSE'
      EXPORTING
        date_of_change          = sy-datum
        objectclass             = 'BELEG'
        objectid                = objid
        tcode                   = sy-tcode
        time_of_change          = sy-uzeit
        username                = sy-uname
        object_change_indicator = 'U'
        planned_or_real_changes = 'R'
*    IMPORTING
*       CHANGENUMBER            =
      EXCEPTIONS
        header_insert_failed    = 1
        no_position_inserted    = 2
        object_invalid          = 3
        open_missing            = 4
        position_insert_failed  = 5
        OTHERS                  = 6.
  ENDIF.
ENDFORM.
*** begin of #001 ***
*&---------------------------------------------------------------------*
*& Form check_changes_d_lok
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_changes_d_lok .
*
*  CALL METHOD lr_alv2->check_changed_data.
** cl_gui_cfw=>set_new_ok_code( new_code = 'ZXY' ).
*  CALL METHOD CL_GUI_CFW=>DISPATCH
*    importing return_code = lv_ret.

  IF bseg-manst NE gs_bseg-manst.

    gv_change = abap_true.

*   Zeilen merken
    CLEAR gs_fb02.
    gs_fb02-bukrs = gs_bkpf-bukrs.
    gs_fb02-belnr = gs_bkpf-belnr.
    gs_fb02-gjahr = gs_bkpf-gjahr.
    gs_fb02-buzei = bseg-buzei.
    gs_fb02-koart = bseg-koart.
    gs_fb02-manst = bseg-manst.

  ENDIF.

  " Prüfung bei Änderung Mahnstufe
  IF gv_change = abap_true AND bseg-manst <> '1'.
    MESSAGE e178(/thkr/fi_wf_bkpf) WITH bseg-manst.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form sichern_lok
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sichern_lok .

*  DATA: lt_bkpf     TYPE STANDARD TABLE OF bkpf,
*        lt_bseg     TYPE STANDARD TABLE OF bseg,
*        lt_bseg_old TYPE STANDARD TABLE OF fbseg,
*        lt_bseg_new TYPE STANDARD TABLE OF fbseg,
*        lv_objectid TYPE cdobjectv,
*        lv_status   TYPE /THKR/DTE_fi_wf_status,
*        lv_pos_upd  TYPE cdpos-chngind,
*        lv_kopf_upd TYPE cdpos-chngind.
*
*  " Setzen Status auf nicht erfolgreich
*  lv_status = 80.
*
*  " Ermittln der BSEG Einträge aus der Datenbank
*  SELECT * INTO TABLE @lt_bseg FROM bseg WHERE bukrs = @gs_fb02-bukrs "#EC CI_ALL_FIELDS_NEEDED
*                                           AND belnr = @gs_fb02-belnr
*                                           AND gjahr = @gs_fb02-gjahr.
*  IF sy-subrc <> 0.
*    " Keine Belegzeilen gefunden
*    MESSAGE s179(/THKR/FI_WF_BKPF) WITH gs_fb02-bukrs gs_fb02-belnr gs_fb02-gjahr.
*  ELSE.
*
*    READ TABLE lt_bseg WITH KEY buzei = gs_fb02-buzei ASSIGNING FIELD-SYMBOL(<fs_bseg>).
*    IF sy-subrc EQ 0.
*
*      " Sichern des unveränderten Satzes
*      APPEND INITIAL LINE TO lt_bseg_old ASSIGNING FIELD-SYMBOL(<ls_bseg_old>).
*      MOVE-CORRESPONDING <fs_bseg> TO <ls_bseg_old>.
*
*      " Aufbereiten Mahnstufe
*      IF <fs_bseg>-manst NE gs_fb02-manst.
*        " Übergabe neue Mahnstufe
*        <fs_bseg>-manst = gs_fb02-manst.
*        " Sichern des veränderten Satzes
*        APPEND INITIAL LINE TO lt_bseg_new ASSIGNING FIELD-SYMBOL(<ls_bseg_new>).
*        MOVE-CORRESPONDING <fs_bseg> TO <ls_bseg_new>.
*        " Änderungsbelegtrigger
*        lv_pos_upd = 'U'.
*        DATA(lv_change) = abap_true.
*      ENDIF.
*
*    ENDIF.
*    SORT lt_bseg BY buzei.
*
*    " Ermitteln zusätzliche Daten für den Update Baustein
*    SELECT * INTO TABLE @DATA(lt_bkdf) FROM bkdf WHERE bukrs = @gs_fb02-bukrs "#EC CI_ALL_FIELDS_NEEDED
*                                                   AND belnr = @gs_fb02-belnr
*                                                   AND gjahr = @gs_fb02-gjahr.
*    IF sy-subrc <> 0.
*      FREE lt_bkdf.
*    ENDIF.
*
*    SELECT * INTO TABLE @DATA(lt_bsec) FROM bsec WHERE bukrs = @gs_fb02-bukrs "#EC CI_ALL_FIELDS_NEEDED
*                                                   AND belnr = @gs_fb02-belnr
*                                                   AND gjahr = @gs_fb02-gjahr.
*    IF sy-subrc <> 0.
*      FREE lt_bsec.
*    ENDIF.
*
*    SELECT * INTO TABLE @DATA(lt_bsed) FROM bsed WHERE bukrs = @gs_fb02-bukrs "#EC CI_ALL_FIELDS_NEEDED
*                                                   AND belnr = @gs_fb02-belnr
*                                                   AND gjahr = @gs_fb02-gjahr.
*    IF sy-subrc <> 0.
*      FREE lt_bsed.
*    ENDIF.
*
*    SELECT * INTO TABLE @DATA(lt_bset) FROM bset WHERE bukrs = @gs_fb02-bukrs "#EC CI_ALL_FIELDS_NEEDED
*                                                   AND belnr = @gs_fb02-belnr
*                                                   AND gjahr = @gs_fb02-gjahr.
*    IF sy-subrc <> 0.
*      FREE lt_bset.
*    ENDIF.
*
*    " Sichern der alten Werte für Übergabe an AVVISO Fuba
*    DATA(ls_bkpf) = gs_bkpf.
*    DATA(lt_bsed_old) = lt_bsed.
*
*    APPEND gs_bkpf TO lt_bkpf.        " Übernahme für Baustein
*    CALL FUNCTION 'CHANGE_DOCUMENT'
*      TABLES
*        t_bkdf = lt_bkdf
*        t_bkpf = lt_bkpf
*        t_bsec = lt_bsec
*        t_bsed = lt_bsed
*        t_bseg = lt_bseg
*        t_bset = lt_bset.
*
*    IF sy-subrc = 0.
*      " Commit muss erst ausgeführt sein, damit alles schon auf der DB ist
*      COMMIT WORK AND WAIT.
*
*      " AVVSIO Übertragung
*      CALL FUNCTION 'Z_FI_ALE_CHANGE_DOCUMENT'
*        EXPORTING
*          i_bkpf_old       = gs_bkpf                 " ursprünglicher FI-Belegkopf
*          i_bkpf_new       = ls_bkpf                 " geänderter FI-Belegkopf
*        TABLES
*          t_bseg_old       = lt_bseg_old             " ursprüngliche FI-Belegzeilen
*          t_bseg_new       = lt_bseg                 " geänderte FI-Belegzeilen
*          t_bsed_old       = lt_bsed_old             " Belegsegment Wechselfelder
*          t_bsed_new       = lt_bsed                 " Belegsegment Wechselfelder
*        EXCEPTIONS
*          no_fi_ale_change = 1                       " Keine Änderungsdaten für FI ALE versendet
*          OTHERS           = 2.
*      IF sy-subrc <> 0.
*        " AVVISO IDOC nicht angetossen
*        MESSAGE w180(/THKR/FI_WF_BKPF).
*      ENDIF.
*
*      " Commit muss ausgeführt werden, damit IDOC erzeugt wird
*      COMMIT WORK.
*
*      "WICHTIG555"
**      " Zusatzfelder Kopf
**      CLEAR lv_change.
**      IF ls_bkpf-zz_k1 <> gs_fb02-zz_k1.
**        ls_bkpf-zz_k1 = gs_fb02-zz_k1.
**        lv_change = abap_true.
**      ENDIF.
**      IF ls_bkpf-zz_k2 <> gs_fb02-zz_k2.
**        ls_bkpf-zz_k2 = gs_fb02-zz_k2.
**        lv_change = abap_true.
**      ENDIF.
**      IF ls_bkpf-zz_k3 <> gs_fb02-zz_k3.
**        ls_bkpf-zz_k3 = gs_fb02-zz_k3.
**        lv_change = abap_true.
**      ENDIF.
*
*      IF lv_change IS NOT INITIAL.
*        UPDATE bkpf FROM ls_bkpf.
*        " Setze Änderungsbelegtrigger
*        lv_kopf_upd = 'U'.
*      ENDIF.
*
*      " Erzeugen Objektid
*      lv_objectid(3)    = sy-mandt.
*      lv_objectid+3(4)  = gs_fb02-bukrs.
*      lv_objectid+7(10) = gs_fb02-belnr.
*      lv_objectid+17(4) = gs_fb02-gjahr.
*
*      " Schreiben Änderungsbelege
*      CALL FUNCTION 'BELEG_WRITE_DOCUMENT'
*        EXPORTING
*          objectid = lv_objectid
*          tcode    = 'FB02'
*          utime    = sy-uzeit
*          udate    = sy-datum
*          username = sy-uname
*          n_bkpf   = ls_bkpf
*          o_bkpf   = gs_bkpf
*          upd_bkpf = lv_kopf_upd
*          upd_bseg = lv_pos_upd
*        TABLES
*          xbseg    = lt_bseg_new
*          ybseg    = lt_bseg_old.
*
*      " Beleg erfolgreich geändert
*      lv_status = 75.
*
*    ENDIF.
*
*    " Speichern der Stausänderung in der ZFI_FB02
*    gs_fb02-status = lv_status.
*    MODIFY /thkr/fb02c FROM gs_fb02.
*
*  ENDIF.

ENDFORM.
*** end of #001 ***

FORM show_position_text.


  DATA: lr_salv2      TYPE REF TO cl_salv_table.

  IF gv_change IS NOT INITIAL.
    gt_texte = gt_texte_changed.
  ENDIF.


  IF lr_container2 IS NOT BOUND.
    CREATE OBJECT lr_container2
      EXPORTING
        container_name = 'CC_POSITIONEN'
        repid          = sy-repid
        dynnr          = sy-dynnr.

    lr_alv2 = NEW cl_gui_alv_grid( i_parent      = lr_container2 " in default container einbetten
                                         i_appl_events = abap_true ).


    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lr_salv2
      CHANGING
        t_table      = gt_texte.

    DATA(it_fcat2) = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns      = lr_salv2->get_columns( )
                                                                       r_aggregations = lr_salv2->get_aggregations( ) ).
    DELETE it_fcat2 WHERE fieldname NE 'BUZEI' AND
                          fieldname NE 'SGTXT' AND
                          fieldname NE 'ZUONR'.

    LOOP AT it_fcat2 INTO DATA(ls_fcat2).
      CASE ls_fcat2-fieldname.
        WHEN 'SGTXT'.
          ls_fcat2-edit      = 'X'.
          ls_fcat2-coltext   = 'Positionstext'.
          ls_fcat2-outputlen = 50.
        WHEN 'ZUONR'.
          IF sy-tcode <> gc_tcode_justiz.
            ls_fcat2-edit      = 'X'.
          ELSE.
            ls_fcat2-edit      = ' '.
          ENDIF.
          ls_fcat2-coltext   = 'Zuordnung'.
          ls_fcat2-outputlen = 20.
      ENDCASE.
      MODIFY it_fcat2 FROM ls_fcat2.
    ENDLOOP.

    SORT gt_texte BY buzei ASCENDING.

    DATA(lv_layout2) = VALUE lvc_s_layo( zebra      = abap_true             " ALV-Control: Alternierende Zeilenfarbe (Zebramuster)
                                        cwidth_opt = 'A'                   " ALV-Control: Spaltenbreite optimieren
                                        no_toolbar = 'X' ).
    lr_alv2->set_table_for_first_display( EXPORTING
                                          is_layout          = lv_layout2
                                        CHANGING
                                          it_fieldcatalog    = it_fcat2
                                          it_outtab          = gt_texte ).
    lr_alv2->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
    lr_alv2->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
    lr_alv2->set_ready_for_input( i_ready_for_input = 1 ).


    cl_gui_alv_grid=>set_focus( control = lr_alv2 ).
    cl_abap_list_layout=>suppress_toolbar( ).

  ELSE.

    CALL METHOD lr_alv2->refresh_table_display.

  ENDIF.

ENDFORM.
"Ausnahme für Kasse:
"Änderungen direkt Sichern ohne 4AP.
FORM sichern_jus.
*  DATA lt_kopf TYPE TABLE OF /thkr/fb02c.
  CONSTANTS: gc_x  TYPE c LENGTH 1 VALUE 'X'.
  DATA lt_bseg TYPE bseg_t.
  DATA ls_bseg TYPE bseg.
  DATA ls_bkpf TYPE bkpf.
  DATA lt_bkpf TYPE TABLE OF bkpf.
  DATA lt_accchg TYPE TABLE OF accchg.
  DATA ls_accchg TYPE accchg.
  DATA lv_kopf TYPE xflag.
  DATA lv_pos  TYPE xflag.
  DATA ls_return TYPE bapiret2.

  DATA: ls_bkpf_old TYPE bkpf,
        lt_bseg_old TYPE STANDARD TABLE OF fbseg,
        lt_bseg_new TYPE STANDARD TABLE OF fbseg,
        lv_objectid TYPE cdobjectv,
        lv_kopf_upd TYPE cdchngind,
        lv_pos_upd  TYPE cdchngind.

  FIELD-SYMBOLS: <fs_bseg> TYPE bseg.

  IF gv_change IS INITIAL.
    MESSAGE e351(/thkr/fi_wf_bkpf).
* Es wurden keine Änderungen an den Daten vorgenommen.
  ELSE.

    SELECT SINGLE * FROM bkpf INTO @ls_bkpf   "#EC CI_ALL_FIELDS_NEEDED
      WHERE belnr  = @gs_fb02-belnr
      AND   bukrs  = @gs_fb02-bukrs
      AND   gjahr  = @gs_fb02-gjahr.

    IF ls_bkpf-bktxt <> gs_fb02-bktxt OR
      ls_bkpf-xblnr <> gs_fb02-xblnr OR
      ls_bkpf-psofn <> gs_fb02-psofn.
      lv_kopf_upd = 'U'.
      lv_kopf = 'X'.
    ENDIF.

    ls_bkpf_old = ls_bkpf.

    ls_bkpf-bktxt = gs_fb02-bktxt.
    ls_bkpf-xblnr = gs_fb02-xblnr.
    ls_bkpf-psofn = gs_fb02-psofn.

    APPEND ls_bkpf TO lt_bkpf.

    CALL FUNCTION 'READ_BSEG'
      EXPORTING
        xbelnr         = gs_fb02-belnr
        xbukrs         = gs_fb02-bukrs
        xbuzei         = gs_fb02-buzei
        xgjahr         = gs_fb02-gjahr
        no_auth_check  = 'X'
      IMPORTING
*       XBSEC          =
*       XBSED          =
        xbseg          = ls_bseg
*       XBSEGA         =
      EXCEPTIONS
        key_incomplete = 1
        not_authorized = 2
        not_found      = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    ls_bseg-zlspr = gs_fb02-zlspr.
    ls_bseg-mansp = gs_fb02-mansp.
    ls_bseg-manst = gs_fb02-manst.
*  IF ls_bseg-koart = 'K'.
    ls_bseg-bvtyp = gs_fb02-bvtyp.                    " Partnerbank
*  ENDIF.

    IF gs_fb02-zlsch_k IS NOT INITIAL .
      ls_bseg-zlsch = gs_fb02-zlsch_k.
    ENDIF.
    IF gs_fb02-zlsch_d IS NOT INITIAL .
      ls_bseg-zlsch = gs_fb02-zlsch_d.
    ENDIF.

    ls_bseg-zterm = gs_fb02-zterm.
    ls_bseg-zfbdt = gs_fb02-zfbdt.
    ls_bseg-zbd1t = gs_fb02-zbd1t.
    ls_bseg-zbd2t = gs_fb02-zbd2t.
    ls_bseg-zbd3t = gs_fb02-zbd3t.
    ls_bseg-zbd1p = gs_fb02-zbd1p.
    ls_bseg-zbd2p = gs_fb02-zbd2p.


    IF ls_bseg-koart = 'D'.

      ls_bseg-madat = gs_fb02-madat.
      ls_bseg-mschl = gs_fb02-mschl.
      ls_bseg-maber = gs_fb02-maber.
      ls_bseg-hbkid = gs_fb02-hbkid.


    ENDIF.

    IF ls_bseg-zlsch IS NOT INITIAL AND gs_fb02-zlsch_d IS INITIAL AND gs_fb02-zlsch_k IS INITIAL.
      CLEAR ls_bseg-zlsch.
    ENDIF.

    SELECT * FROM bseg INTO TABLE lt_bseg     "#EC CI_ALL_FIELDS_NEEDED
  WHERE    belnr  = gs_fb02-belnr                       "#EC CI_NOORDER
  AND      bukrs  = gs_fb02-bukrs
  AND      gjahr  = gs_fb02-gjahr.

    READ TABLE  lt_bseg WITH KEY buzei = gs_fb02-buzei ASSIGNING <fs_bseg> .
    IF sy-subrc EQ 0.

      " Sichern des unveränderten Satzes
      APPEND INITIAL LINE TO lt_bseg_old ASSIGNING FIELD-SYMBOL(<ls_bseg_old>).
      MOVE-CORRESPONDING <fs_bseg> TO <ls_bseg_old>.

      "    Aufbereiten  Änderungsdaten
      IF <fs_bseg>-zlspr NE gs_fb02-zlspr.
        CONCATENATE gs_fb02-buzei 'BSEG-ZLSPR' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zlspr. ls_accchg-newval = gs_fb02-zlspr.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      IF <fs_bseg>-zlsch NE ls_bseg-zlsch.
        CONCATENATE gs_fb02-buzei 'BSEG-ZLSCH' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zlsch. ls_accchg-newval = ls_bseg-zlsch.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      IF <fs_bseg>-mansp NE gs_fb02-mansp.
        CONCATENATE gs_fb02-buzei 'BSEG-MANSP' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-mansp. ls_accchg-newval = gs_fb02-mansp.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      IF <fs_bseg>-manst NE gs_fb02-manst.
        CONCATENATE gs_fb02-buzei 'BSEG-MANST' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-manst. ls_accchg-newval = gs_fb02-manst.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      IF <fs_bseg>-bvtyp NE gs_fb02-bvtyp.            " Partnerbank
        CONCATENATE gs_fb02-buzei 'BSEG-BVTYP' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-bvtyp. ls_accchg-newval = gs_fb02-bvtyp.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.

      "Zahlungsschlüssel
      IF <fs_bseg>-zterm NE gs_fb02-zterm.
        CONCATENATE gs_fb02-buzei 'BSEG-ZTERM' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zterm. ls_accchg-newval = gs_fb02-zterm.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Basisdatum
      IF <fs_bseg>-zfbdt NE gs_fb02-zfbdt.
        CONCATENATE gs_fb02-buzei 'BSEG-ZFBDT' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zfbdt. ls_accchg-newval = gs_fb02-zfbdt.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Tag 1
      IF <fs_bseg>-zbd1t NE gs_fb02-zbd1t.
        CONCATENATE gs_fb02-buzei 'BSEG-ZBD1T' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zbd1t. ls_accchg-newval = gs_fb02-zbd1t.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Prozent 1
      IF <fs_bseg>-zbd1p NE gs_fb02-zbd1p.
        CONCATENATE gs_fb02-buzei 'BSEG-ZBD1P' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zbd1p. ls_accchg-newval = gs_fb02-zbd1p.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Tag 2
      IF <fs_bseg>-zbd2t NE gs_fb02-zbd2t.
        CONCATENATE gs_fb02-buzei 'BSEG-ZBD2T' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zbd2t. ls_accchg-newval = gs_fb02-zbd2t.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Prozent 2
      IF <fs_bseg>-zbd2p NE gs_fb02-zbd2p.
        CONCATENATE gs_fb02-buzei 'BSEG-ZBD2P' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zbd2p. ls_accchg-newval = gs_fb02-zbd2p.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Frist
      IF <fs_bseg>-zbd3t NE gs_fb02-zbd3t.
        CONCATENATE gs_fb02-buzei 'BSEG-ZBD3T' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zbd3t. ls_accchg-newval = gs_fb02-zbd3t.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Mahndatum
      IF <fs_bseg>-madat NE gs_fb02-madat.
        CONCATENATE gs_fb02-buzei 'BSEG-MADAT' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-madat. ls_accchg-newval = gs_fb02-madat.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Mahnschlüssel
      IF <fs_bseg>-mschl NE gs_fb02-mschl.
        CONCATENATE gs_fb02-buzei 'BSEG-MSCHL' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-mschl. ls_accchg-newval = gs_fb02-mschl.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Mahnbereich
      IF <fs_bseg>-maber NE gs_fb02-maber.
        CONCATENATE gs_fb02-buzei 'BSEG-MABER' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-maber. ls_accchg-newval = gs_fb02-maber.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.
      "Hausbank
      IF <fs_bseg>-hbkid NE gs_fb02-hbkid.
        CONCATENATE gs_fb02-buzei 'BSEG-HBKID' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-hbkid. ls_accchg-newval = gs_fb02-hbkid.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
      ENDIF.


      READ TABLE gt_texte_changed WITH KEY buzei = gs_fb02-buzei ASSIGNING FIELD-SYMBOL(<fs_text>).
      IF sy-subrc = 0.

        IF <fs_bseg>-sgtxt NE <fs_text>-sgtxt.
          CONCATENATE gs_fb02-buzei 'BSEG-SGTXT' INTO ls_accchg-fdname.
          ls_accchg-oldval = <fs_bseg>-sgtxt. ls_accchg-newval = <fs_text>-sgtxt.
          APPEND ls_accchg TO lt_accchg.
          lv_pos = gc_x.
          ls_bseg-sgtxt = <fs_text>-sgtxt.
        ENDIF.

        IF <fs_bseg>-zuonr NE <fs_text>-zuonr.
          CONCATENATE gs_fb02-buzei 'BSEG-ZUONR' INTO ls_accchg-fdname.
          ls_accchg-oldval = <fs_bseg>-zuonr. ls_accchg-newval = <fs_text>-zuonr.
          APPEND ls_accchg TO lt_accchg.
          lv_pos = gc_x.
          ls_bseg-zuonr = <fs_text>-zuonr.
        ENDIF.

      ENDIF.

*   Übergabe Werte
      <fs_bseg> = ls_bseg.

      IF lv_pos IS NOT INITIAL.
        " Sichern des veränderten Satzes
        APPEND INITIAL LINE TO lt_bseg_new ASSIGNING FIELD-SYMBOL(<ls_bseg_new>).
        MOVE-CORRESPONDING <fs_bseg> TO <ls_bseg_new>.
        " Änderungsbelegtrigger
        lv_pos_upd = 'U'.
      ENDIF.

      LOOP AT gt_texte_changed ASSIGNING <fs_text> WHERE buzei <> gs_fb02-buzei.
        CLEAR lv_pos.

        READ TABLE  lt_bseg WITH KEY buzei = <fs_text>-buzei ASSIGNING FIELD-SYMBOL(<fs_bseg_text>) .
        IF sy-subrc = 0.
          APPEND INITIAL LINE TO lt_bseg_old ASSIGNING <ls_bseg_old>.
          MOVE-CORRESPONDING <fs_bseg_text> TO <ls_bseg_old>.

          IF <fs_bseg_text>-sgtxt NE <fs_text>-sgtxt.
            CONCATENATE <fs_text>-buzei 'BSEG-SGTXT' INTO ls_accchg-fdname.
            ls_accchg-oldval = <fs_bseg_text>-sgtxt. ls_accchg-newval = <fs_text>-sgtxt.
            APPEND ls_accchg TO lt_accchg.
            lv_pos = gc_x.
            <fs_bseg_text>-sgtxt = <fs_text>-sgtxt.
          ENDIF.

          IF <fs_bseg_text>-zuonr NE <fs_text>-zuonr.
            CONCATENATE <fs_text>-buzei 'BSEG-ZUONR' INTO ls_accchg-fdname.
            ls_accchg-oldval = <fs_bseg_text>-zuonr. ls_accchg-newval = <fs_text>-zuonr.
            APPEND ls_accchg TO lt_accchg.
            lv_pos = gc_x.
            <fs_bseg_text>-zuonr = <fs_text>-zuonr.
          ENDIF.

        ENDIF.

        IF lv_pos IS NOT INITIAL.
          " Sichern des veränderten Satzes
          APPEND INITIAL LINE TO lt_bseg_new ASSIGNING <ls_bseg_new>.
          MOVE-CORRESPONDING <fs_bseg_text> TO <ls_bseg_new>.
          " Änderungsbelegtrigger
          lv_pos_upd = 'U'.
        ENDIF.

      ENDLOOP.

      LOOP AT lt_bseg_old ASSIGNING FIELD-SYMBOL(<fs_bseg_old>).
        READ TABLE lt_bseg_new WITH KEY buzei = <fs_bseg_old>-buzei TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          APPEND <fs_bseg_old> TO lt_bseg_new.
        ENDIF.
      ENDLOOP.

      SORT lt_bseg_old BY buzei.
      SORT lt_bseg_new BY buzei.
      SORT lt_bseg BY buzei.

      SELECT * FROM bkdf INTO TABLE @DATA(lt_bkdf) "#EC CI_ALL_FIELDS_NEEDED
      WHERE      belnr  = @gs_fb02-belnr                "#EC CI_NOORDER
        AND      bukrs  = @gs_fb02-bukrs
        AND      gjahr  = @gs_fb02-gjahr.

      SELECT * FROM bsec INTO TABLE @DATA(lt_bsec) "#EC CI_ALL_FIELDS_NEEDED
      WHERE      belnr  = @gs_fb02-belnr                "#EC CI_NOORDER
        AND      bukrs  = @gs_fb02-bukrs
        AND      gjahr  = @gs_fb02-gjahr.

      SELECT * FROM bsed INTO TABLE @DATA(lt_bsed) "#EC CI_ALL_FIELDS_NEEDED
      WHERE      belnr  = @gs_fb02-belnr                "#EC CI_NOORDER
        AND      bukrs  = @gs_fb02-bukrs
        AND      gjahr  = @gs_fb02-gjahr.

      SELECT * FROM bset INTO TABLE @DATA(lt_bset) "#EC CI_ALL_FIELDS_NEEDED
      WHERE      belnr  = @gs_fb02-belnr                "#EC CI_NOORDER
        AND      bukrs  = @gs_fb02-bukrs
        AND      gjahr  = @gs_fb02-gjahr.

      DATA(lt_bsed_old) = lt_bsed.


      CALL FUNCTION 'CHANGE_DOCUMENT'
        TABLES
          t_bkdf = lt_bkdf
          t_bkpf = lt_bkpf
          t_bsec = lt_bsec
          t_bsed = lt_bsed
          t_bseg = lt_bseg
          t_bset = lt_bset
*         T_BSEG_ADD       =
        .

      IF sy-subrc <> 0.
        MESSAGE 'Fehler beim Ändern des Belegs. Bitte versuchen Sie es erneut.' TYPE 'E' DISPLAY LIKE 'S'.
      ELSE.


        " AVVSIO Übertragung
        CALL FUNCTION 'Z_FI_ALE_CHANGE_DOCUMENT'
          EXPORTING
            i_bkpf_old       = ls_bkpf_old                 " ursprünglicher FI-Belegkopf
            i_bkpf_new       = ls_bkpf                 " geänderter FI-Belegkopf
          TABLES
            t_bseg_old       = lt_bseg_old             " ursprüngliche FI-Belegzeilen
            t_bseg_new       = lt_bseg_new                 " geänderte FI-Belegzeilen
            t_bsed_old       = lt_bsed_old             " Belegsegment Wechselfelder
            t_bsed_new       = lt_bsed                 " Belegsegment Wechselfelder
          EXCEPTIONS
            no_fi_ale_change = 1                       " Keine Änderungsdaten für FI ALE versendet
            OTHERS           = 2.
        IF sy-subrc <> 0.
          " AVVISO IDOC nicht angetossen
          MESSAGE w180(/thkr/fi_wf_bkpf).
        ENDIF.


        COMMIT WORK.

        IF lv_kopf IS NOT INITIAL.
          UPDATE bkpf FROM ls_bkpf.
          " Prüfe Änderungsbelegtrigger
          IF lv_kopf_upd IS INITIAL.
            lv_kopf_upd = 'U'.
          ENDIF.
        ENDIF.

        " Erzeugen Objektid
        lv_objectid(3)    = sy-mandt.
        lv_objectid+3(4)  = gs_fb02-bukrs.
        lv_objectid+7(10) = gs_fb02-belnr.
        lv_objectid+17(4) = gs_fb02-gjahr.

        " Schreiben Änderungsbelege
        CALL FUNCTION 'BELEG_WRITE_DOCUMENT'
          EXPORTING
            objectid = lv_objectid
            tcode    = 'FB02'
            utime    = sy-uzeit
            udate    = sy-datum
            username = sy-uname
            n_bkpf   = ls_bkpf
            o_bkpf   = ls_bkpf_old
            upd_bkpf = lv_kopf_upd
            upd_bseg = lv_pos_upd
          TABLES
            xbseg    = lt_bseg_new
            ybseg    = lt_bseg_old.

        MESSAGE 'Beleg wurde erfoglreich geändert.' TYPE 'S'.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_kontierung
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_kontierung USING iv_bkpf TYPE bkpf
                            iv_bseg TYPE bseg .

  DATA: lv_check TYPE flag.

  SELECT * FROM /thkr/c_fb02_jus
    INTO TABLE @DATA(lt_kont)
    WHERE
    ( ( blart = @iv_bkpf-blart AND bukrs = @iv_bkpf-bukrs )
    OR ( blart = '*' AND bukrs = @iv_bkpf-bukrs )
    OR ( blart = @iv_bkpf-blart AND bukrs = '*' )
    OR ( blart = '*' AND bukrs = '*' ) AND
    ( gsber = @iv_bseg-gsber OR
      fistl = @iv_bseg-fistl OR
      fipos = @iv_bseg-fipos OR
      measure = @iv_bseg-measure OR
      geber = @iv_bseg-geber OR
      fkber = @iv_bseg-fkber ) ) .


  IF sy-subrc = 0.

    LOOP AT lt_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).

      IF ( <fs_kont>-gsber = iv_bseg-gsber OR iv_bseg-gsber CP <fs_kont>-gsber OR iv_bseg-gsber IS INITIAL )
        AND ( <fs_kont>-fistl = iv_bseg-fistl OR iv_bseg-fistl CP <fs_kont>-fistl OR iv_bseg-fistl IS INITIAL )
        AND ( <fs_kont>-fipos = iv_bseg-fipos OR iv_bseg-fipos CP <fs_kont>-fipos OR iv_bseg-fipos IS INITIAL )
        AND ( <fs_kont>-measure = iv_bseg-measure OR iv_bseg-measure CP <fs_kont>-measure OR iv_bseg-measure IS INITIAL )
        AND ( <fs_kont>-geber = iv_bseg-geber OR iv_bseg-geber CP <fs_kont>-geber OR iv_bseg-geber IS INITIAL )
        AND ( <fs_kont>-fkber = iv_bseg-fkber OR iv_bseg-fkber CP <fs_kont>-fkber OR iv_bseg-fkber IS INITIAL ).

        lv_check = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

  ELSE.

    MESSAGE ID '/THKR/FI_WF_BKPF' TYPE 'S' NUMBER '134' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN sy-dynnr.

  ENDIF.

  IF lv_check = abap_false.

    MESSAGE ID '/THKR/FI_WF_BKPF' TYPE 'S' NUMBER '134' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN sy-dynnr.

  ENDIF.



ENDFORM.


FORM check_bupa USING iv_partner TYPE bu_partner.

  DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                            iv_partner = iv_partner ).
  IF no_auth_l EQ abap_true.

    MESSAGE e010(/thkr/bp) WITH iv_partner.

  ENDIF.


ENDFORM.
