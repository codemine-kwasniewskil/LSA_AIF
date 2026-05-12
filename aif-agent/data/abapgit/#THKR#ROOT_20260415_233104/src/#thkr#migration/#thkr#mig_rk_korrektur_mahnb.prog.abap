*&---------------------------------------------------------------------*
*& Report /THKR/MIG_RK_KORREKTUR_MAHNB
*&---------------------------------------------------------------------*
*& Dieser Korrektur-Report soll falsche Mahnbereiche beheben
*&---------------------------------------------------------------------*
REPORT /thkr/mig_rk_korrektur_mahnb.


TYPES: BEGIN OF ty_message,
         type                TYPE syst-msgty,
         lotkz               TYPE pso_lotkz,
         xblnr               TYPE xblnr,
         bukrs               TYPE bukrs,
         belnr               TYPE belnr,
*         satz_id             TYPE /thkr/de_satz_id,
*         rk_pos_nr           TYPE /thkr/rk_pos_nr,
         haup_nebenforderung TYPE /thkr/mig_hf_nf,
         maber_old           TYPE maber,
         maber_new           TYPE maber,
         message             TYPE char100,
         msgid               TYPE syst_msgid,
         msgno               TYPE syst_msgno,
         cnt                 TYPE int4,
       END OF ty_message.


DATA:
  gt_vorgang_schl_ra TYPE RANGE OF char8,
  gv_bukrs           TYPE bukrs,
  gv_belnr           TYPE belnr_d,
  gv_gjahr           TYPE gjahr,
  gv_budat_text(10)  TYPE c,
  gv_change          TYPE c,
  gv_xblnr           TYPE xblnr,
  gt_messages        TYPE TABLE OF ty_message.

**********************************************************************
SELECT-OPTIONS:
            so_bukrs FOR gv_bukrs NO INTERVALS,
            so_belnr  FOR gv_belnr,
            so_xblnr FOR gv_xblnr.

PARAMETERS:
  p_mabero TYPE maber,
  p_mabern TYPE maber,
  p_mahns  TYPE mahns_d DEFAULT '2'.


PARAMETERS:
  p_setmb TYPE c RADIOBUTTON GROUP rb1 DEFAULT 'X',
  p_000   TYPE c RADIOBUTTON GROUP rb1,
  p_vorg  TYPE c RADIOBUTTON GROUP rb1,
  p_nfohf TYPE c RADIOBUTTON GROUP rb1,
  p_test  TYPE flag DEFAULT 'X'.

INITIALIZATION.
  SELECT SINGLE budat FROM /thkr/mig_md INTO @DATA(gv_budat).
  WRITE gv_budat TO gv_budat_text.
  gv_gjahr = gv_budat+0(4).

  gt_vorgang_schl_ra = VALUE #(
  ( sign = 'I' option = 'EQ' low = 'BEITR-M1' )
  ( sign = 'I' option = 'EQ' low = 'BEITR-M2' )
  ( sign = 'I' option = 'EQ' low = 'BEITR-M5' )
  ( sign = 'I' option = 'EQ' low = 'BEITR-M6' )
  ( sign = 'I' option = 'EQ' low = 'BEITR-M8' )
  ( sign = 'I' option = 'EQ' low = 'BEITR-M9' )
  ( sign = 'I' option = 'EQ' low = 'BEITR-P5' )
  ( sign = 'I' option = 'EQ' low = 'ERINM1' )
  ( sign = 'I' option = 'EQ' low = 'ERINM8' )
  ( sign = 'I' option = 'EQ' low = 'MAHNM8' )
  ( sign = 'I' option = 'EQ' low = 'MAHNM9' )
  ( sign = 'I' option = 'EQ' low = 'mawp5' )
  ( sign = 'I' option = 'EQ' low = 'vaaheA1' )
  ( sign = 'I' option = 'EQ' low = 'VOLLSTM1' )
  ( sign = 'I' option = 'EQ' low = 'VOLLSTM2' )
  ( sign = 'I' option = 'EQ' low = 'VOLLSTM5' )
  ( sign = 'I' option = 'EQ' low = 'VOLLSTM6' )
  ( sign = 'I' option = 'EQ' low = 'VOLLSTM8' )
  ( sign = 'I' option = 'EQ' low = 'VOLLSTM9' )
  ( sign = 'I' option = 'EQ' low = 'VOLLSTP5' )
  ).



AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
*    IF screen-name CS 'P_MIGOBJ' OR screen-name CS 'P_USER'.
*      screen-input = 0.
*      MODIFY SCREEN.
*    ENDIF.
  ENDLOOP.


**********************************************************************
START-OF-SELECTION.

  DATA:
    lt_accchg    TYPE table_type_accchg,
    lv_maber_new TYPE maber.


*  IF p_mabero IS INITIAL AND p_vorg = abap_true.
*    MESSAGE 'Alten Mahnbereich angeben' TYPE 'I'.
*    RETURN.
*  ENDIF.

