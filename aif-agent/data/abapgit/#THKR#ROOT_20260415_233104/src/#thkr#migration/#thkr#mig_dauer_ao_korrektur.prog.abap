*&---------------------------------------------------------------------*
*& Report /THKR/MIG_DAUER_AO_KORREKTUR
*&---------------------------------------------------------------------*
*& Dieser Korrektur-Report soll

*&---------------------------------------------------------------------*
REPORT /thkr/mig_dauer_ao_korrektur.


TYPES: BEGIN OF ty_message,
         type            TYPE syst-msgty,
         lotkz           TYPE pso_lotkz,
         xblnr           TYPE xblnr,
         bp_bkvid        TYPE bu_bkvid,
         bvtyp           TYPE bvtyp,
         rate_soll       TYPE wrbtr_cs,
         rate_ist        TYPE wrbtr_cs,
         rate_ursoll     TYPE wrbtr_cs,
         dbbdt           TYPE dbbdt,
         dbatr           TYPE dbatr,
         dbzhl           TYPE dbzhl,
         faelligkeitrate TYPE budat,
         satz_id         TYPE /thkr/de_satz_id,
         message         TYPE char100,
         msgid           TYPE syst_msgid,
         msgno           TYPE syst_msgno,
         cnt             TYPE int4,
       END OF ty_message.

DATA:
  gv_gjahr          TYPE gjahr,
  gv_budat_text(10) TYPE c,
  gv_change         TYPE c,
  gv_lotkz          TYPE pso_lotkz,
  gv_xblnr          TYPE xblnr,
  gt_messages       TYPE TABLE OF ty_message.

**********************************************************************
SELECT-OPTIONS:
            so_lotkz FOR gv_lotkz,
            so_xblnr FOR gv_xblnr.

PARAMETERS:
  p_dbbdt  TYPE dbbdt,
  p_dbatr  TYPE dbatr,
  p_user   TYPE usnm_vbkpf DEFAULT '9999-MIG',
  p_migobj TYPE /thkr/migrationsobjekt DEFAULT 'SSTW',
  p_chdat  TYPE c AS CHECKBOX,
  p_addao  TYPE c AS CHECKBOX,
  p_adduz  TYPE c AS CHECKBOX,
  p_datum  TYPE c AS CHECKBOX,
  p_check  TYPE c AS CHECKBOX DEFAULT 'X',
  p_test   TYPE flag DEFAULT 'X'.

INITIALIZATION.
  SELECT SINGLE budat FROM /thkr/mig_md INTO @DATA(gv_budat).
  WRITE gv_budat TO gv_budat_text.
  gv_gjahr = gv_budat+0(4).


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name CS 'P_MIGOBJ' OR screen-name CS 'P_USER'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


**********************************************************************
START-OF-SELECTION.

  IF p_datum = abap_true AND p_dbatr IS INITIAL AND p_dbbdt IS INITIAL.
    MESSAGE 'Geben Sie ein Dazum ein.' TYPE 'E'.
  ENDIF.

* Selektion aller Daueranordnungen
  SELECT * FROM /thkr/migdao AS a INNER JOIN /thkr/mig_ao_sap AS b ON a~satz_id = b~satz_id
    INTO TABLE @DATA(lt_mig_data) WHERE a~migrationsobjekt = @p_migobj AND a~kassenzeichen IN @so_xblnr AND b~lotkz IN @so_lotkz.

* Test aller SSTW
  LOOP AT lt_mig_data ASSIGNING FIELD-SYMBOL(<fs_mig_data>).
    CLEAR gv_change.

    IF <fs_mig_data>-b-lotkz IS INITIAL.

      APPEND VALUE #(
                      type    = 'W'
                      xblnr   = <fs_mig_data>-b-xblnr
                      message = 'Keine AO vorhanden'
                      msgno   = '001'
                      cnt     = 1
                    ) TO gt_messages.
      CONTINUE.
    ENDIF.

    " DAO Daten lesen
    SELECT SINGLE * FROM psokpf AS a INNER JOIN psosegd AS b ON a~lotkz = b~lotkz AND a~bukrs = b~bukrs AND a~itabkey = b~itabkey AND a~gjahr = b~gjahr
      INTO @DATA(ls_lotkz_data) WHERE a~lotkz = @<fs_mig_data>-b-lotkz AND a~gjahr = @gv_gjahr AND a~bukrs = @<fs_mig_data>-b-bukrs.
    IF sy-subrc <> 0.
      APPEND VALUE #(
            type    = 'E'
            xblnr   = <fs_mig_data>-b-xblnr
            lotkz   = <fs_mig_data>-b-lotkz
            message = 'Fehler lesen Dauer AO'
            msgno   = '002'
            cnt     = 1
      ) TO gt_messages.
      CONTINUE.
    ENDIF.

