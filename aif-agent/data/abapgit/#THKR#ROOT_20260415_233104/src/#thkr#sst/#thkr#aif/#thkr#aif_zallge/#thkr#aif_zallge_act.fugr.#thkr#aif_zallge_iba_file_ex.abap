FUNCTION /THKR/AIF_ZALLGE_IBA_FILE_EX .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(CONTEXT) TYPE  STRING OPTIONAL
*"     REFERENCE(FINF) TYPE  /AIF/T_FINF
*"     REFERENCE(ACTION) TYPE  /AIF/IFACTION OPTIONAL
*"     REFERENCE(TESTRUN) TYPE  /AIF/IFTESTRUN OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) OPTIONAL
*"  EXCEPTIONS
*"      CANCEL
*"----------------------------------------------------------------------
  DATA: lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics.
  DATA: lv_exists     TYPE flag.
  DATA: lv_file_count TYPE i.
  DATA: dir_list TYPE STANDARD TABLE OF epsfili.

  FIELD-SYMBOLS: <ls_header> TYPE /thkr/s_aif_bic_header.
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  "header -> contains important part of the filename
  "line -> contains individual target table for output file
  "footer -> contains the footer for BIC output file
  ASSIGN COMPONENT 'HEADER' OF STRUCTURE <ls_data> TO <ls_header>.

  lo_protokoll = NEW /thkr/cl_aif_file_basics( ).

  DATA(Lv_logical_filename) = |/THKR/AIF_{ finf-ifname }_OUT|.
  DATA(lv_filename) = <ls_header>-start && |{ <ls_header>-verfa CASE = LOWER }| && <ls_header>-gennr && '.' && <ls_header>-empf && '.' && <ls_header>-dienstnr.
  DATA(lv_output_file) = lo_protokoll->get_filepath( iv_logical_filename = CONV #( lv_logical_filename ) iv_filename = lv_filename ).

  FIND ALL OCCURRENCES OF '/' IN lv_output_file RESULTS DATA(lt_result).
  DATA(lv_offset) = lt_result[ lines( lt_result ) ]-offset + 1.
  DATA(lv_output_dir) = lv_output_file(lv_offset).
  lv_output_file = lv_output_file+lv_offset.

  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name               = CONV epsf-epsdirnam( lv_output_dir )
      file_mask              = CONV epsf-epsfilnam( lv_output_file )
    IMPORTING
*     DIR_NAME               =
      file_counter           = lv_file_count
*     ERROR_COUNTER          =
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

  IF lv_file_count <> 0.
    if 1 = 0. MESSAGE e034(/THKR/SST) with lv_output_file lv_output_dir.endif.
    APPEND VALUE BAPIRET2( id = '/THKR/SST'
                           type = 'E'
                           number = 034
                           message_v1 = lv_output_file
                           message_v2 = lv_output_dir ) to return_tab[].
    RAISE cancel.
  ENDIF.

ENDFUNCTION.
