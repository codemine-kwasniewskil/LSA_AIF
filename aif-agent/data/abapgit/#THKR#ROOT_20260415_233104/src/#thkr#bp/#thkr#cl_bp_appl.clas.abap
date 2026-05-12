class /THKR/CL_BP_APPL definition
  public
  create protected .

public section.

  data MS_SEPA_CUST type SEPA_CUST .
  constants CO_ADRKIND_XXDEFAULT type BU_ADRKIND value 'XXDEFAULT' ##NO_TEXT.

  class-methods GET_ADDRESS_GUID_FROM_PARTNER
    importing
      !I_PARTNER type BU_PARTNER
    returning
      value(R_GUID) type SYSUUID_C
    raising
      /THKR/CX_BP .
  methods CONSTRUCTOR .
  class-methods GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_BP_APPL .
  methods GET_PARTNER_DATA
    importing
      !I_PARTNER type BU_PARTNER
    returning
      value(R_DTO_BP) type /THKR/S_DTO_BP
    raising
      /THKR/CX_BP .
  methods CREATE_PARTNER
    importing
      !I_DTO_BP_CREATE type /THKR/S_DTO_BP_CREATE
    exporting
      !E_PARTNER type BU_PARTNER
    returning
      value(R_PARTNER) type BU_PARTNER
    raising
      /THKR/CX_BP .
  methods MODIFY_PARTNER
    importing
      !I_DTO_BP_MODIFY type /THKR/S_DTO_BP_MODIFY
    raising
      /THKR/CX_BP .
  methods RELEASE_PARTNER
    importing
      !I_PARTNER type BU_PARTNER
      !I_TEST_RUN type /THKR/D_BU_TEST_RUN
    raising
      /THKR/CX_BP .
protected section.

  data MV_BPARTNERGUID type SYSUUID_C32 .
  data MV_OBJECT_TASK type BUS_EI_OBJECT_TASK .

  methods CALL_BADI_CVI_DEFAULT_VALUES
    changing
      !C_DATA type CVIS_EI_EXTERN .
  methods MAP_BUT000_DTO
    importing
      !I_BUT000 type BUT000
    changing
      !C_DTO_BP type /THKR/S_DTO_BP .
  methods MAP_BUT0BK_DTO
    importing
      !I_BUT0BK type TTY_BUT0BK
    changing
      !C_DTO_BP type /THKR/S_DTO_BP .
  methods MAP_DFKKBPTAXNUM_DTO
    importing
      !I_DFKKBPTAXNUM type BUP_TT_DFKKBPTAXNUM
    changing
      !C_DTO_BP type /THKR/S_DTO_BP .
  methods MAP_DTO_BUS_EI_EXTERN
    importing
      !I_DTO_BP type /THKR/S_DTO_BP
    exporting
      !E_BUS_EI_EXTERN type BUS_EI_EXTERN
      !E_SEPA_USE type SEPA_TAB_USE_EXT
    raising
      /THKR/CX_BP .
  methods MAP_DTO_CMDS_EI_EXTERN
    importing
      !I_DTO_BP type /THKR/S_DTO_BP
    returning
      value(R_CMDS_EI_EXTERN) type CMDS_EI_EXTERN .
  methods MAP_DTO_CVIS_EI_EXTERN
    importing
      !I_DTO_BP type /THKR/S_DTO_BP
    exporting
      !E_DATA type CVIS_EI_EXTERN
      !E_SEPA_USE type SEPA_TAB_USE_EXT
    raising
      /THKR/CX_BP .
  methods MAP_DTO_VMDS_EI_EXTERN
    importing
      !I_DTO_BP type /THKR/S_DTO_BP
    returning
      value(R_VMDS_EI_EXTERN) type VMDS_EI_EXTERN .
  methods MAP_FSBP_ADDRESS_DTO
    importing
      !I_ADDRESS type FSBP_ADDRESS_OBJECT
    changing
      !C_DTO_BP type /THKR/S_DTO_BP .
  methods MAP_KNA1_DTO
    importing
      !I_KNA1 type KNA1
    changing
      !C_DTO_BP type /THKR/S_DTO_BP .
  methods MAP_KNB1_DTO
    importing
      !I_KNB1 type CVIS_KNB1_T
    changing
      !C_DTO_BP type /THKR/S_DTO_BP .
  methods MAP_LFA1_DTO
    importing
      !I_LFA1 type LFA1
    changing
      !C_DTO_BP type /THKR/S_DTO_BP .
  methods MAP_LFB1_DTO
    importing
      !I_LFB1 type CVIS_LFB1_T
    changing
      !C_DTO_BP type /THKR/S_DTO_BP .
private section.

  class-data INSTANCE type ref to /THKR/CL_BP_APPL .
ENDCLASS.



CLASS /THKR/CL_BP_APPL IMPLEMENTATION.


  METHOD call_badi_cvi_default_values.

* Der Badi   CVI_DEFAULT_VALUES  wird nur im Dialog aufgerufen.
* Um ihn auch in der SST zu nutzen erfolgt die Implementierug hier analog.
* Felder nur füllen, wenn sie nicht schon von außen gefüllt wurden
    DATA:
      ls_v_company_data  TYPE vmds_ei_company_data,
      lt_v_dunning       TYPE cvis_vend_cc_dunning_t,
      ls_company_data    TYPE cmds_ei_company_data,
      lt_dunning         TYPE cvis_cust_cc_dunning_t,
      lt_cvi_role_cat    TYPE cvis_role_category_t,
      lba_default_values TYPE REF TO cvi_default_values.

* Badi Objekt erzeugen
    GET BADI lba_default_values.

* notwendige Vorbelegungen
    " Rolle
    LOOP AT c_data-partner-central_data-role-roles ASSIGNING FIELD-SYMBOL(<fs_role_cat>).
      APPEND VALUE #( category = <fs_role_cat>-data-rolecategory ) TO lt_cvi_role_cat.
    ENDLOOP.
    " Gruppierung
    DATA(ls_but000) = VALUE but000( bu_group = c_data-partner-central_data-common-data-bp_control-grouping ).


* Gibt Vorbel.werte f. buchungskreisabh. Debitordaten zurück
    ASSIGN c_data-customer-company_data-company[ 1 ] TO FIELD-SYMBOL(<fs_cust>).
    IF sy-subrc = 0.
      CALL BADI lba_default_values->get_defaults_for_cust_cc
        EXPORTING
          i_role_categories  = lt_cvi_role_cat
          i_new_company_code = <fs_cust>-data_key-bukrs
          i_but000           = ls_but000
        CHANGING
          c_company_data     = ls_company_data
          c_dunning          = lt_dunning.

      <fs_cust>-data-zuawa = COND #( WHEN <fs_cust>-data-zuawa IS INITIAL THEN ls_company_data-zuawa ELSE <fs_cust>-data-zuawa ).
      <fs_cust>-data-akont = COND #( WHEN <fs_cust>-data-akont IS INITIAL THEN ls_company_data-akont ELSE <fs_cust>-data-akont ).
      <fs_cust>-data-mgrup = COND #( WHEN <fs_cust>-data-mgrup IS INITIAL THEN ls_company_data-mgrup ELSE <fs_cust>-data-mgrup ).
      IF lt_dunning IS NOT INITIAL AND <fs_cust>-dunning-dunning IS INITIAL.
        <fs_cust>-dunning-dunning = VALUE #( ( data-mahna = lt_dunning[ 1 ]-mahna ) ).
      ENDIF.
    ENDIF.


