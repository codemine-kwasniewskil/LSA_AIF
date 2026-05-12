CLASS /thkr/cl_gi_shm_buffer DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_gi_shm_buffer_base
  FINAL
  CREATE PUBLIC
  SHARED MEMORY ENABLED .

  PUBLIC SECTION.

    INTERFACES if_shm_build_instance .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_GI_SHM_BUFFER IMPLEMENTATION.


  METHOD if_shm_build_instance~build.

    DATA:
      my_handle TYPE REF TO /thkr/cl_gi_shm,
      my_data   TYPE REF TO /thkr/cl_gi_shm_buffer,
      my_except TYPE REF TO cx_root.

    TRY.
        my_handle = /thkr/cl_gi_shm=>attach_for_write( inst_name ).
      CATCH cx_shm_error INTO my_except.
        RAISE EXCEPTION TYPE cx_shm_build_failed
          EXPORTING
            previous = my_except.
    ENDTRY.

    CREATE OBJECT my_data AREA HANDLE my_handle.
    my_handle->set_root( my_data ).

    ... " code to build the area instance

    TRY.
        my_handle->detach_commit( ).
      CATCH cx_shm_error INTO my_except.
        RAISE EXCEPTION TYPE cx_shm_build_failed
          EXPORTING
            previous = my_except.
    ENDTRY.

    IF invocation_mode = cl_shm_area=>invocation_mode_auto_build.
      CALL FUNCTION 'DB_COMMIT'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
