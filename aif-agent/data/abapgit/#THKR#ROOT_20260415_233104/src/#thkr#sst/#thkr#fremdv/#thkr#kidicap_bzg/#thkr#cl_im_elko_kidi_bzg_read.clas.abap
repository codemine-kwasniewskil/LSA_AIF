class /THKR/CL_IM_ELKO_KIDI_BZG_READ definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FEB_BSIMP_BANK_STATEMENT .

  methods CONSTRUCTOR .
protected section.

  data FILENAME type CHAR20 .
  data DEFAULT_IMPL type ref to CL_FEB_BSIMP_IMPL_BS_X .
private section.

  class-data S_FORMAT_X type FEBFORMAT_LONG .
  class-data S_COUNT type NUMC08 .
ENDCLASS.



CLASS /THKR/CL_IM_ELKO_KIDI_BZG_READ IMPLEMENTATION.


  METHOD if_feb_bsimp_bank_statement~get_bank_statements.
**********************************************************************
*** This BAdi is called once, therefore we gonna delegate to SAP standard if not Kidicap:
    IF is_imp_source-format_long <> '/THKR/KIDICAP'.

      me->default_impl->if_feb_bsimp_bank_statement~get_bank_statements(
        EXPORTING
          it_file_content            = it_file_content    " Inhalt der Zahlungsdatei
          iv_filename                = iv_filename        " Physischer Dateiname
          is_imp_source              = is_imp_source      " Customizing für Import von elektr. Kontoauszug
          iv_filter_value            = iv_filter_value    " Format des elektronischen Kontoauszugs
        IMPORTING
          et_bank_statements         = et_bank_statements " Tabelle der einzelnen Kontoauszüge
        EXCEPTIONS
          get_bank_statements_failed = 1                  " Fehler beim zerlegen der Datei in einzelne Kontoauszüge
      ).
      IF sy-subrc <> 0.
        RAISE get_bank_statements_failed.
      ENDIF.

    ELSE.

**********************************************************************
**** Copy from class CL_FEB_BSIMP_IMPL_BS_X because CR/LF was deleted
***  during process.
***  Keep filename for KIDICAP Identification
**********************************************************************
      me->filename = to_upper( iv_filename+8(15) ). "kidicap_abs_202501_1646.txt -> abs_202501_1646

      DATA:
        lt_bank_statement        TYPE feby_logical_files,
        ls_bank_statement        TYPE febs_log_file,
        lt_single_bank_statement TYPE feby_content,
        ls_single_bank_statement TYPE febs_line,
        l_string_all             TYPE string,
        l_string_length          TYPE int4,
        l_file_line_no_spaces    TYPE string,
        lt_bapiret               TYPE bapirettab,
        ls_bapiret               TYPE bapiret2,
        l_msgv1                  TYPE symsgv.

      DATA: lv_format_group_x TYPE febformat_grp,
            l_format_group_x  TYPE string.
      DATA: ls_log_file              TYPE febs_log_file.

      DATA: r_badi_get_bank_stmts_x  TYPE REF TO fieb_get_bank_stmts_x.

      DATA: lt_string TYPE table_of_strings,
            lv_string TYPE string.

      FIELD-SYMBOLS:
            <ls_file_content>        TYPE febs_line.

* If the long format name is not available we raise an error
      IF is_imp_source-format_long IS INITIAL.
        CALL METHOD cl_feb_appl_log_handler=>add_message
          EXPORTING
            i_msgid       = 'FB'
            i_msgty       = 'E'
            i_msgno       = '890'
            i_detlevel    = '4'
          EXCEPTIONS
            error_occured = 1.
        IF 1 = 2. MESSAGE e890(fb). ENDIF. "format unknown
        RAISE get_bank_statements_failed.
      ENDIF.

      s_format_x = is_imp_source-format_long.

* File is a table of strings, each CR/LF in the file causes a new string.
* concatenate the strings into one and remove possible formatting space characters
* at the begin of the lines, before the opening bracket of a tag
* (but do not remove spaces elsewhere)
      CLEAR l_string_all.
      LOOP AT it_file_content ASSIGNING <ls_file_content>.
        l_file_line_no_spaces = <ls_file_content>-line.
        SHIFT l_file_line_no_spaces LEFT DELETING LEADING ' '.
        SHIFT l_file_line_no_spaces LEFT DELETING LEADING cl_abap_char_utilities=>horizontal_tab. "3452547
        l_string_length = strlen( l_file_line_no_spaces ).
        IF l_string_length > 0.
          IF l_file_line_no_spaces(1) EQ '<'.
