class /THKR/CL_PSM_FB_APPL definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_FB_APPL .
  methods GET_FKBER_DATA
    importing
      !I_FKBER_ID type /THKR/DTO_GET_PSM_FB
      !I_FLG_TEXT type FLAG default ABAP_FALSE
    returning
      value(R_FKBER) type /THKR/DTO_PSM_FB .
  methods CREATE_FKBER
    importing
      !I_FB_CREATE type /THKR/DTO_CREATE_PSM_FB
    returning
      value(R_KEY) type /THKR/DTO_PSM_FB_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods UPDATE_FKBER
    importing
      !I_FB_CREATE type /THKR/DTO_CREATE_PSM_FB
    returning
      value(R_KEY) type /THKR/DTO_PSM_FB_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHECK_EXISTANCE
    importing
      !I_FKBER_ID type FKBER
    returning
      value(RV_RETURN) type BOOLEAN .
protected section.

  constants MC_AUTHGRP type FM_AUTHGR_FAREA value '0000' ##NO_TEXT.
  constants MC_SPRAS type SPRAS value 'D' ##NO_TEXT.
private section.

  class-data MO_INSTANCE type ref to /THKR/CL_PSM_FB_APPL .

  methods CHECK_IMPORT_DATA
    importing
      !I_FB_CREATE type /THKR/DTO_CREATE_PSM_FB
    raising
      /THKR/CX_PSM_INT_FI .
  methods MAP_HEADER_FIELDS
    importing
      !I_FB_CREATE type /THKR/DTO_CREATE_PSM_FB
    returning
      value(R_TFKB_DI) type FMFA_TFKB_DI .
  methods MAP_TEXT_FIELDS
    importing
      !I_FB_CREATE type /THKR/DTO_CREATE_PSM_FB
    returning
      value(R_TFKBT_DI) type FMFA_TFKBT_DI .
  methods ADJUST_HEADER_FIELDS
    importing
      !I_FKBER_ID type FKBER
    changing
      !C_TFKB_DI type FMFA_TFKB_DI .
  methods SAVE_LONG_TEXT
    importing
      !I_FB_CREATE type /THKR/DTO_CREATE_PSM_FB .
  methods CONSTRUCTOR .
ENDCLASS.



CLASS /THKR/CL_PSM_FB_APPL IMPLEMENTATION.


  METHOD adjust_header_fields.
    DATA: ls_tfkb      TYPE tfkb.

    CALL FUNCTION 'FM_TFKB_READ'
      EXPORTING
        i_fkber   = i_fkber_id
      IMPORTING
        e_f_tfkb  = ls_tfkb
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
      " Verlängerung der Gültigkeitsdauer
      IF c_tfkb_di-datab > ls_tfkb-datab.
        c_tfkb_di-datab = ls_tfkb-datab.
      ENDIF.
    ELSE.
