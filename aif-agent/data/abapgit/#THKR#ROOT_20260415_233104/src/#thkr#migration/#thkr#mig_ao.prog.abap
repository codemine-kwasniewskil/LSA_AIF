*&---------------------------------------------------------------------*
*& Report /THKR/MIG_AO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_ao.

TABLES: /thkr/mig_ao_sap,
        /thkr/migdao.

DATA: g_del       TYPE xfeld,
      g_ro        TYPE xfeld,
      g_uez_check TYPE c,
      g_uez_kto   TYPE c LENGTH 20.

SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.
  PARAMETERS: p_ep     TYPE /thkr/mig_einzelplan,
              p_mo     TYPE /thkr/mig_obj_ao  AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND uc1,
              p_uez_x  TYPE xfeld MODIF ID uez USER-COMMAND uz1,
              p_btr0_x TYPE xfeld MODIF ID btr USER-COMMAND br0,
              p_edas_s TYPE xfeld MODIF ID ed USER-COMMAND eds.
  SELECT-OPTIONS: s_sid FOR /thkr/mig_ao_sap-satz_id,
                  s_kz  FOR /thkr/migdao-kassenzeichen,
                  s_stat FOR /thkr/mig_ao_sap-status NO INTERVALS.
  PARAMETERS: p_pid TYPE /thkr/process_id.
SELECTION-SCREEN END OF BLOCK 001.
SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME.

  PARAMETERS: p_disp   TYPE xfeld RADIOBUTTON GROUP gr1 USER-COMMAND uc1,
              p_prgp   TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID exe,   " Zahlungspartner erzeugen
              p_prao   TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID exe,
              p_exca   TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID ec1,
              p_uez_r  TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID uz1,
              p_uez_a  TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID uz1,
              p_btr0_b TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID br1,
              p_btr0_a TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID br1,
              p_btr0_k TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID br0,
              p_rao    TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID del,
              p_rzp    TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID del,
              p_del    TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID del,
              p_rk_abs TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID rk.

  SELECTION-SCREEN SKIP.
  PARAMETERS: p_path TYPE pathextern LOWER CASE MODIF ID eca DEFAULT 'C:\Test'.

SELECTION-SCREEN END OF BLOCK 002.

SELECTION-SCREEN BEGIN OF BLOCK 003 WITH FRAME TITLE TEXT-001.

  PARAMETERS: p_errm   TYPE xfeld,
              p_nms2   TYPE /thkr/mig_flag_no_ms2,
              p_test   TYPE xfeld MODIF ID eca,
              p_rk_p   TYPE xfeld,
              p_fcampt TYPE c AS CHECKBOX.

  SELECTION-SCREEN SKIP 1.
  PARAMETERS:
    p_job    TYPE c AS CHECKBOX,
    p_jobcnt TYPE int4,
    p_psize  TYPE int4.


  SELECTION-SCREEN SKIP.

SELECTION-SCREEN END OF BLOCK 003.

INITIALIZATION.
  IF p_mo IS INITIAL.
    GET PARAMETER ID '/THKR/MIGOBJ' FIELD p_mo.
  ENDIF.

  IF sy-tcode = '/THKR/MIG_AO_DEL'.
    g_del = 'X'.
  ELSEIF sy-tcode = '/THKR/MIG'.
    g_ro = 'X'.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  DATA: l_status TYPE xfeld.

  LOOP AT SCREEN.
    IF screen-group1 = 'ECA'.
      IF p_exca IS NOT INITIAL.
        l_status = 'X'.
      ELSE.
        CLEAR l_status.
      ENDIF.
      PERFORM switch_screen USING l_status.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'EC1'.
      IF p_mo = 'IOS' OR p_mo = 'VSA' or p_mo = 'SSTE'.
        l_status = 'X'.
      ELSE.
        CLEAR l_status.
      ENDIF.
      PERFORM switch_screen USING l_status.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'UEZ' OR screen-group1 = 'BTR'.
      IF ( p_mo = 'SSTE' OR p_mo = 'SEE_E' OR p_mo = 'SSTS' OR p_mo = 'SSTW' OR p_mo = 'NF' ).
        l_status = 'X'.
      ELSE.
        CLEAR l_status.
      ENDIF.
      PERFORM switch_screen USING l_status.
      MODIFY SCREEN.
    ENDIF.


    IF screen-group1 = 'BR0'.
      IF ( p_mo = 'SSTE' OR p_mo = 'SEE_E' OR p_mo = 'SSTS' OR p_mo = 'SSTW' OR p_mo = 'NF' ) AND ( p_btr0_x = 'X' OR p_btr0_a = abap_true ).
        screen-active = 1.
      ELSE.
        screen-active = 0.
        IF p_btr0_a = abap_true OR p_btr0_k = abap_true.
          p_btr0_a = space.
          p_btr0_b = space.
          p_btr0_k = space.
          p_disp = abap_true.
        ENDIF.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'UZ1'.
      IF ( p_mo = 'SSTE' OR p_mo = 'SEE_E' OR p_mo = 'SSTS' OR p_mo = 'SSTW' OR p_mo = 'NF' ) AND p_uez_x = 'X'.
        screen-active = 1.
      ELSE.
        screen-active = 0.
        IF p_uez_r = abap_true OR p_uez_a = abap_true.
          p_uez_r = space.
          p_uez_a = space.
          p_disp = abap_true.
        ENDIF.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'EXE'.
      IF g_del IS NOT INITIAL.
        CLEAR l_status.
        PERFORM switch_screen USING l_status.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF screen-group1 = 'DEL'.
      PERFORM switch_screen USING g_del.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON EXIT-COMMAND.
  SET PARAMETER ID '/THKR/MIGOBJ' FIELD p_mo.

