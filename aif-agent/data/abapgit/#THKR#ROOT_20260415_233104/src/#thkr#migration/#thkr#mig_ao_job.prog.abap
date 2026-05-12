*&---------------------------------------------------------------------*
*& Report /THKR/MIG_AO_JOB
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_ao_job.

DATA: gv_satz_id TYPE /thkr/de_satz_id.


SELECT-OPTIONS: so_dtoao FOR gv_satz_id.
PARAMETERS:
  p_max    TYPE /thkr/mig_ao_sap_status,
  p_rk_p   TYPE xfeld,
  p_btr0_b TYPE xfeld.

START-OF-SELECTION.

  DATA(lv_cnt_dto) = lines( so_dtoao[] ).
  IF lv_cnt_dto <> 0.
    DATA(lv_mod) = lv_cnt_dto DIV 25.
  ENDIF.
  IF lv_mod < 25.
    lv_mod = 25.
  ENDIF.

  DATA(lo_mig_ao) = /thkr/cl_mig_appl=>get_instance( ).

  LOOP AT so_dtoao[] INTO DATA(ls_dto).
    IF sy-batch = abap_true AND sy-tabix MOD lv_mod = 0.
      MESSAGE i032(/thkr/mig) WITH sy-tabix lv_cnt_dto.
    ENDIF.

    lo_mig_ao->process_mig_ao(
      i_satz_id         = ls_dto-low
      i_betrag_0        = p_btr0_b
      i_ignore_rk_error = p_rk_p
      i_max_status      = p_max ).

  ENDLOOP.
