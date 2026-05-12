class /THKR/CX_LSA1 definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  constants /THKR/CX_LSA1 type SOTR_CONC value '0800272AC84F1EDEB2CE9F30D55B8525' ##NO_TEXT.
  constants TABLETYPE_NOT_FOUND type SOTR_CONC value '00155DD78F031EEAA2C24DFBDA58F221' ##NO_TEXT.
  constants STRUCTURE_FIELD_NOT_FOUND type SOTR_CONC value '00155DD78F031EEAA2C257803EDAD23B' ##NO_TEXT.
  constants FEATURE_NOT_YET_IMPLEMENTED type SOTR_CONC value '00155DB7142F1EDB9DC2668A4E3EF58B' ##NO_TEXT.
  constants ERROR_CREATE_FILE type SOTR_CONC value '00155DB7142F1EDBA0867E6B0EE7758B' ##NO_TEXT.
  constants ERROR_CREATE_FILE_MESS type SOTR_CONC value '00155DB7142F1EDBA086AD10FE86958B' ##NO_TEXT.
  constants ERROR_CONV_CSTRING_XSTRING type SOTR_CONC value '00155DB714981EDCAADBDE5739B5F5AD' ##NO_TEXT.
  data BAPIRET2 type BAPIRET2 .
  data T_BAPIRET2 type BAPIRET2_T .
  data T_MESSAGE type /THKR/T_MESSAGE .
  data MESS type STRING .
  data TABLETYPE type TTYPENAME .
  data STRUCTURE type TABNAME .
  data FIELDNAME type FIELDNAME .
  data FILENAME type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !BAPIRET2 type BAPIRET2 optional
      !T_BAPIRET2 type BAPIRET2_T optional
      !T_MESSAGE type /THKR/T_MESSAGE optional
      !MESS type STRING optional
      !TABLETYPE type TTYPENAME optional
      !STRUCTURE type TABNAME optional
      !FIELDNAME type FIELDNAME optional
      !FILENAME type STRING optional .
  methods GET_BAPI_RETURN_TABLE
    returning
      value(RT_BAPI_RETURN_TABLE) type BAPIRET2_T .
  methods GET_BAPI_RETURN_MESSAGE
    returning
      value(R_BAPI_RETURN_MESSAGE) type BAPIRET2 .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CX_LSA1 IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = /THKR/CX_LSA1 .
 ENDIF.
me->BAPIRET2 = BAPIRET2 .
me->T_BAPIRET2 = T_BAPIRET2 .
me->T_MESSAGE = T_MESSAGE .
me->MESS = MESS .
me->TABLETYPE = TABLETYPE .
me->STRUCTURE = STRUCTURE .
me->FIELDNAME = FIELDNAME .
me->FILENAME = FILENAME .
  endmethod.


  METHOD GET_BAPI_RETURN_MESSAGE.

    IF bapiret2 IS INITIAL.
      READ TABLE t_bapiret2 WITH KEY type = 'E' INTO bapiret2.

      IF sy-subrc <> 0.
        READ TABLE t_bapiret2 INDEX 1 INTO bapiret2.
        IF sy-subrc <> 0.
          bapiret2-type    = 'E'.
          bapiret2-message = get_text( ).
        ENDIF.
      ENDIF.

      READ TABLE t_bapiret2 WITH KEY type = 'A' INTO bapiret2.

      IF sy-subrc <> 0.
        READ TABLE t_bapiret2 INDEX 1 INTO bapiret2.
        IF sy-subrc <> 0.
          bapiret2-type    = 'A'.
          bapiret2-message = get_text( ).
        ENDIF.
      ENDIF.

    ENDIF.

    r_bapi_return_message = bapiret2.

  ENDMETHOD.


  METHOD GET_BAPI_RETURN_TABLE.

    DATA: l_line      LIKE LINE OF t_bapiret2,
          l_oerror    TYPE REF TO cx_root,
          l_lsa_error TYPE REF TO /thkr/cx_lsa1.

    l_oerror    = me.
    l_lsa_error = me.

    DO.

      IF l_lsa_error IS NOT INITIAL.
        "/THKR/CX_LSA-Fehler
        IF l_lsa_error->t_bapiret2 IS NOT INITIAL.
          rt_bapi_return_table = l_lsa_error->t_bapiret2.
        ELSEIF l_lsa_error->bapiret2 IS NOT INITIAL.
          APPEND l_lsa_error->bapiret2 TO rt_bapi_return_table.
        ELSE.
          l_line-message = l_lsa_error->get_text( ).
          l_line-type = 'E'.
          APPEND l_line TO rt_bapi_return_table.
        ENDIF.

      ELSE.

        l_line-message = l_oerror->get_text( ).
        l_line-type = 'E'.
        APPEND l_line TO rt_bapi_return_table.

      ENDIF.

      IF l_oerror->previous IS INITIAL.
        EXIT.
      ENDIF.

      l_oerror = l_oerror->previous.

      TRY.
          l_lsa_error ?= l_oerror.
        CATCH cx_sy_move_cast_error.
          CLEAR l_lsa_error.
      ENDTRY.

    ENDDO.

  ENDMETHOD.
ENDCLASS.
