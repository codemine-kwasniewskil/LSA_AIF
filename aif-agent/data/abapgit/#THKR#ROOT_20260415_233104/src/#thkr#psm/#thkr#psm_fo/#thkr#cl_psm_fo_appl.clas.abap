class /THKR/CL_PSM_FO_APPL definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_FO_APPL .
  methods GET_FOND_DATA
    importing
      !I_FOND_ID type /THKR/DTO_GET_PSM_FO
      !I_FLG_TEXT type FLAG default ABAP_FALSE
    returning
      value(R_FOND) type /THKR/DTO_PSM_FO .
  methods CREATE_FOND
    importing
      !I_FO_CREATE type /THKR/DTO_CREATE_PSM_FO
    returning
      value(R_KEY) type /THKR/DTO_PSM_FO_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods UPDATE_FOND
    importing
      !I_FO_CREATE type /THKR/DTO_CREATE_PSM_FO
    returning
      value(R_KEY) type /THKR/DTO_PSM_FO_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHECK_EXISTANCE
    importing
      !I_FOND_KEY type /THKR/S_PSM_FO_KEY
    returning
      value(RV_RETURN) type BOOLEAN .
protected section.

  constants MC_AUGRP type FM_AUTHGRF value '00' ##NO_TEXT.
  constants MC_SPRAS type SPRAS value 'D' ##NO_TEXT.
private section.

  class-data MO_INSTANCE type ref to /THKR/CL_PSM_FO_APPL .

  methods CHECK_IMPORT_DATA
    importing
      !I_FO_CREATE type /THKR/DTO_CREATE_PSM_FO
    raising
      /THKR/CX_PSM_INT_FI .
  methods MAP_HEADER_FIELDS
    importing
      !I_FO_CREATE type /THKR/DTO_CREATE_PSM_FO
    returning
      value(R_FMFINCODE) type FMFINCODE .
  methods ADJUST_HEADER_FIELDS
    changing
      !C_FMFINCODE type FMFINCODE .
  methods MAP_TEXT_FIELDS
    importing
      !I_FO_CREATE type /THKR/DTO_CREATE_PSM_FO
    returning
      value(R_FMFINT) type FMFINT .
  methods SAVE_LONG_TEXT
    importing
      !I_FO_CREATE type /THKR/DTO_CREATE_PSM_FO .
  methods CONSTRUCTOR .
ENDCLASS.



CLASS /THKR/CL_PSM_FO_APPL IMPLEMENTATION.


  METHOD adjust_header_fields.
    DATA: ls_fmfincode TYPE fmfincode.

    CALL FUNCTION 'FM_FUND_READ'
      EXPORTING
        i_fikrs               = c_fmfincode-fikrs
        i_fincode             = c_fmfincode-fincode
      IMPORTING
        e_f_fmfincode         = ls_fmfincode
      EXCEPTIONS
        master_data_not_found = 1
        fund_not_valid        = 2
        error_occurred        = 3
        date_not_found        = 4
        OTHERS                = 5.

    IF sy-subrc = 0.
      " Verlängerung der Gültigkeitsdauer
      IF c_fmfincode-datab > ls_fmfincode-datab.
        c_fmfincode-datab = ls_fmfincode-datab.
      ENDIF.

      IF c_fmfincode-datbis < ls_fmfincode-datbis.
        c_fmfincode-datbis = ls_fmfincode-datbis.
      ENDIF.
    ELSE.
