*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_RKV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/MIG_TEST_XML_RKV.

DATA: lt_rkv   TYPE /thkr/t_mig_rkv,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_rkv.
APPEND INITIAL LINE TO lt_rkv.

CALL TRANSFORMATION id
  SOURCE table = lt_rkv
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
