*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_FB02_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  OKCOD_VERARBEITUNG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE okcod_verarbeitung INPUT.

  DATA: lv_lfdnr TYPE lfdnr,
        ls_bseg  LIKE gs_bseg.

  CLEAR: bseg, bkpf, kna1, lfa1, t001, t042, t020,
      gs_bkpf,
      gs_bseg,
      gt_texte,
      gt_texte_changed,
      gt_texte_helper,
      gs_fb02,
      gt_fb02.

  CASE ok-code.
    WHEN 'RW'.
      IF sy-dynnr = '0100'.
        SET SCREEN 0.
        LEAVE SCREEN.
      ENDIF.
      PERFORM init.
      CALL SCREEN '0100'.
    WHEN 'END'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'ABR'.
      LEAVE PROGRAM.
    WHEN OTHERS.

      IF rf05l-belnr IS NOT INITIAL.
        SET PARAMETER ID 'BLN' FIELD rf05l-belnr.
      ENDIF.
      IF rf05l-gjahr IS NOT INITIAL.
        SET PARAMETER ID 'GJR' FIELD rf05l-gjahr.
      ENDIF.
      IF rf05l-bukrs IS NOT INITIAL.
        SET PARAMETER ID 'BUK' FIELD rf05l-bukrs.
      ENDIF.

* Eingaben prüfen
      IF rf05l-bukrs IS INITIAL
      OR rf05l-gjahr IS INITIAL
      OR rf05l-belnr IS INITIAL.
        MESSAGE s360(/thkr/fi_wf_bkpf) DISPLAY LIKE 'E'.
        LEAVE TO SCREEN sy-dynnr.
* Bitte geben Sie Belegnummer, Buchungskreis und Geschäftsjahr an.
      ENDIF.


* Beleg lesen
      SELECT SINGLE * INTO gs_bkpf FROM bkpf
        WHERE bukrs = rf05l-bukrs
        AND   gjahr = rf05l-gjahr
        AND   belnr = rf05l-belnr.

      IF sy-subrc NE 0.
        MESSAGE s389(f5a) WITH rf05l-belnr rf05l-bukrs rf05l-gjahr DISPLAY LIKE 'E'.
        LEAVE TO SCREEN sy-dynnr.
      ENDIF.

* Berechtigungsprüfung Belegkopf
      PERFORM auth_check_kopf USING gs_bkpf.

      "WICHTIG123"

* Prüfen, ob der Beleg für Stornierung vorgesehen ist
      SELECT SINGLE lfdnr FROM /thkr/stornoc
           INTO lv_lfdnr
          WHERE bukrs = rf05l-bukrs
            AND belnr = rf05l-belnr
            AND gjahr = rf05l-gjahr
            AND status NE '40'.       "Abgelehnt
      IF sy-subrc = 0.
        MESSAGE e356(/thkr/fi_wf_bkpf)
           WITH rf05l-belnr rf05l-bukrs rf05l-gjahr lv_lfdnr.
* Der Beleg &1/&2/&3 ist unter der Nummer &4 zum Storno vorgesehen.
      ENDIF.
*

* Prüfen, ob der Beleg aktiv im Workflow vorhanden ist
      SELECT SINGLE lfdnr FROM /thkr/fb02c
        INTO lv_lfdnr
        WHERE bukrs = rf05l-bukrs
          AND belnr = rf05l-belnr
          AND gjahr = rf05l-gjahr
          AND (    status NE '40'     "Abgelehnt
                AND status NE '15'    "Änderung ohne Workflow
*           OR status NE '60'         "Beleg fehlerhaft
               AND status NE '70'     "Beleg verbucht
               AND status NE '75' ).  "Beleg verbucht LOK
      IF sy-subrc = 0.
        MESSAGE e350(/thkr/fi_wf_bkpf)
           WITH rf05l-belnr rf05l-bukrs rf05l-gjahr lv_lfdnr.
* Der Beleg &1/&2/&3 wird bereits unter der Nummer &4 bearbeitet.
      ENDIF.

* Buchugnszeile (kreditorisch oder debitorisch) lesen
      SELECT SINGLE * FROM bseg
        INTO gs_bseg
       WHERE bukrs = gs_bkpf-bukrs
         AND gjahr = gs_bkpf-gjahr
         AND belnr = gs_bkpf-belnr