* new tag, continue without formatting space-characters
            CONCATENATE l_string_all l_file_line_no_spaces cl_abap_char_utilities=>cr_lf  INTO l_string_all.
          ELSE.
* the leading spaces were no formatting spaces but part of the tag/attribute combination or data; keep them
            CONCATENATE l_string_all <ls_file_content>-line cl_abap_char_utilities=>cr_lf INTO l_string_all.
          ENDIF.
        ELSE.
* no new tag, line contains only spaces; keep them - assuming they are part of the useful data
          CONCATENATE l_string_all <ls_file_content>-line INTO l_string_all.
        ENDIF.
      ENDLOOP. "at file content lines

* get format group name from system table FIEB_FMTGRP_X
* this is needed as BAdI filter for methods split and parse
      CALL FUNCTION 'FIEB_GET_FMTGRP_X'
        EXPORTING
          iv_format_x       = s_format_x
        IMPORTING
          ev_format_group_x = lv_format_group_x.

      l_format_group_x = lv_format_group_x.


* get BAdI for split and parse
      TRY.
          GET BADI r_badi_get_bank_stmts_x
            FILTERS
              format_group_x = l_format_group_x.
        CATCH cx_badi_not_implemented.

          l_msgv1 = s_format_x.
          CALL METHOD cl_feb_appl_log_handler=>add_message
            EXPORTING
              i_msgid       = 'FEB_BSIMP'
              i_msgty       = 'E'
              i_msgno       = '129'
              i_msgv1       = l_msgv1
              i_detlevel    = '4'
            EXCEPTIONS
              error_occured = 1.
          "BadI-Implementation not available for format &1
          IF 1 = 2. MESSAGE e129(feb_bsimp). ENDIF.

          RAISE get_bank_statements_failed.
      ENDTRY.


* Split complete string into many strings with one logical bank statement
      TRY.
          CALL BADI r_badi_get_bank_stmts_x->split
            EXPORTING
              i_string           = l_string_all
            IMPORTING
              et_string          = lt_string
            EXCEPTIONS
              split_not_possible = 1
              wrong_format       = 2.
        CATCH cx_badi_initial_reference.
      ENDTRY.

      IF sy-subrc NE 0.
        CLEAR et_bank_statements.

        IF sy-subrc = 2.
          l_msgv1 = s_format_x.
          CALL METHOD cl_feb_appl_log_handler=>add_message
            EXPORTING
              i_msgid       = 'FEB_BSIMP'
              i_msgty       = 'E'
              i_msgno       = '125'
              i_msgv1       = l_msgv1
              i_detlevel    = '4'
            EXCEPTIONS
              error_occured = 1.
          "Das Format des Kontoauszugs entspricht nicht Format &1
          IF 1 = 2. MESSAGE e125(feb_bsimp). ENDIF.
        ENDIF.

        RAISE get_bank_statements_failed.
      ENDIF.


* parse to get bank_id, iban etc for each logical bank statement
* Loop at bank statements
      LOOP AT lt_string INTO lv_string.
        CLEAR ls_log_file.
        CLEAR lt_single_bank_statement.
        ls_single_bank_statement-line = lv_string.
        APPEND ls_single_bank_statement TO lt_single_bank_statement.
        ls_bank_statement-content = lt_single_bank_statement.

        TRY.
            CALL BADI r_badi_get_bank_stmts_x->parse
              EXPORTING
                i_string           = lv_string
              IMPORTING
                es_log_file        = ls_log_file
                et_bapiret         = lt_bapiret
              EXCEPTIONS
                parse_not_possible = 1.
          CATCH cx_badi_initial_reference.
        ENDTRY.

        IF sy-subrc NE 0.
          ls_bank_statement-x_error = 'X'.

          CALL METHOD cl_feb_appl_log_handler=>add_message
            EXPORTING
              i_msgid       = 'FEB_BSIMP'
              i_msgty       = 'E'
              i_msgno       = '117'
              i_detlevel    = '4'
            EXCEPTIONS
              error_occured = 1.
          IF 1 = 2. MESSAGE e117(feb_bsimp). ENDIF. "Parsing error
        ENDIF.

        LOOP AT lt_bapiret INTO ls_bapiret.
          CALL METHOD cl_feb_appl_log_handler=>add_message
            EXPORTING
              i_msgid       = ls_bapiret-id
              i_msgty       = ls_bapiret-type
              i_msgno       = ls_bapiret-number
              i_msgv1       = ls_bapiret-message_v1
              i_msgv2       = ls_bapiret-message_v2
              i_msgv3       = ls_bapiret-message_v3
              i_msgv4       = ls_bapiret-message_v4
              i_detlevel    = '4'
            EXCEPTIONS
              error_occured = 1.
        ENDLOOP.


        ls_bank_statement-bank_id = ls_log_file-bank_id.
        ls_bank_statement-bank_account = ls_log_file-bank_account.
