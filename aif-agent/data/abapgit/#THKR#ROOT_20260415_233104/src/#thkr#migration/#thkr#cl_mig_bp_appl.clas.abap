class /THKR/CL_MIG_BP_APPL definition
  public
  inheriting from /THKR/CL_BP_APPL
  final
  create public .

public section.

  data M_CLEAR_BKVID type FLAG .

  class-methods MIG_GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_MIG_BP_APPL .
  methods CREATE_NEW_BUKRS
    importing
      !I_PARTNER type BU_PARTNER
      !I_BUKRS type BUKRS
    raising
      /THKR/CX_BP .
protected section.

  methods MAP_DTO_BUS_EI_EXTERN
    redefinition .
private section.

  class-data INSTANCE type ref to /THKR/CL_MIG_BP_APPL .
ENDCLASS.



CLASS /THKR/CL_MIG_BP_APPL IMPLEMENTATION.


  METHOD create_new_bukrs.

    DATA:
      ls_data         TYPE cvis_ei_extern,
      lt_return_num   TYPE TABLE OF bapiret2,
      lv_partner_guid TYPE bu_partner_guid.

* Ausschalten des Popups zur Anzeige von Infomeldungen bei diversen GP Prüfungen im Dialogprozess
    IF sy-binpt IS INITIAL.
      sy-binpt = abap_true.
      DATA(lv_clear_binpt) = abap_true.
    ENDIF.

* Mapping
    CALL FUNCTION 'BUPA_NUMBERS_GET'
      EXPORTING
        iv_partner      = i_partner
      IMPORTING
        ev_partner_guid = lv_partner_guid
      TABLES
        et_return       = lt_return_num.

    ls_data-partner-header-object_task = 'U'.
    ls_data-partner-central_data-role-roles = VALUE #(
                                                    ( task     = 'U'
                                                      data_key = |ZDE07| "Debitor
                                                      data     = VALUE #( rolecategory = |ZDE07| )
                                                    )
                                                    ( task     = 'U'
                                                      data_key = |ZKR07| "Kreditor
                                                      data     = VALUE #( rolecategory = |ZKR07| )
                                                    )
    ).
    ls_data-partner-central_data-common-data-bp_control-grouping = '0007'.
    ls_data-partner-header-object_instance-bpartnerguid = lv_partner_guid.
    ls_data-customer-company_data-company = VALUE #( ( task = 'I' data_key = VALUE #( bukrs = i_bukrs ) ) ).
    ls_data-vendor-company_data-company = VALUE #( ( task = 'I' data_key = VALUE #( bukrs = i_bukrs ) ) ).

    call_badi_cvi_default_values( CHANGING c_data = ls_data ).
    IF ls_data-customer-company_data-company[ 1 ]-data-akont IS INITIAL.
      ls_data-customer-company_data-company[ 1 ]-data-akont = '2300010000'. "  Aus GInf Mapping
    ENDIF.
    IF ls_data-vendor-company_data-company[ 1 ]-data-akont IS INITIAL.
      ls_data-vendor-company_data-company[ 1 ]-data-akont = '4500010000'. "  Aus GInf Mapping
      ls_data-vendor-company_data-company[ 1 ]-data-reprf = 'X'. "  Aus GInf Mapping
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
        i_data   = VALUE #( ( ls_data ) )
      IMPORTING
        e_return = DATA(lt_return)
    ).

    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ 1 ]-object_msg[ type = 'E' ] ).
      IF lv_clear_binpt = abap_true.
        CLEAR sy-binpt.
      ENDIF.
      RAISE EXCEPTION TYPE /thkr/cx_bp EXPORTING bapiret2_tab = CORRESPONDING #( lt_return[ 1 ]-object_msg ).
    ENDIF.


    IF lv_clear_binpt = abap_true.
      CLEAR sy-binpt.
    ENDIF.

  ENDMETHOD.


  METHOD map_dto_bus_ei_extern.

    DATA:
      lt_error_table    TYPE TABLE OF addr_error,
      ls_address_data_1 TYPE  addr1_data,
      ls_address_data_2 TYPE  addr2_data,
      lv_rc             TYPE ad_rcerror,
      ls_dto_bp         TYPE /thkr/s_dto_bp.

    ls_dto_bp = i_dto_bp.
    CLEAR m_clear_bkvid.

