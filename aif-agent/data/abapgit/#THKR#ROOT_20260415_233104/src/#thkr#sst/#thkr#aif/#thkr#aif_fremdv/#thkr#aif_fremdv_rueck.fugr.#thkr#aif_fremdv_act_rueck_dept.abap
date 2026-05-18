FUNCTION /thkr/aif_fremdv_act_rueck_dept .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

  TYPES ty_dept TYPE c LENGTH 4.

  DATA: lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics,
        lo_rueck             TYPE REF TO /thkr/cl_aif_rueck,
        lv_ifname            TYPE /aif/ifname,
        lv_logical_filename  TYPE filename-fileintern,
        lv_fn_template       TYPE string,
        lv_fn_base_len       TYPE i,
        lv_eol               TYPE abap_cr_lf,
        lt_depts             TYPE SORTED TABLE OF ty_dept WITH UNIQUE KEY table_line,
        lr_dept_tab          TYPE REF TO data,
        lt_dept_rows         TYPE string_table,
        lv_dateiname         TYPE string,
        lv_output_filename   TYPE string.

  FIELD-SYMBOLS: <lt_lines>    TYPE STANDARD TABLE,
                 <ls_common>   TYPE /thkr/s_aif_common,
                 <ls_line>     TYPE any,
                 <lv_fistl>    TYPE any,
                 <lt_dept_tab> TYPE STANDARD TABLE.

  ASSIGN data TO FIELD-SYMBOL(<ls_data>).
  ASSIGN COMPONENT 'COMMON' OF STRUCTURE <ls_data> TO <ls_common>.
  ASSIGN COMPONENT 'LINES'  OF STRUCTURE <ls_data> TO <lt_lines>.

  " No LINES component or empty → success (mirrors AIF_FREMDV_ACT_RUECK behavior)
  IF sy-subrc <> 0 OR <lt_lines> IS INITIAL.
    APPEND VALUE bapiret2( id = '/THKR/SST'
                           number = 021
                           type = 'S'
                           message_v1 = lv_logical_filename ) TO return_tab[].
    success = 'Y'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_protokoll.
  lo_rueck = NEW /thkr/cl_aif_rueck( ).

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ifname = lv_ifname.

  lv_logical_filename = |/THKR/AIF_{ lv_ifname }_IST|.

  lv_eol = COND #( WHEN lo_rueck->ms_pprop-cr_lf = 1 THEN cl_abap_char_utilities=>cr_lf(1)
                   WHEN lo_rueck->ms_pprop-cr_lf = 2 THEN cl_abap_char_utilities=>newline
                   WHEN lo_rueck->ms_pprop-cr_lf = 3 THEN cl_abap_char_utilities=>cr_lf
                   WHEN lo_rueck->ms_pprop-cr_lf IS INITIAL THEN cl_abap_char_utilities=>newline ).

  " Build filename template by stripping the per-dept suffix .XXXX.txt (9 chars).
  " VMAP_IST_RUECK_FNAME produces: BIxx_YYYYMMDD{ifname_lower}.{DEPT4}.txt
  lv_fn_template = CONV string( <ls_common>-dateiname ).
  lv_fn_base_len = strlen( lv_fn_template ) - 9.
  IF lv_fn_base_len > 0.
    lv_fn_template = lv_fn_template(lv_fn_base_len).
  ENDIF.

  " Collect unique FISTL[0:4] dept keys. INSERT into SORTED+UNIQUE silently ignores dupes.
  LOOP AT <lt_lines> ASSIGNING <ls_line>.
    ASSIGN COMPONENT 'FISTL' OF STRUCTURE <ls_line> TO <lv_fistl>.
    IF sy-subrc = 0 AND <lv_fistl> IS NOT INITIAL.
      INSERT CONV ty_dept( <lv_fistl>(4) ) INTO TABLE lt_depts.
    ENDIF.
  ENDLOOP.

  " Fallback: FISTL absent from LINES or all empty → single file (standard behavior)
  IF lt_depts IS INITIAL.
    DATA(lt_fallback) = lo_rueck->modify_output_tab( it_rueck_lines = <lt_lines> ).
    DATA(lv_fallback_fn) = lo_protokoll->get_filepath(
                             iv_logical_filename = lv_logical_filename
                             iv_filename         = CONV string( <ls_common>-dateiname ) ).
    IF lv_fallback_fn IS INITIAL.
      success = 'N'.
      APPEND VALUE bapiret2( id = 'FTR_TRR'
                             number = 013
                             type = 'E'
                             message_v1 = lv_logical_filename ) TO return_tab[].
      RETURN.
    ENDIF.
    CALL METHOD lo_protokoll->write_file_from_string_table
      EXPORTING
        iv_output_filename = lv_fallback_fn
        it_rows            = lt_fallback[]
        iv_cp              = lo_rueck->ms_pprop-codepage
        iv_eol             = CONV string( lv_eol )
      CHANGING
        cv_success         = success
        ct_return_tab      = return_tab[].
    RETURN.
  ENDIF.

  " Write one file per department
  success = 'Y'.
  LOOP AT lt_depts ASSIGNING FIELD-SYMBOL(<lv_dept>).
    " Build a filtered copy of LINES for this dept
    CREATE DATA lr_dept_tab LIKE <lt_lines>.
    ASSIGN lr_dept_tab->* TO <lt_dept_tab>.
    LOOP AT <lt_lines> ASSIGNING <ls_line>.
      ASSIGN COMPONENT 'FISTL' OF STRUCTURE <ls_line> TO <lv_fistl>.
      IF sy-subrc = 0 AND <lv_fistl>(4) = <lv_dept>.
        INSERT <ls_line> INTO TABLE <lt_dept_tab>.
      ENDIF.
    ENDLOOP.

    " Format, resolve path, and write the dept-specific file
    lt_dept_rows       = lo_rueck->modify_output_tab( it_rueck_lines = <lt_dept_tab> ).
    lv_dateiname       = lv_fn_template && '.' && <lv_dept> && '.txt'.
    lv_output_filename = lo_protokoll->get_filepath(
                           iv_logical_filename = lv_logical_filename
                           iv_filename         = lv_dateiname ).

    IF lv_output_filename IS INITIAL.
      success = 'N'.
      APPEND VALUE bapiret2( id = 'FTR_TRR'
                             number = 013
                             type = 'E'
                             message_v1 = lv_logical_filename ) TO return_tab[].
      RETURN.
    ENDIF.

    CALL METHOD lo_protokoll->write_file_from_string_table
      EXPORTING
        iv_output_filename = lv_output_filename
        it_rows            = lt_dept_rows[]
        iv_cp              = lo_rueck->ms_pprop-codepage
        iv_eol             = CONV string( lv_eol )
      CHANGING
        cv_success         = success
        ct_return_tab      = return_tab[].

    IF success <> 'Y'.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