*      ls_bank_statement-bank_statement_id = ls_log_file-bank_statement_id.

        ls_bank_statement-bank_statement_id = me->filename.
        ls_bank_statement-currency = ls_log_file-currency.
        ls_bank_statement-bank_statement_date = ls_log_file-bank_statement_date.
        ls_bank_statement-ssvoz = ls_log_file-ssvoz.
        ls_bank_statement-ssbtr = ls_log_file-ssbtr.
        ls_bank_statement-esvoz = ls_log_file-esvoz.
        ls_bank_statement-esbtr = ls_log_file-esbtr.
        ls_bank_statement-x_error = ls_log_file-x_error.
* Intraday?
        ls_bank_statement-x_intraday = ls_log_file-x_intraday.
* Status information?
        ls_bank_statement-message_type = ls_log_file-message_type.

        IF ls_bank_statement-message_type = ''.
          IF ls_bank_statement-bank_account IS INITIAL.
*        OR ls_bank_statement-bank_statement_id IS INITIAL
*        OR ls_bank_statement-currency IS INITIAL
*        OR ls_bank_statement-bank_statement_date IS INITIAL.
            ls_bank_statement-x_error = ls_log_file-x_error.
          ENDIF.
        ENDIF.

        APPEND ls_bank_statement TO lt_bank_statement.

      ENDLOOP.
      APPEND LINES OF lt_bank_statement TO et_bank_statements.
    ENDIF. "* End for Kidicap Implementation

  ENDMETHOD.


  METHOD if_feb_bsimp_bank_statement~save_bank_statement.
**********************************************************************
*** This BAdi is called once, therefore we gonna delegate to SAP standard if not Kidicap:
    IF is_control_main_paths-format_long <> '/THKR/KIDICAP'.
      me->default_impl->if_feb_bsimp_bank_statement~save_bank_statement(
        EXPORTING
          it_bank_statement            = it_bank_statement     " Inhalt einer logischen Datei
          iv_anwnd                     = iv_anwnd              " Anwendung, die den Bankdatenspeicher nutzt
          iv_filter_value              = iv_filter_value       " Format des elektronischen Kontoauszugs
          is_control_main_paths        = is_control_main_paths " Importinformationen zum elektr. Kontoauszug
          is_posting_parameter         = is_posting_parameter  " Buchungsparameter zum el. Kontoauszug
          is_account                   = is_account            " Kontoinformationen
          ix_simulation                = ix_simulation         " Flag Simulation
          iv_message_type              = iv_message_type       " Nachrichtentyp
        IMPORTING
          ev_vgext_ok                  = ev_vgext_ok           " Vorgang in Tabelle T028G
          et_mansp                     = et_mansp              " Mahnsperren
          et_nott028g                  = et_nott028g           " Externe Vorgänge, die nicht in Tabelle T028G sind
          et_s_kukey                   = et_s_kukey            " Range für Kurzschlüssel  (Kukeys)
          et_acct_statement            = et_acct_statement     " FEB* für Schnittstelle
        EXCEPTIONS
          bank_statement_not_saved     = 1                     " Kontoauszug konnte nicht gespeichert werden
          check_before_upload_failed   = 2                     " Prüfungen vor Upload fehlerhaft
          status_information_not_saved = 3                     " Statusinformation konnte nicht gespeichert werden
      ).
      IF sy-subrc <> 0.
        CASE sy-subrc.
          WHEN 1. RAISE bank_statement_not_saved.
          WHEN 2. RAISE check_before_upload_failed.
          WHEN 3. RAISE status_information_not_saved.
        ENDCASE.
      ENDIF.
    ELSE.
