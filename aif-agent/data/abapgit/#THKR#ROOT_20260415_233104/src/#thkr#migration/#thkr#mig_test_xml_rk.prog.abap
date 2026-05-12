*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_test_xml_rk.

DATA: l_mig_file TYPE /thkr/s_mig_rk_file,
      l_xmlstr   TYPE xstring.

APPEND INITIAL LINE TO l_mig_file-tdto_rk ASSIGNING FIELD-SYMBOL(<dto_file>).
APPEND INITIAL LINE TO <dto_file>-t_rk_faell ASSIGNING FIELD-SYMBOL(<dto_file_faell>).
APPEND INITIAL LINE TO <dto_file_faell>-t_rk_Pos ASSIGNING FIELD-SYMBOL(<dto_file_Ist_Soll>).
APPEND INITIAL LINE TO <dto_file_Ist_Soll>-t_rk_sol_ist.


APPEND <dto_file> TO l_mig_file-tdto_rk.

CALL TRANSFORMATION id
  SOURCE file = l_mig_file
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
