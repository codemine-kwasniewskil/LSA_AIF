*&---------------------------------------------------------------------*
*& Report /THKR/MIG_RUNS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_runs.


TABLES: /thkr/process,
        /thkr/s_dto_de_run.

SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001.
*  PARAMETERS: p_prtp TYPE /thkr/process_type_de AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND uc1 OBLIGATORY DEFAULT 'AO_I'.
  PARAMETERS: p_prtp TYPE /thkr/process_type_mig AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND uc1 OBLIGATORY DEFAULT 'MIG_AO'.
  SELECT-OPTIONS: s_pid FOR /thkr/process-process_id.
  PARAMETERS: p_migo TYPE /thkr/s_mig_run_selection-migrationsobjekt DEFAULT 'SSTE'.

  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS: s_date FOR /thkr/s_dto_de_run-cr_date.
  PARAMETERS: p_stat TYPE /thkr/process_status AS LISTBOX VISIBLE LENGTH 30.
SELECTION-SCREEN END OF BLOCK 001.

START-OF-SELECTION.


  DATA: l_selection TYPE /thkr/s_mig_run_selection,
        l_salv      TYPE REF TO /thkr/cl_easy_salv.



****  IF p_prtp = 'MIG_AO' OR
****     p_prtp = 'MIG_RK' OR
****     p_prtp = 'MIG_CA'.

    TRY .
        IF l_salv IS INITIAL.
          l_selection-process_type     = p_prtp.
          l_selection-r_process_id     = s_pid[].
          l_selection-r_datum          = s_date[].
          l_selection-migrationsobjekt = p_migo.
          l_selection-status           = p_stat.

          CREATE OBJECT l_salv TYPE /thkr/cl_salv_mig_runs.

        ENDIF.

        l_salv->display(
          EXPORTING
            i_selection = l_selection ).

      CATCH cx_root INTO DATA(l_oerror).
        /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
    ENDTRY.

****  ENDIF.
