class /THKR/CL_IM_BP_ADDR_SEARCH definition
  public
  final
  create public

  global friends CL_IM_SIC_RULESET_MAINTENANCE .

public section.

  interfaces IF_EX_ADDRESS_SEARCH .

  constants GC_TYPE_ORGANIZATION type ICM_E_DUPL_TYPE value 'Organization' ##NO_TEXT.
  constants GC_TYPE_PERSON type ICM_E_DUPL_TYPE value 'Person' ##NO_TEXT.
  constants GC_TYPE_CONTACT type ICM_E_DUPL_TYPE value 'Contact' ##NO_TEXT.
  constants GC_TYPE_ADDR_INDP type ICM_E_DUPL_TYPE value 'Address-Independent' ##NO_TEXT.
PROTECTED SECTION.

  TYPES: BEGIN OF lty_auth_list,
           partner TYPE bu_partner,
           adr_ref TYPE ad_addrnum,
         END OF lty_auth_list,

         lty_t_auth_list TYPE STANDARD TABLE OF lty_auth_list.

  TYPES:
    lty_t_key_columns TYPE STANDARD TABLE OF string .
  TYPES:
    BEGIN OF lty_s_search_in_type,
      type  TYPE ad_adrtype,
      value TYPE t_boole,
    END OF lty_s_search_in_type .
  TYPES:
    lty_t_search_in_type TYPE STANDARD TABLE OF lty_s_search_in_type WITH NON-UNIQUE DEFAULT KEY .
  TYPES:
    BEGIN OF lty_s_icm_fields,
      score      TYPE f,
      rule_id    TYPE string,
      type       TYPE string,
      persnumber TYPE ad_persnum,
      addrnumber TYPE ad_addrnum,
    END OF lty_s_icm_fields .
  TYPES:
    lty_t_icm_fields  TYPE STANDARD TABLE OF lty_s_icm_fields WITH NON-UNIQUE DEFAULT KEY .
  TYPES:
    BEGIN OF lty_s_icm_errors,
      ruleset_id    TYPE icm_e_dupl_ruleset_id,
      appl_table    TYPE icm_e_dupl_appl_table,
      entity_type   TYPE icm_e_dupl_type,
      viewname      TYPE icm_e_dupl_viewname,
      error_message TYPE bapiret2,
    END OF lty_s_icm_errors.

  TYPES lty_t_icm_errors TYPE STANDARD TABLE OF lty_s_icm_errors WITH NON-UNIQUE KEY ruleset_id appl_table entity_type.

  CLASS-METHODS read_table
    IMPORTING
      !iv_tabname TYPE tabname
      !is_key     TYPE string
    EXPORTING
      !es_data    TYPE esh_s_int_cluster .
private section.

  class-data GT_FIELD_LIST_1 type ADFLDLIST .
  class-data GT_FIELD_LIST_2 type ADFLDLIST .
  class-data GT_FIELD_LIST_3 type ADFLDLIST .
  class-data GR_CONN type DBCON_NAME .
  class-data GR_PROXY type ref to CL_ESH_TREX_PROXY_RUNTIME .
  class-data GV_SCHEMA type ESH_E_HDB_DBSCHEMA .
  class-data GR_RULESET_MAINTENANCE type ref to CL_IM_SIC_RULESET_MAINTENANCE .

  class-methods CHECK_DUPLICATE_SWITCHED_OFF
    importing
      !IM_T_OBJECT_TYPES type ADREF_INDX_TAB
      !IM_T_SEARCH_FIELDS type ADSRCHLIST
    exporting
      !EV_SWITCHED_OFF type ABAP_BOOL .
  class-methods CHECK_CONSIDER_AUTHORIZATION
    exporting
      !EV_SACF_MODE type CHAR1 .
  class-methods CHECK_CONNECTION
    exporting
      !EV_ERROR type ABAP_BOOL
      !EV_ERROR_TEXT type BAPI_MSG .
  class-methods BUILD_TYPES_FOR_SEARCH
    importing
      !IM_SEARCH_IN_TYPE_1 type T_BOOLE default SPACE
      !IM_SEARCH_IN_TYPE_2 type T_BOOLE default SPACE
      !IM_SEARCH_IN_TYPE_3 type T_BOOLE default SPACE
      !IM_S_OBJECT_TYPES type ADREF_INDX
      !IM_SEARCH_MODE type AD_DUPMODE
    exporting
      !ET_SEARCH_IN_TYPE type LTY_T_SEARCH_IN_TYPE
      !EV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE .
  class-methods GET_RULE_SET
    importing
      !IV_TYPE type AD_ADRTYPE
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IV_FOR_DUPL_CHECK type ICM_E_FOR_DUPL_CHECK optional
      !IV_FOR_VALUE_HELP type ICM_E_FOR_VALUE_HELP optional
    exporting
      !ET_RULESET type ICM_T_DUPL_RULESET
      !EV_NOT_FOUND type ABAP_BOOL
      !EV_NOT_VALID type ABAP_BOOL
      !ES_VALIDATION_ERROR type BAPIRET2 .
  class-methods BUILD_CALL
    importing
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IV_TYPE type AD_ADRTYPE
      !IS_RULESET type ICM_DUPL_RULESET
      !IT_SEARCH_FIELDS type ADSRCHLIST
      !IV_SEARCH_MODE type AD_DUPMODE
      !IV_SACF_MODE type CHAR1
    exporting
      !EV_INPUT_XML type STRING
      !EV_VALID type ABAP_BOOL
      !ES_REASON type STRING
      !ES_OFFSET_STRING type STRING
      !EV_NRHITS_REQUESTED type CHAR5
      !EV_DO_NOT_SEARCH type ABAP_BOOL .
  class-methods ADAPT_FIELDS_TABLE
    importing
      !IV_TYPE type AD_ADRTYPE
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IS_RULESET type ICM_DUPL_RULESET
      !IT_SEARCH_FIELDS type ADSRCHLIST
    exporting
      !ET_SEARCH_FIELDS type ADSRCHLIST .
  class-methods INSERT_KEYS_INTO_RULESET
    importing
      !IS_RULESET type STRING
      !IV_SCHEMA type ESH_E_HDB_DBSCHEMA
      !IV_VIEW_NAME type ICM_E_DUPL_VIEWNAME
      !IT_KEY_COLUMNS type LTY_T_KEY_COLUMNS
    changing
      value(RS_RULESET) type ICM_E_DUPL_RULESET .
  class-methods APPEND_SEARCH_CONDITIONS
    importing
      !IT_SEARCH_FIELDS type ADSRCHLIST
    changing
      value(RV_INPUT_XML) type ICM_E_DUPL_RULESET .
  class-methods APPEND_RESULTCOLUMNS
    importing
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IV_ENTITY_TYPE type ICM_E_DUPL_TYPE
    changing
      value(RV_INPUT_XML) type ICM_E_DUPL_RULESET .
  class-methods APPEND_FILTER
    importing
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IV_ENTITY_TYPE type ICM_E_DUPL_TYPE
      !IV_SACF_MODE type CHAR1
    changing
      value(RV_INPUT_XML) type ICM_E_DUPL_RULESET .
  class-methods GET_ENTITY_TYPE
    importing
      !IV_TECH_ID type BU_TYPE
    returning
      value(RV_ENTITY_TYPE) type ICM_E_DUPL_TYPE .
  class-methods PARSE_XML
    importing
      !IS_XML_STRING type STRING
    exporting
      !EV_VALID type BOOLE_D
      !ES_REASON type STRING
      !ES_OFFSET_STRING type STRING
    exceptions
      NOT_PARSED .
  class-methods EXECUTE_SEARCH
    importing
      !IS_XML_STRING type STRING
      !IV_ENTITY_TYPE type ICM_E_DUPL_TYPE
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
    exporting
      !ET_SEARCH_RESULTS type LTY_T_ICM_FIELDS
      !ES_ERROR type STRING .
  class-methods FILL_RESULT_TABLE
    importing
      !IT_SEARCH_RESULTS_ALL type LTY_T_ICM_FIELDS
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IV_THRESHOLD type AD_THRESHD
      !IV_SEARCH_MODE type AD_DUPMODE
      !IV_CURRENT_ADDRESS_KEY type ADKEY_INDX
      !IV_NRHITS_REQUESTED type CHAR5
    exporting
      !ET_SEARCH_RESULTS type ADKEY_INDX_TAB
      !EV_NUMBER_OF_HITS type INT4 .
  class-methods CHECK_IF_POPUP_REQUIRED
    importing
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IV_SEARCH_MODE type AD_DUPMODE
      !IT_SEARCH_RESULTS type ADKEY_INDX_TAB
    exporting
      !EV_SEARCH_STATUS type AD_DUPSTAT
      !EV_POPUP_REQUIRED type BOOLE_D .
  class-methods BUILD_TABLE_4_AUTH_CHECK
    importing
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IT_SEARCH_RESULTS type ADKEY_INDX_TAB
    exporting
      !ET_AUTH_RESULTS type LTY_T_AUTH_LIST .
  class-methods BUILD_TABLE_4_DISPLAY
    importing
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IT_SEARCH_RESULTS type ADKEY_INDX_TAB
    exporting
      !ET_DISP_RESULTS type SIC_T_DISP_DUPL
      !ES_DATA type ESH_S_INT_CLUSTER .
  class-methods GET_OWNER_OBJECT
    importing
      !IV_ADDRNUMBER type AD_ADDRNUM
      !IV_PERSNUMBER type AD_PERSNUM
      !IV_APPL_TABLE type ICM_E_DUPL_APPL_TABLE
      !IV_ADDRESS_TYPE type AD_ADRTYPE
    exporting
      !EV_KUNNR type SIC_KUNNR
      !EV_LIFNR type SIC_LIFNR
      !EV_PARTNER type BU_PARTNER
      !ES_ADDR_VALUE type ADDR1_VAL
      !ES_DATA type ESH_S_INT_CLUSTER .
  class-methods CHECK_FOR_ERRORS
    importing
      !IT_SEARCH_RESULT type ADKEY_INDX_TAB
      !IT_ERRORS type LTY_T_ICM_ERRORS
    exporting
      !EV_RAISE_EXCEPTION type ABAP_BOOL
      !EV_SEARCH_STATUS type AD_DUPSTAT .
  class-methods ESCAPE_XML_CHARS_IN_STRING
    importing
      !IS_INPUT type STRING
    returning
      value(RS_INPUT_ESCAPED) type STRING .
  class-methods CHECK_ALL_FIELDS_ARE_EMPTY
    importing
      !IT_FIELDS type ADSRCHLIST
    returning
      value(RV_EMPTY) type ABAP_BOOL .
ENDCLASS.



CLASS /THKR/CL_IM_BP_ADDR_SEARCH IMPLEMENTATION.