*Gibt Vorbel.werte f. buchungskreisabh. Kreditordaten zurück
    ASSIGN c_data-vendor-company_data-company[ 1 ] TO FIELD-SYMBOL(<fs_vend>).
    IF sy-subrc = 0.

      CALL BADI lba_default_values->get_defaults_for_vend_cc
        EXPORTING
          i_role_categories  = lt_cvi_role_cat                 " Rollentypen
          i_new_company_code = <fs_vend>-data_key-bukrs            " Neuer Buchungskreis
          i_but000           = ls_but000
        CHANGING
          c_company_data     = ls_v_company_data                " Ext. Schnittstelle: Buchungskreisdaten / Datenfelder
          c_dunning          = lt_v_dunning.                " Lieferantenstamm  (Mahndaten)

      <fs_vend>-data-zuawa = COND #( WHEN <fs_vend>-data-zuawa IS INITIAL THEN ls_v_company_data-zuawa ELSE <fs_vend>-data-zuawa ).
      <fs_vend>-data-akont = COND #( WHEN <fs_vend>-data-akont IS INITIAL THEN ls_v_company_data-akont ELSE <fs_vend>-data-akont ).
      <fs_vend>-data-mgrup = COND #( WHEN <fs_vend>-data-mgrup IS INITIAL THEN ls_v_company_data-mgrup   ELSE <fs_vend>-data-mgrup ).
      IF lt_v_dunning IS NOT INITIAL AND <fs_cust>-dunning-dunning IS INITIAL.
        <fs_vend>-dunning-dunning = VALUE #( ( data-mahna = lt_v_dunning[ 1 ]-mahna ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.

* Sepa Cust.  laden
    CALL FUNCTION 'SEPA_CUSTOMIZING_READ'
      EXPORTING
        i_anwnd   = 'F'
      IMPORTING
        e_cust    = ms_sepa_cust
      EXCEPTIONS
        not_activ = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      " dann keine Default Werte
    ENDIF.
  ENDMETHOD.


METHOD create_partner.
*---------------------------------------------------------------------------------------------------------------------
* Business Partner anlegen
*---------------------------------------------------------------------------------------------------------------------

  DATA:
       lt_sepa_messages TYPE  bapiret1_list.


  mv_object_task = cl_md_bp_maintain=>gc_task_create.
*---------------------------------------------------------------------------------------------------------------------
  IF i_dto_bp_create-partner IS INITIAL.
    TRY.
        mv_bpartnerguid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
      CATCH cx_uuid_error INTO DATA(lx_error).
        RAISE EXCEPTION TYPE /thkr/cx_bp
         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
         EXPORTING previous = lx_error.
    ENDTRY.
  ENDIF.
*---------------------------------------------------------------------------------------------------------------------
* Map Data
  map_dto_cvis_ei_extern( EXPORTING i_dto_bp = CORRESPONDING #( i_dto_bp_create )
                          IMPORTING e_data  = DATA(ls_data) e_sepa_use = DATA(lt_sepa_usage) ).
*---------------------------------------------------------------------------------------------------------------------
* Ausschalten des Popups zur Anzeige von Infomeldungen bei diversen GP Prüfungen im Dialogprozess
  IF sy-binpt IS INITIAL.
    sy-binpt = abap_true.
    DATA(lv_clear_binpt) = abap_true.
  ENDIF.
*---------------------------------------------------------------------------------------------------------------------

* Validate data
  cl_md_bp_maintain=>validate_single(
    EXPORTING
      i_data        = ls_data
    IMPORTING
      et_return_map = DATA(lt_return_map)
  ).
*---------------------------------------------------------------------------------------------------------------------
  IF line_exists( lt_return_map[ type = 'E' ] ) OR line_exists( lt_return_map[ type = 'A' ] ).
    IF lv_clear_binpt = abap_true.
      CLEAR sy-binpt.
    ENDIF.
    RAISE EXCEPTION TYPE /thkr/cx_bp
      MESSAGE e001(/thkr/bp_appl) WITH lt_return_map[ 1 ]-message
      EXPORTING bapiret2_tab = CORRESPONDING #( lt_return_map ).
  ENDIF.
*---------------------------------------------------------------------------------------------------------------------
* Create Partner
  cl_md_bp_maintain=>maintain(
    EXPORTING
      i_data     = VALUE #( ( ls_data ) )
      i_test_run = i_dto_bp_create-test_run
    IMPORTING
      e_return   = DATA(lt_return)
  ).

  IF lt_return IS NOT INITIAL AND line_exists( lt_return[ 1 ]-object_msg[ type = 'E' ] ).
    IF lv_clear_binpt = abap_true.
      CLEAR sy-binpt.
    ENDIF.
    RAISE EXCEPTION TYPE /thkr/cx_bp
     MESSAGE e001(/thkr/bp_appl) WITH lt_return[ 1 ]-object_msg[ 1 ]-message
     EXPORTING bapiret2_tab = CORRESPONDING #( lt_return[ 1 ]-object_msg ).
  ENDIF.


  IF lt_sepa_usage IS NOT INITIAL.
* Die Sepa Mandatsverwendungen sind nicht bestandteil der normalen CREATE/CHANGE API.
* Daher müssen separat angelegt werden.
    CALL FUNCTION 'SEPA_MANDATES_API_ADD_USAGE'
      EXPORTING
        i_tab_use_ext = lt_sepa_usage
      IMPORTING
        et_messages   = lt_sepa_messages.
    IF lt_sepa_messages IS NOT INITIAL AND line_exists( lt_sepa_messages[ type = 'E' ] ).
      IF lv_clear_binpt = abap_true.
        CLEAR sy-binpt.
      ENDIF.
      RAISE EXCEPTION TYPE /thkr/cx_bp
        EXPORTING
          bapiret2_tab = CORRESPONDING #( lt_sepa_messages ).
    ENDIF.
  ENDIF.


*---------------------------------------------------------------------------------------------------------------------
  IMPORT lv_partner TO e_partner FROM MEMORY ID 'BUP_MEMORY_PARTNER'.
*---------------------------------------------------------------------------------------------------------------------
  r_partner = e_partner.
*---------------------------------------------------------------------------------------------------------------------

  IF lv_clear_binpt = abap_true.
    CLEAR sy-binpt.
  ENDIF.
ENDMETHOD.


  METHOD get_address_guid_from_partner.

    DATA:
          lv_addrguid TYPE bu_address_guid.

    CALL FUNCTION 'BUA_ADDRESS_GET'
      EXPORTING
        i_partner        = i_partner
        i_adrkind        = co_adrkind_xxdefault
      IMPORTING
        e_addrguid       = lv_addrguid
      EXCEPTIONS
        no_address_found = 1
        internal_error   = 2
        wrong_parameters = 3
        date_invalid     = 4
        not_valid        = 5
        partner_blocked  = 6
        OTHERS           = 7.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_bp USING MESSAGE.
    ENDIF.

    r_guid = lv_addrguid.

  ENDMETHOD.


  METHOD get_instance.

    IF instance IS INITIAL.
      instance = NEW #( ).
    ENDIF.

    r_instance = instance.

  ENDMETHOD.


  METHOD get_partner_data.

    DATA:
      lt_mandates     TYPE bapi_t_sepa_mandate_data,
      ls_but000       TYPE but000,
      ls_fsbp_address TYPE fsbp_address_object,
      ls_kna1         TYPE kna1,
      ls_lfa1         TYPE lfa1.


    CALL FUNCTION 'BUP_CHECK_EXISTENCE'
      EXPORTING
        iv_partner    = i_partner
      EXCEPTIONS
        partner_found = 1
        OTHERS        = 2.
    IF sy-subrc <> 1.
      RAISE EXCEPTION TYPE /thkr/cx_bp USING MESSAGE.
    ENDIF.