**********************************************************************
**** Copy from class CL_FEB_BSIMP_IMPL_BS_X because CR/LF was deleted
***  during process.
**********************************************************************

      DATA: ls_bank_statement  TYPE febs_line,
            lv_xslt_transf     TYPE cxsltdesc,
            lv_badi_filter_val TYPE badi_filter_val.
      DATA: lt_acct_statement TYPE tty_feb_if,
            ls_acct_statement TYPE feb_if,
            lt_nott028g       TYPE TABLE OF fieb_nott028g.
      DATA: lt_bapiret     TYPE bapirettab,
            ls_bapiret     TYPE bapiret2,
            lt_bapiret_all TYPE bapirettab,
            sysubrc        TYPE sy-subrc,
            lv_msgv1       TYPE symsgv.
      DATA: l_stmt_key TYPE kukey_eb,
            ls_s_kukey TYPE febs_range_kukey.

      CLEAR lt_bapiret.


* get mapping method from customizing (XSLT, BAdI or ...?)
      CALL FUNCTION 'FIEB_READ_MAPP_X'
        EXPORTING
          i_format_x         = s_format_x
          is_account         = is_account
        IMPORTING
          ev_xslt_transf     = lv_xslt_transf
          ev_badi_filter_val = lv_badi_filter_val
        EXCEPTIONS
          not_found          = 1.

      IF sy-subrc NE 0.
        lv_msgv1 = s_format_x.
        CALL METHOD cl_feb_appl_log_handler=>add_message
          EXPORTING
            i_msgid       = 'FB'
            i_msgty       = 'E'
            i_msgno       = '887'
            i_msgv1       = lv_msgv1
            i_detlevel    = '4'
          EXCEPTIONS
            error_occured = 1.
        IF 1 = 2.
          MESSAGE e887(fb).                             "#EC MG_PAR_CNT
        ENDIF.  "Mapping method could not be determined
        RAISE bank_statement_not_saved.
      ENDIF.


* bank_statements
      IF iv_message_type = ''.

        READ TABLE it_bank_statement INTO ls_bank_statement INDEX 1.
* get deep structure of logical bank statement
        CALL FUNCTION 'FIEB_MAPPING_X'
          EXPORTING
            i_bank_statement   = ls_bank_statement-line
            iv_xslt_transf     = lv_xslt_transf
            iv_badi_filter_val = lv_badi_filter_val
          IMPORTING
            et_acct_statement  = lt_acct_statement
            et_bapiret         = lt_bapiret
          EXCEPTIONS
            error_in_transf    = 1
            error_in_badi      = 2
            no_transformation  = 3
            system_error       = 4
            OTHERS             = 9.

        IF sy-subrc NE 0.
          CASE sy-subrc.
            WHEN 1.   "error_in_transf  ->bapiret
            WHEN 2.    "error_in_badi
              lv_msgv1 = lv_badi_filter_val.
              CALL METHOD cl_feb_appl_log_handler=>add_message
                EXPORTING
                  i_msgid       = 'FB'
                  i_msgty       = 'E'
                  i_msgno       = '888'
                  i_msgv1       = lv_msgv1
                  i_detlevel    = '4'
                EXCEPTIONS
                  error_occured = 1.
              IF 1 = 2.
                MESSAGE e888(fb).                       "#EC MG_PAR_CNT
              ENDIF.  "Error in BAdI

            WHEN 3.   "no_transformation  ->bapiret
            WHEN 4.   "system error in transformation
              lv_msgv1 = lv_xslt_transf.
              CALL METHOD cl_feb_appl_log_handler=>add_message
                EXPORTING
                  i_msgid       = 'FB'
                  i_msgty       = 'E'
                  i_msgno       = '891'
                  i_msgv1       = lv_msgv1
                  i_detlevel    = '4'
                EXCEPTIONS
                  error_occured = 1.
              IF 1 = 2.
                MESSAGE e891(fb).                       "#EC MG_PAR_CNT
              ENDIF.
            WHEN OTHERS.
          ENDCASE.

          IF lt_bapiret IS NOT INITIAL.
            LOOP AT lt_bapiret INTO ls_bapiret.
              CALL METHOD cl_feb_appl_log_handler=>add_message
                EXPORTING
                  i_msgid       = ls_bapiret-id
                  i_msgty       = ls_bapiret-type
                  i_msgno       = ls_bapiret-number
                  i_msgv1       = ls_bapiret-message_v1
                  i_msgv2       = ls_bapiret-message_v2
                  i_msgv3       = ls_bapiret-message_v3
                  i_msgv4       = ls_bapiret-message_v4
                  i_detlevel    = '4'
                EXCEPTIONS
                  error_occured = 1.
            ENDLOOP.
          ENDIF.

          RAISE bank_statement_not_saved.
        ENDIF.

