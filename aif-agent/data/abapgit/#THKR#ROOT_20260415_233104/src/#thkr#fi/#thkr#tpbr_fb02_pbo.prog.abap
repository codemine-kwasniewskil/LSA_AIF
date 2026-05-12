*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_FB02_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module KREDITOR_LESEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE kreditor_lesen OUTPUT.


  bkpf-bktxt = gs_bkpf-bktxt.
  bkpf-waers = gs_bkpf-waers.
  bkpf-xblnr = gs_bkpf-xblnr.
  bkpf-bukrs = gs_bseg-bukrs.
  bkpf-psofn = gs_bkpf-psofn.

  t042-zbukr = gs_bseg-bukrs.

  bseg-hkont = gs_bseg-hkont.
  bseg-bukrs = gs_bseg-bukrs.
  bseg-filkd = gs_bseg-filkd.
  bseg-belnr = gs_bseg-belnr.
  bseg-lifnr = gs_bseg-lifnr.   "20210324_BTO
  bseg-buzei = gs_bseg-buzei.
  bseg-wrbtr = gs_bseg-wrbtr.
  bseg-mwskz = gs_bseg-mwskz.
  bseg-stbuk = gs_bseg-stbuk.
  bseg-zlspr = gs_bseg-zlspr.
  bseg-zlsch = gs_bseg-zlsch.
  bseg-sgtxt = gs_bseg-sgtxt.
  bseg-bvtyp = gs_bseg-bvtyp.               "#002
  bseg-zterm = gs_bseg-zterm.
  bseg-zfbdt = gs_bseg-zfbdt.
  bseg-zbd1t = gs_bseg-zbd1t.
  bseg-zbd2t = gs_bseg-zbd2t.
  bseg-zbd3t = gs_bseg-zbd3t.
  bseg-zbd1p = gs_bseg-zbd1p.
  bseg-zbd2p = gs_bseg-zbd2p.

  SELECT SINGLE lifnr land1 name1 stras ort01    "20210324_BTO
    FROM lfa1
    INTO ( lfa1-lifnr,
           lfa1-land1,                           "20210324_BTO
           lfa1-name1,
           lfa1-stras,
           lfa1-ort01 )
    WHERE lifnr = gs_bseg-lifnr.

  bseg-fipos = gs_bseg-fipos.
  bseg-fistl = gs_bseg-fistl.
  bseg-kostl = gs_bseg-kostl.
  bseg-aufnr = gs_bseg-aufnr.
  bseg-projk = gs_bseg-projk.

  PERFORM show_position_text.

* bei Bedarf vorhandene Änderungen übernehmen
*  LOOP AT gt_fb02 INTO gs_fb02                         "20210324_BTO
*                 WHERE belnr = gs_bseg-belnr           "20210324_BTO
*                   AND bukrs = gs_bkpf-bukrs           "20210324_BTO
*                   AND gjahr = gs_bkpf-gjahr           "20210324_BTO
*                   AND buzei = gs_bseg-buzei.          "20210324_BTO
  IF gv_change IS NOT INITIAL.
    bkpf-bktxt = gs_bkpf-bktxt = gs_fb02-bktxt.
    bkpf-psofn = gs_bkpf-psofn = gs_fb02-psofn.
    bkpf-xblnr = gs_bkpf-xblnr = gs_fb02-xblnr.
    bseg-zlspr = gs_bseg-zlspr = gs_fb02-zlspr.
    bseg-zlsch = gs_bseg-zlsch = gs_fb02-zlsch_k.
    bseg-zterm = gs_bseg-zterm = gs_fb02-zterm.
    bseg-zfbdt = gs_bseg-zfbdt = gs_fb02-zfbdt.
    bseg-zbd1t = gs_bseg-zbd1t = gs_fb02-zbd1t.
    bseg-zbd2t = gs_bseg-zbd2t = gs_fb02-zbd2t.
    bseg-zbd3t = gs_bseg-zbd3t = gs_fb02-zbd3t.
    bseg-zbd1p = gs_bseg-zbd1p = gs_fb02-zbd1p.
    bseg-zbd2p = gs_bseg-zbd2p = gs_fb02-zbd2p.
    bseg-bvtyp = gs_bseg-bvtyp = gs_fb02-bvtyp.
