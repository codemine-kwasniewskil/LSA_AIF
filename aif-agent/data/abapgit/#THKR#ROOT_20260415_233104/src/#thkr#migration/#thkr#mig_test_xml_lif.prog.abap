*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_LIF
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/MIG_TEST_XML_LIF.

DATA: lt_lif  TYPE /thkr/t_mig_lif,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_lif.
APPEND INITIAL LINE TO lt_lif.

CALL TRANSFORMATION id
  SOURCE table = lt_lif
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
