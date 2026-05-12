class /THKR/CL_MIGR_GRPS definition
  public
  inheriting from /THKR/CL_XLS_UPLOAD
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !PATH type STRING
      !TESTMODE type ABAP_BOOL default ABAP_TRUE
      !KOKRS type KOKRS default '1000'
    raising
      /THKR/CX_FI_INIT .
  methods GET_HIER_RESULTS
    returning
      value(RESULT) type /THKR/T_BAPISET_HIER .
  methods GET_VALUE_RESULTS
    returning
      value(RESULT) type /THKR/T_BAPISET_VALUE .
protected section.

  types:
    BEGIN OF ty_columns,
      level1 TYPE c LENGTH 15,
      level2 TYPE c LENGTH 15,
      level3 TYPE c LENGTH 15,
      level4 TYPE c LENGTH 15,
      level5 TYPE c LENGTH 15,
      value  TYPE c LENGTH 20,
      descr  TYPE c LENGTH 50,
    END OF ty_columns .
  types:
    tty_columns TYPE TABLE OF ty_columns .

  data KOKRS type KOKRS .
  data MAPPED_DATA type TTY_COLUMNS .
  data RESULT_HIERARCHY type /THKR/T_BAPISET_HIER .
  data RESULT_VALUES type /THKR/T_BAPISET_VALUE .

  methods PREPARE_DATA .
  methods PREPARE_VALUE_TABLE
    importing
      !NODE type CHAR15
      !LEVEL type NUM1
    returning
      value(COUNT) type NUM10 .
  methods DETERMINE_LEVEL
    importing
      !ROW type TY_COLUMNS
    returning
      value(LEVEL) type NUM1 .

  methods MAP_AND_GET_FIELD
    redefinition .
  methods PROCESS_FILE
    redefinition .
private section.
ENDCLASS.



