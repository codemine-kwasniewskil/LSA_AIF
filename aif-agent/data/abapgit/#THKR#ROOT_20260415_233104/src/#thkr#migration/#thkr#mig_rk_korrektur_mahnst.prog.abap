*&---------------------------------------------------------------------*
*& Report /thkr/mig_rk_korrektur_mahnst
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report
*&---------------------------------------------------------------------*
*& Auftrag/Incident: 4000000839/INC08949819 - fehlende Mahnstufen
*& Datum           : 23.03.2026
*& Benutzer        : ZHM000000379
*& Beschreibung
*&
*&
*&  ADF_KEY, RESUBMISSION
*&
*&---------------------------------------------------------------------*

REPORT /thkr/mig_rk_korrektur_mahnst.

**********************************************************************
*Deklarationen
**********************************************************************
TABLES: /thkr/migd_rkfap, /thkr/migdao, /thkr/mig_ao_sap.

TYPES: ty_data TYPE /thkr/s_mig_korr_manst.

TYPES: BEGIN OF ty_cdpos,
         changenr  TYPE cdchangenr,
         value_new TYPE cdfldvaln,
         value_old TYPE cdfldvalo,
       END OF ty_cdpos.


DATA: gt_accchg    TYPE table_type_accchg.

DATA: gt_mig_data TYPE TABLE OF ty_data,
      gs_mig_data TYPE ty_data.

DATA:
  gv_error  TYPE abap_bool,
  gv_bukrs  TYPE bukrs,
  gv_belnr  TYPE belnr_d,
  gv_gjahr  TYPE gjahr,
  gv_change TYPE abap_bool,
  gv_xblnr  TYPE xblnr.

DATA: gs_xbkpf TYPE bkpf,
      gs_ybkpf TYPE bkpf.
DATA: gt_xbseg TYPE TABLE OF fbseg,
      gt_ybseg TYPE TABLE OF fbseg.


INCLUDE /thkr/mig_rk_korrektur_ma_f01.


*********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS:
              so_bukrs   FOR /thkr/mig_ao_sap-bukrs,
              so_belnr   FOR /thkr/mig_ao_sap-belnr,
              so_xblnr   FOR /thkr/mig_ao_sap-xblnr.
  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS:
              so_posnr   FOR /thkr/migd_rkfap-pos_nr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_cmst AS CHECKBOX DEFAULT 'X'.    "Mahnstufe  ändern wenn gefüllt
    SELECTION-SCREEN COMMENT 3(70) TEXT-c02.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_cmsp AS CHECKBOX DEFAULT 'X'.    "Mahnsperre ändern wenn gefüllt
    SELECTION-SCREEN COMMENT 3(70) TEXT-c03.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_cmda AS CHECKBOX DEFAULT 'X'.    "Mahndatum  ändern wenn gefüllt
    SELECTION-SCREEN COMMENT 3(70) TEXT-c05.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_cres AS CHECKBOX DEFAULT 'X'.    "Resubmis.  ändern wenn gefüllt
    SELECTION-SCREEN COMMENT 3(70) TEXT-c04.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_nmst AS CHECKBOX DEFAULT 'X'.    "Mahnstufe  nie ändern
    SELECTION-SCREEN COMMENT 3(70) TEXT-cns.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_nmsp AS CHECKBOX DEFAULT 'X'.    "Mahnsperre nie ändern
    SELECTION-SCREEN COMMENT 3(70) TEXT-cnp.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_nmda AS CHECKBOX DEFAULT 'X'.    "Mahndatum  nie ändern
    SELECTION-SCREEN COMMENT 3(70) TEXT-cnd.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_nres AS CHECKBOX DEFAULT 'X'.    "Resubmis.  nie ändern
    SELECTION-SCREEN COMMENT 3(70) TEXT-cnr.
  SELECTION-SCREEN END OF LINE.


  SELECTION-SCREEN SKIP 1.
  PARAMETERS: p_stor AS CHECKBOX DEFAULT ' '.      "Stornierte Belege ändern
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_aend AS CHECKBOX DEFAULT 'X'.    "geänderte Belege nicht ändern
    SELECTION-SCREEN COMMENT 3(70) TEXT-cae.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN SKIP 1.
  PARAMETERS: p_test TYPE flag DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b3.




