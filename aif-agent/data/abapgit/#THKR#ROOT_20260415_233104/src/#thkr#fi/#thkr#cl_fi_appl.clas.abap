CLASS /thkr/cl_fi_appl DEFINITION
  PUBLIC
  CREATE PRIVATE .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_gp_data.
    TYPES: partner TYPE bu_partner,
           iban    TYPE bu_iban.
           INCLUDE TYPE adrc.
    TYPES END OF ty_gp_data .
    TYPES:
      tty_gp_data TYPE SORTED TABLE OF ty_gp_data WITH NON-UNIQUE KEY partner .
    TYPES:
  "    tty_cds_cube TYPE TABLE OF /thkr/cds_bjcube .
      tty_cds_cube TYPE TABLE OF /thkr/cds_aif_ist_rm_sel.

    CLASS-METHODS get_instance
      RETURNING
        VALUE(r_instance) TYPE REF TO /thkr/cl_fi_appl .
    METHODS get_all_psm_fi_document_data
      IMPORTING
        !i_selection_data TYPE /thkr/s_fi_document_selection
      EXPORTING
        !e_document_data  TYPE /thkr/t_fi_document_data
        !e_kassenz_saldo  TYPE /thkr/t_fi_document_data .
protected section.

  data MS_SELECTION_DATA type /THKR/S_FI_DOCUMENT_SELECTION .
  data MT_CUBE_DATA type TTY_CDS_CUBE .

  methods ADD_GP_DATA
    importing
      !I_PARTNER type BU_PARTNER
    exporting
      !E_PARTNER_DATA type /THKR/S_FI_GP_DATA .
  methods ADD_PRESELECT_GP_DATA
    importing
      !I_GP_DATA type TTY_GP_DATA
      !I_PARTNER type BU_PARTNER
    exporting
      !E_PARTNER_DATA type /THKR/S_FI_GP_DATA .
  methods SELECT_BJCUBE_DATA .
  methods FILL_DTO_DATA
    exporting
      !E_DOCUMENT_DATA type /THKR/T_FI_DOCUMENT_DATA
      !E_KASSENZ_SALDO type /THKR/T_FI_DOCUMENT_DATA .
  methods SELECT_GP_DATA
    importing
      !IT_DOCUMENT_DATA type /THKR/T_FI_DOCUMENT_DATA
    returning
      value(RT_GP_DATA) type TTY_GP_DATA .
private section.

  class-data INSTANCE type ref to /THKR/CL_FI_APPL .
ENDCLASS.



CLASS /THKR/CL_FI_APPL IMPLEMENTATION.


  METHOD add_gp_data.

    TRY.
        DATA(ls_partner_data) = /thkr/cl_bp_appl=>get_instance( )->get_partner_data( i_partner = i_partner ).

        e_partner_data-street = ls_partner_data-ad_street.
        e_partner_data-house_no = ls_partner_data-ad_hsnm1.
        e_partner_data-city = ls_partner_data-ad_city1.
        e_partner_data-postl_cod1 = ls_partner_data-ad_pstcd1.
        e_partner_data-country = ls_partner_data-land1.
        e_partner_data-iban = ls_partner_data-iban.

      CATCH /thkr/cx_bp. " Ausnahmeklasse für Geschäftsobjekte  .
        " dann bleiben die Felder leer
    ENDTRY.

  ENDMETHOD.


  METHOD ADD_PRESELECT_GP_DATA.

    READ TABLE i_gp_data ASSIGNING FIELD-SYMBOL(<ls_gp_data>) WITH TABLE KEY partner = i_partner.
    IF sy-subrc = 0.
      e_partner_data-street = <ls_gp_data>-street.
      e_partner_data-house_no = <ls_gp_data>-house_num1.
      e_partner_data-city = <ls_gp_data>-city1.
      e_partner_data-postl_cod1 = <ls_gp_data>-post_code1.
      e_partner_data-country = <ls_gp_data>-country.
      e_partner_data-iban = <ls_gp_data>-iban.
    ENDIF.

  ENDMETHOD.


  METHOD fill_dto_data.
    DATA:
          ls_document_data TYPE /thkr/s_fi_document_data.

