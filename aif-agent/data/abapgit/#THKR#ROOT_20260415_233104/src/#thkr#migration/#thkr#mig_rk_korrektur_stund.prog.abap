*&---------------------------------------------------------------------*
*& Report ZTEST_GB003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_rk_korrektur_stund.

**********************************************************************
* Deklarationen
**********************************************************************
TABLES: /thkr/migd_rk_si, /thkr/migd_rkfap, bkpf, /thkr/mig_ao_sap, /thkr/migdao.


TYPES: BEGIN OF ty_data,
         belnr                   TYPE  /thkr/mig_ao_sap-belnr,
         bukrs                   TYPE  /thkr/mig_ao_sap-bukrs,
         gjahr                   TYPE  /thkr/mig_ao_sap-gjahr,
         xblnr                   TYPE  /thkr/mig_ao_sap-xblnr,
         rk_pos_nr               TYPE  /thkr/mig_ao_sap-rk_pos_nr,
         rk_pos_nr_haushaltsjahr TYPE  /thkr/mig_ao_sap-rk_pos_nr_haushaltsjahr,
         satz_id                 TYPE  /thkr/de_satz_id,
         reference               TYPE  /thkr/migd_rkfap-satz_id,
         sollnf                  TYPE  /thkr/migd_rkfap-sollnf,
         haup_nebenforderung     TYPE  /thkr/mig_ao_sap-haup_nebenforderung,
         posnr_dkw               TYPE  /thkr/migd_rk_si-posnr_dkw,
         pos_nr                  TYPE  /thkr/migd_rk_si-pos_nr,
       END OF ty_data.


TYPES: BEGIN OF ty_end_data,
         belnr                   TYPE  /thkr/mig_ao_sap-belnr,
         bukrs                   TYPE  /thkr/mig_ao_sap-bukrs,
         gjahr                   TYPE  /thkr/mig_ao_sap-gjahr,
         xblnr                   TYPE  /thkr/mig_ao_sap-xblnr,
         dmbtr                   TYPE  bseg-dmbtr,
         satz_id                 TYPE  /thkr/de_satz_id,
         sollrkfap               TYPE  dmbtr,
         sollmainsi              TYPE  dmbtr,
         solldkwsi               TYPE  dmbtr,
         einzelplan              TYPE  /thkr/migd_rkfap-einzelplan,
         count                   TYPE  int2,
         has_bo                  TYPE  char1,
         budat                   TYPE  bkpf-budat,
         migrationsobjekt        TYPE /thkr/migdao-migrationsobjekt,
         rk_pos_nr               TYPE  /thkr/mig_ao_sap-rk_pos_nr,
         rk_pos_nr_haushaltsjahr TYPE  /thkr/mig_ao_sap-rk_pos_nr_haushaltsjahr,
         haup_nebenforderung     TYPE  /thkr/mig_ao_sap-haup_nebenforderung,
         posnr_dkw               TYPE  /thkr/migd_rk_si-posnr_dkw,
         is_different            TYPE  xflag,
       END OF ty_end_data.

TYPES: BEGIN OF ty_erhebenf,
         satz_id       TYPE /thkr/migd_rk_si-satz_id,
         rksi_position TYPE /thkr/migd_rk_si-rksi_position,
         rksi_haujahr  TYPE /thkr/migd_rk_si-rksi_haujahr,
         soll          TYPE /thkr/migd_rk_si-soll,
         posnr_dkw     TYPE /thkr/migd_rk_si-posnr_dkw,
       END OF ty_erhebenf.

TYPES: BEGIN OF ty_posnr_dkw_count,
         posnr_dkw TYPE /thkr/migd_rk_si-posnr_dkw,
         count     TYPE i,
       END OF ty_posnr_dkw_count,
       tty_posnr_dkw_count TYPE TABLE OF ty_posnr_dkw_count.