* System ist nicht auf IBAN Only konfiguriert
* daher wenn nur IBAN vorhanden oder für DE keine BLZ,
* dann soll in der Migration! keine BV übernommen werden, da Übernahme OP wichtiger
    IF ( i_dto_bp-bankk IS INITIAL AND i_dto_bp-iban IS NOT INITIAL AND i_dto_bp-banks <> 'DE' ) OR
      ( i_dto_bp-bankk IS NOT INITIAL AND i_dto_bp-bankn IS INITIAL AND i_dto_bp-iban IS INITIAL ).
      CLEAR: ls_dto_bp-bankn, ls_dto_bp-bkont, ls_dto_bp-banks,ls_dto_bp-bankk, ls_dto_bp-iban.
      m_clear_bkvid = abap_true.

      " Sonderfall ignorieren
    ELSEIF i_dto_bp-bankn	= '0000000000' AND i_dto_bp-iban IS INITIAL.
      CLEAR: ls_dto_bp-bankn, ls_dto_bp-bkont, ls_dto_bp-banks,ls_dto_bp-bankk, ls_dto_bp-iban.
      m_clear_bkvid = abap_true.

    ELSEIF i_dto_bp-iban IS INITIAL AND i_dto_bp-bankn IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
        EXPORTING
          i_bank_account     = i_dto_bp-bankn                   " Bankkontonummer
          i_bank_control_key = i_dto_bp-bkont " KNBK_BF-BKONT   " Bankenkontrollschlüssel
          i_bank_country     = i_dto_bp-banks " KNBK_BF-BANKS   " Bankland
          i_bank_number      = i_dto_bp-bankk " BNKA-BNKLZ      " Bankleitzahl   BANKL
          i_bank_key         = i_dto_bp-bankk " BNKA-BANKL      " Bankschlüssel  BANKK
        IMPORTING
          e_iban             = ls_dto_bp-iban
        EXCEPTIONS
          no_conversion      = 1
          OTHERS             = 2.
      IF sy-subrc <> 0 OR ls_dto_bp-iban IS INITIAL.
        CLEAR: ls_dto_bp-bankn, ls_dto_bp-bkont, ls_dto_bp-banks,ls_dto_bp-bankk, ls_dto_bp-iban.
        m_clear_bkvid = abap_true.
*        RAISE EXCEPTION TYPE /thkr/cx_bp
*           MESSAGE ID '/THKR/MIG' TYPE 'E' NUMBER '040' WITH i_dto_bp-bankn i_dto_bp-bankk.
      ENDIF.
    ELSEIF i_dto_bp-iban IS NOT INITIAL AND i_dto_bp-banks = 'DE'.
      " Für Deutschland muss die Kontonummer ermittelt werden
      CALL FUNCTION 'CONVERT_IBAN_2_BANK_ACCOUNT'
        EXPORTING
          i_iban             = i_dto_bp-iban
        IMPORTING
          e_bank_account     = ls_dto_bp-bankn "  C Bankkontonummer
          e_bank_control_key = ls_dto_bp-bkont " BKONT  Bankkontrollschlüssel
          e_bank_country     = ls_dto_bp-banks " BANKS  Bankland
          e_bank_number      = ls_dto_bp-bankk " BANKK/BNKLZ  Bankschlüssel/Bankleitzal
        EXCEPTIONS
          no_conversion      = 1
          OTHERS             = 2.
      IF sy-subrc <> 0.
*        RAISE EXCEPTION TYPE /thkr/cx_bp
*         MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        CLEAR: ls_dto_bp-bankn, ls_dto_bp-bkont, ls_dto_bp-banks,ls_dto_bp-bankk, ls_dto_bp-iban.
        m_clear_bkvid = abap_true.
      ENDIF.
    ENDIF.

