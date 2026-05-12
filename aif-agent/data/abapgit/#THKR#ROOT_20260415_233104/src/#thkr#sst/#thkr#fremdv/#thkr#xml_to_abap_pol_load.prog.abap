*&---------------------------------------------------------------------*
*& Report /THKR/XML_TO_ABAP_POL_LOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/xml_to_abap_pol_load.

DATA: lt_items      TYPE TABLE OF /thkr/s_de_pso_xml_item, "/thkr/tt_de_pso_xml,      " Assumes ty_item type is already defined
      lv_xml_string TYPE string,                " String for XML content
      lt_file_table TYPE filetable,             " Table for file selection dialog
      lv_rc         TYPE i,                     " Return code for file dialog
      lv_filename   TYPE string,                " File path
      lt_data_tab   TYPE TABLE OF string,       " Table for binary file lines
      lv_filelength TYPE i.                     " File length
DATA: ls_result     TYPE /thkr/s_de_pso_xml_file.

" Parameters for file path input
PARAMETERS: p_file TYPE rlgrap-filename DEFAULT 'C:\Users\A11311904\Desktop\Neuer Ordner\New Text Document (2).xml'.

" F4 help for file selection

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA: lv_default_file TYPE string VALUE 'C:\*.xml'.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Select XML File'
      default_extension       = 'xml'
      default_filename        = lv_default_file
      file_filter             = 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*'
      multiselection          = abap_false
    CHANGING
      file_table              = lt_file_table
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc = 0 AND lv_rc = 1.
    READ TABLE lt_file_table INTO lv_filename INDEX 1.
    IF sy-subrc = 0.
      p_file = lv_filename.
    ENDIF.
  ELSEIF sy-subrc <> 0.
    MESSAGE 'Error opening file selection dialog!' TYPE 'E' DISPLAY LIKE 'I'.
  ENDIF.

START-OF-SELECTION.
  " Set file path
  lv_filename = p_file.

  " Read file from presentation server in binary mode
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'  " Text file
    IMPORTING
      filelength              = lv_filelength
    CHANGING
      data_tab                = lt_data_tab
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE 'Error uploading file!'(003) TYPE 'E' DISPLAY LIKE 'I'.
    EXIT.
  ENDIF.

  LOOP AT lt_data_tab INTO DATA(lv_line).
    CONCATENATE lv_xml_string lv_line INTO lv_xml_string.
  ENDLOOP.
  " Check if file is empty
  IF lv_xml_string IS INITIAL.
    MESSAGE 'File is empty or data could not be read!'(004) TYPE 'E' DISPLAY LIKE 'I'.
    EXIT.
  ENDIF.

  " Diagnostic output: Display loaded XML string
  WRITE: / 'Loaded XML content: ', lv_xml_string.
  WRITE: / 'Length of XML string: ', strlen( lv_xml_string ).

*  TYPES: BEGIN OF ty_root_items,
*           item TYPE /thkr/s_de_pso_xml,
*         END OF ty_root_items.
*
*  TYPES: BEGIN OF ty_root_values,
*           values TYPE TABLE OF ty_root_items WITH DEFAULT KEY,
*         END OF ty_root_values.
*
*  DATA: lt_items2 TYPE ty_root_values.
*
*  " Apply XSLT transformation with error handling
*  TRY.
*      DATA: lv_result_xml TYPE string.
*      CALL TRANSFORMATION /thkr/sapxml_to_abap_pol_full
*        SOURCE XML lv_xml_string
*        RESULT XML lv_result_xml.
*
*      CALL TRANSFORMATION /thkr/sapxml_to_abap_pol_full
*        SOURCE XML lv_xml_string
*        RESULT values = lt_items.
*
*      DATA: lo_doc TYPE REF TO if_ixml_document.
*      lo_doc = cl_ixml=>create( )->create_document( ).
*      CALL TRANSFORMATION /thkr/sapxml_to_abap_pol_full
*        SOURCE XML lv_xml_string
*        RESULT XML lo_doc.
*
*      WRITE: / 'Document Items:', lines( lt_items ).
**      LOOP AT lt_items INTO DATA(ls_item).
**        WRITE: / 'Document Number:', ls_item-key-belnr.
**      ENDLOOP.
*    CATCH cx_transformation_error INTO DATA(lx_transform_error).
*      MESSAGE 'Transformation error: ' && lx_transform_error->get_text( ) TYPE 'E' DISPLAY LIKE 'I'.
*      EXIT.
*  ENDTRY.



  TRY.
      CALL TRANSFORMATION /thkr/sapxml_to_abap_pol_full
            SOURCE XML lv_xml_string
            RESULT file = ls_result.
      WRITE: / 'Document Items:', lines( ls_result-values-items ).
    CATCH cx_transformation_error INTO DATA(lx_transform_error).
      MESSAGE 'Transformation error: ' && lx_transform_error->get_text( ) TYPE 'E' DISPLAY LIKE 'I'.
  ENDTRY.
