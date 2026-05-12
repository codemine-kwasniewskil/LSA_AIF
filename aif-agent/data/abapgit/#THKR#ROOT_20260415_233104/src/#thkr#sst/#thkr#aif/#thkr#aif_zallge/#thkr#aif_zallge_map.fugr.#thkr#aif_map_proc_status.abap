FUNCTION /thkr/aif_map_proc_status .
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

  DATA: lv_ifversion TYPE /aif/ifversion,
        lv_ns        TYPE /aif/ns,
        lv_ifname    TYPE /aif/ifname,
        lv_msg_id    TYPE /aif/sxmssmguid,
        lo_reproc    TYPE REF TO /thkr/cl_aif_reproc.

  lo_reproc = NEW /thkr/cl_aif_reproc( ).

  value_out = lo_reproc->map_proc_stat(
                iv_objtyp = CONV /thkr/aif_objtyp( value_in )                " Objekttyp
                iv_objid  = CONV char26( value_in2 )                " Char-feld der Laenge 26
              ).
ENDFUNCTION.