*    bseg-sgtxt = gs_bseg-sgtxt = gs_fb02-sgtxt.
  ENDIF.
*  ENDLOOP.

  t001-land1   = 'DE'      .    "20220311_BTO

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DEBITOR_LESEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE debitor_lesen OUTPUT.

  bkpf-bktxt = gs_bkpf-bktxt.
  bkpf-waers = gs_bkpf-waers.
  bkpf-xblnr = gs_bkpf-xblnr.
  bkpf-bukrs = gs_bseg-bukrs.
  bkpf-psofn = gs_bkpf-psofn.

  t042-zbukr = gs_bseg-bukrs.

  "WICHTIG555"
*  bkpf-z_haftvor = gs_bkpf-z_haftvor.
*  bkpf-z_014 = gs_bkpf-zz_014.

  bseg-hkont = gs_bseg-hkont.
  bseg-bukrs = gs_bseg-bukrs.
  bseg-filkd = gs_bseg-filkd.
  bseg-belnr = gs_bseg-belnr.
  bseg-buzei = gs_bseg-buzei.
  bseg-koart = gs_bseg-koart.   "20210324_BTO
  bseg-kunnr = gs_bseg-kunnr.   "20210324_BTO
  bseg-maber = gs_bseg-maber.   "20210324_BTO
  bseg-wrbtr = gs_bseg-wrbtr.
  bseg-mwskz = gs_bseg-mwskz.
  bseg-stbuk = gs_bseg-stbuk.
  bseg-mansp = gs_bseg-mansp.
  bseg-manst = gs_bseg-manst.
  bseg-zlsch = gs_bseg-zlsch.
*  bseg-sgtxt = gs_bseg-sgtxt.
  bseg-zlspr = gs_bseg-zlspr.

  bseg-zterm = gs_bseg-zterm.
  bseg-zfbdt = gs_bseg-zfbdt.
  bseg-zbd1t = gs_bseg-zbd1t.
  bseg-zbd2t = gs_bseg-zbd2t.
  bseg-zbd3t = gs_bseg-zbd3t.
  bseg-zbd1p = gs_bseg-zbd1p.
  bseg-zbd2p = gs_bseg-zbd2p.
  bseg-madat = gs_bseg-madat.
  bseg-mschl = gs_bseg-mschl.
  bseg-maber = gs_bseg-maber.
  bseg-bvtyp = gs_bseg-bvtyp.
*  bseg-hbkid = gs_bseg-hbkid.


  SELECT SINGLE kunnr land1 name1 stras ort01  "20210324_BTO
      FROM kna1
      INTO ( kna1-kunnr,
             kna1-land1,                       "20210324_BTO
             kna1-name1,
             kna1-stras,
             kna1-ort01 )
    WHERE kunnr = gs_bseg-kunnr.

  bseg-fipos = gs_bseg-fipos.
  bseg-fistl = gs_bseg-fistl.
  bseg-kostl = gs_bseg-kostl.
  bseg-aufnr = gs_bseg-aufnr.
  bseg-projk = gs_bseg-projk.

  """"
  PERFORM show_position_text.
*CREATE OBJECT lr_container2
*    EXPORTING
*      container_name = 'CC_POSITIONEN'
*      repid          = sy-repid
*      dynnr          = '0301'.
*
*DATA(lr_alv2) = NEW cl_gui_alv_grid( i_parent      = lr_container2 " in default container einbetten
*                                     i_appl_events = abap_true ).
*
*  CALL METHOD cl_salv_table=>factory
*    IMPORTING
*      r_salv_table = lr_salv2
*    CHANGING
*      t_table      = gt_texte.
*
*  DATA(it_fcat2) = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns      = lr_salv2->get_columns( )
*                                                                     r_aggregations = lr_salv2->get_aggregations( ) ).
*  Delete it_fcat2 where fieldname NE 'BUZEI' AND
*                        fieldname NE 'SGTXT' AND
*                        fieldname NE 'ZUONR'.
*
*    LOOP AT it_fcat2 INTO DATA(ls_fcat2).
*    CASE ls_fcat2-fieldname.
*      WHEN 'SGTXT'.
*        ls_fcat2-edit      = 'X'.
*        ls_fcat2-coltext   = 'Positionstext'.
*        ls_fcat2-outputlen = 50.
*      WHEN 'ZUONR'.
*        ls_fcat2-edit      = 'X'.
*        ls_fcat2-coltext   = 'Zuordnung'.
*        ls_fcat2-outputlen = 20.
*    ENDCASE.
*    MODIFY it_fcat2 FROM ls_fcat2.
*  ENDLOOP.
*
*  DATA(lv_layout2) = VALUE lvc_s_layo( zebra      = abap_true             " ALV-Control: Alternierende Zeilenfarbe (Zebramuster)
*                                      cwidth_opt = 'A'                   " ALV-Control: Spaltenbreite optimieren
*                                      no_toolbar = 'X' ).
*  lr_alv2->set_table_for_first_display( EXPORTING
*                                        is_layout          = lv_layout2
*                                      CHANGING
*                                        it_fieldcatalog    = it_fcat2
*                                        it_outtab          = gt_texte ).
**  lr_alv->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
**  lr_alv->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
*
*  cl_gui_alv_grid=>set_focus( control = lr_alv2 ).
*  cl_abap_list_layout=>suppress_toolbar( ).


  """"
