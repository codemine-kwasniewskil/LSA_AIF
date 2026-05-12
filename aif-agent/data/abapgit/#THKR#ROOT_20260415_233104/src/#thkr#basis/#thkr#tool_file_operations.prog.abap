*&---------------------------------------------------------------------*
*& Report /THKR/TOOL_FILE_MOVE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE /thkr/tool_file_operations_top.             " Global Data
INCLUDE /thkr/tool_file_operations_lcl.             " Local Classes

INITIALIZATION.
  lcl_appl=>get_initial_values( ).

AT SELECTION-SCREEN OUTPUT.
  lcl_appl=>at_selection_screen_output( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path_s.
  lcl_appl=>f4_filename( CHANGING cv_filename = p_path_s ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path_d.
  lcl_appl=>f4_filename( CHANGING cv_filename = p_path_d ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path_z.
  lcl_appl=>f4_filename( CHANGING cv_filename = p_path_z ).

START-OF-SELECTION.
  lcl_appl=>process( ).
