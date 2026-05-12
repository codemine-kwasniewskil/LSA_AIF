FUNCTION z_fm_funds_ctr_create_rfc .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FM_AREA) TYPE  FIKRS
*"     VALUE(I_FUNDS_CTR) TYPE  FISTL
*"     VALUE(IS_FUNDS_CTR_HIVARNT) TYPE  FMFUNDS_CTR_HIVARNT
*"     VALUE(IT_FUNDS_CTR_DATA) TYPE  FMFUNDS_CTR_DATA_T
*"     VALUE(IT_FUNDS_CTR_TEXT) TYPE  FMFUNDS_CTR_TEXT_T
*"     VALUE(I_FLG_TESTRUN) TYPE  TESTRUN DEFAULT 'X'
*"     VALUE(I_FLG_COMMIT) TYPE  XFELD DEFAULT ' '
*"     VALUE(I_FLG_NO_ENQUEUE) TYPE  XFELD DEFAULT ' '
*"     VALUE(I_STR_ID) TYPE  FM_STR_ID DEFAULT 'ZST-01'
*"  EXPORTING
*"     VALUE(ET_MESSAGES) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

* It is only possible to assign the funds center to one
* hierarchy variant because the function module FM_FUNDS_CENTER_NO_SCREEN
* can only handle one assignment.
*
*erstellt, um Funktionalität für sap migration cockpit erweirn zu können
* ======================================================================
*   INCLUDE lfmf2f08. " wg. aufruf
  DATA:
    ls_funds_ctr_all     TYPE fmmd_fistl_all,
    ls_funds_ctr         TYPE fmmd_fmfctr,
    ls_funds_ctr_text    TYPE fmmd_fmfctrt,
    ls_funds_ctr_hivarnt TYPE fmmd_fmhisv.

  DATA:
        lf_messages TYPE bapiret2.

  DATA:
    l_t_dfies          LIKE STANDARD TABLE OF dfies WITH HEADER LINE,
    l_t_fields         TYPE fieldname_tab,
    l_t_funds_ctr_data TYPE fmfunds_ctr_data_t,
    l_line             TYPE c.

  FIELD-SYMBOLS:
    <data> TYPE fmfunds_ctr_data,
    <text> TYPE fmfunds_ctr_text.
* -Erweiterung wg. substrings der Finanzstelle

  DATA: lt_return TYPE TABLE OF  bapiret2.
  DATA: ls_return TYPE  bapiret2.
*  DATA: check_hold VALUE  'X'.
  DATA: substring1 TYPE fmmdcisub1-cisub1.
  DATA: substring2 TYPE fmmdcisub2-cisub2.
  DATA: substring3 TYPE fmmdcisub3-cisub3.
  DATA: lv_xfeld1 TYPE xfeld.
  DATA: lv_xfeld2 TYPE xfeld.
  DATA: lv_xfeld3 TYPE xfeld.
*  SELECT SINGLE FROM fmci
*         FIELDS fipex
*         WHERE fikrs = @i_fm_area
*           AND gjahr = @i_fisc_year
*           AND fipex = @fipos1
*         INTO @DATA(fipos).
*  IF sy-subrc = 0.
*    et_messages = VALUE #( BASE et_messages ( type = 'E' message = 'Fipos bereits vorhanden' ) ).
*    RETURN.
*  ENDIF.

*  DO.
*    IF check_hold NE space.
*      WAIT UP TO 1 SECONDS.
*    ELSE.
*      exit.
*      endif.
*    ENDDO.


  IF i_funds_ctr CS '.'.
    SPLIT i_funds_ctr  AT '.' INTO substring1 substring2 substring3. "customizing ist mit '.' eingestellt
    CONCATENATE: substring1 substring2 substring3  INTO i_funds_ctr ."Rückbau '.' 06.02.2025 pehildem

  ELSE.
    substring1 = i_funds_ctr(4).
    substring2 = i_funds_ctr+4(4).
    substring3 = i_funds_ctr+8(2).
*    CONCATENATE: substring1 substring2 substring3  INTO i_funds_ctr SEPARATED BY '.'.  "Erweiterung wg. Änderung der Struktur der Finanzstellen mit festen '.' im String
    CONCATENATE: substring1 substring2 substring3  INTO i_funds_ctr ."SEPARATED BY '.'.  Rückbau '.' 06.02.2025 pehildem

  ENDIF.
*OEHanlegen falls nicht vorhanden
**  DATA:
*FM_SUBSTRING_CHECK_EXISTANCE
*
*Falls nein, einfach ohne Text anlegen: FM_NEW_SUBSTRING_WRITE

  CALL FUNCTION 'FM_SUBSTRING_CHECK_EXISTANCE'
    EXPORTING
      i_masdatid    = '2'
      i_strid       = 'ZST-01'
      i_sub1        = substring1
      i_sub2        = substring2
      i_sub3        = substring3
    IMPORTING
      e_sub1_exists = lv_xfeld1
      e_sub2_exists = lv_xfeld2
      e_sub3_exists = lv_xfeld3.
  IF lv_xfeld1 = 'X' AND lv_xfeld2 = 'X' AND  lv_xfeld3 = 'X'  .

  ELSEIF lv_xfeld1 = ' '.


    CALL FUNCTION 'FM_NEW_SUBSTRING_WRITE'
      EXPORTING
        i_masdat = '2'
        i_strid  = 'ZST-01'
        i_subnum = 'SUB1'
        i_subval = substring1
*       i_subnum = 'SUB2'
*       i_subval = substring2
*       i_subnum = 'SUB3'
*       i_subval = substring3.
      .

  ELSEIF lv_xfeld2 = ' '.


    CALL FUNCTION 'FM_NEW_SUBSTRING_WRITE'
      EXPORTING
        i_masdat = '2'
        i_strid  = 'ZST-01'