* DAO auf Datum ändern.
    IF p_datum IS NOT INITIAL.

      " neues Datum setzen
      PERFORM change_dao USING <fs_mig_data>-b-xblnr <fs_mig_data>-b-lotkz ls_lotkz_data-a-dbbdt ls_lotkz_data-a-dbatr <fs_mig_data>-b-bukrs gv_gjahr.
      gv_change = abap_true.

    ENDIF.


* 1. Prüfung passt BankverbindungsID zu dem im GP
    IF ls_lotkz_data-b-bvtyp IS NOT INITIAL.
      SELECT * FROM but0bk INTO TABLE @DATA(lt_but0bk) WHERE partner = @ls_lotkz_data-b-kunnr.
      IF sy-subrc <> 0.
        APPEND VALUE #(
                type    = 'E'
                xblnr   = <fs_mig_data>-b-xblnr
                lotkz   = <fs_mig_data>-b-lotkz
*                bp_bkvid = ls_but0bk-bkvid
                bvtyp   = ls_lotkz_data-b-bvtyp
                message = 'GP hat keine Banlverbindung'
                msgno   = '003'
                cnt     = 1
        ) TO gt_messages.

        "  manuelle Korrektur
      ELSE.
        " Prüfung auf ID
        CONVERT DATE sy-datum INTO TIME STAMP DATA(lv_ts) TIME ZONE 'UTC'.
        "gibt es die ID
        LOOP AT lt_but0bk TRANSPORTING NO FIELDS WHERE bkvid = ls_lotkz_data-b-bvtyp AND bk_valid_from <= lv_ts AND bk_valid_to >= lv_ts.
        ENDLOOP.
        IF sy-subrc <> 0.
          APPEND VALUE #(
          type    = 'E'
          xblnr   = <fs_mig_data>-b-xblnr
          lotkz   = <fs_mig_data>-b-lotkz
*          bp_bkvid = ls_but0bk-bkvid
          bvtyp   = ls_lotkz_data-b-bvtyp
          message = 'AO BVTYP <> GP BKVID'
          msgno   = '004'
          cnt     = 1
          ) TO gt_messages.

          " TODo manuelle Korrektur

        ENDIF.
      ENDIF. " Bank vorhanden

    ENDIF. " Ende Bankprüfung

* 2. nächstes Ausführungsdatum <> 1. Ausführungsdatum
    IF ls_lotkz_data-a-dbbdt <>  ls_lotkz_data-a-dbatr. "Anfangsdatum der Dauerbuchung <> Nächster Abrechnungstermin
      IF ls_lotkz_data-a-dbzhl = 0.
        APPEND VALUE #(
                 type    = 'E'
                 xblnr   = <fs_mig_data>-b-xblnr
                 lotkz   = <fs_mig_data>-b-lotkz
                 dbbdt   = ls_lotkz_data-a-dbbdt
                 dbatr   = ls_lotkz_data-a-dbatr
                 message = 'Anfangsdatum <> Nächster Abrechnungstermin noch keine Ausführung'
                 msgno   = '005'
                 cnt     = 1
        ) TO gt_messages.

        " Anpassung Nächste Ausführung = Erste Ausführung
        PERFORM change_dao USING <fs_mig_data>-b-xblnr <fs_mig_data>-b-lotkz ls_lotkz_data-a-dbbdt ls_lotkz_data-a-dbatr <fs_mig_data>-b-bukrs gv_gjahr.
        gv_change = abap_true.
      ELSE.
        APPEND VALUE #(
                      type    = 'W'
                      xblnr   = <fs_mig_data>-b-xblnr
                      lotkz   = <fs_mig_data>-b-lotkz
                      dbbdt   = ls_lotkz_data-a-dbbdt
                      dbatr   = ls_lotkz_data-a-dbatr
                      dbzhl   = ls_lotkz_data-a-dbzhl
                      message = 'Anfangsdatum <> Nächster Abrechnungstermin Ausführung erfolgt'
                      msgno   = '006'
                      cnt     = 1
        ) TO gt_messages.

        " Fehlt eine Rate - >Prüfung siehe 5. und 6.

      ENDIF.

    ENDIF.

