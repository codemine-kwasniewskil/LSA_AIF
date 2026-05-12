FUNCTION /thkr/aif_zallge_act_prot_err_csv.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

  DATA: lt_csv_rows         TYPE TABLE OF string,
        lv_output_filename  TYPE string,
        lv_ns               TYPE /aif/ns,
        lv_ifname           TYPE /aif/ifname,
        lv_ifversion        TYPE /aif/ifversion,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics.

  APPEND VALUE #( id         = 'KM'
                  number     = 418
                  type       = 'I'
                  message_v1 = '/THKR/AIF_ZALLGE_ACT_PROT_ERR_CSV' ) TO return_tab.

  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  IF <ls_data> IS NOT ASSIGNED OR <ls_data> IS INITIAL.
    APPEND VALUE #( id     = '/THKR/SST'
                    number = 0
                    type   = 'E' ) TO return_tab.
    RETURN.
  ENDIF.

  IF <ls_data>-lst IS INITIAL.
    success = 'Y'.
    RETURN.
  ENDIF.

  TRY.
      lo_protokoll = NEW /thkr/cl_aif_file_basics( ).

      " CSV column header — field set per change spec 2686/2026
      APPEND 'TYP;QUELLE;SATZNR;POS;KAP;TITEL;UKTO;OEH;FAELLIG;SOLL;FEHLERNUMMER;FEHLERTEXT'
        TO lt_csv_rows.

      " Append error-only body rows; returns abap_true if any errors found
      DATA(lv_has_errors) = lo_protokoll->create_csv_err_body(
        EXPORTING
          it_lst       = <ls_data>-lst
          is_data      = <ls_data>
        CHANGING
          ct_csv_table = lt_csv_rows
      ).

      " No errors — nothing to send; set success and return quietly
      IF lv_has_errors = abap_false.
        success = 'Y'.
        APPEND VALUE #( id         = 'KM'
                        number     = 418
                        type       = 'I'
                        message_v1 = 'ACT_PROT_ERR_CSV: keine Fehler, kein Versand' )
          TO return_tab.
        RETURN.
      ENDIF.

      CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
        IMPORTING
          ns        = lv_ns
          ifname    = lv_ifname
          ifversion = lv_ifversion.

      " Reuse the existing _LST logical filename (same directory path).
      " Appending _ERR.csv to the base filename distinguishes this output
      " from any full-LST file written in the same run.
      lv_logical_filename = |/THKR/AIF_{ lv_ifname }_LST|.
      lv_output_filename  = lo_protokoll->get_filepath(
                              iv_logical_filename = lv_logical_filename
                              iv_filename         = CONV string( <ls_data>-common-dateiname )
                                                    && '_ERR.csv' ).

      CALL METHOD lo_protokoll->write_and_send_file_csv
        EXPORTING
          iv_output_filename = lv_output_filename
          it_rows            = lt_csv_rows[]
          iv_ns              = lv_ns
          iv_ifname          = lv_ifname
          iv_ifversion       = lv_ifversion
          iv_eol             = CONV string( cl_abap_char_utilities=>newline )
        CHANGING
          cv_success         = success
          ct_return_tab      = return_tab[].

    CATCH cx_sy_itab_line_not_found INTO DATA(lx_line_not_found).
      " LST table is empty — no records to process; treat as success
      IF 1 = 0. MESSAGE i026(/thkr/sst). ENDIF.
      APPEND VALUE #( id     = '/THKR/SST'
                      number = 026
                      type   = 'I' ) TO return_tab.
      success = 'Y'.
  ENDTRY.

ENDFUNCTION.