*       i_subnum = 'SUB1'
*       i_subval = substring1
        i_subnum = 'SUB2'
        i_subval = substring2
*       i_subnum = 'SUB3'
*       i_subval = substring3.
      .
  ELSEIF lv_xfeld3 = ' '.


    CALL FUNCTION 'FM_NEW_SUBSTRING_WRITE'
      EXPORTING
        i_masdat = '2'
        i_strid  = 'ZST-01'
*       i_subnum = 'SUB1'
*       i_subval = substring1
*       i_subnum = 'SUB2'
*       i_subval = substring2
        i_subnum = 'SUB3'
        i_subval = substring3.

  ENDIF.


  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait   = 'X'
    IMPORTING
      return = ls_return.

  APPEND ls_return TO lt_return.
  CLEAR ls_return.
  CLEAR: lv_xfeld1, lv_xfeld2, lv_xfeld3.

*  ENDIF.

*  Aufruf dews Inhalts des Originalbaustein FM_FUNDS_CTR_CREATE_RFC


  CONSTANTS:
*-----Anlegen
        con_insert                 LIKE fmdy-xfeld VALUE 'I'.



* Move the data
  ls_funds_ctr_all-fikrs = i_fm_area.
  ls_funds_ctr_all-fistl = i_funds_ctr.


******************************
* Funds Center
  LOOP AT it_funds_ctr_data ASSIGNING <data>.
    CLEAR ls_funds_ctr.
    ls_funds_ctr-fikrs = i_fm_area.
    ls_funds_ctr-fictr = i_funds_ctr.
    ls_funds_ctr-str_id = i_str_id. "Erweiterung wg. Änderung der Struktur der Finanzstellen mit festen '.' im String
    ls_funds_ctr-fcsub1 = substring1.  "Erweiterung wg. Änderung der Struktur der Finanzstellen mit festen '.' im String
    ls_funds_ctr-fcsub2 = substring2. "Erweiterung wg. Änderung der Struktur der Finanzstellen mit festen '.' im String
    ls_funds_ctr-fcsub3 = substring3. "Erweiterung wg. Änderung der Struktur der Finanzstellen mit festen '.' im String
    MOVE-CORRESPONDING <data> TO ls_funds_ctr.
    ls_funds_ctr-action = con_insert.
* Fix 2025-08-14 - valid dates
  TRY.
      ls_funds_ctr-datab = it_funds_ctr_text[ 1 ]-datab.
      ls_funds_ctr-datbis = it_funds_ctr_text[ 1 ]-datbis.
    CATCH cx_sy_itab_line_not_found.
      "Nothing
  ENDTRY.

    APPEND ls_funds_ctr TO ls_funds_ctr_all-tab_fmfctr.
  ENDLOOP.
******************************
* Funds Center Texts
  LOOP AT it_funds_ctr_text ASSIGNING <text>.
    CLEAR ls_funds_ctr_text.
    ls_funds_ctr_text-fikrs = i_fm_area.
    ls_funds_ctr_text-fictr = i_funds_ctr.
    MOVE-CORRESPONDING <text> TO ls_funds_ctr_text.
    ls_funds_ctr_text-action = con_insert.
    APPEND ls_funds_ctr_text TO ls_funds_ctr_all-tab_fmfctrt.
  ENDLOOP.
******************************
* Hierarchyvariant
  CLEAR ls_funds_ctr_hivarnt.
  ls_funds_ctr_hivarnt-fikrs = i_fm_area.
  ls_funds_ctr_hivarnt-fistl = i_funds_ctr.
  MOVE-CORRESPONDING is_funds_ctr_hivarnt TO ls_funds_ctr_hivarnt.
  ls_funds_ctr_hivarnt-action = con_insert.
  APPEND ls_funds_ctr_hivarnt TO ls_funds_ctr_all-tab_fmhisv.

******************************

  DATA: not_found.
*  Methodenaufruf ersetzt durch perform
  PERFORM fund_ctr_read USING i_fm_area
                              i_funds_ctr
                              CHANGING not_found.

  IF not_found = ' '. "sy-subrc = 0. "Found
    IF 1 = 2.
*      MESSAGE e551 WITH i_fm_area i_funds_ctr.   "Nachritenklasse f6
*     Finanzstelle &1 &2 schon vorhanden
    ENDIF.
    lf_messages = cl_fmmd_utils=>get_bapiret2( i_msgty = 'E'
                                               i_msgid = 'F6'
                                               i_msgno = '551'
                                               i_msgv1 = i_fm_area
                                               i_msgv2 = i_funds_ctr ).
    CONCATENATE 'z208_' lf_messages-message  INTO lf_messages-message.

    APPEND lf_messages TO et_messages.
*   It makes no sense to go further if the funds ctr. exists.
    EXIT.
  ENDIF.

******************************
* Call existing function module.

  CALL FUNCTION 'FM_FUNDS_CTR_CREATE_NO_SCREEN'
    EXPORTING
      i_fikrs            = i_fm_area
      i_fistl            = i_funds_ctr
      i_hivarnt          = ls_funds_ctr_hivarnt-hivarnt
      i_f_fmmd_fistl_all = ls_funds_ctr_all
      i_flg_test         = i_flg_testrun
      i_flg_commit       = i_flg_commit
      i_flg_no_enqueue   = i_flg_no_enqueue
*   TABLES
*     I_T_LONGTEXT       =
    EXCEPTIONS
      input_error        = 1
      master_data_error  = 2
      update_error       = 3
      error_message      = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.

    lf_messages = cl_fmmd_utils=>get_bapiret2_symsg( ).
    APPEND lf_messages TO et_messages.

  ENDIF.



*

ENDFUNCTION.