* Overwrite AZWIN
        lt_acct_statement[ 1 ]-febko-azidt = me->filename.
        lt_acct_statement[ 1 ]-febko-aznum = me->filename.

        APPEND LINES OF lt_bapiret TO lt_bapiret_all.

*No error in mapping, we try to save bank statement in FEBxx
        LOOP AT lt_acct_statement INTO ls_acct_statement.
          CLEAR: lt_bapiret, lt_nott028g, l_stmt_key.

          IF iv_anwnd = '0001' OR iv_anwnd = '0006'.        "n2942341
            "FINWDF06-4236
            DATA: lo_bs_accessor  TYPE REF TO if_far_btd_access.
            lo_bs_accessor = cl_far_btd_access_factory=>get_far_btd_access( ).

            lo_bs_accessor->create_bank_statements(
              EXPORTING
                is_bs_header                = ls_acct_statement-febko
                it_bs_items                 = ls_acct_statement-febep
                it_paynote                  = ls_acct_statement-febre
                it_bs_subitems              = ls_acct_statement-febep_subitems
                iv_privileged_access        = abap_true
                iv_application_type         = iv_anwnd
                iv_only_simulate            = ix_simulation
                it_bs_balances              = ls_acct_statement-febko_balance "n3075743
              IMPORTING
*               et_messages                 =
                et_bankstatement_shortkey   = DATA(lt_bs_shortkeys)
                et_messages_t028g           = lt_nott028g
                et_messages_bapiret         = lt_bapiret
                ev_payment_transaction_code = ev_vgext_ok
            ).

*        CALL FUNCTION 'FIEB_SAVE_BANK_STMT'
*          EXPORTING
*            febko_if         = ls_acct_statement-febko
*            ix_simulation    = ix_simulation
*            iv_anwnd         = iv_anwnd
*            it_balances      = ls_acct_statement-febko_balance "n3075743
*          IMPORTING
*            stmt_key         = l_stmt_key
*            e_vgext_ok       = ev_vgext_ok
*          TABLES
*            febep_if         = ls_acct_statement-febep
*            febre_if         = ls_acct_statement-febre
*            febcl_if         = ls_acct_statement-febcl
*            febep_subitem_if = ls_acct_statement-febep_subitems
*            et_nott028g      = lt_nott028g
*            et_bapiret       = lt_bapiret
*          EXCEPTIONS
*            input_wrong      = 1
*            error            = 2
*            error_message    = 3.

          ELSEIF iv_anwnd = '0004'.  "Intraday
            CALL FUNCTION 'FIEB_SAVE_INTRADAY_STMT'
              EXPORTING
                febko_if          = ls_acct_statement-febko
                ix_simulation     = ix_simulation
                iv_anwnd          = iv_anwnd
                it_balances       = ls_acct_statement-febko_balance "n3075743
                it_febep_subitems = ls_acct_statement-febep_subitems
              IMPORTING
                stmt_key          = l_stmt_key
                e_vgext_ok        = ev_vgext_ok
              TABLES
                febep_if          = ls_acct_statement-febep
                febre_if          = ls_acct_statement-febre
                febcl_if          = ls_acct_statement-febcl
                et_nott028g       = lt_nott028g
                et_bapiret        = lt_bapiret
              EXCEPTIONS
                input_wrong       = 1
                error             = 2
                error_message     = 3.
          ENDIF.

          IF sy-subrc = 0.
            IF ix_simulation = 'X'.
