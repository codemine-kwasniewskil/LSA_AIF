class /THKR/CL_PSM_FP_APPL definition
  public
  final
  create private .

public section.

  types:
    BEGIN OF ty_fp_key,
             fikrs TYPE fikrs,
             gjahr TYPE gjahr,
             fipex TYPE fm_fipex,
           END   OF ty_fp_key .

  class-methods GET_INSTANCE
    importing
      !FIKRS type FIKRS
      !GJAHR type GJAHR
      !FIPEX type FM_FIPEX
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_FP_APPL .
  methods UPDATE_FIPOS
    importing
      !I_FP_DATA type /THKR/S_PSM_FP_HEADER
      !I_FP_TEXT type /THKR/S_PSM_FP_TEXT
    returning
      value(R_KEY) type TY_FP_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods CREATE_FIPOS
    importing
      !I_FP_DATA type /THKR/S_PSM_FP_HEADER
      !I_FP_TEXT type /THKR/S_PSM_FP_TEXT
    returning
      value(R_KEY) type TY_FP_KEY
    raising
      /THKR/CX_PSM_INT_FI .
  methods GET_FIPOS_DATA
    importing
      !I_FLG_TEXT type FLAG optional
    exporting
      !E_FP_TEXT type /THKR/S_PSM_FP_TEXT
    returning
      value(R_FP_DATA) type /THKR/S_PSM_FP_HEADER
    exceptions
      /THKR/CX_PSM_INT_FI .
  methods UPDATE_LONGTEXT
    importing
      !TDID type TDID
      !TEXT type STRING
      !SPRAS type SYLANGU default SY-LANGU
    raising
      /THKR/CX_PSM_INT_FI .
protected section.
private section.

  data M_FIKRS type FIKRS .
  data M_GJAHR type GJAHR .
  data M_FIPEX type FM_FIPEX .
  constants MC_VARIANT type FM_VARNT value '000' ##NO_TEXT.

  methods CHECK_IMPORT_DATA
    importing
      !I_FP_DATA type /THKR/S_PSM_FP_HEADER
    raising
      /THKR/CX_PSM_INT_FI .
  methods MAP_HEADER_FIELDS
    importing
      !I_FP_DATA type /THKR/S_PSM_FP_HEADER
    returning
      value(R_FMCI) type FMCI .
  methods MAP_TEXT_FIELDS
    importing
      !I_FP_TEXT type /THKR/S_PSM_FP_TEXT
    returning
      value(R_FMCIT) type FMCIT .
  methods CONSTRUCTOR
    importing
      !I_FIKRS type FIKRS
      !I_GJAHR type GJAHR
      !I_FIPEX type FM_FIPEX .
  methods SAVE_LONG_TEXT
    importing
      !I_FP_TEXT type /THKR/S_PSM_FP_TEXT .
ENDCLASS.