*********************************************************************
INITIALIZATION.
*********************************************************************
  so_posnr[] = VALUE #( ( sign = 'I' option = 'EQ' low = '0000000000' ) ).

*********************************************************************
START-OF-SELECTION.
*********************************************************************
*  SELECT SINGLE budat FROM /thkr/mig_md INTO @DATA(gv_budat).
*  WRITE gv_budat TO gv_budat_text.
*  gv_gjahr = gv_budat+0(4).

  TRY.
      DATA(gv_uuid) = cl_system_uuid=>create_uuid_c32_static( ).
    CATCH cx_root INTO DATA(lo_cx_uu).

  ENDTRY.


*--------------------------------------------------------------------*
*  Selektion aller Belege
*--------------------------------------------------------------------*

* 1. Alle RK-Position ohne POS-NR
  SELECT satz_id AS xblnr, pos_nr, dat_letz_mahnung, dat_mahnsperre_bis, faellig_dtu, mahnstatus
    FROM /thkr/migd_rkfap
    WHERE pos_nr IN @so_posnr
    AND   satz_id IN @so_xblnr
    INTO TABLE @DATA(gt_rkfap).

  IF gt_rkfap[] IS INITIAL.
    MESSAGE s001(00) WITH 'Keine Daten in /THKR/MIGD_RKFAP gefunden' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


* 2. Migration AO prüfen und weiter daten nachlesen
  LOOP AT gt_rkfap ASSIGNING FIELD-SYMBOL(<fs_rkfap>).

    CLEAR: gs_mig_data, gv_error, gv_gjahr, gv_bukrs, gv_belnr.

    MOVE-CORRESPONDING <fs_rkfap> TO  gs_mig_data.

*   MIG-AO
    SELECT SINGLE *
      FROM /thkr/mig_ao_sap
      INTO CORRESPONDING FIELDS OF @gs_mig_data
      WHERE xblnr = @<fs_rkfap>-xblnr
      AND   haup_nebenforderung   =  'H'
      AND   belnr                 <> ''
      AND   sste_ueberz_forderung =  ''.
    IF sy-subrc NE 0 AND gv_error NE abap_true.
      gs_mig_data-type = 'E'.
      gs_mig_data-message = 'Keine Daten in /THKR/MIG_AO_SAP gefunden '.
      gv_error = abap_true.
    ENDIF.

    gv_belnr = gs_mig_data-belnr.
    gv_gjahr = gs_mig_data-gjahr.
    gv_bukrs = gs_mig_data-bukrs.

*   akktuelle Mahndaten aus BSEG
    IF gv_error NE abap_true.
      SELECT SINGLE buzei, madat, mansp, manst
        FROM bseg
        INTO CORRESPONDING FIELDS OF @gs_mig_data
        WHERE bukrs = @gv_bukrs
        AND   gjahr = @gv_gjahr
        AND   belnr = @gv_belnr
        AND   buzei = 1.
      IF sy-subrc NE 0 AND gv_error NE abap_true.
        gs_mig_data-type = 'E'.
        gs_mig_data-message = 'Keine Daten in BSEG gefunden '.
        gv_error = abap_true.
      ENDIF.
    ENDIF.

*   Resubmission von BKPF
    IF gv_error NE abap_true.
      SELECT SINGLE resubmission, stblg, xreversed, aedat
        FROM bkpf
        INTO CORRESPONDING FIELDS OF @gs_mig_data
        WHERE bukrs = @gv_bukrs
        AND   gjahr = @gv_gjahr
        AND   belnr = @gv_belnr.
      IF sy-subrc NE 0 AND gv_error NE abap_true.
        gs_mig_data-type = 'E'.
        gs_mig_data-message = 'Keine Daten in BKPF gefunden '.
        gv_error = abap_true.
      ENDIF.
    ENDIF.

    IF p_stor EQ abap_false
    AND gs_mig_data-xreversed EQ 'X'
    AND gv_error NE abap_true.
      gs_mig_data-type = 'E'.
      gs_mig_data-message = |Beleg ist storniert { gs_mig_data-stblg }|.
      gv_error = abap_true.
    ENDIF.


    IF gs_mig_data-aedat IS NOT INITIAL.
      PERFORM get_change_data USING   gv_bukrs gv_belnr gv_gjahr
                            CHANGING  gs_mig_data.
    ENDIF.

