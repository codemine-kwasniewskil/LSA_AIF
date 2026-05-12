CLASS /thkr/cl_test_appl DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CLASS-METHODS get_instance
      EXPORTING
        !e_instance       TYPE REF TO /thkr/cl_test_appl
      RETURNING
        VALUE(r_instance) TYPE REF TO /thkr/cl_test_appl .
    METHODS get_object_data
      IMPORTING
        VALUE(i_object_type) TYPE /thkr/object_type
        VALUE(i_object_id)   TYPE /thkr/object_id
      EXPORTING
        !et_dto              TYPE /thkr/t_dto
      RAISING
        /thkr/cx_lsa1 .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA instance TYPE REF TO /thkr/cl_test_appl .
ENDCLASS.



CLASS /THKR/CL_TEST_APPL IMPLEMENTATION.


  METHOD get_instance.

    IF instance IS INITIAL.
      CREATE OBJECT instance.
    ENDIF.

    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.


  METHOD get_object_data.

    DATA: l_parameter          TYPE abap_parmbind,
          lt_parameter         TYPE abap_parmbind_tab,
          l_cls_int            TYPE REF TO object,
          l_cls_int_name       TYPE /thkr/int_cls,
          l_dto_ref            TYPE REF TO data,
          l_obj                TYPE /thkr/c_obj,
          l_oerror             TYPE REF TO cx_root,
          l_oerror_zlsa        TYPE REF TO /thkr/cx_lsa1,
          l_message            TYPE string,
          l_object_type        TYPE /thkr/object_type,
          l_object_id          TYPE /thkr/object_id,
          l_dto                TYPE REF TO data,
          l_dto1               TYPE REF TO data,
          l_dto_line           TYPE /thkr/s_dto,
          l_methodname         TYPE /thkr/c_obj-int_methode,
          l_dto_type           TYPE rs38l_typ,
          l_dto_description    TYPE seodescr,
          l_param_type         TYPE rs38l_typ,
          l_param_description  TYPE seodescr,
          l_helper             TYPE REF TO /thkr/cl_helpers,
          lt_methods           TYPE STANDARD TABLE OF /thkr/c_obj_met,
          l_method             TYPE /thkr/c_obj_met,
          l_parent_object_type TYPE /thkr/object_type,
          l_parent_object_id   TYPE /thkr/object_id.

    FIELD-SYMBOLS: <cls_int> TYPE any,
                   <value>   TYPE any,
                   <param>   TYPE any,
                   <field>   TYPE any.

    l_helper = /thkr/cl_helpers=>get_instance( ).

    CLEAR: et_dto.

    l_object_type = i_object_type.
    l_object_id   = i_object_id.

    WHILE l_object_id IS NOT INITIAL.

      SELECT SINGLE * INTO l_obj
        FROM /thkr/c_obj
        WHERE object_type = l_object_type.

      IF sy-subrc <> 0.
        "Für 'OBJECT' muss es nichts geben, ansonsten ist das Customizing fehlerhaft
        IF l_object_type = 'OBJECT'.
          EXIT.
        ENDIF.
        ASSERT 1 = 2.
      ENDIF.

*     Zugriffsreferenz auf INT-Klasse holen
      CLEAR lt_parameter.
      l_parameter-kind = cl_abap_objectdescr=>importing.
      l_parameter-name = 'E_INSTANCE'.
      CREATE DATA l_parameter-value TYPE REF TO (l_obj-int_cls).
      INSERT l_parameter INTO TABLE lt_parameter.

      CALL METHOD (l_obj-int_cls)=>get_instance
        PARAMETER-TABLE
        lt_parameter.

      ASSIGN l_parameter-value->* TO <cls_int>.
      l_cls_int ?= <cls_int>.

*     Übergabeparameter für get_dto-Aufruf erstellen
      CLEAR lt_parameter.

      l_helper->get_type_of_parameter(
        EXPORTING
          i_clsname     = l_obj-int_cls
          i_method      = CONV #( l_obj-int_methode )
          i_parameter   = CONV #( l_obj-param )
        IMPORTING
          e_type        = l_param_type
          e_description = l_param_description ).

      l_parameter-kind = cl_abap_objectdescr=>exporting.
      l_parameter-name = l_obj-param.
      CREATE DATA l_parameter-value TYPE (l_param_type).