CLASS /THKR/CL_PSM_FP_APPL IMPLEMENTATION.


  METHOD check_import_data.
    IF i_fp_data-zz_fkz IS NOT INITIAL.
      SELECT SINGLE fkz
        FROM /thkr/c_fkz
        INTO @DATA(lv_fkz)
        WHERE fikrs = @m_fikrs AND
              gjahr = @m_gjahr AND
              fkz   = @i_fp_data-zz_fkz.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e018 WITH m_fikrs m_gjahr i_fp_data-zz_fkz.
      ENDIF.
    ENDIF.
    IF i_fp_data-zz_tg IS NOT INITIAL.
      SELECT SINGLE titelgrp
      FROM /thkr/c_titelgrp
      INTO @DATA(ls_tg)
      WHERE fikrs = @m_fikrs AND
            gjahr = @m_gjahr AND
            fkber = @m_fipex(4) AND
            titelgrp   = @i_fp_data-zz_tg.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e019 WITH m_fikrs m_gjahr m_fipex(4) i_fp_data-zz_tg.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    m_fikrs = i_fikrs.
    m_gjahr = i_gjahr.
    m_fipex = i_fipex.
  ENDMETHOD.


  METHOD create_fipos.
    DATA: l_f_fmci    TYPE  fmci.
    DATA: l_f_fmcit   TYPE  fmcit.
    DATA: l_f_fmzubsp TYPE  fmzubsp.
    DATA: l_fipup     TYPE  fmci-fipex.

    IF get_fipos_data( ) IS INITIAL.

      check_import_data( i_fp_data ).

      l_f_fmci  = map_header_fields( i_fp_data ).
      l_f_fmcit = map_text_fields( i_fp_text ).

      CALL FUNCTION 'FM_COM_ITEM_NO_SCREEN_CREATE'
        EXPORTING
          i_f_fmci      = l_f_fmci
          i_f_fmcit     = l_f_fmcit
          i_f_fmzubsp   = l_f_fmzubsp
          i_fipup       = l_fipup
          i_varnt       = mc_variant
        EXCEPTIONS
          error_occured = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE  ID      sy-msgid
                                                          TYPE    sy-msgty
                                                          NUMBER  sy-msgno
                                                          WITH    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        r_key = CORRESPONDING #( l_f_fmci ).
        IF i_fp_text-longtext IS NOT INITIAL.
          save_long_text( i_fp_text = i_fp_text ).
        ENDIF.
      ENDIF.
    ELSE.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e003 WITH m_fikrs m_gjahr m_fipex.
    ENDIF.
  ENDMETHOD.


  METHOD get_fipos_data.
    DATA: l_f_fmci  TYPE fmci.
    DATA: l_f_fmcit TYPE fmcit.

    CALL FUNCTION 'FM_COM_ITEM_READ_SINGLE_DATA'
      EXPORTING
        i_fikrs                  = m_fikrs
        i_gjahr                  = m_gjahr
        i_fipex                  = m_fipex
        i_flg_text               = i_flg_text
        i_flg_hierarchy          = abap_false
      IMPORTING
        e_f_fmci                 = l_f_fmci
        e_f_fmcit                = l_f_fmcit
      EXCEPTIONS
        master_data_not_found    = 1
        hierarchy_data_not_found = 2
        input_error              = 3
        OTHERS                   = 4.
    IF sy-subrc = 0.
      r_fp_data = CORRESPONDING #( l_f_fmci ).
      e_fp_text = CORRESPONDING #( l_f_fmcit ).
    ENDIF.
  ENDMETHOD.


  METHOD get_instance.
    r_instance = NEW #(  i_fikrs = fikrs i_gjahr = gjahr i_fipex = fipex ).
  ENDMETHOD.


  METHOD map_header_fields.
    r_fmci = CORRESPONDING #( i_fp_data ).
    r_fmci-mandt = sy-mandt.
    r_fmci-fikrs = m_fikrs.
    r_fmci-gjahr = m_gjahr.
    r_fmci-fipex = m_fipex.
  ENDMETHOD.


  METHOD map_text_fields.
    r_fmcit = CORRESPONDING #( i_fp_text ).
    r_fmcit-mandt = sy-mandt.
    r_fmcit-fikrs = m_fikrs.
    r_fmcit-gjahr = m_gjahr.
    r_fmcit-fipex = m_fipex.
  ENDMETHOD.


  METHOD save_long_text.
    DATA: ls_head TYPE thead,
          lt_text TYPE tline_t.
    DATA: lt_strtab      TYPE TABLE OF swastrtab.
    DATA: lv_eintraege   TYPE syst_tfill.

    ls_head = VALUE #( tdid = `FP01`
                       tdobject = `FMMD`
                       tdform = `SYSTEM`
                       tdlinesize = 072
                       tdspras = COND #( WHEN i_fp_text-spras IS NOT INITIAL THEN i_fp_text-spras
                                         ELSE sy-langu )
                       tdname = |{ m_fikrs }{ m_gjahr }{ m_fipex }| ).

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string                 = i_fp_text-longtext
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


  METHOD update_fipos.
    DATA: l_f_fmci    TYPE  fmci.
    DATA: l_f_fmcit   TYPE  fmcit.
    DATA: l_f_fmzubsp TYPE  fmzubsp.
    DATA: l_fipup     TYPE  fmci-fipex.

    check_import_data( i_fp_data ).

    l_f_fmci  = map_header_fields( i_fp_data ).
    l_f_fmcit = map_text_fields( i_fp_text ).

    CALL FUNCTION 'FM_COM_ITEM_NO_SCREEN_MAINTAIN'
      EXPORTING
        i_f_fmci         = l_f_fmci
        i_f_fmcit        = l_f_fmcit
        i_f_fmzubsp      = l_f_fmzubsp
        i_flg_no_enqueue = abap_false
        i_fipup          = l_fipup
        i_varnt          = mc_variant
        i_flg_commit     = abap_false
*       IMPORTING
*       E_FLG_INHERIT    =
*       E_FLG_CHANGED    =
      EXCEPTIONS
        error_occured    = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE  ID      sy-msgid
                                                        TYPE    sy-msgty
                                                        NUMBER  sy-msgno
                                                        WITH    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      r_key = CORRESPONDING #( l_f_fmci ).
      IF i_fp_text-longtext IS NOT INITIAL.
        save_long_text( i_fp_text = i_fp_text ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD update_longtext.
    CHECK tdid IS NOT INITIAL AND
          text IS NOT INITIAL.
    DATA: ls_head TYPE thead,
          lt_text TYPE tline_t.
    DATA: lt_strtab      TYPE TABLE OF swastrtab.
    DATA: lv_eintraege   TYPE syst_tfill.

    ls_head = VALUE #( tdid = TDID
                       tdobject = `FMMD`
                       tdform = `SYSTEM`
                       tdlinesize = 072
                       tdspras = conv #( spras )
                       tdname = |{ m_fikrs }{ m_gjahr }{ m_fipex }| ).

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string                 = TEXT
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
ENDCLASS.