DATA: gs_data   TYPE ty_data,
      gt_data   TYPE TABLE OF ty_data,
      gt_poscnt TYPE tty_posnr_dkw_count,
      gt_erhebe TYPE TABLE OF ty_erhebenf,
      gv_min    TYPE int4,
      gv_error  TYPE abap_bool,
      gv_soll   TYPE dmbtr,
      gv_dkw_10 TYPE numc10.

**********************************************************************
* Selektionsbild
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
  SELECT-OPTIONS:
              so_bukrs   FOR /thkr/mig_ao_sap-bukrs,
              so_belnr   FOR /thkr/mig_ao_sap-belnr,
              so_xblnr   FOR /thkr/mig_ao_sap-xblnr,
              so_satz   FOR /thkr/mig_ao_sap-satz_id,
              so_hf      FOR /thkr/mig_ao_sap-haup_nebenforderung.
SELECTION-SCREEN END OF BLOCK b2.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: so_hn    FOR /thkr/migd_rk_si-haup_neben_forderung,
                  so_SOLL  FOR /thkr/migd_rk_si-soll,
                  so_quell FOR /thkr/migd_rk_si-quelle,
                  so_epl   FOR /thkr/migd_rkfap-einzelplan,
                  so_bdat  FOR bkpf-budat.
  PARAMETERS:     so_min   LIKE gv_min DEFAULT '2'.
SELECTION-SCREEN END OF BLOCK b1.


INCLUDE /thkr/mig_rk_korrektur_stun_f1.

**********************************************************************
INITIALIZATION.
**********************************************************************
  so_hf[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'N' ) ).

  so_hn[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'N' ) ).
  so_soll[] = VALUE #( ( sign = 'I' option = 'CP' low = '-*' ) ).
  so_quell[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'KETT-STU' ) ).
  so_bdat[] = VALUE #( ( sign = 'I' option = 'GT' low = '20251231' ) ).


*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*
* Datum der Belegerzeugung
  SELECT SINGLE budat FROM /thkr/mig_md INTO @DATA(gv_budat).

* Ausgangsdaten lesen
  PERFORM get_mid_ao_data.

* Alle Soll/Ist mit Quelle ErgebeNF lesen
  PERFORM get_erhebenf.



* Zu den Datzensätze mit ErgebeNF werden die passenden Belege ermittelt
  LOOP AT gt_erhebe ASSIGNING FIELD-SYMBOL(<fs_ergebe>).

    LOOP AT  gt_data ASSIGNING FIELD-SYMBOL(<fs_data>) WHERE reference = <fs_ergebe>-satz_id
                                                       AND   posnr_dkw = <fs_ergebe>-rksi_position
                                                       AND   rk_pos_nr_haushaltsjahr  = <fs_ergebe>-rksi_haujahr.



    ENDLOOP.

  ENDLOOP.