* Raten lesen
    SELECT * FROM /thkr/migdaor INTO TABLE @DATA(lt_rate) WHERE satz_id = @<fs_mig_data>-a-satz_id.

* 3. Prüfung Falsche Rate
    " 1. Rate <> DAO Betrag
    READ TABLE lt_rate ASSIGNING FIELD-SYMBOL(<fs_1_rate>) WITH KEY ratennummer = 1.
    IF sy-subrc = 0.
      DATA(lv_soll) = CONV wrbtr_cs( <fs_1_rate>-ratensollbetrag ).
      DATA(lv_ist) = CONV wrbtr_cs( <fs_1_rate>-ratenistbetrag ).
      DATA(lv_ursoll) = CONV wrbtr_cs( <fs_1_rate>-ratenursollbetrag ).
      IF lv_soll <> ls_lotkz_data-b-dmbtr.
        APPEND VALUE #(
                     type        = 'E'
                     xblnr       = <fs_mig_data>-b-xblnr
                     lotkz       = <fs_mig_data>-b-lotkz
                     rate_soll   = lv_soll
                     rate_ist    = lv_ist
                     rate_ursoll = lv_ursoll
                     dbbdt       = ls_lotkz_data-a-dbbdt
                     dbatr       = ls_lotkz_data-a-dbatr
                     dbzhl       = ls_lotkz_data-a-dbzhl
                     message     = 'SSTW 1. Rate Betrag <> DAO Betrag'
                     msgno       = '007'
                     cnt         = 1
        ) TO gt_messages.

        " Manuelle Korrektur
      ENDIF.

      " 1. Rate Fälligkeit <> 1. Fälligkeit ?
      IF <fs_1_rate>-faelligkeitrate <> <fs_mig_data>-a-erstefaelligkeit.
        APPEND VALUE #(
               type        = 'E'
               xblnr       = <fs_mig_data>-b-xblnr
               lotkz       = <fs_mig_data>-b-lotkz
               rate_soll   = lv_soll
               rate_ist    = lv_ist
               rate_ursoll = lv_ursoll
               dbbdt       = ls_lotkz_data-a-dbbdt
               dbatr       = ls_lotkz_data-a-dbatr
               dbzhl       = ls_lotkz_data-a-dbzhl
               message     = 'SSTW 1. Rate Fälligkeit <> 1. Fälligkeit'
               msgno       = '020'
               cnt         = 1
        ) TO gt_messages.

        " Manuelle Korrektur
      ENDIF.
    ENDIF.


* 4. Rate in 2025 negativ offenes Soll
    LOOP AT lt_rate ASSIGNING FIELD-SYMBOL(<fs_rate>) WHERE ratennummer < 0.
      lv_soll = CONV wrbtr_cs( <fs_rate>-ratensollbetrag ).
      lv_ist = CONV wrbtr_cs( <fs_rate>-ratenistbetrag ).
      DATA(lv_saldo) = CONV wrbtr_cs( lv_soll - lv_ist ).

      IF lv_saldo < 0.
        APPEND VALUE #(
              type        = 'E'
              xblnr       = <fs_mig_data>-b-xblnr
              lotkz       = <fs_mig_data>-b-lotkz
              rate_soll   = lv_soll
              rate_ist    = lv_ist
              rate_ursoll = lv_ursoll
              dbbdt       = ls_lotkz_data-a-dbbdt
              dbatr       = ls_lotkz_data-a-dbatr
              dbzhl       = ls_lotkz_data-a-dbzhl
              message     = 'Rate Soll < Rate Ist'
              msgno       = '008'
              cnt         = 1
        ) TO gt_messages.

        SELECT SINGLE pos_nr INTO @DATA(lv_rk_pos) FROM /thkr/migd_rkfap
            WHERE satz_id = @<fs_mig_data>-b-xblnr AND faellig_dtu = @<fs_rate>-faelligkeitrate.

        PERFORM add_ao_sap_uez USING <fs_mig_data>-b-xblnr lv_rk_pos <fs_mig_data>-a-haushaltsjahr
                           <fs_mig_data>-a-einzelplan <fs_mig_data>-a-zp_nummer <fs_mig_data>-a-zp_lfd_nummer <fs_rate>-faelligkeitrate.
        gv_change = abap_true.

        CLEAR lv_rk_pos.
      ENDIF.


    ENDLOOP.