*     Parameterwert belegen
      ASSIGN l_object_id TO <value>.

      ASSIGN l_parameter-value->* TO <param>.
      <param> = <value>.

      INSERT l_parameter INTO TABLE lt_parameter.

      IF l_obj-param_fix IS NOT INITIAL.
*       Fixer Parameter
        l_helper->get_type_of_parameter(
          EXPORTING
            i_clsname     = l_obj-int_cls
            i_method      = CONV #( l_obj-int_methode )
            i_parameter   = CONV #( l_obj-param_fix )
          IMPORTING
            e_type        = l_param_type
            e_description = l_param_description ).

        l_parameter-name = l_obj-param_fix.
        CREATE DATA l_parameter-value TYPE (l_param_type).
        ASSIGN l_parameter-value->* TO <param>.
        <param> = l_obj-param_fix_value.

        INSERT l_parameter INTO TABLE lt_parameter.

      ENDIF.
*     Sonderfall: l_object_type ist 'Object'.
      IF l_object_type = 'OBJECT'.
        l_parameter-name = 'I_OBJECT_TYPE'.
        CREATE DATA l_parameter-value TYPE /thkr/object_type.

        ASSIGN l_parameter-value->* TO <param>.
        <param> = i_object_type.

        INSERT l_parameter INTO TABLE lt_parameter.
      ENDIF.

*     Rückgabeparameter für get_dto-Aufruf erstellen
      l_helper->get_type_of_parameter(
        EXPORTING
          i_clsname     = l_obj-int_cls
          i_method      = CONV #( l_obj-int_methode )
          i_parameter   = 'E_DTO'
        IMPORTING
          e_type        = l_dto_type
          e_description = l_dto_description ).


      l_parameter-kind = cl_abap_objectdescr=>importing.
      l_parameter-name = 'E_DTO'.
      CREATE DATA l_parameter-value TYPE (l_dto_type).
      l_dto_ref = l_parameter-value.
      l_dto = l_parameter-value.

      INSERT l_parameter INTO TABLE lt_parameter.

      TRY.

          CALL METHOD l_cls_int->(l_obj-int_methode)
            PARAMETER-TABLE
            lt_parameter.

        CATCH /thkr/cx_lsa1 INTO l_oerror_zlsa.
*           Wenn es (nur) um die DTOs geht, dann kein Abbruch
          CREATE DATA l_dto TYPE bapiret2_t.
          ASSIGN l_dto->* TO <value>.
          <value> = l_oerror_zlsa->get_bapi_return_table( ).
          l_dto_line-is_error = 'X'.

        CATCH cx_root INTO l_oerror.
*           Wenn es (nur) um die DTOs geht, dann kein Abbruch

          CREATE DATA l_dto TYPE string.
          ASSIGN l_dto->* TO <value>.
          <value> = l_oerror->get_text( ).
          l_dto_line-is_error = 'X'.

      ENDTRY.

      l_dto_line-int_cls     = l_obj-int_cls.
      l_dto_line-int_methode = l_obj-int_methode.
      l_dto_line-dto_ref     = l_dto.
      l_dto_line-name        = l_dto_description.
      l_dto_line-object_type = l_object_type.
      l_dto_line-object_id   = l_object_id.
      APPEND l_dto_line TO et_dto.

      IF l_dto_line-is_error IS INITIAL.

        IF l_obj-field_parent_object IS NOT INITIAL.
          ASSIGN l_dto->(l_obj-field_parent_object) TO <field>.
          ASSERT sy-subrc = 0.
          l_parent_object_id   = <field>.
          l_parent_object_type = l_obj-type_parent_object.
        ENDIF.

      ENDIF.

      IF l_object_type = i_object_type OR l_object_type = 'OBJECT'.

        SELECT * INTO TABLE lt_methods
          FROM /thkr/c_obj_met
          WHERE object_type = l_object_type
          ORDER BY int_cls.

        LOOP AT lt_methods INTO l_method.
          CLEAR l_dto_line.

          IF l_cls_int_name <> l_method-int_cls.
