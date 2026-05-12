class /THKR/CL_FI_UPLOAD_GL_ACCOUNT definition
  public
  final
  create public .

public section.

  constants INSERT type CHAR1 value 'I' ##NO_TEXT.
  constants CHANGE type CHAR2 value 'C' ##NO_TEXT.

  methods PROCESS
    importing
      !PATH type STRING
      !BUKRS type BUKRS
      !TESTMODE type ABAP_BOOL default ABAP_TRUE
      !MODE type CHAR1
    raising
      /thkr/cx_FI_INIT .
protected section.

  methods READ_FILE
    importing
      !PATH type STRING
    raising
      /thkr/cx_FI_INIT .
  methods PROCESS_FILE .
  methods MAP_AND_GET_FIELD
    importing
      !LINE type DATA
    changing
      !STRUCTURE type DATA .
  methods MAP_CAREAS
    importing
      !LINE type DATA
    returning
      value(CAREAS) type GLACCOUNT_CAREA_TABLE .
  methods MAP_CCODES
    importing
      !LINE type DATA
    returning
      value(CCODES) type GLACCOUNT_CCODE_TABLE .
  methods MAP_COA
    importing
      !LINE type DATA
    returning
      value(COA) type GLACCOUNT_COA .
  methods MAP_NAMES
    importing
      !LINE type DATA
    returning
      value(NAMES) type GLACCOUNT_NAME_TABLE .
private section.

  data TESTMODE type ABAP_BOOL .
  data DATA type ref to DATA .
  data FIELDMAPS type /thkr/t_KEYVALUE .
  data BUKRS type BUKRS .
  data MESSAGES type BAPIRET2_TAB .
  data MODE type CHAR1 .
ENDCLASS.



