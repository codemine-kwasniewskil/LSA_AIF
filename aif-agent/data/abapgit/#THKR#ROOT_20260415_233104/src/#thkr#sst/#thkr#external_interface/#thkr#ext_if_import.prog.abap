*&---------------------------------------------------------------------*
*& Report /THKR/EXT_IF_IMPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/ext_if_import.

TABLES: sscrfields.

DATA: gs_func TYPE smp_dyntxt.

DATA: gt_filetable TYPE filetable,
      gs_filetable TYPE file_table,
      g_retc       TYPE i,
      g_dir        TYPE string,
      g_frontend   TYPE xfeld.

DATA: g_file        TYPE /thkr/file_w_path.

DATA: g_help_infos TYPE help_info.
DATA: g_xsel.
DATA: g_selvalue TYPE dynfieldvalue.
DATA: gt_dselc TYPE STANDARD TABLE OF dselc,
      gt_dval  TYPE STANDARD TABLE OF dval.
DATA: it_val TYPE vrm_values.

*----------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.                               "Ablageverzeichnisse
SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_type TYPE /thkr/process_type_de_i AS LISTBOX VISIBLE LENGTH 30 USER-COMMAND uc1 OBLIGATORY, " DEFAULT 'AO_I',
              p_frvf TYPE /thkr/cfv-fremdverf OBLIGATORY.

SELECTION-SCREEN END OF BLOCK 001.
SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_ablg RADIOBUTTON GROUP gr1 DEFAULT 'X' USER-COMMAND entr.
  PARAMETERS: p_arch RADIOBUTTON GROUP gr1.
  PARAMETERS: p_file TYPE /thkr/file_w_path LOWER CASE.
SELECTION-SCREEN END OF BLOCK 002.

SELECTION-SCREEN BEGIN OF BLOCK 004 WITH FRAME TITLE TEXT-004.
  PARAMETERS: p_tfile TYPE pathextern LOWER CASE.
  SELECTION-SCREEN SKIP.
  PARAMETERS: p_impo TYPE xfeld,
              p_dmf  TYPE xfeld.
  SELECTION-SCREEN SKIP.
  PARAMETERS: p_sfx  TYPE /thkr/test_suffix,
              p_test TYPE xfeld.
SELECTION-SCREEN END OF BLOCK 004.

*--------------------------------------------------------------------*
INITIALIZATION.
*--------------------------------------------------------------------*
  CLEAR: it_val.

* Domänenwerte holen
  cl_reca_ddic_doma=>get_values( EXPORTING id_name   = '/THKR/PROCESS_TYPE_DE_I'
                                 IMPORTING et_values = DATA(it_dval) ).

  IF lines( it_dval ) > 0.
* wenn Werte vorhanden, dann Auswahlliste erstellen
    it_val = VALUE vrm_values( FOR v IN it_dval ( key  = v-domvalue_l
                                                  text = v-ddtext ) ).

* Auswahlliste setzen
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'P_TYPE'
        values          = it_val
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.

    IF sy-subrc = 0.
* Vorselektion 'Punkt eins'
      p_type = it_val[ 1 ]-key.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
* akt. Selektion der ComboBox heraussuchen
  TRY.
      DATA(s) = it_val[ key = p_type ].

      WRITE: / s-key, s-text.
    CATCH cx_root.
  ENDTRY.
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_type.
*----------------------------------------------------------------------*
  g_help_infos-call    = 'V'.
  g_help_infos-object  = 'F'.
  g_help_infos-program = 'RSSYSTDB'.
  g_help_infos-dynpro  = '1000'.
  g_help_infos-tabname = 'ZJVA_PROCESS_TYPE_I'.

  CALL FUNCTION 'DD_SHLP_CALL_FROM_DYNP'
    EXPORTING
      help_infos   = g_help_infos
    IMPORTING
      selection    = g_xsel
      select_value = g_selvalue
    TABLES
      dynpselect   = gt_dselc
      dynpvaluetab = gt_dval.


*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_tfile.
*----------------------------------------------------------------------*
  REFRESH gt_filetable.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      initial_directory       = g_dir
    CHANGING
      file_table              = gt_filetable
      rc                      = g_retc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  READ TABLE gt_filetable INTO gs_filetable INDEX 1.
  IF sy-subrc EQ 0.
    p_tfile = gs_filetable-filename.
  ENDIF.

