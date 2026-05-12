class /THKR/CL_UPLOAD_MAPPING definition
  public
  inheriting from /THKR/CL_XLS_UPLOAD
  final
  create public .

public section.

  methods RUN
    importing
      !PATH type STRING
    raising
      /THKR/CX_FI_INIT .
  methods GET_MAPPED_DATA
    returning
      value(MAPPED_DATA) type /THKR/T_CENTRMAPPING .
protected section.

  data MAPPED_DATA type /THKR/T_CENTRMAPPING .

  methods MAP_AND_GET_FIELD
    redefinition .
  methods PROCESS_FILE
    redefinition .
private section.
ENDCLASS.



CLASS /THKR/CL_UPLOAD_MAPPING IMPLEMENTATION.


  METHOD get_mapped_data.

    mapped_data = me->mapped_data.

  ENDMETHOD.


  METHOD map_and_get_field.
** The first field is Mandt -> no need:
    DATA(index) = 2.

** Loop over all columns and
**  - skip unwanted
**  - map or transform values
    DATA(struc_desc) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( line ) ).
    LOOP AT struc_desc->components INTO DATA(comp) WHERE name <> 'E' "Bezeichnung
                                                     AND name <> 'R' "Fremdverfahren
                                                     AND name <> 'AD' "Prüfspalte
                                                     AND name <> 'AE' "Bezeichnung
                                                     AND name <> 'AF'. "Bezeichnung

      ASSIGN COMPONENT comp-name OF STRUCTURE line TO FIELD-SYMBOL(<source>).
      ASSIGN COMPONENT index OF STRUCTURE structure TO FIELD-SYMBOL(<target>).

      TRY.
          DATA(descr) = me->fieldmaps[ key = comp-name ].
          CASE descr-value.
            WHEN 'Gültigkeitszeitraum von' OR 'Gültigkeitszeitraum bis'.
              "" 2025-01-01 -> 20250101
              <target> = replace( val = <source> sub = '-' with = '' occ = 0 ).
            WHEN 'OEH alt bisher Fremdmittel-bewirtschaftung'.
              "" nein -> abap_false
              <target> = COND #( WHEN to_lower( <source> ) = 'ja' THEN abap_true ELSE space ).
            WHEN OTHERS.
              "" field -> field
              <target> = <source>.
          ENDCASE.

        CATCH cx_sy_itab_line_not_found INTO DATA(err).
          "" Keep error and end processing:
          RAISE EXCEPTION TYPE /thkr/cx_fi_init
            EXPORTING
              textid = /thkr/cx_fi_init=>no_excel
              msgv1  = 'Keymap fehlhaft: '
              msgv2  = |Feld: { comp-name }|.
      ENDTRY.
      index += 1.
    ENDLOOP.

  ENDMETHOD.


  METHOD process_file.

    DATA(line) = 1.
    LOOP AT me->data->* ASSIGNING FIELD-SYMBOL(<line>).
      CASE line.
        WHEN 1. " Warning and descrption
        WHEN 2. " Columns with description
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
          DATA(row) = VALUE /thkr/centralmap( ).
          me->map_and_get_field( EXPORTING line = <line> CHANGING structure = row ).
          IF row IS NOT INITIAL.
            APPEND row TO me->mapped_data.
          ENDIF.
      ENDCASE.
      line += 1.
    ENDLOOP .

  ENDMETHOD.


  method RUN.
    me->path = path.
    me->process( ).

  endmethod.
ENDCLASS.