* bei Bedarf vorhandene Änderungen übernehmen
  IF gv_change IS NOT INITIAL.
    bkpf-bktxt = gs_bkpf-bktxt = gs_fb02-bktxt.
    bkpf-xblnr = gs_bkpf-xblnr = gs_fb02-xblnr.
    bkpf-psofn = gs_bkpf-psofn = gs_fb02-psofn.
    "WICHTIG555"
*    bkpf-zz_haftvor = gs_bkpf-zz_haftvor
*                    = gs_fb02-zz_haftvor.
*    bkpf-zz_014 = gs_bkpf-zz_014 = gs_fb02-zz_014.
    bseg-mansp = gs_bseg-mansp = gs_fb02-mansp.
    bseg-manst = gs_bseg-manst = gs_fb02-manst.
    bseg-zlsch = gs_bseg-zlsch = gs_fb02-zlsch_d.

    bseg-zlspr = gs_bseg-zlspr = gs_fb02-zlspr.
    bseg-zterm = gs_bseg-zterm = gs_fb02-zterm.
    bseg-zfbdt = gs_bseg-zfbdt = gs_fb02-zfbdt.
    bseg-zbd1t = gs_bseg-zbd1t = gs_fb02-zbd1t.
    bseg-zbd2t = gs_bseg-zbd2t = gs_fb02-zbd2t.
    bseg-zbd3t = gs_bseg-zbd3t = gs_fb02-zbd3t.
    bseg-zbd1p = gs_bseg-zbd1p = gs_fb02-zbd1p.
    bseg-zbd2p = gs_bseg-zbd2p = gs_fb02-zbd2p.
    bseg-madat = gs_bseg-madat = gs_fb02-madat.
    bseg-mschl = gs_bseg-mschl = gs_fb02-mschl.
    bseg-maber = gs_bseg-maber = gs_fb02-maber.
    bseg-bvtyp = gs_bseg-bvtyp = gs_fb02-bvtyp.
*    bseg-hbkid = gs_bseg-hbkid = gs_fb02-hbkid.
  ENDIF.

  t001-land1   = 'DE'      .              "20210324_BTO
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_PF_STATUS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_pf_status OUTPUT.
  SET PF-STATUS 'UELV'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module TITLE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE title OUTPUT.
  SET TITLEBAR 'AEND'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_PF_STATUS_AEND OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_pf_status_aend OUTPUT.
  SET PF-STATUS 'AEND'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module AUTHORITY_CHECK OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE authority_check OUTPUT.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
       ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e133(/thkr/fi_wf_bkpf).
* Keine Berechtigung zur Bearbeitung vorhanden.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_OK OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_ok OUTPUT.
  CLEAR ok-code.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init OUTPUT.
  PERFORM init.
ENDMODULE.

MODULE texte_lesen OUTPUT.
  DATA: lt_bseg      TYPE TABLE OF bseg,
        lr_salv      TYPE REF TO cl_salv_table,
        lr_container TYPE REF TO cl_gui_custom_container.

  bkpf-bktxt = gs_bkpf-bktxt.
