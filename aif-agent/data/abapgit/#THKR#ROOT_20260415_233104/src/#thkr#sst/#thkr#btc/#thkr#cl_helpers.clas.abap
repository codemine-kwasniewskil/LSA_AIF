class /THKR/CL_HELPERS definition
  public
  create protected .

public section.

  class-methods GET_INSTANCE
    returning
      value(E_REFERENCE) type ref to /THKR/CL_HELPERS .
  methods ADD_DOCUMENT_TO_BDS
    importing
      !I_BDS_CLSNAM type BDS_CLSNAM
      !I_BDS_CLSTYP type BDS_CLSTYP
      !I_BDS_DCLASS type BDS_DCLASS
      !I_BDS_DESCRIPTION type BDS_PROPVA
      !I_OBJECT_KEY type SBDST_OBJECT_KEY
      !I_COMP_ID type BDS_COMPID
      !IT_RAW type LVC_T_X1022
    exporting
      !E_BDSREF type BDS_DOCID .
  methods ARCHIVE_DOCUMENT
    importing
      !I_PDF type XSTRING
      !I_DOC_TYPE type SAEDOKTYP default 'PDF'
      !I_CONT_REP_ID type SAEARCHIVI
    exporting
      !E_ARC_DOC_ID type SAEARDOID .
  methods CHECK_ARCHIV
    importing
      !ARCHIV_ID type SAEARCHIVI
    raising
      /THKR/CX_LSA1 .
  methods COMPRESS_XSTRING
    importing
      !I_XSTRING type XSTRING
    exporting
      !ET_X255 type /THKR/T_X255 .
  methods CONVERT_OTF_TO_PDF
    importing
      !IT_OTF type TSFOTF
    exporting
      !ET_RAW_PDF type LVC_T_X1022
      !E_XSTRING_PDF type XSTRING .
  methods CONVERT_RANGE_DATUM_TO_TMSTMP
    importing
      !I_RDATUM type /THKR/T_RDATUM
    exporting
      !E_RTIMESTAMP type /THKR/T_RTIMESTAMP .
  methods CONV_CSTRING_TO_XSTRING
    importing
      !I_STRING type STRING
      !I_ENCODING type ABAP_ENCODING default 'UTF-8'
      !I_IGNORE_CERR type XFELD optional
    exporting
      !E_XSTRING type XSTRING
    raising
      /THKR/CX_LSA1 .
  methods CONV_XSTRING_TO_CSTRING
    importing
      !I_XSTRING type XSTRING
      !I_ENCODING type ABAP_ENCODING default 'UTF-8'
    exporting
      !E_STRING type STRING .
  methods CREATE_PDF
    importing
      !I_FORM type TDSFNAME
      !I_DATA type DATA
    returning
      value(R_PDF) type XSTRING
    raising
      /THKR/CX_LSA1 .
  methods DISPLAY_BAPIRET2_T
    importing
      !IT_BAPIRET2 type BAPIRET2_T .
  methods DISPLAY_EXCEPTION
    importing
      !I_OERROR type ref to CX_ROOT .
  methods DOWNLOAD_XSTRING
    importing
      !I_XSTRING type XSTRING
      !I_FILENAME type STRING
    raising
      /THKR/CX_LSA1 .
  methods FILL_X_STRUCTURE
    importing
      !I_STRUCTURE type TABNAME
    changing
      !C_DATA type DATA
      !C_DATAX type DATA .
  methods GET_ADDRESS_IN_PRINTFORM
    importing
      !ADDRESS_TYPE type SZAD_FIELD-ADDR_TYPE default '1'
      !ADDRESS_NUMBER type ADRC-ADDRNUMBER
      !PERSON_NUMBER type ADRP-PERSNUMBER optional
      !SENDER_COUNTRY type AD_CTRY_FR default 'DE'
      !RECEIVER_LANGUAGE type T002-SPRAS default 'D'
    returning
      value(R_VALUE) type STRING .
  methods GET_ARCHIVE
    importing
      !AR_OBJECT type SAEOBJART
      !SAP_OBJECT type SAEANWDID
    returning
      value(ARCHIV_DATA) type TOAOM
    raising
      /THKR/CX_LSA1 .
  methods GET_FIELDLIST_FROM_STRUCT
    importing
      !I_STRUCTURE type TABNAME
      !I_INCLUDE_FIELDS_TYPE_S type XFELD optional
    exporting
      !ET_FIELDLIST type /THKR/T_STRUCTURE_FIELD .
  methods GET_ROWTYPE_BY_TABLETYPE
    importing
      !I_TABLETYPE type TTYPENAME
    exporting
      !E_ROWTYPE type TTROWTYPE
    raising
      /THKR/CX_LSA1 .
  methods GET_SECONDS_OF_DAY
    importing
      !I_TIMESTAMP type TIMESTAMP
    exporting
      !E_SECONDS type /THKR/SECONDS
    returning
      value(R_SECONDS) type /THKR/SECONDS .
  methods GET_SELECT_CLAUSE_FROM_STRUCT
    importing
      !I_STRUCTURE type TABNAME
      !I_PREFIX type STRING
      !I_COMMA_SEPARATION type XFELD optional
      !IT_EXCLUDE_FIELDS type TTFIELDNAME optional
    changing
      !C_SELECT_CLAUSE type STRING .
  methods GET_TYPE_BY_STRUCTURE_FIELD
    importing
      !I_STRUCTURE type TABNAME
      !I_FIELDNAME type FIELDNAME
    exporting
      !E_ROLLNAME type ROLLNAME
      !E_DATATYPE type DATATYPE_D
    raising
      /THKR/CX_LSA1 .
  methods GET_TYPE_OF_PARAMETER
    importing
      !I_CLSNAME type SEOCLSNAME
      !I_METHOD type SEOCMPNAME
      !I_PARAMETER type SEOSCONAME
    exporting
      !E_TYPE type RS38L_TYP
      !E_DESCRIPTION type SEODESCR
    raising
      /THKR/CX_LSA1 .
  methods GUI_DOWNLOAD_XSTRING
    importing
      !I_XSTRING type XSTRING
      !I_FILENAME type STRING .
  methods REMOVE_LEADING_ZEROS
    changing
      !C_VALUE type DATA .
  methods UNCOMPRESS_XSTRING
    importing
      !IT_X255 type /THKR/T_X255
    exporting
      !E_XSTRING type XSTRING .
  methods UNCOMPRESS_XSTRING1
    importing
      !I_XSTRING type XSTRING optional
      !IT_X255 type /THKR/T_X255 optional
    exporting
      !E_XSTRING type XSTRING .
  methods GET_LVC_T_FCAT_4_ITAB
    importing
      !I_TABLE_REF type ref to DATA
    exporting
      !ET_FCAT type LVC_T_FCAT .
  methods GET_XML_ESCAPING
    changing
      !CV_XMLSTRING type CSEQUENCE .
  PROTECTED SECTION.

    CLASS-DATA lsa_helpers TYPE REF TO /thkr/cl_helpers .
