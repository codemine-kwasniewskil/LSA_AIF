*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_RKN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_test_xml_rkn.

DATA: lt_rkn   TYPE /thkr/t_mig_rkn,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_rkn.
APPEND INITIAL LINE TO lt_rkn.

CALL TRANSFORMATION id
  SOURCE table = lt_rkn
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
