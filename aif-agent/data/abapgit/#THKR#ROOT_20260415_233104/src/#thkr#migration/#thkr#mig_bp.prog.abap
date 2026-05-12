*&---------------------------------------------------------------------*
*& Report /THKR/MIG_BP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_bp.

TYPES: BEGIN OF ty_statistic,
         epl                      TYPE /thkr/mig_einzelplan,
         initial                  TYPE int4,
         rk_fehlt                 TYPE int4,
         rk_pos_nicht_gefunden    TYPE int4,
         rk_geprueft              TYPE int4,
         fehler_gp                TYPE int4,
         gp_angelegt              TYPE int4,
         nacharbeit_gp_fehlerhaft TYPE int4,
         gp_freigegeben           TYPE int4,
         fehler_ao_beleg          TYPE int4,
         ao_beleg_erzeugt         TYPE int4,
         kto_datei_erstellt       TYPE int4,
         fehler_folgebeleg        TYPE int4,
         folgebeleg_erstellt      TYPE int4,
         k_rate_n_stichtag        TYPE int4,
         absetzung_ao_erstellt    TYPE int4,
         nuller_kassenzeichen     TYPE int4,
         sste_ueberz_forderung    TYPE int4,
         payac01_saknr_hit_first  TYPE int4,
         kz_ignore_rk_error       TYPE int4,
         betrag_0                 TYPE int4,
       END OF ty_statistic.


DATA:
  gs_statistic TYPE ty_statistic,
  gt_statistic TYPE TABLE OF ty_statistic,
  gv_epl       TYPE /thkr/mig_einzelplan,
  gv_mo        TYPE /thkr/mig_obj_ao,
  gv_stat      TYPE /thkr/mig_ao_sap_status,
  gv_partner   TYPE bu_partner.

SELECT-OPTIONS:
  so_ep    FOR gv_epl,
  so_mo    FOR gv_mo,
  so_stat  FOR gv_stat,
  so_bp    FOR gv_partner.

PARAMETERS:
  p_bpext TYPE flag RADIOBUTTON GROUP rbg1,
  p_stat  TYPE flag RADIOBUTTON GROUP rbg1 DEFAULT 'X'.

