CLASS /thkr/cl_bfw_appl DEFINITION
  PUBLIC
  CREATE PROTECTED .

  PUBLIC SECTION.

    CLASS-METHODS get_lsa_appl
      RETURNING
        VALUE(e_reference) TYPE REF TO /thkr/cl_bfw_appl .
    CLASS-METHODS get_instance
      EXPORTING
        VALUE(e_instance) TYPE REF TO /thkr/cl_bfw_appl
      RETURNING
        VALUE(r_instance) TYPE REF TO /thkr/cl_bfw_appl .
    METHODS constructor .
    METHODS delete_events_by_ln_key
      IMPORTING
        !i_ln_art         TYPE /thkr/event_ln_art
        !i_ln_key         TYPE /thkr/event_ln_key
        !i_event_category TYPE /thkr/event_category OPTIONAL .
    METHODS get_dto_event
      IMPORTING
        !i_event_id TYPE /thkr/event_id
        !i_ln_art   TYPE /thkr/event_ln_art OPTIONAL
      EXPORTING
        !e_dto      TYPE /thkr/s_dto_event_d .
    METHODS get_tdto_event
      IMPORTING
        !i_selection  TYPE /thkr/s_event_selection
      EXPORTING
        !e_tdto_event TYPE /thkr/t_dto_event .
    METHODS modify_events_from_tdto
      IMPORTING
        !i_tdto_event TYPE /thkr/t_dto_event .
    METHODS modify_event_from_dto
      IMPORTING
        !i_dto_event TYPE /thkr/s_dto_event_d .
  PROTECTED SECTION.

    CLASS-DATA lsa_appl TYPE REF TO /thkr/cl_bfw_appl .

    METHODS get_new_event_id
      EXPORTING
        !e_event_id TYPE /thkr/event_id .
  PRIVATE SECTION.

    DATA t_event_category2 TYPE STANDARD TABLE OF /thkr/c_event .
ENDCLASS.



CLASS /THKR/CL_BFW_APPL IMPLEMENTATION.


  METHOD CONSTRUCTOR.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE t_event_category2
      FROM /thkr/c_event.

  ENDMETHOD.


  METHOD DELETE_EVENTS_BY_LN_KEY.

    DATA: lt_event_id TYPE STANDARD TABLE OF /thkr/event_id,
          l_event_id  TYPE /thkr/event_id.

    IF i_ln_art IS INITIAL OR i_ln_key IS INITIAL.
      RETURN.
    ENDIF.

    SELECT id INTO TABLE lt_event_id
      FROM  /thkr/ln_evt
      WHERE  ln_art  = i_ln_art
      AND    ln_key  = i_ln_key.

    LOOP AT  lt_event_id  INTO l_event_id.

      IF i_event_category IS NOT INITIAL.

        SELECT SINGLE id INTO l_event_id
          FROM /thkr/event
          WHERE id             = l_event_id
          AND   event_category = i_event_category.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
      ENDIF.

      DELETE
      FROM  /thkr/event
      WHERE id  = l_event_id.

      DELETE FROM /thkr/ln_evt
      WHERE id = l_event_id.

      DELETE FROM /thkr/evt_blob
      WHERE id = l_event_id.

    ENDLOOP.

  ENDMETHOD.


  METHOD GET_DTO_EVENT.

    DATA: l_selection  TYPE /thkr/s_event_selection,
          l_tdto_event TYPE /thkr/t_dto_event,
          l_event      TYPE /thkr/c_event,
          lt_x255      TYPE /thkr/t_x255.


    l_selection-event_id = i_event_id.
    l_selection-ln_art   = i_ln_art.

    get_tdto_event(
      EXPORTING
        i_selection  = l_selection
      IMPORTING
        e_tdto_event = l_tdto_event ).

    READ TABLE l_tdto_event INDEX 1 INTO e_dto.

    SELECT x255 INTO TABLE @lt_x255
      FROM /thkr/evt_blob
      WHERE id = @i_event_id
      ORDER BY lfd_nr.

    IF sy-subrc = 0.

      /thkr/cl_helpers=>get_instance( )->uncompress_xstring(
        EXPORTING
          it_x255   = lt_x255
        IMPORTING
          e_xstring = e_dto-xstring ).

    ENDIF.

  ENDMETHOD.


  METHOD GET_INSTANCE.

    IF lsa_appl IS INITIAL.
      CREATE OBJECT lsa_appl.
    ENDIF.

    e_instance = lsa_appl.
    r_instance = lsa_appl.

  ENDMETHOD.


  METHOD GET_LSA_APPL.

    IF lsa_appl IS INITIAL.
      CREATE OBJECT lsa_appl.
    ENDIF.

    e_reference = lsa_appl.

  ENDMETHOD.


  METHOD GET_NEW_EVENT_ID.

    CLEAR e_event_id.


    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '00'
        object                  = '/THKR/EVENT'
