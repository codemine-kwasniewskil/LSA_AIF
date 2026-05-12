class /THKR/CL_PSM_VE_APPL definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_VE_APPL .
  methods GET_VERMERK_DATA
    importing
      !I_VERMERK_ID type /THKR/DTO_GET_PSM_VE
      !I_FLG_TEXT type FLAG default ABAP_FALSE
    returning
      value(R_VERMERK) type /THKR/DTO_PSM_VE .
  methods CREATE_VERMERK
    importing
      !I_VE_CREATE type /THKR/DTO_CREATE_PSM_VE
    returning
      value(R_KEY) type /THKR/DTO_PSM_VE_KEY
    raising
      /THKR/CX_PSM_INT_FI .
protected section.

  constants MC_APPLIC type FMKU_BUDTXT_APPLIC value '01' ##NO_TEXT.
  constants MC_SPRAS type SPRAS value 'D' ##NO_TEXT.
private section.

  class-data MO_INSTANCE type ref to /THKR/CL_PSM_VE_APPL .

  methods GENERATE_TXTTEMPL
    importing
      !IV_TXTTEMPL type BUKU_TXTTEMPL
    returning
      value(RV_TXTTEMPL) type BUKU_TXTTEMPL .
  methods CHECK_IMPORT_DATA
    importing
      !I_VE_CREATE type /THKR/DTO_CREATE_PSM_VE
    raising
      /THKR/CX_PSM_INT_FI .
  methods SAVE_LONG_TEXT
    importing
      !I_VE_CREATE type /THKR/DTO_CREATE_PSM_VE
      !I_TEXTTEMPL type BUKUTEXTTEMPL .
  methods MAP_HEADER_FIELDS
    importing
      !I_VE_CREATE type /THKR/DTO_CREATE_PSM_VE
    returning
      value(RV_TEXTTEMPL) type BUKUTEXTTEMPL .
  methods MAP_TEXT_FIELDS
    importing
      !I_VE_CREATE type /THKR/DTO_CREATE_PSM_VE
      !I_TEXTTEMPL type BUKUTEXTTEMPL
    returning
      value(RV_TEXTTEMPLT) type BUKUTEXTTEMPLT .
  methods CONSTRUCTOR .
ENDCLASS.



CLASS /THKR/CL_PSM_VE_APPL IMPLEMENTATION.


  METHOD check_import_data.
    " Überprüfung der Pflichtfeld-Eingabe
    IF   i_ve_create-applic   IS INITIAL
      OR i_ve_create-txtcat   IS INITIAL
      OR i_ve_create-txttempl IS INITIAL.

      " Erforderliche Felder sind nicht ausgefüllt
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e007.
    ENDIF.

    IF i_ve_create-txttempl+2(1) = 'K'.
      CASE i_ve_create-txttempl+7(1).
        WHEN 0 OR 1 OR 2 OR 3.
          " Der K-Vermerk gehört nicht zum Ausgabetitel und wird nicht übernommen.
          RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE e043.
        WHEN OTHERS.
          EXIT.
      ENDCASE.
    ENDIF.
  ENDMETHOD.


  METHOD CONSTRUCTOR.
    "
  ENDMETHOD.


  METHOD create_vermerk.

*    check_existance( ) - not applicable
    check_import_data( i_ve_create ).

    " Feldzuordnung zu Zielstrukturen
    DATA(ls_bukutexttempl)  = map_header_fields( i_ve_create ).
    DATA(ls_bukutexttemplt) = map_text_fields( i_ve_create = i_ve_create i_texttempl = ls_bukutexttempl ).

    MODIFY bukutexttempl FROM ls_bukutexttempl.
    MODIFY bukutexttemplt FROM ls_bukutexttemplt.

    " Ausnahmebehandlung
    IF sy-subrc = 0.
      save_long_text( i_ve_create = i_ve_create i_texttempl = ls_bukutexttempl ).
      r_key = CORRESPONDING #( ls_bukutexttempl ).
    ELSE.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD generate_txttempl.
    " OBSOLETE METHOD, ID generation now takes place in the mapping of AIF interface HAVWeb - I_0036_001

    DATA: lv_gen_id TYPE numc10.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = '/THKR/VEID'
      IMPORTING
        number                  = lv_gen_id