* 5. Fehlende Stichtagsrate
    SELECT SINGLE * INTO @DATA(ls_rk_pos) FROM /thkr/migd_rkfap WHERE satz_id = @<fs_mig_data>-b-xblnr AND faellig_dtu = @gv_budat AND haup_nebenforderung = 'H'.
    IF sy-subrc = 0.
      lv_soll = CONV wrbtr_cs( ls_rk_pos-sollhf ).
      lv_ist = CONV wrbtr_cs( ls_rk_pos-ist ).
      lv_saldo = lv_soll - lv_ist.

      SELECT SINGLE dmbtr FROM bsid_view INTO @DATA(lv_dmbtr)
         WHERE xblnr = @<fs_mig_data>-b-xblnr AND bukrs = @<fs_mig_data>-b-bukrs AND bldat = @gv_budat.
      IF sy-subrc = 0.
        APPEND VALUE #(
            type      = 'I'
            xblnr     = <fs_mig_data>-b-xblnr
            lotkz     = <fs_mig_data>-b-lotkz
            rate_soll = lv_soll
            rate_ist  = lv_ist
            dbbdt     = ls_lotkz_data-a-dbbdt
            dbatr     = ls_lotkz_data-a-dbatr
            dbzhl     = ls_lotkz_data-a-dbzhl
            message   = |Stichtagsrate { gv_budat_text } vorhanden|
            msgno     = '009'
            cnt       = 1
        ) TO gt_messages.

      ELSEIF lv_saldo > 0.


* Prüfen ob die DAO bereits manuell geändert wurde
        IF ls_lotkz_data-a-usnam <> p_user AND p_check IS NOT INITIAL.
          APPEND VALUE #(
            type      = 'E'
            xblnr     = <fs_mig_data>-b-xblnr
            lotkz     = <fs_mig_data>-b-lotkz
            rate_soll = lv_soll
            rate_ist  = lv_ist
            dbbdt     = ls_lotkz_data-a-dbbdt
            dbatr     = ls_lotkz_data-a-dbatr
            dbzhl     = ls_lotkz_data-a-dbzhl
            message   = 'Fehlende Stichtagsrate DAO von anderen User geändert, manuelle prüfen'
            msgno     = '022'
            cnt       = 1
          ) TO gt_messages.

        ELSE.

          APPEND VALUE #(
               type      = 'E'
               xblnr     = <fs_mig_data>-b-xblnr
               lotkz     = <fs_mig_data>-b-lotkz
               rate_soll = lv_soll
               rate_ist  = lv_ist
               dbbdt     = ls_lotkz_data-a-dbbdt
               dbatr     = ls_lotkz_data-a-dbatr
               dbzhl     = ls_lotkz_data-a-dbzhl
               message   = |Fehlende Stichtagsrate { gv_budat_text }|
               msgno     = '010'
               cnt       = 1
          ) TO gt_messages.

          " Rate nachbuchen
          PERFORM add_ao_sap USING <fs_mig_data>-b-xblnr ls_rk_pos-pos_nr <fs_mig_data>-a-haushaltsjahr
                          <fs_mig_data>-a-einzelplan <fs_mig_data>-a-zp_nummer <fs_mig_data>-a-zp_lfd_nummer.
          gv_change = abap_true.

        ENDIF. " DAO bereits manuell geändert

      ENDIF. "Stichtagsrate { gv_budat_text } vorhanden lv_saldo > 0

    ENDIF. ". Fehlende Stichtagsrate


