*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XSLT_TIT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/MIG_TEST_XSLT_TIT.

TYPES lty_result TYPE x LENGTH 1024.

DATA: lt_result    TYPE STANDARD TABLE OF lty_result,
      l_file       TYPE /thkr/file_w_path,
      l_cstring    TYPE string,
      lt_fipo  TYPE /THKR/T_MIG_FIPO,
      l_xml_string TYPE xstring.


l_file = 'C:\XML\TIT_test.xml'.

cl_gui_frontend_services=>gui_upload(
  EXPORTING
    filename = CONV #( l_file )
    filetype = 'BIN'
  CHANGING
    data_tab = lt_result ).

LOOP AT lt_result INTO DATA(l_result).
  CONCATENATE l_xml_string l_result INTO l_xml_string IN BYTE MODE.
ENDLOOP.

TRY.


    CALL TRANSFORMATION /thkr/tit_to_abap
      SOURCE XML l_xml_string
      RESULT table = lt_fipo.


  CATCH cx_root INTO DATA(l_oerror).
    /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

ENDTRY.

CLEAR lt_fipo.
