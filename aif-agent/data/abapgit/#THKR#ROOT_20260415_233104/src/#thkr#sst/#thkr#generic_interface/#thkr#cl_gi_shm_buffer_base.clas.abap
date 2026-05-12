CLASS /thkr/cl_gi_shm_buffer_base DEFINITION
  PUBLIC
  ABSTRACT
  CREATE PUBLIC
  SHARED MEMORY ENABLED .

  PUBLIC SECTION.

    METHODS get_entry_from_buffer
      IMPORTING
        !i_gi_id      TYPE /thkr/gi_id
        !i_para       TYPE data
      CHANGING
        !c_data       TYPE data
      RETURNING
        VALUE(retval) TYPE i .
    METHODS new_entry_start
      IMPORTING
        !i_gi_id      TYPE /thkr/gi_id
        VALUE(i_para) TYPE data .
    METHODS put_entry_to_buffer
      IMPORTING
        !i_gi_id      TYPE /thkr/gi_id
        VALUE(i_para) TYPE data
        VALUE(i_data) TYPE data .
    METHODS remove_entry_from_buffer
      IMPORTING
        !i_gi_id      TYPE /thkr/gi_id
        !i_para       TYPE data
      RETURNING
        VALUE(retval) TYPE i .
  PROTECTED SECTION.

    DATA t_buffer TYPE /thkr/t_gi_shm_buffer .
    DATA timeout_buffer_update TYPE i VALUE 300 ##NO_TEXT.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_GI_SHM_BUFFER_BASE IMPLEMENTATION.


  METHOD get_entry_from_buffer.
*   Die für eine Schnittstelle ermittelten Daten werden in den SHM-Puffer geschrieben

    DATA: l_para      TYPE xstring,
          l_hash      TYPE xstring,
          l_timestamp TYPE timestamp,
          l_seconds   TYPE i,
          l_helpers   TYPE REF TO /thkr/cl_helpers.

    FIELD-SYMBOLS: <buffer> LIKE LINE OF t_buffer,
                   <line>   TYPE /thkr/s_gi_shm_buffer_line,
                   <data>   TYPE data.

*   Um später sicherzustellen, dass nur identische Aufrufe gepuffert werden, wird der HASH
*   der Eingabeparameter bestimmt und mit dem zu den gepufferten Daten abgelegten HASH verglichen
    CALL TRANSFORMATION id
      SOURCE para = i_para
      RESULT XML l_para.

    TRY.
        cl_abap_message_digest=>calculate_hash_for_raw(
          EXPORTING
*           if_algorithm     = 'SHA1'
            if_data          = l_para
*           if_length        = 0
          IMPORTING
            ef_hashxstring   = l_hash ).

      CATCH cx_abap_message_digest .
    ENDTRY.

    READ TABLE t_buffer WITH TABLE KEY gi_id = i_gi_id hash = l_hash ASSIGNING <line>.

    IF sy-subrc = 0.
      IF <line>-content IS NOT INITIAL.
        CALL TRANSFORMATION id
          SOURCE XML <line>-content
          RESULT data = c_data.
      ELSE.
*        DATA I_TIMESTAMP TYPE TIMESTAMP.
*        DATA E_SECONDS   TYPE ZBAU_SECONDS.
*        DATA R_SECONDS   TYPE ZBAU_SECONDS.

        IF <line>-update_started IS NOT INITIAL.
          GET TIME STAMP FIELD l_timestamp.
          l_helpers = /thkr/cl_helpers=>get_instance( ).

          l_seconds = l_helpers->get_seconds_of_day( l_timestamp ) - l_helpers->get_seconds_of_day( <line>-update_started ).
          IF l_seconds > timeout_buffer_update.
*            DELETE TABLE t_buffer WITH TABLE KEY if_id = i_if_id hash = l_hash.
            retval = -3.  "Update Timeout
          ELSE.
            retval = -2.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      retval = -1.
    ENDIF.

  ENDMETHOD.


  METHOD new_entry_start.
*   Die für eine Schnittstelle ermittelten Daten werden in den SHM-Puffer geschrieben

    DATA: l_line TYPE /thkr/s_gi_shm_buffer_line.

    l_line-gi_id = i_gi_id.

*   Um später sicherzustellen, dass nur identische Aufrufe gepuffert werden, wird der HASH
*   der Eingabeparameter bestimmt und mit den Daten abgelegt
    CALL TRANSFORMATION id
      SOURCE para = i_para
      RESULT XML l_line-para.

    TRY.
        cl_abap_message_digest=>calculate_hash_for_raw(
          EXPORTING
*           if_algorithm     = 'SHA1'
            if_data          = l_line-para
*           if_length        = 0
          IMPORTING
            ef_hashxstring   = l_line-hash ).

      CATCH cx_abap_message_digest .
    ENDTRY.

*   Ggf. vorhandene Puffereinträge (gleiche Schnittstelle, gleiche Parameter) löschen
    DELETE TABLE t_buffer WITH TABLE KEY gi_id = i_gi_id hash = l_line-hash.

    GET TIME STAMP FIELD l_line-update_started.

    APPEND l_line TO t_buffer.

  ENDMETHOD.


  METHOD put_entry_to_buffer.
*   Die für eine Schnittstelle ermittelten Daten werden in den SHM-Puffer geschrieben

    DATA: l_line TYPE /thkr/s_gi_shm_buffer_line.

    l_line-gi_id = i_gi_id.

*   Um später sicherzustellen, dass nur identische Aufrufe gepuffert werden, wird der HASH
*   der Eingabeparameter bestimmt und mit den Daten abgelegt
    CALL TRANSFORMATION id
      SOURCE para = i_para
      RESULT XML l_line-para.

    TRY.
        cl_abap_message_digest=>calculate_hash_for_raw(
          EXPORTING
*           if_algorithm     = 'SHA1'
            if_data          = l_line-para
*           if_length        = 0
          IMPORTING
            ef_hashxstring   = l_line-hash ).

      CATCH cx_abap_message_digest .
    ENDTRY.

*   Ggf. vorhandene Puffereinträge (gleiche Schnittstelle, gleiche Parameter) löschen
    DELETE TABLE t_buffer WITH TABLE KEY gi_id = i_gi_id hash = l_line-hash.

*   Daten als XML-Stream in den Puffer schreiben
    CALL TRANSFORMATION id
      SOURCE data = i_data
      RESULT XML l_line-content.

    APPEND l_line TO t_buffer.

  ENDMETHOD.


  METHOD remove_entry_from_buffer.
*   Die für eine Schnittstelle ermittelten Daten werden in den SHM-Puffer geschrieben

    DATA: l_para TYPE xstring,
          l_hash TYPE xstring.

*   Um später sicherzustellen, dass nur identische Aufrufe gepuffert werden, wird der HASH
*   der Eingabeparameter bestimmt und mit dem zu den gepufferten Daten abgelegten HASH verglichen
    CALL TRANSFORMATION id
      SOURCE para = i_para
      RESULT XML l_para.

    TRY.
        cl_abap_message_digest=>calculate_hash_for_raw(
          EXPORTING
*           if_algorithm     = 'SHA1'
            if_data          = l_para
*           if_length        = 0
          IMPORTING
            ef_hashxstring   = l_hash ).

      CATCH cx_abap_message_digest .
    ENDTRY.

    DELETE TABLE t_buffer WITH TABLE KEY gi_id = i_gi_id hash = l_hash.

  ENDMETHOD.
ENDCLASS.