START-OF-SELECTION.
  DATA: l_salv      TYPE REF TO /thkr/cl_salv_mig_ao_sap,
        l_selection TYPE /thkr/s_mig_ao_sap_selection,
        l_frontend  TYPE xfeld,
        l_answer    TYPE c.

  TRY.

      IF p_uez_x = 'X' AND ( p_mo = 'SSTW' OR p_mo = 'NF' ).
        DATA(lv_sstw_uez) = abap_true.
      ELSE.
        CLEAR lv_sstw_uez.
      ENDIF.

      IF p_edas_s = abap_true.
        p_mo = 'SSTE'.
        p_ep = '50'.
      ENDIF.

      l_selection-einzelplan            = p_ep.
      l_selection-r_satz_id             = s_sid[].
      l_selection-r_kassenzeichen       = s_kz[].
      l_selection-r_status              = s_stat[].
      l_selection-migrationsobjekt      = p_mo.
      l_selection-process_id            = p_pid.
      l_selection-flag_select_message   = p_errm.
      l_selection-read_only             = g_ro.
      l_selection-flag_ueberz_forderung = p_uez_x.
      l_selection-flag_force_campt      = p_fcampt.
      l_selection-flag_betrag_0         = p_btr0_x.
      l_selection-flag_force_betrag_0   = p_btr0_b.
      l_selection-job_count             = p_jobcnt.
      l_selection-flag_start_as_job     = p_job.
      l_selection-package_size          = p_psize.
      l_selection-rk_abs                = p_rk_abs.
      l_selection-sstwuz                = lv_sstw_uez.
      l_selection-p_edas_s               = p_edas_s.

      /thkr/cl_mig_appl=>get_instance( )->set_flag_no_ms2( p_nms2 ).



      IF p_rk_abs = abap_true.
        " Absetzung AO für negative Sollbeträge aus RK Konto
        /thkr/cl_mig_appl=>get_instance( )->process_mig_absetzung_rk(
          i_selection  = l_selection ).

        MESSAGE i031(/thkr/mig) WITH 'Absetzung AO'. "Verarbeitung &1 beendet.

      ELSEIF  p_disp IS NOT INITIAL OR g_ro IS NOT INITIAL.

        CREATE OBJECT l_salv.
        l_salv->display(
          EXPORTING
            i_selection = l_selection
*           i_vari      =
        ).

      ELSEIF p_prgp IS NOT INITIAL.
        "Zahlungspartner anlegen

        /thkr/cl_mig_appl=>get_instance( )->process_mig_aos(
          i_selection  = l_selection
          i_ignore_rk_error = p_rk_p     " Prüfung auf RK ignorieren
          i_max_status = '20' ).

        MESSAGE i031(/thkr/mig) WITH 'Zahlungspartner anlegen'. "Verarbeitung &1 beendet.


      ELSEIF p_prao IS NOT INITIAL.
        "Anordnungen anlegen

        /thkr/cl_mig_appl=>get_instance( )->process_mig_aos(
          i_selection  = l_selection ).

        MESSAGE i031(/thkr/mig) WITH 'Anordnungen anlegen'. "Verarbeitung &1 beendet.


      ELSEIF p_btr0_b IS NOT INITIAL .
        "Anordnungen 1Cent für Betrag = 0 anlegen -> wird über Selection Parameter gesteuert
        /thkr/cl_mig_appl=>get_instance( )->process_mig_aos(
          i_selection  = l_selection ).

        MESSAGE i031(/thkr/mig) WITH 'Anordnungen anlegen'. "Verarbeitung &1 beendet.

      ELSEIF p_exca IS NOT INITIAL OR p_uez_r IS NOT INITIAL.
        "Kontoauszugsdatei erstellen
        /thkr/cl_mig_appl=>get_instance( )->process_export_camt(
          i_selection = l_selection
          i_path      = CONV #( p_path )
          i_frontend  = 'X'
          i_test      = p_test ).

        MESSAGE i031(/thkr/mig) WITH 'Kontoauszugsdatei erstellen'. "Verarbeitung &1 beendet.
      ELSEIF p_uez_a IS NOT INITIAL.
        " Absetzung AO für überzahlte Forderungen der 1 Cent Lösungerstellen
        /thkr/cl_mig_appl=>get_instance( )->process_mig_absetzung_uez(
          i_selection  = l_selection ).

        MESSAGE i031(/thkr/mig) WITH 'Absetzung AO'. "Verarbeitung &1 beendet.

      ELSEIF p_btr0_a IS NOT INITIAL.
        " Absetzung AO für Betrag = 0 erstellen
        /thkr/cl_mig_appl=>get_instance( )->process_mig_absetzung_btr0(
          i_selection  = l_selection ).

        MESSAGE i031(/thkr/mig) WITH 'Absetzung AO'. "Verarbeitung &1 beendet.

      ELSEIF p_btr0_k IS NOT INITIAL.
        " Kontoauszugsdatei für Betrag = 0  EPL50 erstellen

        IF l_selection-einzelplan IS INITIAL.
          l_selection-einzelplan = '50'.
        ENDIF.

        IF l_selection-einzelplan <> '50'.
          MESSAGE i044(/thkr/mig).
        ELSE.
          /thkr/cl_mig_appl=>get_instance( )->process_export_camt(
            i_selection = l_selection
            i_path      = CONV #( p_path )
            i_frontend  = 'X'
            i_test      = p_test ).

          MESSAGE i031(/thkr/mig) WITH 'Kontoauszugsdatei erstellen'. "Verarbeitung &1 beendet.
        ENDIF.

      ELSEIF p_del IS NOT INITIAL.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar      = 'Datensätze löschen'
            text_question = 'Sollen die Datensätze gelöscht werden?'
            text_button_1 = 'Ja'
            text_button_2 = 'Nein'
          IMPORTING
            answer        = l_answer.

        IF l_answer = '1'.

          /thkr/cl_mig_appl=>get_instance( )->delete_mig_aos(
            i_selection = l_selection ).

          MESSAGE 'Datensätze gelöscht!' TYPE 'I'.

        ENDIF.

      ELSEIF p_rao IS NOT INITIAL.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar      = 'Migrationsergebnisse zurücksetzen'
            text_question = 'Sollen die Anordnungen endknüpft werden?'
            text_button_1 = 'Ja'
            text_button_2 = 'Nein'
          IMPORTING
            answer        = l_answer.

        IF l_answer = '1'.

          /thkr/cl_mig_appl=>get_instance( )->reset_mig_aos(
            i_selection = l_selection
            i_only_ao   = 'X'
          ).

          MESSAGE 'Datensätze verarbeitet!' TYPE 'I'.

        ENDIF.

      ELSEIF p_rzp IS NOT INITIAL.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar      = 'Migrationsergebnisse zurücksetzen'
            text_question = 'Sollen die Anordnungen & Partner endknüpft werden?'
            text_button_1 = 'Ja'
            text_button_2 = 'Nein'
          IMPORTING
            answer        = l_answer.

        IF l_answer = '1'.

          /thkr/cl_mig_appl=>get_instance( )->reset_mig_aos(
            i_selection = l_selection ).

          MESSAGE 'Datensätze verarbeitet!' TYPE 'I'.

        ENDIF.

      ENDIF.

    CATCH cx_root INTO DATA(l_oerror).

      /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

  ENDTRY.

FORM switch_screen USING p_para TYPE xfeld.
  IF p_para IS INITIAL.
    screen-invisible = '1'.
    IF screen-group3 = 'LOW' OR screen-group3 = 'HGH' OR screen-group3 = 'PAR'.
      screen-input = '0'.
    ENDIF.
  ELSE.
    screen-invisible = '0'.
    IF screen-group3 = 'LOW' OR screen-group3 = 'HGH' OR screen-group3 = 'PAR'.
      screen-input = '1'.
    ENDIF.
  ENDIF.
ENDFORM.
