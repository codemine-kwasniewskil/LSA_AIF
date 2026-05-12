class /THKR/CX_PSM_TOOLS definition
  public
  inheriting from /THKR/CX_ROOT
  final
  create public .

public section.

  constants:
    begin of CVGRP_NOT_FOUND,
      msgid type symsgid value '/THKR/PSM_TOOLS',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CVGRP_NOT_FOUND .
  constants:
    begin of CVGRP_NOT_CREATED,
      msgid type symsgid value '/THKR/PSM_TOOLS',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value 'MSGV2',
      attr3 type scx_attrname value 'MSGV3',
      attr4 type scx_attrname value 'MSGV4',
    end of CVGRP_NOT_CREATED .
  constants:
    begin of CVGRP_NO_COMMIT,
      msgid type symsgid value '/THKR/PSM_TOOLS',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CVGRP_NO_COMMIT .
  constants:
    begin of BEERL_NOT_FOUND,
      msgid type symsgid value '/THKR/PSM_TOOLS',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of BEERL_NOT_FOUND .
  constants:
    begin of BEERL_NOT_CREATED,
      msgid type symsgid value '/THKR/PSM_TOOLS',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of BEERL_NOT_CREATED .
  constants:
    begin of BEERL_NO_COMMIT,
      msgid type symsgid value '/THKR/PSM_TOOLS',
      msgno type symsgno value '006',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of BEERL_NO_COMMIT .
  constants:
    begin of CVGRP_DONE,
      msgid type symsgid value '/THKR/PSM_TOOLS',
      msgno type symsgno value '008',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of CVGRP_DONE .
  constants:
    begin of BEERL_DONE,
      msgid type symsgid value '/THKR/PSM_TOOLS',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of BEERL_DONE .

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



CLASS /THKR/CX_PSM_TOOLS IMPLEMENTATION.


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
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
