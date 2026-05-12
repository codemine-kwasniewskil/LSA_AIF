*&---------------------------------------------------------------------*
*& Report /thkr/mig_rk_korrektur_mahnst2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report
*&---------------------------------------------------------------------*
*& Auftrag/Incident: 4000000864: INC08949819 - fehlende Mahnstufen #4
*& Datum           : 28.04.2026
*& Benutzer        : ZHM000000379
*& Beschreibung
*&
*&
*&
*&
*&---------------------------------------------------------------------*

REPORT /thkr/mig_rk_korrektur_mahnst4.

**********************************************************************
*Deklarationen
**********************************************************************
TABLES: /thkr/migd_rkfap, /thkr/migdao, /thkr/mig_ao_sap, bseg, /thkr/s_mig_korr_manst, bkpf.

TYPES: ty_data TYPE /thkr/s_mig_korr_manst.

TYPES: BEGIN OF ty_cdpos,
         changenr  TYPE cdchangenr,
         value_new TYPE cdfldvaln,
         value_old TYPE cdfldvalo,
       END OF ty_cdpos.


DATA: gt_accchg    TYPE table_type_accchg.

DATA: gt_mig_data TYPE TABLE OF ty_data.

DATA:
  gv_error      TYPE abap_bool,
  gv_bukrs      TYPE bukrs,
  gv_belnr      TYPE belnr_d,
  gv_gjahr      TYPE gjahr,
  gv_change     TYPE abap_bool,
  gv_xblnr      TYPE xblnr,
  gv_init_gjahr TYPE gjahr.


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
              so_satzi   FOR /thkr/mig_ao_sap-satz_id,
              so_xblnr   FOR /thkr/mig_ao_sap-xblnr,
              so_blart   FOR bkpf-blart,
              so_hf      FOR /thkr/mig_ao_sap-haup_nebenforderung,
              so_migob   FOR /thkr/migdao-migrationsobjekt,
              so_manst   FOR  bseg-manst.
  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS:
              so_manew   FOR bseg-manst.
  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS:
              so_posnr   FOR /thkr/migd_rkfap-pos_nr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_cmst AS CHECKBOX DEFAULT ' '.    "Mahnstufe  des Beleges immer überschreiben
    SELECTION-SCREEN COMMENT 3(70) TEXT-c02.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_cmsp AS CHECKBOX DEFAULT ' '.    "Mahnsperre des Beleges immer überschreiben
    SELECTION-SCREEN COMMENT 3(70) TEXT-c03.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_cmda AS CHECKBOX DEFAULT ' '.    "Mahndatum  des Beleges immer überschreiben
    SELECTION-SCREEN COMMENT 3(70) TEXT-c05.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_cres AS CHECKBOX DEFAULT ' '.    "Resubmis. des Beleges immer überschreiben
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
  SELECTION-SCREEN COMMENT /1(79) TEXT-sor.
  PARAMETERS: p_spos RADIOBUTTON GROUP g1.
  PARAMETERS: p_sjah RADIOBUTTON GROUP g1 DEFAULT 'X'.
  PARAMETERS: p_sshf RADIOBUTTON GROUP g1.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_force AS CHECKBOX DEFAULT space.
    SELECTION-SCREEN COMMENT 3(79) TEXT-for.
  SELECTION-SCREEN END OF LINE.
  SELECT-OPTIONS: so_minfd FOR /thkr/s_mig_korr_manst-cnt.
  SELECTION-SCREEN COMMENT /1(79) TEXT-min.
  PARAMETERS: p_fddel AS CHECKBOX DEFAULT 'X'.     "Wenn so_minfd nicht erreicht aus Liste löschen
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
  so_belnr[] = VALUE #( ( sign = 'E' option = 'EQ' low = '' ) ).
  so_minfd[] = VALUE #( ( sign = 'I' option = 'BT' low = '1' high = '2' ) ).
  so_posnr[] = VALUE #( ( sign = 'E' option = 'EQ' low = '0000000000' ) ).
  so_manst[] = VALUE #( ( sign = 'I' option = 'EQ' low = '0' ) ).
  so_manew[] = VALUE #( ( sign = 'E' option = 'EQ' low = '0' ) ).



*********************************************************************
START-OF-SELECTION.
*********************************************************************
  SELECT SINGLE budat FROM /thkr/mig_md INTO @DATA(gv_budat).
  gv_init_gjahr = gv_budat+0(4).

  TRY.
      DATA(gv_uuid) = cl_system_uuid=>create_uuid_c32_static( ).
    CATCH cx_root INTO DATA(lo_cx_uu).

  ENDTRY.

*--------------------------------------------------------------------*
*  Selektion aller Belege
*--------------------------------------------------------------------*