METHOD ADAPT_FIELDS_TABLE.

  " depending on which view is to be searched, the input table of fields ( maintained by user ) should be extended correspondingly

  DATA: lv_name1       TYPE string,
        lv_name2       TYPE string,
        ls_name1_name2 TYPE string.

  et_search_fields = it_search_fields.

  " if search for duplicates in BUT000, organization  --> needs NAME1 and optional NAME2
  " if search for duplicates in BUT000, address_independent  --> needs NAME1 and optional NAME2
  " if NAME_LAST and NAME_FIRST given --> change them to NAME1 and NAME2

  " if search for contacts in Customer ( table KNVK ) --> match NAME_LAST and NAME_FIRST to NAME1 and NAME2

  IF ( ( iv_appl_table = 'BUT000' OR iv_appl_table = 'KNA1' ) AND iv_type = '1' ) OR
     ( iv_appl_table = 'BUT000'  AND iv_type = '4' ).

    READ TABLE et_search_fields WITH KEY fieldname = 'NAME1' TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      READ TABLE et_search_fields INTO DATA(ls_search_fields) WITH KEY fieldname = 'NAME_LAST'.
      IF sy-subrc = 0.
        lv_name1 = ls_search_fields-content.
        MOVE: 'NAME1'   TO ls_search_fields-fieldname,
              lv_name1  TO ls_search_fields-content.
        APPEND ls_search_fields TO et_search_fields.
      ENDIF.
    ENDIF.

    READ TABLE et_search_fields WITH KEY fieldname = 'NAME2' TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      READ TABLE et_search_fields INTO ls_search_fields WITH KEY fieldname = 'NAME_FIRST'.
      IF sy-subrc = 0.
        lv_name2 = ls_search_fields-content.
        MOVE: 'NAME2'   TO ls_search_fields-fieldname,
              lv_name2  TO ls_search_fields-content.
        APPEND ls_search_fields TO et_search_fields.
      ENDIF.
    ENDIF.

    " eliminate the unsuitable fields for organization
    DELETE et_search_fields WHERE fieldname = 'NAME_LAST' OR fieldname = 'NAME_FIRST'.

  ENDIF.

  " if search for duplicates in BUT000, person  --> needs NAME_LAST  and optional NAME_FIRST
  " if NAME1 and NAME2 given --> change them to NAME_LAST and NAME_FIRST

  IF ( iv_appl_table = 'BUT000' OR iv_appl_table = 'KNA1' ) AND iv_type = '2'.
    READ TABLE et_search_fields WITH KEY fieldname = 'NAME_LAST' TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      READ TABLE et_search_fields INTO ls_search_fields WITH KEY fieldname = 'NAME1'.
      IF sy-subrc = 0.
        lv_name1 = ls_search_fields-content.
        MOVE: 'NAME_LAST' TO ls_search_fields-fieldname,
              lv_name1    TO ls_search_fields-content.
        APPEND ls_search_fields TO et_search_fields.
      ENDIF.
    ENDIF.
    READ TABLE et_search_fields WITH KEY fieldname = 'NAME_FIRST' TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      READ TABLE et_search_fields INTO ls_search_fields WITH KEY fieldname = 'NAME2'.
      IF sy-subrc = 0.
        lv_name2 = ls_search_fields-content.
        MOVE: 'NAME_FIRST' TO ls_search_fields-fieldname,
              lv_name2     TO ls_search_fields-content.
        APPEND ls_search_fields TO et_search_fields.
      ENDIF.
    ENDIF.

    " eliminate the unsuitable fields for person
    DELETE et_search_fields WHERE fieldname = 'NAME1' OR fieldname = 'NAME2'.
  ENDIF.

  " if search for duplicates in BUT000, address-independent  --> gets NAME1 and optional NAME2
  " if a contact to BUT000 should be checked against address-independent --> move NAME_LAST to NAME1 and NAME_FIRST to NAME2 ( check contact and not organization )
  " delete all the address fields (CITY1, POST_CODE1, STREET,HOUSE_NUM1, COUNTRY and REGION)
  IF iv_appl_table = 'BUT000'  AND iv_type = '4'.

    " check if contact ( NAME_LAST is available )
    READ TABLE et_search_fields WITH KEY fieldname = 'NAME_LAST' TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      " delete NAME1 and NAME2 of the organization
      DELETE et_search_fields WHERE fieldname = 'NAME1' OR fieldname = 'NAME2'.

      " move NAME_LAST to NAME1 and NAME_FIRST to NAME2
      READ TABLE et_search_fields INTO ls_search_fields WITH KEY fieldname = 'NAME_LAST'.
      IF sy-subrc = 0.
        lv_name1 = ls_search_fields-content.
        MOVE: 'NAME1    ' TO ls_search_fields-fieldname,
              lv_name1    TO ls_search_fields-content.
        APPEND ls_search_fields TO et_search_fields.
      ENDIF.
      READ TABLE et_search_fields INTO ls_search_fields WITH KEY fieldname = 'NAME_FIRST'.
      IF sy-subrc = 0.
        lv_name1 = ls_search_fields-content.
        MOVE: 'NAME2'     TO ls_search_fields-fieldname,
              lv_name1    TO ls_search_fields-content.
        APPEND ls_search_fields TO et_search_fields.
      ENDIF.

    ENDIF.  " contact data

    DELETE et_search_fields WHERE fieldname NE 'NAME1' AND fieldname NE 'NAME2' AND fieldname NE 'TELNR_LONG' AND fieldname NE 'SMTP_ADDR'.
  ENDIF.


  " if search for duplicates in BUT000, contact  --> gets in it_search_fields NAME1 and optional NAME2 ( the name of the organization to which the contact will be assigned )
  "                                              --> gets in it_search_fields NAME_LAST and optional NAME_FIRST ( name of the person to be a contact )
  " nothing to match for BUT000 contact


  " if search for contacts in Vendor  --> match NAME_LAST and NAME_FIRST to NAME1 and NAME2
  " because contacts will be checked against vendor. There is no view for contacts for vendor

  IF ( iv_appl_table = 'LFA1' ) AND iv_type = '1'.

    LOOP AT et_search_fields INTO ls_search_fields WHERE fieldname = 'NAME_LAST' OR fieldname = 'NAME_FIRST'.
      IF ls_name1_name2 IS INITIAL.
        MOVE ls_search_fields-content TO ls_name1_name2.
      ELSE.
        CONCATENATE ls_name1_name2 ls_search_fields-content INTO ls_name1_name2 SEPARATED BY space.
      ENDIF.
    ENDLOOP.

    READ TABLE et_search_fields INTO ls_search_fields WITH KEY fieldname = 'NAME1'.
    IF sy-subrc = 0.
      IF ls_search_fields-content IS INITIAL.
        MOVE ls_name1_name2 TO ls_search_fields-content.
        MODIFY et_search_fields FROM ls_search_fields INDEX sy-tabix.
      ENDIF.
    ELSE.
      MOVE: 'ADRC'         TO ls_search_fields-tablename,
            'NAME1'        TO ls_search_fields-fieldname,
            ls_name1_name2 TO ls_search_fields-content.
      APPEND ls_search_fields TO et_search_fields.
    ENDIF.

    " eliminate the unsuitable fields for person
    DELETE et_search_fields WHERE fieldname = 'NAME_FIRST'.
    DELETE et_search_fields WHERE fieldname = 'NAME_LAST'.
  ENDIF.


  " check if the given fields for search ( it_search_fields ) are all contained in the view of the corresponding ruleset
  " search conditions are alowwed only for the fields from the view ( e.g. DEPARTMENT is not contained in ICM_PARTNER_CONT )

  DATA: it_view_fields TYPE TABLE OF dd27p.
  CLEAR ls_search_fields.

  CALL FUNCTION 'DDIF_VIEW_GET'
    EXPORTING
      name          = is_ruleset-viewname
*     STATE         = 'A'
    TABLES
*     DD26V_TAB     =
      dd27p_tab     = it_view_fields
*     dd28j_tab     =
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF it_view_fields IS NOT INITIAL.
    LOOP AT et_search_fields INTO ls_search_fields.
      DATA(lv_tabix) = sy-tabix.
      READ TABLE it_view_fields WITH KEY viewfield = ls_search_fields-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        DELETE et_search_fields INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD APPEND_FILTER.

  DATA: ls_filter TYPE string,
        ls_auth   TYPE string,
        lv_tabix  LIKE sy-tabix.


  "  MANDT is filter for each object
  ls_filter = | <filter>"MANDT"=''{ sy-mandt }''|.

  CASE iv_appl_table.
    WHEN 'BUT000'.
      IF iv_entity_type = gc_type_organization.
        ls_filter = |{ ls_filter }| &&