*      generate Kukey
              s_count = s_count + 1.
              l_stmt_key = s_count.
            ENDIF.

            IF iv_anwnd = '0001' OR iv_anwnd = '0006'.      "3439499
              LOOP AT lt_bs_shortkeys INTO l_stmt_key.      "3439499
                ls_s_kukey-sign = 'I'.
                ls_s_kukey-option = 'EQ'.
                ls_s_kukey-low = l_stmt_key.
                APPEND ls_s_kukey TO et_s_kukey.
              ENDLOOP.                                      "3439499
            ELSEIF iv_anwnd = '0004'.                       "3439499
              IF l_stmt_key IS NOT INITIAL.
                ls_s_kukey-sign = 'I'.
                ls_s_kukey-option = 'EQ'.
                ls_s_kukey-low = l_stmt_key.
                APPEND ls_s_kukey TO et_s_kukey.
              ENDIF.
            ENDIF.                                          "3439499

          ENDIF.

          APPEND LINES OF lt_nott028g TO et_nott028g.
          APPEND LINES OF lt_bapiret TO lt_bapiret_all.
          APPEND ls_acct_statement TO et_acct_statement.

        ENDLOOP.


        IF lt_bapiret_all IS NOT INITIAL.
          LOOP AT lt_bapiret_all INTO ls_bapiret.
            CALL METHOD cl_feb_appl_log_handler=>add_message
              EXPORTING
                i_msgid       = ls_bapiret-id
                i_msgty       = ls_bapiret-type
                i_msgno       = ls_bapiret-number
                i_msgv1       = ls_bapiret-message_v1
                i_msgv2       = ls_bapiret-message_v2
                i_msgv3       = ls_bapiret-message_v3
                i_msgv4       = ls_bapiret-message_v4
                i_detlevel    = '4'
              EXCEPTIONS
                error_occured = 1.
          ENDLOOP.
        ENDIF.

        IF et_s_kukey IS INITIAL.
          RAISE bank_statement_not_saved.
        ENDIF.


      ELSE. "message_TYPE = 'N'

        READ TABLE it_bank_statement INTO ls_bank_statement INDEX 1.
        CALL FUNCTION 'FIEB_MAPPING_STATUS_X'
          EXPORTING
            i_bank_statement   = ls_bank_statement-line
            iv_xslt_transf     = lv_xslt_transf
            iv_badi_filter_val = lv_badi_filter_val
          IMPORTING
            et_bapiret         = lt_bapiret
          EXCEPTIONS
            error_in_badi      = 1
            error_in_transf    = 2
            OTHERS             = 9.

        sysubrc = sy-subrc.

        IF sy-subrc = 1. "error in BAdI
          lv_msgv1 = lv_badi_filter_val.
          CALL METHOD cl_feb_appl_log_handler=>add_message
            EXPORTING
              i_msgid       = 'FB'
              i_msgty       = 'E'
              i_msgno       = '888'
              i_msgv1       = lv_msgv1
              i_detlevel    = '4'
            EXCEPTIONS
              error_occured = 1.
          IF 1 = 2.
            MESSAGE e888(fb).                           "#EC MG_PAR_CNT
          ENDIF.  "Error in BAdI
        ENDIF.


        IF lt_bapiret IS NOT INITIAL.
          LOOP AT lt_bapiret INTO ls_bapiret.
            CALL METHOD cl_feb_appl_log_handler=>add_message
              EXPORTING
                i_msgid       = ls_bapiret-id
                i_msgty       = ls_bapiret-type
                i_msgno       = ls_bapiret-number
                i_msgv1       = ls_bapiret-message_v1
                i_msgv2       = ls_bapiret-message_v2
                i_msgv3       = ls_bapiret-message_v3
                i_msgv4       = ls_bapiret-message_v4
                i_detlevel    = '4'
              EXCEPTIONS
                error_occured = 1.
            IF ls_bapiret-type = 'E'.
              sysubrc = 1.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF sysubrc = 1.
          RAISE bank_statement_not_saved.
        ENDIF.
      ENDIF.
    ENDIF. "** Kidicap implemenation
  ENDMETHOD.


  METHOD constructor.

    default_impl = NEW cl_feb_bsimp_impl_bs_x( ).

  ENDMETHOD.
ENDCLASS.
