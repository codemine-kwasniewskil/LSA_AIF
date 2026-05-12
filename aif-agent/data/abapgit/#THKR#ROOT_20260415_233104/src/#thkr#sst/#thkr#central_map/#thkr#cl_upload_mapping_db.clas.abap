class /THKR/CL_UPLOAD_MAPPING_DB definition
  public
  final
  create public .

public section.

  methods SAVE_TO_DB
    importing
      !MAPPED_DATA type /THKR/T_CENTRMAPPING
      !TESTMODE type BOOLEAN default ABAP_TRUE
    raising
      /THKR/CX_FI_INIT .
  methods FLUSH_DB
    importing
      !TESTMODE type BOOLEAN default ABAP_TRUE .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_UPLOAD_MAPPING_DB IMPLEMENTATION.


  METHOD flush_db.
    DELETE FROM /thkr/centralmap.

    IF testmode = abap_true.
      ROLLBACK WORK.
    ENDIF.
  ENDMETHOD.


  METHOD save_to_db.

** Insert single line to find out which datasets are not allowed:
    DATA(err) = NEW /thkr/cx_fi_init( textid = /thkr/cx_fi_init=>no_excel ).
    LOOP AT mapped_data INTO DATA(line).
      INSERT /thkr/centralmap FROM line.
      IF sy-subrc <> 0.
        err->bapiret2_tab = VALUE #( BASE err->bapiret2_tab
                                     ( id         = '/THKR/FI_INIT'
                                       number     = 000
                                       type       = 'E'
                                       message_v1 = 'Fehler mit Datensatz: - '
                                       message_v2 = |{ line-ep } { line-dst_old } { line-oeh_old }|
                                       message_v3 = |- DB subrc: { sy-subrc }|
                                       message_v4 = |- Korrektur: Löschen oder lfnNr. nutzen| ) ).
      ENDIF.
    ENDLOOP.
    IF testmode = abap_true.
      ROLLBACK WORK.
    ENDIF.
    IF err->bapiret2_tab IS NOT INITIAL.
      RAISE EXCEPTION err.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