*                    | AND ("PERSNUMBER"='''' OR "PERSNUMBER" is NULL)| &&
*                    | AND ("PERSNUMBER_ADR6" ='''' OR "PERSNUMBER_ADR6" is NULL)| &&
                    | AND ("TYPE"=2 OR "TYPE" = 3)|.   " organization or group


      ELSEIF iv_entity_type = gc_type_person.
        ls_filter = |{ ls_filter }| &&
                    | AND ("PERSNUMBER"="PERSNUMBER_ADR2" OR "PERSNUMBER_ADR2"='''' OR "PERSNUMBER_ADR2" is NULL)| &&
                    | AND ("PERSNUMBER"="PERSNUMBER_ADR6" OR "PERSNUMBER_ADR6"='''' OR "PERSNUMBER_ADR6" is NULL)| .


      ENDIF.


    WHEN 'BUT052' OR  'MOM052'.
      " only MANDT and eventl. authorization filter


     WHEN 'KNA1' OR 'LFA1' .
      " only MANDT , no authorization filter for KNA1 and LFA1
      " ls_filter = | <filter>"MANDT"=''{ sy-mandt }''|.

  ENDCASE.

" add authorization conditions, if SACF is activated
  IF iv_sacf_mode IS NOT INITIAL AND    " A (active) or L (logging )
    cl_bupa_shlp_auth_check=>gt_auth_selopt IS NOT INITIAL .

    " 1.  AND ("AUGRP" = ''''
    " 2.  AND ("AUGRP" = '''' OR "AUGRP" = ''A1'' ... OR "AUGRP" = ''An''

    ls_auth = | AND (|.

    LOOP AT cl_bupa_shlp_auth_check=>gt_auth_selopt INTO DATA(ls_auth_selopt).

      lv_tabix = sy-tabix.
      IF lv_tabix = 1.

        IF ls_auth_selopt-low IS INITIAL.
          ls_auth = |{ ls_auth }| &&
                    | "{ ls_auth_selopt-shlpfield }" = ''''|.
        ELSE.
          ls_auth = |{ ls_auth }| &&
                    | "{ ls_auth_selopt-shlpfield }" = ''{ ls_auth_selopt-low }''|.
        ENDIF.

      ELSEIF lv_tabix > 1 .

        IF ls_auth_selopt-low IS INITIAL.
          ls_auth = |{ ls_auth }| &&
                    |OR "{ ls_auth_selopt-shlpfield }" = ''''|.
        ELSE.
          ls_auth = |{ ls_auth }| &&
                    |OR "{ ls_auth_selopt-shlpfield }" = ''{ ls_auth_selopt-low }''|.
        ENDIF.

      ENDIF.  " IF lv_tabix = 1.
    ENDLOOP.

    " add the close bracket
    ls_auth = |{ ls_auth }| &&
              | )|.

  ENDIF.  " IF iv_sacf_mode IS NOT INITIAL AN

  " close the filter

  IF iv_appl_table NE 'KNA1' AND
     iv_appl_table NE 'LFA1' .
    rv_input_xml = |{ rv_input_xml }{ ls_filter } { ls_auth }|  &&
                   |</filter></query> ')|.
  ELSE.
    rv_input_xml = |{ rv_input_xml }{ ls_filter }|  &&
                   |</filter></query> ')|.
  ENDIF.

ENDMETHOD.


METHOD APPEND_RESULTCOLUMNS.

  DATA: ls_resultcolumns   TYPE string.

  " for BUT000, BUT052, MOM052, Customer and Vendor
  " _SCORE, _RULE_ID and ADDRNUMBER  will be alwasy delivered from the search
  ls_resultcolumns = |{ ls_resultcolumns }| &&
                         |<resultsetcolumn name="_SCORE" />| &&
                         |<resultsetcolumn name="_RULE_ID" />| &&
                         | <resultsetcolumn name="ADDRNUMBER" />| .

  CASE iv_appl_table.

    WHEN 'BUT000'.

      " for organization and person
      IF iv_entity_type NE gc_type_contact AND iv_entity_type NE gc_type_addr_indp.
        ls_resultcolumns = |{ ls_resultcolumns }| &&
                           |<resultsetcolumn name="TYPE" />| &&
                           |<resultsetcolumn name="PERSNUMBER" />|.

      " for contact
      ELSEIF iv_entity_type = gc_type_contact.
        ls_resultcolumns = |{ ls_resultcolumns }| &&
                           |<resultsetcolumn name="PERSNUMBER" />|.

      " for address independent
      ELSEIF iv_entity_type = gc_type_addr_indp.
        ls_resultcolumns = |{ ls_resultcolumns }| &&
                           |<resultsetcolumn name="TYPE" />| &&
                           |<resultsetcolumn name="PERSNUMBER" />|.
      ENDIF.

    WHEN 'BUT052' OR 'MOM052' OR 'KNA1' OR 'KNVK'.

      ls_resultcolumns = |{ ls_resultcolumns }| &&
                         |<resultsetcolumn name="PERSNUMBER" />|.
  ENDCASE.

  rv_input_xml = |{ rv_input_xml }{ ls_resultcolumns }|.

ENDMETHOD.


METHOD APPEND_SEARCH_CONDITIONS.

  DATA: ls_search_condition   TYPE string.

  LOOP AT it_search_fields INTO DATA(ls_search_field).
    " take only the maintained fields ( which have content <> initial )
    " check the content against SQL injection
    IF NOT ls_search_field-content IS INITIAL.

      ls_search_condition =  |{ ls_search_condition }| &&
                             |<column name="{ ls_search_field-fieldname }">{ escape_xml_chars_in_string( is_input = CONV #( ls_search_field-content ) )  }</column>|.
    ENDIF.
  ENDLOOP.

  rv_input_xml = |{ rv_input_xml }{ ls_search_condition }|.

ENDMETHOD.


METHOD BUILD_CALL.

  DATA: lv_teil_string TYPE string,
        lv_auth_string TYPE string,
        lt_key_columns TYPE TABLE OF string,
        lv_input_xml   TYPE string,
        lv_has_data    TYPE abap_bool.

  " extend the search fields (if needed) based on appl. table and type
  adapt_fields_table(
    EXPORTING
      iv_type          = iv_type
      iv_appl_table    = iv_appl_table
      is_ruleset       = is_ruleset
      it_search_fields = it_search_fields
    IMPORTING
      et_search_fields = DATA(lt_t_search_fields) ).


  " if no fields available for search --> do not perform the search for duplicates
  " no fields for search in the case:  search address_independent is activated and the search fields are only address fields ( they all are delted in this case )
  IF check_all_fields_are_empty( it_fields = lt_t_search_fields ) = abap_true.
    ev_do_not_search = abap_true.
    RETURN.
  ELSE.
    IF iv_type = '4'. " gc_type_addr_indp  " address-independent search - check if at least one address-independent query condition is filled
      CLEAR lv_has_data.
      LOOP AT lt_t_search_fields ASSIGNING FIELD-SYMBOL(<fs_fields>).
        IF <fs_fields>-content IS NOT INITIAL.
          lv_has_data = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_has_data IS INITIAL. " no entry found wíth a query condition (content value)
        ev_do_not_search = abap_true.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

  "------------------------------------------------------------------------------
  " build the xml search string --> input for SP SYS_EXECUTE_SEARCH_RULE_SET
  "------------------------------------------------------------------------------

  " initialize the xml string with the fix part for appl_table BUT000:
  " 1.  <?xml version="1.0" encoding="UTF-8"?>
  " 2.  <query>
  " 3.    <ruleset>
  " 4.      <attributeView name="SCHEMA.VIEWNAME" nonUniqueKeys="true">
  " 5.          <keyColumn name="ADDRNUMBER"/>
  " 6.      </attributeView>

  " limit the search hits if iv_search_mode = 'S' ( to win performance )
  IF iv_search_mode = 'S'.
    " the limitation of the required hits is dependend from the GET/SET parameter NRHITS
    " the parameter can be assigned to the user which performs duplicate check
    " If the content of parameter NRHITS is empty --> 100 hits is the default value

    GET PARAMETER ID 'NRHITS' FIELD ev_nrhits_requested.

    IF ev_nrhits_requested IS INITIAL.
      ev_input_xml = |CALL SYS.EXECUTE_SEARCH_RULE_SET('<?xml version="1.0" encoding="UTF-8"?><query limit="50">|.
    ELSE.
      ev_input_xml = |CALL SYS.EXECUTE_SEARCH_RULE_SET('<?xml version="1.0" encoding="UTF-8"?><query limit="{ ev_nrhits_requested }">|.
    ENDIF.

  ELSEIF  iv_search_mode NE 'S'.
    ev_input_xml = |CALL SYS.EXECUTE_SEARCH_RULE_SET('<?xml version="1.0" encoding="UTF-8"?><query>|.
  ENDIF. "  IF iv_search_mode = 'S'.



  IF is_ruleset-entity_type = gc_type_organization.
    APPEND 'ADDRNUMBER' TO lt_key_columns.
  ELSEIF is_ruleset-entity_type = gc_type_person OR
         is_ruleset-entity_type = gc_type_contact OR
         is_ruleset-entity_type = gc_type_addr_indp.
    APPEND 'ADDRNUMBER' TO lt_key_columns.
    APPEND 'PERSNUMBER' TO lt_key_columns.
  ENDIF.

  " extend the ruleset with the block:
  " 1.      <attributeView name="SCHEMA.VIEWNAME" nonUniqueKeys="true">
  " 2.          <keyColumn name="ADDRNUMBER"/>
  " 3.      </attributeView>

  insert_keys_into_ruleset(
    EXPORTING
      is_ruleset     = is_ruleset-ruleset
      iv_schema      = gv_schema
      iv_view_name   = is_ruleset-viewname
      it_key_columns = lt_key_columns
    CHANGING
        rs_ruleset   = ev_input_xml ).

  " extend the ruleset with the search conditions like:
  " 1.    <column name="CITY1">heidelberg</column>   !!!! columns from it_search_fields
  " 2.    ...
  " 3.    <column name="POST_CODE1">heidelberg</column>

  append_search_conditions(
    EXPORTING
      it_search_fields = lt_t_search_fields
    CHANGING
      rv_input_xml     = ev_input_xml   ).

  " add the resultsetcolumns ( significant for BUT000 and iv_type: _SCORE, _RULE_ID, TYPE, (ADDRNUMBER / ADDRNUMBER and PERSNUMBER )

  append_resultcolumns(
    EXPORTING
      iv_appl_table  = iv_appl_table
      iv_entity_type = is_ruleset-entity_type
    CHANGING
      rv_input_xml   =  ev_input_xml  ).


  " add the filter like:
  " for organization ( take also the type = group ) like:
  " <filter>"MANDT" = ''<sy-mandt>'' AND ("PERSNUMBER" = '''' OR "PERSNUMBER" is NULL) AND ("PERSNUMBER_ADR6" = '''' OR
  " "PERSNUMBER_ADR6" is NULL) AND("TYPE" = 2 OR "TYPE" = 3)</filter>
  " OR
  " <filter>"MANDT" = ''<sy-mandt>'' AND ("PERSNUMBER" = '''' OR "PERSNUMBER" is NULL) AND ("PERSNUMBER_ADR6" = '''' OR
  " "PERSNUMBER_ADR6" is NULL) AND("TYPE" = 2 OR "TYPE" = 3) AND ( AUGRP = v1 ... )</filter>

  append_filter(
    EXPORTING
      iv_appl_table  = iv_appl_table
      iv_entity_type = is_ruleset-entity_type
      iv_sacf_mode   = iv_sacf_mode
    CHANGING
      rv_input_xml   = ev_input_xml   ).


  " check if lv_input_xml  is a valid xml-string
  parse_xml(
        EXPORTING
          is_xml_string       = ev_input_xml
        IMPORTING
          ev_valid         = ev_valid
          es_reason        = es_reason
          es_offset_string = es_offset_string
        EXCEPTIONS
          not_parsed       = 1 ).

ENDMETHOD.


METHOD build_table_4_auth_check.

  " if KNA1 or LFA1 --> build dynamically the table for KNA1-hits or LFA1-hits ( blueprint )
  " if BUT000 --> the table  lt_disp_duplicates  will be build to be used for display the duplicates
  "  no display for table MOM052 and BUT052

  TYPES: BEGIN OF ty_auth_list,
           partner TYPE bu_partner,
           adr_ref TYPE ad_addrnum,
         END OF ty_auth_list.

  DATA: lt_auth_list TYPE STANDARD TABLE OF ty_auth_list,
        ls_auth_list TYPE ty_auth_list.

  DATA: lr_struct_ref      TYPE REF TO data,
        lt_return_codes    TYPE bapirettab,
        lr_tab_ref         TYPE REF TO data,
        lv_tabname         TYPE tabname,
        lt_disp_duplicates TYPE TABLE OF sic_s_disp_dupl,
        ls_disp_duplicate  TYPE sic_s_disp_dupl.

  FIELD-SYMBOLS: <ft_data> TYPE STANDARD TABLE.


  IF iv_appl_table = 'KNA1' OR
     iv_appl_table = 'LFA1'.

    " build dynamically the fields of the table KNA1 and LFA1

    TRY.
        CREATE DATA lr_struct_ref TYPE (iv_appl_table).
        ASSIGN lr_struct_ref->* TO FIELD-SYMBOL(<fs_data_tmp>).
        DATA(lt_blueprint) = cl_esh_int_data_blueprint=>get_blueprint_from_data( EXPORTING ix_data = lr_struct_ref ).
        READ TABLE lt_blueprint INDEX 2 REFERENCE INTO DATA(lr_blueprint).
        " add the column "SCORE" in the blueprint as the first column
        lr_blueprint->inttype = 'P'.
        lr_blueprint->compname = 'SCORE'.
        lr_blueprint->leng = 4.
        lr_blueprint->decimals = 1.

        DATA(lr_struct_score_ref) = cl_esh_int_data_blueprint=>create_data_from_blueprint( it_blueprint = lt_blueprint ).
        ASSIGN lr_struct_score_ref->* TO FIELD-SYMBOL(<fs_data>).

        CREATE DATA lr_tab_ref LIKE TABLE OF <fs_data>.
        ASSIGN lr_tab_ref->* TO <ft_data>.

      CATCH cx_sy_create_data_error INTO DATA(lx_table_error).
      CATCH cx_esh_int_engine INTO DATA(lx_esh_engine_error).
    ENDTRY.

  ENDIF.  " IF iv_appl_table = 'KNA1' OR


  " build the display table lt_disp_duplicates for BUT000
  " build the display table es_data for KNA1/KNVK or LFA1

  LOOP AT it_search_results INTO DATA(ls_search_result).

    " get the current data for Customer-ID/Vendor-ID/Partner-ID/Contact_Customer  for each found result
    " for Contact_Customer --> addrnumber is the home address of the found duplicate contact,
    " for Contact_Customer --> persnumber is the found duplicate contact
    get_owner_object(
      EXPORTING
        iv_addrnumber   = ls_search_result-addrnumber
        iv_persnumber   = ls_search_result-persnumber
        iv_appl_table   = iv_appl_table
        "iv_address_type = im_current_address_type
        iv_address_type = ls_search_result-addr_type
      IMPORTING
        ev_kunnr        = ls_disp_duplicate-kunnr
        ev_lifnr        = ls_disp_duplicate-lifnr
        ev_partner      = ls_disp_duplicate-partner
        es_addr_value   = DATA(ls_addr_value)         " data of partner/contact_customer
        es_data         = DATA(ls_data) ).            " appl. data of customer/vendor

    CLEAR ls_auth_list.

    ls_auth_list-adr_ref = ls_search_result-addrnumber.

    IF ls_disp_duplicate-partner IS NOT INITIAL.
      ls_auth_list-partner = ls_disp_duplicate-partner.
    ELSEIF ls_disp_duplicate-kunnr IS NOT INITIAL.
      ls_disp_duplicate-partner = ls_disp_duplicate-kunnr.
    ELSEIF ls_disp_duplicate-lifnr IS NOT INITIAL.
      ls_disp_duplicate-partner = ls_disp_duplicate-kunnr.
    ENDIF.

    APPEND ls_auth_list TO lt_auth_list.



  ENDLOOP.

  et_auth_results = lt_auth_list.

ENDMETHOD.


METHOD BUILD_TABLE_4_DISPLAY.

  " if KNA1 or LFA1 --> build dynamically the table for KNA1-hits or LFA1-hits ( blueprint )
  " if BUT000 --> the table  lt_disp_duplicates  will be build to be used for display the duplicates
  "  no display for table MOM052 and BUT052

  DATA: lr_struct_ref      TYPE REF TO data,
        lt_return_codes    TYPE bapirettab,
        lr_tab_ref         TYPE REF TO data,
        lv_tabname         TYPE tabname,
        lt_disp_duplicates TYPE TABLE OF sic_s_disp_dupl,
        ls_disp_duplicate  TYPE sic_s_disp_dupl.

  FIELD-SYMBOLS: <ft_data> TYPE STANDARD TABLE.


  IF iv_appl_table = 'KNA1' OR
     iv_appl_table = 'LFA1'.

    " build dynamically the fields of the table KNA1 and LFA1

    TRY.
        CREATE DATA lr_struct_ref TYPE (iv_appl_table).
        ASSIGN lr_struct_ref->* TO FIELD-SYMBOL(<fs_data_tmp>).
        DATA(lt_blueprint) = cl_esh_int_data_blueprint=>get_blueprint_from_data( EXPORTING ix_data = lr_struct_ref ).
        READ TABLE lt_blueprint INDEX 2 REFERENCE INTO DATA(lr_blueprint).
        " add the column "SCORE" in the blueprint as the first column
        lr_blueprint->inttype = 'P'.
        lr_blueprint->compname = 'SCORE'.
        lr_blueprint->leng = 4.
        lr_blueprint->decimals = 1.

        DATA(lr_struct_score_ref) = cl_esh_int_data_blueprint=>create_data_from_blueprint( it_blueprint = lt_blueprint ).
        ASSIGN lr_struct_score_ref->* TO FIELD-SYMBOL(<fs_data>).

        CREATE DATA lr_tab_ref LIKE TABLE OF <fs_data>.
        ASSIGN lr_tab_ref->* TO <ft_data>.

      CATCH cx_sy_create_data_error INTO DATA(lx_table_error).
      CATCH cx_esh_int_engine INTO DATA(lx_esh_engine_error).
    ENDTRY.

  ENDIF.  " IF iv_appl_table = 'KNA1' OR


  " build the display table lt_disp_duplicates for BUT000
  " build the display table es_data for KNA1/KNVK or LFA1

  LOOP AT it_search_results INTO DATA(ls_search_result).

    " get the current data for Customer-ID/Vendor-ID/Partner-ID/Contact_Customer  for each found result
    " for Contact_Customer --> addrnumber is the home address of the found duplicate contact,
    " for Contact_Customer --> persnumber is the found duplicate contact
    get_owner_object(
      EXPORTING
        iv_addrnumber   = ls_search_result-addrnumber
        iv_persnumber   = ls_search_result-persnumber
        iv_appl_table   = iv_appl_table
        "iv_address_type = im_current_address_type
        iv_address_type = ls_search_result-addr_type
      IMPORTING
        ev_kunnr        = ls_disp_duplicate-kunnr
        ev_lifnr        = ls_disp_duplicate-lifnr
        ev_partner      = ls_disp_duplicate-partner
        es_addr_value   = DATA(ls_addr_value)         " data of partner/contact_customer
        es_data         = DATA(ls_data) ).            " appl. data of customer/vendor

    " fill ls_disp_duplicate with the data of the current found object

    " for partner
    IF ls_disp_duplicate-partner IS NOT INITIAL.
      MOVE-CORRESPONDING ls_search_result TO ls_disp_duplicate.
      MOVE ls_search_result-percentage TO ls_disp_duplicate-score.
      MOVE-CORRESPONDING ls_addr_value TO ls_disp_duplicate.

      " populate the name fields depending on the address type
      IF ls_search_result-addr_type = '2' .  " check for contacts
        MOVE ls_disp_duplicate-name1 TO ls_disp_duplicate-name_last.
        MOVE ls_disp_duplicate-name2 TO ls_disp_duplicate-name_first.
      ENDIF.

      APPEND ls_disp_duplicate TO et_disp_results.
      CLEAR ls_disp_duplicate.

      " for customer or vendor
    ELSEIF ls_disp_duplicate-kunnr IS NOT INITIAL OR
           ls_disp_duplicate-lifnr IS NOT INITIAL.

      IF ls_data-cluster IS NOT INITIAL.

        " deserialize the data for customer or vendor
        cl_esh_int_config_tools=>unpack_cluster( EXPORTING is_data                 = ls_data
                                                 IMPORTING ev_cluster_import_error = DATA(lv_import_error)
                                                 CHANGING  cr_data                 = lr_struct_ref
                                                           ct_return_codes         = lt_return_codes ).

        IF lv_import_error IS INITIAL.
          MOVE-CORRESPONDING: <fs_data_tmp> TO <fs_data>.
          ASSIGN COMPONENT 'SCORE' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fv_score>).
          <fv_score> = ls_search_result-percentage.

          " populate the name and the address data of the customer_contact.
          " if customer_contact --> ls_addr_value  contains the address data of the found duplicate
          " if customer_contact --> ls_data contains the data of the customer to which the contact belongs
          IF ls_search_result-addr_type = '2' .  " check for contacts

            " take the address of the found duplicate contact_customer
            " country
            ASSIGN COMPONENT 'LAND1' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fv_land>).
            <fv_land> = ls_addr_value-country.
            " city
            ASSIGN COMPONENT 'ORT01' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fv_ort>).
            <fv_ort> = ls_addr_value-city1.
            " post_code
            ASSIGN COMPONENT 'PSTLZ' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fv_pstlz>).
            <fv_pstlz> = ls_addr_value-post_code1.
            " street
            ASSIGN COMPONENT 'STRAS' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fv_stras>).
            <fv_stras> = ls_addr_value-street.

            " take the name of the found duplicate in NAME1
            ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fv_name1>).
            <fv_name1> = ls_addr_value-name1.

          ENDIF.

          APPEND <fs_data> TO <ft_data>.
        ENDIF.

      ENDIF.  " IF ls_data-cluster IS NOT INITIAL.
    ENDIF.  " IF ls_disp_duplicate-partner IS NOT INITIAL.
  ENDLOOP.

  " serialize the table of duplicates  for customer or vendor
  " to be given as parameter in the next step

  IF iv_appl_table = 'KNA1' OR
     iv_appl_table = 'LFA1'.

    IF <ft_data> IS ASSIGNED AND <ft_data> IS NOT INITIAL.
      lv_tabname = iv_appl_table.

      cl_esh_int_config_tools=>pack_cluster( EXPORTING iv_content   = 'DATA'
                                                       iv_ddic_name =  lv_tabname
                                                       iv_ddic_type =  cl_esh_int_config_tools=>gc_ddic_type_ttyp
                                                       ix_data      = <ft_data>
                                             IMPORTING es_data      =  es_data ).

    ENDIF.
  ENDIF.  " IF iv_appl_table = 'KNA1' OR ...

ENDMETHOD.


METHOD BUILD_TYPES_FOR_SEARCH.

  " im_search_in_type_1 --> organization
  " im_search_in_type_1 --> person
  " im_search_in_type_3 --> contact

  " for Customer do duplicate check in KNA1 ( type = organization )
  "                             and in KNVK ( type = person )
  " for Vendor do duplicate check in LFA1 ( type = organization )
  " for contact to BUT000 check in BUT000 with type = person and BUT052 with type = contact
  " for employee check only in MOM052 with type = contact


  DATA: ls_search_in_type TYPE lty_s_search_in_type.

  IF im_search_in_type_1 = abap_true.
    ls_search_in_type-type = '1'.
    ls_search_in_type-value = abap_true.
    APPEND ls_search_in_type TO et_search_in_type.
  ENDIF.

  " im_search_in_type_2 = X will be considered only if not MOM052
  IF im_search_in_type_2 = abap_true AND im_s_object_types-appl_table NE 'MOM052'.
    ls_search_in_type-type = '2'.
    ls_search_in_type-value = abap_true.
    APPEND ls_search_in_type TO et_search_in_type.
  ENDIF.
  IF im_search_in_type_3 = abap_true.
    ls_search_in_type-type = '3'.
    ls_search_in_type-value = abap_true.
    APPEND ls_search_in_type TO et_search_in_type.
  ENDIF.

  " for Vendor do duplicate only for type 1
  IF im_s_object_types-appl_table  = 'LFA1'.
    DELETE et_search_in_type WHERE type NE '1'.
  ENDIF.

  " by search for customer ( search_mode = S ) --> do search only in KNA1, not in KNVK ( no contacts should be searched )
  " by creation of a customer ( search_mode = I ) --> do search for duplicates only in KNA1, not in KNVK
  IF im_s_object_types-appl_table  = 'KNA1' AND ( im_search_mode = 'S' OR im_search_mode = 'I' ).
    DELETE et_search_in_type WHERE type NE '1'.
  ENDIF.


  "-----------------------------------------------------------------------
  " check in customizing --> if address-independent check is required
  " address-independent is required only for BUT000 ( organization, person, contact )
  " if yes --> extend the lt_search_in_type corresponding
  "-----------------------------------------------------------------------

  IF im_s_object_types-appl_table = 'BUT000' OR im_s_object_types-appl_table = 'BUT052'.

    gr_ruleset_maintenance = cl_im_sic_ruleset_maintenance=>get_instance( ).
    DATA(lv_addr_indep_required) = gr_ruleset_maintenance->check_is_addrindp_active( ).

    IF lv_addr_indep_required = abap_true.
      ls_search_in_type-type = '4'.
      ls_search_in_type-value = abap_true.
      APPEND ls_search_in_type TO et_search_in_type.
    ENDIF.
  ENDIF.  " IF im_s_object_types-appl_table = 'BUT000'.


  " for contacts for BPs --> change ev_appl_table to BUT000
  " the search will take place in ICM_PARTNER_PERS with im_search_in_type_2
  " and in ICM_PARTNER_CONT with im_search_in_type_3
  IF im_s_object_types-appl_table  = 'BUT052' .
    ev_appl_table = 'BUT000'.
    EXIT.
  ENDIF.

  " for employees --> consider only the search in MOM052 with im_search_in_type_3. Do not need search in BUT000 with im_search_in_type_2
  " the interface could not be change to get only MOM052 --> so the implementation do not consider BUT000 with im_search_in_type_2
  IF im_s_object_types-appl_table  = 'MOM052' .
    ev_appl_table = 'MOM052'.
    EXIT.
  ENDIF.

  "  determine the view used for search for duplicates
  ev_appl_table = im_s_object_types-appl_table.


ENDMETHOD.


METHOD CHECK_ALL_FIELDS_ARE_EMPTY.

  rv_empty = abap_true.

  CHECK it_fields IS NOT INITIAL.

  LOOP AT it_fields TRANSPORTING NO FIELDS WHERE content IS NOT INITIAL .
    rv_empty = abap_false.
    EXIT.
  ENDLOOP.

ENDMETHOD.


METHOD CHECK_CONNECTION.

  CONSTANTS: lc_hdb TYPE  dbcon_dbms VALUE 'HDB'.

  DATA: lr_conn      TYPE REF TO cl_sql_connection,
        sqlexc_ref   TYPE REF TO cx_sql_exception,
        sql_code(10) TYPE c,
        longtext     TYPE string.


  CLEAR: ev_error, ev_error_text.

  " check if data base is Hana
  TRY.
      lr_conn = cl_sql_connection=>get_connection( ).
      IF lr_conn->get_dbms( ) = lc_hdb.
        gr_conn =  lr_conn->get_con_name( ).
      ELSE.
        " no HANA --> duplicate check not possible
        "gv_use_dupl_check = abap_false.
        "    MESSAGE i010(sic_dupl_hana).
        MESSAGE ID 'SIC_DUPL_HANA' TYPE 'I' NUMBER '010' INTO ev_error_text.
        ev_error = abap_true.
        RETURN.
      ENDIF.

    CATCH cx_sql_exception INTO sqlexc_ref.
      IF sqlexc_ref->sql_message IS INITIAL.
*          MESSAGE w000(sic_dupl_hana).
        MESSAGE ID 'SIC_DUPL_HANA' TYPE 'I' NUMBER '000' INTO ev_error_text.
        ev_error = abap_true.
        RETURN.
      ELSE.
        sql_code = sqlexc_ref->sql_code.
        CONDENSE sql_code NO-GAPS.
        MOVE sqlexc_ref->sql_message TO longtext.
        "  MESSAGE w001(sic_dupl_hana) WITH sql_code longtext.
        MESSAGE ID 'SIC_DUPL_HANA' TYPE 'I' NUMBER '001' INTO ev_error_text WITH sql_code longtext.
        ev_error = abap_true.
        RETURN.
      ENDIF.
  ENDTRY.

  " get the schema of the primary db connection
  IF gr_proxy IS NOT BOUND.
    TRY.
        gr_proxy = cl_esh_trex_proxy_runtime=>get_instance( iv_connection_guid = cl_esh_cdsabap_const=>sc_hana_connection_guid ).

        " get the HANA version
        "mv_eshana_api_version = gr_proxy->eshana_api_version( ).

        " get schema of the CDS-connection
        gv_schema = gr_proxy->dest_dbschema_ddic_default( ).

        IF gv_schema IS INITIAL.
          IF 1 = 2. MESSAGE e058(esh_sql_search). ENDIF.    "#EC *
*          CLEAR ls_message.
*          ls_message-msgty = 'E'.
*          ls_message-msgid = 'ESH_SQL_SEARCH'.
*          ls_message-msgno = '058'.
*          ls_message-msgv1 = iv_connector_id.
*          ls_message-context-tabname = iv_cds_entity.
*          IF ir_applog IS BOUND.
*            ir_applog->add_message( is_message = ls_message ).
*          ENDIF.

          ev_error = abap_true.
          RETURN.
        ENDIF.


      CATCH cx_esh_trex_proxy.
        IF gr_proxy IS NOT BOUND.
*       ESH_SQL_SEARCH 020 CDS connectivity is not available - cannot check CDS connector &1
          IF 1 = 2. MESSAGE i020(esh_sql_search). ENDIF.    "#EC *
*          IF ir_applog IS BOUND.
*            CLEAR ls_message.
*            ls_message-msgty = 'I'.
*            ls_message-msgid = 'ESH_SQL_SEARCH'.
*            ls_message-msgno = 020.
*            ls_message-msgv1 = iv_connector_id.
*            ls_message-context-tabname = iv_cds_entity.
*            ir_applog->add_message( is_message = ls_message ).
*          ENDIF.
          ev_error = abap_true.
          RETURN.
        ENDIF.
    ENDTRY.
  ENDIF.  "IF mr_proxy IS NOT BOUND.

ENDMETHOD.


METHOD CHECK_CONSIDER_AUTHORIZATION.

* check if authorization should be considered ( SACF is activated or not ) for the user of duplicate check
* if yes --> the table cl_bupa_shlp_auth_check=>gt_auth_selopt contains the auth. of the user of duplicate check
* if yes --> take the content of the table cl_bupa_shlp_auth_check=>gt_auth_selopt  in the filter for the search rule sets
* authorizations will be checked only for BUT000 ( BUT052 goes to BUT000 )and MOM052
* authorizations will be checked for F4-Help-Search (IM_SEARCH_MODE = S ) and duplicate check ( IM_SEARCH_MODE = U/I )


  DATA: lv_sacf_mode(1)  TYPE c.

  IF cl_bupa_shlp_auth_check=>gv_sacf_mode IS NOT INITIAL AND
        cl_bupa_shlp_auth_check=>gv_sacf_mode NE 'I'.

    ev_sacf_mode = cl_bupa_shlp_auth_check=>gv_sacf_mode.
  ENDIF.

ENDMETHOD.


METHOD CHECK_DUPLICATE_SWITCHED_OFF.

  DATA: ls_index_config TYPE sic_index_config.


*  check if searching for duplicates should not be performed


  "-------------------------------------------------------------------------------------------------------------
  "  1. no duplicate check if no address is maintained

  "  for the case that: only name and Email-address/ phone is maintained ( in CRM ) --> do not duplicate check
  "  therefore --> message 016 of SIC_DUPL_HANA should be available in the customizing table SIC_INDEX_CONFIG
  "  case valid for BUT000 and BUT052
  "-------------------------------------------------------------------------------------------------------------

  SELECT SINGLE * FROM sic_index_config INTO CORRESPONDING FIELDS OF ls_index_config "#EC CI_ALL_FIELDS_NEEDED
                                 WHERE arbgb      = 'SIC_DUPL_HANA'
                                 AND   msgnr      = '016'
                                 AND   switch_off = 'X'.
  IF sy-subrc = 0.

    " check if BUT000 or BUT052
    LOOP AT im_t_object_types INTO DATA(ls_object_type) WHERE main_obj = 'X' AND
               ( appl_table = 'BUT000' OR
                 appl_table = 'BUT052' ).
    ENDLOOP.

    IF sy-subrc = 0.
      " check if only name and mail are maintained ( values <> space ) --> if yes --> do nothing
      LOOP AT im_t_search_fields INTO DATA(im_s_search_field).
        IF im_s_search_field-fieldname = 'CITY1' AND
           im_s_search_field-content   IS INITIAL.
          DATA(lv_no_city) = abap_true.
        ELSEIF im_s_search_field-fieldname = 'POST_CODE1' AND
           im_s_search_field-content   IS INITIAL.
          DATA(lv_no_postcode) = abap_true.
        ELSEIF im_s_search_field-fieldname = 'STREET' AND
           im_s_search_field-content   IS INITIAL.
          DATA(lv_no_street) = abap_true.
        ELSEIF im_s_search_field-fieldname = 'HOUSE_NUM1' AND
           im_s_search_field-content   IS INITIAL.
          DATA(lv_no_housenr) = abap_true.
        ENDIF.

      ENDLOOP.
      IF lv_no_city = abap_true AND
         lv_no_postcode = abap_true AND
         lv_no_street = abap_true AND
         lv_no_housenr = abap_true.
        " no duplicate check is required

        ev_switched_off = abap_true.
        RETURN.
      ENDIF.

    ENDIF.  " IF sy-subrc = 0.
  ENDIF.  " IF sy-subrc = 0.

  "----------------------------------------------------------------
  "  2.  check if duplicate check should be generally switched off
  "----------------------------------------------------------------
  SELECT SINGLE * FROM sic_index_config INTO CORRESPONDING FIELDS OF ls_index_config "#EC CI_ALL_FIELDS_NEEDED
                                 WHERE arbgb      = 'SIC_DUPL_HANA'
                                 AND   msgnr      = '017'
                                 AND   switch_off = 'X'.

  IF sy-subrc = 0.
    ev_switched_off = abap_true.
    RETURN.
  ENDIF.

  "------------------------------------------------------------------------------------------------------------------------------------------
  "  3.  check if duplicate check should be switched off for some users ( e.g. loading BPs from ERP into CRM using background processes )
  "------------------------------------------------------------------------------------------------------------------------------------------
  SELECT SINGLE * FROM sic_index_config INTO CORRESPONDING FIELDS OF ls_index_config "#EC CI_ALL_FIELDS_NEEDED
                                WHERE arbgb      = 'SIC_DUPL_HANA'
                                AND   msgnr      = '018'
                                AND   switch_off = 'X'.

  IF sy-subrc  = 0.

    IF ls_index_config-bname = sy-uname
      OR ( ls_index_config-parameters IS NOT INITIAL
        AND ls_index_config-parameters CS sy-uname ).

      ev_switched_off = abap_true.
      RETURN.
    ENDIF.
  ENDIF.

  "--------------------------------------------------------------------------
  "  4.  check if duplicate check should be deactivated in batch processes
  "--------------------------------------------------------------------------
  SELECT SINGLE * FROM sic_index_config INTO CORRESPONDING FIELDS OF ls_index_config "#EC CI_ALL_FIELDS_NEEDED
                             WHERE arbgb      = 'SIC_DUPL_HANA'
                             AND   msgnr      = '019'
                             AND   switch_off = 'X'.

  IF sy-subrc = 0.
    IF sy-batch = abap_true.
      ev_switched_off = abap_true.
      RETURN.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD CHECK_FOR_ERRORS.

  FREE ev_raise_exception.
  FREE ev_search_status.

  READ TABLE it_errors  WITH KEY error_message-type = 'E' ASSIGNING FIELD-SYMBOL(<ls_error>).
  READ TABLE it_errors  WITH KEY error_message-type = 'I' ASSIGNING FIELD-SYMBOL(<ls_info>).

  " fill the status of the duplicate check
  IF it_search_result IS NOT INITIAL.
    ev_search_status = '01'.
  ENDIF.

  " if ev_raise_exception = abap_true --> no duplicates will be considered
  " duplicates found
  IF ev_search_status = '01'.

    " duplicates found but also errors in the processing
    IF <ls_error> IS ASSIGNED.

      " 01 + E --> ???
      MESSAGE ID <ls_error>-error_message-id
            TYPE 'I'  "<ls_error>-error_message-type
            NUMBER <ls_error>-error_message-number
            WITH <ls_error>-error_message-message_v1
                 <ls_error>-error_message-message_v2
                 <ls_error>-error_message-message_v3
                 <ls_error>-error_message-message_v4
            DISPLAY LIKE 'I'.
      ev_raise_exception = abap_false.

      " there are results but at least one ruleset has had an error
      " ?? if we do not raise the exception the error will not be picked up by CRM

    ELSEIF <ls_info> IS ASSIGNED.

      " duplicates found but at least one search rule set not active
      " 01 + I  --> no raise
      " there are results but at least in one case a ruleset was not active
      " ?? the info will not be picked up by CRM
      MESSAGE ID <ls_info>-error_message-id
            TYPE <ls_info>-error_message-type
            NUMBER <ls_info>-error_message-number
            WITH <ls_info>-error_message-message_v1
                 <ls_info>-error_message-message_v2
                 <ls_info>-error_message-message_v3
                 <ls_info>-error_message-message_v4
            DISPLAY LIKE 'I'.
      ev_raise_exception = abap_false.

    ELSE.

      " 01 + no error/info -> nur status 01

    ENDIF.

    " no duplicates found
  ELSE.

    " no duplicates found and errors in the processing
    IF <ls_error> IS ASSIGNED.

      " 00 + E --> raise
      MESSAGE ID <ls_error>-error_message-id
            TYPE 'I'  "<ls_error>-error_message-type
            NUMBER <ls_error>-error_message-number
            WITH <ls_error>-error_message-message_v1
                 <ls_error>-error_message-message_v2
                 <ls_error>-error_message-message_v3
                 <ls_error>-error_message-message_v4
            DISPLAY LIKE 'I'.
      ev_raise_exception = abap_true.

    ELSEIF <ls_info> IS ASSIGNED.

      " no duplicates found but inactive rulesets
      " 00 + I --> Info
      MESSAGE ID <ls_info>-error_message-id
            TYPE <ls_info>-error_message-type
            NUMBER <ls_info>-error_message-number
            WITH <ls_info>-error_message-message_v1
                 <ls_info>-error_message-message_v2
                 <ls_info>-error_message-message_v3
                 <ls_info>-error_message-message_v4
            DISPLAY LIKE 'I'.
      ev_raise_exception = abap_false.

    ELSE.

      " 00 + no error/info -> nur status 00

    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD CHECK_IF_POPUP_REQUIRED.

  " for business partner -----------------------------------------------------------------------------------------------
  "    no popup for potential duplicates should be sent ( IM_SEARCH_MODE = I/U ) in transaction BP,BP0,BUP1,BUP2,BUP3
  "    no popup should be sent in CRM wui ( sy-tcode = ' ' )
  "    popup should be sent if IM_SEARCH_MODE = 'S' ( for F4- Partners by Address (Rough Search) and SY-TCODE = BP
  "---------------------------------------------------------------------------------------------------------------------

  " for customer and vendor -----------------------------------------------------------------------
  "    popup should be sent if IM_SEARCH_MODE = 'S' ( for F4- Partners by Address (Rough Search)
  "    popup should be sent if IM_SEARCH_MODE = 'I' / 'U' ( duplicate check hit list )
  "------------------------------------------------------------------------------------------------

  " fill the status of the duplicate check
  IF it_search_results IS NOT INITIAL.
    ev_search_status = '01'.
  ENDIF.

  CASE iv_appl_table.

    WHEN 'BUT000'.
      IF  sy-tcode IS INITIAL OR                                                                                        " CRM Web-UI
         ( ( sy-tcode = 'BP' OR sy-tcode = 'BP0' OR sy-tcode = 'BUP1' OR sy-tcode = 'BUP2' OR sy-tcode = 'BUP3' ) AND   " for BP/BO0/BUP1/BUP2/BUP3
           iv_search_mode NE 'S' ).                                                                                     " no search but duplicate check ( Update/Insert )

        " no popup required --> set the status dependent on existing potential duplicates
        IF it_search_results IS NOT INITIAL.
          ev_search_status = '01'.
          CLEAR ev_popup_required.
        ENDIF.

        "  for all other transaction except BP and search_mode = 'S' ( search ) -> popup is required
      ELSEIF sy-tcode IS NOT INITIAL AND
             iv_search_mode = 'S'.
        ev_popup_required = abap_true.

      ENDIF.   " IF  sy-tcode IS INITIAL OR  ...

      " for customer and vendor --> popup is alwaysequired
    WHEN 'KNA1' OR 'LFA1'.
      ev_popup_required = abap_true.

      " for employee --> no popup required
    WHEN 'MOM052'.
      CLEAR ev_popup_required.

  ENDCASE.


ENDMETHOD.


METHOD ESCAPE_XML_CHARS_IN_STRING.

  rs_input_escaped = is_input.

  " enscape the special URL chars
  REPLACE ALL OCCURRENCES OF `&` IN rs_input_escaped WITH `&amp;`.
  REPLACE ALL OCCURRENCES OF `"` IN rs_input_escaped WITH `&quot;`.
  REPLACE ALL OCCURRENCES OF `'` IN rs_input_escaped WITH `&apos;`.
  REPLACE ALL OCCURRENCES OF `<` IN rs_input_escaped WITH `&lt;`.
  REPLACE ALL OCCURRENCES OF `>` IN rs_input_escaped WITH `&gt;`.

ENDMETHOD.


METHOD EXECUTE_SEARCH.

  DATA: lr_sql_stmt TYPE REF TO cl_sql_statement,       "#EC CI_ADBC_US
        lr_result   TYPE REF TO cl_sql_result_set.

  DATA: _score                TYPE REF TO decfloat16,
        _rule_id              TYPE REF TO string,
        type                  TYPE REF TO string,
        persnumber            TYPE REF TO string,
        addrnumber            TYPE REF TO string,
        org_addr_number       TYPE REF TO string,
        addrnumber_adcp       TYPE REF TO string,
        ls_result_icm         TYPE lty_s_icm_fields,
        "lt_result_icm         LIKE TABLE OF ls_result_icm,
        lx_abap_invalid_name  TYPE REF TO cx_abap_invalid_name,
        lx_abap_invalid_value TYPE REF TO cx_abap_invalid_value,
        lv_rows               TYPE i,
        lx_sql_exception      TYPE REF TO cx_sql_exception. "#EC CI_ADBC_US

  FIELD-SYMBOLS: <fs_string>       TYPE string,
                 <fs_int>          TYPE int4,
                 <fs_string_adcp>  TYPE string,
                 <fs_float>        TYPE decfloat16,
                 <fs_primary_id>   TYPE any,
                 <fs_value_object> TYPE adsrchline,
                 <fv_value>        TYPE any.

  " for BUT000, BUT052, customer and vendor --> _score, _rule_id, persnumber and addrnumber

  CREATE DATA _score.
  CREATE DATA _rule_id.
  IF iv_appl_table = 'BUT000' AND ( iv_entity_type = gc_type_organization OR iv_entity_type = gc_type_person OR iv_entity_type = gc_type_addr_indp ).
    CREATE DATA type.
  ENDIF.
  CREATE DATA persnumber.
  CREATE DATA addrnumber.


  TRY.

      CREATE OBJECT lr_sql_stmt .

      " call the stored procedure SYS.EXECUTE_SEARCH_RULE_SET('is_xml_string',?)
      lr_result = lr_sql_stmt->execute_query( statement = is_xml_string ). "#EC CI_ADBC_US

      " get the resultcolumns: _SCORE, _RULE_ID, TYPE, ADDRNUMBER ( and optional PERSNUMBER )

      lr_result->set_param( data_ref = _score ).
      lr_result->set_param( data_ref = _rule_id ).

      " get the address if organization for BUT000
      " set parameter addrnumber before parameter type
      IF ( iv_appl_table = 'BUT000' AND iv_entity_type EQ gc_type_organization ) OR
         ( iv_appl_table = 'BUT000' AND iv_entity_type EQ gc_type_person ) OR
         ( iv_appl_table = 'BUT000' AND iv_entity_type EQ gc_type_addr_indp ).
        lr_result->set_param( data_ref = addrnumber ).
        lr_result->set_param( data_ref = type ).
        lr_result->set_param( data_ref = persnumber ).
      ENDIF.

      IF  iv_appl_table = 'BUT052' OR iv_appl_table = 'MOM052' OR ( iv_appl_table = 'BUT000' AND iv_entity_type EQ gc_type_contact ).
        lr_result->set_param( data_ref = addrnumber ).
        lr_result->set_param( data_ref = persnumber ).
      ENDIF.

      IF iv_appl_table = 'KNA1' OR iv_appl_table = 'LFA1'.
        lr_result->set_param( data_ref = addrnumber ).
        IF iv_entity_type EQ gc_type_person.
          lr_result->set_param( data_ref = persnumber ).
        ENDIF.

      ENDIF.


      " get the results from the search

      DO.
        lv_rows = lr_result->next( ).
        IF lv_rows = 0.  " no hits more
          EXIT.
        ENDIF.

        ASSIGN _score->* TO <fs_float>.
        MOVE <fs_float> TO ls_result_icm-score.
        ASSIGN _rule_id->* TO <fs_string>.
        MOVE <fs_string> TO ls_result_icm-rule_id.
        UNASSIGN <fs_string>.

        IF iv_appl_table = 'BUT000'.
          ASSIGN persnumber->* TO <fs_string>.
          MOVE <fs_string> TO ls_result_icm-persnumber.
          UNASSIGN <fs_string>.

          " type only for organization, person and address_independent
          IF iv_entity_type EQ gc_type_organization OR iv_entity_type EQ gc_type_person.
            ASSIGN type->* TO <fs_string>.
            MOVE <fs_string> TO ls_result_icm-type.
            CLEAR <fs_string>.
          ELSEIF iv_entity_type EQ gc_type_addr_indp.
            MOVE '4' TO ls_result_icm-type.
          ENDIF.

          ASSIGN addrnumber->* TO <fs_string>.
          MOVE <fs_string> TO ls_result_icm-addrnumber.
          CLEAR <fs_string>.

          APPEND ls_result_icm TO et_search_results.
          CLEAR ls_result_icm.

        ENDIF.

        IF iv_appl_table = 'BUT052' OR iv_appl_table = 'MOM052'.
          ASSIGN persnumber->* TO <fs_string>.
          MOVE <fs_string> TO ls_result_icm-persnumber.
          UNASSIGN <fs_string>.

          ASSIGN addrnumber->* TO <fs_string>.
          MOVE <fs_string> TO ls_result_icm-addrnumber.
          CLEAR <fs_string>.

          APPEND ls_result_icm TO et_search_results.
          CLEAR ls_result_icm.
        ENDIF.

        IF iv_appl_table = 'KNA1' OR iv_appl_table = 'LFA1'.

          IF iv_entity_type = gc_type_person.
            ASSIGN persnumber->* TO <fs_string>.
            MOVE <fs_string> TO ls_result_icm-persnumber.
            UNASSIGN <fs_string>.
          ENDIF.
          ASSIGN addrnumber->* TO <fs_string>.
          MOVE <fs_string> TO ls_result_icm-addrnumber.
          CLEAR <fs_string>.

          APPEND ls_result_icm TO et_search_results.
          CLEAR ls_result_icm.
        ENDIF.

      ENDDO.

    CATCH cx_sql_exception INTO lx_sql_exception.       "#EC CI_ADBC_US
      es_error  = lx_sql_exception->get_text( ).        "#EC CI_ADBC_US
  ENDTRY.

  " fill the result table

ENDMETHOD.


METHOD FILL_RESULT_TABLE.

  " ls_ex_search_result-addr_type should contain:
  "  1  for organization
  "  2  for person
  "  3 for contact

  DATA: ls_ex_search_result TYPE adkey_indx.

  LOOP AT it_search_results_all INTO DATA(ls_search_result_all).

    CLEAR: ls_ex_search_result.

    CASE iv_appl_table.
      WHEN 'BUT000'.
        IF ls_search_result_all-type = '2' OR       "organization
           ls_search_result_all-type = '3'.         " group

          " By searching for duplicates for organizations, the system also finds organizations whose contact persons
          " have the same e-mail address or telephone number as the newly created organization.
          " This is incorrect. These organizations have nothing to do with the newly created organization and should not be returned as duplicates.
          " The incorrect duplicates are found using the rules "Organization by telephone or mobile" and "Organization by E-mail"
          " from the active rule set for organizations (RULESET_ORG in transaction ICM_RULESET). see note 3051076
          IF ls_search_result_all-persnumber is not initial.
            IF ( ls_search_result_all-rule_id = 'Organization by telephone or mobile'
                   OR ls_search_result_all-rule_id = 'Organization by E-mail'
                 ).
              CONTINUE.   " do not take this result
            ELSE.
              CLEAR ls_search_result_all-persnumber. " it is an organization. do not show the contact person
            ENDIF.
          ENDIF.

          MOVE '1' TO ls_ex_search_result-addr_type.
        ELSEIF ls_search_result_all-type = '1'.      " person

          MOVE: '2'                             TO ls_ex_search_result-addr_type,
                ls_search_result_all-persnumber TO ls_ex_search_result-persnumber.

        ELSEIF ls_search_result_all-type IS INITIAL.      " contact

          MOVE: '3' TO ls_ex_search_result-addr_type,
                ls_search_result_all-persnumber TO ls_ex_search_result-persnumber.

        ELSEIF ls_search_result_all-type = '4'.      " address_independent
          " check if person or organization
*          IF ls_search_result_all-addrnumber IS NOT INITIAL AND ls_search_result_all-persnumber IS NOT INITIAL.
*            MOVE: '2' TO ls_ex_search_result-addr_type,   " person
*                  ls_search_result_all-persnumber TO ls_ex_search_result-persnumber.
*          ELSEIF ls_search_result_all-persnumber IS INITIAL.
*            MOVE '1' TO ls_ex_search_result-addr_type.     " organization
*          ENDIF.
          " based on Stephan comment --> type for address-independent is always '1' (organization)
          " MOVE: ls_search_result_all-persnumber TO ls_ex_search_result-persnumber,
          MOVE: ls_search_result_all-addrnumber TO ls_ex_search_result-addrnumber,
                '1' TO ls_ex_search_result-addr_type.     " organization
        ENDIF.

      WHEN 'BUT052' OR 'MOM052'.
        MOVE: '3'                             TO ls_ex_search_result-addr_type,
              ls_search_result_all-persnumber TO ls_ex_search_result-persnumber.

      WHEN 'KNA1' OR 'LFA1'.                         " for customer and vendor only type 1
        IF ls_search_result_all-persnumber IS NOT INITIAL.
          MOVE: '2'   TO ls_ex_search_result-addr_type,
                ls_search_result_all-persnumber TO ls_ex_search_result-persnumber.
        ELSE.
          MOVE '1' TO ls_ex_search_result-addr_type.
        ENDIF.
    ENDCASE.

    " fill the other fields of the result table

    " addrnumber
    MOVE ls_search_result_all-addrnumber TO ls_ex_search_result-addrnumber.

    " score
    DATA(lv_dec4_1) = ls_search_result_all-score * 100.
    MOVE lv_dec4_1 TO ls_ex_search_result-percentage.

    " filter the hits based on the given threshold
    IF ls_ex_search_result-percentage GE iv_threshold.
      APPEND ls_ex_search_result TO et_search_results.
    ENDIF.

  ENDLOOP.

  " delete duplicates entries
  SORT et_search_results BY addrnumber persnumber addr_type date_from nation.
  DELETE ADJACENT DUPLICATES FROM et_search_results COMPARING addrnumber persnumber addr_type date_from nation.
  SORT et_search_results BY percentage DESCENDING.

  " eliminate from the result the changed BP
  IF iv_search_mode NE 'S'.
    DELETE et_search_results WHERE addrnumber = iv_current_address_key-addrnumber AND
                                   persnumber = iv_current_address_key-persnumber AND
                                   addr_type  = iv_current_address_key-addr_type.
  ENDIF.

  " if NRHITS requested --> keep only the first NRHITS hits
  IF iv_nrhits_requested IS NOT INITIAL.
    DATA(lv_nrhits) = iv_nrhits_requested.
    lv_nrhits = lv_nrhits + 1.
    DELETE et_search_results FROM lv_nrhits.
  ENDIF.

  " deliver the number of found hits
  DESCRIBE TABLE et_search_results LINES ev_number_of_hits.


ENDMETHOD.


  METHOD GET_ENTITY_TYPE.

    SELECT SINGLE entity_type FROM icm_dupl_entity INTO @DATA(lv_entity_type)  "#EC CI_NOORDER or "#EC WARNOK
      WHERE tech_id = @iv_tech_id .

    IF sy-subrc = 0.
      rv_entity_type = lv_entity_type.
    ENDIF.

  ENDMETHOD.


METHOD GET_OWNER_OBJECT.

  DATA: lv_counter         TYPE i,
        ls_addrnumber      TYPE addr1_sel,
        ls_addr_value      TYPE addr1_val,
        lv_address_type    TYPE ad_adrtype,
        lt_addr_ref_table  TYPE szadr_addr_ref_read_tab,
        "ls_addr_ref_line   TYPE szadr_addr_ref_read_line,
        ls_addr_pers_sel   TYPE addr2_sel,
        ls_addr_pers_value TYPE addr2_val.

  DATA: lv_tabname           TYPE tabname,
        ls_key               TYPE string,
        ls_data              TYPE esh_s_int_cluster,
        lr_struct_ref        TYPE REF TO data,
        lt_return_codes      TYPE bapirettab.


  CLEAR: ls_addr_value, ls_addr_pers_value, es_addr_value.

  IF iv_persnumber IS INITIAL.
    lv_address_type = '1'.
  ELSE.
    lv_address_type = '2'.
  ENDIF.

  " get the table of Where-Used for the address
  CALL FUNCTION 'ADDR_REFERENCE_GET'
    EXPORTING
      address_number     = iv_addrnumber
      person_number      = iv_persnumber
      address_type       = lv_address_type
    IMPORTING
      reference_counter  = lv_counter
    TABLES
      reference_table    = lt_addr_ref_table
    EXCEPTIONS
      parameter_error    = 1
      address_not_exist  = 2
      no_reference_found = 3
      internal_error     = 4
      OTHERS             = 5.

  IF sy-subrc = 0 AND NOT lv_counter IS INITIAL.
    LOOP AT lt_addr_ref_table INTO DATA(ls_addr_ref_line) WHERE addr_ref-owner = 'X'.
      IF ls_addr_ref_line-obj_type = 'KNA1'.
        ev_kunnr = ls_addr_ref_line-obj_key.
      ELSEIF ls_addr_ref_line-obj_type = 'LFA1'.
        ev_lifnr = ls_addr_ref_line-obj_key.
      ELSEIF ls_addr_ref_line-obj_type = 'BUS1006'.
        ev_partner = ls_addr_ref_line-obj_key.
      ELSEIF ls_addr_ref_line-obj_type = 'BUS1006001'.  " contact for customer

        " get the customer ID from the contact ( KNVK )
        lv_tabname = 'KNVK'.
        ls_key = ls_addr_ref_line-obj_key.
        read_table(
          EXPORTING
            iv_tabname = lv_tabname
            is_key     = ls_key
          IMPORTING
            es_data    = ls_data ).

        IF ls_data-cluster IS NOT INITIAL.
          " deserialize the data of KNVK to get the customer ID
          CREATE DATA lr_struct_ref TYPE (lv_tabname).
          cl_esh_int_config_tools=>unpack_cluster( EXPORTING is_data                 = ls_data
                                                   IMPORTING ev_cluster_import_error = DATA(lv_import_error)
                                                   CHANGING  cr_data                 = lr_struct_ref
                                                             ct_return_codes         = lt_return_codes ).
          IF lv_import_error IS INITIAL.
            ASSIGN lr_struct_ref->* TO FIELD-SYMBOL(<fs_data>).
            ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fv_kunnr>).
            ev_kunnr = <fv_kunnr>.
          ENDIF.
        ENDIF.  " IF ls_data-cluster IS NOT INITIAL.

      ENDIF.
    ENDLOOP.
  ENDIF.