* Mapping Cube Daten nach STO Daten
    LOOP AT mt_cube_data ASSIGNING FIELD-SYMBOL(<fs_cube_data>)  WHERE gezahlt NE 0.
      MOVE-CORRESPONDING <fs_cube_data> TO ls_document_data.
      ls_document_data-xblnr                = <fs_cube_data>-kassenzeichen.
      ls_document_data-belnr                = <fs_cube_data>-belnr.
      ls_document_data-budat                = CONV string( <fs_cube_data>-buchungsdatum ).
      ls_document_data-blart                = <fs_cube_data>-accountingdocumenttype.
      ls_document_data-waers                = <fs_cube_data>-twaer.
      ls_document_data-partner              = <fs_cube_data>-bpid.
      ls_document_data-businesspartner_name = <fs_cube_data>-bpname.

*     Neue Felder füllen - 20250521
      ls_document_data-fistl                = <fs_cube_data>-fistel.
      ls_document_data-fipex                = <fs_cube_data>-fipos.
      ls_document_data-gjahr                = <fs_cube_data>-hhj.
      ls_document_data-valut                = <fs_cube_data>-valutadatum.
      ls_document_data-psobt                = <fs_cube_data>-kassendatum.
      ls_document_data-bvorg                = <fs_cube_data>-zeitbuchnummer.
      ls_document_data-city                 = <fs_cube_data>-bpcity.
      ls_document_data-postl_cod1           = <fs_cube_data>-bpplz.
      ls_document_data-street               = <fs_cube_data>-bpadresse.
      ls_document_data-house_no             = <fs_cube_data>-bphousenumber.
      ls_document_data-country              = <fs_cube_data>-bpcountrycode.
      ls_document_data-swift                = <fs_cube_data>-bic.
      ls_document_data-verwzw               = <fs_cube_data>-verwendungszweck.
      ls_document_data-geber                = <fs_cube_data>-dienstelle.

** ZHM000000307 - nachlesen von Kopf-Daten BKPF-BKTXT, da noch nicht im CDS-View ->
** -> kommt jetzt aus Cube.

      " alle Daten
      APPEND ls_document_data TO e_document_data.
      APPEND ls_document_data TO e_kassenz_saldo.

      " Summen
      "      READ TABLE e_kassenz_saldo ASSIGNING FIELD-SYMBOL(<fs_saldo>) WITH KEY xblnr = <fs_cube_data>-documentreferenceid.
*      READ TABLE e_kassenz_saldo ASSIGNING FIELD-SYMBOL(<fs_saldo>) WITH KEY xblnr = <fs_cube_data>-kassenzeichen.
*      IF sy-subrc = 0.
*        ADD ls_document_data-solloriginalbetrag TO <fs_saldo>-solloriginalbetrag.
*        ADD ls_document_data-gezahlt            TO <fs_saldo>-gezahlt.
*        ADD ls_document_data-offenessoll        TO <fs_saldo>-offenessoll.
*      ELSE.
*        APPEND ls_document_data               TO e_kassenz_saldo.
*      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_all_psm_fi_document_data.

    ms_selection_data = i_selection_data.
    ms_selection_data-fikrs = COND #( WHEN ms_selection_data-fikrs IS INITIAL THEN '1000' ELSE ms_selection_data-fikrs ).

    select_bjcube_data( ).


    fill_dto_data( IMPORTING e_document_data = e_document_data e_kassenz_saldo = e_kassenz_saldo ).


  ENDMETHOD.


  METHOD get_instance.

    IF instance IS INITIAL.
      instance = NEW #( ).
    ENDIF.

    r_instance = instance.
  ENDMETHOD.


  METHOD select_bjcube_data.















    DATA(where_clause) =   'fikrs   EQ @ms_selection_data-fikrs'
                           &&' AND bukrs IN @ms_selection_data-bukrs_ra'
                           &&' AND hhj                    IN @ms_selection_data-gjahr_ra'
                           &&' AND belnr                  IN @ms_selection_data-belnr_ra'
                           &&' AND kassenzeichen          IN @ms_selection_data-xblnr_ra'