private section.

  types:
    ty_char1 TYPE c LENGTH 1 .

  constants C_EMPTY_STRING type TY_CHAR1 value ']' ##NO_TEXT.

  methods DISPLAY_ERRORS
    importing
      !I_OERROR type ref to CX_ROOT optional
      !IT_BAPIRET2 type BAPIRET2_T optional .
ENDCLASS.



CLASS /THKR/CL_HELPERS IMPLEMENTATION.


  METHOD add_document_to_bds.


    DATA:lt_component TYPE TABLE OF bapicompon,
         l_component  LIKE LINE OF lt_component,
         lt_signature TYPE TABLE OF bapisignat,
         l_signature  LIKE LINE OF lt_signature,
         l_object_key TYPE sbdst_object_key.


* Eindeutigen Schlüssel erzeugen und in Komponententabelle schreiben
    REFRESH lt_component.

    l_component-comp_id = i_comp_id.
    APPEND l_component TO lt_component.

* Detaildaten zum BDS-Eintrag erzeugen
    REFRESH lt_signature.

    l_signature-prop_name  = 'BDS_DOCUMENTCLASS'.
    l_signature-prop_value = i_bds_dclass.
    APPEND l_signature TO lt_signature.

    l_signature-prop_name  = 'BDS_KEYWORD'.
    l_signature-prop_value = i_bds_description.
    APPEND l_signature TO lt_signature.

    l_signature-prop_name  = 'DESCRIPTION'.
    l_signature-prop_value = i_bds_description.
    APPEND l_signature TO lt_signature.

    l_signature-prop_name  = 'BDS_DOCUMENTTYPE'.
    l_signature-prop_value = i_bds_clsnam.
    APPEND l_signature TO lt_signature.

    l_object_key = i_object_key.

    CALL METHOD cl_bds_document_set=>create_with_table
      EXPORTING
        classname       = i_bds_clsnam
        classtype       = i_bds_clstyp
        components      = lt_component
        content         = it_raw
      CHANGING
        signature       = lt_signature
        object_key      = l_object_key
      EXCEPTIONS
        internal_error  = 1
        error_kpro      = 2
        parameter_error = 3
        not_authorized  = 4
        not_allowed     = 5
        nothing_found   = 6
        OTHERS          = 7.

    ASSERT sy-subrc = 0.

    READ TABLE lt_signature INDEX 1 INTO l_signature.

    e_bdsref = l_signature-doc_id.

  ENDMETHOD.


  METHOD archive_document.
    DATA: lt_content TYPE solix_tab,
          lt_comps   TYPE TABLE OF scms_comp,
          l_length   TYPE int4,
          l_mimetype TYPE w3conttype.

    FIELD-SYMBOLS: <l_comp> LIKE LINE OF lt_comps.

    CLEAR: e_arc_doc_id.

    "Datei-Inhalt konvertieren (in binary)
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = i_pdf
      TABLES
        binary_tab = lt_content.

    "Mimetype ermitteln
    SELECT SINGLE mimetype
      FROM toadd
      INTO l_mimetype
      WHERE doc_type = i_doc_type.
    IF sy-subrc <> 0 OR l_mimetype IS INITIAL.
      l_mimetype = 'application/pdf'. "#EC NOTEXT "Fallback (immer PDF)
    ENDIF.

    "Länge ermitteln, wenn nicht gegeben
    l_length = xstrlen( i_pdf ).

    "Komponenteninhalt füllen
    APPEND INITIAL LINE TO lt_comps ASSIGNING <l_comp>.
    <l_comp>-fsize     = l_length.
    <l_comp>-compid    = 'data'.                            "#EC NOTEXT
    <l_comp>-mimetype  = l_mimetype.

    "Archivieren
    CALL FUNCTION 'SCMS_HTTP_CREATE_TABLE'
      EXPORTING
        crep_id               = i_cont_rep_id
      IMPORTING
        doc_id_out            = e_arc_doc_id
      TABLES
        comps                 = lt_comps
        data                  = lt_content
      EXCEPTIONS
        bad_request           = 1
        unauthorized          = 2
        forbidden             = 3
        conflict              = 4
        internal_server_error = 5
        error_http            = 6
        error_url             = 7
        error_signature       = 8
        error_parameter       = 9
        OTHERS                = 10.
    IF sy-subrc <> 0.
      "Fehler-Handling
* (del)      ASSERT sy-subrc = 0.     "Test
    ENDIF.

  ENDMETHOD.


  METHOD check_archiv.

    DATA: l_cr      TYPE scms_crep,
          ls_srep   TYPE scms_screp,
          l_message TYPE bapiret2.

    l_cr = archiv_id.

    SELECT SINGLE * FROM crep INTO CORRESPONDING FIELDS OF ls_srep
      WHERE crep_id = l_cr.
    IF sy-subrc = 0.
      IF ls_srep-crep_type = '04'.           "Verbindung testen
        SELECT SINGLE * FROM crep_http INTO
                           CORRESPONDING FIELDS OF ls_srep
                           WHERE crep_id = archiv_id.
        CALL FUNCTION 'SCMS_HTTP_PING'
          EXPORTING
            crep_id    = ls_srep-crep_id
