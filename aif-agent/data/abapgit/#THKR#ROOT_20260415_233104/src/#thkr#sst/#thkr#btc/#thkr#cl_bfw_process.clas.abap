CLASS /thkr/cl_bfw_process DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA process_type TYPE /thkr/process_type READ-ONLY .
    DATA process_id TYPE /thkr/process_id READ-ONLY .
    DATA attr_process TYPE /thkr/s_process READ-ONLY .
    DATA t_event TYPE /thkr/t_event READ-ONLY .

    METHODS add_event
      IMPORTING
        !i_event_category  TYPE /thkr/event_category DEFAULT 'E'
        !i_event_category2 TYPE /thkr/event_category2 DEFAULT ''
        !i_mess            TYPE /thkr/mess OPTIONAL
        !i_amnt            TYPE /thkr/amnt OPTIONAL
        !i_waers           TYPE waers OPTIONAL
        !i_event_date      TYPE /thkr/event_date OPTIONAL
        !i_exception       TYPE REF TO cx_root OPTIONAL
        !it_mapping        TYPE /thkr/t_gi_mapping_line OPTIONAL
        !it_ln_evt         TYPE /thkr/t_ln_evt OPTIONAL
        !i_ln_art          TYPE /thkr/event_ln_art OPTIONAL
        !i_ln_key          TYPE /thkr/event_ln_key OPTIONAL
        !i_date            TYPE dats OPTIONAL
        !i_time            TYPE tims OPTIONAL
        !i_cr_user         TYPE /thkr/cr_user OPTIONAL .
    METHODS constructor
      IMPORTING
        !i_process_type TYPE /thkr/process_type
        !i_process_id   TYPE /thkr/process_id OPTIONAL
        !i_save_proc    TYPE xfeld DEFAULT ' ' .
    METHODS read .
    METHODS save .
    METHODS save_events
      IMPORTING
        !i_delete_saved_events TYPE xfeld DEFAULT '' .
protected section.

  data DEF type ref to /THKR/CL_EXT_IF_DEF .
  data SAVE_PROC type XFELD .
  data MAX_ID type /THKR/PROCESS_ID .
  data LSA_DEF type ref to /THKR/CL_DEF .
  data HELPERS type ref to /THKR/CL_HELPERS .

  methods GET_NEW_EVENT_ID
    exporting
      !E_EVENT_ID type /THKR/EVENT_ID .
  PRIVATE SECTION.

    DATA type_proc_data TYPE REF TO cl_abap_structdescr .

    METHODS add_event_1
      IMPORTING
        !i_event_category  TYPE /thkr/event_category DEFAULT 'E'
        !i_event_category2 TYPE /thkr/event_category2 DEFAULT ''
        !i_mess            TYPE /thkr/mess OPTIONAL
        !i_oerror          TYPE REF TO cx_root OPTIONAL
        !i_amnt            TYPE /thkr/amnt OPTIONAL
        !i_waers           TYPE waers OPTIONAL
        !i_event_date      TYPE /thkr/event_date OPTIONAL
        !it_mapping        TYPE /thkr/t_gi_mapping_line OPTIONAL
        !it_ln_evt         TYPE /thkr/t_ln_evt OPTIONAL
        !i_ln_art          TYPE /thkr/event_ln_art OPTIONAL
        !i_ln_key          TYPE /thkr/event_ln_key OPTIONAL
        !i_date            TYPE dats OPTIONAL
        !i_time            TYPE tims OPTIONAL
        !i_cr_user         TYPE /thkr/cr_user OPTIONAL .
    METHODS save_exception
      IMPORTING
        !i_event_id TYPE /thkr/event_id
        !i_oerror   TYPE REF TO cx_root .
    METHODS save_mapping
      IMPORTING
        !i_event_id TYPE /thkr/event_id
        !it_mapping TYPE /thkr/t_gi_mapping_line .
ENDCLASS.