*           Zugriffsreferenz auf INT-Klasse holen
            CLEAR l_cls_int.
            l_cls_int_name = l_method-int_cls.

            CLEAR lt_parameter.
            l_parameter-kind = cl_abap_objectdescr=>importing.
            l_parameter-name = 'E_INSTANCE'.
            CREATE DATA l_parameter-value TYPE REF TO (l_cls_int_name).
            INSERT l_parameter INTO TABLE lt_parameter.

            CALL METHOD (l_cls_int_name)=>get_instance
              PARAMETER-TABLE
              lt_parameter.

            ASSIGN l_parameter-value->* TO <cls_int>.
            l_cls_int ?= <cls_int>.
          ENDIF.

          l_methodname = l_method-int_methode.

          l_helper->get_type_of_parameter(
            EXPORTING
              i_clsname     = l_cls_int_name
              i_method      = CONV #( l_methodname )
              i_parameter   = 'E_DTO'
            IMPORTING
              e_type        = l_dto_type
              e_description = l_dto_description ).

*         Übergabeparameter für get_dto-Aufruf erstellen
          CLEAR lt_parameter.

          l_helper->get_type_of_parameter(
            EXPORTING
              i_clsname     = l_cls_int_name
              i_method      = CONV #( l_methodname )
              i_parameter   = CONV #( l_obj-param )
            IMPORTING
              e_type        = l_param_type
              e_description = l_param_description ).

          l_parameter-kind = cl_abap_objectdescr=>exporting.
          l_parameter-name = l_obj-param.
          CREATE DATA l_parameter-value TYPE (l_param_type).

*         Parameterwert belegen
          ASSIGN l_object_id TO <value>.

          ASSIGN l_parameter-value->* TO <param>.
          <param> = <value>.

          INSERT l_parameter INTO TABLE lt_parameter.

*         Sonderfall: l_object_type ist 'Object'.
          IF l_object_type = 'OBJECT'.
            l_parameter-name = 'I_OBJECT_TYPE'.
            CREATE DATA l_parameter-value TYPE /thkr/object_type.

            ASSIGN l_parameter-value->* TO <param>.
            <param> = i_object_type.

            INSERT l_parameter INTO TABLE lt_parameter.
          ENDIF.

*         Rückgabeparameter für get_dto-Aufruf erstellen
          l_parameter-kind = cl_abap_objectdescr=>importing.
          l_parameter-name = 'E_DTO'.
          CREATE DATA l_parameter-value TYPE (l_dto_type).
          l_dto_ref = l_parameter-value.

          INSERT l_parameter INTO TABLE lt_parameter.

          TRY.

              CALL METHOD l_cls_int->(l_methodname)
                PARAMETER-TABLE
                lt_parameter.

              l_dto1 = l_parameter-value.

            CATCH /thkr/cx_lsa1 INTO l_oerror_zlsa.
*             Da es (nur) um die DTOs geht, dann kein Abbruch
              CREATE DATA l_dto TYPE bapiret2_t.
              ASSIGN l_dto->* TO <value>.
              <value> = l_oerror_zlsa->get_bapi_return_table( ).
              l_dto_line-is_error = 'X'.
              l_dto1 = l_dto.

            CATCH cx_root INTO l_oerror.
*           Da es (nur) um die DTOs geht, dann kein Abbruch
              CREATE DATA l_dto TYPE string.
              ASSIGN l_dto->* TO <value>.
              <value> = l_oerror->get_text( ).
              l_dto_line-is_error = 'X'.
              l_dto1 = l_dto.

          ENDTRY.

          l_dto_line-int_cls     = l_cls_int_name.
          l_dto_line-int_methode = l_methodname.
          l_dto_line-dto_ref = l_dto1.
          l_dto_line-name    = l_dto_description.
          l_dto_line-object_type = l_object_type.
          l_dto_line-object_id   = l_object_id.
          APPEND l_dto_line TO et_dto.

        ENDLOOP.

      ENDIF.

      IF l_obj-field_parent_object IS NOT INITIAL.
        IF l_parent_object_id IS NOT INITIAL.
          l_object_id   = l_parent_object_id.
          l_object_type = l_parent_object_type.
          CLEAR: l_parent_object_type, l_parent_object_id.
        ELSE.
*         Die Ermittlung des Haupt-DTO's ist fehlgeschlagen
          CLEAR: l_object_id, l_object_type.
        ENDIF.
      ELSEIF l_object_type <> 'OBJECT'.
*       Wenn kein weiteres übergeordnetes Objekt, dann Daten die allgemein zu
*       Objecttype/Object-ID ermittelt werden zurückgeben
        l_object_type = 'OBJECT'.
        l_object_id   = i_object_id.
      ELSE.
        CLEAR: l_object_id, l_object_type.
      ENDIF.

    ENDWHILE.

  ENDMETHOD.
ENDCLASS.
