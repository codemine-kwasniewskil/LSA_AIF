class /THKR/CX_FMBB_PDF_CREATOR definition
  public
  inheriting from /THKR/CX_ROOT
  final
  create public .

public section.

  constants:
    begin of /THKR/CX_FMBB_PDF_CREATOR,
      msgid type symsgid value '/THKR/PSM_BU',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value 'MSGV2',
      attr3 type scx_attrname value 'MSGV3',
      attr4 type scx_attrname value '',
    end of /THKR/CX_FMBB_PDF_CREATOR .
  constants:
    begin of FP_ERROR,
      msgid type symsgid value '/THKR/PSM_BU',
      msgno type symsgno value '010',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FP_ERROR .

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
protected section.
private section.
ENDCLASS.



CLASS /THKR/CX_FMBB_PDF_CREATOR IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
BAPIRET2 = BAPIRET2
BAPIRET2_TAB = BAPIRET2_TAB
MSGV1 = MSGV1
MSGV2 = MSGV2
MSGV3 = MSGV3
MSGV4 = MSGV4
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = /THKR/CX_FMBB_PDF_CREATOR .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
