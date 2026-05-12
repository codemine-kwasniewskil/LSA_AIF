FUNCTION /thkr/aif_fremdv_act_plzdb.
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
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_GP
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------


  DATA: lt_table            TYPE TABLE OF string,
        lv_ns               TYPE /aif/ns,
        lv_ifname           TYPE /aif/ifname,
        lv_ifversion        TYPE /aif/ifversion,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics,
        lt_adrc             TYPE TABLE OF adrc,
        lv_output_filename  TYPE string.


  SELECT DISTINCT
    city1, post_code1, country
  FROM adrc
  WHERE post_code1 <> ''
  INTO CORRESPONDING FIELDS OF TABLE @lt_adrc.


  LOOP AT lt_adrc INTO DATA(ls_adrc).
    APPEND |{ ls_adrc-country WIDTH = 4 }\|{ ls_adrc-post_code1 WIDTH = 10 }\|{ ls_adrc-city1 WIDTH = 27 }\|| TO lt_table.
  ENDLOOP.

  CREATE OBJECT lo_protokoll.

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns     = lv_ns
      ifname = lv_ifname
      ifversion = lv_ifversion.

  lv_logical_filename = |/THKR/AIF_{ lv_ifname }_PLZ|.
  lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename = 'plzdb.txt' ).

  CALL METHOD lo_protokoll->write_and_send_file
    EXPORTING
      iv_output_filename = lv_output_filename
      it_rows            = lt_table[]
      iv_ns              = lv_ns
      iv_ifname          = lv_ifname
      iv_ifversion       = lv_ifversion
      iv_eol             = conv string( cl_abap_char_utilities=>newline )
    CHANGING
      cv_success         = success
      ct_return_tab      = return_tab[].


ENDFUNCTION.
