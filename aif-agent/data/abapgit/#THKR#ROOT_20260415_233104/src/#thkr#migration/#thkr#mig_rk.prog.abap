*&---------------------------------------------------------------------*
*& Report /THKR/MIG_RK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_rk.

TABLES: /thkr/mig_rk_sap.


DATA: g_del  TYPE xfeld,
      g_disp TYPE xfeld.

SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.

  PARAMETERS: p_epl TYPE /thkr/mig_epl,
              p_ds  TYPE /thkr/mig_rk_dienststelle.
  SELECT-OPTIONS: s_sid FOR /thkr/mig_rk_sap-satz_id,
                  s_kz  FOR /thkr/mig_rk_sap-s_kassenzeichen.
  PARAMETERS: p_pid TYPE /thkr/process_id.
SELECTION-SCREEN END OF BLOCK 001.

SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME.

  PARAMETERS: p_disp TYPE xfeld RADIOBUTTON GROUP gr1 USER-COMMAND uc1 DEFAULT 'X',
              p_inf  TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID inf,
              p_inf2 TYPE xfeld AS CHECKBOX MODIF ID inf,
              p_del  TYPE xfeld RADIOBUTTON GROUP gr1 MODIF ID del.

SELECTION-SCREEN END OF BLOCK 002.

INITIALIZATION.

  IF sy-tcode = '/THKR/MIG_RK_DEL'.
    g_del = 'X'.
  ELSE.
    g_disp = 'X'.
  ENDIF.


AT SELECTION-SCREEN OUTPUT.
  DATA: l_status TYPE xfeld.

  LOOP AT SCREEN.

    IF screen-group1 = 'DEL'.
      PERFORM switch_screen USING g_del.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'INF'.
      PERFORM switch_screen USING g_disp.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.


START-OF-SELECTION.
  DATA: l_salv      TYPE REF TO /thkr/cl_salv_mig_rk_sap,
        l_selection TYPE /thkr/s_mig_rk_sap_selection,
        l_answer    TYPE c.

  CREATE OBJECT l_salv.

  TRY.

      l_selection-epl             = p_epl.
      l_selection-r_kassenzeichen = s_kz[].
      l_selection-r_satz_id       = s_sid[].
      l_selection-dienststelle    = p_ds.
      l_selection-process_id      = p_pid.
      l_selection-flag_init_op_kassenzeichen           = p_inf2.

      IF p_disp IS NOT INITIAL.

        l_salv->display(
          EXPORTING
            i_selection = l_selection
*           i_vari      =
        ).

      ELSEIF p_inf IS NOT INITIAL.

        /thkr/cl_mig_rk=>get_instance( )->init_kass_ops( i_selection = l_selection ).

        MESSAGE i031(/thkr/mig) WITH 'Initialisierung beendet'. "Verarbeitung &1 beendet.

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

          /thkr/cl_mig_appl=>get_instance( )->delete_mig_rks(
            i_selection = l_selection ).

          MESSAGE 'Datensätze gelöscht!' TYPE 'I'.

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
