FUNCTION /thkr/aif_fremdv_act_write_fil .
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

  DATA: lt_table            TYPE TABLE OF string,
        lv_output_filename  TYPE string,
        lv_ns               TYPE /aif/ns,
        lv_ifname           TYPE /aif/ifname,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics.
  DATA: lv_file_count       TYPE i.
  DATA: dir_list TYPE STANDARD TABLE OF epsfili.
  DATA: lo_rueck            TYPE REF TO /thkr/cl_aif_rueck.
  DATA: lo_type            TYPE REF TO cl_abap_typedescr.
  DATA: ls_bic_header     TYPE /thkr/s_aif_bic_header.
  DATA: lv_eol            TYPE abap_cr_lf.


  FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <ls_header> TYPE any.
  FIELD-SYMBOLS: <ls_footer> TYPE /thkr/s_aif_bic_footer.
  FIELD-SYMBOLS: <ls_common> TYPE /thkr/s_aif_common.
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_FREMDV_ACT_WRITE_FIL' ) TO return_tab.
*"----------------------------------------------------------------------


  "header -> contains important part of the filename
  "line -> contains individual target table for output file
  "footer -> contains the footer for BIC output file
  ASSIGN COMPONENT 'HEADER' OF STRUCTURE <ls_data> TO <ls_header>.
  ASSIGN COMPONENT 'LINE' OF STRUCTURE <ls_data> TO <lt_table>.
  ASSIGN COMPONENT 'FOOTER' OF STRUCTURE <ls_data> TO <ls_footer>.
  ASSIGN COMPONENT 'COMMON' OF STRUCTURE <ls_data> TO <ls_common>.

  IF <lt_table> IS ASSIGNED AND <lt_table> IS NOT INITIAL.
    CREATE OBJECT lo_protokoll.


    CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
      IMPORTING
        ns     = lv_ns
        ifname = lv_ifname.

    "modify row.
    lo_rueck = NEW /thkr/cl_aif_rueck( ).

    IF <ls_header> IS ASSIGNED
   AND <ls_footer> IS ASSIGNED.
      lt_table = lo_rueck->modify_output_tab(
                   it_rueck_lines = <lt_table>                 " Tabelle von Strings
                   is_header = <ls_header>
                   is_footer = <ls_footer>
                 ).
    ELSE.
      lt_table = lo_rueck->modify_output_tab(
             it_rueck_lines = <lt_table>                 " Tabelle von Strings
           ).
    ENDIF.

    Lv_logical_filename = |/THKR/AIF_{ lv_ifname }_OUT|.
    IF <ls_header> IS ASSIGNED.

      lo_type ?= cl_abap_typedescr=>describe_by_data( p_data = <ls_header> ).
      IF lo_type->absolute_name+6 = '/THKR/S_AIF_BIC_HEADER'.
        "BIC-Datei
        ls_bic_header = <ls_header>.
        DATA(lv_filename) = ls_bic_header-start+3 && |{ ls_bic_header-verfa CASE = LOWER }| && ls_bic_header-gennr && '.' && ls_bic_header-empf && '.' && ls_bic_header-dienstnr.
      ELSE.
        "Andere Datei.
        "Dateiname muss individuell ausgeprägt werden.
        lv_filename = |Dateiausgabe_{ sy-datum }_{ sy-uzeit }.txt|.
      ENDIF.
    ELSE.
      IF <ls_common> IS ASSIGNED.
        "Dateiname aus Struktur Common verwenden.
        lv_filename = <ls_common>-dateiname.
      ELSE.
        lv_filename = |Dateiausgabe_{ sy-datum }_{ sy-uzeit }.txt|.
      ENDIF.
    ENDIF.
    lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename =  lv_filename ).
    IF lv_output_filename IS INITIAL.
      success = 'N'.
      APPEND VALUE bapiret2( id = 'FTR_TRR'
                       number = 013
                       type = 'E'
                       message_v1 = lv_logical_filename ) TO return_tab[].
    ELSE.

      FIND ALL OCCURRENCES OF '/' IN lv_output_filename RESULTS DATA(lt_result).
      DATA(lv_offset) = lt_result[ lines( lt_result ) ]-offset + 1.
      DATA(lv_output_dir) = lv_output_filename(lv_offset).
      DATA(lv_output_file) = lv_output_filename+lv_offset.


      CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
        EXPORTING
          dir_name               = CONV epsf-epsdirnam( lv_output_dir )
          file_mask              = CONV epsf-epsfilnam( lv_output_file )
        IMPORTING
*         DIR_NAME               =
          file_counter           = lv_file_count
*         ERROR_COUNTER          =
        TABLES
          dir_list               = dir_list
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
* Implement suitable error handling here
      ENDIF.
      DATA(lv_ovwr) = lo_protokoll->overwrite_files(
           iv_ns     = lv_ns                 " Namensraum
           iv_ifname = lv_ifname                 " Schnittstellenname
         ).
      IF  lv_file_count <> 0 AND lv_ovwr = abap_false.
        IF 1 = 0. MESSAGE e034(/thkr/sst) WITH lv_output_file lv_output_dir.ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                               type = 'E'
                               number = 034
                               message_v1 = lv_output_file
                               message_v2 = lv_output_dir ) TO return_tab[].
        success = 'N'.
      ELSE.
        lv_eol =  COND #( WHEN lo_rueck->ms_pprop-cr_lf = 1 THEN cl_abap_char_utilities=>cr_lf(1)
                                               WHEN lo_rueck->ms_pprop-cr_lf = 2 THEN cl_abap_char_utilities=>newline
                                               WHEN lo_rueck->ms_pprop-cr_lf = 3 THEN cl_abap_char_utilities=>cr_lf
                                               WHEN lo_rueck->ms_pprop-cr_lf IS INITIAL THEN cl_abap_char_utilities=>newline ).
        CALL METHOD lo_protokoll->write_file_from_string_table
          EXPORTING
            iv_output_filename = lv_output_filename
            it_rows            = lt_table[]
            iv_cp              = lo_rueck->ms_pprop-codepage
            iv_eol             = CONV string( lv_eol )
          CHANGING
            cv_success         = success
            ct_return_tab      = return_tab[].
      ENDIF.
    ENDIF.

  ELSE.
    IF 1 = 0. MESSAGE i044(/thkr/sst) WITH lv_logical_filename. ENDIF.
    APPEND VALUE bapiret2( id = '/THKR/SST'
                         number = 044
                         type = 'S'
                         message_v1 = lv_logical_filename ) TO return_tab[].
    success = 'Y'.
  ENDIF.



ENDFUNCTION.