*   ADF_KEY
    IF gv_error NE abap_true.
      SELECT SINGLE adf_key
        FROM /thkr/migd_rk
        INTO @gs_mig_data-adf_key
        WHERE satz_id = @<fs_rkfap>-xblnr.
      IF sy-subrc NE 0 AND gv_error NE abap_true.
        gs_mig_data-type = 'E'.
        gs_mig_data-message = 'Keine Daten in /THKR/MIGD_RK gefunden '.
        gv_error = abap_true.
      ENDIF.
    ENDIF.

*   Stundungsende, Einzelplan, Kennz.Stundung, ADFSCHLUESSEL
    IF gv_error NE abap_true.
      SELECT SINGLE stundungsende, einzelplan, kennzeichenstundung, adfschluessel
        FROM /thkr/migdao
        INTO CORRESPONDING FIELDS OF @gs_mig_data
        WHERE satz_id = @gs_mig_data-satz_id.
      IF sy-subrc NE 0 AND gv_error NE abap_true.
        gs_mig_data-type = 'E'.
        gs_mig_data-message = 'Keine Daten in /THKR/MIGDAO gefunden '.
        gv_error = abap_true.
      ENDIF.
    ENDIF.


*    neue Daten holen
    IF gv_error NE abap_true.
      PERFORM get_new_data CHANGING gs_mig_data
                                    gv_error.

    ENDIF.

*  Änderungen vorhanden?
    IF  gs_mig_data-mansp = gs_mig_data-mansp_new
    AND gs_mig_data-manst = gs_mig_data-manst_new
    AND gs_mig_data-madat = gs_mig_data-madat_new
    AND gs_mig_data-resubmission = gs_mig_data-resub_new
    AND gv_error NE abap_true.

      gs_mig_data-type = 'S'.
      gs_mig_data-message = 'Keine Änderungen vorhanden'.

    ELSEIF p_aend EQ abap_true
    AND gs_mig_data-aedat IS NOT INITIAL
    AND gv_error NE abap_true.

      gs_mig_data-type = 'S'.
      gs_mig_data-message = 'Beleg hat Änderungsdatum => nicht ändern'.

    ENDIF.

* für die Änderung merken
    APPEND gs_mig_data TO gt_mig_data.

  ENDLOOP.


  FREE gt_rkfap.

  IF gt_mig_data[] IS INITIAL.
    MESSAGE s001(00) WITH 'Keine Daten gefunden' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.




*--------------------------------------------------------------------*
* Beleg ändern
*--------------------------------------------------------------------*
  LOOP AT gt_mig_data ASSIGNING FIELD-SYMBOL(<fs_mig_data>) WHERE type IS INITIAL.


    FREE gt_accchg. "BSEG
    CLEAR: gv_error, gv_gjahr, gv_belnr, gv_bukrs.
    CLEAR: gs_xbkpf, gs_ybkpf.


*  Belegkopf
    gv_belnr = <fs_mig_data>-belnr.
    gv_gjahr = <fs_mig_data>-gjahr.
    gv_bukrs = <fs_mig_data>-bukrs.

