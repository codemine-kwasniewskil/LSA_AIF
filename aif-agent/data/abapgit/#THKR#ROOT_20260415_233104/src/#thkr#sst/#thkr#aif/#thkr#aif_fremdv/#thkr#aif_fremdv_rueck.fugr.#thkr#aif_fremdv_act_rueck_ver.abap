*"----------------------------------------------------------------------
* Gereon Koks  TSI  30.4.2025
*"----------------------------------------------------------------------
* Ausgabe der Felder in eine Datei.
* Hier aber nicht horizontal (d.h. Felder in der Reihe in eine Zeile),
* sondern vertikal (d.h. Felder untereinander jeweils in einem Satz)
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_fremdv_act_rueck_ver .
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
        ls_table            TYPE string,
        lt_table_vert       TYPE TABLE OF string,
        lt_table_send       TYPE TABLE OF string,
        lv_output_filename  TYPE string,
        lv_ifname           TYPE /aif/ifname,
        lv_logical_filename TYPE filename-fileintern,
        lo_protokoll        TYPE REF TO /thkr/cl_aif_file_basics.
  DATA: lo_rueck            TYPE REF TO /thkr/cl_aif_rueck.
  DATA: lv_eol            TYPE ABAP_CR_LF.
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <lt_table> TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <ls_common> TYPE /thkr/s_aif_common.
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).
*"----------------------------------------------------------------------
  "COMMON and LINES should be part of the IST Structure
  "COMMON -> Contains the file name
  "lines -> contains individual target table for IST RÜCKMELDUNG data
  ASSIGN COMPONENT 'COMMON' OF STRUCTURE <ls_data> TO <ls_common>.
  ASSIGN COMPONENT 'LINES' OF STRUCTURE <ls_data> TO <lt_table>.
*"----------------------------------------------------------------------
  IF sy-subrc = 0.
    IF <lt_table> IS NOT INITIAL.
      CREATE OBJECT lo_protokoll.

      CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
        IMPORTING
          ifname = lv_ifname.

      "modify row.
      lo_rueck = NEW /thkr/cl_aif_rueck( ).
      lt_table = lo_rueck->modify_output_tab(
                   it_rueck_lines = <lt_table>                 " Tabelle von Strings
                 ).

      lv_logical_filename = |/THKR/AIF_{ lv_ifname }_IST|.
*"----------------------------------------------------------------------
      IF <ls_common> IS ASSIGNED.
        lv_output_filename = lo_protokoll->get_filepath( iv_logical_filename = lv_logical_filename iv_filename = CONV string( <ls_common>-dateiname ) ).
*"----------------------------------------------------------------------
        IF lv_output_filename IS INITIAL.
          success = 'N'.
          APPEND VALUE bapiret2( id = 'FTR_TRR'
                           number = 013
                           type = 'E'
                           message_v1 = lv_logical_filename ) TO return_tab[].
        ELSE.
          LOOP AT lt_table INTO ls_table.
            SPLIT ls_table AT ';' INTO TABLE lt_table_vert.
            LOOP AT lt_table_vert INTO ls_table.
              APPEND ls_table TO lt_table_send.
            ENDLOOP.
          ENDLOOP.
          lv_eol =  COND #( WHEN lo_rueck->ms_pprop-cr_lf = 1 THEN cl_abap_char_utilities=>cr_lf(1)
                            WHEN lo_rueck->ms_pprop-cr_lf = 2 THEN cl_abap_char_utilities=>newline
                            WHEN lo_rueck->ms_pprop-cr_lf = 3 THEN cl_abap_char_utilities=>cr_lf
                            WHEN lo_rueck->ms_pprop-cr_lf IS INITIAL THEN cl_abap_char_utilities=>newline ).
          CALL METHOD lo_protokoll->write_file_from_string_table
            EXPORTING
              iv_output_filename = lv_output_filename
              it_rows            = lt_table_send[]
              iv_cp              = lo_rueck->ms_pprop-codepage
              iv_eol             = conv string( lv_eol )
            CHANGING
              cv_success         = success
              ct_return_tab      = return_tab[].
        ENDIF.
*"----------------------------------------------------------------------
      ENDIF.
*"----------------------------------------------------------------------
    ELSE.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                           number = 021
                           type = 'S'
                           message_v1 = lv_logical_filename ) TO return_tab[].
      success = 'Y'.
    ENDIF.
*"----------------------------------------------------------------------
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
