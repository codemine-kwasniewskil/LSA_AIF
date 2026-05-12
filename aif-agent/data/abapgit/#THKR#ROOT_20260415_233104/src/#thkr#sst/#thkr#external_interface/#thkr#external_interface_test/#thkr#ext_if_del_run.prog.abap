*&---------------------------------------------------------------------*
*& Report /THKR/EXT_IF_DEL_RUN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/ext_if_del_run.

TABLES: /thkr/de_run.

PARAMETERS: p_pt TYPE /thkr/process_type_de AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND uc1 OBLIGATORY DEFAULT 'AO_I'.
SELECT-OPTIONS s_pid FOR /thkr/de_run-process_id.

START-OF-SELECTION.

  DATA: l_selection TYPE /thkr/s_de_run_selection.

  l_selection-process_type = p_pt.
  l_selection-r_process_id   = s_pid[].

  ASSERT l_selection-r_process_id IS NOT INITIAL.
  ASSERT l_selection-process_type IS NOT INITIAL.

  /thkr/cl_ext_if_appl=>get_instance( )->get_tdto_de_run(
    EXPORTING
      i_selection = l_selection
    IMPORTING
      et_dto      = DATA(lt_process) ).

  LOOP AT lt_process INTO DATA(l_process).

    /thkr/cl_ext_if_appl=>get_instance( )->delete_run(
      i_process_type = l_process-process_type
      i_process_id   = l_process-process_id ).

  ENDLOOP.
