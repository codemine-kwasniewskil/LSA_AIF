*&---------------------------------------------------------------------*
*& Report /THKR/EXT_IF_EXPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/ext_if_export.
*
*TABLES: sscrfields, bkpf.
*
*DATA: g_frontend  TYPE xfeld,
*      g_file      TYPE /thkr/file_w_path,
*      l_selection TYPE /thkr/s_fi_document_selection.
*
*SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001.
*  PARAMETERS: p_type TYPE /thkr/process_type_de_e AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND uc1 OBLIGATORY DEFAULT 'IR_E',
*              p_frvf TYPE /thkr/cfv-fremdverf OBLIGATORY.
*
*SELECTION-SCREEN END OF BLOCK 001.
*
*SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE TEXT-002. "TEXT-002 Selektion gebuchter Finanzbuchhaltungsbelege
*  SELECT-OPTIONS: s_bukrs FOR bkpf-bukrs.
*
*SELECTION-SCREEN END OF BLOCK 002.
*SELECTION-SCREEN BEGIN OF BLOCK 003 WITH FRAME TITLE TEXT-003.  "Selektion für Testzwecke
*  PARAMETERS:     p_gjahr TYPE gjahr MODIF ID d2.
*  SELECT-OPTIONS: s_belnr FOR bkpf-belnr MODIF ID d2,
*                  s_blart FOR bkpf-blart MODIF ID d2,
*                  s_cpudt FOR bkpf-cpudt MODIF ID d2.
*  SELECTION-SCREEN SKIP.
**  PARAMETERS: p_extype TYPE zjva_process_type_ec AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND uc1 MODIF ID d2,
**              p_test   TYPE xfeld MODIF ID d2 USER-COMMAND uc1,
**              p_testr  TYPE xfeld MODIF ID d3.
*SELECTION-SCREEN END OF BLOCK 003.
*
*SELECTION-SCREEN BEGIN OF BLOCK 004 WITH FRAME TITLE TEXT-004.
*  PARAMETERS: p_tfile TYPE pathextern LOWER CASE.
*  SELECTION-SCREEN SKIP.
*  SELECTION-SCREEN SKIP.
*  PARAMETERS: p_test TYPE xfeld.
*SELECTION-SCREEN END OF BLOCK 004.
*
*START-OF-SELECTION.
**----------------------------------------------------------------------*
*  DATA: l_salv_inpdb TYPE REF TO /thkr/cl_salv_inpdb,
*        lrt_inpdb    TYPE REF TO /thkr/t_de_inpdb,
*        l_xmlstr     TYPE xstring.
*
*  DATA(def) = /thkr/cl_ext_if_def=>get_instance( ).
*
*  IF p_tfile IS INITIAL.
*    CLEAR: g_frontend, g_file.
*  ELSE.
*    g_file = p_tfile.
*    g_frontend = 'X'.
*  ENDIF.
*
*  l_selection-r_bukrs = s_bukrs[].
*  l_selection-gjahr = p_gjahr.
*  l_selection-r_belnr = s_belnr[].
*  l_selection-r_blart = s_blart[].
*  l_selection-r_cpudt = s_cpudt[].
*
*  /thkr/cl_ext_if_appl=>get_instance( )->process_export(
*      EXPORTING
*        i_process_type    = p_type
*        i_fremdverf       = p_frvf
*        i_filename        = g_file
*        i_frontend        = g_frontend
*        i_test            = p_test
*        i_fi_doc_selection =  l_selection ).
*
*  IF p_test IS NOT INITIAL.
*
*    TRY.
*
*        /thkr/cl_ext_if_appl=>get_instance( )->get_xml_data_by_run(
*          EXPORTING
*            i_process_type = p_type
*            i_process_id   = def->c_process_id-current_process
*          IMPORTING
*            e_xmlstr       = l_xmlstr ).
*
*        CALL FUNCTION 'DISPLAY_XML_STRING'
*          EXPORTING
*            xml_string = l_xmlstr.
*
*      CATCH cx_root INTO DATA(l_oerror).
*
*        /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
*
*    ENDTRY.
*  ENDIF.
