class /THKR/CL_FMBB_PDF_CREATOR definition
  public
  final
  create public .

public section.

  methods CREATE_PDF
    importing
      !HEADER type FMBW_S_HEADER
      !LINES type FMED_T_LINES
      !DOC_ID type FMBW_S_DOCID
      !FIRKS type FIKRS default '1000'
    raising
      /THKR/CX_FMBB_PDF_CREATOR .
protected section.

  constants OUTPUT_DESTINATION type RSPOPNAME value 'PDF1' ##NO_TEXT.
  constants FORM_NAME type FPNAME value '/THKR/FMBB_ZUWEISUNG' ##NO_TEXT.

  methods CLOSE_FORM .
  methods INIT_FORM
    changing
      !OUTPUTPARAMS type SFPOUTPUTPARAMS
    returning
      value(FM_NAME) type FUNCNAME
    raising
      /THKR/CX_FMBB_PDF_CREATOR .
  methods CALL_FORM
    importing
      !HEADER type FMBW_S_HEADER
      !LINES type FMED_T_LINES
      !DOC_ID type FMBW_S_DOCID
      !FIRKS type FIKRS default '1000'
      !FM_NAME type FUNCNAME
    returning
      value(PDF_FILE) type FPFORMOUTPUT
    raising
      /THKR/CX_FMBB_PDF_CREATOR .
  methods GET_OUTPUTPARAMS
    importing
      !FILENAME type SYPRTXT
    returning
      value(OUTPUTPARAMS) type SFPOUTPUTPARAMS .
  methods GET_DOCPARAMS
    returning
      value(DOCPARAMS) type SFPDOCPARAMS .
  methods SAVE_PDF_TO_GOS
    importing
      !PDF_FILE type FPFORMOUTPUT
      !DEF_FILENAME type STRING
      !OBJECT_ID type SAEOBJID
    raising
      /THKR/CX_FMBB_PDF_CREATOR .
  methods SAVE_PDF_FILE
    importing
      !PDF_FILE type FPFORMOUTPUT
      !DEF_FILENAME type STRING
    raising
      /THKR/CX_FMBB_PDF_CREATOR .
private section.
ENDCLASS.



CLASS /THKR/CL_FMBB_PDF_CREATOR IMPLEMENTATION.


  METHOD create_pdf.