** Zähle die Treffer pro Kassenzeichen, Position
*  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
*
*    SELECT SINGLE sollhf, sollnf
*      FROM /thkr/migd_rkfap
*      INTO (@DATA(gv_sollhf), @DATA(gv_sollnf))
*      WHERE satz_id       =  @<fs_data>-xblnr
*      AND   pos_nr        =  @<fs_data>-rk_pos_nr
*      AND   haushaltsjahr =  @<fs_data>-rk_pos_nr_haushaltsjahr.
*
*    IF <fs_data>-haup_nebenforderung = 'H'.
*      REPLACE '-' IN gv_sollhf WITH ''.
*      TRY.
*          MOVE gv_sollhf TO <fs_data>-sollrkfap.
*        CATCH cx_root.
*      ENDTRY.
*    ELSE.
*      REPLACE '-' IN gv_sollnf WITH ''.
*      TRY.
*          MOVE gv_sollnf TO <fs_data>-sollrkfap.
*        CATCH cx_root.
*      ENDTRY.
*    ENDIF.
*
*
** Hauptzeile ermitteln
*    SELECT SINGLE satz_id, rksi_position, rksi_haujahr, soll, posnr_dkw, haup_neben_forderung
*    FROM /thkr/migd_rk_si
*    INTO @DATA(gs_tmp_main)
*    WHERE haup_neben_forderung IN @so_hn
*    AND   satz_id       =  @<fs_data>-xblnr
*    AND   rksi_position =  @<fs_data>-rk_pos_nr
*    AND   rksi_haujahr  =  @<fs_data>-rk_pos_nr_haushaltsjahr.
*
*    <fs_data>-posnr_dkw = gs_tmp_main-posnr_dkw.
*
*    gv_dkw_10 = CONV numc10( gs_tmp_main-posnr_dkw ).
*
*    REPLACE '-' IN gs_tmp_main-soll WITH ''.
*    TRY.
*        MOVE gs_tmp_main-soll TO <fs_data>-sollmainsi.
*      CATCH cx_root.
*    ENDTRY.
*
*
**   Daten aus den DKW-Positionen
*    SELECT satz_id, rksi_position, rksi_haujahr, soll, posnr_dkw, haup_neben_forderung
*    FROM /thkr/migd_rk_si
*    INTO TABLE @DATA(gt_tmp_si)
*    WHERE haup_neben_forderung IN @so_hn
*    AND   satz_id       =  @gs_tmp_main-satz_id
*    AND   ( rksi_position =  @gs_tmp_main-posnr_dkw OR rksi_position =  @gv_dkw_10 )
*    AND   rksi_haujahr  =  @gs_tmp_main-rksi_haujahr
*    AND   soll          IN @so_SOLL
*    AND   quelle        IN @so_quell.
*
*    <fs_data>-count = lines( gt_tmp_si ).
*
*    CLEAR gv_soll.
*    LOOP AT gt_tmp_si ASSIGNING FIELD-SYMBOL(<fs_tmp_si>).
**      REPLACE '-' IN <fs_tmp_si>-soll WITH ''.
*      MOVE <fs_tmp_si>-soll TO gv_soll.
*      TRY.
*          ADD gv_soll TO <fs_data>-solldkwsi.
*        CATCH cx_root.
*      ENDTRY.
*    ENDLOOP.
*
*
*    FREE: gt_tmp_si.
*    CLEAR: gs_tmp_main.
*
**   Buchungen auf dem beleh?
*    SELECT SINGLE budat
*      FROM bkpf
*      INTO @<fs_data>-budat
*      WHERE belnr = @<fs_data>-belnr
*      AND   bukrs = @<fs_data>-bukrs
*      AND   gjahr = @<fs_data>-gjahr
*      AND budat IN @so_bdat.
*    IF sy-subrc EQ 0.
*      <fs_data>-has_bo = abap_true.
*    ENDIF.
*
** Betrag am Beleg
*    SELECT SINGLE dmbtr
*      FROM bseg
*      INTO @<fs_data>-dmbtr
*      WHERE belnr = @<fs_data>-belnr
*      AND   bukrs = @<fs_data>-bukrs
*      AND   gjahr = @<fs_data>-gjahr
*      AND   buzei = '1'.
*
*    IF <fs_data>-dmbtr NE ( <fs_data>-solldkwsi * -1 ).
*      <fs_data>-is_different = abap_true.
*    ENDIF.
*
*  ENDLOOP.

*  DELETE gt_data WHERE count < so_min.


