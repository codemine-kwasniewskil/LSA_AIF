class /THKR/CX_REPORT_FILE_HELPER definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  constants DIALOG_ERROR type SOTR_CONC value 'DFD50B6E8D321FE086D2439D914C8FC5' ##NO_TEXT.
  constants FILE_ERROR type SOTR_CONC value 'DFD50B6E8D321FE086D29E900D2D91B9' ##NO_TEXT.
  data V1 type SYMSGV .
  data V2 type SYMSGV .
  data V3 type SYMSGV .
  data V4 type SYMSGV .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !V1 type SYMSGV optional
      !V2 type SYMSGV optional
      !V3 type SYMSGV optional
      !V4 type SYMSGV optional .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CX_REPORT_FILE_HELPER IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
me->V1 = V1 .
me->V2 = V2 .
me->V3 = V3 .
me->V4 = V4 .
  endmethod.
ENDCLASS.