START-OF-SELECTION.


  CASE abap_true.
    WHEN p_bpext.
      UPDATE but000 SET bpext = '' WHERE partner IN so_bp AND bpext = ' 2025'.
      COMMIT WORK.
      WRITE:/ sy-dbcnt , ' Partner geändert.'.

    WHEN p_stat.
      SELECT * FROM /thkr/migdao AS o INNER JOIN /thkr/mig_ao_sap AS p ON o~satz_id = p~satz_id
        INTO TABLE @DATA(lt_mig_data)
        WHERE p~epl IN @so_ep AND o~migrationsobjekt IN @so_mo AND p~status IN @so_stat.
      LOOP AT lt_mig_data ASSIGNING FIELD-SYMBOL(<fs_data>).
        CLEAR: gs_statistic.
        gs_statistic-epl = <fs_data>-p-epl.

        CASE <fs_data>-p-status.
          WHEN ''.
            ADD 1 TO gs_statistic-initial.
          WHEN '04'.
            ADD 1 TO  gs_statistic-rk_fehlt.
          WHEN '05'.
            ADD 1 TO  gs_statistic-rk_pos_nicht_gefunden.
          WHEN '06'.
            ADD 1 TO  gs_statistic-rk_geprueft.
          WHEN '09'.
            ADD 1 TO  gs_statistic-fehler_gp.
          WHEN '10'.
            ADD 1 TO  gs_statistic-gp_angelegt.
          WHEN '19'.
            ADD 1 TO  gs_statistic-nacharbeit_gp_fehlerhaft.
          WHEN '20'.
            ADD 1 TO  gs_statistic-gp_freigegeben.
          WHEN '39'.
            ADD 1 TO  gs_statistic-fehler_ao_beleg.
          WHEN '40'.
            ADD 1 TO  gs_statistic-ao_beleg_erzeugt.
          WHEN '43'.
            ADD 1 TO  gs_statistic-kto_datei_erstellt.
          WHEN '49'.
            ADD 1 TO  gs_statistic-fehler_folgebeleg.
          WHEN '50'.
            ADD 1 TO  gs_statistic-folgebeleg_erstellt.
          WHEN '51'.
            ADD 1 TO  gs_statistic-k_rate_n_stichtag.
          WHEN '52'.
            ADD 1 TO  gs_statistic-absetzung_ao_erstellt.
          WHEN OTHERS.
        ENDCASE.

        IF <fs_data>-p-nuller_kassenzeichen IS NOT INITIAL.
          ADD 1 TO  gs_statistic-nuller_kassenzeichen.
        ENDIF.
        IF <fs_data>-p-sste_ueberz_forderung IS NOT INITIAL.
          ADD 1 TO  gs_statistic-sste_ueberz_forderung.
        ENDIF.
        IF <fs_data>-p-betrag_0 IS NOT INITIAL.
          ADD 1 TO  gs_statistic-betrag_0.
        ENDIF.
        IF <fs_data>-p-payac01_saknr_hit_first IS NOT INITIAL.
          ADD 1 TO  gs_statistic-payac01_saknr_hit_first.
        ENDIF.
        IF <fs_data>-p-kz_ignore_rk_error IS NOT INITIAL.
          ADD 1 TO  gs_statistic-kz_ignore_rk_error.
        ENDIF.

        COLLECT gs_statistic INTO gt_statistic.
      ENDLOOP.


      TRY.
          SORT gt_statistic BY epl.

          cl_salv_table=>factory(
            IMPORTING
              r_salv_table = DATA(go_salv_statistic)
            CHANGING
              t_table      = gt_statistic ).

          go_salv_statistic->get_columns( )->get_column( 'INITIAL' )->set_medium_text( value = 'INITIAL' ).
          go_salv_statistic->get_columns( )->get_column( 'INITIAL' )->set_short_text( value = 'INITIAL' ).
          go_salv_statistic->get_columns( )->get_column( 'INITIAL' )->set_long_text( value = 'INITIAL' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_FEHLT' )->set_long_text( value = 'RK_FEHLT' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_FEHLT' )->set_medium_text( value = 'RK_FEHLT' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_FEHLT' )->set_short_text( value = 'RK_FEHLT' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_POS_NICHT_GEFUNDEN' )->set_long_text( value = 'RK_POS_N_GEFUNDEN' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_POS_NICHT_GEFUNDEN' )->set_medium_text( value = 'RK_POS_N_GEFUNDEN' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_POS_NICHT_GEFUNDEN' )->set_short_text( value = 'RK_POS_N' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_GEPRUEFT' )->set_long_text( value = 'RK_GEPRUEFT' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_GEPRUEFT' )->set_medium_text( value = 'RK_GEPRUEFT' ).
          go_salv_statistic->get_columns( )->get_column( 'RK_GEPRUEFT' )->set_short_text( value = 'RK_GEPR' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_GP' )->set_long_text( value = 'FEHLER_GP' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_GP' )->set_medium_text( value = 'FEHLER_GP' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_GP' )->set_short_text( value = 'FEHLER_GP' ).
          go_salv_statistic->get_columns( )->get_column( 'GP_ANGELEGT' )->set_long_text( value = 'GP_ANGELEGT' ).
          go_salv_statistic->get_columns( )->get_column( 'GP_ANGELEGT' )->set_medium_text( value = 'GP_ANGELEGT' ).
          go_salv_statistic->get_columns( )->get_column( 'GP_ANGELEGT' )->set_short_text( value = 'GP_ANGEL' ).
          go_salv_statistic->get_columns( )->get_column( 'NACHARBEIT_GP_FEHLERHAFT' )->set_long_text( value = 'NACHARBEIT_GP_FEHLER' ).
          go_salv_statistic->get_columns( )->get_column( 'NACHARBEIT_GP_FEHLERHAFT' )->set_medium_text( value = 'NACHARBEIT_GP_FEHLER' ).
          go_salv_statistic->get_columns( )->get_column( 'NACHARBEIT_GP_FEHLERHAFT' )->set_short_text( value = 'NACH_GP_FE' ).
          go_salv_statistic->get_columns( )->get_column( 'GP_FREIGEGEBEN' )->set_long_text( value = 'GP_FREIGEGEBEN' ).
          go_salv_statistic->get_columns( )->get_column( 'GP_FREIGEGEBEN' )->set_medium_text( value = 'GP_FREIGEGEBEN' ).
          go_salv_statistic->get_columns( )->get_column( 'GP_FREIGEGEBEN' )->set_short_text( value = 'GP_FREI' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_AO_BELEG' )->set_long_text( value = 'FEHLER_AO_BELEG' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_AO_BELEG' )->set_medium_text( value = 'FEHLER_AO_BELEG' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_AO_BELEG' )->set_short_text( value = 'FEHLER_AO' ).
          go_salv_statistic->get_columns( )->get_column( 'AO_BELEG_ERZEUGT' )->set_long_text( value = 'AO_BELEG_ERZEUGT' ).
          go_salv_statistic->get_columns( )->get_column( 'AO_BELEG_ERZEUGT' )->set_medium_text( value = 'AO_BELEG_ERZEUGT' ).
          go_salv_statistic->get_columns( )->get_column( 'AO_BELEG_ERZEUGT' )->set_short_text( value = 'AO_BELEG' ).
          go_salv_statistic->get_columns( )->get_column( 'KTO_DATEI_ERSTELLT' )->set_long_text( value = 'KTO_DATEI_ERSTELLT' ).
          go_salv_statistic->get_columns( )->get_column( 'KTO_DATEI_ERSTELLT' )->set_medium_text( value = 'KTO_DATEI_ERSTELLT' ).
          go_salv_statistic->get_columns( )->get_column( 'KTO_DATEI_ERSTELLT' )->set_short_text( value = 'KTO_DATEI' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_FOLGEBELEG' )->set_medium_text( value = 'FEHLER_FOLGEBELEG' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_FOLGEBELEG' )->set_long_text( value = 'FEHLER_FOLGEBELEG' ).
          go_salv_statistic->get_columns( )->get_column( 'FEHLER_FOLGEBELEG' )->set_short_text( value = 'FEHLER_FOL' ).
          go_salv_statistic->get_columns( )->get_column( 'FOLGEBELEG_ERSTELLT' )->set_long_text( value = 'FOLGEBELEG_ERSTELLT' ).
          go_salv_statistic->get_columns( )->get_column( 'FOLGEBELEG_ERSTELLT' )->set_medium_text( value = 'FOLGEBELEG_ERSTELLT' ).
          go_salv_statistic->get_columns( )->get_column( 'FOLGEBELEG_ERSTELLT' )->set_short_text( value = 'FOLGEBELEG' ).
          go_salv_statistic->get_columns( )->get_column( 'K_RATE_N_STICHTAG' )->set_long_text( value = 'K_RATE_N_STICHTAG' ).
          go_salv_statistic->get_columns( )->get_column( 'K_RATE_N_STICHTAG' )->set_medium_text( value = 'K_RATE_N_STICHTAG' ).
          go_salv_statistic->get_columns( )->get_column( 'K_RATE_N_STICHTAG' )->set_short_text( value = 'K_RATE_STI' ).
          go_salv_statistic->get_columns( )->get_column( 'ABSETZUNG_AO_ERSTELLT' )->set_long_text( value = 'ABSETZUNG_AO_ERST' ).
          go_salv_statistic->get_columns( )->get_column( 'ABSETZUNG_AO_ERSTELLT' )->set_medium_text( value = 'ABSETZUNG_AO_ERST' ).
          go_salv_statistic->get_columns( )->get_column( 'ABSETZUNG_AO_ERSTELLT' )->set_short_text( value = 'ABSETZ_AO' ).
          go_salv_statistic->get_columns( )->get_column( 'NULLER_KASSENZEICHEN' )->set_long_text( value = 'NULLER_KASSENZEICHEN' ).
          go_salv_statistic->get_columns( )->get_column( 'NULLER_KASSENZEICHEN' )->set_medium_text( value = 'NULLER_KASSENZEICHEN' ).
          go_salv_statistic->get_columns( )->get_column( 'NULLER_KASSENZEICHEN' )->set_short_text( value = '0_KASSENZ' ).
          go_salv_statistic->get_columns( )->get_column( 'SSTE_UEBERZ_FORDERUNG' )->set_long_text( value = 'UEBERZ_FORDERUNGEN' ).
          go_salv_statistic->get_columns( )->get_column( 'SSTE_UEBERZ_FORDERUNG' )->set_medium_text( value = 'UEBERZ_FORDERUNG' ).
          go_salv_statistic->get_columns( )->get_column( 'SSTE_UEBERZ_FORDERUNG' )->set_short_text( value = 'UEBERZ_FO' ).
          go_salv_statistic->get_columns( )->get_column( 'PAYAC01_SAKNR_HIT_FIRST' )->set_long_text( value = 'PAYAC01_SAKNR_FIRST' ).
          go_salv_statistic->get_columns( )->get_column( 'PAYAC01_SAKNR_HIT_FIRST' )->set_medium_text( value = 'PAYAC01_SAKNR_FIRST' ).
          go_salv_statistic->get_columns( )->get_column( 'PAYAC01_SAKNR_HIT_FIRST' )->set_short_text( value = 'PAYAC01' ).
          go_salv_statistic->get_columns( )->get_column( 'KZ_IGNORE_RK_ERROR' )->set_long_text( value = 'KZ_IGNORE_RK_ERROR' ).
          go_salv_statistic->get_columns( )->get_column( 'KZ_IGNORE_RK_ERROR' )->set_medium_text( value = 'KZ_IGNORE_RK_ERROR' ).
          go_salv_statistic->get_columns( )->get_column( 'KZ_IGNORE_RK_ERROR' )->set_short_text( value = 'KZ_IGN_RK' ).
          go_salv_statistic->get_columns( )->get_column( 'BETRAG_0' )->set_long_text( value = 'BETRAG_0' ).
          go_salv_statistic->get_columns( )->get_column( 'BETRAG_0' )->set_medium_text( value = 'BETRAG_0' ).
          go_salv_statistic->get_columns( )->get_column( 'BETRAG_0' )->set_short_text( value = 'BETRAG_0' ).

*          go_salv_statistic->get_columns( )->set_optimize( ).
          go_salv_statistic->get_functions( )->set_all( ).
          go_salv_statistic->display( ).

        CATCH cx_root INTO DATA(gx_root).
          MESSAGE gx_root->get_text( ) TYPE 'I'.
      ENDTRY.

    WHEN OTHERS.

      SELECT partner FROM but000 INTO TABLE @DATA(lt_but000) WHERE partner IN @so_bp.
      IF sy-subrc = 0.
        DATA(l_cnt) = lines( lt_but000 ).
        WRITE: 'Anzahl Partner: ', l_cnt.
      ENDIF.
  ENDCASE.