*           SECURITY   = ' '
            http_serv  = ls_srep-http_serv
            http_port  = ls_srep-http_port
            http_sport = ls_srep-http_sport
            http_scrpt = ls_srep-http_scrpt
            version    = ls_srep-version
          EXCEPTIONS
            error_http = 1
            OTHERS     = 2.
        IF sy-subrc <> 0.          "keine Verbindung zum Archivsystem
          l_message-id   = 'OA'.
          l_message-type = 'E'.
          l_message-number = '717'.
          RAISE EXCEPTION TYPE /thkr/cx_lsa1 EXPORTING bapiret2 = l_message.
        ENDIF.
      ENDIF.
    ELSE.                                 "Archiv unbekannt?!!?
      l_message-id   = 'OA'.
      l_message-type = 'E'.
      l_message-number = '843'.
      RAISE EXCEPTION TYPE /thkr/cx_lsa1 EXPORTING bapiret2 = l_message.
    ENDIF.

  ENDMETHOD.


  METHOD compress_xstring.

    DATA: l_gzipstr TYPE xstring,
          l_offset  TYPE i.

    CLEAR: et_x255.

    cl_abap_gzip=>compress_binary(
      EXPORTING
        raw_in         = i_xstring
*       raw_in_len     = -1
*       compress_level = 6
      IMPORTING
        gzip_out       = l_gzipstr
        gzip_out_len   = DATA(l_len) ).

    l_offset = 0.

    DO.
      APPEND l_gzipstr+l_offset TO et_x255.
      ADD 255 TO l_offset.
      IF l_offset > l_len.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.


  METHOD convert_otf_to_pdf.


    DATA: l_numbytes       TYPE i,
          l_pdf_rec_length TYPE i,
          l_raw_rec_length TYPE i,
          l_xstring_length TYPE i,
          l_offset         TYPE i,
          l_raw_stream_wa  LIKE LINE OF et_raw_pdf,
          lt_pdf_stream    TYPE tline_tab,
          l_pdf_stream_wa  LIKE LINE OF lt_pdf_stream.

    CLEAR: et_raw_pdf, e_xstring_pdf.

    FIELD-SYMBOLS <pdf_line> TYPE x.
    FIELD-SYMBOLS <raw_line> TYPE x.

*   OTF in RAW für PDF umwandeln
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
      IMPORTING
        bin_filesize          = l_numbytes
      TABLES
        otf                   = it_otf
        lines                 = lt_pdf_stream
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        err_bad_otf           = 4
        OTHERS                = 5.
    ASSERT sy-subrc = 0.

*   PDF in RAW umwandeln
    DESCRIBE FIELD l_pdf_stream_wa LENGTH l_pdf_rec_length IN BYTE MODE.
    DESCRIBE FIELD l_raw_stream_wa LENGTH l_raw_rec_length IN BYTE MODE.

    ASSIGN l_pdf_stream_wa TO <pdf_line> CASTING.

    LOOP AT lt_pdf_stream INTO l_pdf_stream_wa.

      CONCATENATE e_xstring_pdf <pdf_line> INTO e_xstring_pdf IN BYTE MODE.

    ENDLOOP.

    l_xstring_length = xstrlen( e_xstring_pdf ).
    l_offset = 0.

    ASSIGN l_raw_stream_wa TO <raw_line> CASTING.

    DO.

      <raw_line> = e_xstring_pdf+l_offset.

      APPEND l_raw_stream_wa TO et_raw_pdf.

      l_offset = l_offset + l_raw_rec_length.

      IF l_offset > l_xstring_length.
        EXIT.
      ENDIF.

    ENDDO.

  ENDMETHOD.


  METHOD convert_range_datum_to_tmstmp.

    LOOP AT i_rdatum INTO DATA(l_rdatum).
      APPEND INITIAL LINE TO e_rtimestamp ASSIGNING FIELD-SYMBOL(<rtimestamp>).

      <rtimestamp>-sign   = l_rdatum-sign.
      IF l_rdatum-option = 'EQ'.
        <rtimestamp>-option = 'BT'.
        l_rdatum-high = l_rdatum-low.
      ELSE.
        <rtimestamp>-option = l_rdatum-option.
      ENDIF.
      IF l_rdatum-low IS NOT INITIAL.
        CONVERT DATE l_rdatum-low INTO TIME STAMP <rtimestamp>-low TIME ZONE sy-zonlo.
      ENDIF.
      IF l_rdatum-high IS NOT INITIAL.
        ADD 1 TO l_rdatum-high.
        CONVERT DATE l_rdatum-high INTO TIME STAMP <rtimestamp>-high TIME ZONE sy-zonlo.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD conv_cstring_to_xstring.

    DATA: text_len  TYPE i,
          l_xstring TYPE xstring,
          l_conv    TYPE REF TO cl_abap_conv_out_ce,
          l_oerror  TYPE REF TO cx_root.

** no text -> no conversion
    text_len = strlen( i_string ).
    IF text_len = 0.
      e_xstring            = ''.
      EXIT.
    ENDIF.

    l_conv = cl_abap_conv_out_ce=>create(
      EXPORTING
        encoding    = i_encoding
        ignore_cerr = i_ignore_cerr ).

