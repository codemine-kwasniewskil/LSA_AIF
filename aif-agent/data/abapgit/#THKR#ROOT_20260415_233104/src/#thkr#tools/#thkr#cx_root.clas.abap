class /THKR/CX_ROOT definition
  public
  inheriting from CX_STATIC_CHECK
  abstract
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  data BAPIRET2 type BAPIRET2 .
  data BAPIRET2_TAB type BAPIRET2_T .
  data MSGV1 type SYMSGV .
  data MSGV2 type SYMSGV .
  data MSGV3 type SYMSGV .
  data MSGV4 type SYMSGV .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !BAPIRET2 type BAPIRET2 optional
      !BAPIRET2_TAB type BAPIRET2_T optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional .
  methods GET_BAPIRET_TABLE
    returning
      value(BAIPRET2_TAB) type BAPIRET2_TAB .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CX_ROOT IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->BAPIRET2 = BAPIRET2 .
me->BAPIRET2_TAB = BAPIRET2_TAB .
me->MSGV1 = MSGV1 .
me->MSGV2 = MSGV2 .
me->MSGV3 = MSGV3 .
me->MSGV4 = MSGV4 .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD get_bapiret_table.
    bapiret2_tab = me->bapiret2_tab.
  ENDMETHOD.
ENDCLASS.
