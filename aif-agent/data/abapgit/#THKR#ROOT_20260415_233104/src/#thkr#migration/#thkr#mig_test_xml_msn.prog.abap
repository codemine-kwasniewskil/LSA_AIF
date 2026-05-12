*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XSLT_MSN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_test_xml_msn.

DATA: lt_msn   TYPE /THKR/T_MIG_FIPO_MSN,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_msn.
APPEND INITIAL LINE TO lt_msn.

CALL TRANSFORMATION id
  SOURCE table = lt_msn
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
