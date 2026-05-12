class /THKR/CL_MIGR_UPD_FIPOS_L2U definition
  public
  inheriting from /THKR/CL_ALV_BASE_CTR
  final
  create public .

public section.

  types:
    BEGIN OF ty_dataset,
        fikrs          TYPE fikrs,
        fipex          TYPE fm_fipex,
        gjahr          TYPE gjahr,
        new_fipex      TYPE fm_fipex,
        upd_fmci   TYPE icon_d,
        upd_fmhici TYPE icon_d,
        del_fmci   TYPE icon_d,
        del_fmhici TYPE icon_d,
      END OF ty_dataset .
  types:
    tty_dataset TYPE TABLE OF ty_dataset .

  methods CONSTRUCTOR
    importing
      !TESTMODE type XFLAG default ABAP_TRUE
      !CORRECTION type XFLAG default ABAP_TRUE .
protected section.

  constants GREEN type ICON_D value '@08@' ##NO_TEXT.
  constants YELLOW type ICON_D value '@09@' ##NO_TEXT.
  constants RED type ICON_D value '@0A@' ##NO_TEXT.
  data BLOCK_SIZE type SYTABIX value 1000 ##NO_TEXT.
  data FIPOS_DATASET type TTY_DATASET .
  data TESTMODE type XFLAG .
  data CORRECTION type XFLAG .

  methods INSERT_FMCI .
  methods INSERT_FMHICI .
  methods DELETE_FMCI .
  methods DELETE_FMHICI .
  methods PROCESS_BLOCK
    importing
      !INDEX type SYTABIX .
  methods PROCESS .

  methods GET_DATA_FROM_CUBE
    redefinition .
  methods SET_ALV_HEADER
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_MIGR_UPD_FIPOS_L2U IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->testmode = testmode.
    me->correction = correction.
  ENDMETHOD.


  METHOD delete_fmci.
    LOOP AT me->fipos_dataset INTO DATA(fipos).
      DELETE FROM fmci WHERE fikrs = fipos-fikrs
                         AND gjahr = fipos-gjahr
                         AND fipex = fipos-fipex.
      IF sy-subrc = 0.
        me->fipos_dataset[ fikrs = fipos-fikrs gjahr = fipos-gjahr fipex = fipos-fipex ]-del_fmci = me->green.
      ELSE.
        me->fipos_dataset[ fikrs = fipos-fikrs gjahr = fipos-gjahr fipex = fipos-fipex ]-del_fmci = me->red.
      ENDIF.
      me->process_block( sy-tabix ).
    ENDLOOP.
    me->process_block( me->block_size ).
  ENDMETHOD.


  METHOD delete_fmhici.

    LOOP AT me->fipos_dataset INTO DATA(fipos).
      DELETE FROM fmhici WHERE fikrs = fipos-fikrs
                         AND gjahr = fipos-gjahr
                         AND fipex = fipos-fipex.
      IF sy-subrc = 0.
        me->fipos_dataset[ fikrs = fipos-fikrs gjahr = fipos-gjahr fipex = fipos-fipex ]-del_fmhici = me->green.
      ELSE.
        me->fipos_dataset[ fikrs = fipos-fikrs gjahr = fipos-gjahr fipex = fipos-fipex ]-del_fmhici = me->red.
      ENDIF.
      me->process_block( sy-tabix ).
    ENDLOOP.
    me->process_block( me->block_size ).
  ENDMETHOD.


  METHOD get_data_from_cube.
** Select all relevant data with lower case letter and add default yellow traffic light for processing
    SELECT FROM fmci
       FIELDS fikrs,
              fipex,
              gjahr,
              CAST( 'new' AS CHAR( 24 ) ) AS newfipex,
              '@09@' AS upd_fmci,
              '@09@' AS upd_fmhici,
              '@09@' AS del_fmci,
              '@09@' AS del_fmhici
       WHERE
         like_regexpr( pcre = '[a-z]', value = fipex, case_sensitive = 'X'  ) = 1
       INTO TABLE @me->fipos_dataset.

** start process if nessessary
    IF me->fipos_dataset IS NOT INITIAL.
      me->process( ).
    ENDIF.

