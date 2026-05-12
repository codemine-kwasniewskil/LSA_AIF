FUNCTION /thkr/aif_zallge_act_prot_lst .
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

  DATA: lt_table            TYPE TABLE OF string,
        lv_output_filename  TYPE string,
        lv_ns               TYPE /aif/ns,
        lv_ifname           TYPE /aif/ifname,
        lv_ifversion        TYPE /aif/ifversion,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics.

  APPEND VALUE #( id         = 'KM'
               number     = 418
               type       = 'I'
               message_v1 = '/THKR/AIF_ZALLGE_ACT_PROT_LST' ) TO return_tab.

  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

* Initialisiere die Tabelle ohne feste Größe
  CLEAR lt_table.

*AUFBAU HEADER
  IF <ls_data> IS NOT ASSIGNED OR <ls_data> IS INITIAL. "Zeile 1
    APPEND VALUE #( id         = '/THKR/SST'
                         number     = 0
                         type       = 'E'
                         ) TO return_tab.
    RETURN.
  ENDIF.

  TRY.
      lo_protokoll = NEW /thkr/cl_aif_file_basics( ).
      lo_protokoll->create_lst_header(
        EXPORTING
          iv_quelle     = <ls_data>-lst[ 1 ]-quelle
          iv_vkuerzel   = <ls_data>-lst[ 1 ]-verfahrenskuerzel
          iv_stelle     = <ls_data>-lst[ 1 ]-dienststelle
        CHANGING
          ct_prot_table = lt_table                 " Tabelle von Strings
      ).

*AUFBAU BODY
      lo_protokoll->create_lst_body(
        EXPORTING
          it_lst        = <ls_data>-lst                 " Übergabeprotokoll LST
          is_data         = <ls_data>
        CHANGING
          ct_prot_table = lt_table                 " Tabelle von Strings
      ).

*AUFBAU FOOTER
      lo_protokoll->create_lst_footer(
        EXPORTING
          iv_beginn_datum = <ls_data>-common-beginndatum                 " Feld vom Typ DATS
          iv_beginn_uzeit = <ls_data>-common-beginnuzeit                 " Feld vom Typ TIMS
        CHANGING
          ct_prot_table   = lt_table                 " Tabelle von Strings
      ).


      CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
        IMPORTING
          ns        = lv_ns
          ifname    = lv_ifname
          ifversion = lv_ifversion.


      Lv_logical_filename = |/THKR/AIF_{ lv_ifname }_LST|.
      lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename = CONV string( <ls_data>-common-dateiname ) ).

      CALL METHOD lo_protokoll->write_and_send_file
        EXPORTING
          iv_output_filename = lv_output_filename
          it_rows            = lt_table[]
          iv_ns              = lv_ns
          iv_ifname          = lv_ifname
          iv_ifversion       = lv_ifversion
          iv_width           = 80
          iv_eol              = conv string( cl_abap_char_utilities=>newline )
        CHANGING
          cv_success         = success
          ct_return_tab      = return_tab[].
    CATCH cx_sy_itab_line_not_found INTO DATA(lx_line_not_found).
      IF 1 = 0. MESSAGE i026(/thkr/sst).ENDIF.
      APPEND VALUE #( id         = '/THKR/SST'
                         number     = 026
                         type       = 'I'
                         ) TO return_tab.
  ENDTRY.
ENDFUNCTION.
