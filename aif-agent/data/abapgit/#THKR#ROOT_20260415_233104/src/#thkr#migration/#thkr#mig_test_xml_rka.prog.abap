*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_RKA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/MIG_TEST_XML_RKA.

DATA: lt_rka  TYPE /thkr/t_mig_rka,
      l_xmlstr TYPE xstring.

APPEND INITIAL LINE TO lt_rka.
APPEND INITIAL LINE TO lt_rka.

CALL TRANSFORMATION id
  SOURCE table = lt_rka
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