* Implement suitable error handling here
    ENDIF.
  ENDMETHOD.


  METHOD check_existance.
    FREE: rv_return.

    SELECT COUNT( * ) FROM fmfincode UP TO 1 ROWS WHERE fikrs   = i_fond_key-fikrs
                                                    AND fincode = i_fond_key-fincode.

    IF sy-subrc = 0.
      rv_return = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD check_import_data.
    " Überprüfung der Pflichtfeld-Eingabe
    IF   i_fo_create-fikrs   IS INITIAL
      OR i_fo_create-fincode IS INITIAL
      OR i_fo_create-datab   IS INITIAL
      OR i_fo_create-datbis  IS INITIAL
      OR i_fo_create-type    IS INITIAL
      OR i_fo_create-bezeich IS INITIAL.

      " Erforderliche Felder sind nicht ausgefüllt
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e007.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    "
  ENDMETHOD.


  METHOD create_fond.
    DATA: lt_return TYPE bapiret2_t.

    IF check_existance( i_fond_key = CORRESPONDING #( i_fo_create ) ) = abap_false.   " Überprüfung, dass ein solches Objekt noch nicht erstellt wurde
      check_import_data( i_fo_create ).

      " Feldzuordnung zu Zielstrukturen
      DATA(ls_fmfincode)  = map_header_fields( i_fo_create ).
      DATA(ls_fmfint) = map_text_fields( i_fo_create ).

      " Aufruf des BAPIs zur Erstellung des Objekts
      CALL FUNCTION 'FM_FUND_CREATE'
        EXPORTING
          is_fmfincode = ls_fmfincode
          is_fmfint    = ls_fmfint
          i_flg_test   = abap_false
          i_flg_commit = abap_true
*         i_flg_check_field_status = abap_true
*         it_fundbpd   =
*         i_flg_nolock = abap_false
        IMPORTING
          et_messages  = lt_return.

      " Ausnahmebehandlung
      IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
      ELSE.
        r_key = CORRESPONDING #( ls_fmfincode ).

        IF i_fo_create-longtext IS NOT INITIAL.
          save_long_text( i_fo_create ).
        ENDIF.
      ENDIF.
    ELSE.
      " Der Fond &1 &2 existiert bereits
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e004 WITH i_fo_create-fikrs i_fo_create-fincode.
    ENDIF.

  ENDMETHOD.


  METHOD get_fond_data.

    DATA: l_f_fmfincode TYPE fmfincode,
          l_f_fmfint    TYPE fmfint.

    CALL FUNCTION 'FM_FUND_READ'
      EXPORTING
        i_fikrs               = i_fond_id-fikrs
        i_fincode             = i_fond_id-fincode
        i_gjahr_fincode       = i_fond_id-gjahr_fincode
        i_flg_text            = i_flg_text
      IMPORTING
        e_f_fmfincode         = l_f_fmfincode
        e_f_fmfint            = l_f_fmfint
      EXCEPTIONS
        master_data_not_found = 1
        fund_not_valid        = 2
        error_occurred        = 3
        date_not_found        = 4
        OTHERS                = 5.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING l_f_fmfincode TO r_fond.
      IF l_f_fmfint IS NOT INITIAL.
        MOVE-CORRESPONDING l_f_fmfint TO r_fond.
      ENDIF.
    ELSE.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD get_instance.
    IF mo_instance IS NOT BOUND.
      mo_instance = NEW #( ).
    ENDIF.

    r_instance = mo_instance.
  ENDMETHOD.


  METHOD map_header_fields.
    r_fmfincode = CORRESPONDING #( i_fo_create ).
    r_fmfincode-aenname = sy-uname.
    r_fmfincode-aendat = sy-datum.
    IF r_fmfincode-augrp IS INITIAL.
      r_fmfincode-augrp = mc_augrp.
    ENDIF.
  ENDMETHOD.


  METHOD map_text_fields.
    r_fmfint = CORRESPONDING #( i_fo_create ).
    r_fmfint-mctxt = to_upper( r_fmfint-bezeich ).
    IF r_fmfint-spras IS INITIAL.
      r_fmfint-spras = mc_spras.
    ENDIF.
  ENDMETHOD.


  METHOD save_long_text.
    DATA: ls_head   TYPE thead,
          lt_text   TYPE tline_t,
          lt_strtab TYPE TABLE OF swastrtab.
    DATA: lv_eintraege   TYPE syst_tfill.

    ls_head = VALUE #( tdid = `FD01`
                       tdobject = `FMMD`
                       tdform = `SYSTEM`
                       tdlinesize = 072
                       tdversion = 00001
                       tdspras = i_fo_create-spras
                       tdname = |{ i_fo_create-fikrs }{ i_fo_create-fincode }| ).

    IF ls_head-tdspras IS INITIAL.
      ls_head-tdspras = mc_spras.
    ENDIF.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string                 = i_fo_create-longtext
        max_component_length         = 132
      TABLES
        string_components            = lt_strtab
      EXCEPTIONS
        max_component_length_invalid = 1
        OTHERS                       = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    LOOP AT lt_strtab ASSIGNING FIELD-SYMBOL(<fs_line>).
      APPEND VALUE #( tdformat = `*` tdline = <fs_line>-str ) TO lt_text.
    ENDLOOP.

    CALL FUNCTION 'SELECT_TEXT'
      EXPORTING
        id       = ls_head-tdid
        language = ls_head-tdspras
        name     = ls_head-tdname
        object   = ls_head-tdobject
      IMPORTING
        entries  = lv_eintraege.
    IF lv_eintraege = 0.
      DATA(lv_insert) = abap_true.
    ELSEIF lv_eintraege > 0.
      lv_insert = abap_false.
    ENDIF.

    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header          = ls_head
        insert          = lv_insert
        savemode_direct = abap_true
*      IMPORTING
*       newheader       = ls_head
*       function        =
      TABLES
        lines           = lt_text
      EXCEPTIONS
        object          = 1
        id              = 2
        language        = 3
        name            = 4.
    IF sy-subrc <> 0.
      " Implement suitable error handling here
    ENDIF.
  ENDMETHOD.


  METHOD update_fond.
    DATA: lt_return TYPE bapiret2_t.

    IF check_existance( i_fond_key = CORRESPONDING #( i_fo_create ) ) = abap_true.   " Überprüfung, dass der zu aktualisierende Fonds existiert
      check_import_data( i_fo_create ).

      " Feldzuordnung zu Zielstrukturen
      DATA(ls_fmfincode)  = map_header_fields( i_fo_create ).
      DATA(ls_fmfint) = map_text_fields( i_fo_create ).
      adjust_header_fields( CHANGING c_fmfincode = ls_fmfincode ).

      " Aufruf des BAPIs zur ändern des Objekts
      CALL FUNCTION 'FM_FUND_CHANGE'
        EXPORTING
          is_fmfincode = ls_fmfincode
          is_fmfint    = ls_fmfint
          i_flg_test   = abap_false
          i_flg_commit = abap_true
*         it_fundbpd   =
*         i_flg_check_field_status = abap_true
*         i_flg_nolock = abap_false
        IMPORTING
          et_messages  = lt_return.

      " Ausnahmebehandlung
      IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
      ELSE.
        r_key = CORRESPONDING #( ls_fmfincode ).
        IF i_fo_create-longtext IS NOT INITIAL.
          save_long_text( i_fo_create ).
        ENDIF.
      ENDIF.
    ELSE.
      " Der Fond &1 &2 existiert nicht
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e008 WITH i_fo_create-fikrs i_fo_create-fincode.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