* 6. Fehlende Raten in 2026; Prüfung ob es eine Buchung zum Kassenzeichen zur 1. Fälligkeit gibt
    IF <fs_1_rate> IS ASSIGNED AND ls_lotkz_data-a-dbzhl = 1.
      SELECT SINGLE belnr FROM bkpf INTO @DATA(lv_belnr)
          WHERE xblnr = @<fs_mig_data>-b-xblnr AND bukrs = @<fs_mig_data>-b-bukrs AND bldat = @<fs_1_rate>-faelligkeitrate.
      IF sy-subrc <> 0.
        lv_soll = CONV wrbtr_cs( <fs_1_rate>-ratensollbetrag ).
        lv_ist = CONV wrbtr_cs( <fs_1_rate>-ratenistbetrag ).
        lv_ursoll = CONV wrbtr_cs( <fs_1_rate>-ratenursollbetrag ).

        IF lv_soll > 0.


* Prüfen ob die DAO bereits manuell geändert wurde
          IF ls_lotkz_data-a-usnam <> p_user AND p_check IS NOT INITIAL.
            APPEND VALUE #(
              type      = 'E'
              xblnr     = <fs_mig_data>-b-xblnr
              lotkz     = <fs_mig_data>-b-lotkz
              rate_soll = lv_soll
              rate_ist  = lv_ist
              dbbdt     = ls_lotkz_data-a-dbbdt
              dbatr     = ls_lotkz_data-a-dbatr
              dbzhl     = ls_lotkz_data-a-dbzhl
              message   = 'Fehlende 1. Raten 2026 DAO von User geändert, manuelle prüfen'
              msgno     = '022'
              cnt       = 1
            ) TO gt_messages.

          ELSE.

            " Rate nachbuchen
            SELECT SINGLE pos_nr INTO @lv_rk_pos FROM /thkr/migd_rkfap WHERE satz_id = @<fs_mig_data>-b-xblnr AND faellig_dtu = @<fs_1_rate>-faelligkeitrate.
            IF sy-subrc = 0.

              APPEND VALUE #(
                    type            = 'E'
                    xblnr           = <fs_mig_data>-b-xblnr
                    lotkz           = <fs_mig_data>-b-lotkz
                    rate_soll       = lv_soll
                    rate_ist        = lv_ist
                    rate_ursoll     = lv_ursoll
                    dbbdt           = ls_lotkz_data-a-dbbdt
                    dbatr           = ls_lotkz_data-a-dbatr
                    dbzhl           = ls_lotkz_data-a-dbzhl
                    faelligkeitrate = <fs_1_rate>-faelligkeitrate
                    message         = |Fehlende 1. Rate { gv_budat_text }|
                    msgno           = '011'
                    cnt             = 1
              ) TO gt_messages.

              PERFORM add_ao_sap USING <fs_mig_data>-b-xblnr lv_rk_pos <fs_mig_data>-a-haushaltsjahr
                                      <fs_mig_data>-a-einzelplan <fs_mig_data>-a-zp_nummer <fs_mig_data>-a-zp_lfd_nummer.
              gv_change = abap_true.
            ELSEIF sy-subrc <> 0.
              APPEND VALUE #(
                      type            = 'E'
                      xblnr           = <fs_mig_data>-b-xblnr
                      lotkz           = <fs_mig_data>-b-lotkz
                      rate_soll       = lv_soll
                      rate_ist        = lv_ist
                      rate_ursoll     = lv_ursoll
                      dbbdt           = ls_lotkz_data-a-dbbdt
                      dbatr           = ls_lotkz_data-a-dbatr
                      dbzhl           = ls_lotkz_data-a-dbzhl
                      faelligkeitrate = <fs_1_rate>-faelligkeitrate
                      message         = 'Fehler Keine Posnr aus RK zu 1. Rate'
                      msgno           = '012'
                      cnt             = 1
              ) TO gt_messages.
            ENDIF. "Rate nachbuchen

          ENDIF. "DAO bereits manuell geändert w

        ENDIF. "Soll > 0
      ENDIF."noch keine Rate
    ENDIF. "Fehlende Raten in 2026;


    IF p_test IS INITIAL AND gv_change = abap_true.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.