*   - Wiedervorlage
    PERFORM check_change USING <fs_mig_data>-resubmission
                               <fs_mig_data>-resub_new
                               p_cres
                               p_nres
                     CHANGING gv_change.
    IF gv_change EQ abap_true.

      SELECT SINGLE *
      FROM bkpf
      INTO @gs_xbkpf
      WHERE bukrs = @gv_bukrs
      AND   gjahr = @gv_gjahr
      AND   belnr = @gv_belnr.

      MOVE-CORRESPONDING gs_xbkpf TO gs_ybkpf.        "alte Daten
      gs_xbkpf-resubmission = <fs_mig_data>-resub_new."neue Daten

      UPDATE bkpf SET resubmission = @<fs_mig_data>-resub_new
        WHERE bukrs = @gv_bukrs
        AND   gjahr = @gv_gjahr
        AND   belnr = @gv_belnr.

      IF sy-subrc EQ 0.

        CALL FUNCTION 'UPDATE_BKPF_LAST_CHANGE_TSTAMP'
          EXPORTING
            it_bkpf_key = VALUE fagl_t_belnr_key( ( bukrs = gv_bukrs belnr = gv_belnr gjahr = gv_gjahr ) ).

        CALL FUNCTION 'OPEN_FI_PERFORM_00001110_E'
          EXPORTING
            i_xbkpf = gs_xbkpf "neu Daten
            i_ybkpf = gs_ybkpf "alte Daten
          TABLES
            xbseg   = gt_xbseg
            ybseg   = gt_ybseg.

      ENDIF.

    ENDIF.


*   Belegposition
*   - Mahndatum
    PERFORM check_change USING    <fs_mig_data>-madat
                                  <fs_mig_data>-madat_new
                                  p_cmda "überschreiben
                                  p_nmda "nie ändern
                         CHANGING gv_change.
    IF gv_change EQ abap_true.
      APPEND VALUE #(
                     fdname = 'MADAT'
                     oldval = <fs_mig_data>-madat
                     newval = <fs_mig_data>-madat_new
                    ) TO gt_accchg.
    ENDIF.

*   - Mahnsperre
    PERFORM check_change USING    <fs_mig_data>-mansp
                                  <fs_mig_data>-mansp_new
                                  p_cmsp
                                  p_nmsp
                         CHANGING gv_change.
    IF gv_change EQ abap_true.
      APPEND VALUE #(
                     fdname = 'MANSP'
                     oldval = <fs_mig_data>-mansp
                     newval = <fs_mig_data>-mansp_new
                    ) TO gt_accchg.
    ENDIF.

*   - Mahnstufe
    PERFORM check_change USING    <fs_mig_data>-manst
                                  <fs_mig_data>-manst_new
                                  p_cmst
                                  p_nmst
                         CHANGING gv_change.
    IF gv_change EQ abap_true.
      APPEND VALUE #(
                     fdname = 'MANST'
                     oldval = <fs_mig_data>-manst
                     newval = <fs_mig_data>-manst_new
                    ) TO gt_accchg.
    ENDIF.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        x_lock               = 'X'
        i_bukrs              = <fs_mig_data>-bukrs
        i_belnr              = <fs_mig_data>-belnr
        i_gjahr              = <fs_mig_data>-gjahr
        i_buzei              = <fs_mig_data>-buzei
      TABLES
        t_accchg             = gt_accchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.
    IF sy-subrc <> 0.
      gv_error = abap_true.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_msg).
      <fs_mig_data>-type = sy-msgty.
      <fs_mig_data>-message = lv_msg.
    ELSE.
      <fs_mig_data>-type    = 'S'.
      <fs_mig_data>-message =  |Belegdaten erfolgreich geändert|.
    ENDIF.


    IF  p_test = abap_true OR gv_error EQ abap_true.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.

    IF p_test NE abap_true.
      PERFORM save_logging USING gv_uuid
                                 <fs_mig_data>.
    ENDIF.

  ENDLOOP.


**********************************************************************
*  Ausgabe
**********************************************************************
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                              CHANGING  t_table      = gt_mig_data ).

      lo_salv->get_columns( )->set_optimize( abap_true ).


      DATA(lo_layo) = lo_salv->get_layout( ).
      lo_layo->set_save_restriction( if_salv_c_layout=>restrict_none ).
      DATA(ls_key) = lo_layo->get_key( ).
      ls_key-report = sy-repid.
      ls_key-handle = 'TAB'.
      lo_layo->set_key( ls_key ).

      lo_salv->get_functions( )->set_all( abap_true ).

      PERFORM set_columns USING lo_salv.


      DATA: ls_layo TYPE lvc_s_layo.

      lo_salv->display( ).

    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.