** Store data
    DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( p_data = me->fipos_dataset ) ).
    CREATE DATA me->datacube TYPE HANDLE table_desc.
    ASSIGN me->datacube TO FIELD-SYMBOL(<datatable>).
    <datatable>->* = me->fipos_dataset.

  ENDMETHOD.


  METHOD insert_fmci.
    "" Get actual line from db for inserting again:
    SELECT FROM fmci
       FIELDS *
       FOR ALL ENTRIES IN @me->fipos_dataset
       WHERE fikrs = @me->fipos_dataset-fikrs
         AND gjahr = @me->fipos_dataset-gjahr
         AND fipex = @me->fipos_dataset-fipex
      INTO TABLE @DATA(fiposen_complete).

    LOOP AT fiposen_complete ASSIGNING FIELD-SYMBOL(<line>).
      DATA(fipos) = <line>-fipex.
      <line>-fipex = to_upper( val = <line>-fipex ).
      INSERT fmci FROM <line>.
      IF sy-subrc = 0.
        me->fipos_dataset[ fikrs = <line>-fikrs gjahr = <line>-gjahr fipex = fipos ]-new_fipex = to_upper( val = <line>-fipex ).
        me->fipos_dataset[ fikrs = <line>-fikrs gjahr = <line>-gjahr fipex = fipos ]-upd_fmci = me->green.
      ELSE.
        me->fipos_dataset[ fikrs = <line>-fikrs gjahr = <line>-gjahr fipex = fipos ]-new_fipex = to_upper( val = <line>-fipex ).
        me->fipos_dataset[ fikrs = <line>-fikrs gjahr = <line>-gjahr fipex = fipos ]-upd_fmci = me->red.
      ENDIF.
      me->process_block( sy-tabix ).
    ENDLOOP.
    "" Final call to DB:
    me->process_block( me->block_size ).
  ENDMETHOD.


  METHOD insert_fmhici.
** Select full data to insert again with corrected data:
    SELECT FROM fmhici
       FIELDS *
       FOR ALL ENTRIES IN @me->fipos_dataset
       WHERE fikrs = @me->fipos_dataset-fikrs
         AND gjahr = @me->fipos_dataset-gjahr
         AND fipex = @me->fipos_dataset-fipex
      INTO TABLE @DATA(fiposhier_complete).

    LOOP AT fiposhier_complete ASSIGNING FIELD-SYMBOL(<line_hier>).
      DATA(fipos) = <line_hier>-fipex.
      "" Update all fipos to uppercase!
      <line_hier>-fipex       = to_upper( val = <line_hier>-fipex ).
      <line_hier>-parent_fip  = to_upper( val = <line_hier>-parent_fip ).
      <line_hier>-hiroot_fip  = to_upper( val = <line_hier>-hiroot_fip ).
      <line_hier>-next_fip    = to_upper( val = <line_hier>-next_fip ).
      <line_hier>-child_fip   = to_upper( val = <line_hier>-child_fip ).

      INSERT fmhici FROM <line_hier>.
      IF sy-subrc = 0.
        me->fipos_dataset[ fikrs = <line_hier>-fikrs gjahr = <line_hier>-gjahr fipex = fipos ]-upd_fmhici = me->green.
      ELSE.
        me->fipos_dataset[ fikrs = <line_hier>-fikrs gjahr = <line_hier>-gjahr fipex = fipos ]-upd_fmhici = me->red.
      ENDIF.
      me->process_block( sy-tabix ).
    ENDLOOP.
    "" Final call to DB:
    me->process_block( me->block_size ).
  ENDMETHOD.


  METHOD process.
    IF me->correction = abap_true.
      me->insert_fmci( ).
      me->insert_fmhici( ).
    ENDIF.
    me->delete_fmci( ).
    me->delete_fmhici( ).
  ENDMETHOD.


  METHOD process_block.
    IF index  MOD me->block_size = 0.
      IF me->testmode EQ abap_true.
        ROLLBACK WORK.
      ELSE.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_alv_header.
    DATA(testmode) = COND #( WHEN me->testmode = abap_true THEN '[Testmodus]' ).
    me->salv->get_display_settings( )->set_list_header( |Fipos Korrektur Anzahl: { lines( me->fipos_dataset ) } { testmode }| ).
  ENDMETHOD.
ENDCLASS.
