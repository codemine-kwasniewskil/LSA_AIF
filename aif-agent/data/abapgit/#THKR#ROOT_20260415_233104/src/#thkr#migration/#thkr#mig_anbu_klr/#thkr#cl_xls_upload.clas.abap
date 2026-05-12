class /THKR/CL_XLS_UPLOAD definition
  public
  abstract
  create public .

public section.

  constants INSERT type CHAR1 value 'I' ##NO_TEXT.
  constants CHANGE type CHAR2 value 'C' ##NO_TEXT.
protected section.

  data TESTMODE type ABAP_BOOL .
  data DATA type ref to DATA .
  data FIELDMAPS type /THKR/T_KEYVALUE .
  data MESSAGES type BAPIRET2_TAB .
  data PATH type STRING .

  methods PROCESS
    raising
      /THKR/CX_FI_INIT .
  methods READ_FILE
    raising
      /THKR/CX_FI_INIT .
  methods PROCESS_FILE
    raising
      /THKR/CX_FI_INIT .
  methods MAP_AND_GET_FIELD
    importing
      !LINE type DATA
    changing
      !STRUCTURE type DATA
    raising
      /THKR/CX_FI_INIT .
private section.
ENDCLASS.



CLASS /THKR/CL_XLS_UPLOAD IMPLEMENTATION.


  METHOD map_and_get_field.

    LOOP AT me->fieldmaps INTO DATA(fieldmap).
      ASSIGN COMPONENT fieldmap-value OF STRUCTURE structure TO FIELD-SYMBOL(<target>).
      ASSIGN COMPONENT fieldmap-key OF STRUCTURE line TO FIELD-SYMBOL(<field>).
      IF <target> IS ASSIGNED
      AND <field> IS ASSIGNED AND <field> IS NOT INITIAL.
        IF 1 = 2.
*          Do some conversions for fields
*          <target> = |{ <field> ALPHA = IN }|.
        ELSE.
          <target> = <field>.
        ENDIF.
      ENDIF.
      UNASSIGN <target>.
    ENDLOOP.

  ENDMETHOD.


  METHOD PROCESS.
    me->read_file( ).
    me->process_file( ).
    IF me->messages IS NOT INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_fi_init EXPORTING bapiret2_tab = me->messages.
    ENDIF.
  ENDMETHOD.


  METHOD process_file.

    DATA(line) = 1.
    LOOP AT me->data->* ASSIGNING FIELD-SYMBOL(<line>).
      CASE line.
        WHEN 1. " Text Header
          " nothing to do

        WHEN 2. " Columns
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
        WHEN OTHERS. " All lines with information

      ENDCASE.
      line += 1.
    ENDLOOP .

  ENDMETHOD.


  METHOD READ_FILE.
    DATA : lt_records       TYPE solix_tab,
           lv_headerxstring TYPE xstring,
           lv_filelength    TYPE i.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename        = me->path
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
          document_name = me->path
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
