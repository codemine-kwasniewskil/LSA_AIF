*&---------------------------------------------------------------------*
*& Report /THKR/MIG_RK_KORR_SOLL_ABGANG
*&---------------------------------------------------------------------*
*& Dieser Korrektur-Report soll fehlende Sollabgänge der LIste hinzufügen

*&---------------------------------------------------------------------*
REPORT /thkr/mig_rk_korr_soll_abgang.


TYPES: BEGIN OF ty_message,
         type                TYPE syst-msgty,
         lotkz               TYPE pso_lotkz,
         xblnr               TYPE xblnr,
         satz_id             TYPE /thkr/de_satz_id,
         rk_pos_nr           TYPE /thkr/rk_pos_nr,
         haup_nebenforderung TYPE /thkr/mig_hf_nf,
         soll                TYPE /thkr/amnt,
         ist                 TYPE /thkr/amnt,
         saldo               TYPE /thkr/amnt,
         message             TYPE char100,
         msgid               TYPE syst_msgid,
         msgno               TYPE syst_msgno,
         cnt                 TYPE int4,
       END OF ty_message.


DATA:
  gv_gjahr          TYPE gjahr,
  gv_budat_text(10) TYPE c,
  gv_change         TYPE c,
  gv_xblnr          TYPE xblnr,
  gt_messages       TYPE TABLE OF ty_message.

**********************************************************************
SELECT-OPTIONS:
            so_xblnr FOR gv_xblnr.

PARAMETERS:
  p_ini  TYPE c AS CHECKBOX,
  p_zahl TYPE c AS CHECKBOX DEFAULT 'X',
  p_test TYPE flag DEFAULT 'X'.

INITIALIZATION.
  SELECT SINGLE budat FROM /thkr/mig_md INTO @DATA(gv_budat).
  WRITE gv_budat TO gv_budat_text.
  gv_gjahr = gv_budat+0(4).


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
*    IF screen-name CS 'P_MIGOBJ' OR screen-name CS 'P_USER'.
*      screen-input = 0.
*      MODIFY SCREEN.
*    ENDIF.
  ENDLOOP.


**********************************************************************
START-OF-SELECTION.

* Selektion aller RK Belege
  DATA:
    l_migdao      TYPE /thkr/migdao,
    lv_sstw       TYPE flag,
    lv_nuller_kaz TYPE flag,
    l_saldo       TYPE /thkr/amnt,
    l_soll        TYPE /thkr/amnt,
    l_ist         TYPE /thkr/amnt,
    ls_selection  TYPE /thkr/s_mig_rk_sap_selection.

  ls_selection-r_kassenzeichen = so_xblnr[].
  ls_selection-flag_init_op_kassenzeichen = p_ini.
  ls_selection-flag_select_details = abap_true.

  /thkr/cl_mig_rk=>get_instance( )->get_tdto_mig_rk(
    EXPORTING
      i_selection = ls_selection                  " Selektionskriterien: Migration - Rückstandskonto
    IMPORTING
      et_dto      =  DATA(lt_dto_rk)                " TDTO: Migration: Rückstandskonto
  ).

  LOOP AT lt_dto_rk INTO DATA(l_dto_rk).

    /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_ao(
     EXPORTING
       i_xblnr                = l_dto_rk-s_kassenzeichen               " Kassenzeichen
       i_haupt_nebenforderung = 'H'
     IMPORTING
       e_dto                  = DATA(ls_ao_dto_h)                " DTO: Migration Anordnung
   ).

    LOOP AT l_dto_rk-t_rk_faell INTO DATA(l_rk_faell).
      LOOP AT l_rk_faell-t_rk_pos INTO DATA(l_rk_pos).
        "Definition 000er Kassenzeichen
        IF l_rk_pos-haup_nebenforderung = 'H' AND l_rk_pos-einzelplan = '93' AND l_rk_pos-kapitel = '4133'
            AND l_rk_pos-titel = '233 00' AND ( l_rk_pos-unterkonto = '00' OR l_rk_pos-unterkonto = '' ) AND
          l_dto_rk-zp_v-kennz_vertreter = 'G'.
          lv_nuller_kaz = abap_true.
        ELSE.
          CLEAR lv_nuller_kaz.
        ENDIF.

        "Nur bei Amtshilfe auch Hauptforderungen berücksichtigen
        "oder 000er Kassenzeichen
        IF l_dto_rk-typ <> 'A' AND l_rk_pos-haup_nebenforderung = 'H' AND lv_nuller_kaz IS INITIAL.
          CONTINUE.
        ENDIF.

        CLEAR: l_soll, l_ist, l_saldo.

        IF l_rk_pos-haup_nebenforderung = 'N'.
          l_soll = l_rk_pos-sollnf.
        ELSE.
          l_soll = l_rk_pos-sollhf.
        ENDIF.
        l_ist  = l_rk_pos-ist.
        l_saldo = l_soll - l_ist.
        IF l_saldo < '0.00'.
          " Weiter

        ELSE.
          " Hier nur Korrektur der negativen Beträge
          CONTINUE.
        ENDIF.

