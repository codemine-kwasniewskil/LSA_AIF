*&---------------------------------------------------------------------*
*& Report Z_FI_FK850_K_JOURNAL
*&---------------------------------------------------------------------*
************************************************************************
* Bericht 850 Kassenzeichen-Belegjournal - hier kLSA891 --> B891
*
************************************************************************
* Beschreibung:
*
* Der Bericht ermöglicht es, durch die Angabe der Kassenzeichen
* und/oder des Verwendungszwecks im Anordnungsbeleg, die Haushalts-
* buchungen aufzulisten.
* Zusätzlich besteht die Möglichkeit, die Buchungen zeitlich
* (Fortschreibungsdatum im Haushaltsmanagement) einzuschränken.
* Die Eingabe von Wildcards wird bei der Suche unterstützt.
************************************************************************
* Autor: Andreas Mühr
* Firma: DXC Technology Deutschland GmbH
************************************************************************
* 2025-04-02 js - Layout /LHK als Default

INCLUDE /thkr/fi_fk850_k_journal_top.                 " Global Data

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_alvlay.
  DATA: lv_layout_key TYPE salv_s_layout_key.

  lv_layout_key-report = sy-repid.
  p_alvlay = cl_salv_layout_service=>f4_layouts( lv_layout_key )-layout.

AT SELECTION-SCREEN.
  IF s_xblnr[] IS INITIAL AND s_sgtxt[] IS INITIAL AND
     s_fipex[] IS INITIAL AND s_fistl[] IS INITIAL.     "js
    MESSAGE e001 WITH 'Bitte Referenz und/oder Textsuche pflegen'(000).
  ENDIF.

START-OF-SELECTION.

* Daten holen
  SELECT FROM /thkr/cds_bjcube
    FIELDS
      stunr
      ,fikrs
      ,financialmanagementareaname
      ,fipex
      ,commitmentitemdescription
      ,fistl
      ,fundscenterdescription
      ,wrttp
      ,controllingvaluetypename
      ,bukrs
      ,controllingareaname
      ,gjahr
      ,documentreferenceid
      ,zhldt
      ,lotkz
      ,accountingdocumenttype
      ,knbelnr
      ,bsegsi_belnr
      ,bsegan_belnr
      ,kngjahr
      ,knbuzei
      ,accountingdoccreatedbyuser
      ,twaer
      ,psofn
      ,btart
      ,solloriginalbetrag
      ,CAST( gezahlt AS CURR( 12,2 ) ) AS gezahlt
      ,offenessoll
      ,auggj
      ,kunnr
      ,kundenname
      ,lifnr
      ,lifname
      ,augbl
      ,augdt
      ,erledigt
      ,sgtxt
      ,gsber
      ,wrbtr
      ,pruefung
      ,bsegsikn
      ,bsegsili
      ,bsegankn
      ,bseganli
      ,vrgng
      ,maber
    WHERE    fikrs               EQ @p_fikrs
         AND zhldt               LE @p_stdat
         AND documentreferenceid IN @s_xblnr
         AND zhldt               IN @s_zhldt
         AND sgtxt               IN @s_sgtxt
         AND fipex               IN @s_fipex    "js
         AND fistl               IN @s_fistl    "js
         AND maber               IN @s_maber
    ORDER BY bukrs, documentreferenceid, stunr  "js
    INTO TABLE @DATA(gt_result).
  IF sy-subrc NE 0.
    MESSAGE s048 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

* AUTHORITY-CHECK
  DATA(gt_result_check) = gt_result.

* Check Buchungskreis
  gt_result_check = gt_result.

  SORT gt_result_check BY bukrs.

  CLEAR: lv_bukrs_temp, gv_no_auth_flag.
  LOOP AT gt_result_check INTO DATA(ls_result).
    IF ls_result-bukrs NE lv_bukrs_temp.
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
          ID 'ACTVT' FIELD '03'
          ID 'BUKRS' FIELD ls_result-bukrs.
      IF sy-subrc NE 0.
        DELETE gt_result WHERE bukrs EQ ls_result-bukrs.
        gv_no_auth_flag = 'X'.
      ENDIF.
    ENDIF.
    lv_bukrs_temp = ls_result-bukrs.
  ENDLOOP.