*         AND buzei = '01'
        AND (   koart = 'D'
             OR koart = 'K' ).

      IF gs_bseg-augdt IS NOT INITIAL.

*        IF sy-tcode = gc_tcode.                   " #001
*          MESSAGE s468(/THKR/FI_WF_BKPF).
*          CALL SCREEN '0303'.
*        ELSE.
*          MESSAGE e378(/THKR/FI_WF_BKPF).
*        ENDIF.                                    " #001
        MESSAGE 'Der Beleg ist bereits ausgeglichen' TYPE 'S' DISPLAY LIKE 'E'.
        LEAVE TO SCREEN sy-dynnr.
* Keine Änderung möglich, Beleg ist ausgeglichen.
      ENDIF.

      SELECT bukrs, belnr, gjahr, buzei, sgtxt, zuonr FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE @gt_texte
        WHERE bukrs = @gs_bkpf-bukrs
         AND gjahr = @gs_bkpf-gjahr
         AND belnr = @gs_bkpf-belnr.

      gt_texte_helper = gt_texte.

*   1. Sachkontenzeile für Authcheck lesen
      SELECT belnr gjahr buzei gsber augdt koart
             bukrs geber measure fistl fipos kostl kunnr lifnr
        UP TO 1 ROWS
        FROM bseg
        INTO CORRESPONDING FIELDS OF ls_bseg
        WHERE bukrs = gs_bseg-bukrs
          AND belnr = gs_bseg-belnr
          AND gjahr = gs_bseg-gjahr
          AND koart = 'S'
          AND kostl IS NOT NULL
       ORDER BY PRIMARY KEY.
      ENDSELECT.
      PERFORM auth_check_buzei USING ls_bseg.

      SELECT SINGLE lifnr, kunnr
        FROM bseg
         INTO @DATA(ls_bupa)
        WHERE bukrs = @gs_bseg-bukrs
          AND belnr = @gs_bseg-belnr
          AND gjahr = @gs_bseg-gjahr
        AND ( koart = 'D' OR koart = 'K' ).

      IF ls_bupa-lifnr IS NOT INITIAL.
        PERFORM check_bupa USING ls_bupa-lifnr.
      ELSEIF ls_bupa-kunnr IS NOT INITIAL.
        PERFORM check_bupa USING ls_bupa-kunnr.
      ENDIF.

      IF sy-tcode = gc_tcode_justiz.

        PERFORM check_kontierung USING gs_bkpf
                                       ls_bseg.

      ENDIF.

      gs_bseg-fipos = ls_bseg-fipos.
      gs_bseg-fistl = ls_bseg-fistl.
      gs_bseg-kostl = ls_bseg-kostl.
      gs_bseg-measure = ls_bseg-measure.


* Verarbeitung der Position starten:
      PERFORM position_aufrufen.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SICHERN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE sichern INPUT.

  CHECK ok-code = 'SAVE'.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  OK_VERARB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ok_verarb INPUT.

  CASE ok-code.
    WHEN 'AE'.
      IF gv_fehler IS INITIAL.
        IF sy-tcode = gc_tcode.
          PERFORM sichern.
        ELSEIF sy-tcode = gc_tcode_justiz.
          PERFORM sichern_jus.
        ENDIF.
        PERFORM init.
        LEAVE TO SCREEN '0100'.
      ENDIF.
    WHEN 'RW'.
      IF gv_change = abap_true AND
         gv_fehler IS INITIAL.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE TO SCREEN '0100'.
      ENDIF.
    WHEN 'END'.
      IF gv_change = abap_true AND
         gv_fehler IS INITIAL.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'ABR'.
      IF gv_change = abap_true AND
         gv_fehler IS INITIAL.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE PROGRAM.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHANGES_D  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_changes_d INPUT.
  PERFORM check_changes_d.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHANGES_K  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_changes_k INPUT.

  PERFORM check_changes_k.

ENDMODULE.

MODULE ok_verarb_ausgegl INPUT.
  CASE ok-code.
    WHEN 'AE'.
      PERFORM sichern_ausgegl.
      PERFORM init.
      LEAVE TO SCREEN '0100'.
    WHEN 'RW'.
      IF gv_change = abap_true.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE TO SCREEN '0100'.
      ENDIF.
    WHEN 'END'.
      IF gv_change = abap_true.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'ABR'.
      IF gv_change = abap_true.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE PROGRAM.
      ENDIF.
  ENDCASE.
