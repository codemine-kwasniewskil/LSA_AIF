*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_BORE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/MIG_TEST_XML_BORE.

DATA: lt_bore  TYPE /thkr/t_mig_bore,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_bore.
APPEND INITIAL LINE TO lt_bore.

CALL TRANSFORMATION id
  SOURCE table = lt_bore
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
