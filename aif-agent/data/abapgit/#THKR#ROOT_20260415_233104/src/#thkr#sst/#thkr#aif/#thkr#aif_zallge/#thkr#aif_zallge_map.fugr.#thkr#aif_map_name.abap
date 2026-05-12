FUNCTION /thkr/aif_map_name.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  "Feld value_in = 38_RES4
  "Feld value_in2 = 46_NAME2.
  "Feld value_in3 = BU_TYPE (nach dem Mapping)
  "Feld value_in4 = Zielfeld
  DATA: lo_name TYPE REF TO /thkr/cl_aif_fmap_name.

  CLEAR value_out.
  "Aufbau Name
  lo_name = NEW /thkr/cl_aif_fmap_name( ).

  IF value_in2 IS not INITIAL.

    DATA(lv_name2) = lo_name->set_name2( iv_46_name2 =  value_in2 ).

    DATA(lv_fullname) = lo_name->set_fullname(
                      iv_38_res = value_in
                      iv_name2  = lv_name2
                    ).
  ELSE.
    lv_fullname = lo_name->set_fullname(
                iv_38_res = value_in
              ).
  ENDIF.
  "Mapping Name
  value_out = lo_name->map_name(
                iv_bu_type      =  conv bu_type( value_in3 )               " Geschäftspartnertyp
                iv_fullname     = lv_fullname
                iv_target_field = value_in4
              ).
ENDFUNCTION.