* Nicht alle Tabellen sind in einem BO enthalten, daher 2 mal Instanzieeren

* Klassische Partner Daten
*    DATA(lo_bp_api) = fsbp_business_factory=>get_instance( i_partner = i_partner i_name = if_fsbp_const_xo_objects=>bo_business_partner ).
    DATA(lo_bp_api) = xo_api_adapter=>get_instance(
      i_bo_type = if_fsbp_const_xo_objects=>bo_type_business_partner             " Name des Business Object Typs
      i_bo_name = if_fsbp_const_xo_objects=>bo_business_partner                  " Name des Business Objects
    ).

    lo_bp_api->bo_get(
      EXPORTING
        i_object_key = CONV #( i_partner )                " Schlüsselparameter
      IMPORTING
        e_data       = DATA(lt_bo_data)                 " Liste von Tabellendaten
    ).

    r_dto_bp-partner = i_partner.

    LOOP AT lt_bo_data ASSIGNING FIELD-SYMBOL(<fs_data>).
      CASE <fs_data>-table_name.
        WHEN fsbp_api_adapter_intern=>if_fsbp_const_xo_objects~mo_but000.
          LOOP AT <fs_data>-table_data->* INTO ls_but000. ENDLOOP.
          me->map_but000_dto( EXPORTING i_but000 = ls_but000 CHANGING c_dto_bp = r_dto_bp ).

        WHEN fsbp_api_adapter_intern=>if_fsbp_const_xo_objects~mo_address.
          LOOP AT <fs_data>-table_data->* INTO ls_fsbp_address. ENDLOOP.
          me->map_fsbp_address_dto( EXPORTING i_address = ls_fsbp_address CHANGING c_dto_bp = r_dto_bp ).

        WHEN fsbp_api_adapter_intern=>if_fsbp_const_xo_objects~mo_dfkkbptaxnum.
          me->map_dfkkbptaxnum_dto( EXPORTING i_dfkkbptaxnum = <fs_data>-table_data->* CHANGING c_dto_bp = r_dto_bp ).

        WHEN fsbp_api_adapter_intern=>if_fsbp_const_xo_objects~mo_but0bk.
          me->map_but0bk_dto( EXPORTING i_but0bk = <fs_data>-table_data->* CHANGING c_dto_bp = r_dto_bp ).

        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

* um spätere Fehler zu vermeiden, die Instanz abräumen. Modify und Create laufen nur mit CLASSIC Instanz
    xo_controller=>get_instance( lo_bp_api->get_my_bo_type( ) )->raise_cleanup( ).


* Financial Partner Daten laden
    CLEAR: lt_bo_data.

*    lo_bp_api = fsbp_business_factory_intern=>get_instance( i_partner = i_partner ).
    lo_bp_api = xo_api_adapter=>get_instance(
      i_bo_type = if_fsbp_const_xo_objects=>bo_type_business_partner             " Name des Business Object Typs
      i_bo_name = if_fsbp_const_xo_objects=>bo_business_partner_classic                 " Name des Business Objects
    ).

    lo_bp_api->bo_get(
      EXPORTING
        i_object_key = CONV #( i_partner )                " Schlüsselparameter
      IMPORTING
        e_data       = lt_bo_data                 " Liste von Tabellendaten
    ).

    LOOP AT lt_bo_data ASSIGNING <fs_data>.
      CASE <fs_data>-table_name.
        WHEN  if_cvi_const_xo_objects_cust=>mo_kna1.
          LOOP AT <fs_data>-table_data->* INTO ls_kna1. ENDLOOP.
          me->map_kna1_dto( EXPORTING i_kna1 = ls_kna1 CHANGING c_dto_bp = r_dto_bp ).

        WHEN  if_cvi_const_xo_objects_cust=>mo_knb1.
          me->map_knb1_dto( EXPORTING i_knb1 =  <fs_data>-table_data->* CHANGING c_dto_bp = r_dto_bp ).

        WHEN if_cvi_const_xo_objects_vendor=>mo_lfa1 .
          LOOP AT <fs_data>-table_data->* INTO ls_lfa1. ENDLOOP.
          me->map_lfa1_dto( EXPORTING i_lfa1 = ls_lfa1 CHANGING c_dto_bp = r_dto_bp ).

        WHEN if_cvi_const_xo_objects_vendor=>mo_lfb1.
          me->map_lfb1_dto( EXPORTING i_lfb1 =  <fs_data>-table_data->* CHANGING c_dto_bp = r_dto_bp ).

        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

* select Sepa Mandat Data
*SND_ID = GP Nummer
    CALL FUNCTION 'BAPI_SEPA_MANDATE_SELECT1'
      EXPORTING
        is_selection_criteria = VALUE bapi_s_sepa_mandate_selection( application = 'F' snd_type = 'BUS3007' snd_id = i_partner )
        i_check_authority     = VALUE bapiflag(                      bapiflag    = space )
      IMPORTING
        et_mandates_found     = lt_mandates.
    LOOP AT lt_mandates ASSIGNING FIELD-SYMBOL(<fs_mandat>).
      APPEND INITIAL LINE TO r_dto_bp-t_mandate ASSIGNING FIELD-SYMBOL(<fs_dto_mandat>).
      <fs_dto_mandat>-sepa_anwnd = <fs_mandat>-application.
      <fs_dto_mandat>-sepa_crdid = <fs_mandat>-sepa_creditor_id.
      <fs_dto_mandat>-sepa_mndid = <fs_mandat>-sepa_mandate_id.
      <fs_dto_mandat>-sepa_val_from_date = <fs_mandat>-lifetime_from.
      <fs_dto_mandat>-sepa_val_to_date = <fs_mandat>-lifetime_to.
      <fs_dto_mandat>-sepa_sign_city = <fs_mandat>-sign_city.
      <fs_dto_mandat>-sepa_sign_date = <fs_mandat>-sign_date.
      <fs_dto_mandat>-sepa_status = <fs_mandat>-status.
      <fs_dto_mandat>-/thkr/gsber = <fs_mandat>-/thkr/gsber.
      <fs_dto_mandat>-/thkr/xblnr = <fs_mandat>-/thkr/xblnr.
    ENDLOOP.


  ENDMETHOD.


  METHOD map_but000_dto.

    c_dto_bp-bu_type = i_but000-type.
    CASE c_dto_bp-bu_type.
      WHEN 1.
        c_dto_bp-bu_name1 = i_but000-name_last.
        c_dto_bp-bu_name2 = i_but000-name_first.
      WHEN 2.
        c_dto_bp-bu_name1 = i_but000-name_org1.
        c_dto_bp-bu_name2 = i_but000-name_org2.
        c_dto_bp-bu_name3 = i_but000-name_org3.
        c_dto_bp-bu_name4 = i_but000-name_org4.
      WHEN 3.
        c_dto_bp-bu_name1 = i_but000-name_grp1.
        c_dto_bp-bu_name2 = i_but000-name_grp2.
    ENDCASE.


    c_dto_bp-bu_group = i_but000-bu_group.
    c_dto_bp-bu_bpkind = i_but000-bpkind.
    c_dto_bp-bu_bpext = i_but000-bpext.
    c_dto_bp-bu_augrp = i_but000-augrp.
    c_dto_bp-bu_source = i_but000-source.
    c_dto_bp-bu_xdele = i_but000-xdele.
    c_dto_bp-ad_title = i_but000-title.
    c_dto_bp-ad_title1 = i_but000-title_aca1.
    c_dto_bp-ad_titles = i_but000-title_royl.
    c_dto_bp-bu_legenty = i_but000-legal_enty.
    c_dto_bp-bu_birthdt = i_but000-birthdt.

  ENDMETHOD.


  METHOD map_but0bk_dto.

    DATA(lv_current_datum) = CONV bu_bk_valid_from( sy-datum && '000000' ).


    LOOP AT i_but0bk INTO DATA(ls_but0bk) WHERE bk_valid_from <= lv_current_datum AND bk_valid_to >= lv_current_datum.

      c_dto_bp-bkvid  = ls_but0bk-bkvid .
      c_dto_bp-banks  = ls_but0bk-banks .
      c_dto_bp-bankk  = ls_but0bk-bankl .
      c_dto_bp-bankn  = ls_but0bk-bankn.
      c_dto_bp-bkont  = ls_but0bk-bkont.
      c_dto_bp-bu_koinh	= ls_but0bk-koinh.
      c_dto_bp-xezer  = ls_but0bk-xezer.
      c_dto_bp-iban	= ls_but0bk-iban.

      EXIT.
    ENDLOOP.

  ENDMETHOD.


  METHOD map_dfkkbptaxnum_dto.

    LOOP AT i_dfkkbptaxnum INTO DATA(ls_taxnum).

      APPEND VALUE #(
                       bptaxtype = ls_taxnum-taxtype
                       bptaxnum  = ls_taxnum-taxnum
                    ) TO c_dto_bp-t_taxnumber.


    ENDLOOP.

  ENDMETHOD.