*                           &&' AND buchungsdatum          IN @ms_selection_data-budat_ra'
                           &&' AND zhldt                  IN @ms_selection_data-budat_ra'
                           &&' AND fipos                  IN @ms_selection_data-fipex_ra'
                           &&' AND fistel                 IN @ms_selection_data-fictr_ra'
                           &&' AND lotkz                  IN @ms_selection_data-lotkz_ra'
                           &&' AND accountingdocumenttype IN @ms_selection_data-blart_ra'
                           &&' AND alreadysent            EQ @ms_selection_data-resend'
                           &&' AND gezahlt                NE 0'.

    "** If SST is given: Just select related items:
    IF ms_selection_data-sst_key IS NOT INITIAL.
      where_clause =  where_clause && ' AND belegsstkey   EQ @ms_selection_data-sst_key'.
      if ms_selection_data-resend = abap_true.
        where_clause =  where_clause && ' AND sstkey       EQ @ms_selection_data-sst_key'.
      endif.
    ENDIF.

    SELECT FROM /thkr/cds_aif_ist_rm_sel
     FIELDS *
     WHERE (where_clause)
     ORDER BY bukrs, kassenzeichen", stunr
     INTO TABLE @mt_cube_data.
    IF sy-subrc NE 0.
      " Dann keine Daten
    ENDIF.

  ENDMETHOD.


  METHOD select_gp_data.
    DATA: lt_but020  TYPE STANDARD TABLE OF but020,
          lt_but0bk  TYPE SORTED TABLE OF but0bk WITH NON-UNIQUE KEY partner,
          lt_adrc    TYPE SORTED TABLE OF adrc WITH NON-UNIQUE KEY addrnumber,
          ls_gp_data LIKE LINE OF rt_gp_data.

    CHECK it_document_data[] IS NOT INITIAL.

    SELECT DISTINCT partner bkvid banks bankl bankn iban FROM but0bk
      INTO CORRESPONDING FIELDS OF TABLE lt_but0bk
      FOR ALL ENTRIES IN it_document_data
      WHERE partner = it_document_data-partner.

    SELECT DISTINCT partner addrnumber FROM but020
      INTO CORRESPONDING FIELDS OF TABLE lt_but020
      FOR ALL ENTRIES IN it_document_data
      WHERE partner = it_document_data-partner.

    IF lt_but020[] IS NOT INITIAL.
      SELECT * FROM adrc
        INTO TABLE lt_adrc
        FOR ALL ENTRIES IN lt_but020
        WHERE addrnumber = lt_but020-addrnumber.
    ENDIF.

    LOOP AT lt_but020 ASSIGNING FIELD-SYMBOL(<ls_but020>).
      FREE: ls_gp_data.
      ls_gp_data-partner = <ls_but020>-partner.

      READ TABLE lt_adrc ASSIGNING FIELD-SYMBOL(<ls_adrc>) WITH TABLE KEY addrnumber = <ls_but020>-addrnumber.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING <ls_adrc> TO ls_gp_data.
      ENDIF.

      READ TABLE lt_but0bk ASSIGNING FIELD-SYMBOL(<ls_but0bk>) WITH TABLE KEY partner = <ls_but020>-partner.
      IF sy-subrc = 0.
        IF <ls_but0bk>-iban IS NOT INITIAL.
          ls_gp_data-iban = <ls_but0bk>-iban.
        ELSE.
          CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
            EXPORTING
              i_bank_account = <ls_but0bk>-bankn
              i_bank_country = <ls_but0bk>-banks
              i_bank_number  = <ls_but0bk>-bankl
              i_bank_key     = <ls_but0bk>-bankl
            IMPORTING
              e_iban         = ls_gp_data-iban
            EXCEPTIONS
              no_conversion  = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            " Implement suitable error handling here
          ENDIF.
        ENDIF.
      ENDIF.

      INSERT ls_gp_data INTO TABLE rt_gp_data.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