* get the fields of the address to be displayed
  IF lv_address_type = '1'.  " address for organisation
    ls_addrnumber-addrnumber = iv_addrnumber.
    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        address_selection = ls_addrnumber
*       ADDRESS_GROUP     =
*       READ_SADR_ONLY    = ' '
*       READ_TEXTS        = ' '
*       IV_CURRENT_COMM_DATA          = ' '
      IMPORTING
        address_value     = ls_addr_value
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.

*   for the addressindependent usecase:
*   the values NAME1 and NAME2 in ADRC are empty
*   as a fallback for display in popup:
*   NAME1 and NAME2 have to be read from BUT000 using the PARTNER number as key
    IF ls_addr_value-name1 IS INITIAL AND ls_addr_value-name2 IS INITIAL.

      IF ev_partner IS NOT INITIAL.

        SELECT SINGLE * FROM but000 INTO @DATA(ls_data_but000)
            WHERE partner = @ev_partner.

        IF ls_data_but000 IS NOT INITIAL.

          IF ls_data_but000-name_last IS NOT INITIAL AND ls_data_but000-name_first IS NOT INITIAL.

            " it is a person and both name_last and name_first are filled
            " --> name_last name_first into field name1
            CONCATENATE ls_data_but000-name_last ls_data_but000-name_first INTO ls_addr_value-name1 SEPARATED BY space.

          ELSEIF ls_data_but000-name_last IS NOT INITIAL.

            " it is a person and only name_last ist filled
            " --> name_last into field name1
            ls_addr_value-name1 = ls_data_but000-name_last.

          ELSEIF ls_data_but000-mc_name1 IS NOT INITIAL AND ls_data_but000-mc_name2 IS NOT INITIAL.

            " it is a organisation and mc_name1 and mc_name2 are filled
            " --> mc_name1 mc_name2 into field name1
            CONCATENATE ls_data_but000-mc_name1 ls_data_but000-mc_name2 INTO ls_addr_value-name1 SEPARATED BY space.

          ELSEIF ls_data_but000-mc_name1 IS NOT INITIAL.

            " it is a organisation and only mc_name1 is filled
            " --> mc_name1 into field name1
            ls_addr_value-name1 = ls_data_but000-mc_name1.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.