CLASS /THKR/CL_FI_UPLOAD_GL_ACCOUNT IMPLEMENTATION.


  METHOD map_and_get_field.

    LOOP AT me->fieldmaps INTO DATA(fieldmap).
      ASSIGN COMPONENT fieldmap-value OF STRUCTURE structure TO FIELD-SYMBOL(<target>).
      ASSIGN COMPONENT fieldmap-key OF STRUCTURE line TO FIELD-SYMBOL(<field>).
      IF <target> IS ASSIGNED
      AND <field> IS ASSIGNED AND <field> IS NOT INITIAL.
        IF fieldmap-value = 'SAKNR'
        OR fieldmap-value = 'SAKAN'
        OR fieldmap-value = 'ZUAWA'
        or fieldmap-value = 'KATYP'.
          <target> = |{ <field> ALPHA = IN }|.
        ELSE.
          <target> = <field>.
        ENDIF.
      ENDIF.
      UNASSIGN <target>.
    ENDLOOP.

  ENDMETHOD.


  METHOD map_careas.
    DATA(data_line) = VALUE glaccount_carea( ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = data_line-keyy ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = data_line-data ).

    me->map_and_get_field( EXPORTING line = line CHANGING structure = data_line-info ).
    data_line-fromto-datab = '19000101'.
    data_line-fromto-datbi = '99991231'.
    data_line-action = COND #( WHEN me->mode = me->insert THEN if_gl_account_master=>gc_glaccount_action-insert
                                                          ELSE if_gl_account_master=>gc_glaccount_action-update ).
    "Just if DATA provided
    CHECK data_line-data IS NOT INITIAL.
    careas = VALUE #( BASE careas ( data_line ) ).
  ENDMETHOD.


  METHOD map_ccodes.
    DATA(data_line) = VALUE glaccount_ccode( ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = data_line-keyy ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = data_line-data ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = data_line-info ).
    data_line-keyy-bukrs = me->bukrs.
    data_line-data-waers = 'EUR'.
    data_line-action = COND #( WHEN me->mode = me->insert THEN if_gl_account_master=>gc_glaccount_action-insert
                                                          ELSE if_gl_account_master=>gc_glaccount_action-update ).
    ccodes = VALUE #( BASE ccodes ( data_line ) ).
  ENDMETHOD.


  METHOD map_coa.

    me->map_and_get_field( EXPORTING line = line CHANGING structure = coa-keyy ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = coa-data ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = coa-info ).

    coa-action = COND #( WHEN me->mode = me->insert THEN if_gl_account_master=>gc_glaccount_action-insert
                                                    ELSE if_gl_account_master=>gc_glaccount_action-update ).
  ENDMETHOD.


  METHOD map_names.

    DATA(data_line) = VALUE glaccount_name( ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = data_line-keyy ).
    me->map_and_get_field( EXPORTING line = line CHANGING structure = data_line-data ).
    data_line-keyy-spras = 'D'.
    data_line-action = COND #( WHEN me->mode = me->insert THEN if_gl_account_master=>gc_glaccount_action-insert
                                                          ELSE if_gl_account_master=>gc_glaccount_action-update ).
    names = VALUE #( BASE names ( data_line ) ).

  ENDMETHOD.


  METHOD process.
    me->bukrs     = bukrs.
    me->testmode  = testmode.
    me->mode      = mode.

    me->read_file( path = path ).

    me->process_file( ).
    IF me->messages IS NOT INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_fi_init EXPORTING bapiret2_tab = me->messages.
    ENDIF.
  ENDMETHOD.


  METHOD process_file.

    DATA(line) = 1.
    LOOP AT me->data->* ASSIGNING FIELD-SYMBOL(<line>).
      CASE line.
        WHEN 1 OR 2. " Text Header, nothing to do
        WHEN 3. " Fieldmapping. Find all fields with a entry: FIELDNAME for input
          TRY.
              LOOP AT CAST cl_abap_structdescr( cl_abap_datadescr=>describe_by_data( <line> ) )->components INTO DATA(comp).
                ASSIGN COMPONENT comp-name OF STRUCTURE <line> TO FIELD-SYMBOL(<field>).
                IF <field> IS ASSIGNED AND <field> IS NOT INITIAL.
                  DATA(fieldmap) = VALUE /thkr/s_keyvalue( key = comp-name value = <field> ).
                  APPEND fieldmap TO me->fieldmaps.
                ENDIF.
              ENDLOOP.
            CATCH cx_root.
          ENDTRY.
        WHEN OTHERS. " All lines with information about the GL Account
          DATA(save_coa)    = me->map_coa( <line> ).

          "" Don't process snx kinf of useless data:
          CHECK save_coa-keyy-saknr IS NOT INITIAL
            AND save_coa-keyy-saknr <> '0000000000'
            AND save_coa-keyy-saknr <> 'x'.

          DATA(save_names)  = me->map_names( <line> ).
          DATA(save_ccodes) = me->map_ccodes( <line> ).
          DATA(save_careas) = me->map_careas( <line> ).
          DATA(return) = VALUE bapiret2_tab( ).
          IF me->testmode EQ abap_false.
            CALL FUNCTION 'GL_ACCT_UTIL_ENQUEUE'
              EXPORTING
                x_chart_of_accounts = abap_true
                x_names             = abap_true
                x_company_code      = abap_true
                x_cost_element      = abap_true
                gl_account_number   = save_coa-keyy-saknr
                chart_of_accounts   = save_coa-keyy-ktopl
                company_code        = me->bukrs
              EXCEPTIONS
                OTHERS              = 1.
            IF sy-subrc <> 0.
              me->messages = VALUE #( BASE me->messages ( id = '/thkr/FI_INIT' number = 000 message = |Konte SKTO: { save_coa-keyy-saknr } nicht sperren| ) ).
              CONTINUE.
            ENDIF.
          ENDIF.
          CALL FUNCTION 'GL_ACCT_MASTER_SAVE'
            EXPORTING
              testmode           = me->testmode
              no_save_at_warning = abap_false
              no_authority_check = abap_false
            TABLES
              account_names      = save_names
              account_ccodes     = save_ccodes
              account_careas     = save_careas
              return             = return
            CHANGING
              account_coa        = save_coa.

          DATA(type) = COND #( WHEN line_exists( return[ type = 'E' ] ) THEN 'E' ELSE 'S' ).
          me->messages = VALUE #( BASE me->messages ( id = '/thkr/FI_INIT' number = 000 type = type message = |Meldungen zu SKTO: { save_coa-keyy-saknr }| ) ).
          me->messages = VALUE #( BASE me->messages ( LINES OF return )  ).

          IF me->testmode EQ abap_false.
            COMMIT WORK AND WAIT.
            CALL FUNCTION 'GL_ACCT_UTIL_DEQUEUE_ALL'.
          ENDIF.
      ENDCASE.
      line += 1.
    ENDLOOP .

  ENDMETHOD.


  METHOD read_file.
    DATA : lt_records       TYPE solix_tab,
           lv_headerxstring TYPE xstring,
           lv_filelength    TYPE i.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename        = path
        filetype        = 'BIN'
      IMPORTING
        filelength      = lv_filelength
        header          = lv_headerxstring
      TABLES
        data_tab        = lt_records
      EXCEPTIONS
        file_open_error = 1
        file_read_error = 2
        OTHERS          = 3.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_filelength
      IMPORTING
        buffer       = lv_headerxstring
      TABLES
        binary_tab   = lt_records
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_fi_init EXPORTING textid = /thkr/cx_fi_init=>no_excel.
    ENDIF.
    TRY .
        DATA(lo_excel_ref) = NEW cl_fdt_xl_spreadsheet(
          document_name = path
          xdocument     = lv_headerxstring ).
      CATCH cx_fdt_excel_core INTO DATA(error).
        RAISE EXCEPTION TYPE /thkr/cx_fi_init EXPORTING textid = /thkr/cx_fi_init=>no_excel previous = error.
    ENDTRY .

    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names( IMPORTING worksheet_names = DATA(lt_worksheets) ).

    IF NOT lt_worksheets IS INITIAL.
      READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.
      me->data = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
        lv_woksheetname ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
