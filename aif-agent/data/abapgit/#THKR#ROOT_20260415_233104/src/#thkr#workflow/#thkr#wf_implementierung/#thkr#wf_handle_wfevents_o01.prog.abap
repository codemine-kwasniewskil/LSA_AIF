*&---------------------------------------------------------------------*
*& Include          /THKR/WF_HANDLE_WFEVENTS_O01
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'MAIN'.
  SET TITLEBAR '100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module BUILD_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE build_alv OUTPUT.

  " Datendefinition
  DATA: lt_exclude TYPE ui_functions,                       "#EC NEEDED
        ls_layout  TYPE lvc_s_layo,                         "#EC NEEDED
        ls_variant TYPE disvariant.                         "#EC NEEDED


  IF go_custom_container1 IS INITIAL.

    " Aufbau Container und ALV Objekt
    CREATE OBJECT go_custom_container1
      EXPORTING
        container_name = gv_container1.
    CREATE OBJECT go_grid1
      EXPORTING
        i_parent = go_custom_container1.

    " Aufbau Feldkatalog
    PERFORM build_fieldcat CHANGING gt_fieldcat1.

    " Aufbau ALV layout
    PERFORM build_layout CHANGING ls_layout.

    " Aufbereitung Menü
    PERFORM exclude_tb_functions CHANGING lt_exclude.

    " Edit-Event extra registrieren
    go_grid1->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_modified ).

    " Edit-Mode aktiv setzen
    go_grid1->set_ready_for_input( i_ready_for_input = 1 ).

    " ...und EventHandler zuweisen
    CREATE OBJECT go_events.
    SET HANDLER go_events->handle_data_changed FOR go_grid1.

    " Vorbelegung Variante
    ls_variant-report = sy-repid.

    " Aufruf ALV für erste Anzeige
    CALL METHOD go_grid1->set_table_for_first_display
      EXPORTING
        is_variant           = ls_variant
        i_save               = 'U'
        is_layout            = ls_layout
        it_toolbar_excluding = lt_exclude
      CHANGING
        it_fieldcatalog      = gt_fieldcat1
        it_outtab            = gt_events.

  ELSE.

    " Aufruf ALV
    CALL METHOD go_grid1->refresh_table_display.

  ENDIF.

ENDMODULE.