* noch mal auf Vorhandensein der Bank prüfen
    IF ls_dto_bp-bankk IS NOT INITIAL.
      CALL FUNCTION 'READ_BANK_ADDRESS'
        EXPORTING
          bank_country = ls_dto_bp-banks
          bank_number  = ls_dto_bp-bankk
        EXCEPTIONS
          not_found    = 4.
      IF sy-subrc <> 0.
*        RAISE EXCEPTION TYPE /thkr/cx_bp
*         MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        CLEAR: ls_dto_bp-bankn, ls_dto_bp-bkont, ls_dto_bp-banks,ls_dto_bp-bankk, ls_dto_bp-iban.
        m_clear_bkvid = abap_true.
      ENDIF.

    ENDIF.

    IF ls_dto_bp-bu_birthdt = 0. "wegen richtiger Formatierung
      CLEAR ls_dto_bp-bu_birthdt.
    ENDIF.

* Call Super
    CALL METHOD super->map_dto_bus_ei_extern
      EXPORTING
        i_dto_bp        = ls_dto_bp
      IMPORTING
        e_bus_ei_extern = e_bus_ei_extern
        e_sepa_use      = e_sepa_use.


* Migration Zusatzmapping

    ASSIGN e_bus_ei_extern-central_data-address-addresses[ 1 ] TO FIELD-SYMBOL(<fs_address>).
    <fs_address>-data-communication-phone-current_state = abap_true.
    <fs_address>-data-communication-phone-phone  = VALUE #( ( contact-task = mv_object_task contact-data-telephone = i_dto_bp-mig_tel_number ) ).
    <fs_address>-data-communication-smtp-current_state = abap_true.
    <fs_address>-data-communication-smtp-smtp  = VALUE #( (  contact-task = mv_object_task contact-data-e_mail = i_dto_bp-mig_smtp_addr ) ).


* Prüfung PLZ und Regionschlüssel
*- Wenn der Regionenschlüssel falsch ist, wird dieser LEER gelassen, da es kein  Pflichtfeld darstellt (wenn Regionenschlüssel nicht definiert)
*- Als Platzhalter der PLZ wird ""DE-99998"" verwendet (""99999"" wird in Abstimmung mit Fr. Jäger bereits für ausländische GP verwendet) (wenn PLZ ungültig)"
* Das gilt auch für ausländische Adressen!

    ls_address_data_1 = VALUE #( city1  = <fs_address>-data-postal-data-city   post_code1 = <fs_address>-data-postal-data-postl_cod1
                                 street = <fs_address>-data-postal-data-street country    = <fs_address>-data-postal-data-country ).

    CALL FUNCTION 'ADDR_CHECK'
      EXPORTING
        address_object_type = '1'
      IMPORTING
        returncode          = lv_rc
      TABLES
        error_table         = lt_error_table
      CHANGING
        address_data_1      = ls_address_data_1
      EXCEPTIONS
        parameter_error     = 1
        OTHERS              = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_bp
        MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSEIF lv_rc = 'E'.
      LOOP AT lt_error_table ASSIGNING FIELD-SYMBOL(<fs_error>).
        " Fehler im Land
        IF ( <fs_error>-msg_id = 'AM' AND <fs_error>-msg_number = '214' ) OR "Länder-/Regionenschlüssel &1 ist nicht definiert
          ( <fs_error>-msg_id = 'AM' AND <fs_error>-msg_number BETWEEN '650' AND '747' )."Postleitzahl Fehler
          <fs_address>-data-postal-data-postl_cod1 = '99998'.
          <fs_address>-data-postal-data-country = 'DE'.
          <fs_address>-data-postal-data-region = ''.
        ENDIF.
      ENDLOOP.
    ENDIF.


  ENDMETHOD.


  METHOD mig_get_instance.

    IF instance IS INITIAL.
      instance = NEW #( ).
    ENDIF.

    r_instance = instance.


  ENDMETHOD.
ENDCLASS.