CLASS /THKR/CL_BFW_PROCESS IMPLEMENTATION.


  METHOD add_event.

    DATA: l_event_wa  LIKE LINE OF t_event,
          l_ln_evt    TYPE /thkr/s_ln_evt,
          l_mess      TYPE /thkr/mess,
          l_exception TYPE REF TO cx_root,
          l_oerror    TYPE REF TO cx_root,
          l_amnt      TYPE /thkr/amnt.

    IF i_event_category = 'E'.
      attr_process-flag_error = 'X'.
    ENDIF.

    IF i_event_category = 'W'.
      attr_process-flag_warning = 'X'.
    ENDIF.

    IF i_exception IS NOT INITIAL.
      l_exception = i_exception.
      l_oerror    = i_exception.
      l_amnt      = i_amnt.
      WHILE l_exception IS NOT INITIAL.

        l_mess = l_exception->get_text( ).

        IF l_mess IS NOT INITIAL.

          add_event_1(
            i_event_category  = i_event_category
            i_event_category2 = i_event_category2
            i_mess            = l_mess
            i_oerror          = l_oerror
            i_amnt            = l_amnt
            it_ln_evt         = it_ln_evt
            i_ln_art          = i_ln_art
            i_ln_key          = i_ln_key
            i_cr_user         = i_cr_user ).

        ENDIF.
        CLEAR: l_amnt, l_oerror.

        "mögliche Endlosschleife vermeiden
        "Wenn die beiden Exceptions gleich sind, wird logischersweise
        "das Abbruchbedingung der WHILE-Schleife nicht erreicht.
        IF l_exception NE l_exception->previous.
          l_exception = l_exception->previous.
        ELSE.
          EXIT. "While verlassen
        ENDIF.

      ENDWHILE.

    ELSE.

      add_event_1(
        i_event_category  = i_event_category
        i_event_category2 = i_event_category2
        i_mess            = i_mess
        i_amnt            = i_amnt
        i_waers           = i_waers
        i_event_date      = i_event_date
        it_mapping        = it_mapping
        it_ln_evt         = it_ln_evt
        i_ln_art          = i_ln_art
        i_ln_key          = i_ln_key
        i_date            = i_date
        i_time            = i_time
        i_cr_user         = i_cr_user ).

    ENDIF.




  ENDMETHOD.


  METHOD add_event_1.

    DATA: l_event_wa LIKE LINE OF t_event,
          l_ln_evt   TYPE /thkr/s_ln_evt.

    l_event_wa-mess = i_mess.

    max_id = max_id + 1.

    l_event_wa-id              = max_id.
    l_event_wa-event_category  = i_event_category.
    l_event_wa-event_category2 = i_event_category2.
    l_event_wa-process_type    = process_type.
    l_event_wa-process_id      = process_id.
    l_event_wa-oerror          = i_oerror.
    l_event_wa-t_mapping       = it_mapping.

    IF i_amnt IS NOT INITIAL.
      l_event_wa-amnt  = i_amnt.
      l_event_wa-waers = i_waers.
    ENDIF.

    IF i_event_date IS NOT INITIAL.
      l_event_wa-event_date = i_event_date.
    ELSE.
      l_event_wa-event_date = sy-datum.
    ENDIF.

    IF i_date IS NOT INITIAL.
      IF i_time IS NOT INITIAL.
        CONVERT DATE i_date TIME i_time
            INTO TIME STAMP l_event_wa-cr_time_stamp TIME ZONE sy-zonlo.
      ELSE.
        CONVERT DATE i_date
            INTO TIME STAMP l_event_wa-cr_time_stamp TIME ZONE sy-zonlo.
      ENDIF.
    ELSE.
      GET TIME STAMP FIELD l_event_wa-cr_time_stamp.
    ENDIF.

    IF i_cr_user IS NOT INITIAL.
      l_event_wa-cr_user = i_cr_user.
    ELSE.
      l_event_wa-cr_user = sy-uname.
    ENDIF.

    l_event_wa-is_new = 'X'.

    IF it_ln_evt IS NOT INITIAL.
