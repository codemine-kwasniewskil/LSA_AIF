*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_MVW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/MIG_TEST_XML_MVW.

DATA: lt_mvw  TYPE /thkr/t_mig_mvw,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_mvw.
APPEND INITIAL LINE TO lt_mvw.

CALL TRANSFORMATION id
  SOURCE table = lt_mvw
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