* Ausgabe
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                              CHANGING  t_table      = gt_messages ).

      SET PARAMETER ID 'EXCEL_INPLACE' FIELD space.
      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).
      lo_salv->get_columns( )->get_column( 'CNT' )->set_short_text( 'Zähler' ).
      lo_salv->get_columns( )->get_column( 'CNT' )->set_long_text( 'Zähler' ).
      lo_salv->get_columns( )->get_column( 'CNT' )->set_medium_text( 'Zähler' ).
      lo_salv->get_columns( )->get_column( 'MESSAGE' )->set_short_text( 'Nachricht' ).
      lo_salv->get_columns( )->get_column( 'MESSAGE' )->set_long_text( 'Nachricht' ).
      lo_salv->get_columns( )->get_column( 'MESSAGE' )->set_medium_text( 'Nachricht' ).

      lo_salv->get_columns( )->get_column( 'RATE_SOLL' )->set_short_text( 'Soll' ).
      lo_salv->get_columns( )->get_column( 'RATE_SOLL' )->set_long_text( 'Soll' ).
      lo_salv->get_columns( )->get_column( 'RATE_SOLL' )->set_medium_text( 'Soll' ).
      lo_salv->get_columns( )->get_column( 'RATE_IST' )->set_short_text( 'Ist' ).
      lo_salv->get_columns( )->get_column( 'RATE_IST' )->set_long_text( 'Ist' ).
      lo_salv->get_columns( )->get_column( 'RATE_IST' )->set_medium_text( 'Ist' ).
      lo_salv->get_columns( )->get_column( 'RATE_URSOLL' )->set_short_text( 'Ursoll' ).
      lo_salv->get_columns( )->get_column( 'RATE_URSOLL' )->set_long_text( 'Ursoll' ).
      lo_salv->get_columns( )->get_column( 'RATE_URSOLL' )->set_medium_text( 'Ursoll' ).

      lo_salv->display( ).

    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.

**********************************************************************

FORM change_dao USING i_xblnr i_lotkz i_dbbdt i_dbatr i_bukrs i_gjahr.
  IF p_chdat IS INITIAL AND p_datum IS INITIAL.
    RETURN.
  ENDIF.

  SELECT SINGLE * FROM psokpf INTO @DATA(l_psokpf_old) WHERE lotkz = @i_lotkz AND bukrs = @i_bukrs AND gjahr = @i_gjahr.
  DATA(l_psokpf) = l_psokpf_old.

  IF p_chdat = abap_true.
    l_psokpf-dbatr = i_dbbdt. " Nächste = erste

  ELSEIF p_datum = abap_true.
    IF p_dbatr IS NOT INITIAL.
      l_psokpf-dbatr =  p_dbatr.
    ENDIF.
    IF p_dbbdt IS NOT INITIAL.
      l_psokpf-dbbdt = p_dbbdt.
    ENDIF.
  ELSE.
    EXIT.
  ENDIF.




* Ändert es nicht, setzt nur die Ausführung um 1 hoch
*  CALL FUNCTION 'FM_FI_HEADER_DATA_UPDATE'
*    EXPORTING
*      i_lotkz        = i_lotkz
*      i_f_psokpf     = l_psokpf
*      i_f_psokpf_old = l_psokpf_old
*    EXCEPTIONS
*      error_message  = 1.