*  bkpf-XBLNR = gs_bkpf-XBLNR.
  bseg-hkont = gs_bseg-hkont.
  bseg-bukrs = gs_bseg-bukrs.
  bkpf-bukrs = gs_bseg-bukrs.
  t042-zbukr = gs_bseg-bukrs.
  bseg-filkd = gs_bseg-filkd.
  bseg-belnr = gs_bseg-belnr.

  SELECT SINGLE lifnr name1 stras ort01    "20210324_BTO
    FROM lfa1
    INTO ( lfa1-lifnr,                           "20210324_BTO
           lfa1-name1,
           lfa1-stras,
           lfa1-ort01 )
    WHERE lifnr = gs_bseg-lifnr.

  CREATE OBJECT lr_container
    EXPORTING
      container_name = 'CC_POSITIONEN'
      repid          = sy-repid
      dynnr          = '0303'.

  SELECT * FROM bseg INTO TABLE lt_bseg WHERE belnr = gs_bseg-belnr AND bukrs = gs_bseg-bukrs AND gjahr = gs_bseg-gjahr.

  DATA(lr_alv) = NEW cl_gui_alv_grid( i_parent      = lr_container " in default container einbetten
                                     i_appl_events = abap_true ).

  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lr_salv
    CHANGING
      t_table      = lt_bseg.

  DATA(it_fcat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns      = lr_salv->get_columns( )
                                                                     r_aggregations = lr_salv->get_aggregations( ) ).

  DELETE it_fcat WHERE  fieldname NE 'BUKRS' AND
                        fieldname NE 'BELNR' AND
                        fieldname NE 'GJAHR' AND
                        fieldname NE 'GJAHR' AND
                        fieldname NE 'buzei' AND
                        fieldname NE 'SGTXT' AND
                        fieldname NE 'WRBTR' AND
                        fieldname NE 'BUZEI'.

  LOOP AT it_fcat INTO DATA(ls_fcat).
    CASE ls_fcat-fieldname.
      WHEN 'SGTXT'.
        ls_fcat-edit      = 'X'.
        ls_fcat-coltext   = 'Positionstext'.
        ls_fcat-outputlen = 50.
    ENDCASE.
    MODIFY it_fcat FROM ls_fcat.
  ENDLOOP.

  DATA(lv_layout) = VALUE lvc_s_layo( zebra      = abap_true             " ALV-Control: Alternierende Zeilenfarbe (Zebramuster)
                                      cwidth_opt = 'A'                   " ALV-Control: Spaltenbreite optimieren
                                      no_toolbar = 'X' ).
  lr_alv->set_table_for_first_display( EXPORTING
                                        is_layout          = lv_layout
                                      CHANGING
                                        it_fieldcatalog    = it_fcat
                                        it_outtab          = lt_bseg ).
*  lr_alv->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).
*  lr_alv->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).

  cl_gui_alv_grid=>set_focus( control = lr_alv ).
  cl_abap_list_layout=>suppress_toolbar( ).

ENDMODULE.
*** begin of #001 ***
*&---------------------------------------------------------------------*
*& Module MAHNSTUFE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE mahnstufe OUTPUT.

  DATA(lv_input) = abap_true.
  DATA(lv_input_manst) = abap_true.
  LOOP AT SCREEN INTO DATA(ls_screen).
    CASE ls_screen-name.
      WHEN 'BSEG-MANST'.                " Mahnstufe
        IF gs_bkpf-bukrs = '8000' OR bseg-maber = '90'.
          ls_screen-input = '0'.    " nicht eingabebereit
          lv_input = abap_false.
        ELSEIF bseg-manst <> '0' AND bseg-manst <> '1'.
          ls_screen-input = '0'.    " nicht eingabebereit
          lv_input_manst = abap_false.
        ELSE.
          ls_screen-input = '1'.    " eingabebereit
        ENDIF.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.
    " Übernahme der Änderung
    MODIFY SCREEN FROM ls_screen.
  ENDLOOP.

  IF lv_input = abap_false.
    MESSAGE i177(/thkr/fi_wf_bkpf).
  ENDIF.
  IF lv_input_manst = abap_false.
    MESSAGE i178(/thkr/fi_wf_bkpf).
  ENDIF.

ENDMODULE.
*** end of #001 ***
