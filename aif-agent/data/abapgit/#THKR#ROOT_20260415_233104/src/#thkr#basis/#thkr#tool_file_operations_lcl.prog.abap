*&---------------------------------------------------------------------*
*& Include          /THKR/TOOL_FILE_MOVE_LCL
*&---------------------------------------------------------------------*
CLASS lcl_appl DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: at_selection_screen_output.
    CLASS-METHODS: get_initial_values.
    CLASS-METHODS: process.
    CLASS-METHODS: f4_filename CHANGING cv_filename TYPE eps2filnam.
  PRIVATE SECTION.
    CLASS-DATA: mv_default_dir TYPE dirname.

    CLASS-METHODS: move_files  IMPORTING it_files TYPE eps2filis.
    CLASS-METHODS: zip_files   IMPORTING it_files TYPE eps2filis.
    CLASS-METHODS: read_file   IMPORTING iv_filename    TYPE eps2filnam
                               RETURNING VALUE(rv_file) TYPE xstring.
    CLASS-METHODS: delete_file IMPORTING iv_filename    TYPE eps2filnam.
ENDCLASS.

CLASS lcl_appl IMPLEMENTATION.
  METHOD get_initial_values.
    SELECT SINGLE dirname
      FROM user_dir
      INTO @mv_default_dir
      WHERE aliass = 'Z_SST'.
    IF sy-subrc = 0.
      p_path_s = mv_default_dir.
      p_path_d = mv_default_dir.
      p_path_z = mv_default_dir.
    ENDIF.
  ENDMETHOD.
  METHOD at_selection_screen_output.
    LOOP AT SCREEN.
      CASE screen-group1.
        WHEN 'GRM'.
          screen-input = COND #( WHEN rbs1 = abap_true THEN 1 ELSE 0 ).
          screen-active = COND #( WHEN rbs1 = abap_true THEN 1 ELSE 0 ).
          screen-invisible = COND #( WHEN rbs1 = abap_true THEN 0 ELSE 1 ).
        WHEN 'GRZ'.
          screen-input = COND #( WHEN rbs2 = abap_true THEN 1 ELSE 0 ).
          screen-active = COND #( WHEN rbs2 = abap_true THEN 1 ELSE 0 ).
          screen-invisible = COND #( WHEN rbs2 = abap_true THEN 0 ELSE 1 ).
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD.
  METHOD process.
    DATA: lt_files_list TYPE TABLE OF eps2fili.

    CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
      EXPORTING
        iv_dir_name            = p_path_s
        "file_mask              = p_mask
      TABLES
        dir_list               = lt_files_list
      EXCEPTIONS
        invalid_eps_subdir     = 1
        sapgparam_failed       = 2
        build_directory_failed = 3
        no_authorization       = 4
        read_directory_failed  = 5
        too_many_read_errors   = 6
        empty_directory_list   = 7
        OTHERS                 = 8.
    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 4.
          WRITE / |{ TEXT-001 } { p_path_s }|.
        WHEN 7.
          WRITE / |{ TEXT-002 } { p_path_s }|.
        WHEN OTHERS.
          WRITE / |{ TEXT-003 } { p_path_s }|.
      ENDCASE.
      EXIT.
    ELSE.
      DELETE lt_files_list WHERE name NP p_mask.
      IF lt_files_list IS INITIAL.
        WRITE / |{ TEXT-002 } { p_path_s }|.
        EXIT.
      ENDIF.
    ENDIF.

    WRITE / TEXT-slt.
    LOOP AT lt_files_list INTO DATA(ls_file).
      WRITE / ls_file-name.
    ENDLOOP.

    IF rbs1 IS NOT INITIAL.
      move_files( lt_files_list ).
    ELSEIF rbs2 IS NOT INITIAL.
      zip_files( lt_files_list ).
    ENDIF.
  ENDMETHOD.
  METHOD f4_filename.
    DATA: lv_file_name TYPE eps2filnam.
    CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
      EXPORTING
        directory        = mv_default_dir
      IMPORTING
        serverfile       = lv_file_name
      EXCEPTIONS
        canceled_by_user = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      EXIT.
    ELSEIF lv_file_name IS NOT INITIAL.
      cv_filename = lv_file_name.
    ENDIF.
  ENDMETHOD.
  METHOD move_files.
    DATA: lt_protocol   TYPE TABLE OF btcxpm.
    DATA: lv_status     TYPE extcmdexex-status.

    LOOP AT it_files INTO DATA(ls_file).
      CASE abap_true.
        WHEN rbm1.
          DATA(lv_output_filename) = ls_file-name.
        WHEN rbm2.
          lv_output_filename = |{ sy-datum }_{ ls_file-name }|.
        WHEN rbm3.
          lv_output_filename = |{ sy-datum }_{ sy-uzeit }_{ ls_file-name }|.
      ENDCASE.
      DATA(lv_addit_par) = CONV btcxpgpar( |'%{ p_path_s }/{ ls_file-name }%' '%{ p_path_d }/{ lv_output_filename }%'| ).
      CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
        EXPORTING
          commandname                   = 'ZMV'
          additional_parameters         = lv_addit_par
        IMPORTING
          status                        = lv_status
        TABLES
          exec_protocol                 = lt_protocol
        EXCEPTIONS
          no_permission                 = 1
          command_not_found             = 2
          parameters_too_long           = 3
          security_risk                 = 4
          wrong_check_call_interface    = 5
          program_start_error           = 6
          program_termination_error     = 7
          x_error                       = 8
          parameter_expected            = 9
          too_many_parameters           = 10
          illegal_command               = 11
          wrong_asynchronous_parameters = 12
          cant_enq_tbtco_entry          = 13
          jobcount_generation_error     = 14
          OTHERS                        = 15.
      IF sy-subrc <> 0 OR lv_status = 'E'.
        READ TABLE lt_protocol INTO DATA(ls_protocol) INDEX 1.
        IF sy-subrc = 0.
          WRITE / ls_protocol-message.
        ELSE.
          WRITE / |{ TEXT-004 } { ls_file-name }|.
        ENDIF.
      ELSE.
        WRITE / |{ TEXT-005 } { ls_file-name } { TEXT-006 }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD zip_files.
    DATA: lv_rawdata  TYPE xstring.

    DATA(lo_zip) = NEW cl_abap_zip( ).
    LOOP AT it_files INTO DATA(ls_file).
      lo_zip->add( name = CONV #( ls_file-name )  content = read_file( |{ p_path_s }/{ ls_file-name }| ) ).
    ENDLOOP.
    DATA(lv_zip_xstr) = lo_zip->save( ).

    DATA(lv_zip_filename) = p_path_z.
    REPLACE '<SID>' IN lv_zip_filename WITH |{ sy-sysid }|.
    REPLACE '<DATE>' IN lv_zip_filename WITH |{ sy-datum }|.
    REPLACE '<TIME>' IN lv_zip_filename WITH |{ sy-uzeit }|.

    OPEN DATASET lv_zip_filename FOR OUTPUT IN BINARY MODE.
    IF sy-subrc = 0.
      TRANSFER lv_zip_xstr TO lv_zip_filename.
      CLOSE DATASET lv_zip_filename.
      WRITE: TEXT-007, lv_zip_filename.
      IF rbz3 IS NOT INITIAL.
        LOOP AT it_files INTO ls_file.
          delete_file( |{ p_path_s }/{ ls_file-name }| ).
        ENDLOOP.
      ENDIF.
    ELSE.
      WRITE: TEXT-008.
    ENDIF.
  ENDMETHOD.
  METHOD read_file.
    DATA: lt_rawdata    TYPE sdokcntbins.
    DATA: lv_line       TYPE sdokcntbin.

    DATA(all_bytelengh) = 0.
    OPEN DATASET iv_filename FOR INPUT IN BINARY MODE.
    IF sy-subrc = 0.
      READ DATASET iv_filename INTO rv_file.
      CLOSE DATASET iv_filename.
    ENDIF.
  ENDMETHOD.
  METHOD delete_file.
    DELETE DATASET iv_filename.
    IF sy-subrc = 0.
      WRITE: TEXT-009, iv_filename.
    ELSE.
      WRITE: TEXT-010, iv_filename.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
