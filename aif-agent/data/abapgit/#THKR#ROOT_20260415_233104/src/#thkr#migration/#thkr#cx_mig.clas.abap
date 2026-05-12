class /THKR/CX_MIG definition
  public
  inheriting from /THKR/CX_LSA1
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .
  interfaces IF_T100_DYN_MSG .

  data SATZ_ID type /THKR/DE_SATZ_ID .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !BAPIRET2 type BAPIRET2 optional
      !T_BAPIRET2 type BAPIRET2_T optional
      !T_MESSAGE type /THKR/T_MESSAGE optional
      !MESS type STRING optional
      !TABLETYPE type TTYPENAME optional
      !STRUCTURE type TABNAME optional
      !FIELDNAME type FIELDNAME optional
      !FILENAME type STRING optional
      !SATZ_ID type /THKR/DE_SATZ_ID optional .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CX_MIG IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
BAPIRET2 = BAPIRET2
T_BAPIRET2 = T_BAPIRET2
T_MESSAGE = T_MESSAGE
MESS = MESS
TABLETYPE = TABLETYPE
STRUCTURE = STRUCTURE
FIELDNAME = FIELDNAME
FILENAME = FILENAME
.
me->SATZ_ID = SATZ_ID .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