CLASS /THKR/CL_MIGR_GRPS IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->path = path.
    me->testmode = testmode.
    me->process( ).
  ENDMETHOD.


  METHOD determine_level.
    IF  row-level1        IS NOT INITIAL
       AND row-level2     IS INITIAL
       AND row-level3     IS INITIAL
       AND row-level4     IS INITIAL
       AND row-level5     IS INITIAL
       AND row-value IS INITIAL .
      level = 0.
    ELSEIF  row-level1    IS NOT INITIAL
       AND row-level2     IS NOT INITIAL
       AND row-level3     IS INITIAL
       AND row-level4     IS INITIAL
       AND row-level5     IS INITIAL
       AND row-value IS INITIAL .
      level = 1.
    ELSEIF  row-level1    IS NOT INITIAL
       AND row-level2     IS NOT INITIAL
       AND row-level3     IS NOT INITIAL
       AND row-level4     IS INITIAL
       AND row-level5     IS INITIAL
       AND row-value IS INITIAL .
      level = 2.
    ELSEIF  row-level1    IS NOT INITIAL
       AND row-level2     IS NOT INITIAL
       AND row-level3     IS NOT INITIAL
       AND row-level4     IS NOT INITIAL
       AND row-level5     IS INITIAL
       AND row-value IS INITIAL .
      level = 3.
    ELSEIF  row-level1    IS NOT INITIAL
       AND row-level2     IS NOT INITIAL
       AND row-level3     IS NOT INITIAL
       AND row-level4     IS NOT INITIAL
       AND row-level5     IS NOT INITIAL
       AND row-value IS INITIAL .
      level = 4.
    ENDIF.


  ENDMETHOD.


  METHOD get_hier_results.
    result = me->result_hierarchy.
  ENDMETHOD.


  method GET_VALUE_RESULTS.
    result = me->result_values.
  endmethod.


  method MAP_AND_GET_FIELD.

    LOOP AT me->fieldmaps INTO DATA(fieldmap).
      ASSIGN COMPONENT sy-tabix OF STRUCTURE structure TO FIELD-SYMBOL(<target>).
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
  endmethod.


  METHOD PREPARE_DATA.
    LOOP AT me->data->* ASSIGNING FIELD-SYMBOL(<line>).
      DATA(row) = VALUE ty_columns( ).
      me->map_and_get_field( EXPORTING line = <line> CHANGING structure = row ).
      APPEND row TO me->mapped_data.
    ENDLOOP.
  ENDMETHOD.


  METHOD prepare_value_table.
    DATA(datas) = me->mapped_data.
    count = 0.
    LOOP AT datas ASSIGNING FIELD-SYMBOL(<line>).
      DATA(result_value) = VALUE /thkr/s_values_hier( valfrom = <line>-value valto = <line>-value descr = <line>-descr ).
      IF  level = 0
      AND <line>-level1     = node
      AND <line>-level2     IS INITIAL
      AND <line>-level3     IS INITIAL
      AND <line>-level4     IS INITIAL
      AND <line>-level5     IS INITIAL
      AND <line>-value IS NOT INITIAL .
        APPEND result_value TO me->result_values.
        count += 1.
      ENDIF.
      " Leaf 1
      IF  level = 1
      AND <line>-level1     IS NOT INITIAL
      AND <line>-level2     = node
      AND <line>-level3     IS INITIAL
      AND <line>-level4     IS INITIAL
      AND <line>-level5     IS INITIAL
      AND <line>-value IS NOT INITIAL .
        APPEND result_value  TO me->result_values.
        count += 1.
      ENDIF.
      " Leaf 2
      IF  level = 2
      AND <line>-level1     IS NOT INITIAL
      AND <line>-level2     IS NOT INITIAL
      AND <line>-level3     = node
      AND <line>-level4     IS INITIAL
      AND <line>-level5     IS INITIAL
      AND <line>-value IS NOT INITIAL .
        APPEND result_value TO me->result_values.
        count += 1.
      ENDIF.
      " Leaf 3
      IF  level = 3
      AND <line>-level1     IS NOT INITIAL
      AND <line>-level2     IS NOT INITIAL
      AND <line>-level3     IS NOT INITIAL
      AND <line>-level4     = node
      AND <line>-level5     IS INITIAL
      AND <line>-value IS NOT INITIAL .
        APPEND result_value TO me->result_values.
        count += 1.
      ENDIF.
      " Leaf 4
      IF  level = 4
      AND <line>-level1     IS NOT INITIAL
      AND <line>-level2     IS NOT INITIAL
      AND <line>-level3     IS NOT INITIAL
      AND <line>-level4     IS NOT INITIAL
      AND <line>-level5     = node
      AND <line>-value IS NOT INITIAL .
        APPEND result_value TO me->result_values.
        count += 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


METHOD process_file.
  DATA: hier   TYPE STANDARD TABLE OF bapiset_hier,
        values TYPE STANDARD TABLE OF bapi1112_values.
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
            me->prepare_data( ).
          CATCH cx_root.
        ENDTRY.
      WHEN OTHERS. " All lines with information
        DATA(row) = VALUE ty_columns( ).
        me->map_and_get_field( EXPORTING line = <line> CHANGING structure = row ).
        """ Ebene 1  Ebene 2 Ebene 3 Ebene 4 Ebene 5 Kostenstelle  Bezeichnung
        """ A        B       C       D       E       F             G
        "" A,D=empty E -> Root Node
        "" B,D=empty E -> Leaf Node, parent = A
        "" etc.
        IF row-value   IS INITIAL     " hierarchy entries only
        AND row-level1 IS NOT INITIAL." no empty rows!
          DATA(level) = me->determine_level( row ).
          ASSIGN COMPONENT |level{ level + 1 }| OF STRUCTURE row TO FIELD-SYMBOL(<lvlfield>).

          me->result_hierarchy = VALUE #( BASE me->result_hierarchy ( groupname = <lvlfield>
                                                                      hierlevel = level
                                                                      valcount  = me->prepare_value_table( level = level node = <lvlfield> )
                                                                      descript  = row-descr ) ).
        ENDIF.
*
    ENDCASE.
    line += 1.
  ENDLOOP .
ENDMETHOD.
ENDCLASS.
