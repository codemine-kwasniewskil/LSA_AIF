*&---------------------------------------------------------------------*
*& Report /THKR/EXT_IF_RUNS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/ext_if_runs.

TABLES: /thkr/process,
        /thkr/s_dto_de_run.

SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_prtp TYPE /thkr/process_type_de AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND uc1 OBLIGATORY DEFAULT 'AO_I'.
  SELECT-OPTIONS: s_pid FOR /thkr/process-process_id.
  PARAMETERS: p_frvf TYPE /thkr/s_dto_de_run-fremdverf MATCHCODE OBJECT /thkr/fremdverf.
  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS: s_date FOR /thkr/s_dto_de_run-cr_date.
  PARAMETERS: p_stat TYPE /thkr/process_status AS LISTBOX VISIBLE LENGTH 30.
SELECTION-SCREEN END OF BLOCK 001.

START-OF-SELECTION.

  DATA: l_selection TYPE /thkr/s_de_run_selection,
        l_salv      TYPE REF TO /thkr/cl_easy_salv.

  IF l_salv IS INITIAL.
    l_selection-process_type = p_prtp.
    l_selection-r_process_id = s_pid[].
    l_selection-r_datum      = s_date[].
    l_selection-fremdverf    = p_frvf.
    l_selection-status       = p_stat.

    IF p_prtp = 'AO_I' OR
       p_prtp = 'IR_E' OR
       p_prtp = 'FKT_I' OR
       p_prtp = 'GRP_I' OR
       p_prtp = 'EZP_I'.
*      MOVE-CORRESPONDING l_selection TO l_selection.
*      CASE p_prtp.
*        WHEN 'FKT_I'.
*          CREATE OBJECT l_salv TYPE /thkr/cl_salv_ext_if_run2.
*        WHEN OTHERS.
          CREATE OBJECT l_salv TYPE /thkr/cl_salv_ext_if_run.
*      ENDCASE.
    ENDIF.
  ENDIF.

  TRY .
      l_salv->display(
        EXPORTING
          i_selection = l_selection ).

    CATCH cx_salv_not_found.

  ENDTRY.
