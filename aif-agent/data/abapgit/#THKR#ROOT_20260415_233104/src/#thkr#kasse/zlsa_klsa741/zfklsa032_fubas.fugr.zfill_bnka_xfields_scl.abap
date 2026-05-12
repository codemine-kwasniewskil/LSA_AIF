FUNCTION zfill_bnka_xfields_scl.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BANKS) LIKE  BNKA-BANKS
*"     VALUE(I_VERS) LIKE  T005BU-VERS
*"     VALUE(I_XPC) LIKE  RF02B-BANKXFPR
*"     VALUE(I_MAX_REC) LIKE  RFPDO_BF-MAX_REC
*"     VALUE(I_KEYTYPE) LIKE  T005-BNKEY DEFAULT '1'
*"  EXPORTING
*"     VALUE(CNT_SREADTO) LIKE  RF02B-COUNTER
*"     VALUE(E_OPTIMIZED) TYPE  XFELD
*"  TABLES
*"      ITAB_BNKA STRUCTURE  BNKA
*"      TAB_FILE STRUCTURE  RLGRAP
*"----------------------------------------------------------------------
*"---Hinweis 1680894  Einlesen SCL CT-----------------------------------
*"----------------------------------------------------------------------
  DATA: BEGIN OF xml_line,
          data(256) TYPE x,
        END OF xml_line,
        xml_table LIKE TABLE OF xml_line,
        filename TYPE string,
        pixml          TYPE REF TO if_ixml,
        pdocument      TYPE REF TO if_ixml_document,
        pstreamfactory TYPE REF TO if_ixml_stream_factory,
        pistream       TYPE REF TO if_ixml_istream,
        pparser        TYPE REF TO if_ixml_parser,
        pnode          TYPE REF TO if_ixml_node,
        size           TYPE i,
        totalsize      TYPE i.

  LOOP AT tab_file.
*-- Upload file -------------------------------------------------------
    filename = tab_file-filename.
    IF i_xpc IS INITIAL.
      OPEN DATASET filename FOR INPUT IN BINARY MODE.
      DO.
        READ DATASET filename INTO xml_line-data.
        IF xml_line-data IS INITIAL.
          CLOSE DATASET filename.
          EXIT.
        ELSE.
          APPEND xml_line TO xml_table.
          DESCRIBE FIELD xml_line-data LENGTH size IN BYTE MODE.
          ADD size TO totalsize.
        ENDIF.
      ENDDO.
    ELSE.
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename   = filename
          filetype   = 'BIN'
        IMPORTING
          filelength = totalsize
        TABLES
          data_tab   = xml_table
        EXCEPTIONS
          OTHERS     = 11.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        EXIT.
      ENDIF.
    ENDIF.
*-- Create XML stream ------------------------------------------------
    CLASS cl_ixml DEFINITION LOAD.
    pixml = cl_ixml=>create( ).
    pdocument = pixml->create_document( ).
    pstreamfactory = pixml->create_stream_factory( ).
    pistream = pstreamfactory->create_istream_itable(
      table = xml_table
      size = totalsize ).
    pparser = pixml->create_parser(
      stream_factory = pstreamfactory
      istream        = pistream
      document       = pdocument ).
    CHECK NOT pparser IS INITIAL.
    CHECK pparser->parse( ) = 0.
    CALL METHOD pistream->close( ).
    CLEAR pistream.
    pnode ?= pdocument.
*-- Convert XML data to BNKA structure --------------------------------
    PERFORM convert_xml_nodes_to_itab USING pnode CHANGING itab_bnka[].
  ENDLOOP.
  IF itab_bnka[] IS INITIAL.
    APPEND itab_bnka.
  ELSE.
    SORT itab_bnka BY banks bankl.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  convert_xml_nodes_to_itab
*&---------------------------------------------------------------------*
FORM convert_xml_nodes_to_itab
  USING value(pnode) TYPE REF TO if_ixml_node
  CHANGING t_bnka TYPE table.

  STATICS:
        BEGIN OF st_bic,
          status(10),
          bic(11),
          banka(105),
          product(20),
          from_datum(10),
        END OF st_bic.
  DATA: pnodeinfo  TYPE REF TO if_ixml_node,
        BEGIN OF wa_xml_element,
          elementname   TYPE string,
          elementvalue  TYPE string,
          elementtype   TYPE i,
        END OF wa_xml_element,
        wa_bnka LIKE bnka,
        l_ftype,
        lp_element  TYPE REF TO if_ixml_element.

  CLEAR: wa_xml_element.
  PERFORM get_file_type USING l_ftype.
* Parse node ----------------------------------------------------------
  IF pnode->get_type( ) = if_ixml_node=>co_node_element.
    lp_element ?= pnode->query_interface( ixml_iid_element ).
    wa_xml_element-elementname = pnode->get_name( ).
    wa_xml_element-elementvalue = lp_element->get_value( ).
    CASE wa_xml_element-elementname.
      WHEN 'RchEntry'.
        CLEAR st_bic.
      WHEN 'Status'.
        st_bic-status = wa_xml_element-elementvalue.
      WHEN 'FrDtTm'.
        st_bic-from_datum = wa_xml_element-elementvalue.
        TRANSLATE st_bic-from_datum USING '- '.
        CONDENSE st_bic-from_datum NO-GAPS.
      WHEN 'BIC'.
        st_bic-bic = wa_xml_element-elementvalue.
      WHEN 'Nm'.
        st_bic-banka = wa_xml_element-elementvalue.
      WHEN 'ProductName'.
        st_bic-product = wa_xml_element-elementvalue.
    ENDCASE.
  ENDIF.
* Get next node (recursively) -----------------------------------------
  pnode = pnode->get_first_child( ).
  WHILE NOT pnode IS INITIAL.
    PERFORM convert_xml_nodes_to_itab USING pnode CHANGING t_bnka.
    pnode = pnode->get_next( ).
  ENDWHILE.
* Store converted data ------------------------------------------------
  CHECK NOT st_bic-bic IS INITIAL.    "only banks with a BIC
  CHECK NOT st_bic-banka IS INITIAL.  "only banks with a name
  CHECK st_bic-product(3) = 'SCT'.    "only SEPA credit transfer
  IF l_ftype = 'F'.
    CHECK st_bic-status NE 'deleted'. "only existing banks
  ELSEIF st_bic-status = 'deleted'.
    wa_bnka-loevm = 'X'.
  ENDIF.
* CHECK st_bic-from_datum < sy-datum. "only banks in validity period
  wa_bnka-banks = st_bic-bic+4(2).
  wa_bnka-banka = st_bic-banka.
  wa_bnka-swift = st_bic-bic.
  APPEND wa_bnka TO t_bnka.
  CLEAR: wa_bnka, st_bic.

ENDFORM.                    "convert_xml_nodes_to_itab

*&---------------------------------------------------------------------*
*&      Form  get_file_type
*&---------------------------------------------------------------------*
FORM get_file_type CHANGING ftype.

  FIELD-SYMBOLS: <ftype>.
  DATA: hlp_txt(30).
  STATICS: s_ftype.         "F - full file, D - delta file

  IF s_ftype IS INITIAL.
    CONCATENATE '(' sy-cprog ')p_lodel' INTO hlp_txt.
    ASSIGN (hlp_txt) TO <ftype>.
    IF NOT <ftype> IS ASSIGNED.
      s_ftype = 'F'.
    ELSEIF <ftype> IS INITIAL.
      s_ftype = 'F'.
    ELSE.
      s_ftype = 'D'.
    ENDIF.
  ELSE.
    ftype = s_ftype.
  ENDIF.

ENDFORM.                    "get_file_type