METHOD map_dto_bus_ei_extern.
*---------------------------------------------------------------------------------------------------------------------
* Partner aufbauen
*---------------------------------------------------------------------------------------------------------------------
  DATA:
    lv_zbukr        TYPE dzbukr,
    ls_t042         TYPE t042,
    lv_crdid        TYPE sepa_crdid,
    ls_rec_data     TYPE sepa_s_receiver_data,
    lv_bankk        TYPE bankk,
    lv_bkont        TYPE bkont,
    lv_banks        TYPE banks,
    lv_bankn        TYPE bankn,
    ls_bnka         TYPE bnka,
    lt_return       TYPE TABLE OF bapiret2,
    lv_partner_guid TYPE bu_partner_guid.
*---------------------------------------------------------------------------------------------------------------------
  e_bus_ei_extern-header-object_instance-bpartner = i_dto_bp-partner.

  IF i_dto_bp-partner IS INITIAL.
    e_bus_ei_extern-header-object_instance-bpartnerguid = mv_bpartnerguid.
  ELSE.
    CALL FUNCTION 'BUPA_NUMBERS_GET'
      EXPORTING
        iv_partner      = i_dto_bp-partner
      IMPORTING
        ev_partner_guid = lv_partner_guid
      TABLES
        et_return       = lt_return.
    e_bus_ei_extern-header-object_instance-bpartnerguid = lv_partner_guid.
  ENDIF.

  e_bus_ei_extern-header-object_task = mv_object_task.
*---------------------------------------------------------------------------------------------------------------------
* Konzept des GP sieht vor Standard-GP-Rollen werden je GP-Gruppierung kopiert
  e_bus_ei_extern-central_data-role-roles = VALUE #(
                                                    ( task     = mv_object_task
                                                      data_key = |ZDE| && i_dto_bp-bu_group+2(2)  "Debitor
                                                      data     = VALUE #( rolecategory = |ZDE| && i_dto_bp-bu_group+2(2) )
                                                    )
                                                    ( task     = mv_object_task
                                                      data_key = |ZKR| && i_dto_bp-bu_group+2(2) "Kreditor
                                                      data     = VALUE #( rolecategory = |ZKR| && i_dto_bp-bu_group+2(2) )
                                                    )
                                                   ).

  IF mv_object_task = cl_md_bp_maintain=>gc_task_create.
    e_bus_ei_extern-central_data-common-data-bp_control-category = i_dto_bp-bu_type.
    e_bus_ei_extern-central_data-common-data-bp_control-grouping = i_dto_bp-bu_group."für Nummernvergabe

    IF e_bus_ei_extern-central_data-common-data-bp_control-grouping IS INITIAL.
      e_bus_ei_extern-central_data-common-data-bp_control-grouping = '0007'.
    ENDIF.
  ENDIF.
*---------------------------------------------------------------------------------------------------------------------
  CASE i_dto_bp-bu_type.
*---------------------------------------------------------------------------------------------------------------------
* Person
    WHEN 1.
      e_bus_ei_extern-central_data-common-data-bp_person-firstname             = i_dto_bp-bu_name2.
      e_bus_ei_extern-central_data-common-datax-bp_person-firstname            = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_person-lastname              = i_dto_bp-bu_name1.
      e_bus_ei_extern-central_data-common-datax-bp_person-lastname             = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_person-correspondlanguage    = COND #( WHEN i_dto_bp-bu_langu IS INITIAL THEN 'D' ELSE i_dto_bp-bu_langu ).
      e_bus_ei_extern-central_data-common-datax-bp_person-correspondlanguage   = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_person-birthdate             = i_dto_bp-bu_birthdt.
      e_bus_ei_extern-central_data-common-datax-bp_person-birthdate            = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_person-sex                   = i_dto_bp-bu_sexid.
      e_bus_ei_extern-central_data-common-datax-bp_person-sex                  = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_person-title_aca1            = i_dto_bp-ad_title1.
      e_bus_ei_extern-central_data-common-datax-bp_person-title_aca1           = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_person-title_sppl            = i_dto_bp-ad_titles.
      e_bus_ei_extern-central_data-common-datax-bp_person-title_sppl           = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_centraldata-partnerlanguage	 = COND #( WHEN i_dto_bp-bu_langu IS INITIAL THEN 'D' ELSE i_dto_bp-bu_langu ).
      e_bus_ei_extern-central_data-common-datax-bp_centraldata-partnerlanguage = abap_true.
*---------------------------------------------------------------------------------------------------------------------
* Organisation
    WHEN 2.
      e_bus_ei_extern-central_data-common-data-bp_organization-name1      = i_dto_bp-bu_name1.
      e_bus_ei_extern-central_data-common-datax-bp_organization-name1     = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_organization-name2      = i_dto_bp-bu_name2.
      e_bus_ei_extern-central_data-common-datax-bp_organization-name2     = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_organization-name3      = i_dto_bp-bu_name3.
      e_bus_ei_extern-central_data-common-datax-bp_organization-name3     = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_organization-name4      = i_dto_bp-bu_name4.
      e_bus_ei_extern-central_data-common-datax-bp_organization-name4     = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_organization-legalform  = i_dto_bp-bu_legenty.
      e_bus_ei_extern-central_data-common-datax-bp_organization-legalform = abap_true.
*---------------------------------------------------------------------------------------------------------------------
* Gruppe
    WHEN 3.
      e_bus_ei_extern-central_data-common-data-bp_group-namegroup1  = i_dto_bp-bu_name1.
      e_bus_ei_extern-central_data-common-datax-bp_group-namegroup1 = abap_true.
      e_bus_ei_extern-central_data-common-data-bp_group-namegroup2  = i_dto_bp-bu_name2.
      e_bus_ei_extern-central_data-common-datax-bp_group-namegroup2 = abap_true.