* Selektion aller Belege

  CASE abap_true.
    WHEN p_setmb.
      " beliebeige Belege
      IF so_belnr[] IS INITIAL.
        MESSAGE 'Für direkte Selektion müssen Belege vorgegeben werden.' TYPE 'I'.
      ELSE.
        SELECT * FROM /thkr/mig_ao_sap INTO TABLE @DATA(lt_mig_data) WHERE xblnr IN @so_xblnr AND belnr IN @so_belnr AND bukrs IN @so_bukrs.
      ENDIF.

    WHEN p_000.
      " alle NF zu Nuller kassenzeichen
      " erst alle gekennzeichneten HF erkennen
      SELECT * FROM /thkr/mig_ao_sap INTO TABLE @DATA(lt_mig_data_000_hf) WHERE xblnr IN @so_xblnr AND belnr IN @so_belnr AND bukrs IN @so_bukrs
        AND nuller_kassenzeichen = @abap_true AND haup_nebenforderung = 'H'.
      " alle anderen Belege dazu denen das Kennzeichen fehlt ermitteln
      SELECT * FROM /thkr/mig_ao_sap INTO TABLE @lt_mig_data FOR ALL ENTRIES IN @lt_mig_data_000_hf
        WHERE xblnr = @lt_mig_data_000_hf-xblnr AND haup_nebenforderung = 'N' AND nuller_kassenzeichen = ''.

    WHEN p_nfohf.
      " NF ohne HF
      SELECT * FROM /thkr/mig_ao_sap AS a INTO TABLE @lt_mig_data WHERE xblnr IN @so_xblnr AND belnr IN @so_belnr AND bukrs IN @so_bukrs
         AND haup_nebenforderung = 'N' AND NOT EXISTS ( SELECT * FROM /thkr/mig_ao_sap AS b WHERE b~xblnr = a~xblnr AND ( haup_nebenforderung = '' OR haup_nebenforderung = 'H' ) ).

    WHEN p_vorg.
      SELECT * FROM /thkr/mig_ao_sap INTO TABLE @lt_mig_data WHERE xblnr IN @so_xblnr AND belnr IN @so_belnr AND bukrs IN @so_bukrs.

    WHEN OTHERS.
  ENDCASE.




  LOOP AT lt_mig_data ASSIGNING FIELD-SYMBOL(<fs_mig_data>) WHERE belnr IS NOT INITIAL.
    CLEAR: lv_maber_new.

    SELECT SINGLE * FROM bsid_view INTO @DATA(ls_bsid)
      WHERE bukrs = @<fs_mig_data>-bukrs AND gjahr = @gv_gjahr AND belnr = @<fs_mig_data>-belnr AND buzei = 1 and manst = @p_mahns.
    IF sy-subrc <> 0.
*      APPEND VALUE #(
*                     type    = 'E'
*                     bukrs   = <fs_mig_data>-bukrs
*                     xblnr   = <fs_mig_data>-xblnr
*                     belnr   = <fs_mig_data>-belnr
*                     message = |Fehler Beleg Selektion|
*                     msgid   = '001'
*                     cnt     = 1
*      ) TO gt_messages.
      CONTINUE.
    ENDIF.

    CASE abap_true.
      WHEN  p_vorg.
        " alle Belege mit Mahnbereich SO sollen neuen Mahnschlüssel aus Vorgang bekommen
        IF ls_bsid-maber <> p_mabero.
          CONTINUE.
        ENDIF.

        SELECT SINGLE vorgang_schl FROM /thkr/migd_rkv INTO @DATA(lv_vorgang)
          WHERE satz_id = @<fs_mig_data>-xblnr AND vorgang_schl IN @gt_vorgang_schl_ra.
        IF sy-subrc = 0.
          DATA(lv_cnt) = strlen( lv_vorgang ) - 2.
          lv_maber_new = lv_vorgang+lv_cnt(2).
        ELSE.
          "keine Ableitung möglich
          APPEND VALUE #(
                type      = 'E'
                lotkz     = <fs_mig_data>-lotkz
                bukrs     = ls_bsid-bukrs
                xblnr     = ls_bsid-xblnr
                belnr     = ls_bsid-belnr
*                      mansp     = ls_bsid-mansp
                maber_old = ls_bsid-maber
