*&---------------------------------------------------------------------*
*& Report /thkr/psm_bsp_upload
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/psm_bsp_upload.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_file RADIOBUTTON GROUP fd1 USER-COMMAND fd DEFAULT 'X'.
  PARAMETERS: p_dir RADIOBUTTON GROUP fd1.
  PARAMETERS: p_pathl TYPE ibipparms-path.
SELECTION-SCREEN END OF BLOCK part1.

SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_test  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: p_del  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK part3.

**********************************************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pathl.
  DATA: lv_rc TYPE i.
  DATA: lt_file_table TYPE filetable.
  IF p_file = abap_true.
    cl_gui_frontend_services=>file_open_dialog( EXPORTING window_title = 'Datei auswählen' CHANGING file_table = lt_file_table rc = lv_rc ).
    IF lv_rc <> -1.
      TRY.
          p_pathl = lt_file_table[ 1 ]-filename .
        CATCH cx_sy_itab_line_not_found.
          MESSAGE i001(/thkr/fi_init) DISPLAY LIKE 'E'.
          EXIT.
      ENDTRY.
    ENDIF.
  ENDIF.

  IF p_dir = abap_true.
    DATA: lv_dir TYPE string.
    cl_gui_frontend_services=>directory_browse(
        EXPORTING
          window_title = 'Verzeichnis auswählen'
        CHANGING
           selected_folder = lv_dir
        EXCEPTIONS
          cntl_error = 1
          error_no_gui = 2
          not_supported_by_gui = 3 ).

    IF sy-subrc = 0.
      p_pathl = lv_dir.
    ELSE.
      MESSAGE ID '/THKR/PSM_TOOLS' TYPE 'I' NUMBER 010
        WITH sy-subrc cond symsgv( WHEN sy-subrc = 1 Then 'CNTR_ERROR'
                                   WHEN sy-subrc = 2 THEN 'ERROR_NO_GUI'
                                   WHEN sy-subrc = 3 THEN 'NOT_SUPPORTED_BY_GUI' )  DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

**********************************************************************
START-OF-SELECTION.
  DATA: lt_file_table TYPE filetable.
  DATA(handler) = NEW /thkr/cl_psm_bsp_upload( ).

  TRY.
    DATA(lv_path_ok) = handler->check_path_for_file_or_dir(
      EXPORTING
        iv_is_dir  = p_dir                 " allgemeines flag
        iv_is_file = p_file                 " allgemeines flag
        iv_path    = p_pathl                 " Filename
    ).

      handler->get_files(
        EXPORTING
          iv_path       = p_pathl
          iv_is_file    = p_file                 " allgemeines flag
          iv_is_dir     = p_dir                 " allgemeines flag
        IMPORTING
          et_file_table = lt_file_table                 " file_table
      ).
      LOOP AT lt_file_table ASSIGNING FIELD-SYMBOL(<ls_file>).
        handler->run(  path     = CONV #( <ls_file>-filename )
                       testmode = p_test
                       delete   = p_del ).
      ENDLOOP.
      handler->get_data( IMPORTING processed_data = DATA(processed_data) ).
    CATCH /thkr/cx_psm_tools into DATA(lx_exc).
      MESSAGE ID lx_exc->if_t100_message~t100key-msgid
            TYPE 'I'
            NUMBER lx_exc->if_t100_message~t100key-msgno
            WITH lx_exc->if_t100_dyn_msg~msgv1 lx_exc->if_t100_dyn_msg~msgv2 lx_exc->if_t100_dyn_msg~msgv3 lx_exc->if_t100_dyn_msg~msgv4
            DISPLAY LIKE 'E'.
  ENDTRY.
**** Show mapped data
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(salv)
                              CHANGING  t_table      = processed_data ).

      DATA(header) = COND #( WHEN p_test = abap_true THEN ' - TESTMODE -' ).
      salv->get_display_settings( )->set_list_header( |Upload BSP { header }| ).
      salv->get_functions( )->set_all( abap_true ).
      salv->get_columns( )->set_optimize( abap_true ).
      salv->get_sorts( )->add_sort( columnname = 'BUDCAT' sequence = if_salv_c_sort=>sort_up ).
      salv->get_sorts( )->add_sort( columnname = 'FISCYEAR' sequence = if_salv_c_sort=>sort_up ).
      salv->get_sorts( )->add_sort( columnname = 'FUND' sequence = if_salv_c_sort=>sort_up ).
      salv->get_sorts( )->add_sort( columnname = 'FUNDSCTR' sequence = if_salv_c_sort=>sort_up ).
      salv->get_sorts( )->add_sort( columnname = 'CMMTITEM' sequence = if_salv_c_sort=>sort_up ).
      salv->display( ).

    CATCH cx_salv_error INTO DATA(err).
      MESSAGE err->get_text( ) TYPE 'E'.
  ENDTRY.