*---------------------------------------------------------------------------------------------------------------------
  ENDCASE.
*---------------------------------------------------------------------------------------------------------------------
  e_bus_ei_extern-central_data-common-data-bp_centraldata-partnertype         = i_dto_bp-bu_bpkind.
  e_bus_ei_extern-central_data-common-datax-bp_centraldata-partnertype        = abap_true.
  e_bus_ei_extern-central_data-common-data-bp_centraldata-title_key           = i_dto_bp-ad_title.
  e_bus_ei_extern-central_data-common-datax-bp_centraldata-title_key          = abap_true.
  e_bus_ei_extern-central_data-common-data-bp_centraldata-partnerexternal     = i_dto_bp-bu_bpext.
  e_bus_ei_extern-central_data-common-datax-bp_centraldata-partnerexternal    = abap_true.
  e_bus_ei_extern-central_data-common-data-bp_centraldata-authorizationgroup  = i_dto_bp-bu_augrp.
  e_bus_ei_extern-central_data-common-datax-bp_centraldata-authorizationgroup = abap_true.
  e_bus_ei_extern-central_data-common-data-bp_centraldata-dataorigintype      = i_dto_bp-bu_source.
  e_bus_ei_extern-central_data-common-datax-bp_centraldata-dataorigintype     = abap_true.
  e_bus_ei_extern-central_data-common-data-bp_centraldata-searchterm1         = i_dto_bp-bu_sort1.
  e_bus_ei_extern-central_data-common-datax-bp_centraldata-searchterm1        = abap_true.
  e_bus_ei_extern-central_data-common-data-bp_centraldata-searchterm2         = i_dto_bp-bu_sort2.
  e_bus_ei_extern-central_data-common-datax-bp_centraldata-searchterm2        = abap_true.

* LSA Zusatzfelder
  e_bus_ei_extern-central_data-common-data-/thkr/gsber      = COND #( WHEN i_dto_bp-/thkr/gsber IS INITIAL THEN '0001' ELSE i_dto_bp-/thkr/gsber ).
  e_bus_ei_extern-central_data-common-data-/thkr/sst        = i_dto_bp-/thkr/sst.
  "--> TODO Felder müssen in X Struktur vorhanden sein für ändern .
*    r_bus_ei_extern-central_data-common-datax-/thkr/gsber       = abap_true.
*    r_bus_ei_extern-central_data-common-datax-/thkr/sst       = abap_true.

  e_bus_ei_extern-central_data-address-addresses = VALUE #(
                                                            (
                                                            task                         = mv_object_task
                                                            data_key-operation           = 'XXDFLT'
                                                            data_key-guid                = COND #( WHEN i_dto_bp-partner IS NOT INITIAL THEN get_address_guid_from_partner( i_dto_bp-partner ) )
                                                            data-postal-data-c_o_name    = i_dto_bp-ad_name_co
                                                            data-postal-datax-c_o_name   = abap_true
                                                            data-postal-data-city        = i_dto_bp-ad_city1
                                                            data-postal-datax-city       = abap_true
                                                            data-postal-data-district    = i_dto_bp-ad_city2
                                                            data-postal-datax-district   = abap_true
                                                            data-postal-data-postl_cod1  = i_dto_bp-ad_pstcd1
                                                            data-postal-datax-postl_cod1 = abap_true
                                                            data-postal-data-postl_cod2  = i_dto_bp-ad_pstcd2
                                                            data-postal-datax-postl_cod2 = abap_true
                                                            data-postal-data-po_box      = i_dto_bp-ad_pobx
                                                            data-postal-datax-po_box     = abap_true
                                                            data-postal-data-po_box_cit  = i_dto_bp-ad_pobxloc
                                                            data-postal-datax-po_box_cit = abap_true
                                                            data-postal-data-street      = i_dto_bp-ad_street
                                                            data-postal-datax-street     = abap_true
                                                            data-postal-data-house_no    = i_dto_bp-ad_hsnm1
                                                            data-postal-datax-house_no   = abap_true
                                                            data-postal-data-country     = i_dto_bp-land1
                                                            data-postal-datax-country    = abap_true
                                                            data-postal-data-langu       = i_dto_bp-land1+0(1)
                                                            data-postal-datax-langu      = abap_true
                                                          )
                                                          ).
*---------------------------------------------------------------------------------------------------------------------
  IF i_dto_bp-iban IS NOT INITIAL
  OR ( i_dto_bp-banks is NOT INITIAL
  AND  i_dto_bp-bankk is NOT INITIAL
  AND  i_dto_bp-bankn is NOT INITIAL )
  OR i_dto_bp-iban IS NOT INITIAL AND i_dto_bp-bankk is NOT INITIAL.
      IF  i_dto_bp-iban IS NOT INITIAL AND i_dto_bp-bankk is INITIAL. "IBAN und BIC werden geliefert. Keine Umrechnung notwendig
        CALL FUNCTION 'CONVERT_IBAN_2_BANK_ACCOUNT'
          EXPORTING
            i_iban             = i_dto_bp-iban
*           I_POPUP            =
*           I_ACCNO_UNKNOWN    =
*           I_XIBAN_ONLY       =
*           I_BANKS            =
*           I_XCONVERT_ONLY    =
          IMPORTING
            e_bank_account     = lv_bankn "	C	Bankkontonummer
            e_bank_control_key = lv_bkont " BKONT	Bankkontrollschlüssel
            e_bank_country     = lv_banks " BANKS	Bankland
            e_bank_number      = lv_bankk " BANKK/BNKLZ  Bankschlüssel/Bankleitzal
          EXCEPTIONS
            no_conversion      = 1
            OTHERS             = 2.

        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE /thkr/cx_bp
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

      ELSE.
        lv_bankk = i_dto_bp-bankk.
        lv_bkont = i_dto_bp-bkont.
        lv_banks = i_dto_bp-banks.
        lv_bankn = i_dto_bp-bankn.
      ENDIF.
*---------------------------------------------------------------------------------------------------------------------
      CALL FUNCTION 'READ_BANK_ADDRESS'
        EXPORTING
          bank_country = lv_banks
          bank_number  = lv_bankk
        IMPORTING
          bnka_wa      = ls_bnka
        EXCEPTIONS
          not_found    = 4.

      IF sy-subrc <> 0.
        "dann kein BIC
      ENDIF.
*---------------------------------------------------------------------------------------------------------------------

      e_bus_ei_extern-central_data-bankdetail-bankdetails = VALUE #(
                                                                 (
                                                                 task                = mv_object_task
                                                                 data-externalbankid = i_dto_bp-bkvid
                                                                 data-bank_ctry      = lv_banks " BANKS Bank Länder-/Regionenschlüssel
                                                                 datax-bank_ctry     = abap_true
                                                                 data-bank_ctryiso   = lv_banks " INTCA ISO-Code des Landes/der Region
                                                                 datax-bank_ctryiso  = abap_true
                                                                 data-bank_key       = lv_bankk " BANKK Bankschlüssel
                                                                 datax-bank_key      = abap_true
                                                                 data-bank_acct      = lv_bankn " BANKN Bankkontonummer
                                                                 datax-bank_acct     = abap_true
                                                                 data-ctrl_key       = lv_bkont " BKONT Bankenkontrollschlüssel
                                                                 datax-ctrl_key      = abap_true
                                                                 data-accountholder  = i_dto_bp-bu_koinh
                                                                 datax-accountholder = abap_true
                                                                 data-coll_auth      = i_dto_bp-xezer
                                                                 datax-coll_auth     = abap_true
                                                                 data-iban           = i_dto_bp-iban
                                                                 datax-iban          = abap_true
                                                                 )




      ).
    ENDIF.