ENDMODULE.

MODULE check_changes_ausgegl INPUT.
  PERFORM check_changes_ausgegl.
ENDMODULE.
" begin of #001 ***
*&---------------------------------------------------------------------*
*&      Module  CHECK_CHANGES_D_LOK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_changes_d_lok INPUT.
  PERFORM check_changes_d_lok.
ENDMODULE.
*** end of #001 ***
*&---------------------------------------------------------------------*
*&      Module  LEAVE_100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE leave_100 INPUT.

  CASE ok-code.
    WHEN 'RW'.
      IF gv_change = abap_true AND
         gv_fehler IS INITIAL.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE TO SCREEN '0100'.
      ENDIF.
    WHEN 'END'.
      IF gv_change = abap_true AND
         gv_fehler IS INITIAL.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE PROGRAM.
      ENDIF.
    WHEN 'ABR'.
      IF gv_change = abap_true AND
         gv_fehler IS INITIAL.        "20210324_BTO
        PERFORM pop_up_sichern.
      ELSE.
        PERFORM init.
        LEAVE PROGRAM.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_BVTYP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_bvtyp INPUT.

  DATA: lv_lifnr TYPE lifnr.


  " Ermitteln des Lieferanten
  CLEAR lv_lifnr.
  IF gs_bseg-empfb IS INITIAL.
    lv_lifnr = gs_bseg-lifnr.
  ELSE.
    lv_lifnr = gs_bseg-empfb.
  ENDIF.

*  " Prüfung der Partnerbank
*  CALL FUNCTION '/OPT/VIM_VALIDATE_PAYEE'
*    EXPORTING
*      i_lifnr = lv_lifnr
*      i_bukrs = gs_bseg-bukrs
*      i_bvtyp = bseg-bvtyp.

ENDMODULE.
*** begin of change #002 ***
*&---------------------------------------------------------------------*
*&      Module  F4_BVTYP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_bvtyp INPUT.

  DATA: lv_bvtyp TYPE bvtyp.
  DATA: lv_kunnr LIKE knbk-kunnr.


  " LIFNR abhängig von Kontoart setzen
  CLEAR lv_lifnr.
  IF gs_bseg-koart = 'K'.
    IF gs_bseg-empfb IS INITIAL.
      lv_lifnr = gs_bseg-lifnr.
    ELSE.
      lv_lifnr = gs_bseg-empfb.
    ENDIF.
  ELSE.
*      IF knb1-xverr <> space.
*      lifnr = kna1-lifnr.
*    ENDIF.
    IF lv_lifnr = space.
      IF bseg-empfb IS INITIAL.                            "Note 206687
        lv_kunnr = bseg-kunnr.
      ELSE.                                                "Note 206687
        lv_kunnr = bseg-empfb.                                "Note 206687
      ENDIF.                                               "Note 206687
    ENDIF.
  ENDIF.

*------- Partnerbanktypen anzeigen -------------------------------------
  CALL FUNCTION 'FI_F4_BVTYP'
    EXPORTING
      i_lifnr = lv_lifnr
      i_kunnr = lv_kunnr
    IMPORTING
      e_bvtyp = lv_bvtyp.

  IF NOT lv_bvtyp IS INITIAL.
    bseg-bvtyp = lv_bvtyp.
  ENDIF.

ENDMODULE.
*** end of change #002 ***
*&---------------------------------------------------------------------*
*&      Module  F4_ZTERM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_zterm INPUT.

  CALL FUNCTION 'FI_F4_ZTERM'
    EXPORTING
      i_koart = bseg-koart
      i_zterm = bseg-zterm
      i_xshow = ' '
    IMPORTING
      e_zterm = bseg-zterm.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_CHANGES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_changes INPUT.

  PERFORM get_changes_form.

ENDMODULE.

FORM get_changes_form.

  "CALL METHOD lr_alv2->refresh_table_display.
  DATA: lv_ret TYPE i.
  CALL METHOD lr_alv2->check_changed_data.
* cl_gui_cfw=>set_new_ok_code( new_code = 'ZXY' ).
  CALL METHOD cl_gui_cfw=>dispatch
    IMPORTING
      return_code = lv_ret.

ENDFORM.