* get the fields of address for the duplicate person or duplicate contact_customer
  ELSEIF lv_address_type = '2'.
    ls_addr_pers_sel-persnumber = iv_persnumber.
    ls_addr_pers_sel-addrnumber = iv_addrnumber.
    CALL FUNCTION 'ADDR_PERSONAL_GET'
      EXPORTING
        address_personal_selection = ls_addr_pers_sel
      IMPORTING
        address_personal_value     = ls_addr_pers_value
      EXCEPTIONS
        parameter_error            = 1
        address_not_exist          = 2
        person_not_exist           = 3
        version_not_exist          = 4
        internal_error             = 5
        person_blocked             = 6
        OTHERS                     = 7.

  ENDIF.

  IF sy-subrc = 0.
    IF NOT ls_addr_value IS INITIAL.
      es_addr_value = ls_addr_value.
    ELSEIF NOT ls_addr_pers_value IS INITIAL.
      MOVE-CORRESPONDING ls_addr_pers_value TO es_addr_value.
      CONCATENATE ls_addr_pers_value-name_last ls_addr_pers_value-name_first INTO es_addr_value-name1 SEPARATED BY space.
    ENDIF.
  ENDIF.

  " if the found hit ( iv_addrnumber) belongs to KNA1 or LFA1 --> get the data for the found customer/vendor --> fill es_data

  IF ev_kunnr IS NOT INITIAL.
    lv_tabname = 'KNA1'.

    ls_key = ev_kunnr.
    read_table(
      EXPORTING
        iv_tabname = lv_tabname
        is_key     = ls_key
      IMPORTING
        es_data    = ls_data ).

    es_data = ls_data.

  ENDIF.

  IF ev_lifnr IS NOT INITIAL.
    lv_tabname  = 'LFA1'.

    ls_key = ev_lifnr.
    read_table(
      EXPORTING
        iv_tabname = lv_tabname
        is_key     = ls_key
      IMPORTING
        es_data    = ls_data ).

    es_data = ls_data.

  ENDIF.