*---------------------------------------------------------------------------------------------------------------------
    IF i_dto_bp-t_mandate IS NOT INITIAL.
* Mandat Default Daten lesen
* Zahlenden Buhungskreis ermitteln
      DATA(lv_bukrs) = i_dto_bp-customer-t_customer_company[ 1 ]-bukrs.

      CALL FUNCTION 'FI_FC_GET_PARAMETERS_CC'
        EXPORTING
          i_bukrs         = lv_bukrs
        IMPORTING
          e_s_t042        = ls_t042
        EXCEPTIONS
          entry_not_found = 1
          OTHERS          = 2.

      IF sy-subrc <> 0.
        lv_zbukr = lv_bukrs. "sollte nicht passieren
      ELSE.
        lv_zbukr = ls_t042-zbukr.
      ENDIF.
*---------------------------------------------------------------------------------------------------------------------
* Gläubiger ID ermitteln
      IF NOT ms_sepa_cust-fname_crdid IS INITIAL.
        CALL FUNCTION ms_sepa_cust-fname_crdid "'FI_APAR_MANDATE_DEFAULT_CRDID'
          EXPORTING
            i_rec_id = VALUE sepa_s_receiver_id( rec_type = 'BUS0002' rec_id = lv_zbukr )
          IMPORTING
            e_crdid  = lv_crdid.
      ENDIF.
*---------------------------------------------------------------------------------------------------------------------
* GP Daten Empfänger ermitteln
      IF NOT ms_sepa_cust-fname_def IS INITIAL.
        CALL FUNCTION ms_sepa_cust-fname_def "'FI_APAR_MANDATE_DEFAULT_DATA'
          EXPORTING
            i_snd_id   = VALUE sepa_s_sender_id(   snd_type = 'BUS3007' snd_id = i_dto_bp-partner )
            i_rec_id   = VALUE sepa_s_receiver_id( rec_type = 'BUS0002' rec_id = lv_zbukr )
          IMPORTING
            e_rec_data = ls_rec_data.
      ENDIF.
*---------------------------------------------------------------------------------------------------------------------
      LOOP AT i_dto_bp-t_mandate ASSIGNING FIELD-SYMBOL(<fs_mandate>).
        APPEND VALUE #(                        " Mandate geht nicht mit Update, nur mit Modify
                       task                   = COND #( WHEN mv_object_task = cl_md_bp_maintain=>gc_task_change THEN cl_md_bp_maintain=>gc_task_modify ELSE mv_object_task )
                       data-application       = 'F'
                       datax-application      = abap_true
                       data-snd_type          = 'BUS3007'      "Mandat: Sender-Typ Debitorenkonto
                       datax-snd_type         = abap_true
                       " siehe SAP Hinweis 2442841
                       data-snd_id            = COND #( WHEN mv_object_task = cl_md_bp_maintain=>gc_task_create THEN '' ELSE i_dto_bp-partner )
                       datax-snd_id           = abap_true
                       data-rec_type          = 'BUS0002'      "Mandat: Empfänger-Typ  Buchungskreis
                       datax-rec_type         = abap_true
                       data-rec_id            = lv_zbukr
                       datax-rec_id           = abap_true
                       data-rec_name1         = ls_rec_data-rec_name1
                       datax-rec_name1        = abap_true
                       data-rec_name2         = ls_rec_data-rec_name2
                       datax-rec_name2        = abap_true
                       data-rec_street        = ls_rec_data-rec_street
                       datax-rec_street       = abap_true
                       data-rec_housenum      = ls_rec_data-rec_housenum
                       datax-rec_housenum     = abap_true
                       data-rec_postal        = ls_rec_data-rec_postal
                       datax-rec_postal       = abap_true
                       data-rec_city          = ls_rec_data-rec_city
                       datax-rec_city         = abap_true
                       data-rec_country       = ls_rec_data-rec_country
                       datax-rec_country      = abap_true
                       data-sepa_creditor_id  = lv_crdid
                       datax-sepa_creditor_id = abap_true
                       data-sepa_mandate_id   = <fs_mandate>-sepa_mndid
                       datax-sepa_mandate_id  = abap_true
                       data-lifetime_from     = <fs_mandate>-sepa_val_from_date
                       datax-lifetime_from    = abap_true
                       data-lifetime_to       = <fs_mandate>-sepa_val_to_date
                       datax-lifetime_to      = abap_true
                       data-sign_city         = <fs_mandate>-sepa_sign_city
                       datax-sign_city        = abap_true
                       data-sign_date         = <fs_mandate>-sepa_sign_date
                       datax-sign_date        = abap_true
                       data-status            = COND #( WHEN <fs_mandate>-sepa_status IS INITIAL THEN '1' ELSE <fs_mandate>-sepa_status )
                       datax-status           = abap_true
        " Zahlungsart Std, 1  Einmal Mandat
                       data-pay_type          = COND #( WHEN <fs_mandate>-pay_type IS INITIAL THEN '1' ELSE <fs_mandate>-pay_type )
                       datax-pay_type         = abap_true

                       data-snd_name1         = i_dto_bp-bu_name1
                       datax-snd_name1        = abap_true
                       data-snd_name2         = i_dto_bp-bu_name2
                       datax-snd_name2        = abap_true
                       data-snd_street        = i_dto_bp-ad_street
                       datax-snd_street       = abap_true
                       data-snd_postal        = i_dto_bp-ad_pstcd1
                       datax-snd_postal       = abap_true
                       data-snd_city          = i_dto_bp-ad_city1
                       datax-snd_city         = abap_true
                       data-snd_country       = COND #( WHEN i_dto_bp-land1 IS INITIAL THEN 'DE' ELSE i_dto_bp-land1 )
                       datax-snd_country      = abap_true
                       data-snd_language      = i_dto_bp-land1
                       datax-snd_language     = abap_true
                       data-snd_housenum      = i_dto_bp-ad_hsnm1
                       datax-snd_housenum     = abap_true

                       data-snd_iban          = i_dto_bp-iban
                       datax-snd_iban         = abap_true
                       data-snd_bic           = ls_bnka-swift
                       datax-snd_bic          = abap_true


* THKR Zusatzfelder --> TODO TP BP Felder müssen in X Struktur vorhanden sein für ändern .
                       data-/thkr/gsber       = <fs_mandate>-/thkr/gsber
*                     datax-/thkr/gsber      = abap_true
                       data-/thkr/xblnr       = <fs_mandate>-/thkr/xblnr
*                     datax-/thkr/xblnr      = abap_true

        ) TO e_bus_ei_extern-central_data-sepa_mandate-sepa_mandate.

* Sepa Mandatsverwendung muss einzeln verarbeitet werden
        IF <fs_mandate>-lastuse_date IS NOT INITIAL OR <fs_mandate>-lastuse_doctype IS NOT INITIAL OR <fs_mandate>-lastuse_docid IS NOT INITIAL .
          APPEND VALUE #( anwnd       = 'F'
                          mndid       = <fs_mandate>-sepa_mndid
                          rec_crdid   = lv_crdid
                          use_date    = <fs_mandate>-lastuse_date
                          use_doctype = <fs_mandate>-lastuse_doctype
                          use_docid   = <fs_mandate>-lastuse_docid )
            TO e_sepa_use.
        ENDIF.

      ENDLOOP.
    ENDIF.
