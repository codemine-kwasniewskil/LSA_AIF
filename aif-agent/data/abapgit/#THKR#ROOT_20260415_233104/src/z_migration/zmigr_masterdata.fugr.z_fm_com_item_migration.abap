FUNCTION z_fm_com_item_migration.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FM_AREA) TYPE  FIKRS
*"     VALUE(I_CMMT_ITEM) TYPE  FM_FIPEX
*"     VALUE(I_FISC_YEAR) TYPE  GJAHR
*"     VALUE(IS_CMMT_ITEM_DATA) TYPE  IFMCIDAT
*"     VALUE(IS_CMMT_ITEM_TEXT) TYPE  FMCMMT_ITEM_TEXT
*"     VALUE(IS_CMMT_ITEM_HIER) TYPE  FMCMMT_ITEM_HIER
*"     VALUE(I_FLG_TEST) TYPE  XFELD DEFAULT 'X'
*"     VALUE(I_FLG_COMMIT) TYPE  XFELD DEFAULT 'X'
*"     VALUE(I_LONGTEXT) TYPE  STRINGVAL
*"  EXPORTING
*"     VALUE(ET_MESSAGES) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

** This FuBa wraps the COMMITMENT ITEM creation and adds the functialty to add
** the longtext as well in on step

** ToDos: Messages are not published to MC correctly. Use message class?


  DATA lines TYPE tline_t.

  "" delete . within Fiposnumber for check
  DATA(fipos1) = CONV fm_fipex( replace( val = i_cmmt_item sub = '.' with = '' ) ).
  DATA: lt_return TYPE TABLE OF  bapiret2.
  DATA: ls_return TYPE  bapiret2.
*  DATA: check_hold VALUE  'X'.
*
  Data: substring2 type FMMDCISUB2-CISUB2.

  DATA: lv_xfeld TYPE xfeld.
  SELECT SINGLE FROM fmci
         FIELDS fipex
         WHERE fikrs = @i_fm_area
           AND gjahr = @i_fisc_year
           AND fipex = @fipos1
         INTO @DATA(fipos).
  IF sy-subrc = 0.
    et_messages = VALUE #( BASE et_messages ( type = 'E' message = 'Fipos bereits vorhanden' ) ).
    RETURN.
  ENDIF.

*  DO.
*    IF check_hold NE space.
*      WAIT UP TO 1 SECONDS.
*    ELSE.
*      exit.
*      endif.
*    ENDDO.
substring2 = i_cmmt_item+4(4).

*OEHanlegen falls nicht vorhanden
**  DATA:
*FM_SUBSTRING_CHECK_EXISTANCE
*
*Falls nein, einfach ohne Text anlegen: FM_NEW_SUBSTRING_WRITE

    CALL FUNCTION 'FM_SUBSTRING_CHECK_EXISTANCE'
      EXPORTING
        i_masdatid    = '2'
        i_strid       = 'ZST-01'
*       I_SUB1        =
        i_sub2        = substring2
      IMPORTING
        e_sub2_exists = lv_xfeld.
    IF lv_xfeld = 'X'.

    ELSE.
      CALL FUNCTION 'FM_NEW_SUBSTRING_WRITE'
        EXPORTING
          i_masdat = '2'
          i_strid  = 'ZST-01'
          i_subnum = 'SUB2'
          i_subval = substring2.


      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = 'X'
        IMPORTING
          return = ls_return.

      APPEND ls_return TO lt_return.
      CLEAR ls_return.
      CLEAR lv_xfeld.

    ENDIF.

    CALL FUNCTION 'FM_COM_ITEM_CREATE_RFC'
      EXPORTING
        i_fm_area         = i_fm_area
        i_cmmt_item       = i_cmmt_item
        i_fisc_year       = i_fisc_year
        is_cmmt_item_data = is_cmmt_item_data
        is_cmmt_item_text = is_cmmt_item_text
        is_cmmt_item_hier = is_cmmt_item_hier
        i_flg_test        = i_flg_test
        i_flg_commit      = i_flg_commit
      IMPORTING
        et_messages       = et_messages.
    LOOP AT et_messages ASSIGNING FIELD-SYMBOL(<msg>).
      IF <msg>-type CA 'EX'.
        ROLLBACK WORK.
        RETURN. " top here because error occured!
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
      EXPORTING
        stream_lines = VALUE string_table( ( i_longtext ) )
        lf           = abap_true
      TABLES
        itf_text     = lines.

    CALL FUNCTION 'CREATE_TEXT'
      EXPORTING
        fid       = 'FP01'
        flanguage = 'D'
        fname     = CONV tdobname( |{ i_fm_area }{ i_fisc_year }{ fipos1 }| )
        fobject   = 'FMMD'
      TABLES
        flines    = lines
      EXCEPTIONS
        no_init   = 1
        no_save   = 2
        OTHERS    = 3.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      et_messages = VALUE #( BASE et_messages ( type = 'E' message = 'Problem mit CREATE_TEXT' ) ).
    ENDIF.

  ENDFUNCTION.