* Prüfen ob es schon eine Buchung außer Mig zu dem Kassenzeichen gibt, dann manuell aussteuern
        SELECT SINGLE belnr FROM bkpf INTO @DATA(lv_bkpf_beln) WHERE xblnr = @l_dto_rk-s_kassenzeichen AND budat <> @gv_budat.
        IF sy-subrc = 0.
          IF p_zahl IS INITIAL.
            APPEND VALUE #(
                 type    = 'I'
                 xblnr   = l_dto_rk-s_kassenzeichen
                 message = 'Buchung auf Kassenzeichen wurde ignoriert'
                 msgno   = '005'
                 cnt     = 1
            ) TO gt_messages.
          ELSE.
            APPEND VALUE #(
                   type    = 'E'
                   xblnr   = l_dto_rk-s_kassenzeichen
                   message = 'Buchung auf Kassenzeichen vorhanden, manuelle prüfen'
                   msgno   = '004'
                   cnt     = 1
            ) TO gt_messages.
            CONTINUE.
          ENDIF.
        ENDIF.

        CONCATENATE 'RKP' l_dto_rk-s_kassenzeichen l_rk_pos-pos_nr l_rk_pos-haup_nebenforderung INTO DATA(l_satz_id_rk_pos) SEPARATED BY '_'.

        SELECT SINGLE * INTO @DATA(l_ao_sap)
          FROM /thkr/mig_ao_sap
          WHERE satz_id = @l_satz_id_rk_pos.

        IF sy-subrc = 0 AND ls_selection-flag_init_op_kassenzeichen IS INITIAL.
          APPEND VALUE #(
             type    = 'W'
             xblnr   = l_dto_rk-s_kassenzeichen
             message = 'MIG Eintrag bereits vorhanden, prüfen'
             msgno   = '001'
             cnt     = 1
          ) TO gt_messages.
          CONTINUE.
        ENDIF.

        l_ao_sap-satz_id   = l_satz_id_rk_pos.
        l_ao_sap-xblnr     = l_dto_rk-s_kassenzeichen.
        l_ao_sap-rk_pos_nr = l_rk_pos-pos_nr.
        l_ao_sap-rk_pos_nr_haushaltsjahr = l_rk_pos-haushaltsjahr.
        l_ao_sap-epl       = l_rk_pos-einzelplan.
        l_ao_sap-zp_nr     = l_dto_rk-zp-zp_nummer.
        l_ao_sap-zp_lfd_nr = l_dto_rk-zp-zp_lfd_nummer.
        IF l_ao_sap-status  < '06'. "Status nicht überschreiben, wenn neu initialisiert
          l_ao_sap-status = '06'.
        ENDIF.
        l_ao_sap-haup_nebenforderung = l_rk_pos-haup_nebenforderung.
        IF l_rk_pos-haup_nebenforderung = 'N'.
          READ TABLE l_dto_rk-t_rk_faell ASSIGNING FIELD-SYMBOL(<fs_hf_faell>) WITH KEY faellig_dtu = ls_ao_dto_h-fealligkeit.
          IF sy-subrc = 0.
            READ TABLE <fs_hf_faell>-t_rk_pos ASSIGNING FIELD-SYMBOL(<fs_pos_h>) WITH KEY haup_nebenforderung = 'H'.
            IF sy-subrc = 0.
              l_ao_sap-pos_nr_haupforderung = <fs_pos_h>-pos_nr.
            ENDIF.
          ELSE.
            " MIG AO Ohne POS_NR_HAUPFORDERUNG
            READ TABLE l_rk_faell-t_rk_pos INTO DATA(ls_faell_h) WITH KEY haup_nebenforderung = 'H'.
            IF sy-subrc = 0.
              l_ao_sap-pos_nr_haupforderung = ls_faell_h-pos_nr.
            ELSE.
              " HF liegt in anderer Fälligkeit
              LOOP AT l_dto_rk-t_rk_faell ASSIGNING FIELD-SYMBOL(<fs_h_faell>) WHERE faellig_dtu <> l_rk_faell-faellig_dtu.
                READ TABLE <fs_h_faell>-t_rk_pos ASSIGNING FIELD-SYMBOL(<fs_faell_h>) WITH KEY haup_nebenforderung = 'H'.
                IF sy-subrc = 0.
                  l_ao_sap-pos_nr_haupforderung = <fs_faell_h>-pos_nr.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ELSE.
          l_ao_sap-pos_nr_haupforderung = l_rk_pos-pos_nr.
        ENDIF.
        l_ao_sap-nuller_kassenzeichen = lv_nuller_kaz.
        l_ao_sap-rk_abs = abap_true.


        IF p_test = 'X'.
          APPEND VALUE #(
            type                = 'E'
            xblnr               = l_dto_rk-s_kassenzeichen
            satz_id             = l_ao_sap-satz_id
            rk_pos_nr           = l_ao_sap-rk_pos_nr
            haup_nebenforderung = l_ao_sap-haup_nebenforderung
            soll                = l_soll
            ist                 = l_ist
            saldo               = l_saldo
            message             = 'Negativer Betrag erkannt'
            msgno               = '002'
            cnt                 = 1
          ) TO gt_messages.
        ELSE.

          MODIFY /thkr/mig_ao_sap FROM l_ao_sap.

          APPEND VALUE #(
              type                = 'S'
              xblnr               = l_dto_rk-s_kassenzeichen
              satz_id             = l_ao_sap-satz_id
              rk_pos_nr           = l_ao_sap-rk_pos_nr
              haup_nebenforderung = l_ao_sap-haup_nebenforderung
              soll                = l_soll
              ist                 = l_ist
              saldo               = l_saldo
              message             = 'Datensatz hinzugefügt'
              msgno               = '003'
              cnt                 = 1
          ) TO gt_messages.
        ENDIF.



      ENDLOOP. " RK Pos zu einer Fälligkeit

    ENDLOOP. " RK Fälligkeit zu einem RK



    IF p_test IS INITIAL.

      UPDATE /thkr/mig_rk_sap
        SET kass_op_initialized ='X'
        WHERE satz_id = l_dto_rk-satz_id.

      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.


  ENDLOOP. " Alle RK



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

      lo_salv->get_columns( )->get_column( 'SOLL' )->set_short_text( 'Soll' ).
      lo_salv->get_columns( )->get_column( 'SOLL' )->set_long_text( 'Soll' ).
      lo_salv->get_columns( )->get_column( 'SOLL' )->set_medium_text( 'Soll' ).
      lo_salv->get_columns( )->get_column( 'IST' )->set_short_text( 'Ist' ).
      lo_salv->get_columns( )->get_column( 'IST' )->set_long_text( 'Ist' ).
      lo_salv->get_columns( )->get_column( 'IST' )->set_medium_text( 'Ist' ).
      lo_salv->get_columns( )->get_column( 'SALDO' )->set_short_text( 'Saldo' ).
      lo_salv->get_columns( )->get_column( 'SALDO' )->set_long_text( 'Saldo' ).
      lo_salv->get_columns( )->get_column( 'SALDO' )->set_medium_text( 'Saldo' ).

      lo_salv->display( ).

    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.