* Check Geschäftsbereich
  gt_result_check = gt_result.

  SORT gt_result_check BY gsber.

  CLEAR: lv_gsber_temp.
  LOOP AT gt_result_check INTO ls_result.
    IF ls_result-gsber NE lv_gsber_temp.
      AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
          ID 'ACTVT' FIELD '03'
          ID 'GSBER' FIELD ls_result-gsber.
      IF sy-subrc NE 0.
        DELETE gt_result WHERE gsber EQ ls_result-gsber.
        gv_no_auth_flag = 'X'.
      ENDIF.
    ENDIF.
    lv_gsber_temp = ls_result-gsber.
  ENDLOOP.

  "Check Z_FICA(_TRG oder _UTK)

  gt_result_check = gt_result.
  SORT gt_result_check BY fikrs fistl fipex.
  DELETE ADJACENT DUPLICATES FROM gt_result_check COMPARING fikrs fistl fipex.

  DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).

  LOOP AT gt_result_check INTO ls_result.

    SELECT SINGLE augrp FROM fmfctr INTO lv_fmfctr_auth
    WHERE fictr EQ ls_result-fistl AND
          fikrs EQ ls_result-fikrs  AND
          datbis GE sy-datum.

    CASE lv_object_fica.
      WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

        CALL FUNCTION '/THKR/CHECK_FICA_UTK'
          EXPORTING
            activity          = '03'
            fm_area           = ls_result-fikrs
            fm_fmfctr_authgrp = lv_fmfctr_auth
            fm_fipex          = ls_result-fipex
*           IV_USER           = SY-UNAME
          IMPORTING
            ex_subrc          = lv_rc.
      WHEN OTHERS.

        SELECT SINGLE augrp FROM fmci INTO lv_fipex_auth
         WHERE fipex EQ ls_result-fipex AND
         fikrs EQ ls_result-fikrs.

        CALL FUNCTION 'Z_CHECK_FICA_TRG'
          EXPORTING
            activity          = '03'
            fm_area           = ls_result-fikrs
            fm_fmfctr_authgrp = lv_fmfctr_auth
            fm_fipex_authgrp  = lv_fipex_auth
*           IV_USER           = SY-UNAME
          IMPORTING
            ex_subrc          = lv_rc.

    ENDCASE.

    IF lv_rc <> 0.

      DELETE gt_result WHERE fikrs EQ ls_result-fikrs
      AND fistl = ls_result-fistl AND fipex = ls_result-fipex.
      gv_no_auth_flag = 'X'.

    ENDIF.
    CLEAR lv_rc.

  ENDLOOP.


  DATA: lt_partner TYPE STANDARD TABLE OF bu_partner.
  "Prüfung, ob Geschäftspartnerdaten berechtigt sind.
  gt_result_check = gt_result.
  SELECT DISTINCT lifnr FROM @gt_result_check AS result
    WHERE lifnr IS NOT INITIAL
    INTO TABLE @DATA(lt_lifnr).

  SELECT DISTINCT kunnr FROM @gt_result_check AS result
    WHERE kunnr IS NOT INITIAL
    INTO TABLE @DATA(lt_kunnr).


  APPEND LINES OF lt_lifnr TO lt_partner.
  APPEND LINES OF lt_kunnr TO lt_partner.

  IF lt_partner IS NOT INITIAL.

    SORT lt_partner.
    DELETE ADJACENT DUPLICATES FROM lt_partner.

    DATA(lv_object) = /thkr/cl_auth_check=>get_bupa_object( ).

    LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).

      DATA(rv_no_auth) = /thkr/cl_auth_check=>check_bupa_auth(
      EXPORTING iv_partner = <fs_partner>
                iv_object = lv_object
      ).
      IF rv_no_auth = abap_true.

        DELETE gt_result WHERE lifnr = <fs_partner> OR kunnr = <fs_partner>.
        gv_no_auth_flag = 'X'.
        CLEAR rv_no_auth.
      ENDIF.

    ENDLOOP.

    CLEAR lt_partner.

  ENDIF.



* Meldungen
  IF gt_result IS INITIAL.
    MESSAGE s052 DISPLAY LIKE 'E'.
    RETURN.
  ELSE.
    IF gv_no_auth_flag EQ 'X'.
      MESSAGE i051.
    ENDIF.
  ENDIF.

END-OF-SELECTION.
* Feldkatalog automatisch durch SALV-Objekte erstellen lassen

  cl_salv_table=>factory( IMPORTING r_salv_table = o_salv
                          CHANGING  t_table      = gt_result ).

* Spalten lesen
  col_tab = o_salv->get_columns( ).
  col_ref = col_tab->get( ).

