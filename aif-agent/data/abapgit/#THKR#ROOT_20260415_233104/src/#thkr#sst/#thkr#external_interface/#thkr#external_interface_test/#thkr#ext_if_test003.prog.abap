*&---------------------------------------------------------------------*
*& Report /THKR/EXT_IF_TEST001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/ext_if_test003.
*
*DATA: l_hvw_file TYPE /thkr/s_de_hvw_file,
*      l_xmlstr   TYPE xstring.
*
*FIELD-SYMBOLS: <t_beleg>    TYPE STANDARD TABLE,
*               <t_position> TYPE STANDARD TABLE.
*
*APPEND INITIAL LINE TO l_hvw_file-t_funktion.
*APPEND INITIAL LINE TO l_hvw_file-t_funktion.
*
*APPEND INITIAL LINE TO l_hvw_file-t_gruppe.
*APPEND INITIAL LINE TO l_hvw_file-t_gruppe.
*
*APPEND INITIAL LINE TO l_hvw_file-t_einzelplan ASSIGNING FIELD-SYMBOL(<ep>).
*APPEND INITIAL LINE TO <ep>-t_kapitel ASSIGNING FIELD-SYMBOL(<kap>).
*APPEND INITIAL LINE TO <kap>-t_vermerk.
*APPEND INITIAL LINE TO <kap>-t_titel_gr ASSIGNING FIELD-SYMBOL(<tgr>).
*APPEND INITIAL LINE TO <tgr>-t_vermerk.
*APPEND INITIAL LINE TO <tgr>-t_vermerk.
*APPEND INITIAL LINE TO <tgr>-t_titel ASSIGNING FIELD-SYMBOL(<titel>).
*APPEND INITIAL LINE TO <titel>-t_ansatz.
*APPEND INITIAL LINE TO <titel>-t_ansatz.
*APPEND INITIAL LINE TO <titel>-t_ve.
*APPEND INITIAL LINE TO <titel>-t_ve.
*
*CALL TRANSFORMATION id
*  SOURCE file = l_hvw_file
*  RESULT XML l_xmlstr.
*
*CALL FUNCTION 'DISPLAY_XML_STRING'
*  EXPORTING
*    xml_string = l_xmlstr.
