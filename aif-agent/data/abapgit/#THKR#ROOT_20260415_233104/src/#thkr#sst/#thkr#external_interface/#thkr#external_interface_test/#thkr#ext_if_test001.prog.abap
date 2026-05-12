*&---------------------------------------------------------------------*
*& Report /THKR/EXT_IF_TEST001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/ext_if_test001.

DATA: l_ao_file TYPE /thkr/s_de_file,
      l_xmlstr  TYPE xstring.

FIELD-SYMBOLS: <t_beleg>    TYPE STANDARD TABLE,
               <t_position> TYPE STANDARD TABLE.

get TIME STAMP FIELD l_ao_file-cr_time_stamp.

APPEND INITIAL LINE TO l_ao_file-t_ao ASSIGNING FIELD-SYMBOL(<ao>).
APPEND INITIAL LINE TO <ao>-t_beleg ASSIGNING FIELD-SYMBOL(<beleg>).
APPEND INITIAL LINE TO <beleg>-gp-t_bankverb ASSIGNING FIELD-SYMBOL(<bankverb>).
APPEND <bankverb> TO <beleg>-gp-t_bankverb.
APPEND INITIAL LINE TO <beleg>-t_zeile ASSIGNING FIELD-SYMBOL(<zeile>).
APPEND <zeile> TO <beleg>-t_zeile.
APPEND <beleg> TO <ao>-t_beleg.
APPEND <ao> TO l_ao_file-t_ao.

CALL TRANSFORMATION id
  SOURCE file = l_ao_file
  RESULT XML l_xmlstr.

CALL FUNCTION 'DISPLAY_XML_STRING'
  EXPORTING
    xml_string = l_xmlstr.


TRY.
    CALL TRANSFORMATION /thkr/abap_to_lsa_ao
      SOURCE file = l_ao_file
      RESULT XML l_xmlstr.

    CALL FUNCTION 'DISPLAY_XML_STRING'
      EXPORTING
        xml_string = l_xmlstr.

  CATCH cx_root INTO DATA(l_oerror).
    /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

ENDTRY.
