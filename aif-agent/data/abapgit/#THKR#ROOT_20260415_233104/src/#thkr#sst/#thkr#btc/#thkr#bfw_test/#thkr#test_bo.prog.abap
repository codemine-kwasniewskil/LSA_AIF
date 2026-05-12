*&---------------------------------------------------------------------*
*& Report /THKR/TEST_BO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/test_bo.

PARAMETERS: p_obj_tp TYPE /thkr/object_type AS LISTBOX VISIBLE LENGTH 30,
            p_obj_id TYPE /thkr/object_id.

START-OF-SELECTION.
  DATA: l_selection TYPE /thkr/s_dto_selection,
        l_salv      TYPE REF TO /thkr/cl_test_salv_dtos.

  l_selection-object_type = p_obj_tp.
  l_selection-object_id   = p_obj_id.

  CREATE OBJECT l_salv.

  TRY.
      l_salv->display(
        EXPORTING
          i_selection = l_selection ).

    CATCH cx_root INTO DATA(l_oerror).

      /thkr/cl_helpers=>get_instance( )->display_exception( i_oerror = l_oerror ).

  ENDTRY.