*---------------------------------------------------------------------------------------------------------------------
    LOOP AT i_dto_bp-t_ident_number ASSIGNING FIELD-SYMBOL(<fs_ident_number>).
      APPEND VALUE #(
                     task                            = mv_object_task
                     data_key-identificationcategory = <fs_ident_number>-bu_id_category
                     data_key-identificationnumber   = <fs_ident_number>-bu_id_number
                    )
        TO e_bus_ei_extern-central_data-ident_number-ident_numbers.
    ENDLOOP.
*---------------------------------------------------------------------------------------------------------------------
    LOOP AT i_dto_bp-t_taxnumber ASSIGNING FIELD-SYMBOL(<fs_taxnumber>).
      APPEND VALUE #(
                     task               = mv_object_task
                     data_key-taxtype   = <fs_taxnumber>-bptaxtype
                     data_key-taxnumber = <fs_taxnumber>-bptaxnum
                    )
        TO e_bus_ei_extern-central_data-taxnumber-taxnumbers.
    ENDLOOP.
*---------------------------------------------------------------------------------------------------------------------
  ENDMETHOD.


METHOD map_dto_cmds_ei_extern.
*---------------------------------------------------------------------------------------------------------------------
* Customer aufbauen
*---------------------------------------------------------------------------------------------------------------------
  DATA:
    lt_dunning       TYPE cmds_ei_dunning_t,
    ls_company_datax TYPE cmds_ei_company_datax.
*---------------------------------------------------------------------------------------------------------------------
* Key Data
  r_cmds_ei_extern-header-object_instance-kunnr = i_dto_bp-customer-kunnr.
  r_cmds_ei_extern-header-object_task           = mv_object_task.
*---------------------------------------------------------------------------------------------------------------------
* Central data
  MOVE-CORRESPONDING i_dto_bp-customer TO r_cmds_ei_extern-central_data-central-data.

  DATA(lo_strucdescr) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( i_dto_bp-customer ) ).

  LOOP AT lo_strucdescr->components ASSIGNING FIELD-SYMBOL(<fs_component>).
    ASSIGN COMPONENT <fs_component>-name OF STRUCTURE r_cmds_ei_extern-central_data-central-datax TO FIELD-SYMBOL(<fs_datax>).
    IF sy-subrc = 0.
      <fs_datax> = abap_true.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------------------------------------------------------
* Company Data
  IF i_dto_bp-customer-t_customer_company IS NOT INITIAL.

    lo_strucdescr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( i_dto_bp-customer-t_customer_company[ 1 ] ) ).

    LOOP AT lo_strucdescr->components ASSIGNING <fs_component>.
      ASSIGN COMPONENT <fs_component>-name OF STRUCTURE ls_company_datax TO FIELD-SYMBOL(<fs_comp_datax>).
      IF sy-subrc = 0.
        <fs_comp_datax> = abap_true.
      ENDIF.
    ENDLOOP.

    LOOP AT i_dto_bp-customer-t_customer_company ASSIGNING FIELD-SYMBOL(<fs_customer_data>).
      LOOP AT <fs_customer_data>-t_dunning ASSIGNING FIELD-SYMBOL(<fs_dunning>).
        IF sy-tabix = 1.
          " ein Mahnbereich muss Default mit key = Space sein
          APPEND VALUE #( data-mahna = <fs_dunning>-mahna ) TO lt_dunning.
        ENDIF.
        IF <fs_dunning>-maber IS NOT INITIAL.
          APPEND VALUE #( task     = mv_object_task
                          data_key = VALUE #(                              maber = <fs_dunning>-maber )
                          data     = CORRESPONDING #( <fs_dunning> MAPPING mahns = mahns_d )
                          datax    = VALUE #(                              mahna = abap_true mansp = abap_true madat = abap_true mahns = abap_true knrma = abap_true gmvdt = abap_true busab = abap_true )
                        ) TO lt_dunning.
        ENDIF.
      ENDLOOP.
      APPEND VALUE #( task            = mv_object_task
                      data_key-bukrs  = <fs_customer_data>-bukrs
                      data            = CORRESPONDING #( <fs_customer_data> )
                      datax           = ls_company_datax
                      dunning-dunning = lt_dunning
                    ) TO r_cmds_ei_extern-company_data-company.
    ENDLOOP.
  ENDIF.

*---------------------------------------------------------------------------------------------------------------------
ENDMETHOD.


METHOD map_dto_cvis_ei_extern.

  map_dto_bus_ei_extern( EXPORTING i_dto_bp        = i_dto_bp
                         IMPORTING e_bus_ei_extern = e_data-partner
                                   e_sepa_use      = e_sepa_use ).
  e_data-customer = map_dto_cmds_ei_extern( i_dto_bp ).
  e_data-vendor   = map_dto_vmds_ei_extern( i_dto_bp ).

  call_badi_cvi_default_values( CHANGING c_data = e_data ).

ENDMETHOD.


METHOD map_dto_vmds_ei_extern.
*---------------------------------------------------------------------------------------------------------------------
* Vendor aufbauen
*---------------------------------------------------------------------------------------------------------------------
  DATA:
    lt_dunning       TYPE cmds_ei_dunning_t,
    ls_company_datax TYPE vmds_ei_company_datax.
*---------------------------------------------------------------------------------------------------------------------
* Key Data
  r_vmds_ei_extern-header-object_instance-lifnr = i_dto_bp-vendor-lifnr.
  r_vmds_ei_extern-header-object_task = mv_object_task.
*---------------------------------------------------------------------------------------------------------------------
* Central data
  MOVE-CORRESPONDING i_dto_bp-vendor TO r_vmds_ei_extern-central_data-central-data.

  DATA(lo_strucdescr) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( i_dto_bp-vendor ) ).

  LOOP AT lo_strucdescr->components ASSIGNING FIELD-SYMBOL(<fs_component>).
    ASSIGN COMPONENT <fs_component>-name OF STRUCTURE r_vmds_ei_extern-central_data-central-datax TO FIELD-SYMBOL(<fs_datax>).
    IF sy-subrc = 0.
      <fs_datax> = abap_true.
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------------------------------------------------------
* Company Data
  IF i_dto_bp-vendor-t_vendor_company IS NOT INITIAL.

    lo_strucdescr = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( i_dto_bp-vendor-t_vendor_company[ 1 ] ) ).

    LOOP AT lo_strucdescr->components ASSIGNING <fs_component>.
      ASSIGN COMPONENT <fs_component>-name OF STRUCTURE ls_company_datax TO FIELD-SYMBOL(<fs_comp_datax>).

      IF sy-subrc = 0.
        <fs_comp_datax> = abap_true.
      ENDIF.
    ENDLOOP.



    LOOP AT i_dto_bp-vendor-t_vendor_company ASSIGNING FIELD-SYMBOL(<fs_vendor_data>).
      LOOP AT <fs_vendor_data>-t_dunning ASSIGNING FIELD-SYMBOL(<fs_dunning>).
        APPEND VALUE #( task     = mv_object_task
                        data_key = VALUE #( maber = <fs_dunning>-maber )
                        data     = CORRESPONDING #( <fs_dunning> MAPPING mahns = mahns_d )
                        datax    = VALUE #( mahna = abap_true mansp = abap_true madat = abap_true mahns = abap_true knrma = abap_true gmvdt = abap_true busab = abap_true )
                      ) TO lt_dunning.
      ENDLOOP.

      APPEND VALUE #( task            = mv_object_task
                      data_key-bukrs  = <fs_vendor_data>-bukrs
                      data            = CORRESPONDING #( <fs_vendor_data> )
                      datax           = ls_company_datax
                      dunning-dunning = lt_dunning
                    ) TO r_vmds_ei_extern-company_data-company.
    ENDLOOP.
  ENDIF.
