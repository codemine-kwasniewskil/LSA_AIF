*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XSLT_TIT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_test_xml_camt.

DATA: lt_fipo  TYPE /THKR/T_MIG_camt,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_fipo.
APPEND INITIAL LINE TO lt_fipo.

CALL TRANSFORMATION id
  SOURCE table = lt_fipo
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
