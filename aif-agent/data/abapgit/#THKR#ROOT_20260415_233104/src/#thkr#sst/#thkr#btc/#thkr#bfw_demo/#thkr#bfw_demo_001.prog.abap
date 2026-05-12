*&---------------------------------------------------------------------*
*& Report /THKR/BFW_DEMO_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/bfw_demo_001.

PARAMETERS: p_fil TYPE /thkr/gi_filter_id DEFAULT 'DEMO001',
            p_apf TYPE xfeld.

START-OF-SELECTION.

  TYPES: BEGIN OF lty_param,
           flight_id TYPE /thkr/bfw_test_flight_id,
         END OF lty_param.

  DATA: lt_string   TYPE STANDARD TABLE OF string,
        l_string    TYPE string,
        lt_mapping  TYPE /thkr/t_gi_mapping_line,
        l_param     TYPE lty_param,
        l_selection TYPE /thkr/s_flight_selection,
        l_gi_appl   TYPE REF TO /thkr/cl_gi_appl.

  TRY.
      l_gi_appl = /thkr/cl_gi_appl=>get_instance( ).

      /thkr/cl_flight_int=>get_instance( )->get_tdto_flight(
        EXPORTING
          i_selection = l_selection
        IMPORTING
          e_tdto      = DATA(lt_flight) ).

      IF p_apf IS NOT INITIAL.

        l_gi_appl->apply_filter(
          EXPORTING
            i_filter_id  = p_fil
*           i_dto_filter = i_dto_filter
          CHANGING
            c_data       = lt_flight ).

      ENDIF.

      LOOP AT lt_flight INTO DATA(l_flight).
        CLEAR: lt_mapping, l_string.

        l_param-flight_id = l_flight-flight_id.

        l_gi_appl->get_data_by_gi(
          EXPORTING
            i_gi_id  = 'DEMO_FL1'
            i_para   = l_param
          CHANGING
            c_data   = lt_mapping ).

        l_gi_appl->write_gi_mapping_to_line(
           EXPORTING
             it_mapping  = lt_mapping
             i_record_id = 'FL1'
           IMPORTING
             e_line      = l_string ).

        APPEND l_string TO lt_string.
        WRITE: / l_string.

      ENDLOOP.

    CATCH cx_root INTO DATA(l_oerror).

      /thkr/cl_helpers=>get_instance( )->display_exception( i_oerror = l_oerror ).

  ENDTRY.