* Daten von den
  SELECT a~*
    INTO CORRESPONDING FIELDS OF TABLE @gt_mig_data
    FROM /thkr/mig_ao_sap AS a
    WHERE a~xblnr                 IN @so_xblnr
    AND   a~haup_nebenforderung   IN @so_hf
    AND   a~belnr                 IN @so_belnr
    AND   a~rk_pos_nr             IN @so_posnr
    AND   a~satz_id               IN @so_satzi
    AND   a~bukrs                 IN @so_bukrs.
  IF sy-subrc NE 0 AND gv_error NE abap_true.
    MESSAGE s001(00) WITH 'Keine Daten gefunden' DISPLAY LIKE 'E'.
*    EXIT.
  ENDIF.


  LOOP AT gt_mig_data ASSIGNING FIELD-SYMBOL(<fs_mig_data>).

    DATA(lv_tabix) = sy-tabix.

    CLEAR: gv_error, gv_gjahr, gv_bukrs, gv_belnr.

    gv_belnr = <fs_mig_data>-belnr.
    gv_gjahr = <fs_mig_data>-gjahr.
    gv_bukrs = <fs_mig_data>-bukrs.
    IF gv_gjahr IS INITIAL.
      gv_gjahr = gv_init_gjahr.
    ENDIF.

* /thkr/migdao
    SELECT SINGLE stundungsende, einzelplan, kennzeichenstundung, adfschluessel, migrationsobjekt
    INTO CORRESPONDING FIELDS OF @<fs_mig_data>
    FROM /thkr/migdao
    WHERE satz_id  = @<fs_mig_data>-satz_id
    AND  migrationsobjekt IN @so_migob.

    IF so_migob[] IS NOT INITIAL
    AND sy-subrc NE 0.
      <fs_mig_data>-type = 'E'.
      <fs_mig_data>-message = 'Migrationobjekt nicht gefunden'.
      gv_error = abap_true.
    ENDIF.


* BSEG
    SELECT SINGLE buzei, madat, mansp, manst
      FROM bseg
      INTO CORRESPONDING FIELDS OF @<fs_mig_data>
      WHERE bukrs = @gv_bukrs
      AND   gjahr = @gv_gjahr
      AND   belnr = @gv_belnr
      AND   buzei = 1.
    IF sy-subrc NE 0 AND gv_error NE abap_true.
      <fs_mig_data>-type = 'E'.
      <fs_mig_data>-message = 'Keine Daten in BSEG gefunden'.
      gv_error = abap_true.
    ENDIF.

    IF so_manst[] IS NOT INITIAL
    AND <fs_mig_data>-manst NOT IN so_manst.
      <fs_mig_data>-type = 'E'.
      <fs_mig_data>-message = 'Mahnstufe nicht gewünscht'.
      DELETE gt_mig_data INDEX lv_tabix.
      CONTINUE.
    ENDIF.

* RK Positionsdaten
    SELECT pos_nr, dat_letz_mahnung, dat_mahnsperre_bis, faellig_dtu, mahnstatus, haushaltsjahr, sollhf
      FROM /thkr/migd_rkfap
      INTO TABLE @DATA(gt_rkfap)
      WHERE satz_id              = @<fs_mig_data>-xblnr
      AND   pos_nr               = @<fs_mig_data>-rk_pos_nr
      AND   haushaltsjahr        = @<fs_mig_data>-rk_pos_nr_haushaltsjahr
      AND   haup_nebenforderung  = @<fs_mig_data>-haup_nebenforderung.

    IF p_spos EQ abap_true.
      SORT gt_rkfap BY pos_nr DESCENDING.
    ELSEIF p_sjah EQ abap_true.
      SORT gt_rkfap BY haushaltsjahr DESCENDING faellig_dtu DESCENDING.
    ELSE.
      SORT gt_rkfap BY sollhf DESCENDING.
    ENDIF.

    IF gt_rkfap[] IS INITIAL.
      <fs_mig_data>-type = 'E'.
      <fs_mig_data>-message = 'Keine Daten in /THKR/MIGD_RKFAP gefunden '.
      gv_error = abap_true.
      IF so_posnr[] IS NOT INITIAL.
        DELETE gt_mig_data INDEX lv_tabix.
        CONTINUE.
      ENDIF.
    ENDIF.

    <fs_mig_data>-cnt = lines( gt_rkfap ).

    IF <fs_mig_data>-cnt NOT IN so_minfd.
      <fs_mig_data>-type = 'E'.
      <fs_mig_data>-message = 'Mindestanzahl /THKR/MIGD_RKFAP nicht erreicht'.
      IF p_fddel EQ abap_true.
        DELETE gt_mig_data INDEX lv_tabix.
      ENDIF.
      CONTINUE.
    ENDIF.