*   Tabelle mit Verknüpfungen übergeben
      l_event_wa-t_ln_evt = it_ln_evt.

    ELSEIF i_ln_art IS NOT INITIAL.
*   Einzelne Verknüpfung übergeben

      ASSERT i_ln_key IS NOT INITIAL.
      l_ln_evt-ln_art = i_ln_art.
      l_ln_evt-ln_key = i_ln_key.
      APPEND l_ln_evt TO l_event_wa-t_ln_evt.

    ENDIF.

    APPEND l_event_wa TO t_event.

  ENDMETHOD.


  METHOD constructor.

    process_type   = i_process_type.

    IF i_process_id IS INITIAL.
      process_id = 0.
      GET TIME STAMP FIELD attr_process-cr_time_stamp.

      attr_process-cr_user = sy-uname.
      save_proc            = i_save_proc.
    ELSE.
      process_id = i_process_id.
      save_proc  = 'X'.
    ENDIF.

    lsa_def = /thkr/cl_def=>get_lsa_def( ).
    helpers = /thkr/cl_helpers=>get_instance( ).

  ENDMETHOD.


  METHOD get_new_event_id.

    CLEAR e_event_id.


    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '00'
        object                  = '/THKR/EVT'
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


  METHOD read.

    DATA: l_process_wa TYPE /thkr/process.

    SELECT SINGLE *
    FROM   /thkr/process INTO CORRESPONDING FIELDS OF l_process_wa
    WHERE  process_type = process_type
    AND    process_id  = process_id.

    ASSERT sy-subrc = 0.

    MOVE-CORRESPONDING l_process_wa TO attr_process.

    CLEAR t_event.

    SELECT *
    FROM   /thkr/event INTO CORRESPONDING FIELDS OF TABLE t_event
    WHERE process_type = process_type
    AND   process_id  = process_id.


  ENDMETHOD.


  METHOD save.

    DATA: l_proc_wa TYPE /thkr/process,
          l_dummy   TYPE c.

    IF save_proc = 'X'.
*   Nur wenn Daten des Verarbeitungsprozesses gespeichert werden sollen
*   Den Prozess speichern

      IF process_id = 0.
*     Hinweis: Wurde der Prozess aus der DB gelesen, ist PROCESS_ID nicht 0
        SELECT MAX( process_id )
        FROM   /thkr/process INTO process_id
        WHERE  process_type = process_type.

        process_id = process_id + 1.

*     Datensatz erstmalig einfügen um Referenzen zu ermöglichen
        MOVE-CORRESPONDING attr_process TO l_proc_wa.
        l_proc_wa-process_type = process_type.
        l_proc_wa-process_id  = process_id.
        INSERT /thkr/process FROM l_proc_wa.

      ENDIF.

    ENDIF.

* Meldungen bearbeiten

    save_events( ).

    IF save_proc = 'X'.
*   Wenn Daten des Verarbeitungsprozesses gespeichert werden sollen

*   Flags neu ermitteln
      CLEAR attr_process-flag_error.
      CLEAR attr_process-flag_warning.

      SELECT SINGLE event_category INTO l_dummy
      FROM /thkr/event
      WHERE process_type    = process_type
      AND   process_id     = process_id
      AND   event_category = 'E'.
      IF sy-subrc = 0.
        attr_process-flag_error = 'X'.
      ENDIF.

      SELECT SINGLE event_category INTO l_dummy
      FROM /thkr/event
      WHERE process_type    = process_type
      AND   process_id     = process_id
      AND   event_category = 'W'.
      IF sy-subrc = 0.
        attr_process-flag_warning = 'X'.
      ENDIF.

      MOVE-CORRESPONDING attr_process TO l_proc_wa.
      l_proc_wa-process_type = process_type.
      l_proc_wa-process_id  = process_id.

      MODIFY /thkr/process FROM l_proc_wa.
    ENDIF.

  ENDMETHOD.


  METHOD save_events.

    DATA: l_event_wa  TYPE /thkr/event,
          l_ln_evt_wa TYPE /thkr/ln_evt,
          l_ln_evt    TYPE /thkr/s_ln_evt.

    FIELD-SYMBOLS: <event> LIKE LINE OF t_event.

