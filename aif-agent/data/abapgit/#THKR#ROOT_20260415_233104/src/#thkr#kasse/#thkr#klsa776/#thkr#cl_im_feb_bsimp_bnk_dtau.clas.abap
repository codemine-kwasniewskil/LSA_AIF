class /THKR/CL_IM_FEB_BSIMP_BNK_DTAU definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FEB_BSIMP_BANK_STATEMENT .
protected section.
private section.

  data FILENAME type CHAR255 .
ENDCLASS.



CLASS /THKR/CL_IM_FEB_BSIMP_BNK_DTAU IMPLEMENTATION.


  METHOD if_feb_bsimp_bank_statement~get_bank_statements.

** We must fake some data here, because we want the program to continue to the method SAVE_BANK_STATEMENTS
** which only works if the id&account are correctly given here!
** NOTE: Bank-ID and Account will NOT be considered during the booking process only the data from the DTAUS0 file !!
    et_bank_statements = VALUE #( ( bank_id      = '81000000'
                                    bank_account = '0081001500'
                                    "x_intraday   = abap_true
                                    content      = it_file_content ) ).

    me->filename = iv_filename.

  ENDMETHOD.


  METHOD if_feb_bsimp_bank_statement~save_bank_statement.
    DATA: number           TYPE tbtcjob-jobcount,
          name             TYPE tbtcjob-jobname VALUE 'DTAUS0_HANDLER',
          print_parameters TYPE pri_params.

** The FORM dtaus_disk(rfeka100) is messageing direct per MESSAGE call. This would
** break the processing of FEB_FILE_HANDLING. Therefore we call the report as a
** background job and collect/process the messages afterwards.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = name
      IMPORTING
        jobcount         = number
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    IF sy-subrc = 0.
      DATA(anwnd) = COND #( WHEN is_posting_parameter-intraday = abap_true THEN '0004' ELSE iv_anwnd ).
      SUBMIT /thkr/read_dtaus_rfeka100
              TO SAP-SPOOL SPOOL PARAMETERS print_parameters WITHOUT SPOOL DYNPRO
              WITH p_anwnd = anwnd
              WITH p_path  = is_control_main_paths-path_source
              WITH p_flnm  = me->filename
              VIA JOB name NUMBER number
              AND RETURN.

      IF sy-subrc = 0.
        CALL FUNCTION 'JOB_CLOSE'
          EXPORTING
            jobcount             = number
            jobname              = name
            strtimmed            = 'X'
          EXCEPTIONS
            cant_start_immediate = 1
            invalid_startdate    = 2
            jobname_missing      = 3
            lock_failed          = 4
            OTHERS               = 5.
        DO.
          DATA done TYPE btcstatus.
          DATA aborted TYPE btcstatus.
          CALL FUNCTION 'SHOW_JOBSTATE'
            EXPORTING
              jobcount = number
              jobname  = name
            IMPORTING
              aborted  = aborted
              finished = done
            EXCEPTIONS
              OTHERS   = 4.
          IF sy-subrc = 0.
            CHECK done    IS NOT INITIAL
            OR    aborted IS NOT INITIAL.
            EXIT.
          ELSE.
            RAISE bank_statement_not_saved.
          ENDIF.
        ENDDO.
        DATA joblogs TYPE TABLE OF tbtc5.
        CALL FUNCTION 'BP_JOBLOG_READ'
          EXPORTING
            jobcount         = number
            jobname          = name
          TABLES
            joblogtbl        = joblogs
          EXCEPTIONS
            cant_read_joblog = 1
            OTHERS           = 8.
        IF sy-subrc = 0.
          IF line_exists( joblogs[ msgtype = 'E' ] ).
            LOOP AT joblogs INTO DATA(log) WHERE msgtype = 'E'.
              cl_feb_appl_log_handler=>add_message( i_msgid = log-msgid
                                                    i_msgty = log-msgtype
                                                    i_msgno = log-msgno
                                                    i_msgv1 = log-msgv1
                                                    i_msgv2 = log-msgv2
                                                    i_msgv3 = log-msgv3
                                                    i_msgv4 = log-msgv4 ).
            ENDLOOP.
            RAISE check_before_upload_failed.
          ELSE.
            TRY.
                et_s_kukey  = VALUE #( ( sign   = cl_abap_range=>sign-including
                                         option = cl_abap_range=>option-equal
                                         low    = joblogs[ msgid = '/THKR/ELKO' msgno = 002 ]-msgv1 ) ).
                ev_vgext_ok = 0.
              CATCH cx_sy_itab_line_not_found.
                RAISE bank_statement_not_saved.
            ENDTRY.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
