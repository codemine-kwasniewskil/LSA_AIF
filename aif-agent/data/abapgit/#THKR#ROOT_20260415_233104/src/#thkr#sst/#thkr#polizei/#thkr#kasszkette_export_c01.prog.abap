*&---------------------------------------------------------------------*
*& Include          /THKR/ADRCITY_EXPORT_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      CLASS DEFINITION
*&---------------------------------------------------------------------*
CLASS lcl_appl DEFINITION.
*    -----//-----
  PUBLIC SECTION.
    CLASS-METHODS:
      class_constructor,
      main,
      display,
      send_aif,
      screen_check,
      f4_path,
      ss_pbo.

*    -----//-----
  PROTECTED SECTION.
    CLASS-DATA:
      mv_gui_available TYPE c,
      mt_data          TYPE TABLE OF /thkr/s_kassz_kette,
      mo_table         TYPE REF TO cl_salv_table.

*    -----//-----
  PRIVATE SECTION.
    CLASS-METHODS:
      get_data,
      file_save,
      create_file CHANGING ct_text_data TYPE truxs_t_text_data.
ENDCLASS.
*&---------------------------------------------------------------------*
*&      CLASS IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS lcl_appl IMPLEMENTATION.
  METHOD class_constructor.
    CALL FUNCTION 'GUI_IS_AVAILABLE'
      IMPORTING
        return = mv_gui_available.
  ENDMETHOD.
  METHOD main.
    get_data( ).
    IF p_save = abap_true.
      IF mt_data IS NOT INITIAL.
        file_save( ).
      ELSE.
        MESSAGE TEXT-e02 TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  METHOD display.
    CHECK mv_gui_available IS NOT INITIAL.
    DATA: lo_functions  TYPE REF TO cl_salv_functions,
          lo_display    TYPE REF TO cl_salv_display_settings,
          lo_layout     TYPE REF TO cl_salv_layout,
          lo_columns    TYPE REF TO cl_salv_columns_table,
          lo_column     TYPE REF TO cl_salv_column_table,
          lo_events     TYPE REF TO cl_salv_events_table,
          lo_selections TYPE REF TO cl_salv_selections.
    DATA: key            TYPE salv_s_layout_key.

    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = mo_table
                                CHANGING  t_table      = mt_data ).

        lo_functions = mo_table->get_functions( ).
        lo_functions->set_all( abap_true ).

        lo_columns = mo_table->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        " Set columnname as name for generated table
        LOOP AT  mo_table->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<col>).
          <col>-r_column->set_short_text( CONV #( to_mixed( <col>-columnname ) ) ).
          <col>-r_column->set_medium_text( CONV #( to_mixed( <col>-columnname ) ) ).
          <col>-r_column->set_long_text( CONV #( to_mixed( <col>-columnname ) ) ).
        ENDLOOP.
*        DATA(lt_columns) = lo_columns->get(  ).
*        LOOP AT lt_columns INTO DATA(ls_columns).
*          TRY.

*              lo_column ?= lo_columns->get_column( ls_columns-columnname ).
*              CASE ls_columns-columnname.
*                WHEN 'COUNTRY'.
*                  lo_column->set_short_text( CONV #( TEXT-c01 ) ).
*                  lo_column->set_medium_text( CONV #( TEXT-c01 ) ).
*                  lo_column->set_long_text( CONV #( TEXT-c01 ) ).
*                WHEN 'POST_CODE'.
*                  lo_column->set_short_text( CONV #( TEXT-c02 ) ).
*                  lo_column->set_medium_text( CONV #( TEXT-c02 ) ).
*                  lo_column->set_long_text( CONV #( TEXT-c02 ) ).
*                WHEN 'CITY'.
*                  lo_column->set_short_text( CONV #( TEXT-c03 ) ).
*                  lo_column->set_medium_text( CONV #( TEXT-c03 ) ).
*                  lo_column->set_long_text( CONV #( TEXT-c03 ) ).
*                WHEN OTHERS.
*                  lo_column->set_technical( abap_true ).
*              ENDCASE.
*            CATCH cx_salv_not_found.
*          ENDTRY.
*        ENDLOOP.

        lo_selections = mo_table->get_selections( ).
        lo_selections->set_selection_mode( if_salv_c_selection_mode=>cell ).

        lo_display = mo_table->get_display_settings( ).
        lo_display->set_striped_pattern( cl_salv_display_settings=>true ).
        lo_display->set_list_header( TEXT-t01 ).

        lo_layout = mo_table->get_layout( ).
        key-report = sy-repid.
        lo_layout->set_key( key ).
        lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
        lo_layout->set_default( cl_salv_layout=>true ).

        mo_table->display( ).
      CATCH cx_salv_msg INTO DATA(lo_salv_msg).
        DATA(lv_msg) = lo_salv_msg->get_text( ).
        MESSAGE lv_msg TYPE 'E'.
      CATCH cx_salv_not_found.
    ENDTRY.
  ENDMETHOD.
  METHOD send_aif.
*    DATA: lt_aif_data TYPE TABLE OF /thkr/s_pcodes_root.
*
*    SELECT ns, ifname, ifversion, send_pcode
*      FROM /thkr/t_if_pcode
*      INTO TABLE @DATA(lt_interfaces).
*
*    LOOP AT lt_interfaces INTO DATA(ls_interface) WHERE send_pcode IS NOT INITIAL.
*      APPEND INITIAL LINE TO lt_aif_data ASSIGNING FIELD-SYMBOL(<fs_aif_data>).
*      <fs_aif_data> = CORRESPONDING #( ls_interface ).
*      <fs_aif_data>-line = mt_data.
*
*      TRY.
*          CALL METHOD /aif/cl_enabler_xml=>transfer_to_aif_mult
*            EXPORTING
*              it_any_structure = lt_aif_data
*              iv_queue_ns      = ls_interface-ns
*              iv_use_buffer    = abap_true.
*        CATCH /aif/cx_enabler_base INTO DATA(lo_exp_aif).
*        CATCH cx_root INTO DATA(lo_exp_root).
*      ENDTRY.
*    ENDLOOP.

  ENDMETHOD.
  METHOD ss_pbo.
    LOOP AT SCREEN.
      IF screen-name = 'P_AIF'.
        screen-input = 0.
      ENDIF.
      IF screen-group1 = 'LCL'.
        IF p_user = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDMETHOD.
  METHOD screen_check.
    IF p_save = abap_true AND p_path IS INITIAL.
      MESSAGE TEXT-e01 TYPE 'E'.
      EXIT.
    ENDIF.
  ENDMETHOD.
  METHOD f4_path.
    DATA: lv_action   TYPE i,
          lv_filename TYPE string,
          lv_fullpath TYPE string,
          lv_path     TYPE string.

    CASE abap_true.
      WHEN p_local.
        cl_gui_frontend_services=>file_save_dialog(
          EXPORTING
            default_extension = 'csv'
          CHANGING
            filename          = lv_filename
            path              = lv_path
            fullpath          = lv_fullpath
            user_action       = lv_action
          EXCEPTIONS
            OTHERS            = 99 ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          IF lv_action EQ cl_gui_frontend_services=>action_ok.
            p_path = lv_fullpath.
          ENDIF.
        ENDIF.
      WHEN p_appse.
        CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
          IMPORTING
            serverfile       = p_path
          EXCEPTIONS
            canceled_by_user = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
  METHOD get_data.
    SELECT FROM /thkr/kassz_kett
      FIELDS id,fkassz,wkassz
      INTO TABLE @mt_data.
  ENDMETHOD.
  METHOD file_save.
    DATA: lt_csv_output TYPE truxs_t_text_data.",

    CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
      EXPORTING
        i_field_seperator    = ';'
        i_line_header        = abap_false
      TABLES
        i_tab_sap_data       = mt_data
      CHANGING
        i_tab_converted_data = lt_csv_output
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    create_file( CHANGING ct_text_data = lt_csv_output ).
  ENDMETHOD.
  METHOD create_file.
    CASE abap_true.
      WHEN p_local.
        " saving to Local PC
        TRY.
            cl_gui_frontend_services=>gui_download( EXPORTING filename = CONV #( p_path )
                                                              filetype = 'ASC'
                                                    CHANGING  data_tab = ct_text_data ).
          CATCH cx_root INTO DATA(e_text).
            MESSAGE e_text->get_text( ) TYPE 'I'.
        ENDTRY.
      WHEN p_appse.
        " saving to Application Server
        OPEN DATASET p_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

        LOOP AT ct_text_data ASSIGNING FIELD-SYMBOL(<ls_text_data>).
          TRANSFER <ls_text_data> TO p_path.
        ENDLOOP.
        CLOSE DATASET p_path.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
