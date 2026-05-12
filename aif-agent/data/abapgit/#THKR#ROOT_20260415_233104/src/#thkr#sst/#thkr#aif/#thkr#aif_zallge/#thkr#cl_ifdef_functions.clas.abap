class /THKR/CL_IFDEF_FUNCTIONS definition
  public
  final
  create public .

public section.

  methods ANONYMISATION
    importing
      !IS_FINF type /AIF/T_FINF
    changing
      !CS_RAW_STRUC type ANY .
protected section.
private section.

  types:
    ty_t_ano_set TYPE STANDARD TABLE OF /thkr/ano_set .

  methods GET_LFA_PROP
    importing
      !IV_STRUC_NAME type /AIF/LFA_STRUNAME
    exporting
      !EV_SEPARATOR type /AIF/LFA_SEPARATOR
      !EV_FIELDNAME type /AIF/LFA_FIELD .
  methods GET_SST
    importing
      !IS_FINF type /AIF/T_FINF
    returning
      value(RV_/THKR/SST) type /THKR/DTE_BU_SST .
  methods SELECT_ANONYMISATION_CONFIG
    importing
      !IV_SST type /THKR/DTE_BU_SST
    exporting
      !ET_ANO_SET type TY_T_ANO_SET .
ENDCLASS.



CLASS /THKR/CL_IFDEF_FUNCTIONS IMPLEMENTATION.


  METHOD anonymisation.
    DATA:  lt_felder         TYPE TABLE OF string.
    DATA:  ls_felder         TYPE string.
    DATA:  lo_tabl          TYPE REF TO cl_abap_tabledescr.
    DATA:  lo_struc         TYPE REF TO cl_abap_structdescr.
    DATA:  lv_tabix(4)       TYPE n.
    FIELD-SYMBOLS: <lt_data> TYPE STANDARD TABLE.
    FIELD-SYMBOLS: <fs_value> TYPE any.

    "Get configuration of File adapter based on structure
    get_lfa_prop(
      EXPORTING
        iv_struc_name = is_finf-ddicstructureraw                 " Name einer Struktur
      IMPORTING
        ev_separator  = DATA(lv_separator)                 " Feldtrennzeichen
        ev_fieldname  = DATA(lv_fieldname)                 " Feldname
    ).
    IF lv_fieldname IS INITIAL.
      "There is no component. data table = root structure
      ASSIGN cs_raw_struc TO <lt_data>.
    ELSE.
      "there is a component. assign data table of sub structure
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE cs_raw_struc TO <lt_data>.
    ENDIF.

    "get interface from AIF Mapping
    DATA(lv_sst) = get_sst( is_finf = is_finf ).

    "Read anonymisation configuration
    select_anonymisation_config(
      EXPORTING
        iv_sst        =  lv_sst                " BP: Schnittstellenpartner
      IMPORTING
        et_ano_set    = DATA(lt_ano_set)
    ).

    "Get fields from raw structure
    lo_tabl ?= cl_abap_tabledescr=>describe_by_data( p_data = <lt_data> ).
    lo_struc ?= lo_tabl->get_table_line_type( ).
    DATA(lt_comp) = lo_struc->get_components( ).

    "Loop through raw data
    IF lt_ano_set IS NOT INITIAL.
      LOOP AT <lt_data> ASSIGNING FIELD-SYMBOL(<ls_data_line>).

        "loop throuth raw structure to anoymize the fields.
        LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>).
          ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE <ls_data_line> TO <fs_value>.
          TRY.
              <fs_value> = lt_ano_set[ field = <ls_comp>-name ]-wert.
            CATCH cx_sy_itab_line_not_found.
              "No configuration for field. go ahead.
              CONTINUE.
          ENDTRY.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  method GET_LFA_PROP.
    SELECT SINGLE SEPARATOR, FIELDNAME
      FROM /AIF/T_LFA_CONF
     where structure = @iv_struc_name
      into (@ev_separator, @ev_fieldname ).
      if sy-subrc <> 0.
        clear: ev_separator, ev_fieldname.
      endif.
  endmethod.


  METHOD get_sst.

    SELECT SINGLE sap_fieldname1, ns_vmapname, vmapname
      FROM /aif/t_fmap
     WHERE ns = @is_finf-ns
       AND ifname = @is_finf-ifname
       AND ifversion = @is_finf-ifversion
       AND fieldname = '/THKR/SST'
      INTO (@DATA(lv_ns_fieldname), @DATA(lv_ns_vmap), @DATA(lv_vmap) ).

    IF lv_ns_vmap IS INITIAL AND lv_vmap IS INITIAL.
      "no mapping used.
      "Fix value
      "In AIF the first character is $ or %
      "Delete first character
      rv_/thkr/sst = lv_ns_fieldname+1.
    ELSE.
      SELECT SINGLE int_value FROM /aif/t_vmapval INTO @rv_/thkr/sst
            WHERE ns        = @lv_ns_vmap
              AND vmapname  = @lv_vmap
              AND ext_value = @lv_ns_fieldname+1.
    ENDIF.
  ENDMETHOD.


  METHOD SELECT_ANONYMISATION_CONFIG.

    SELECT SINGLE * FROM /thkr/ano_system INTO @DATA(ls_ano_system)
            WHERE active = 'ACTIVE'.
    IF sy-subrc = 0.

* Anonymization-Set for this Interface
      SELECT SINGLE * FROM /thkr/ano_zuord INTO @DATA(ls_ano_zuord)
      WHERE sst   = @iv_sst.
      IF sy-subrc = 0.
* Read all fields of the Set and anonymize accordingly
        SELECT * FROM /thkr/ano_set INTO TABLE @et_ano_set
         WHERE ano_set = @ls_ano_zuord-ano_set.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