* Meldungen nach der Entstehungsreihenfolge sortieren
    SORT t_event BY id.

* Meldungen bearbeiten

* Meldungen speichern
    LOOP AT t_event ASSIGNING <event>
    WHERE is_new IS NOT INITIAL OR is_deleted IS NOT INITIAL.

      IF <event>-is_deleted IS NOT INITIAL.
*     Meldung ist als 'zu löschen' gekennzeichnet

        DELETE FROM /thkr/event
        WHERE  id = <event>-id.

        DELETE FROM /thkr/ln_evt
        WHERE  id = <event>-id.

        DELETE FROM /thkr/evt_blob
        WHERE id = <event>-id.

        DELETE t_event.

      ELSE.

        IF <event>-is_new IS NOT INITIAL.

          IF <event>-event_category2 = lsa_def->event_category_trace.
*           Es handelt sich um eine Log-Meldung für die Fehlersuche
            IF lsa_def->testmode_is_set( i_flag = lsa_def->tmbin_trace ) IS INITIAL.
*             Solche Meldungen sollen nicht geschrieben werden
              DELETE t_event.
              CONTINUE.

            ENDIF.
          ENDIF.

          IF <event>-event_category = 'T'.  "Transient
            CONTINUE.
          ENDIF.

          get_new_event_id(
            IMPORTING
              e_event_id = <event>-id ).

          <event>-process_id  = process_id.
          <event>-process_type = process_type.

          MOVE-CORRESPONDING <event> TO l_event_wa.

          INSERT /thkr/event FROM l_event_wa.
          ASSERT sy-subrc = 0.

          l_ln_evt_wa-id = <event>-id.

          LOOP AT <event>-t_ln_evt INTO l_ln_evt.
            MOVE-CORRESPONDING l_ln_evt TO l_ln_evt_wa.
            INSERT /thkr/ln_evt FROM l_ln_evt_wa.
            ASSERT sy-subrc = 0.
          ENDLOOP.

          IF <event>-oerror IS NOT INITIAL.
            "Exception persistieren
            save_exception(
              EXPORTING
                i_event_id = <event>-id
                i_oerror   = <event>-oerror ).
          ELSEIF <event>-t_mapping IS NOT INITIAL.
            "Mapping persistieren
            save_mapping(
              EXPORTING
                i_event_id = <event>-id
                it_mapping = <event>-t_mapping ).

          ENDIF.

          IF i_delete_saved_events IS INITIAL.
            CLEAR <event>-is_new.
          ELSE.
            DELETE t_event.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD save_exception.

    DATA: l_xmlstr   TYPE xstring,
          l_evt_blob TYPE /thkr/evt_blob.

    CALL TRANSFORMATION id
      SOURCE error = i_oerror
      RESULT XML l_xmlstr.

    helpers->compress_xstring(
     EXPORTING
       i_xstring = l_xmlstr
     IMPORTING
       et_x255   = DATA(lt_x255) ).

    l_evt_blob-id = i_event_id.

    LOOP AT lt_x255 INTO l_evt_blob-x255.
      ADD 1 TO l_evt_blob-lfd_nr.
      INSERT /thkr/evt_blob FROM l_evt_blob.
    ENDLOOP.

  ENDMETHOD.


  METHOD save_mapping.

    DATA: l_xmlstr   TYPE xstring,
          l_evt_blob TYPE /thkr/evt_blob.

    CALL TRANSFORMATION id
      SOURCE mapping = it_mapping
      RESULT XML l_xmlstr.

    helpers->compress_xstring(
     EXPORTING
       i_xstring = l_xmlstr
     IMPORTING
       et_x255   = DATA(lt_x255) ).

    l_evt_blob-id = i_event_id.

    LOOP AT lt_x255 INTO l_evt_blob-x255.
      ADD 1 TO l_evt_blob-lfd_nr.
      INSERT /thkr/evt_blob FROM l_evt_blob.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