* Conversion of text
    TRY.
        l_conv->write(
          EXPORTING
            n    = text_len
            data = i_string ).

        l_xstring = l_conv->get_buffer( ).

      CATCH cx_sy_codepage_converter_init cx_sy_conversion_codepage INTO l_oerror.
        RAISE EXCEPTION TYPE /thkr/cx_lsa1
          EXPORTING
            textid   = /thkr/cx_lsa1=>error_conv_cstring_xstring
            previous = l_oerror.
    ENDTRY.

    e_xstring        = l_xstring.

  ENDMETHOD.


  METHOD conv_xstring_to_cstring.

    DATA: l_len    TYPE i.
    DATA: l_xstring TYPE xstring,
          l_conv    TYPE REF TO cl_abap_conv_in_ce.

** no text -> no conversion
    l_len = xstrlen( i_xstring ).
    IF l_len = 0.
      e_string            = ''.
      EXIT.
    ENDIF.

    l_conv = cl_abap_conv_in_ce=>create(
      EXPORTING
        encoding = i_encoding ).

* Conversion of text

    TRY.
        l_conv->convert(
          EXPORTING
            input           = i_xstring
*               n               = -1
          IMPORTING
            data            = e_string
*    len             = len
*    input_too_short = input_too_short
               ).
*  CATCH cx_sy_conversion_codepage.
*  CATCH cx_sy_codepage_converter_init.
*  CATCH cx_parameter_invalid_type.
      CATCH cx_root INTO DATA(l_oerror).
    ENDTRY.

  ENDMETHOD.


  METHOD create_pdf.



    DATA: lt_raw                TYPE lvc_t_x1022,
          l_on                  TYPE boolean VALUE 'X',
          l_off                 TYPE boolean VALUE ' ',
          l_fm_name             TYPE rs38l_fnam,
          ls_composer_param_ret TYPE ssfcresop,
          ls_job_info           TYPE ssfcrescl,
          ls_control_param      TYPE ssfctrlop,
          ls_composer_param     TYPE ssfcompop,
          l_toa_dara            TYPE toa_dara,
          l_arc_params          TYPE arc_params.
*          t_data_ref            type ref to data,
*          tdata_ref             type ref to data.

*    field-symbols: <tdata>  type standard table,
*                   <t_data> type standard table.

*   Druckparameter vorbelegen
    CLEAR: ls_composer_param, ls_composer_param_ret.
    ls_composer_param-tdimmed    = l_on.
    ls_composer_param-tddelete   = l_off.
    ls_composer_param-tdnewid    = l_on.
    ls_composer_param-tdcover    = l_off.
    ls_composer_param-tdcovtitle = i_form.
    ls_control_param-langu       = sy-langu.

*   Funktionsbaustein zu Formular suchen
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = i_form
      IMPORTING
        fm_name            = l_fm_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc NE 0.                  "DE20170105 sollte nicht vorkommen
    ELSE.
      "   Parameter für PDF-Druck ändern
      CLEAR: ls_composer_param_ret.
      ls_control_param-getotf      = 'X'.
      ls_control_param-no_dialog   = 'X'.
      ls_composer_param-tddest = 'LP01'.      "constants->pdf_printer.

*   physischer Druck im WebDynpro so nicht umsetzbar, deshalb nur im Test
*      IF constants->test_mode IS NOT INITIAL.
*   Aufruf der Smartform für den physichen Druck
      CALL FUNCTION l_fm_name
        EXPORTING
          archive_index      = l_toa_dara
          archive_parameters = l_arc_params
          control_parameters = ls_control_param
          output_options     = ls_composer_param
          user_settings      = ' '
          i_data             = i_data
        IMPORTING
          job_output_info    = ls_job_info
          job_output_options = ls_composer_param_ret
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 6.

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_lsa1.
      ELSE.
        convert_otf_to_pdf(
          EXPORTING
            it_otf = ls_job_info-otfdata
          IMPORTING
            e_xstring_pdf = r_pdf
            et_raw_pdf    = lt_raw ).
      ENDIF.

    ENDIF.                                                  "DE20170105
  ENDMETHOD.


  METHOD display_bapiret2_t.

    display_errors(
      it_bapiret2 = it_bapiret2 ).

  ENDMETHOD.


  METHOD display_errors.

    DATA: l_answer  TYPE c,
          l_message TYPE string,
          lt_error  TYPE /thkr/t_error,
          lt_error1 TYPE /thkr/t_error,
          l_error   TYPE /thkr/s_error,
          l_bapiret TYPE bapiret2,
          l_oerror  TYPE REF TO cx_root,
          l_/thkr/cx_lsa TYPE REF TO /thkr/cx_lsa1,
          l_salv    TYPE REF TO /thkr/cl_salv_errors.

    FIELD-SYMBOLS: <oerror> TYPE REF TO data.

    IF i_oerror IS NOT INITIAL.
      l_oerror = i_oerror.
*   Fehlertext der übergebenen Exception auslesen: Für die Anzeige im Meldungsfenster
      l_message = i_oerror->get_text( ).

*   Tabelle lt_error für Detailanzeige der Meldungen aufbauen
      DO.
        l_error-type = 'E'. "Der eigentliche Text der Exception ist immer ein Error
        l_error-message = l_oerror->get_text( ).
        APPEND l_error TO lt_error. "Text der Exception-Hauptmeldung

        TRY.
            l_/thkr/cx_lsa ?= l_oerror. "Ist das eine Exception, vom Typ /thkr/cx_lsa1?

            IF sy-subrc = 0.

              IF l_/thkr/cx_lsa->t_bapiret2 IS NOT INITIAL.
                MOVE-CORRESPONDING l_/thkr/cx_lsa->t_bapiret2 TO lt_error1.
                APPEND LINES OF lt_error1 TO lt_error.
              ENDIF.
              IF l_/thkr/cx_lsa->bapiret2 IS NOT INITIAL.
                MOVE-CORRESPONDING l_/thkr/cx_lsa->bapiret2 TO l_error.
                APPEND l_error TO lt_error.
              ENDIF.
            ENDIF.
          CATCH cx_sy_move_cast_error.
        ENDTRY.
        IF l_oerror->previous IS INITIAL.
          EXIT.
        ENDIF.
        l_oerror = l_oerror->previous.

      ENDDO.
    ELSE.
      MOVE-CORRESPONDING it_bapiret2 TO lt_error.
      READ TABLE lt_error INDEX 1 INTO DATA(l_line).
      l_message = l_line-message.
    ENDIF.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'Fehler'