* 2. write change documents
  DATA: l_t_vbkpf_new LIKE vbkpf OCCURS 0 WITH HEADER LINE,
        l_t_vbkpf_old LIKE vbkpf OCCURS 0 WITH HEADER LINE,
        l_t_vbseg     LIKE vbseg OCCURS 0 WITH HEADER LINE,     "Dummy
        l_t_vbsec     LIKE vbsec OCCURS 0 WITH HEADER LINE,     "Dummy
        l_t_vbset     LIKE vbset OCCURS 0 WITH HEADER LINE,     "Dummy
        l_t_pso       LIKE pso02 OCCURS 0 WITH HEADER LINE,     "Dummy
        l_f_pso       LIKE pso02.

  CLEAR l_t_vbkpf_new.
  CLEAR l_t_vbkpf_old.
  CLEAR l_t_vbseg.
  CLEAR l_t_vbsec.
  CLEAR l_t_vbset.
  CLEAR l_t_pso.
  CLEAR l_f_pso.

  MOVE-CORRESPONDING l_psokpf TO l_t_vbkpf_new.
  APPEND l_t_vbkpf_new.
  MOVE-CORRESPONDING l_psokpf TO l_t_vbseg.
  APPEND l_t_vbseg.
  MOVE-CORRESPONDING l_psokpf TO l_t_vbsec.
  APPEND l_t_vbsec.
  MOVE-CORRESPONDING l_psokpf TO l_t_vbset.
  APPEND l_t_vbset.
  MOVE-CORRESPONDING l_psokpf TO l_t_pso.
  APPEND l_t_pso.

  MOVE-CORRESPONDING l_psokpf_old TO l_t_vbkpf_old.
  APPEND l_t_vbkpf_old.
  MOVE-CORRESPONDING l_psokpf_old TO l_f_pso.


  CALL FUNCTION 'FI_PSO_RECURRING_CHANGE_WRITE'
    EXPORTING
      f_pso_old   = l_f_pso
    TABLES
      t_vbkpf_old = l_t_vbkpf_old
      t_vbsec_old = l_t_vbsec
      t_vbseg_old = l_t_vbseg
      t_vbset_old = l_t_vbset
      t_pso_new   = l_t_pso
      t_vbkpf_new = l_t_vbkpf_new
      t_vbsec_new = l_t_vbsec
      t_vbseg_new = l_t_vbseg
      t_vbset_new = l_t_vbset.

* 3. update database
  UPDATE psokpf FROM l_psokpf.
  IF sy-subrc <> 0.
    APPEND VALUE #(
                   type    = 'E'
                   xblnr   = i_xblnr
                   lotkz   = i_lotkz
                   dbbdt   = i_dbbdt
                   dbatr   = l_psokpf-dbatr
                   message = 'Fehler Änderung Anordnung'
                   msgno   = '013'
                   cnt     = 1
                  ) TO gt_messages.
    ROLLBACK WORK.
  ELSE.
    IF  p_chdat = abap_true.
      APPEND VALUE #(
                   type    = 'S'
                   xblnr   = i_xblnr
                   lotkz   = i_lotkz
                   dbbdt   = i_dbbdt
                   dbatr   = l_psokpf-dbatr
                   message = 'Änderung Nächste Ausführung am'
                   msgno   = '014'
                   cnt     = 1
                    ) TO gt_messages.
    ELSE.
      APPEND VALUE #(
             type    = 'S'
             xblnr   = i_xblnr
             lotkz   = i_lotkz
             dbbdt   = l_psokpf-dbbdt
             dbatr   = l_psokpf-dbatr
             message = 'Änderung Nächste/Ersts Ausführung am'
             msgno   = '014'
             cnt     = 1
      ) TO gt_messages.
    ENDIF.
  ENDIF.




ENDFORM.
**********************************************************************

