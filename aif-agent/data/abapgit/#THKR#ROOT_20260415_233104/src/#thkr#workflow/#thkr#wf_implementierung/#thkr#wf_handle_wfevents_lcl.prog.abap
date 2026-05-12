*&---------------------------------------------------------------------*
*& Include          /THKR/WF_HANDLE_WFEVENTS_LCL
*&---------------------------------------------------------------------*
*       CLASS lcl_events DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_events DEFINITION.

  PUBLIC SECTION.
    METHODS:
      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed sender.

ENDCLASS.                    "lcl_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_rohr_eventhandler IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_events IMPLEMENTATION.

  METHOD handle_data_changed.

    " alle Inhalte der geänderten Zellen in die interne Tabelle schreiben
    LOOP AT er_data_changed->mt_good_cells INTO DATA(ls_good).
      " Dazu auf die richtige Zeile in der ITAB positionieren:
      READ TABLE <lt_itab> ASSIGNING FIELD-SYMBOL(<ls_wa>) INDEX ls_good-row_id.
      IF sy-subrc = 0.
        " Und das geänderte Feld dem Feldsymbol zuweisen
        ASSIGN COMPONENT ls_good-fieldname OF STRUCTURE <ls_wa> TO <lv_feld>.
        IF sy-subrc = 0.
          " Feldwert zuweisen
          <lv_feld> = ls_good-value.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "handle_data_changed

ENDCLASS.