ENDMETHOD.


METHOD GET_RULE_SET.

  DATA: ls_ruleset          TYPE string,
        lt_icm_dupl_ruleset TYPE TABLE OF icm_dupl_ruleset,
        ls_icm_dupl_ruleset TYPE icm_dupl_ruleset.

  DATA(lv_entity_type) = get_entity_type( iv_tech_id = iv_type ).

  IF gr_ruleset_maintenance IS NOT BOUND.
    DATA(lr_ruleset_maintenance) = cl_im_sic_ruleset_maintenance=>get_instance( ).
  ELSE.
    lr_ruleset_maintenance = gr_ruleset_maintenance.
  ENDIF.

  lr_ruleset_maintenance->get_ruleset(
    EXPORTING
      iv_entity_type      = lv_entity_type
      iv_appl_table       = iv_appl_table
      iv_for_dupl_check   = iv_for_dupl_check
      iv_for_value_help   = iv_for_value_help
    IMPORTING
      et_ruleset          = et_ruleset
      ev_not_found        = ev_not_found
      ev_not_valid        = ev_not_valid
      es_validation_error = es_validation_error
    ).


ENDMETHOD.


METHOD if_ex_address_search~address_search.

*     extended for Employee ( MOM052) for S4HANA at 11.12.2017
* --> IM_CURRENT_ADDRESS_TYPE = 3
* --> IM_SEARCH_IN_TYPE_1 = space
* --> IM_SEARCH_IN_TYPE_2 = space
* --> IM_SEARCH_IN_TYPE_3 = X
* --> IM_T_OBJECT_TYPES = MOM052  ADDRNUMBER   X
*     duplicate check for employee is done only based on the name_last and name_first ( address stored in HR tables not ADRC )
*     is executable only from TA --> WUI
*--------------------------------------------------------------------------------------------------------------------------------
* --> extended with authorizations for F4-Help Search and duplicate check at 7.06.2018
* --> the views for BUT000 and MOM052 were extended with the field AUGRP
* --> for Organization and Person --> the existent Filter will be extended
* --> for Contacts --> new Filter for authorizations will be added
*     input: ( im_search_in_type_2 = X, BUT000 PARTNER )
*            ( im_search_in_type_3 = X, BUT052 ADDRNUMBER --> BUT000 PARTNER )
* --> Employee  ( MOM052 )  similar with Contact --> new Filter for authorizations should be added
*     input: ( im_search_in_type_3 = X, MOM052 ADDRNUMBER )

