FUNCTION /thkr/aif_fremdv_xslt_rueck .
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
        lv_ifname           TYPE /aif/ifname,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics,
        lv_date             TYPE char40,
        lv_xml              TYPE string.
  DATA: lo_rueck            TYPE REF TO /thkr/cl_aif_rueck.


  FIELD-SYMBOLS: <lt_table> TYPE /thkr/t_aif_sap_kassenergebnis.
  FIELD-SYMBOLS: <ls_common> TYPE /thkr/s_aif_common.
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  "COMMON and LINES should be part of the IST Structure
  "COMMON -> Contains the file name
  "lines -> contains individual target table for IST RÜCKMELDUNG data
  ASSIGN COMPONENT 'COMMON' OF STRUCTURE <ls_data> TO <ls_common>.
  ASSIGN COMPONENT 'LINES' OF STRUCTURE <ls_data> TO <lt_table>.
  IF sy-subrc = 0.
    CREATE OBJECT lo_protokoll.

    CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
      IMPORTING
        ifname = lv_ifname.

    "modify row.
    lo_rueck = NEW /thkr/cl_aif_rueck( ).
    lt_table = lo_rueck->modify_output_tab(
      it_rueck_lines = <lt_table>                 " Tabelle von Strings
    ).

    LOOP AT <lt_table> ASSIGNING FIELD-SYMBOL(<line>).
      <line>-counter = sy-tabix.
    ENDLOOP.

    lv_logical_filename = |/THKR/AIF_{ lv_ifname }_IST|.
    IF <ls_common> IS ASSIGNED.
      lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename = CONV string( <ls_common>-dateiname ) ).
      IF lv_output_filename IS INITIAL.
        success = 'N'.
        APPEND VALUE bapiret2( id         = 'FTR_TRR'
                               number     = 013
                               type       = 'E'
                               message_v1 = lv_logical_filename ) TO return_tab[].
      ELSE.
*        lv_date = |{ sy-datum(4) }-{ sy-datum+4(2) }-{ sy-datum+6(2) }T{ sy-uzeit(2) }:{ sy-uzeit+2(2) }:{ sy-uzeit+4(2) }.0|.
        cl_gdt_conversion=>date_time_outbound(
          EXPORTING
            im_date  = sy-datum        " Datum und Zeit, aktuelles (Applikationsserver-)Datum
            im_time  = sy-uzeit
          IMPORTING
            ex_value = lv_date     " Zeitstempel gem. Aufbau ISO 8601
        ).

        CALL TRANSFORMATION /thkr/abap_to_bruecke_ist
          SOURCE metadata = lv_date
                 data = <lt_table>
                 RESULT XML lv_xml.

        " save file
        OPEN DATASET lv_output_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
        TRANSFER lv_xml TO lv_output_filename.
        CLOSE DATASET lv_output_filename.

*        CALL METHOD lo_protokoll->write_file_from_string_table
*          EXPORTING
*            iv_output_filename = lv_output_filename
*            it_rows            = lt_table[]
*          CHANGING
*            cv_success         = success
*            ct_return_tab      = return_tab[].
      ENDIF.
    ENDIF.


  ENDIF.


ENDFUNCTION.
