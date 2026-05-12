FUNCTION /thkr/aif_fremdv_act_write_plz .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/SST_PLZ_INPUT_SAP
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

** Dateien wegschreiben ->
  DATA(lo_protokoll) = NEW /thkr/cl_aif_file_basics( ).
  DATA(it_strings) = VALUE string_table( ).

  LOOP AT data-data INTO DATA(data_line) GROUP BY ( data_id = data_line-data_id  ) INTO DATA(data_group).
    CLEAR: it_strings.
    LOOP AT GROUP data_group INTO DATA(member).
      CASE member-data_id.
        WHEN 'PC'. "Postal Code
          DATA(lv_logical_filename) = '/THKR/AIF_I_0034_001_MAP_PLZ'.
        WHEN 'CT'. "City
          lv_logical_filename = '/THKR/AIF_I_0034_001_MAP_ORT'.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
      it_strings = VALUE #( BASE it_strings ( CONV #( member ) ) ).
    ENDLOOP.

    IF it_strings IS NOT INITIAL.
      DATA(outpath) =  lo_protokoll->get_filepath( iv_logical_filename = CONV #( lv_logical_filename ) ).
      lo_protokoll->write_file_from_string_table(
        EXPORTING
          iv_output_filename = outpath
          it_rows            = it_strings            " Tabelle von Strings
          iv_eol             = conv string( cl_abap_char_utilities=>newline )
        CHANGING
          cv_success         = success         " Erfolgskennzeichen
          ct_return_tab      = return_tab[]      " Returntabelle
      ).
      IF success <> 'Y'.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