*       DIAGNOSE_OBJECT       = ' '
        text_question         = l_message
        text_button_1         = 'Details'(001)
*       ICON_BUTTON_1         = ' '
        text_button_2         = 'OK'(002)
*       ICON_BUTTON_2         = ' '
*       DEFAULT_BUTTON        = '1'
        display_cancel_button = ''
*       USERDEFINED_F1_HELP   = ' '
*       START_COLUMN          = 25
*       START_ROW             = 6
        popup_type            = 'ICON_MESSAGE_ERROR'
*       IV_QUICKINFO_BUTTON_1 = ' '
*       IV_QUICKINFO_BUTTON_2 = ' '
      IMPORTING
        answer                = l_answer.
    IF sy-subrc <> 0.
*     Implement suitable error handling here
    ENDIF.

    IF l_answer = '1'.

      CREATE OBJECT l_salv
        EXPORTING
          it_error = lt_error
          i_oerror = i_oerror.

      TRY.
          l_salv->display( ).
        CATCH cx_salv_not_found.
        CATCH cx_root.
          ASSERT 1 = 2.
      ENDTRY.

    ENDIF.

  ENDMETHOD.


  METHOD display_exception.

    display_errors( i_oerror    = i_oerror ).

  ENDMETHOD.


  METHOD download_xstring.

    DATA: l_mess     TYPE string.

    TRY.
        OPEN DATASET i_filename FOR OUTPUT IN BINARY MODE MESSAGE l_mess.
        IF sy-subrc = 0.

          CLEAR l_mess.
          TRANSFER i_xstring TO i_filename.
          CLOSE DATASET i_filename.

        ENDIF.

      CATCH cx_root INTO DATA(l_oerror).
        RAISE EXCEPTION TYPE /THKR/CX_LSA1
          EXPORTING
            textid   = /THKR/CX_LSA1=>error_create_file
            filename = i_filename
            previous = l_oerror.
    ENDTRY.
    IF l_mess IS NOT INITIAL.
      RAISE EXCEPTION TYPE /THKR/CX_LSA1
        EXPORTING
          textid   = /THKR/CX_LSA1=>error_create_file_mess
          filename = i_filename
          mess     = l_mess.
    ENDIF.

  ENDMETHOD.


  METHOD fill_x_structure.

* Bei BAPI-Aufrufen muss häufig neben der Daten-Struktur mit den zu ändernden Daten eine X-Struktur
* übergeben werden, mit deren Hilfe definiert wird, welche Felder aus der Daten-Struktur beachtet
* werden sollen. Die Methode setzt für jedes gefüllte Feld der Daten-Strukur das entsprechende Feld
* der X-Struktur
* Bsp.:
*  call function 'BAPI_PO_CREATE1'
*    exporting
*      poheader               = l_poheader
*      poheaderx              = l_poheaderx
*      ...


    TYPES: BEGIN OF lty_field,
             position  TYPE tabfdpos,
             fieldname TYPE fieldname,
             domname   TYPE domname,
             inttype   TYPE inttype,
           END OF lty_field.

    DATA: lt_field TYPE STANDARD TABLE OF lty_field,
          l_field  TYPE lty_field,
          l_dd     TYPE REF TO data,
          l_ddx    TYPE REF TO data.

    FIELD-SYMBOLS <fld> TYPE any.
    FIELD-SYMBOLS <fldx> TYPE any.

    GET REFERENCE OF c_data  INTO l_dd.
    GET REFERENCE OF c_datax INTO l_ddx.

    SELECT *
      FROM dd03l INTO CORRESPONDING FIELDS OF TABLE lt_field
      WHERE tabname = i_structure
      AND   as4local = 'A'
      ORDER BY position.

    LOOP AT lt_field INTO l_field.

      ASSIGN l_dd->(l_field-fieldname) TO <fld>.
      ASSIGN l_ddx->(l_field-fieldname) TO <fldx>.
      IF <fld> IS NOT INITIAL.
        <fldx> = 'X'.

        IF l_field-inttype = 'C'.
          IF <fld> = c_empty_string.
            CLEAR <fld>.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_address_in_printform.
