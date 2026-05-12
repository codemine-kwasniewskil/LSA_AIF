FUNCTION /thkr/bp_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_DTO_BP_CREATE) TYPE  /THKR/S_DTO_BP_CREATE
*"  EXPORTING
*"     VALUE(E_PARTNER) TYPE  BU_PARTNER
*"  TABLES
*"     RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA: messages     TYPE bapirettab.
  TRY.
      DATA(message_collector) = cf_reca_message_list=>create( ).
      /thkr/cl_bp_appl=>get_instance( )->create_partner(
        EXPORTING
          i_dto_bp_create = i_dto_bp_create
        IMPORTING
          e_partner       = e_partner ).
    CATCH /thkr/cx_bp INTO DATA(lo_exp).
      message_collector->add_from_exception( io_exception = lo_exp ).
      message_collector->get_list_as_bapiret( IMPORTING et_list = messages ).
    CATCH cx_root INTO DATA(lo_exp_root).
      message_collector->add_from_exception( io_exception = lo_exp_root ).
      message_collector->get_list_as_bapiret( IMPORTING et_list = messages ).
  ENDTRY.
  LOOP AT messages ASSIGNING FIELD-SYMBOL(<fs_message>).
    APPEND <fs_message> TO return.
  ENDLOOP.
ENDFUNCTION.