* Hotspot setzen
  LOOP AT col_ref INTO wa.
    CASE wa-columnname.
      WHEN 'KNBELNR' OR 'AUGBL'.
        col ?= wa-r_column.
        col->set_key( abap_true ).
        col->set_cell_type( 5 ).  "5 = Hotspot
    ENDCASE.
  ENDLOOP.

* Events
  SET HANDLER lcl_events=>on_link_click   FOR o_salv->get_event( ).

* fehlende Spaltenbezeichner mit Feldname auffüllen
  lo_columns = o_salv->get_columns( ).
  lt_cols    = lo_columns->get( ).

  LOOP AT lt_cols INTO ls_cols.
    lo_column ?= ls_cols-r_column.

    lv_txt_s = lo_column->get_short_text( ).
    lv_txt_m = lo_column->get_short_text( ).
    lv_txt_l = lo_column->get_short_text( ).

    CASE ls_cols-columnname.
      WHEN 'SOLLORIGINALBETRAG'.
        lv_txt_s = lv_txt_m = lv_txt_l = 'Soll-Originalbetrag'(001).
        lo_column->set_long_text( lv_txt_l ).
        lo_column->set_medium_text( lv_txt_m ).
        lo_column->set_short_text( lv_txt_s ).
        lo_column->set_currency_column( 'TWAER' ).
      WHEN 'GEZAHLT'.
        lv_txt_s = lv_txt_m = lv_txt_l = 'Gezahlt'(002).
        lo_column->set_long_text( lv_txt_l ).
        lo_column->set_medium_text( lv_txt_m ).
        lo_column->set_short_text( lv_txt_s ).
        lo_column->set_currency_column( 'TWAER' ).
      WHEN 'OFFENESSOLL'.
        lv_txt_s = lv_txt_m = lv_txt_l = 'offenes Restsoll'(003).
        lo_column->set_long_text( lv_txt_l ).
        lo_column->set_medium_text( lv_txt_m ).
        lo_column->set_short_text( lv_txt_s ).
        lo_column->set_currency_column( 'TWAER' ).
      WHEN 'KUNDENNAME'.
        lv_txt_s = lv_txt_m = lv_txt_l = 'Name Debitor'(004).
        lo_column->set_long_text( lv_txt_l ).
        lo_column->set_medium_text( lv_txt_m ).
        lo_column->set_short_text( lv_txt_s ).

      WHEN 'LIFNAME'.
        lv_txt_s = lv_txt_m = lv_txt_l = 'Name Kreditor'(005).
        lo_column->set_long_text( lv_txt_l ).
        lo_column->set_medium_text( lv_txt_m ).
        lo_column->set_short_text( lv_txt_s ).

      WHEN 'ERLEDIGT'.
        lv_txt_s = lv_txt_m = lv_txt_l = 'erledigt'(006).
        lo_column->set_long_text( lv_txt_l ).
        lo_column->set_medium_text( lv_txt_m ).
        lo_column->set_short_text( lv_txt_s ).

      WHEN 'WRBTR'.
        lv_txt_s = lv_txt_m = lv_txt_l = 'Betrag in Belegwährung'(007).
        lo_column->set_long_text( lv_txt_l ).
        lo_column->set_medium_text( lv_txt_m ).
        lo_column->set_short_text( lv_txt_s ).

      WHEN 'PRUEFUNG'.
        lv_txt_s = lv_txt_m = lv_txt_l = 'Prüfung'(008).
        lo_column->set_long_text( lv_txt_l ).
        lo_column->set_medium_text( lv_txt_m ).
        lo_column->set_short_text( lv_txt_s ).
    ENDCASE.
  ENDLOOP.

* Layout/Variante setzen
  IF NOT p_alvlay IS INITIAL.
    lv_variant = p_alvlay.
  ELSE.
    lv_variant = '/LHK'.
  ENDIF.

  o_salv->get_layout( )->set_initial_layout( lv_variant ).
* Benutzerspezifische Layouts aktivieren

  lv_layout_key-report = sy-repid.
  o_alv_layout = o_salv->get_layout( ).
  o_alv_layout->set_key( lv_layout_key ).
  o_alv_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

* Grundeinstellungen
  o_salv->get_functions( )->set_all( abap_true ).
  o_salv->get_columns( )->set_optimize( abap_true ).
  o_salv->get_display_settings( )->set_list_header( sy-title ).
  o_salv->get_display_settings( )->set_striped_pattern( abap_true ).
  o_salv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).
  o_salv->get_functions( )->set_all( ).

* ALV anzeigen
  o_salv->display( ).

  INCLUDE /thkr/fi_fk850_k_journal_c01.                 " Klassenimplementierung
