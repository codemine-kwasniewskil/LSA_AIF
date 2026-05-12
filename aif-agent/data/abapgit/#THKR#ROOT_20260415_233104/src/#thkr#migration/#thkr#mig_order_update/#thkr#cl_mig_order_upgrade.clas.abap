class /THKR/CL_MIG_ORDER_UPGRADE definition
  public
  final
  create public .

public section.

  types:
    TY_MBS_RANGE type TABLE of FPCR_S_RANGE_KBLNR .

  methods CONSTRUCTOR
    importing
      !TESTMODE type XFLAG default ABAP_TRUE .
  methods PROCESS_MB
    importing
      !MBS type TY_MBS_RANGE .
protected section.

  data TESTMODE type XFLAG .
private section.
ENDCLASS.



CLASS /THKR/CL_MIG_ORDER_UPGRADE IMPLEMENTATION.


  METHOD constructor.

    me->testmode = testmode.

  ENDMETHOD.


  METHOD process_mb.

    SELECT FROM kblp
      FIELDS fipos
            ,aufnr
            ,kostl
            ,fistl
            ,geber
            ,fkber
            ,measure
      WHERE belnr IN @mbs
      INTO TABLE @DATA(kbpl_entry).

*    LOOP AT mbs INTO DATA(mb).
*
*
*    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