*---------------------------------------------------------------------------

  DATA: ls_reason_tmp(150)       TYPE c,
        ls_offset_string_tmp(20) TYPE c,
        lv_error_text(240)       TYPE c,
        lt_lines                 TYPE trtexts,
        ls_lines                 TYPE char80,
        lv_var1(50)              TYPE c,
        lv_var2(50)              TYPE c,
        lv_var3(50)              TYPE c,
        lt_search_result_all     TYPE lty_t_icm_fields,
        lv_prompt                TYPE char10,
        lv_user_action           TYPE syucomm,
        lv_for_value_help        TYPE abap_bool,
        lv_for_dupl_check        TYPE abap_bool,
        lt_errors                TYPE lty_t_icm_errors.

  DATA: lt_but000_range  TYPE RANGE OF bu_partner,
        lt_adr_ref_range TYPE RANGE OF ad_addrnum.

  "----------------------------
  "  1.  Prerequisite Checks
  "----------------------------

  "  check if searching for duplicates should be switched off ( setting in customizing )
  check_duplicate_switched_off(
     EXPORTING
       im_t_object_types  = im_t_object_types
       im_t_search_fields = im_t_search_fields
     IMPORTING
       ev_switched_off    = DATA(lv_dupl_switched_off) ).

  IF lv_dupl_switched_off = abap_true.
    RETURN.
  ENDIF.

  " get the primary connection to HANA
  check_connection(
    IMPORTING
      ev_error      = DATA(lv_conn_error)
      ev_error_text = DATA(ls_conn_error_text) ).

  IF lv_conn_error = abap_true.
    "  Message I013  Message type W or E message in a Popup --> leads to dump  --> so I-message
    MESSAGE i013(sic_dupl_hana) WITH ls_conn_error_text DISPLAY LIKE 'I'.
    RAISE communication_error.
  ENDIF.

  " determine the main object, exception for MOM052
  LOOP AT im_t_object_types INTO DATA(ls_object_types).
    IF ls_object_types-appl_table = 'MOM052'.
      ls_object_types-main_obj = 'X'.
      EXIT.
    ELSE.
      IF ls_object_types-main_obj = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF ls_object_types-main_obj NE 'X'.
    " no main object delivered --> no duplicate check possible
    MESSAGE w014(sic_dupl_hana) DISPLAY LIKE 'I'.
    RAISE internal_error.
  ENDIF.

  " no duplicate check is supported for contacts to customer and vendor
  IF im_search_mode = 'U' AND
    im_current_address_type = '3'  AND
    ( ls_object_types-appl_table = 'KNA1' OR
      ls_object_types-appl_table = 'LFA1' ).
    RETURN.
  ENDIF.

  "------------------------------------------
  "  2.  Prepare to perform duplicate check
  "------------------------------------------

  " determine the types ( Org/Pers/Contact ) where should be searched for
  build_types_for_search(
    EXPORTING
      im_search_in_type_1 = im_search_in_type_1
      im_search_in_type_2 = im_search_in_type_2
      im_search_in_type_3 = im_search_in_type_3
      im_s_object_types   = ls_object_types
      im_search_mode      = im_search_mode
    IMPORTING
      et_search_in_type = DATA(lt_search_in_type)
      ev_appl_table     = DATA(lv_appl_table) ).

  " check if authorization should be considered ( SACF is activated or not ) for the user of the duplicate check
  " authorizations will be considered only for BUT000

  IF lv_appl_table = 'BUT000'.
    check_consider_authorization( IMPORTING ev_sacf_mode = DATA(lv_sacf_mode) ).
  ENDIF.

  IF im_search_mode = 'S'. " value help search
    lv_for_value_help = abap_true.
  ELSE.
    lv_for_dupl_check = abap_true.
  ENDIF.

  "--------------------------------------------------------------------
  "  3.  Build the search call for duplicates and execute the search
  "--------------------------------------------------------------------

  LOOP AT lt_search_in_type INTO DATA(ls_search_in_type) WHERE value = abap_true.

    " get the ruleset correspondingly to the appl. table und type
    get_rule_set(
      EXPORTING
        iv_type             = ls_search_in_type-type
        iv_appl_table       = lv_appl_table
        iv_for_value_help   = lv_for_value_help
        iv_for_dupl_check   = lv_for_dupl_check
      IMPORTING
        et_ruleset          = DATA(lt_ruleset)
        ev_not_found        = DATA(lv_not_found)
        ev_not_valid        = DATA(lv_not_valid)
        es_validation_error = DATA(ls_validation_error)
        ).

    " no ruleset found --> no duplicate check can be performed
    IF lv_not_found = abap_true.

      " map the type to readable type
      APPEND INITIAL LINE TO lt_errors ASSIGNING FIELD-SYMBOL(<ls_error>).
      <ls_error>-appl_table  = lv_appl_table.
      <ls_error>-ruleset_id  = space.
      <ls_error>-entity_type = get_entity_type( iv_tech_id = ls_search_in_type-type ).
      " <ls_error>-viewname
      " I 022 SIC_DUPL_HANA : No ruleset active for type &1. Check transaction &2. No duplicate check.
      <ls_error>-error_message-type = 'I'.
      <ls_error>-error_message-id = 'SIC_DUPL_HANA'.
      <ls_error>-error_message-number = 022.
      <ls_error>-error_message-message_v1 = <ls_error>-entity_type.
      <ls_error>-error_message-message_v2 = 'ICM_RULESET'.
      MESSAGE i022(sic_dupl_hana) WITH <ls_error>-entity_type 'ICM_RULESET' INTO <ls_error>-error_message-message.

    ELSEIF lv_not_valid = abap_true.

      APPEND INITIAL LINE TO lt_errors ASSIGNING <ls_error>.
      <ls_error>-appl_table  = lv_appl_table.
      <ls_error>-ruleset_id  = space.
      <ls_error>-entity_type = get_entity_type( iv_tech_id = ls_search_in_type-type ).
      " <ls_error>-viewname
      IF ls_validation_error IS NOT INITIAL.
        " show the validation error - map the whole message
        <ls_error>-error_message = ls_validation_error.
      ELSE.
        " treat it as a "not active" case
        " I 022 SIC_DUPL_HANA : No ruleset active for type &1. Check transaction &2. No duplicate check.
        <ls_error>-error_message-type = 'I'.
        <ls_error>-error_message-id  = 'SIC_DUPL_HANA'.
        <ls_error>-error_message-number = 022.
        <ls_error>-error_message-message_v1 = <ls_error>-entity_type.
        <ls_error>-error_message-message_v2 = 'ICM_RULESET'.
        MESSAGE i022(sic_dupl_hana) WITH <ls_error>-entity_type 'ICM_RULESET' INTO <ls_error>-error_message-message.
      ENDIF.

    ENDIF.

    LOOP AT lt_ruleset ASSIGNING FIELD-SYMBOL(<ls_ruleset>).

      " build the xml string ( input parameter for the SP "SYS.EXECUTE_SEARCH_RULE_SET"

      build_call(
        EXPORTING
          iv_appl_table    = lv_appl_table
          iv_type          = ls_search_in_type-type
          is_ruleset       = <ls_ruleset>
          it_search_fields = im_t_search_fields
          iv_search_mode   = im_search_mode    " simple search (S), create (I) or change (U)
          iv_sacf_mode     = lv_sacf_mode      " consider authorizations ( SACF is activated )
        IMPORTING
          ev_input_xml        = DATA(lv_input_xml)
          ev_valid            = DATA(lv_valid)
          es_reason           = DATA(ls_reason)
          es_offset_string    = DATA(ls_offset_string)
          ev_nrhits_requested = DATA(lv_nrhits_requested)
          ev_do_not_search    = DATA(lv_do_not_search)  ).

      " check if the search should be done
      IF lv_do_not_search = abap_true.
        CONTINUE.
      ENDIF.

      IF lv_valid = abap_false.

        ls_reason_tmp = ls_reason.   " take the max. lenght of the string which can be displayed ( 150 )
        ls_offset_string_tmp = ls_offset_string(20).
        MOVE: ls_reason_tmp(50)     TO lv_var1,
              ls_reason_tmp+50(50)  TO lv_var2,
              ls_reason_tmp+100(50) TO lv_var3.

        " map the type to readable type
        APPEND INITIAL LINE TO lt_errors ASSIGNING <ls_error>.
        <ls_error>-appl_table  = <ls_ruleset>-appl_table.
        <ls_error>-ruleset_id  = <ls_ruleset>-ruleset_id.
        <ls_error>-entity_type = <ls_ruleset>-entity_type.
        <ls_error>-viewname    = <ls_ruleset>-viewname.

        " E SIC_DUPL_HANA 015 = &1&2&3 ín &4
        <ls_error>-error_message-type = 'E'.
        <ls_error>-error_message-id = 'SIC_DUPL_HANA'.
        <ls_error>-error_message-number = 015.
        <ls_error>-error_message-message_v1 = lv_var1.
        <ls_error>-error_message-message_v2 = lv_var2.
        <ls_error>-error_message-message_v3 = lv_var3.
        <ls_error>-error_message-message_v4 = ls_offset_string_tmp.
        MESSAGE e015(sic_dupl_hana) WITH lv_var1 lv_var2 lv_var3 ls_offset_string_tmp INTO <ls_error>-error_message-message.

        CONTINUE.
      ENDIF.

      " execute the search for duplicates
      execute_search(
        EXPORTING
          is_xml_string  = lv_input_xml
          iv_entity_type = <ls_ruleset>-entity_type
          iv_appl_table  = lv_appl_table
        IMPORTING
          et_search_results = DATA(lt_search_result)
          es_error          = DATA(ls_error)  ).

      IF ls_error IS NOT INITIAL.
        " split the error text in parts of 50 char.

        lv_error_text = ls_error.
        CALL FUNCTION 'TR_SPLIT_TEXT'
          EXPORTING
            iv_text  = lv_error_text
            iv_len   = 50
          IMPORTING
            et_lines = lt_lines.

        READ TABLE lt_lines INTO ls_lines INDEX 1.
        IF sy-subrc IS INITIAL.
          lv_var1 = ls_lines.
        ENDIF.
        READ TABLE lt_lines INTO ls_lines INDEX 2.
        IF sy-subrc IS INITIAL.
          lv_var2 = ls_lines.
        ENDIF.
        READ TABLE lt_lines INTO ls_lines INDEX 3.
        IF sy-subrc IS INITIAL.
          lv_var3 = ls_lines.
        ENDIF.

        " map the type to readable type
        APPEND INITIAL LINE TO lt_errors ASSIGNING <ls_error>.
        <ls_error>-appl_table  = <ls_ruleset>-appl_table.
        <ls_error>-ruleset_id  = <ls_ruleset>-ruleset_id.
        <ls_error>-entity_type = <ls_ruleset>-entity_type.
        <ls_error>-viewname    = <ls_ruleset>-viewname.

        " E SIC_DUPL_HANA 011  Error while searching with ruleset &1:  &2&3&4. Dupl. Check inactivated
        <ls_error>-error_message-type = 'E'.
        <ls_error>-error_message-id = 'SIC_DUPL_HANA'.
        <ls_error>-error_message-number = 011.
        <ls_error>-error_message-message_v1 = <ls_error>-ruleset_id .
        <ls_error>-error_message-message_v2 = lv_var1.
        <ls_error>-error_message-message_v3 = lv_var2.
        <ls_error>-error_message-message_v4 = lv_var3.
        MESSAGE e011(sic_dupl_hana) WITH <ls_ruleset>-ruleset_id lv_var1 lv_var2 lv_var3 INTO <ls_error>-error_message-message.

        CONTINUE.
      ENDIF.

      " fill the complete result table
      APPEND LINES OF lt_search_result TO  lt_search_result_all.

      CLEAR: lv_input_xml, lt_search_result, ls_error, lv_valid, lv_not_found.

    ENDLOOP. " LOOP AT lt_ruleset ASSIGNING FIELD-SYMBOL(<ls_ruleset>).

    CLEAR: lt_ruleset, lv_not_found.

  ENDLOOP.

  IF lt_search_result_all IS NOT INITIAL.

    " fill the result table ex_t_search_result
    fill_result_table(
       EXPORTING
         it_search_results_all  = lt_search_result_all
         iv_appl_table          = lv_appl_table
         iv_threshold           = im_threshold
         iv_search_mode         = im_search_mode
         iv_current_address_key = im_current_address_key
         iv_nrhits_requested    = lv_nrhits_requested
       IMPORTING
         et_search_results      = ex_t_search_result
         ev_number_of_hits      = ex_number_of_hits ).
    "Ermitteln Zuordnung Adresse zu GP
    build_table_4_auth_check(
     EXPORTING
       iv_appl_table     = lv_appl_table
       it_search_results = ex_t_search_result
    IMPORTING
       et_auth_results   = DATA(lt_auth_results) ) .

    IF lt_auth_results IS NOT INITIAL.


      DATA: lv_object TYPE xuobject.

       lv_object = /thkr/cl_auth_check=>get_bupa_object( ).

      "Geschäftsbereiche für Berechtigungsprüfung ermitteln
      SELECT partner, /thkr/gsber, augrp  FROM but000
        INTO TABLE @DATA(lt_but000)
        FOR ALL ENTRIES IN @lt_auth_results
        WHERE partner = @lt_auth_results-partner.
      IF sy-subrc = 0.
        SELECT DISTINCT /thkr/gsber, augrp FROM but000
          INTO TABLE @DATA(lt_but000_auth)
        FOR ALL ENTRIES IN @lt_auth_results
        WHERE partner = @lt_auth_results-partner.

        LOOP AT lt_but000_auth ASSIGNING FIELD-SYMBOL(<fs_auth>).

          DATA(lv_no_auth) = /thkr/cl_auth_check=>check_bupa_object(
                        EXPORTING iv_act = '03'
                        iv_augrp = <fs_auth>-augrp
                        iv_gsber = <fs_auth>-/thkr/gsber
                        iv_object = lv_object
                        ).
          IF lv_no_auth = abap_true.

            DATA(lv_no_auth2) = /thkr/cl_auth_check=>check_bupa_object(
                        EXPORTING iv_act = 'F4'
                        iv_augrp = <fs_auth>-augrp
                        iv_gsber = <fs_auth>-/thkr/gsber
                        iv_object = lv_object
                        ).
            IF lv_no_auth2 = abap_true.

              DELETE lt_but000 WHERE /thkr/gsber = <fs_auth>-/thkr/gsber
              AND augrp = <fs_auth>-augrp.

            ENDIF.

          ENDIF.
          clear: lv_no_auth, lv_no_auth2.

        ENDLOOP.
*
*        LOOP AT lt_but000 ASSIGNING FIELD-SYMBOL(<fs_but000>)
*          GROUP BY <fs_but000>-/thkr/gsber, <fs_but000>-augrp
*          WITHOUT MEMBERS ASSIGNING FIELD-SYMBOL(<fs_gsber>).
*
*          AUTHORITY-CHECK OBJECT 'Z_BUPA_GSB'
*          ID 'ACTVT'       FIELD '03'
*          ID 'GSBER'  FIELD <fs_gsber>.
*          IF sy-subrc NE 0.
*            AUTHORITY-CHECK OBJECT 'Z_BUPA_GSB'
*             ID 'ACTVT'       FIELD 'F4'
*             ID 'GSBER'  FIELD <fs_gsber>.
*          ENDIF.
*           Wenn keine Berechtigung, dann werf den GP aus der Tabelle
*          Darf nicht angezeigt werden
*          IF sy-subrc NE 0.
*            DELETE lt_but000
*             WHERE /THKR/gsber = <fs_gsber>.
*          ENDIF.