*   Bei mehrfacher Anzahl, eine aussuchen
    IF <fs_mig_data>-cnt = 1.
      READ TABLE gt_rkfap ASSIGNING FIELD-SYMBOL(<fs_rkfap>) INDEX 1.
      MOVE-CORRESPONDING <fs_rkfap> TO <fs_mig_data>.
    ELSEIF <fs_mig_data>-cnt > 1.
      IF p_force NE abap_true.
        READ TABLE gt_rkfap ASSIGNING <fs_rkfap> INDEX 1.
        MOVE-CORRESPONDING <fs_rkfap> TO <fs_mig_data>.
      ELSE.
        LOOP AT gt_rkfap ASSIGNING <fs_rkfap> WHERE mahnstatus NE '0'.
          EXIT.
        ENDLOOP.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING <fs_rkfap> TO <fs_mig_data>.
        ELSE.
          READ TABLE gt_rkfap ASSIGNING <fs_rkfap> INDEX 1.
          MOVE-CORRESPONDING <fs_rkfap> TO <fs_mig_data>.
        ENDIF.
      ENDIF.
    ENDIF.


*   Resubmission von BKPF
    SELECT SINGLE resubmission, stblg, xreversed, aedat, blart
      FROM bkpf
      INTO CORRESPONDING FIELDS OF @<fs_mig_data>
      WHERE bukrs = @gv_bukrs
      AND   gjahr = @gv_gjahr
      AND   belnr = @gv_belnr
      AND   blart IN @so_blart.
    IF sy-subrc NE 0 AND gv_error NE abap_true.
      <fs_mig_data>-type = 'E'.
      <fs_mig_data>-message = 'Keine Daten in BKPF gefunden '.
      gv_error = abap_true.
      IF so_blart[] IS NOT INITIAL.
        DELETE gt_mig_data INDEX lv_tabix.
        CONTINUE.
      ENDIF.
    ENDIF.

* Stornierte ausschließen
    IF p_stor EQ abap_false
    AND <fs_mig_data>-xreversed EQ 'X'
    AND gv_error NE abap_true.
      <fs_mig_data>-type = 'E'.
      <fs_mig_data>-message = |Beleg ist storniert { <fs_mig_data>-stblg }|.
      gv_error = abap_true.
    ENDIF.

*   ADF_KEY
    SELECT SINGLE adf_key
      FROM /thkr/migd_rk
      INTO @<fs_mig_data>-adf_key
      WHERE satz_id = @<fs_mig_data>-xblnr.
    IF sy-subrc NE 0 AND gv_error NE abap_true.
      <fs_mig_data>-type = 'E'.
      <fs_mig_data>-message = 'Keine Daten in /THKR/MIGD_RK gefunden '.
      gv_error = abap_true.
    ENDIF.

*   wurde die Mahnstufe bereit einmal geändert
    IF <fs_mig_data>-aedat IS NOT INITIAL.
      PERFORM get_change_data USING   gv_bukrs gv_belnr gv_gjahr
                            CHANGING  <fs_mig_data>.

      IF <fs_mig_data>-changenr IS NOT INITIAL
      AND gv_error NE abap_true
      AND  p_aend  EQ abap_true.
        <fs_mig_data>-type = 'S'.
        <fs_mig_data>-message = 'Mahnstufe wurde bereits geändert'.
        gv_error = abap_true.
      ENDIF.

    ENDIF.

* neue Daten holen
*   das lohnt aber nur, wenn bis hier kein Lesefehler aufgetreten ist
    IF gv_error NE abap_true.

      PERFORM get_new_data CHANGING <fs_mig_data>
                                    gv_error.

      IF <fs_mig_data>-manst_new NOT IN so_manew
      AND gv_error NE abap_true.
        <fs_mig_data>-type = 'E'.
        <fs_mig_data>-message = 'Zielmahnstufe nicht erreicht'.
        gv_error = abap_true.
      ENDIF.

    ENDIF.

*  Änderungen vorhanden?
    IF  <fs_mig_data>-mansp = <fs_mig_data>-mansp_new
    AND <fs_mig_data>-manst = <fs_mig_data>-manst_new
    AND <fs_mig_data>-madat = <fs_mig_data>-madat_new
    AND <fs_mig_data>-resubmission = <fs_mig_data>-resub_new
    AND gv_error NE abap_true.
      <fs_mig_data>-type = 'S'.
      <fs_mig_data>-message = 'Keine Änderungen vorhanden'.
    ENDIF.

  ENDLOOP.




*--------------------------------------------------------------------*
* Beleg ändern
*--------------------------------------------------------------------*
  IF p_test NE abap_true.

    LOOP AT gt_mig_data ASSIGNING <fs_mig_data> WHERE type IS INITIAL.


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

  ENDIF.

**********************************************************************
*  Ergebnisausgabe
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
