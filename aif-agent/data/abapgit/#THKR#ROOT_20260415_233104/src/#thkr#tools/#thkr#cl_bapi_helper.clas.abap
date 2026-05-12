class /THKR/CL_BAPI_HELPER definition
  public
  final
  create public .

public section.

  class-methods CONTAINS_ERROR
    importing
      !BAPIRET2_T type BAPIRET2_T
    returning
      value(VALUE) type STRING .
  class-methods IS_ERROR
    importing
      !BAPIRET2 type BAPIRET2
    returning
      value(VALUE) type STRING .
  class-methods ADD_MESSAGE
    importing
      !BAPIRET2 type ref to BAPIRET2_T
      !MSG_TYPE type CLIKE
      !MSG_ID type CLIKE
      !MSG_NUMBER type CLIKE
      !MSG_PAR1 type CLIKE optional
      !MSG_PAR2 type CLIKE optional
      !MSG_PAR3 type CLIKE optional
      !MSG_PAR4 type CLIKE optional .
  class-methods FILL_MESSAGE
    importing
      !BAPIRET2_T type ref to BAPIRET2_T .
  class-methods FILL_MESSAGE_STRUC
    importing
      !BAPIRET2 type ref to BAPIRET2 .
  class-methods GET_MESSAGE_TEXT
    importing
      !BAPIRET2 type BAPIRET2
    returning
      value(VALUE) type STRING .
  class-methods CONVERT_ERRORS_TO_WARNINGS
    importing
      !BAPIRET2 type BAPIRET2_T
    returning
      value(VALUE) type BAPIRET2_T .
  class-methods RAISE_IF_HAS_ERROR
    importing
      !BAPIRET2 type BAPIRET2_T .
  class-methods RAISE_IF_HAS_ERROR2
    importing
      !BAPIRET2 type BAPIRET2 .
  class-methods SIMPLIFY_TYPE
    importing
      !TYPE type CLIKE
    returning
      value(VALUE) type STRING .
  class-methods COLLECT_MESSAGE_FROM_SYST
    changing
      !MESSAGES type BAPIRET2_T .
  class-methods COLLECT_MESSAGE_FROM_EX
    importing
      !EXCEPTION type ref to CX_ROOT
    changing
      !MESSAGES type BAPIRET2_T .
  class-methods COLLECT_MESSAGE_FROM_SYST_99
    changing
      !MESSAGES type BAPIRET2_T .
  class-methods COLLECT_MESSAGE_FROM_SYST2_99
    importing
      !MESSAGES type ref to BAPIRET2_T .
  class-methods CONVERT_OLD_RETURN_TO_NEW
    importing
      !INPUT type BAPIRETURN
    returning
      value(VALUE) type BAPIRET2 .
  class-methods CREATE
    importing
      !TEXT type CLIKE
      !TYPE type CLIKE
      !P1 type CLIKE optional
      !P2 type CLIKE optional
      !P3 type CLIKE optional
      !P4 type CLIKE optional
    returning
      value(VALUE) type BAPIRET2 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_BAPI_HELPER IMPLEMENTATION.


  METHOD add_message.
    DATA:
      lr_bapiret2 TYPE REF TO bapiret2.

    CREATE DATA lr_bapiret2.
    lr_bapiret2->type = msg_type.
    lr_bapiret2->id = msg_id.
    lr_bapiret2->number = msg_number.
    lr_bapiret2->message_v1 = msg_par1.
    lr_bapiret2->message_v2 = msg_par2.
    lr_bapiret2->message_v3 = msg_par3.
    lr_bapiret2->message_v4 = msg_par4.
    fill_message_struc( lr_bapiret2 ).
    APPEND lr_bapiret2->* TO bapiret2->*.
  ENDMETHOD.


  METHOD collect_message_from_ex.
    DATA:  ltr_message TYPE REF TO bapiret2_t.
    DATA:
      ls_bapi     TYPE bapiret2,
      lv_message  TYPE string,
      lv_message1 TYPE string,
      lv_message2 TYPE string,
      lv_message3 TYPE string,
      lv_message4 TYPE string.

    lv_message = exception->get_text( ).

    lv_message1 = lv_message.
    SHIFT lv_message LEFT BY 50 PLACES.
    lv_message2 = lv_message.
    SHIFT lv_message LEFT BY 50 PLACES.
    lv_message3 = lv_message.
    SHIFT lv_message LEFT BY 50 PLACES.
    lv_message4 = lv_message.

    GET REFERENCE OF messages INTO ltr_message.
    DATA(msg) = cl_message_helper=>get_t100_for_object( cl_message_helper=>get_latest_t100_exception( exception ) ).
    add_message(
        bapiret2 = ltr_message
        msg_type = msg-msgty
        msg_id = msg-msgid
        msg_number = msg-msgno
        msg_par1 = msg-msgv1
        msg_par2 = msg-msgv2
        msg_par3 = msg-msgv3
        msg_par4 = msg-msgv4 ).
  ENDMETHOD.


  METHOD collect_message_from_syst.
    DATA:
      ltr_message TYPE REF TO bapiret2_t.

    IF sy-msgid IS INITIAL.
      RETURN.
    ENDIF.

    GET REFERENCE OF messages INTO ltr_message.
    add_message(
      bapiret2 = ltr_message
      msg_type = sy-msgty
      msg_id = sy-msgid
      msg_number = sy-msgno
      msg_par1 = sy-msgv1
      msg_par2 = sy-msgv2
      msg_par3 = sy-msgv3
      msg_par4 = sy-msgv4 ).

  ENDMETHOD.


  METHOD collect_message_from_syst2_99.
    collect_message_from_syst_99( CHANGING messages = messages->* ).
  ENDMETHOD.


  METHOD collect_message_from_syst_99.
    IF sy-subrc <> 99.
      RETURN.
    ENDIF.
    collect_message_from_syst( CHANGING messages = messages ).
  ENDMETHOD.


  METHOD contains_error.
    FIELD-SYMBOLS:
      <bapiret2> TYPE bapiret2.

    LOOP AT bapiret2_t ASSIGNING <bapiret2>.
      IF NOT is_error( bapiret2 = <bapiret2> ) IS INITIAL.
        value = 'X'.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD convert_errors_to_warnings.
    DATA:
      ls_bapiret2 TYPE bapiret2.

    LOOP AT bapiret2 INTO ls_bapiret2.
      IF NOT is_error( ls_bapiret2 ) IS INITIAL.
        ls_bapiret2-type = 'W'.
      ENDIF.
      APPEND ls_bapiret2 TO value.
    ENDLOOP.
  ENDMETHOD.


  METHOD convert_old_return_to_new.
    value-log_msg_no = input-log_msg_no.
    value-log_no = input-log_no.
    value-message = input-message.
    value-message_v1 = input-message_v1.
    value-message_v2 = input-message_v2.
    value-message_v3 = input-message_v3.
    value-message_v4 = input-message_v4.
    value-type = input-type.
  ENDMETHOD.


  METHOD create.
    DATA:
      lv_text TYPE string,
      lv_temp TYPE string.

    lv_text = text.

    IF p1 IS SUPPLIED.
      lv_temp = p1.
      REPLACE ALL OCCURRENCES OF '&1' IN lv_text WITH lv_temp.
    ENDIF.

    IF p2 IS SUPPLIED.
      lv_temp = p2.
      REPLACE ALL OCCURRENCES OF '&2' IN lv_text WITH lv_temp.
    ENDIF.

    IF p3 IS SUPPLIED.
      lv_temp = p3.
      REPLACE ALL OCCURRENCES OF '&3' IN lv_text WITH lv_temp.
    ENDIF.

    IF p4 IS SUPPLIED.
      lv_temp = p4.
      REPLACE ALL OCCURRENCES OF '&3' IN lv_text WITH lv_temp.
    ENDIF.

    value-id = 'ZIP_GENERIC'.
    value-type = type.
    value-number = '000'.
    value-message_v1 = lv_text.
    "A trick to keep space if it is 50th character.
    DATA(lv_last_char) = /thkr/cl_string_helper=>substring( s = lv_text skip = 49 take = 1 ).
    CONDENSE lv_last_char.
    IF lv_last_char IS INITIAL.
      SHIFT lv_text LEFT BY 49 PLACES.
    ELSE.
      SHIFT lv_text LEFT BY 50 PLACES.
    ENDIF.
    value-message_v2 = lv_text.
    lv_last_char = /thkr/cl_string_helper=>substring( s = lv_text skip = 49 take = 1 ).
    CONDENSE lv_last_char.
    IF lv_last_char IS INITIAL.
      SHIFT lv_text LEFT BY 49 PLACES.
    ELSE.
      SHIFT lv_text LEFT BY 50 PLACES.
    ENDIF.
    value-message_v3 = lv_text.
    lv_last_char = /thkr/cl_string_helper=>substring( s = lv_text skip = 49 take = 1 ).
    CONDENSE lv_last_char.
    IF lv_last_char IS INITIAL.
      SHIFT lv_text LEFT BY 49 PLACES.
    ELSE.
      SHIFT lv_text LEFT BY 50 PLACES.
    ENDIF.
    value-message_v4 = lv_text.
    lv_last_char = /thkr/cl_string_helper=>substring( s = lv_text skip = 49 take = 1 ).
    CONDENSE lv_last_char.
    IF lv_last_char  IS INITIAL.
      SHIFT lv_text LEFT BY 49 PLACES.
    ELSE.
      SHIFT lv_text LEFT BY 50 PLACES.
    ENDIF.
    value-message = get_message_text( value ).
  ENDMETHOD.


  METHOD fill_message.
    DATA:
      lr_bapiret2 TYPE REF TO bapiret2.

    LOOP AT bapiret2_t->* REFERENCE INTO lr_bapiret2.
      fill_message_struc( lr_bapiret2 ).
    ENDLOOP.
  ENDMETHOD.


  METHOD fill_message_struc.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type       = bapiret2->type
        cl         = bapiret2->id
        number     = bapiret2->number
        par1       = bapiret2->message_v1
        par2       = bapiret2->message_v2
        par3       = bapiret2->message_v3
        par4       = bapiret2->message_v4
        log_no     = bapiret2->log_no
        log_msg_no = bapiret2->log_msg_no
        row        = bapiret2->row
        field      = bapiret2->field
      IMPORTING
        return     = bapiret2->*.
  ENDMETHOD.


  METHOD get_message_text.
    DATA:
      lr_temp TYPE REF TO bapiret2.

    CREATE DATA lr_temp.
    lr_temp->* = bapiret2.
    fill_message_struc( lr_temp ).
    value = lr_temp->message.
  ENDMETHOD.


  METHOD is_error.
    IF bapiret2-type CA 'AEH'.
      value = 'X'.
    ENDIF.
  ENDMETHOD.


  METHOD raise_if_has_error.
    FIELD-SYMBOLS:
      <bapiret2> TYPE bapiret2.

    LOOP AT bapiret2 ASSIGNING <bapiret2>.
      IF is_error( <bapiret2> ).
        DATA(lv_message) = get_message_text( <bapiret2> ) .
        "RAISE EXCEPTION TYPE /thkr/cx_root." MESSAGE lv_message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD raise_if_has_error2.
    DATA:
      lt_bapi TYPE bapiret2_t.

    APPEND bapiret2 TO lt_bapi.
    raise_if_has_error( lt_bapi ).
  ENDMETHOD.


  METHOD simplify_type.
    IF type CA 'AEX'.
      value = 'E'.
    ELSEIF type = 'W'.
      value = 'W'.
    ELSEIF type CA 'IS'.
      value = 'I'.
    ELSE.
      value = 'E'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
