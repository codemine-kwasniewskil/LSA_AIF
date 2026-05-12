*&---------------------------------------------------------------------*
*& Include          /THKR/FI_CHK_IBAN_GP_CLA                           *
*&---------------------------------------------------------------------*
*& Beschreibung:                                                       *
*&                                                                     *
*& Programm-Klassen /THKR/FI_CHK_IBAN_GP - Bericht IBAN - GP's         *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:       Frank Brähler (Orexes GmbH)                            *
*& Anlage:      22.01.2026                                             *
*&                                                                     *
*& Änderer:     Frank Brähler                                          *
*& l.Datum:     22.01.2026                                             *
*&                                                                     *
*&---------------------------------------------------------------------*

************************************************************************
* Klassen Definitionen                                                 *
************************************************************************
CLASS lcl_appl DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS:
      display IMPORTING it_alv TYPE /thkr/fi_tools_t_iban_gp_alv.

  PROTECTED SECTION.
    CLASS-DATA:
      mt_alv   TYPE /thkr/fi_tools_t_iban_gp_alv,
      mo_table TYPE REF TO cl_salv_table.

  PRIVATE SECTION.
ENDCLASS.                    "lcl_appl DEFINITION

************************************************************************
* Klassen Implementierungen                                            *
************************************************************************
CLASS lcl_appl IMPLEMENTATION.
  METHOD display.
************************************************************************
*   Lokale Objekte                                                     *
************************************************************************
    DATA: lo_functions  TYPE REF TO cl_salv_functions,
          lo_display    TYPE REF TO cl_salv_display_settings,
          lo_layout     TYPE REF TO cl_salv_layout,
          lo_columns    TYPE REF TO cl_salv_columns_table,
          lo_column     TYPE REF TO cl_salv_column_table,
          lo_events     TYPE REF TO cl_salv_events_table,
          lo_selections TYPE REF TO cl_salv_selections,
          lo_salv_msg   TYPE REF TO cx_salv_msg.

************************************************************************
*   Lokale Variablen, Strukturen, Tabellentypen                        *
************************************************************************
    DATA: key            TYPE salv_s_layout_key,
          lt_columns     TYPE salv_t_column_ref,
          ls_columns     TYPE salv_s_column_ref,
          lv_short_text  TYPE scrtext_s,
          lv_medium_text TYPE scrtext_m,
          lv_long_text   TYPE scrtext_l,
          lv_variant     TYPE slis_vari,
          lv_msg         TYPE string.

************************************************************************
*   Start der Ausgabe                                                  *
************************************************************************
    mt_alv[] = it_alv[].
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = mo_table
                                CHANGING  t_table      = mt_alv ).

************************************************************************
*   ALV-Ausgabe vorbereiten                                            *
************************************************************************
        lo_functions = mo_table->get_functions( ).
        lo_functions->set_all( abap_true ).

        lo_columns = mo_table->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        CLEAR ls_columns.
        lt_columns = lo_columns->get(  ).

        LOOP AT lt_columns INTO ls_columns.
          TRY.
              lo_column ?= lo_columns->get_column( ls_columns-columnname ).
            CATCH cx_salv_not_found.
              CONTINUE.
          ENDTRY.
        ENDLOOP.

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

        IF NOT p_vari IS INITIAL.
          lo_layout->set_initial_layout( p_vari ).
        ENDIF.

        mo_table->display( ).
      CATCH cx_salv_msg INTO lo_salv_msg.
        lv_msg = lo_salv_msg->get_text( ).
        MESSAGE lv_msg TYPE 'E'.
      CATCH cx_salv_not_found.
    ENDTRY.
  ENDMETHOD.                    "display
ENDCLASS.                    "lcl_appl IMPLEMENTATION