*--------------------------------------------------------------------*
* Ergebnis ausgeben
*--------------------------------------------------------------------*
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                              CHANGING  t_table      = gt_data ).



      DATA(lo_layo) = lo_salv->get_layout( ).
      lo_layo->set_save_restriction( if_salv_c_layout=>restrict_none ).
      DATA(ls_key) = lo_layo->get_key( ).
      ls_key-report = sy-repid.
      ls_key-handle = 'TAB'.
      lo_layo->set_key( ls_key ).

      lo_salv->get_columns( )->set_optimize( abap_true ).
      lo_salv->get_functions( )->set_all( abap_true ).

      lo_salv->get_columns( )->get_column( 'SOLLRKFAP' )->set_short_text( 'SOLLRKFAP' ).
      lo_salv->get_columns( )->get_column( 'SOLLRKFAP' )->set_long_text( 'SOLLRKFAP' ).
      lo_salv->get_columns( )->get_column( 'SOLLRKFAP' )->set_medium_text( 'SOLLRKFAP' ).

      lo_salv->get_columns( )->get_column( 'SOLLMAINSI' )->set_short_text( 'SOLLRKSI' ).
      lo_salv->get_columns( )->get_column( 'SOLLMAINSI' )->set_long_text( 'SOLLRKSI' ).
      lo_salv->get_columns( )->get_column( 'SOLLMAINSI' )->set_medium_text( 'SOLLRKSI' ).

      lo_salv->get_columns( )->get_column( 'SOLLDKWSI' )->set_short_text( 'SOLLDKW' ).
      lo_salv->get_columns( )->get_column( 'SOLLDKWSI' )->set_long_text( 'SOLLDKW' ).
      lo_salv->get_columns( )->get_column( 'SOLLDKWSI' )->set_medium_text( 'SOLLDKW' ).

      lo_salv->get_columns( )->get_column( 'COUNT' )->set_short_text( 'Anzahl' ).
      lo_salv->get_columns( )->get_column( 'COUNT' )->set_long_text( 'Anzahl' ).
      lo_salv->get_columns( )->get_column( 'COUNT' )->set_medium_text( 'Anzahl' ).

      lo_salv->get_columns( )->get_column( 'HAS_BO' )->set_short_text( 'Neue Buch.' ).
      lo_salv->get_columns( )->get_column( 'HAS_BO' )->set_long_text( 'Neue Buchungen' ).
      lo_salv->get_columns( )->get_column( 'HAS_BO' )->set_medium_text( 'Neue Buchungen' ).

      lo_salv->get_columns( )->get_column( 'EINZELPLAN' )->set_short_text( 'Einzelpl.' ).
      lo_salv->get_columns( )->get_column( 'EINZELPLAN' )->set_long_text( 'Einzelplan' ).
      lo_salv->get_columns( )->get_column( 'EINZELPLAN' )->set_medium_text( 'Einzelplan' ).

      lo_salv->get_columns( )->get_column( 'RK_POS_NR_HAUSHALTSJAHR' )->set_short_text( 'RK-HJahr' ).
      lo_salv->get_columns( )->get_column( 'RK_POS_NR_HAUSHALTSJAHR' )->set_long_text( 'RK-HJahr' ).
      lo_salv->get_columns( )->get_column( 'RK_POS_NR_HAUSHALTSJAHR' )->set_medium_text( 'RK-HJahr' ).

      lo_salv->get_columns( )->get_column( 'POSNR_DKW' )->set_short_text( 'RKPosNrDKW' ).
      lo_salv->get_columns( )->get_column( 'POSNR_DKW' )->set_long_text( 'RKPosNrDKW' ).
      lo_salv->get_columns( )->get_column( 'POSNR_DKW' )->set_medium_text( 'RKPosNrDKW' ).

      lo_salv->get_columns( )->get_column( 'IS_DIFFERENT' )->set_short_text( 'Delta' ).
      lo_salv->get_columns( )->get_column( 'IS_DIFFERENT' )->set_long_text( 'Delta' ).
      lo_salv->get_columns( )->get_column( 'IS_DIFFERENT' )->set_medium_text( 'Delta' ).

*      lo_salv->get_columns( )->get_column( '' )->set_short_text( '' ).
*      lo_salv->get_columns( )->get_column( '' )->set_long_text( '' ).
*      lo_salv->get_columns( )->get_column( '' )->set_medium_text( '' ).


      lo_salv->display( ).


    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.
