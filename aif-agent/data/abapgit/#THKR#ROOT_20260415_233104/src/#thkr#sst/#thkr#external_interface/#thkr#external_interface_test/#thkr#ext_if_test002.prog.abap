*&---------------------------------------------------------------------*
*& Report /THKR/EXT_IF_TEST001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/ext_if_test002.

TYPES lty_result TYPE x LENGTH 1024.

TYPES: BEGIN OF lty_param,
         beleg TYPE REF TO data,
       END OF lty_param.

DATA: lt_result   TYPE STANDARD TABLE OF lty_result,
      l_file      TYPE string,
      l_ao_file   TYPE REF TO data,
      l_xmlstr    TYPE xstring,
      l_param     TYPE lty_param,
      l_ao_create TYPE /thkr/s_dto_psm_ao_create.

FIELD-SYMBOLS: <t_beleg>    TYPE STANDARD TABLE.

l_file = 'C:\XML\LSA_Anordnungen.xml'.

cl_gui_frontend_services=>gui_upload(
  EXPORTING
    filename = l_file
    filetype = 'BIN'
  CHANGING
    data_tab = lt_result ).

LOOP AT lt_result INTO DATA(l_result).
  CONCATENATE l_xmlstr l_result INTO l_xmlstr IN BYTE MODE.
ENDLOOP.

/thkr/cl_gi_appl=>get_instance( )->get_record_type_handles(
  EXPORTING
    i_record_id = 'AO_FILE'
  IMPORTING
    e_struct_descr       = DATA(l_sd_ao_file) ).

CREATE DATA l_ao_file TYPE HANDLE l_sd_ao_file.

ASSIGN l_ao_file->* TO FIELD-SYMBOL(<ao_file>).

TRY.
    CALL TRANSFORMATION /thkr/lsa_ao_to_abap
      SOURCE XML l_xmlstr
      RESULT file = <ao_file>.

  CATCH cx_root INTO DATA(l_oerror).
    /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

ENDTRY.

ASSIGN l_ao_file->('T_BELEG') TO <t_beleg>.

LOOP AT <t_beleg> REFERENCE INTO l_param-beleg.



ENDLOOP.