*---------------------------------------------------------------------------------------------------------------------
ENDMETHOD.


  METHOD map_fsbp_address_dto.

    c_dto_bp-ad_name_co = i_address-address-c_o_name.
    c_dto_bp-ad_city1 = i_address-address-city.
    c_dto_bp-ad_city2 = i_address-address-district.
    c_dto_bp-ad_pstcd1 = i_address-address-postl_cod1.
    c_dto_bp-ad_pstcd2 = i_address-address-postl_cod2.
    c_dto_bp-ad_pobx = i_address-address-po_box.
    c_dto_bp-ad_pobxloc = i_address-address-po_box_cit.
    c_dto_bp-ad_street = i_address-address-street.
    c_dto_bp-ad_hsnm1 = i_address-address-house_no.
    c_dto_bp-land1 = i_address-address-country.


  ENDMETHOD.


  METHOD map_kna1_dto.

    MOVE-CORRESPONDING i_kna1 TO c_dto_bp-customer.

  ENDMETHOD.


  METHOD map_knb1_dto.

    c_dto_bp-customer-t_customer_company = CORRESPONDING #( i_knb1 ).

  ENDMETHOD.


  METHOD map_lfa1_dto.


    MOVE-CORRESPONDING i_lfa1 TO c_dto_bp-vendor.

  ENDMETHOD.


  METHOD map_lfb1_dto.

    c_dto_bp-vendor-t_vendor_company = CORRESPONDING #( i_lfb1 ).

  ENDMETHOD.


  METHOD modify_partner.
    DATA:
         lt_sepa_messages TYPE  bapiret1_list.

    mv_object_task = cl_md_bp_maintain=>gc_task_change. "MODIFY wird bei Deb/Kred nicht unterstützt

* Map Data
    map_dto_cvis_ei_extern( EXPORTING i_dto_bp = CORRESPONDING #( i_dto_bp_modify )
                            IMPORTING e_data = DATA(ls_data) e_sepa_use = DATA(lt_sepa_usage) ).

* Ausschalten des Popups zur Anzeige von Infomeldungen bei diversen GP Prüfungen im Dialogprozess
    IF sy-binpt IS INITIAL.
      sy-binpt = abap_true.
      DATA(lv_clear_binpt) = abap_true.
    ENDIF.


* Validate data
    cl_md_bp_maintain=>validate_single(
      EXPORTING
        i_data        = ls_data
      IMPORTING
        et_return_map = DATA(lt_return_map)
    ).

    IF line_exists( lt_return_map[ type = 'E' ] ) OR line_exists( lt_return_map[ type = 'A' ] ).
      IF lv_clear_binpt = abap_true.
        CLEAR sy-binpt.
      ENDIF.
      RAISE EXCEPTION TYPE /thkr/cx_bp EXPORTING bapiret2_tab = CORRESPONDING #( lt_return_map ).
    ENDIF.

* Change Partner
    cl_md_bp_maintain=>maintain(
      EXPORTING
        i_data     = VALUE #( ( ls_data ) )
        i_test_run = i_dto_bp_modify-test_run
      IMPORTING
        e_return   = DATA(lt_return)
    ).

    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ 1 ]-object_msg[ type = 'E' ] ).
      IF lv_clear_binpt = abap_true.
        CLEAR sy-binpt.
      ENDIF.
      RAISE EXCEPTION TYPE /thkr/cx_bp EXPORTING bapiret2_tab = CORRESPONDING #( lt_return[ 1 ]-object_msg ).
    ENDIF.


    IF lt_sepa_usage IS NOT INITIAL.
* Die Sepa Mandatsverwendungen sind nicht bestandteil der normalen CREATE/CHANGE API.
* Daher müssen separat angelegt werden.
      CALL FUNCTION 'SEPA_MANDATES_API_ADD_USAGE'
        EXPORTING
          i_tab_use_ext = lt_sepa_usage
        IMPORTING
          et_messages   = lt_sepa_messages.
      IF lt_sepa_messages IS NOT INITIAL AND line_exists( lt_sepa_messages[ type = 'E' ] ).
        IF lv_clear_binpt = abap_true.
          CLEAR sy-binpt.
        ENDIF.
        RAISE EXCEPTION TYPE /thkr/cx_bp
          EXPORTING
            bapiret2_tab = CORRESPONDING #( lt_sepa_messages ).
      ENDIF.
    ENDIF.


    IF lv_clear_binpt = abap_true.
      CLEAR sy-binpt.
    ENDIF.


  ENDMETHOD.


  METHOD release_partner.

    DATA:
      lv_partner      TYPE bu_partner,
      lt_return       TYPE TABLE OF bapiret2,
      lv_partner_guid TYPE bu_partner_guid.

    CALL FUNCTION 'BUPA_NUMBERS_GET'
      EXPORTING
        iv_partner      = i_partner
      IMPORTING
        ev_partner_guid = lv_partner_guid
        ev_partner      = lv_partner
      TABLES
        et_return       = lt_return.
    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_bp EXPORTING bapiret2_tab = CORRESPONDING #( lt_return ).
    ENDIF.


    cl_md_bp_maintain=>maintain(
      EXPORTING
        i_data     = VALUE #( (
                              partner-header-object_task                                    = cl_md_bp_maintain=>gc_task_change
                              partner-header-object_instance-bpartnerguid                   = lv_partner_guid
                              partner-header-object_instance-bpartner                       = lv_partner
                              partner-central_data-common-data-bp_centraldata-centralblock  = space
                              partner-central_data-common-datax-bp_centraldata-centralblock = abap_true
                              partner-central_data-common-data-bp_centraldata-notreleased   = space
                              partner-central_data-common-datax-bp_centraldata-notreleased  = abap_true
                              customer-header-object_task                                   = cl_md_bp_maintain=>gc_task_change
                              customer-header-object_instance-kunnr                         = lv_partner
                              customer-central_data-central-data-sperr                      = space
                              customer-central_data-central-datax-sperr                     = abap_true
                              vendor-header-object_task                                     = cl_md_bp_maintain=>gc_task_change
                              vendor-header-object_instance-lifnr                           = lv_partner
                              vendor-central_data-central-data-sperr                        = space
                              vendor-central_data-central-datax-sperr                       = abap_true
                              ) )
        i_test_run = i_test_run
      IMPORTING
        e_return   = DATA(lt_return_maintain)
    ).

    IF lt_return_maintain IS NOT INITIAL AND ( line_exists( lt_return_maintain[ 1 ]-object_msg[ type = 'E' ] ) OR  line_exists( lt_return_maintain[ 1 ]-object_msg[ type = 'A' ] ) ).
      RAISE EXCEPTION TYPE /thkr/cx_bp EXPORTING bapiret2_tab = CORRESPONDING #( lt_return_maintain[ 1 ]-object_msg ).
    ENDIF.



  ENDMETHOD.
ENDCLASS.
