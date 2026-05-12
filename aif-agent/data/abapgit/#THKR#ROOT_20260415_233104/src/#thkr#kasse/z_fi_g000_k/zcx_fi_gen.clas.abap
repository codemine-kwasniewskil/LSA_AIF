class ZCX_FI_GEN definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  constants ZCX_FI_GEN type SOTR_CONC value 'B6294529D6101ED9AEB882AD3050C5DC' ##NO_TEXT.
  constants ERR_SEND_MAIL type SOTR_CONC value 'B6294529D6101ED9AEBB0CC4FDFE05E9' ##NO_TEXT.
  constants ERR_AUTH_FILE type SOTR_CONC value 'B6294529D6101ED9AFECA16F6D5AC75D' ##NO_TEXT.
  constants ERR_WRITE_FILE type SOTR_CONC value 'B6294529D6101ED9AFECA1704B89875D' ##NO_TEXT.
  constants FILE_OPEN_ERROR type SOTR_CONC value 'B6294529D6101ED9AFECB8D0A9610756' ##NO_TEXT.
  constants ERR_FISTL type SOTR_CONC value 'B6294529D6101ED9B7F2CD58F3D04754' ##NO_TEXT.
  constants FILE_UPLOAD_ERROR type SOTR_CONC value 'B6294529D6101EDA85E906E4B13D92EC' ##NO_TEXT.
  constants INSERT_ERROR_SQL type SOTR_CONC value 'B6294529D6101EDA85E9BC50A6D812EA' ##NO_TEXT.
  constants ELKO_INTERPRET_VWZW type SOTR_CONC value 'B6294529D6101EDA8DF25D4397039753' ##NO_TEXT.
  constants ELKO_INTERPRET_IBAN type SOTR_CONC value 'B6294529D6101EDA8DF51EAE7E965753' ##NO_TEXT.
  constants ELKO_INTERPRET_SUCHM type SOTR_CONC value 'B6294529D6101EDA8DF53B4F15B2D6A8' ##NO_TEXT.
  constants ELKO_INTERPRET_MV type SOTR_CONC value 'B6294529D6101EDA8DF5DE0118F21753' ##NO_TEXT.
  constants ELKO_INTERPRET_MVM type SOTR_CONC value 'B6294529D6101EDA8DF5DE043C261753' ##NO_TEXT.
  data MESS type STRING .
  data BAPIRET2 type BAPIRET2 .
  data T_BAPIRET2 type BAPIRET2_T .
  data T_MESSAGES type ZFI_T_MESSAGES .
  data SERVER type STRING .
  data FILENAME type STRING .
  data RC type MSGV1 .
  data TABNAME type MSGV1 .
  data TXT type MSGV1 .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !MESS type STRING optional
      !BAPIRET2 type BAPIRET2 optional
      !T_BAPIRET2 type BAPIRET2_T optional
      !T_MESSAGES type ZFI_T_MESSAGES optional
      !SERVER type STRING optional
      !FILENAME type STRING optional
      !RC type MSGV1 optional
      !TABNAME type MSGV1 optional
      !TXT type MSGV1 optional .
  methods GET_BAPI_RETURN_TABLE
    returning
      value(R_BAPI_RETURN_MESSAGES) type BAPIRET2_T .
  methods GET_BAPI_RETURN_MESSAGE
    returning
      value(R_BAPI_RETURN_MESSSAGE) type BAPIRET2 .
protected section.
private section.
ENDCLASS.



CLASS ZCX_FI_GEN IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_FI_GEN .
 ENDIF.
me->MESS = MESS .
me->BAPIRET2 = BAPIRET2 .
me->T_BAPIRET2 = T_BAPIRET2 .
me->T_MESSAGES = T_MESSAGES .
me->SERVER = SERVER .
me->FILENAME = FILENAME .
me->RC = RC .
me->TABNAME = TABNAME .
me->TXT = TXT .
  endmethod.


  METHOD get_bapi_return_message.

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
    r_bapi_return_messsage = bapiret2.

  ENDMETHOD.


  METHOD get_bapi_return_table.

    DATA: l_line LIKE LINE OF t_bapiret2.
    IF t_bapiret2 IS NOT INITIAL.
      r_bapi_return_messages = t_bapiret2.
    ELSEIF bapiret2 IS NOT INITIAL.
      APPEND bapiret2 TO r_bapi_return_messages.
    ELSE.
      l_line-message = get_text( ).
      l_line-type = 'E'.
      APPEND l_line TO r_bapi_return_messages.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