*DATA ADRSWA_IN                      TYPE ADRS.
*DATA ADDRESS_1                      TYPE ADRS1.
*DATA ADDRESS_2                      TYPE ADRS2.
*DATA ADDRESS_3                      TYPE ADRS3.
*DATA ADDRESS_TYPE                   TYPE SZAD_FIELD-ADDR_TYPE.
*DATA ADDRESS_NUMBER                 TYPE ADRC-ADDRNUMBER.
*DATA ADDRESS_HANDLE                 TYPE SZAD_FIELD-HANDLE.
*DATA PERSON_NUMBER                  TYPE ADRP-PERSNUMBER.
*DATA PERSON_HANDLE                  TYPE SZAD_FIELD-HANDLE.
*DATA SENDER_COUNTRY                 TYPE SZAD_FIELD-SEND_CNTRY.
*DATA RECEIVER_LANGUAGE              TYPE T002-SPRAS.
*DATA NUMBER_OF_LINES                TYPE ADRS-ANZZL.
*DATA STREET_HAS_PRIORITY            TYPE SZAD_FIELD-STREETPRIO.
*DATA LINE_PRIORITY                  TYPE SZAD_FIELD-PRIORITY.
*DATA COUNTRY_NAME_IN_RECEIVER_LANGU TYPE SZAD_FIELD-FLAG.
*DATA LANGUAGE_FOR_COUNTRY_NAME      TYPE T002-SPRAS.
*DATA NO_UPPER_CASE_FOR_CITY         TYPE SZAD_FIELD-FLAG.
*DATA IV_NATION                      TYPE ADRC-NATION.
*DATA IV_NATION_SPACE                TYPE T_BOOLE.
*DATA IV_PERSON_ABOVE_ORGANIZATION   TYPE T_BOOLE.
*DATA IS_BUPA_TIME_DEPENDENCY        TYPE ADBUPA_TD.
*DATA IV_COUNTRY_NAME_SEPARATE_LINE  TYPE XFELD.
*DATA IV_LANGU_CREA                  TYPE T002-SPRAS.
*DATA IV_DISPLAY_COUNTRY_IN_SHRTFORM TYPE XFELD.
*DATA BLK_EXCPT                      TYPE AD_BLKFLAG.
*DATA ADRSWA_OUT                     TYPE ADRS.
*DATA ADDRESS_PRINTFORM              TYPE ADRS_PRINT.
*DATA ADDRESS_SHORT_FORM             TYPE SZAD_FIELD-ADDR_SHORT.
*DATA ADDRESS_SHORT_FORM_S           TYPE SZAD_FIELD-ADDR_SHORT.
*DATA ADDRESS_DATA_CARRIER           TYPE SZAD_FIELD-ADDR_DC.
*DATA ADDRESS_DATA_CARRIER_0         TYPE SZAD_FIELD-ADDR_DC.
*DATA NUMBER_OF_USED_LINES           TYPE ADRS-ANZZL.
*DATA NAME_IS_EMPTY                  TYPE SZAD_FIELD-FLAG.
*DATA ADDRESS_NOT_FOUND              TYPE SZAD_FIELD-FLAG.
    DATA address_printform_table        TYPE szadr_printform_table.
*DATA ADDRESS_SHORT_FORM_WO_NAME     TYPE SZAD_FIELD-ADDR_SHORT.
*DATA EV_NATION                      TYPE ADRC-NATION.

    CLEAR r_value.

* - Daten zur Adress-Nummer, etc. besorgen
    CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
      EXPORTING
*       ADRSWA_IN                      = ADRSWA_IN
*       ADDRESS_1                      = ADDRESS_1
*       ADDRESS_2                      = ADDRESS_2
*       ADDRESS_3                      = ADDRESS_3
        address_type                   = address_type
        address_number                 = address_number
*       ADDRESS_HANDLE                 = ' '
        person_number                  = person_number
*       PERSON_HANDLE                  = ' '
        sender_country                 = sender_country
        receiver_language              = receiver_language
*       NUMBER_OF_LINES                = 10
*       STREET_HAS_PRIORITY            = ' '
*       LINE_PRIORITY                  = ' '
*       COUNTRY_NAME_IN_RECEIVER_LANGU = ' '
*       LANGUAGE_FOR_COUNTRY_NAME      = ' '
*       NO_UPPER_CASE_FOR_CITY         = ' '
*       IV_NATION                      = ' '
*       IV_NATION_SPACE                = ' '
*       IV_PERSON_ABOVE_ORGANIZATION   = ' '
*       IS_BUPA_TIME_DEPENDENCY        = ' '
*       IV_COUNTRY_NAME_SEPARATE_LINE  = ' '
*       IV_LANGU_CREA                  = ' '
*       IV_DISPLAY_COUNTRY_IN_SHRTFORM = ' '
*       BLK_EXCPT                      = BLK_EXCPT
      IMPORTING
*       ADRSWA_OUT                     = ADRSWA_OUT
*       ADDRESS_PRINTFORM              = ADDRESS_PRINTFORM
*       ADDRESS_SHORT_FORM             = ADDRESS_SHORT_FORM
*       ADDRESS_SHORT_FORM_S           = ADDRESS_SHORT_FORM_S
*       ADDRESS_DATA_CARRIER           = ADDRESS_DATA_CARRIER
*       ADDRESS_DATA_CARRIER_0         = ADDRESS_DATA_CARRIER_0
*       NUMBER_OF_USED_LINES           = NUMBER_OF_USED_LINES
*       NAME_IS_EMPTY                  = NAME_IS_EMPTY
*       ADDRESS_NOT_FOUND              = ADDRESS_NOT_FOUND
        address_printform_table        = address_printform_table
*       ADDRESS_SHORT_FORM_WO_NAME     = ADDRESS_SHORT_FORM_WO_NAME
*       EV_NATION                      = EV_NATION
      EXCEPTIONS
        address_blocked                = 1
        person_blocked                 = 2
        contact_person_blocked         = 3
        addr_to_be_formated_is_blocked = 4
        OTHERS                         = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

* - String aufbereiten
    LOOP AT address_printform_table INTO DATA(ls_addrl).
      IF r_value IS NOT INITIAL.
        r_value = r_value && cl_abap_char_utilities=>cr_lf && ls_addrl-address_line.
      ELSE.
        r_value = ls_addrl-address_line.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_archive.

    DATA: l_message TYPE bapiret2,
          lt_data   TYPE STANDARD TABLE OF toaom.

    CLEAR: lt_data.

    CALL FUNCTION 'ARCHIV_METAINFO_GET'
      EXPORTING
        active_flag           = abap_true
        ar_object             = ar_object
        sap_object            = sap_object
      TABLES
        toaom_fkt             = lt_data
      EXCEPTIONS
        error_connectiontable = 1
        error_parameter       = 2
        OTHERS                = 3.
    IF sy-subrc <> 0.
