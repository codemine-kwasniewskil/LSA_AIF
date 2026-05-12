class /THKR/CX_FI_INIT definition
  public
  inheriting from /THKR/CX_ROOT
  create public .

public section.

  constants:
    begin of NO_EXCEL,
      msgid type symsgid value '/THKR/FI_INIT',
      msgno type symsgno value '000',
      attr1 type scx_attrname value 'MSGV1',
      attr2 type scx_attrname value 'MSGV2',
      attr3 type scx_attrname value 'MSGV3',
      attr4 type scx_attrname value 'MSGV4',
    end of NO_EXCEL .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CX_FI_INIT IMPLEMENTATION.
ENDCLASS.