*                      maber_new = lv_maber_new
                haup_nebenforderung = <fs_mig_data>-haup_nebenforderung
                message   = |Mahnbereich nicht aus Vorgang ableitbar|
                msgid     = '002'
                cnt       = 1
          ) TO gt_messages.
          CONTINUE.
        ENDIF.

      WHEN p_setmb.
        " Mahnbereich in Beleg von alt nach neu setzen
        IF p_mabero IS NOT INITIAL AND ls_bsid-maber <> p_mabero. " Nur den aus der Selektion berücksichtigen
          CONTINUE.
        ENDIF.
        lv_maber_new = p_mabern.


      WHEN p_000.
        " hier muss die NF den MABER der HF bekommen
        DATA(lv_000_hf_belnr) = lt_mig_data_000_hf[ xblnr = <fs_mig_data>-xblnr haup_nebenforderung = 'H' ]-belnr.
        SELECT SINGLE maber FROM bsid_view INTO @lv_maber_new
          WHERE bukrs = @<fs_mig_data>-bukrs AND gjahr = @ls_bsid-gjahr AND belnr = @lv_000_hf_belnr AND buzei = 1.

      WHEN p_nfohf.
        " aus RK Event ermitteln
        " prüfen ob es ein Vorgang mit den def. Schlüsseln gibt
        SELECT SINGLE vorgang_schl FROM /thkr/migd_rkv INTO @lv_vorgang WHERE satz_id = @<fs_mig_data>-xblnr AND vorgang_schl IN @gt_vorgang_schl_ra.
        IF sy-subrc = 0.
          lv_cnt = strlen( lv_vorgang ) - 2.
          lv_maber_new = lv_vorgang+lv_cnt(2).
        ELSE.
          "keine Ableitung möglich
          APPEND VALUE #(
                type      = 'E'
                lotkz     = <fs_mig_data>-lotkz
                bukrs     = ls_bsid-bukrs
                xblnr     = ls_bsid-xblnr
                belnr     = ls_bsid-belnr
*                      mansp     = ls_bsid-mansp
                maber_old = ls_bsid-maber
*                      maber_new = lv_maber_new
                haup_nebenforderung = <fs_mig_data>-haup_nebenforderung
                message   = |Mahnbereich nicht aus Vorgang ableitbar|
                msgid     = '002'
                cnt       = 1
          ) TO gt_messages.
          CONTINUE.
        ENDIF.
    ENDCASE.

    IF ls_bsid-maber = lv_maber_new.
      " Dann keine Änderung
      CONTINUE.
    ENDIF.

    APPEND VALUE #(
                   fdname = 'MABER'
                   oldval = ls_bsid-maber
                   newval = lv_maber_new
                  ) TO lt_accchg.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        x_lock               = 'X'
        i_bukrs              = ls_bsid-bukrs
        i_belnr              = ls_bsid-belnr
        i_gjahr              = ls_bsid-gjahr
        i_buzei              = ls_bsid-buzei
      TABLES
        t_accchg             = lt_accchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_msg).
      APPEND VALUE #(
                      type      = sy-msgty
                      lotkz     = <fs_mig_data>-lotkz
                      bukrs     = ls_bsid-bukrs
                      xblnr     = ls_bsid-xblnr
                      belnr     = ls_bsid-belnr
*                      mansp     = ls_bsid-mansp
                      maber_old = ls_bsid-maber
                      maber_new = p_mabern
                      haup_nebenforderung = <fs_mig_data>-haup_nebenforderung
                      message   = lv_msg
                      msgid     = sy-msgid
                      msgno     = sy-msgno
                      cnt       = 1
                    ) TO gt_messages.
    ELSE.
      APPEND VALUE #(
                      type      = 'S'
                      lotkz     = <fs_mig_data>-lotkz
                      bukrs     = ls_bsid-bukrs
                      xblnr     = ls_bsid-xblnr
                      belnr     = ls_bsid-belnr
*                      mansp     = ls_bsid-mansp
                      maber_old = ls_bsid-maber
                      maber_new = lv_maber_new
                      haup_nebenforderung = <fs_mig_data>-haup_nebenforderung
                      message   = |Mahnbereich auf { lv_maber_new } geändert.|
                      msgid     = '003'
                      cnt       = 1
                    ) TO gt_messages.
    ENDIF.
  ENDLOOP.

  IF  p_test = abap_true.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDIF.




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

      lo_salv->get_columns( )->get_column( 'MABER_OLD' )->set_short_text( 'Maber alt' ).
      lo_salv->get_columns( )->get_column( 'MABER_OLD' )->set_long_text( 'Maber alt' ).
      lo_salv->get_columns( )->get_column( 'MABER_OLD' )->set_medium_text( 'Maber alt' ).
      lo_salv->get_columns( )->get_column( 'MABER_NEW' )->set_short_text( 'Maber neu' ).
      lo_salv->get_columns( )->get_column( 'MABER_NEW' )->set_long_text( 'Maber neu' ).
      lo_salv->get_columns( )->get_column( 'MABER_NEW' )->set_medium_text( 'Maber neu' ).
*      lo_salv->get_columns( )->get_column( 'SALDO' )->set_short_text( 'Saldo' ).
*      lo_salv->get_columns( )->get_column( 'SALDO' )->set_long_text( 'Saldo' ).
*      lo_salv->get_columns( )->get_column( 'SALDO' )->set_medium_text( 'Saldo' ).

      lo_salv->display( ).

    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.