*      message id 'OA' type 'E' number '401' into l_mess.
      l_message-id   = 'OA'.
      l_message-type = 'E'.
      l_message-number = '401'.
      RAISE EXCEPTION TYPE /THKR/CX_LSA1 EXPORTING bapiret2 = l_message.
    ELSE.
      READ TABLE lt_data INTO archiv_data INDEX 1.
    ENDIF.

  ENDMETHOD.


  METHOD get_fieldlist_from_struct.

    DATA: l_structure TYPE tabname,
          lt_dd       TYPE STANDARD TABLE OF dd03l,
          l_fieldlist LIKE LINE OF et_fieldlist,
          l_prefix    TYPE /thkr/structure_field,
          lt_prefix   LIKE STANDARD TABLE OF l_prefix,
          l_depth     TYPE i,
          l_diff      TYPE i,
          l_lfd_nr    TYPE i.

    FIELD-SYMBOLS <dd> LIKE LINE OF lt_dd.

    CLEAR: et_fieldlist.

    l_structure = i_structure.

    SELECT * INTO TABLE lt_dd
      FROM dd03l
      WHERE tabname = l_structure
      AND ( as4local = 'A' OR as4local = 'N' ).

    SORT lt_dd BY position.

    LOOP AT lt_dd ASSIGNING <dd>.

      IF <dd>-fieldname+0(1) = '.'.
*       .INCLUDE
        CONTINUE.
      ENDIF.

      IF <dd>-depth < l_depth.
        l_diff = l_depth - <dd>-depth.

        DO l_diff TIMES.
          DELETE TABLE lt_prefix FROM l_prefix.
          CLEAR l_prefix.

          LOOP AT lt_prefix INTO l_prefix.
          ENDLOOP.
        ENDDO.

      ENDIF.

      l_depth = <dd>-depth.

      IF <dd>-comptype = 'S'.
*       Element vom Typ Struktur
        CLEAR l_fieldlist-fieldname.
        CONCATENATE l_prefix <dd>-fieldname INTO l_fieldlist-fieldname.

        IF l_prefix IS INITIAL.
          CONCATENATE <dd>-fieldname '-' INTO l_prefix.
        ELSE.
          CONCATENATE l_prefix <dd>-fieldname '-' INTO l_prefix.
        ENDIF.
        APPEND l_prefix TO lt_prefix.
        IF i_include_fields_type_s IS INITIAL.
          CONTINUE.
        ENDIF.

      ELSE.
        CLEAR l_fieldlist-fieldname.
        CONCATENATE l_prefix <dd>-fieldname INTO l_fieldlist-fieldname.
        ADD 1 TO l_lfd_nr.
        l_fieldlist-lfd_nr = l_lfd_nr.
      ENDIF.
      l_fieldlist-datatype = <dd>-datatype.
      l_fieldlist-rollname = <dd>-rollname.
      l_fieldlist-ddlen    = <dd>-leng.

      CLEAR: l_fieldlist-scrtext_m, l_fieldlist-scrtext_l.
      IF <dd>-rollname IS NOT INITIAL.
        SELECT SINGLE scrtext_m INTO @l_fieldlist-scrtext_m
          FROM dd04l
            INNER JOIN dd04t ON dd04l~rollname = dd04t~rollname
          WHERE dd04l~rollname = @<dd>-rollname
          AND   ( dd04l~as4local = 'A' OR dd04l~as4local = 'N' OR dd04l~as4local = 'L' ).

        l_fieldlist-scrtext_l = l_fieldlist-scrtext_m.

      ELSE.
        SELECT SINGLE ddtext INTO @l_fieldlist-scrtext_l
          FROM dd03t
          WHERE tabname   = @i_structure
            AND fieldname = @<dd>-fieldname.

        l_fieldlist-scrtext_m = l_fieldlist-scrtext_l.

      ENDIF.

      APPEND l_fieldlist TO et_fieldlist.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_instance.

    IF lsa_helpers IS INITIAL.
      CREATE OBJECT lsa_helpers.
    ENDIF.

    e_reference = lsa_helpers.

  ENDMETHOD.


  METHOD get_lvc_t_fcat_4_itab.

    DATA: lo_columns      TYPE REF TO cl_salv_columns_table,
          lo_aggregations TYPE REF TO cl_salv_aggregations,
          lo_salv_table   TYPE REF TO cl_salv_table.

    FIELD-SYMBOLS: <table> TYPE STANDARD TABLE.

    ASSIGN i_table_ref->* TO <table>.

    TRY.
        cl_salv_table=>factory(
          EXPORTING
            list_display = abap_false
          IMPORTING
            r_salv_table = lo_salv_table
          CHANGING
            t_table      = <table> ).
      CATCH cx_salv_msg.                                "#EC NO_HANDLER
    ENDTRY.

    lo_columns  = lo_salv_table->get_columns( ).
    lo_aggregations = lo_salv_table->get_aggregations( ).

    et_fcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
      EXPORTING
        r_columns             = lo_columns
        r_aggregations        = lo_aggregations ).


  ENDMETHOD.


  METHOD get_rowtype_by_tabletype.

    SELECT SINGLE rowtype INTO e_rowtype
      FROM dd40l
      WHERE typename = i_tabletype
      AND   as4local = 'A'.

    IF sy-subrc <> 0.

      RAISE EXCEPTION TYPE /THKR/CX_LSA1
        EXPORTING
          textid    = /THKR/CX_LSA1=>tabletype_not_found
          tabletype = i_tabletype.

    ENDIF.

  ENDMETHOD.


  METHOD get_seconds_of_day.
    DATA: l_hours     TYPE i,
          l_minutes   TYPE i,
          l_seconds   TYPE i,
          l_timestamp TYPE c LENGTH 14.

    l_timestamp = i_timestamp.

    l_hours    = l_timestamp+8(2).
    l_minutes  = l_timestamp+10(2).
    l_seconds  = l_timestamp+12(2).
    l_seconds = l_hours * 3600 + l_minutes * 60 + l_seconds.
    e_seconds = l_seconds.
    r_seconds = l_seconds.

  ENDMETHOD.


  METHOD get_select_clause_from_struct.