FORM add_ao_sap_uez USING i_xblnr i_pos_nr i_haushaltsjahr i_einzelplan i_zp_nummer i_zp_lfd_nummer i_faelligkeitrate.

  IF p_adduz IS INITIAL.
    RETURN.
  ENDIF.


  DATA l_ao_sap TYPE /thkr/mig_ao_sap.

  CONCATENATE 'STW' i_xblnr i_pos_nr 'H' INTO l_ao_sap-satz_id SEPARATED BY '_'.

  SELECT SINGLE satz_id FROM /thkr/mig_ao_sap INTO @DATA(lv_satz_id) WHERE satz_id  = @l_ao_sap-satz_id.
  IF sy-subrc = 0.
    APPEND VALUE #(
                type    = 'E'
                xblnr   = i_xblnr
                satz_id = l_ao_sap-satz_id
                message = '/THKR/MIG_AO_SAP Eintrag vorhanden, keine AO?'
                msgno   = '019'
                cnt     = 1
    ) TO gt_messages.
    RETURN.
  ENDIF.

  l_ao_sap-xblnr     = i_xblnr.
  l_ao_sap-rk_pos_nr = i_pos_nr.
  l_ao_sap-rk_pos_nr_haushaltsjahr = i_haushaltsjahr.
  l_ao_sap-epl       = i_einzelplan.
  l_ao_sap-zp_nr     = i_zp_nummer.
  l_ao_sap-zp_lfd_nr = i_zp_lfd_nummer.
  l_ao_sap-haup_nebenforderung = 'H'.
  l_ao_sap-pos_nr_haupforderung = i_pos_nr.
  l_ao_sap-sstw_ueberzahlung = abap_true.
  l_ao_sap-sstw_ueberzahlung_datum = i_faelligkeitrate.
  l_ao_sap-sstw_hauptforderung = abap_true.


  MODIFY /thkr/mig_ao_sap FROM l_ao_sap.
  IF sy-subrc <> 0.
    APPEND VALUE #(
                   type    = 'E'
                   xblnr   = i_xblnr
                   satz_id = l_ao_sap-satz_id
                   message = 'Fehler Änderung /THKR/MIG_AO_SAP Eintrag'
                   msgno   = '015'
                   cnt     = 1
                  ) TO gt_messages.
    ROLLBACK WORK.
  ELSE.
    APPEND VALUE #(
                 type    = 'S'
                 xblnr   = i_xblnr
                 satz_id = l_ao_sap-satz_id
                 message = 'Änderung /THKR/MIG_AO_SAP neuer Eintrag'
                 msgno   = '016'
                 cnt     = 1
                  ) TO gt_messages.
  ENDIF.


ENDFORM.

**********************************************************************
FORM add_ao_sap USING i_xblnr i_pos_nr i_haushaltsjahr i_einzelplan i_zp_nummer i_zp_lfd_nummer.

  IF p_addao IS INITIAL.
    RETURN.
  ENDIF.

  DATA l_ao_sap TYPE /thkr/mig_ao_sap.

  CONCATENATE 'STW' i_xblnr i_pos_nr 'H' INTO l_ao_sap-satz_id SEPARATED BY '_'.

  SELECT SINGLE satz_id FROM /thkr/mig_ao_sap INTO @DATA(lv_satz_id) WHERE satz_id  = @l_ao_sap-satz_id.
  IF sy-subrc = 0.
    APPEND VALUE #(
                type    = 'E'
                xblnr   = i_xblnr
                satz_id = l_ao_sap-satz_id
                message = '/THKR/MIG_AO_SAP Eintrag vorhanden, keine AO?'
                msgno   = '019'
                cnt     = 1
    ) TO gt_messages.
    RETURN.
  ENDIF.

  l_ao_sap-xblnr     = i_xblnr.
  l_ao_sap-rk_pos_nr = i_pos_nr.
  l_ao_sap-rk_pos_nr_haushaltsjahr = i_haushaltsjahr.
  l_ao_sap-epl       = i_einzelplan.
  l_ao_sap-zp_nr     = i_zp_nummer.
  l_ao_sap-zp_lfd_nr = i_zp_lfd_nummer.
  l_ao_sap-haup_nebenforderung = 'H'.
  l_ao_sap-pos_nr_haupforderung = i_pos_nr.
  l_ao_sap-sstw_hauptforderung = abap_true.

  MODIFY /thkr/mig_ao_sap FROM l_ao_sap.
  IF sy-subrc <> 0.
    APPEND VALUE #(
                   type    = 'E'
                   xblnr   = i_xblnr
                   satz_id = l_ao_sap-satz_id
                   message = 'Fehler Änderung /THKR/MIG_AO_SAP Eintrag'
                   msgno   = '015'
                   cnt     = 1
                  ) TO gt_messages.
    ROLLBACK WORK.
  ELSE.
    APPEND VALUE #(
                 type    = 'S'
                 xblnr   = i_xblnr
                 satz_id = l_ao_sap-satz_id
                 message = 'Änderung /THKR/MIG_AO_SAP neuer Eintrag'
                 msgno   = '016'
                 cnt     = 1
                  ) TO gt_messages.
  ENDIF.



ENDFORM.