**********************************************************************
** Collect all data and create /THKR/FMBB_ZUWEISUNG
    DATA filename TYPE string.

    DATA(outputparams) = me->get_outputparams( CONV #( filename ) ).
    DATA(fm_name) = me->init_form( CHANGING outputparams = outputparams ).

* Erkennung mehrer relevanter Sender + Empfänger --> mehrere Formulare
    DATA send_counter TYPE i VALUE 0.
    DATA recv_counter TYPE i VALUE 0.
    DATA entr_counter TYPE i VALUE 0.

    DATA send_lines TYPE fmed_t_lines.
    DATA recv_lines TYPE fmed_t_lines.
    DATA entr_lines TYPE fmed_t_lines.
    DATA done_lines TYPE fmed_t_lines.
    DATA done_send_lines TYPE fmed_t_lines.
    DATA done_recv_lines TYPE fmed_t_lines.
    DATA custom_lines TYPE fmed_t_lines.

    DATA send_data TYPE fmed_s_line.
    DATA recv_data TYPE fmed_s_line.
    DATA entr_data TYPE fmed_s_line.
    DATA inner_entr_data TYPE fmed_s_line.
    DATA lines_data TYPE fmed_s_line.

    LOOP AT lines INTO lines_data.

      IF NOT lines_data-flg_added = 'X'.

        IF lines_data-process = 'SEND' OR lines_data-process = 'TRCS' OR lines_data-process = 'COSD' OR lines_data-process = 'RBBS'.

          send_counter = send_counter + 1.

          APPEND lines_data TO send_lines.

        ELSEIF lines_data-process = 'RECV' OR lines_data-process = 'TRCR' OR lines_data-process = 'CORV' OR lines_data-process = 'RBBT'.

          recv_counter = recv_counter + 1.

          APPEND lines_data TO recv_lines.

        ELSEIF lines_data-process = 'ENTR' OR lines_data-process = 'RETN' OR lines_data-process = 'SUPL'.

          entr_counter = entr_counter + 1.

          APPEND lines_data TO entr_lines.

        ENDIF.
      ENDIF.
    ENDLOOP.

    DATA pdf_file TYPE fpformoutput.

    IF ( send_counter = 1 AND recv_counter = 1 ).

      send_data = send_lines[ 1 ].
      recv_data = recv_lines[ 1 ].
      filename =  header-docdate && '_' && send_data-address-fundsctr && '_' && send_data-address-cmmtitem  && '-' && recv_data-address-fundsctr && '_' && recv_data-address-cmmtitem.

      APPEND LINES OF send_lines TO custom_lines.
      APPEND LINES OF recv_lines TO custom_lines.

      pdf_file = me->call_form( header  = header  " Kopfstruktur des Erfassungsbelegs (effektiv und gemerkt)
                                lines   = custom_lines   " Erfassungsbelegpositionen
                                doc_id  = doc_id  " ID des HHM-Erfassungsbelegs (echt und gemerkt)
                                fm_name = fm_name ). " Funktionsname                )

      me->save_pdf_file( pdf_file = pdf_file def_filename = filename ).

    ELSEIF entr_counter = 1.

      entr_data = entr_lines[ 1 ].
      filename =  header-docdate && '_' && entr_data-address-fundsctr && '_' && entr_data-address-cmmtitem.

      pdf_file = me->call_form( header  = header  " Kopfstruktur des Erfassungsbelegs (effektiv und gemerkt)
                                lines   = entr_lines   " Erfassungsbelegpositionen
                                doc_id  = doc_id  " ID des HHM-Erfassungsbelegs (echt und gemerkt)
                                fm_name = fm_name ). " Funktionsname                )

      me->save_pdf_file( pdf_file = pdf_file def_filename = filename ).

    ELSEIF entr_counter > 1.
      DATA: lv_exists TYPE abap_bool.
      LOOP AT entr_lines INTO entr_data.

        REFRESH custom_lines.

        lv_exists = xsdbool( line_exists( done_lines[ address-cmmtitem = entr_data-address-cmmtitem address-fundsctr = entr_data-address-fundsctr ] ) ).
        IF lv_exists = abap_false.
          LOOP AT entr_lines INTO inner_entr_data.
            IF entr_data-address-cmmtitem = inner_entr_data-address-cmmtitem AND entr_data-address-fundsctr = inner_entr_data-address-fundsctr.
              filename =  header-docdate && '_' && entr_data-address-fundsctr && '_' && entr_data-address-cmmtitem  && '-' && inner_entr_data-address-fundsctr && '_' && inner_entr_data-address-cmmtitem.
              APPEND inner_entr_data TO custom_lines.
              APPEND inner_entr_data TO done_lines.
            ENDIF.
          ENDLOOP.

          pdf_file = me->call_form( header  = header  " Kopfstruktur des Erfassungsbelegs (effektiv und gemerkt)
                            lines   = custom_lines   " Erfassungsbelegpositionen
                            doc_id  = doc_id  " ID des HHM-Erfassungsbelegs (echt und gemerkt)
                            fm_name = fm_name ). " Funktionsname                )

          me->save_pdf_file( pdf_file = pdf_file def_filename = filename ).
        ENDIF.
      ENDLOOP.

    ELSE.
      SORT send_lines BY address-cmmtitem address-fundsctr ceffyear.
      SORT recv_lines BY address-cmmtitem address-fundsctr ceffyear.

      LOOP AT send_lines INTO send_data.
        REFRESH custom_lines.
        REFRESH done_recv_lines.
        IF line_exists( done_send_lines[ address-cmmtitem = send_data-address-cmmtitem address-fundsctr = send_data-address-fundsctr ] ).
          CONTINUE.
        ELSE.
          APPEND send_data TO done_send_lines.
        ENDIF.

        LOOP AT recv_lines INTO recv_data.
          IF recv_data-address-cmmtitem = send_data-address-cmmtitem.

            IF lines( done_recv_lines ) = 0.
              APPEND send_data TO custom_lines.
              APPEND recv_data TO custom_lines.
              filename =  header-docdate && '_' && send_data-address-fundsctr && '_' && send_data-address-cmmtitem  && '-' && recv_data-address-fundsctr && '_' && recv_data-address-cmmtitem.
              APPEND recv_data TO done_recv_lines.

            ELSEIF lines( done_recv_lines ) > 0 AND NOT line_exists( done_recv_lines[ address-fundsctr = recv_data-address-fundsctr ] ).

              pdf_file = me->call_form( header  = header  " Kopfstruktur des Erfassungsbelegs (effektiv und gemerkt)
                                                lines   = custom_lines   " Erfassungsbelegpositionen
                                                doc_id  = doc_id  " ID des HHM-Erfassungsbelegs (echt und gemerkt)
                                                fm_name = fm_name ). " Funktionsname                )
              me->save_pdf_file( pdf_file = pdf_file def_filename = filename ).

              REFRESH custom_lines.
              APPEND send_data TO custom_lines.
              APPEND recv_data TO custom_lines.
              filename =  header-docdate && '_' && send_data-address-fundsctr && '_' && send_data-address-cmmtitem  && '-' && recv_data-address-fundsctr && '_' && recv_data-address-cmmtitem.
              APPEND recv_data TO done_recv_lines.
            ELSEIF lines( done_recv_lines ) > 0 AND line_exists( done_recv_lines[ address-fundsctr = recv_data-address-fundsctr ] ).
              APPEND recv_data TO custom_lines.
              APPEND recv_data TO done_recv_lines.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF NOT lines( custom_lines ) = 0.
          pdf_file = me->call_form( header  = header  " Kopfstruktur des Erfassungsbelegs (effektiv und gemerkt)
                                    lines   = custom_lines   " Erfassungsbelegpositionen
                                    doc_id  = doc_id  " ID des HHM-Erfassungsbelegs (echt und gemerkt)
                                    fm_name = fm_name ). " Funktionsname                )
          me->save_pdf_file( pdf_file = pdf_file def_filename = filename ).
        ENDIF.
      ENDLOOP.
    ENDIF.

    me->save_pdf_to_gos( pdf_file     = pdf_file
                         def_filename = filename
                         object_id    = |{ doc_id-fm_area }{ doc_id-docyear }{ doc_id-docnr }| ).

    me->close_form( ).

  ENDMETHOD.


  METHOD get_outputparams.

    outputparams  = VALUE sfpoutputparams( nodialog = abap_true
                                           preview  = abap_false
                                           getpdf   = abap_true
                                           getxml   = abap_false
                                           covtitle = filename
                                           dest     = me->output_destination ).

  ENDMETHOD.


  METHOD get_docparams.

    docparams  = VALUE sfpdocparams( langu   = sy-langu
                                     country = |DE| ).

  ENDMETHOD.


  METHOD save_pdf_file.
    DATA(fullpath) = ``.
    DATA(filename)  = ``.
    DATA(path) = ``.
    DATA(action) = cl_gui_frontend_services=>action_cancel.

    cl_gui_frontend_services=>file_save_dialog( EXPORTING  default_file_name = def_filename
                                                           default_extension = 'pdf'
                                                CHANGING   filename          = filename
                                                           path              = path
                                                           fullpath          = fullpath
                                                           user_action       = action
                                                EXCEPTIONS OTHERS            = 1 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_fmbb_pdf_creator
        EXPORTING
          textid = /thkr/cx_fmbb_pdf_creator=>fp_error
          msgv1  = |Save_Dialog: { sy-subrc }|.
      RETURN.
    ENDIF.

    DATA(solix) = cl_bcs_convert=>xstring_to_solix( iv_xstring = pdf_file-pdf ).

    cl_gui_frontend_services=>gui_download( EXPORTING  filename = fullpath
                                                       filetype = 'BIN'
                                            CHANGING   data_tab = solix
                                            EXCEPTIONS OTHERS   = 5 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_fmbb_pdf_creator
        EXPORTING
          textid = /thkr/cx_fmbb_pdf_creator=>fp_error
          msgv1  = |GUI_Download: { sy-subrc }|.
    ENDIF.
  ENDMETHOD.


  METHOD call_form.
*    DATA: fm_name  TYPE rs38l_fnam,
*    DATA     pdf_file TYPE fpformoutput          .

    DATA name     TYPE tdobname.
    DATA temp_id  TYPE tdobname.

    CALL FUNCTION 'FMKU_CONSTRUCT_TEXTNAME'
      EXPORTING
        i_f_heldid  = CORRESPONDING fmhed_s_docid( doc_id )
      IMPORTING
        e_held_name = name
        e_temp_id   = temp_id.

* Formularaufruf
    CALL FUNCTION fm_name
      EXPORTING
        /1bcdwb/docparams  = me->get_docparams( )
        header             = header
        lines              = lines
        doc_id             = doc_id
        firks              = firks
        txtname            = COND #( WHEN doc_id-docnr IS INITIAL THEN temp_id ELSE name )
      IMPORTING
        /1bcdwb/formoutput = pdf_file
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE /thkr/cx_fmbb_pdf_creator
        EXPORTING
          textid = /thkr/cx_fmbb_pdf_creator=>fp_error
          msgv1  = |FM_Name Call subrc:{ sy-subrc }|.
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD close_form.
*   ausgabejob schliessen
    call function 'FP_JOB_CLOSE'
      exceptions
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        others         = 4.
    IF sy-subrc <> 0.
      MESSAGE e026(/thkr/fi_ea_forms) WITH me->form_name.
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD init_form.
* Formularname ermitteln
    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = me->form_name
          IMPORTING
            e_funcname = fm_name.

      CATCH cx_fp_api_repository
            cx_fp_api_usage
            cx_fp_api_internal INTO DATA(err).
        RAISE EXCEPTION TYPE /thkr/cx_fmbb_pdf_creator
          EXPORTING
            textid   = /thkr/cx_fmbb_pdf_creator=>fp_error
            previous = err
            msgv1    = |FUNCTION_MODULE_NAME|.
        RETURN.
    ENDTRY.

* Neuen Ausgabejob öffnen
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_fmbb_pdf_creator
        EXPORTING
          textid   = /thkr/cx_fmbb_pdf_creator=>fp_error
          previous = err
          msgv1    = |JOB_OPEN|.
      RETURN.
      RETURN.
    ENDIF.
  ENDMETHOD.


  METHOD save_pdf_to_gos.
    DATA: bin_data   TYPE STANDARD TABLE OF tbl1024,
*          ls_toadt   TYPE toadt,
          lv_flength TYPE sapb-length.
*          lv_anzahl  TYPE i.


    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = pdf_file-pdf
      TABLES
        binary_tab = bin_data.

    lv_flength = lines( bin_data ) * 1024.

    CALL FUNCTION 'ARCHIV_CREATE_TABLE'
      EXPORTING
        ar_object                = 'ZFMBBPDF'
*       DEL_DATE                 = DEL_DATE
        object_id                = object_id
        sap_object               = 'BUS0050'
        flength                  = lv_flength
        doc_type                 = 'PDF'
*       DOCUMENT                 = DOCUMENT
*       MANDT                    = SY-MANDT
*       VSCAN_PROFILE            = '/SCMS/KPRO_CREATE'
        filename                 = CONV char255( |{ def_filename }.pdf| )
*       DESCR                    = ' '
* IMPORTING
*       OUTDOC                   = OUTDOC
      TABLES
*       ARCHIVOBJECT             = ARCHIVOBJECT
        binarchivobject          = bin_data
      EXCEPTIONS
        error_archiv             = 1
        error_communicationtable = 2
        error_connectiontable    = 3
        error_kernel             = 4
        error_parameter          = 5
        error_user_exit          = 6
        error_mandant            = 7
        blocked_by_policy        = 8
        OTHERS                   = 9.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.
ENDCLASS.
