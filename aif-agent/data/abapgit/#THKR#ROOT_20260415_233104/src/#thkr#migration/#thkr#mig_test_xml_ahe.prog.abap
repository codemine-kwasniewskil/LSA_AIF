*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_AHE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/MIG_TEST_XML_AHE.

DATA: lt_ahe  TYPE /thkr/t_mig_ahe,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_ahe.
APPEND INITIAL LINE TO lt_ahe.

CALL TRANSFORMATION id
  SOURCE table = lt_ahe
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
