*&---------------------------------------------------------------------*
*& Report /THKR/TEST_GI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/test_gi.

TABLES: /thkr/c_gi.

PARAMETERS: p_gi  TYPE /thkr/c_gi-gi_id,
            p_rec TYPE /thkr/c_gi_rec-record_id.

PARAMETERS: parname1 TYPE /thkr/gi_src_param DEFAULT 'OBJECT_ID',
            par1     TYPE /thkr/event_ln_key,
            parname2 TYPE /thkr/gi_src_param,
            par2     TYPE /thkr/event_ln_key,
            parname3 TYPE /thkr/event_ln_key,
            par3     TYPE /thkr/event_ln_key,
            parname4 TYPE /thkr/event_ln_key,
            par4     TYPE /thkr/event_ln_key,
            parname5 TYPE /thkr/event_ln_key,
            par5     TYPE /thkr/event_ln_key.

START-OF-SELECTION.

  DATA: l_param_struct_descr TYPE REF TO cl_abap_structdescr,
        lt_components        TYPE abap_component_tab,
        l_param              TYPE REF TO data,
        l_struct             TYPE REF TO data,
        l_dto                TYPE REF TO data,
        l_xmlstr             TYPE xstring,
        lt_mapping           TYPE /thkr/t_gi_mapping_line,
        l_record             TYPE string,
        lt_record            TYPE STANDARD TABLE OF string,
        l_appl               TYPE REF TO /thkr/cl_gi_appl.

  l_appl = /thkr/cl_gi_appl=>get_instance( ).

  APPEND INITIAL LINE TO lt_components ASSIGNING FIELD-SYMBOL(<component>).
  <component>-name = parname1.
  <component>-type ?= cl_abap_datadescr=>describe_by_name( '/THKR/OBJECT_ID' ).

  IF parname2 IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = parname2.
    <component>-type ?= cl_abap_datadescr=>describe_by_name( '/THKR/OBJECT_ID' ).
  ENDIF.

  IF parname3 IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = parname3.
    <component>-type ?= cl_abap_datadescr=>describe_by_name( '/THKR/OBJECT_ID' ).
  ENDIF.

  IF parname4 IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = parname4.
    <component>-type ?= cl_abap_datadescr=>describe_by_name( '/THKR/OBJECT_ID' ).
  ENDIF.

  IF parname5 IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_components ASSIGNING <component>.
    <component>-name = parname5.
    <component>-type ?= cl_abap_datadescr=>describe_by_name( '/THKR/OBJECT_ID' ).
  ENDIF.

  TRY.
      l_param_struct_descr = cl_abap_structdescr=>create(
          p_components = lt_components ).

    CATCH cx_root INTO DATA(l_oerror).
  ENDTRY.

  CREATE DATA l_param TYPE HANDLE l_param_struct_descr.
  ASSIGN l_param->(parname1) TO FIELD-SYMBOL(<param1>).
  <param1> = par1.

  IF parname2 IS NOT INITIAL.
    ASSIGN l_param->(parname2) TO FIELD-SYMBOL(<param2>).
    <param2> = par2.
  ENDIF.

  IF parname3 IS NOT INITIAL.
    ASSIGN l_param->(parname3) TO FIELD-SYMBOL(<param3>).
    <param3> = par3.
  ENDIF.

  IF parname4 IS NOT INITIAL.
    ASSIGN l_param->(parname4) TO FIELD-SYMBOL(<param4>).
    <param4> = par4.
  ENDIF.

  IF parname5 IS NOT INITIAL.
    ASSIGN l_param->(parname5) TO FIELD-SYMBOL(<param5>).
    <param5> = par5.
  ENDIF.

  SELECT SINGLE * INTO @DATA(l_gi)
    FROM /thkr/c_gi
    WHERE gi_id = @p_gi.

  IF l_gi-is_mapping IS INITIAL.
    IF l_gi-gi_structure IS NOT INITIAL.
      CREATE DATA l_dto TYPE (l_gi-gi_structure).
      ASSIGN l_dto->* TO FIELD-SYMBOL(<dto>).
    ELSE.

      l_appl->get_record_type_handles(
        EXPORTING
          i_record_id          = l_gi-record_id
        IMPORTING
          e_struct_descr       = DATA(l_struct_descr) ).

      CREATE DATA l_struct TYPE HANDLE l_struct_descr.
      ASSIGN l_struct->* TO <dto>.

    ENDIF.
  ELSE.
    ASSIGN lt_mapping TO <dto>.
  ENDIF.

  ASSIGN l_param->* TO FIELD-SYMBOL(<param>).

  TRY.
      l_appl->get_data_by_gi(
        EXPORTING
          i_gi_id = l_gi-gi_id
          i_para  = <param>
*         i_usrid =
*         i_shm_id =
        CHANGING
          c_data  = <dto> ).

      CALL TRANSFORMATION id
        SOURCE dto = <dto>
        RESULT XML l_xmlstr.

      CALL FUNCTION 'DISPLAY_XML_STRING'
        EXPORTING
          xml_string = l_xmlstr.

      IF p_rec IS NOT INITIAL.

        l_appl->write_gi_mapping_to_line(
          EXPORTING
            it_mapping  = lt_mapping
            i_record_id = p_rec
          IMPORTING
            e_line      = l_record ).

        CALL TRANSFORMATION id
          SOURCE str = l_record
          RESULT XML l_xmlstr.

        CALL FUNCTION 'DISPLAY_XML_STRING'
          EXPORTING
            xml_string = l_xmlstr.

        APPEND l_record TO lt_record.
        APPEND l_record TO lt_record.
        APPEND l_record TO lt_record.


        cl_gui_frontend_services=>gui_download(
          EXPORTING
            filename  = 'C:\Temp\aaa.txt'
            filetype  = 'ASC'
          CHANGING
            data_tab  = lt_record ).

      ENDIF.

    CATCH /thkr/cx_lsa1 INTO l_oerror.
      /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
  ENDTRY.
