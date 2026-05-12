*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XML_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_test_xml_01.

DATA: l_mig_ao_file TYPE /thkr/s_mig_ao_file,
      l_xmlstr      TYPE xstring.

APPEND INITIAL LINE TO l_mig_ao_file-tdto_ao ASSIGNING FIELD-SYMBOL(<dto_ao>).
APPEND INITIAL LINE TO <dto_ao>-t_split.
APPEND INITIAL LINE TO <dto_ao>-t_split.
APPEND INITIAL LINE TO <dto_ao>-t_rate.
APPEND INITIAL LINE TO <dto_ao>-t_rate.
APPEND INITIAL LINE TO <dto_ao>-t_svz.
APPEND INITIAL LINE TO <dto_ao>-t_svz.

APPEND <dto_ao> TO l_mig_ao_file-tdto_ao.

CALL TRANSFORMATION id
  SOURCE file = l_mig_ao_file
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.