*       QUANTITY                =
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    IF sy-subrc = 0.
      IF strlen( iv_txttempl ) = 2.
        rv_txttempl = |{ iv_txttempl }{ lv_gen_id }|.
      ELSE.
        rv_txttempl = |{ iv_txttempl }{ lv_gen_id+1(9) }|.
      ENDIF.
    ELSE.
* Implement suitable error handling here
    ENDIF.
  ENDMETHOD.


  METHOD GET_INSTANCE.
    IF mo_instance IS NOT BOUND.
      mo_instance = NEW #( ).
    ENDIF.

    r_instance = mo_instance.
  ENDMETHOD.


  METHOD get_vermerk_data.

    DATA: ls_txttempl       TYPE bukutexttempl,
          ls_txttempl_texts TYPE bukutexttemplt,
          lt_long_text      TYPE buku_t_textline.

    CALL FUNCTION 'BUKU_READ_TEXT_TEMPLATE'
      EXPORTING
        i_applic             = i_vermerk_id-applic
        i_txtcat             = i_vermerk_id-txtcat
        i_txttempl           = i_vermerk_id-txttempl
        i_flg_with_texts     = i_flg_text
        i_flg_with_long_text = i_flg_text
      IMPORTING
        e_s_txttempl         = ls_txttempl
        e_s_txttempl_texts   = ls_txttempl_texts
        e_t_long_text        = lt_long_text
      EXCEPTIONS
        no_entry_found       = 1
        OTHERS               = 2.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_txttempl TO r_vermerk.
      IF ls_txttempl_texts IS NOT INITIAL.
        r_vermerk-text = ls_txttempl_texts-text.
      ENDIF.
      LOOP AT lt_long_text ASSIGNING FIELD-SYMBOL(<ls_long_text>).
        r_vermerk-longtext = |{ r_vermerk-longtext }{ <ls_long_text> }|.
      ENDLOOP.
    ELSE.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD map_header_fields.
    DATA: l_tstmp1 TYPE timestamp.
    GET TIME STAMP FIELD l_tstmp1.

    rv_texttempl = VALUE #( client = sy-mandt
                            applic = i_ve_create-applic
                            txtcat = i_ve_create-txtcat ).

    rv_texttempl-txttempl = i_ve_create-txttempl. " generate_txttempl( i_ve_create-txttempl ).
    rv_texttempl-tdname = |{ i_ve_create-applic }{ i_ve_create-txtcat }{ rv_texttempl-txttempl } { l_tstmp1 }|.

  ENDMETHOD.


  METHOD map_text_fields.
    rv_texttemplt = CORRESPONDING #( i_texttempl ).
    rv_texttemplt-langu = mc_spras.
    rv_texttemplt-text = i_ve_create-text.
  ENDMETHOD.


  METHOD save_long_text.
    DATA: ls_head        TYPE thead,
          lt_text        TYPE tline_t,
          ls_bukutextcat TYPE bukutextcat,
          lt_strtab      TYPE TABLE OF swastrtab.

    " get general info for the header field
    CALL FUNCTION 'BUKU_READ_TEXT_CATEGORY'
      EXPORTING
        i_applic        = i_texttempl-applic
        i_txtcat        = i_texttempl-txtcat
      IMPORTING
        e_s_bukutextcat = ls_bukutextcat
      EXCEPTIONS
        OTHERS          = 1.

    ls_head = VALUE #( tdid = ls_bukutextcat-tdid
                       tdobject = `GLPLTEXT`
                       tdfuser = sy-uname
                       tdfdate = sy-datum
                       tdftime = sy-timlo
                       tdspras = mc_spras
                       tdname = i_texttempl-tdname ).


    " split longtext into a string table
    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string                 = i_ve_create-longtext
        max_component_length         = 132
      TABLES
        string_components            = lt_strtab
      EXCEPTIONS
        max_component_length_invalid = 1
        OTHERS                       = 2.
    IF sy-subrc <> 0.
      " Implement suitable error handling here
    ENDIF.

    LOOP AT lt_strtab ASSIGNING FIELD-SYMBOL(<fs_line>).
      APPEND VALUE #( tdformat = `*` tdline = <fs_line>-str ) TO lt_text.
    ENDLOOP.


    " save the result as standard text
    CALL FUNCTION 'SAVE_TEXT'
      EXPORTING
        header          = ls_head
        insert          = abap_true
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
