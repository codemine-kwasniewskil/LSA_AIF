*&---------------------------------------------------------------------*
*& Report /THKR/MIGRATE_GROUPS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/upload_mapping.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_pathl TYPE ibipparms-path.
SELECTION-SCREEN END OF BLOCK part1.

SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_test  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: p_flush  TYPE abap_bool AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK part3.

SELECTION-SCREEN BEGIN OF BLOCK part4 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN COMMENT /1(75) comm1.
  SELECTION-SCREEN COMMENT /1(75) comm5.
  SELECTION-SCREEN COMMENT /1(75) comm2.
  SELECTION-SCREEN COMMENT /1(75) comm3.
  SELECTION-SCREEN COMMENT /1(75) comm4.
SELECTION-SCREEN END OF BLOCK part4.

**********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pathl.
  DATA: lv_rc TYPE i.
  DATA: lt_file_table TYPE filetable.
  cl_gui_frontend_services=>file_open_dialog( EXPORTING window_title = 'Datei auswählen' CHANGING file_table = lt_file_table rc = lv_rc ).
  IF lv_rc <> -1.
    TRY.
        p_pathl = lt_file_table[ 1 ]-filename .
      CATCH cx_sy_itab_line_not_found.
        MESSAGE i001(/thkr/fi_init) DISPLAY LIKE 'E'.
        EXIT.
    ENDTRY.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  comm1 = 'Die Exceldatei sollte folgenden Aufbau haben:'.
  comm5 = '!! Es wird das erste Tabellenblatt verwendet!!'.
  comm2 = 'Zeile 1:  Warnung/Hinweis'.
  comm3 = 'Zeile 2:  <Beschreibung der Zellen>'.
  comm4 = 'Zeile 3..x:  <Werte>'.

*  LOOP AT SCREEN.
*    IF screen-name CS 'P_FLUSH'.
*      screen-input = 0.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.
**********************************************************************
START-OF-SELECTION.

** Get DB Handler
  DATA(dbhandler) = NEW /thkr/cl_upload_mapping_db( ).
  IF p_flush = abap_true.
    dbhandler->flush_db( testmode = p_test ).
  ELSE.
    TRY.
** Run uploader to upload and map data
        DATA(uploader) = NEW /thkr/cl_upload_mapping( ).
        uploader->run( path = CONV #( p_pathl ) ).
        DATA(mapped_data) = uploader->get_mapped_data( ).
** Push this to db
        dbhandler->save_to_db( mapped_data = mapped_data testmode = p_test ).

        CATCH /thkr/cx_fi_init INTO DATA(err). " Fehlerkasse Init.
        IF err->bapiret2_tab  IS NOT INITIAL.
          cl_rmsl_message=>display( err->bapiret2_tab ).
        ELSE.
          MESSAGE err->get_text( ) TYPE 'E'.
        ENDIF.
    ENDTRY.
  ENDIF.

*** Show mapped data
  cl_salv_table=>factory( IMPORTING r_salv_table = DATA(salv)
                          CHANGING  t_table      = mapped_data ).
  salv->get_functions( )->set_all( abap_true ).
  salv->get_columns( )->set_optimize( abap_true ).
  salv->get_columns( )->get_column( columnname = 'MANDT' )->set_visible( abap_false ).
  salv->display( ).