* Implement suitable error handling here
    ENDIF.
  ENDMETHOD.


  METHOD check_existance.
    FREE: rv_return.

    SELECT COUNT( * ) FROM tfkb UP TO 1 ROWS WHERE fkber = i_fkber_id.

    IF sy-subrc = 0.
      rv_return = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD check_import_data.
    " Überprüfung der Pflichtfeld-Eingabe
    IF   i_fb_create-fkber   IS INITIAL
      OR i_fb_create-datab   IS INITIAL
      OR i_fb_create-datbis  IS INITIAL.
      " Erforderliche Felder sind nicht ausgefüllt
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e007.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    "
  ENDMETHOD.


  METHOD create_fkber.
    DATA: lt_return TYPE bapiret2_t.

    IF check_existance( i_fkber_id = i_fb_create-fkber ) = abap_false.   " Überprüfung, dass ein solches Objekt noch nicht erstellt wurde
      check_import_data( i_fb_create ).

      " Feldzuordnung zu Zielstrukturen
      DATA(ls_tfkb)  = map_header_fields( i_fb_create ).
      DATA(ls_tfkbt) = map_text_fields( i_fb_create ).

      " Aufruf des BAPIs zur Erstellung des Objekts
      CALL FUNCTION 'FM_FUNC_AREA_CREATE'
        EXPORTING
          i_func_area   = i_fb_create-fkber
          is_tfkb       = ls_tfkb
          is_tfkbt      = ls_tfkbt
          i_flg_testrun = abap_false
          i_flg_commit  = abap_true
        IMPORTING
          et_messages   = lt_return.

      " Ausnahmebehandlung
      IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
      ELSE.
        r_key = i_fb_create-fkber.

        IF i_fb_create-longtext IS NOT INITIAL.
          save_long_text( i_fb_create ).
        ENDIF.
      ENDIF.
    ELSE.
      " Der Funktionsbereich &1 existiert bereits
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e015 WITH i_fb_create-fkber.
    ENDIF.

  ENDMETHOD.


  METHOD get_fkber_data.
    DATA: l_f_tfkb      TYPE tfkb,
          l_f_tfkbt     TYPE tfkbt,
          lv_year_start TYPE sydatum,
          lv_year_end   TYPE sydatum.

    CALL FUNCTION 'FM_TFKB_READ'
      EXPORTING
        i_fkber    = i_fkber_id-fkber
        i_flg_text = i_flg_text
      IMPORTING
        e_f_tfkb   = l_f_tfkb
        e_f_tfkbt  = l_f_tfkbt
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING l_f_tfkb TO r_fkber.
      IF l_f_tfkbt IS NOT INITIAL.
        MOVE-CORRESPONDING l_f_tfkbt TO r_fkber.
      ENDIF.

      " Verproben, ob sich die Intervalle ueberschneiden
      IF i_fkber_id-gjahr_fkber IS NOT INITIAL.
        lv_year_start = |{ i_fkber_id-gjahr_fkber }0101|.
        lv_year_end = |{ i_fkber_id-gjahr_fkber }1231|.

        IF NOT ( ( lv_year_start BETWEEN l_f_tfkb-datab AND l_f_tfkb-datbis )
              OR ( lv_year_end BETWEEN l_f_tfkb-datab AND l_f_tfkb-datbis ) ).
          FREE: r_fkber.
        ENDIF.
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
    r_tfkb_di = CORRESPONDING #( i_fb_create ).
    IF r_tfkb_di-authgrp IS INITIAL.
      r_tfkb_di-authgrp = mc_authgrp.
    ENDIF.
  ENDMETHOD.


  METHOD map_text_fields.
    r_tfkbt_di = CORRESPONDING #( i_fb_create ).
    IF r_tfkbt_di-spras IS INITIAL.
      r_tfkbt_di-spras = mc_spras.
    ENDIF.
  ENDMETHOD.


  METHOD save_long_text.
    DATA: ls_head   TYPE thead,
          lt_text   TYPE tline_t,
          lt_strtab TYPE TABLE OF swastrtab.
    DATA: lv_eintraege   TYPE syst_tfill.

    ls_head = VALUE #( tdid = `FA01`
                       tdobject = `FMMD`
                       tdform = `SYSTEM`
                       tdlinesize = 072
                       tdversion = 00001
                       tdspras = i_fb_create-spras
                       tdname = |{ i_fb_create-fkber }| ).

    IF ls_head-tdspras IS INITIAL.
      ls_head-tdspras = mc_spras.
    ENDIF.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string                 = i_fb_create-longtext
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


  METHOD update_fkber.
    DATA: lt_return TYPE bapiret2_t.

    IF check_existance( i_fkber_id = i_fb_create-fkber ) = abap_true.   " Überprüfung, dass der zu aktualisierende Objects existiert
      check_import_data( i_fb_create ).

      " Feldzuordnung zu Zielstrukturen
      DATA(ls_tfkb)  = map_header_fields( i_fb_create ).
      DATA(ls_tfkbt) = map_text_fields( i_fb_create ).
      adjust_header_fields( EXPORTING i_fkber_id = i_fb_create-fkber CHANGING c_tfkb_di = ls_tfkb ).

      " Aufruf des BAPIs zur Erstellung des Objekts
      CALL FUNCTION 'FM_FUNC_AREA_CHANGE'
        EXPORTING
          i_func_area   = i_fb_create-fkber
*         IS_TFKB_OLD   =
          is_tfkb_new   = ls_tfkb
*         IS_TFKBT_OLD  =
          is_tfkbt_new  = ls_tfkbt
          i_flg_testrun = abap_false
          i_flg_commit  = abap_true
        IMPORTING
          et_messages   = lt_return.

      " Ausnahmebehandlung
      IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
      ELSE.
        r_key = i_fb_create-fkber.
        IF i_fb_create-longtext IS NOT INITIAL.
          save_long_text( i_fb_create ).
        ENDIF.
      ENDIF.
    ELSE.
      " Der Funktionsbereich &1 existiert nicht
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e014 WITH i_fb_create-fkber.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
