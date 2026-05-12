*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XSLT_TIT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_test_xml_vsa_svz.

DATA: lt_sva_svz TYPE /thkr/t_mig_vsa_svz,
      l_xmlstr   TYPE xstring.

APPEND INITIAL LINE TO lt_sva_svz.
APPEND INITIAL LINE TO lt_sva_svz.

CALL TRANSFORMATION id
  SOURCE Table = lt_sva_svz
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