**----------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
**----------------------------------------------------------------------*
*  CLEAR gs_md.
*  SELECT * INTO CORRESPONDING FIELDS OF gs_md
*    UP TO 1 ROWS
*    FROM ztjva_ihv_md
*     WHERE process_type = p_cont
*      ORDER BY PRIMARY KEY.
*  ENDSELECT.
*  IF sy-subrc EQ 0.
*    IF p_ablg = 'X'.
*      CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
*        EXPORTING
*          directory        = gs_md-pathextern
*          filemask         = space
*        IMPORTING
*          serverfile       = p_file
*        EXCEPTIONS
*          canceled_by_user = 1
*          OTHERS           = 2.
*    ELSE.
*      CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
*        EXPORTING
*          directory        = gs_md-pathextern_archive
*          filemask         = space
*        IMPORTING
*          serverfile       = p_file
*        EXCEPTIONS
*          canceled_by_user = 1
*          OTHERS           = 2.
*
*    ENDIF.
*  ENDIF.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  DATA: l_salv_inpdb TYPE REF TO /thkr/cl_salv_inpdb,
        lrt_inpdb    TYPE REF TO /thkr/t_de_inpdb,
        l_xmlstr     TYPE xstring.

  DATA(def) = /thkr/cl_ext_if_def=>get_instance( ).

  IF p_tfile IS INITIAL.
    g_file = p_file.
    CLEAR g_frontend.
  ELSE.
    g_file = p_tfile.
    g_frontend = 'X'.
  ENDIF.

  /thkr/cl_ext_if_appl=>get_instance( )->process_import(
      EXPORTING
        i_process_type    = p_type
        i_fremdverf       = p_frvf
        i_filename        = g_file
        i_frontend        = g_frontend
        i_import_only     = p_impo
        i_dont_move_files = p_dmf
        i_test_suffix     = p_sfx
        i_test            = p_test ).

  IF p_test IS NOT INITIAL.

    CASE p_type.
      WHEN def->c_process_type-anordnung.

        TRY.
            /thkr/cl_ext_if_appl=>get_instance( )->get_t_inpbd(
              IMPORTING
               et_inpdb  = DATA(lt_inpdb) ).

            GET REFERENCE OF lt_inpdb INTO lrt_inpdb.

            CREATE OBJECT l_salv_inpdb
              EXPORTING
                it_inpdb = lrt_inpdb.

            l_salv_inpdb->display( ).

            /thkr/cl_ext_if_appl=>get_instance( )->get_de_file(
              IMPORTING
                e_de_file = DATA(l_de_file) ).

            CALL TRANSFORMATION id
              SOURCE file = l_de_file
              RESULT XML l_xmlstr.

            CALL FUNCTION 'DISPLAY_XML_STRING'
              EXPORTING
                xml_string = l_xmlstr.

          CATCH cx_root INTO DATA(l_oerror).

            /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

        ENDTRY.
      WHEN def->c_process_type-einzelplan.

        TRY.

            /thkr/cl_ext_if_appl=>get_instance( )->get_xml_data_by_run(
              EXPORTING
                i_process_type = p_type
                i_process_id   = def->c_process_id-current_process
              IMPORTING
                e_xmlstr       = l_xmlstr
            ).

            CALL FUNCTION 'DISPLAY_XML_STRING'
              EXPORTING
                xml_string = l_xmlstr.

          CATCH cx_root INTO l_oerror.

            /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
        ENDTRY.
    ENDCASE.

  ENDIF.

  MESSAGE i000(/thkr/eif).

*----------------------------------------------------------------------*

FORM switch_screen USING p_para TYPE xfeld.
  IF p_para IS INITIAL.
    screen-invisible = '1'.
    IF screen-group3 = 'LOW' OR screen-group3 = 'HGH' OR screen-group3 = 'PAR'.
      screen-input = '0'.
    ENDIF.
  ELSE.
    screen-invisible = '0'.
    IF screen-group3 = 'LOW' OR screen-group3 = 'HGH' OR screen-group3 = 'PAR'.
      screen-input = '1'.
    ENDIF.
  ENDIF.
ENDFORM.