*        ENDLOOP.
        "wenn but000 leer --> keine Berechtigung auf GP
        IF lt_but000 IS INITIAL.
          CLEAR ex_t_search_result.
          CLEAR lt_search_result_all.
          "Neubestimmung der Zeilen
          DESCRIBE TABLE ex_t_search_result LINES ex_number_of_hits.
        ELSE.
          "Aufbauen Range der erlaubten GP
          SELECT 'I' AS sign, 'EQ' AS option, partner AS low
            FROM @lt_but000 AS partners INTO CORRESPONDING FIELDS OF TABLE @lt_but000_range.
          IF sy-subrc = 0.
            "Aufbauen Range der erlaubten Adressen
            SELECT 'I' AS sign, 'EQ' AS option, adr_ref AS low
              FROM @lt_auth_results AS adr_refs
              WHERE partner IN @lt_but000_range
              INTO CORRESPONDING FIELDS OF TABLE @lt_adr_ref_range.
            IF sy-subrc = 0.
              "Löschen der nicht erlaubten Adresses
              DELETE ex_t_search_result
              WHERE addrnumber NOT IN lt_adr_ref_range.

              DELETE lt_search_result_all
              WHERE addrnumber NOT IN lt_adr_ref_range.
              "Neubestimmung der Zeilen
              DESCRIBE TABLE ex_t_search_result LINES ex_number_of_hits.

            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.


  " check if errors occured by the processing
  check_for_errors(
    EXPORTING
      it_errors          = lt_errors
      it_search_result   = ex_t_search_result
    IMPORTING
      ev_raise_exception = DATA(lv_raise_exception)
      ev_search_status   = ex_search_status
      ).

  IF lv_raise_exception = abap_true.
    RAISE internal_error.
  ENDIF.

  " continue process only if hits were found " popup
  CHECK lt_search_result_all IS NOT INITIAL.

  " Check if a popup with the potential duplicates should be build
  check_if_popup_required(
    EXPORTING
      iv_appl_table       = lv_appl_table
      iv_search_mode      = im_search_mode
      it_search_results   = ex_t_search_result
    IMPORTING
      ev_popup_required   = DATA(lv_popup_required) ).


  "  for KNA1, LFA1 and BP with search_mode = 'S' -->
  "  build the popup and fill it with the found results
  CHECK lv_popup_required = abap_true.

  IF im_dialog_allowed = abap_true.

    IF ex_t_search_result IS INITIAL.
      ex_search_status = '02'.
      RETURN.
    ELSE.

      " popup is required, dialog is allowed and result hits found
      " prepare output table for displaying result hits
      build_table_4_display(
        EXPORTING
          iv_appl_table     = lv_appl_table
          it_search_results = ex_t_search_result
        IMPORTING
          et_disp_results   = DATA(lt_disp_results)
          es_data           = DATA(ls_data) ).


      " display Hit List using ALV grid control
      CALL FUNCTION 'ICM_DISPLAY_HIT_LIST'
        EXPORTING
          im_search_mode       = im_search_mode
          im_address_type      = im_current_address_type
          im_appl_table        = lv_appl_table
          is_cluster           = ls_data
        IMPORTING
          ev_prompt            = lv_prompt
          ev_user_action       = lv_user_action
        TABLES
          it_potential_matches = lt_disp_results.

      " set export search status depending on the user action
      CASE lv_user_action.
        WHEN 'SELECT'.   ex_search_status = '01'.
        WHEN 'REJECT'.   ex_search_status = '02'. " only for Customer and Vendor
        WHEN 'CANCEL'.   ex_search_status = '04'.
        WHEN 'NEW_SRCH'. ex_search_status = '06'.
      ENDCASE.

      " fill ex_selected_address_key for KNA1 --> by selection of a duplicate in popup to make possible the navigation
      IF ( lv_appl_table = 'BUT000' OR lv_appl_table = 'LFA1' OR lv_appl_table = 'KNA1' ) AND lv_user_action = 'SELECT'.
        READ TABLE ex_t_search_result INDEX lv_prompt INTO ex_selected_address_key.
        ex_selected_address_type = ex_selected_address_key-addr_type.
      ENDIF.

    ENDIF.

  ENDIF.  " IF lv_dialog_allowed = abap_true.


ENDMETHOD.


  method IF_EX_ADDRESS_SEARCH~INITIALIZE.
  endmethod.


  method IF_EX_ADDRESS_SEARCH~IS_COMPLETE.
  endmethod.


  method IF_EX_ADDRESS_SEARCH~READ_INDEX_FIELD_LIST.

  DATA: lt_additional_fields TYPE adfldlist.

  CASE im_current_address_type.
    WHEN '1'.
      IF gt_field_list_1[] IS INITIAL.

        SELECT tablename fieldname FROM tsad10 INTO
          CORRESPONDING FIELDS OF TABLE gt_field_list_1
            WHERE def_type1 = 'X'.

        SELECT tablename fieldname FROM tsad10 INTO
            CORRESPONDING FIELDS OF TABLE lt_additional_fields
              WHERE type1_fld = 'X' AND  tablename = 'ADRC' AND (  fieldname = 'PO_BOX' OR fieldname = 'POST_CODE2' ).

        APPEND LINES OF lt_additional_fields TO gt_field_list_1.

      ENDIF.
      ex_field_list[] = gt_field_list_1[].

    WHEN '2'.
      IF gt_field_list_2[] IS INITIAL.

        SELECT tablename fieldname FROM tsad10 INTO
          CORRESPONDING FIELDS OF TABLE gt_field_list_2
            WHERE def_type2 = 'X'.

        SELECT tablename fieldname FROM tsad10 INTO
            CORRESPONDING FIELDS OF TABLE lt_additional_fields
              WHERE type1_fld = 'X' AND  tablename = 'ADRC' AND (  fieldname = 'PO_BOX' OR fieldname = 'POST_CODE2' ).

        APPEND LINES OF lt_additional_fields TO gt_field_list_2.

      ENDIF.
      ex_field_list[] = gt_field_list_2[].

    WHEN '3'.
      IF gt_field_list_3[] IS INITIAL.

        SELECT tablename fieldname FROM tsad10 INTO
          CORRESPONDING FIELDS OF TABLE gt_field_list_3
            WHERE def_type3 = 'X'.

        SELECT tablename fieldname FROM tsad10 INTO
              CORRESPONDING FIELDS OF TABLE lt_additional_fields
                WHERE type1_fld = 'X' AND  tablename = 'ADRC' AND (  fieldname = 'PO_BOX' OR fieldname = 'POST_CODE2' ).

        APPEND LINES OF lt_additional_fields TO gt_field_list_3.

      ENDIF.
      ex_field_list[] = gt_field_list_3[].

  ENDCASE.

ENDMETHOD.


METHOD INSERT_KEYS_INTO_RULESET.

  DATA: lv_key_column_string TYPE string.

  LOOP AT it_key_columns ASSIGNING FIELD-SYMBOL(<lv_key_column>).
    lv_key_column_string = |{ lv_key_column_string }<keyColumn name="{ <lv_key_column> }" />|.
  ENDLOOP.

  "rs_ruleset = is_ruleset.

  IF is_ruleset(9) = '<ruleset>'.
    rs_ruleset = |{ rs_ruleset }| &&
                 |{ is_ruleset(9) }| &&
                 | <attributeView name="{ iv_schema }.{ iv_view_name }" nonUniqueKeys="true">| &&
                 |{ lv_key_column_string }| &&
                 | </attributeView>| &&
                 |{ is_ruleset+9 }| .
  ENDIF.

ENDMETHOD.


METHOD PARSE_XML.

* transforms the given XML string into a Control Tree
* If no XML string is given, we return an initial
* XML document.

  DATA: ixml         TYPE REF TO if_ixml,
        xml_document TYPE REF TO if_ixml_document,
        rtnflag      TYPE        c,
        rtn          TYPE        i.


  DATA: stream_factory TYPE REF TO if_ixml_stream_factory,
        istream        TYPE REF TO if_ixml_istream,
        parser         TYPE REF TO if_ixml_parser,
        parse_error    TYPE REF TO if_ixml_parse_error.

  CALL METHOD cl_ixml=>create
    RECEIVING
      rval = ixml.

  IF ixml IS INITIAL.
    RAISE not_parsed.
  ENDIF.

  CALL METHOD ixml->create_document
    RECEIVING
      rval = xml_document.

* We need these auxiliary interfaces to convert the
* XML string into a DOM

  CALL METHOD ixml->create_stream_factory
    RECEIVING
      rval = stream_factory.

  CALL METHOD stream_factory->create_istream_cstring
    EXPORTING
      string = is_xml_string
    RECEIVING
      rval   = istream.

  CALL METHOD ixml->create_parser
    EXPORTING
      document       = xml_document
      istream        = istream
      stream_factory = stream_factory
    RECEIVING
      rval           = parser.

* Parse the XML string into the DOM

  CALL METHOD parser->set_normalizing
*  EXPORTING
*    IS_NORMALIZING = 'X'
    RECEIVING
      rval = rtnflag.

  CALL METHOD parser->parse
    RECEIVING
      rval = rtn.

  CASE rtn.
    WHEN ixml_mr_parser_ok.
      ev_valid = abap_true.
      RETURN.

    WHEN ixml_mr_parser_unspecified
    OR   ixml_mr_parser_internal
    OR   ixml_mr_parser_invalid_arg
    OR   ixml_mr_parser_fatal_error.
      ev_valid = abap_false.
      RAISE not_parsed.

    WHEN ixml_mr_parser_error.
      ev_valid = abap_false.

      DATA: xmlstring TYPE string,
            retstring TYPE string,
            offset    TYPE i.

      CLEAR xmlstring.
      CALL METHOD parser->get_error
        EXPORTING
          index = 0
*         MIN_SEVERITY = 3
        RECEIVING
          rval  = parse_error.

      CALL METHOD parse_error->get_offset
        RECEIVING
          rval = offset.

      MOVE is_xml_string+offset(20) TO es_offset_string.

      CALL METHOD parse_error->get_reason
        RECEIVING
          rval = retstring.

      MOVE retstring TO es_reason.
      RAISE not_parsed.

    WHEN OTHERS.
      RAISE not_parsed.
  ENDCASE.
ENDMETHOD.


METHOD READ_TABLE.

  DATA: lv_sel_condition TYPE string.
  DATA: lv_tabname       TYPE string.

  DATA: lr_tab_ref     TYPE REF TO data,
        lr_structdescr TYPE REF TO cl_abap_structdescr.


    TRY.
      CREATE DATA lr_tab_ref TYPE (iv_tabname).

      DATA(lt_blueprint) = cl_esh_int_data_blueprint=>get_blueprint_from_data( EXPORTING ix_data = lr_tab_ref ).
      DATA(lr_struct_ref) = cl_esh_int_data_blueprint=>create_data_from_blueprint( it_blueprint = lt_blueprint ).
      ASSIGN lr_struct_ref->* TO FIELD-SYMBOL(<fs_data>).

      lr_structdescr ?= cl_abap_structdescr=>describe_by_name( p_name = iv_tabname ).
      DATA(lt_field_list) = lr_structdescr->get_ddic_field_list( ).
      DELETE lt_field_list WHERE keyflag IS INITIAL.
      DELETE lt_field_list WHERE ( fieldname = 'MANDT' OR fieldname = 'CLIENT' ).

      DATA(lt_blueprint_4_key_flds) = lt_blueprint.
      LOOP AT lt_blueprint_4_key_flds FROM 1 REFERENCE INTO DATA(lr_fld).
        READ TABLE lt_field_list TRANSPORTING NO FIELDS WITH KEY fieldname = lr_fld->compname.

        CHECK syst-subrc NE 0.

        DELETE lt_blueprint_4_key_flds.
      ENDLOOP.

      DATA(lr_key_ref) = cl_esh_int_data_blueprint=>create_data_from_blueprint( it_blueprint = lt_blueprint_4_key_flds ).
      ASSIGN lr_key_ref->* TO FIELD-SYMBOL(<fs_key>).

      " KNA1 and LFA1 have only one key ( KUNNR, LIFNR ); MANDT can be omitted in Select
      <fs_key> = is_key.
      LOOP AT lt_field_list REFERENCE INTO DATA(lr_key_fld).
        ASSIGN lr_key_fld->fieldname TO FIELD-SYMBOL(<fv_key_fieldname>).
        IF NOT ( lv_sel_condition IS INITIAL ).
          CONCATENATE: lv_sel_condition 'AND' INTO lv_sel_condition SEPARATED BY space.
        ENDIF.

*        CONCATENATE: lv_sel_condition ' ' <fv_key_fieldname> ' = <fs_key>-' <fv_key_fieldname> INTO lv_sel_condition RESPECTING BLANKS. CONDENSE lv_sel_condition.
        CONCATENATE: lv_sel_condition ' ' <fv_key_fieldname> ' = <fs_key>' INTO lv_sel_condition RESPECTING BLANKS. CONDENSE lv_sel_condition.
      ENDLOOP.

      " check SQL-injection on lv_sel_condition
      lv_sel_condition = cl_abap_dyn_prg=>escape_quotes( lv_sel_condition ).
      lv_tabname = cl_abap_dyn_prg=>escape_quotes( iv_tabname ).

      SELECT SINGLE * FROM (lv_tabname) INTO <fs_data>
         WHERE (lv_sel_condition).

      IF syst-subrc EQ 0.
        cl_esh_int_config_tools=>pack_cluster( EXPORTING iv_content   = 'DATA'
                                                         iv_ddic_name =  iv_tabname
                                                         iv_ddic_type =  cl_esh_int_config_tools=>gc_ddic_type_tabl
                                                         ix_data      = <fs_data>

                                               IMPORTING es_data      =  es_data ).
      ENDIF.

    CATCH cx_sy_create_data_error INTO DATA(lx_table_error).
    CATCH cx_esh_int_engine INTO DATA(lx_esh_int_engine).

  ENDTRY.
ENDMETHOD.
ENDCLASS.