* Felder einer Struktur aus Dictionary lesen, um damit
* eine Selektionsliste für dynamisches SQL aufzubauen

    TYPES: BEGIN OF lty_field,
             position  TYPE tabfdpos,
             fieldname TYPE fieldname,
             domname   TYPE domname,
             datatype  TYPE datatype_d,
           END OF  lty_field.

    DATA: lt_field TYPE STANDARD TABLE OF lty_field,
          l_field  TYPE lty_field,
          l_sfield TYPE c LENGTH 30,
          l_comma  TYPE c,
          l_len    TYPE i.

    SELECT  *
    FROM  dd03l INTO CORRESPONDING FIELDS OF TABLE lt_field
    WHERE  tabname = i_structure
    AND as4local = 'A'
    ORDER BY position.

    IF i_comma_separation IS NOT INITIAL AND strlen( c_select_clause ) > 0.
      l_comma = ','.
    ENDIF.

    LOOP AT  lt_field INTO l_field.

      IF l_field-fieldname+0(1) = '.'.
* .INCLUDE auslassen
        CONTINUE.
      ENDIF.

      IF l_field-datatype = 'TTYP'.
*       Tabellentypen auslassen
        CONTINUE.
      ENDIF.

      READ TABLE it_exclude_fields WITH KEY table_line = l_field-fieldname  TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        "Feld soll ausgelassen werden
        CONTINUE.
      ENDIF.

      CONCATENATE  i_prefix '~' l_field-fieldname INTO  l_sfield.
      CONCATENATE  c_select_clause l_comma l_sfield
        INTO c_select_clause SEPARATED BY space.
      IF i_comma_separation IS NOT INITIAL.
        l_comma = ','.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_type_by_structure_field.

    DATA: l_dd03l TYPE dd03l.

    SELECT SINGLE * INTO l_dd03l
      FROM dd03l
      WHERE tabname = i_structure
      AND fieldname = i_fieldname
      AND ( as4local = 'A' OR as4local = 'N' ).

    IF sy-subrc <> 0.

      RAISE EXCEPTION TYPE /THKR/CX_LSA1
        EXPORTING
          textid    = /THKR/CX_LSA1=>structure_field_not_found
          structure = i_structure
          fieldname = i_fieldname.

    ENDIF.

    e_rollname = l_dd03l-rollname.
    e_datatype = l_dd03l-datatype.

  ENDMETHOD.


  METHOD get_type_of_parameter.

    DATA: l_para    TYPE vseomepara,
          l_message TYPE string.

    CLEAR: e_type, e_description.

    SELECT SINGLE * INTO l_para
      FROM vseomepara
      WHERE clsname = i_clsname
      AND   cmpname = i_method
      AND   sconame = i_parameter
      AND   version = '1'
      AND   langu   = 'D'.

    IF sy-subrc = 0.
      e_type        = l_para-type.
      e_description = l_para-descript.
    ELSE.
      CONCATENATE i_clsname '-' i_method INTO l_message.
      CONCATENATE 'Method' l_message 'has no parameter' i_parameter '!' INTO l_message SEPARATED BY space.

      RAISE EXCEPTION TYPE /THKR/CX_LSA1
        EXPORTING
          textid = /THKR/CX_LSA1=>/THKR/CX_LSA1
          mess   = l_message.
    ENDIF.

  ENDMETHOD.


  METHOD gui_download_xstring.

    TYPES lty_result TYPE x LENGTH 1024.

    DATA: lt_result  TYPE STANDARD TABLE OF lty_result,
          l_filesize TYPE i,
          l_offset   TYPE i.

*   xstring in interne Tabelle schreiben
    l_filesize = xstrlen( i_xstring ).
    l_offset = 0.
    DO.
      APPEND i_xstring+l_offset TO lt_result.
      l_offset = l_offset + 1024.
      IF l_offset > l_filesize.
        EXIT.
      ENDIF.
    ENDDO.

    TRY.
        cl_gui_frontend_services=>gui_download(
            EXPORTING bin_filesize = l_filesize
                         filename  = i_filename
                         filetype  = 'BIN'
            CHANGING     data_tab  = lt_result ).
      CATCH cx_root INTO DATA(l_oerror).

        display_exception( l_oerror ).

    ENDTRY.

  ENDMETHOD.


  METHOD remove_leading_zeros.

    DESCRIBE FIELD c_value TYPE DATA(l_type).

    IF 'Cg' CA l_type.

      DATA(l_len) = strlen( c_value ).

      WHILE c_value(1) = '0' AND l_len > 1.
        l_len = l_len - 1.
        c_value = c_value+1(l_len).
      ENDWHILE.

    ENDIF.

  ENDMETHOD.


  METHOD uncompress_xstring.

    DATA: l_gzipstr TYPE xstring.

    CLEAR: e_xstring.

    LOOP AT it_x255 INTO DATA(l_x255).
      CONCATENATE l_gzipstr l_x255 INTO l_gzipstr IN BYTE MODE.
    ENDLOOP.

    IF l_gzipstr IS NOT INITIAL.
      TRY.
          cl_abap_gzip=>decompress_binary(
            EXPORTING
              gzip_in     = l_gzipstr
*           gzip_in_len = -1
            IMPORTING
              raw_out     = e_xstring
*           raw_out_len =
                 ).
        CATCH cx_root INTO DATA(l_oerror).

          display_exception( i_oerror = l_oerror ).


      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD uncompress_xstring1.

    cl_abap_gzip=>decompress_binary(
      EXPORTING
        gzip_in     = i_xstring
*           gzip_in_len = -1
      IMPORTING
        raw_out     = e_xstring
*           raw_out_len =
           ).

  ENDMETHOD.


  METHOD get_xml_escaping.

    REPLACE ALL OCCURRENCES OF '&' IN cv_xmlstring WITH '&amp;'. "#EC NOTEXT
    REPLACE ALL OCCURRENCES OF '<' IN cv_xmlstring WITH '&lt;'. "#EC NOTEXT
    REPLACE ALL OCCURRENCES OF '>' IN cv_xmlstring WITH '&gt;'. "#EC NOTEXT
    REPLACE ALL OCCURRENCES OF '"' IN cv_xmlstring WITH '&quot;'. "#EC NOTEXT

  ENDMETHOD.
ENDCLASS.