*       QUANTITY                = '1'
*       SUBOBJECT               = ' '
*       TOYEAR                  = '0000'
*       IGNORE_BUFFER           = ' '
      IMPORTING
        number                  = e_event_id
*       QUANTITY                =
*       RETURNCODE              =
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    IF sy-subrc <> 0.
      ASSERT 1 = 2.

    ENDIF.


  ENDMETHOD.


  METHOD GET_TDTO_EVENT.

    DATA: l_helper        TYPE REF TO /thkr/cl_helpers,
          l_select_clause TYPE string,
          l_from_clause   TYPE string,
          l_where_clause  TYPE string,
          l_and           TYPE string,
          l_ln_selected   TYPE xfeld,
          l_ln_event      TYPE /thkr/s_ln_evt,
          l_index         TYPE i.

    CLEAR: e_tdto_event.

    FIELD-SYMBOLS <dto_event> LIKE LINE OF e_tdto_event.

    l_helper = /thkr/cl_helpers=>get_instance( ).

    l_helper->get_select_clause_from_struct(
      EXPORTING
        i_structure     = '/THKR/S_EVENT'
        i_prefix        = 'a'
      CHANGING
        c_select_clause = l_select_clause ).

    CONCATENATE 'a~id' l_select_clause
      INTO l_select_clause SEPARATED BY space.

    l_from_clause = '/thkr/event AS a'.

    IF i_selection-ln_art IS NOT INITIAL OR i_selection-ln_key IS NOT INITIAL
      OR i_selection-t_ln_event IS NOT INITIAL OR i_selection-r_ln_key IS NOT INITIAL.

      IF i_selection-t_ln_event IS NOT INITIAL AND i_selection-ln_key IS NOT INITIAL.
        ASSERT 1 = 2.
        "Entweder Tabelle mit Verknüpfungen oder einzelne Verknüpfung!
      ENDIF.

      l_ln_selected = 'X'.
      CONCATENATE l_from_clause 'inner join /thkr/ln_evt as b on a~id = b~id'
        INTO l_from_clause SEPARATED BY space.

      CONCATENATE l_select_clause 'b~ln_art b~ln_key'
        INTO l_select_clause SEPARATED BY space.

    ENDIF.

    l_index = 1.

    READ TABLE i_selection-t_ln_event INDEX l_index INTO l_ln_event.
    IF sy-subrc <> 0.
      l_ln_event-ln_art = i_selection-ln_art.
      l_ln_event-ln_key = i_selection-ln_key.
    ENDIF.

    DO.

      CLEAR: l_where_clause, l_and.

      IF i_selection-process_type IS NOT INITIAL.
        l_where_clause = 'a~process_type = i_selection-process_type'.
        l_and = 'and'.

      ENDIF.

      IF i_selection-process_id IS NOT INITIAL.

        CONCATENATE l_where_clause l_and 'a~process_id = i_selection-process_id'
            INTO l_where_clause SEPARATED BY space.
        l_and = 'and'.
      ENDIF.

      IF i_selection-event_category IS NOT INITIAL.

        CONCATENATE l_where_clause l_and 'a~event_category = i_selection-event_category'
            INTO l_where_clause SEPARATED BY space.
        l_and = 'and'.

      ENDIF.

      IF i_selection-event_category2 IS NOT INITIAL.

        CONCATENATE l_where_clause l_and 'a~event_category2 = i_selection-event_category2'
            INTO l_where_clause SEPARATED BY space.
        l_and = 'and'.

      ENDIF.

      IF i_selection-event_id IS NOT INITIAL.

        CONCATENATE l_where_clause l_and 'a~id = i_selection-event_id'
            INTO l_where_clause SEPARATED BY space.
        l_and = 'and'.

      ENDIF.

      IF l_ln_event-ln_art IS NOT INITIAL.

        CONCATENATE l_where_clause l_and 'b~ln_art = l_ln_event-ln_art'
            INTO l_where_clause SEPARATED BY space.
        l_and = 'and'.

      ENDIF.

      IF l_ln_event-ln_key IS NOT INITIAL.

        CONCATENATE l_where_clause l_and 'b~ln_key = l_ln_event-ln_key'
            INTO l_where_clause SEPARATED BY space.
        l_and = 'and'.

      ENDIF.

      IF i_selection-r_ln_key IS NOT INITIAL.

        CONCATENATE l_where_clause l_and 'b~ln_key in i_selection-r_ln_key'
            INTO l_where_clause SEPARATED BY space.
        l_and = 'and'.

      ENDIF.

      SELECT (l_select_clause) APPENDING CORRESPONDING FIELDS OF TABLE e_tdto_event
        FROM (l_from_clause)
        WHERE (l_where_clause).

      l_index = l_index + 1.
      READ TABLE i_selection-t_ln_event INDEX l_index INTO l_ln_event.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

    ENDDO.

    LOOP AT e_tdto_event ASSIGNING <dto_event>.

      CONVERT TIME STAMP <dto_event>-cr_time_stamp TIME ZONE sy-zonlo
        INTO DATE <dto_event>-cr_date TIME <dto_event>-cr_time.

      SELECT * INTO CORRESPONDING FIELDS OF TABLE <dto_event>-t_ln_evt
        FROM /thkr/ln_evt
        WHERE id = <dto_event>-id.

      READ TABLE t_event_category2 WITH KEY event_category2 = <dto_event>-event_category2
        INTO DATA(l_event_category2).
      IF sy-subrc = 0.
        <dto_event>-is_read_only = l_event_category2-is_read_only.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD MODIFY_EVENTS_FROM_TDTO.

    LOOP AT i_tdto_event ASSIGNING FIELD-SYMBOL(<dto_event>) WHERE dto_status IS NOT INITIAL.

      modify_event_from_dto( i_dto_event = <dto_event> ).

    ENDLOOP.

  ENDMETHOD.


  METHOD MODIFY_EVENT_FROM_DTO.

    DATA: l_event           TYPE /thkr/event,
          l_ln_evt          TYPE /thkr/ln_evt,
          l_event_category2 TYPE /thkr/c_event.

    IF i_dto_event-dto_status = 'D'. "Ereignis löschen

      DELETE FROM /thkr/event
      WHERE id = i_dto_event-id.

    ELSEIF i_dto_event-dto_status = 'C'.

      MOVE-CORRESPONDING i_dto_event TO l_event.

      IF i_dto_event-id IS INITIAL.
*       Neues Ereignis
        ASSERT i_dto_event-ln_art IS NOT INITIAL.
        ASSERT i_dto_event-ln_key IS NOT INITIAL.

        get_new_event_id(
          IMPORTING
            e_event_id = l_event-id ).

        l_ln_evt-id = l_event-id.
        l_ln_evt-ln_art = i_dto_event-ln_art.
        l_ln_evt-ln_key = i_dto_event-ln_key.

        GET TIME STAMP FIELD l_event-cr_time_stamp.
        IF l_event-cr_user IS INITIAL.
          l_event-cr_user = sy-uname.
        ENDIF.

        MODIFY /thkr/ln_evt FROM l_ln_evt.
      ENDIF.

      IF l_event-amnt IS NOT INITIAL AND l_event-waers IS INITIAL.
        l_event-waers = 'EUR'.
      ENDIF.

      IF i_dto_event-event_category2 IS NOT INITIAL.
        READ TABLE t_event_category2 WITH KEY event_category2 = i_dto_event-event_category2
          INTO l_event_category2.
      ENDIF.

      IF l_event-event_date IS INITIAL.
        l_event-event_date = sy-datum.
      ENDIF.

      MODIFY /thkr/event FROM l_event.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
