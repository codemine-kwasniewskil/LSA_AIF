*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_proc_stat .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.                                             "#EC NOBREAK
*"----------------------------------------------------------------------
  DATA: lo_struc     TYPE REF TO cl_abap_structdescr.
  DATA: lo_reproc    TYPE REF TO /thkr/cl_aif_reproc.

  ASSIGN curr_line  TO FIELD-SYMBOL(<ls_curr_line>).

  success = 'Y'.

  lo_reproc = NEW /thkr/cl_aif_reproc( ).
  lo_struc ?= cl_abap_structdescr=>describe_by_data( <ls_curr_line> ).

  DATA(lv_offset) = strlen( lo_struc->absolute_name ) - 6.

  TRY.
      CASE lo_reproc->get_type_of_processing( iv_absolute_name = CONV string( lo_struc->absolute_name+6(lv_offset) ) ).
        WHEN: 'M'.
          "Mehrsatzverarbeitung (Schleifen lauf in der Aktion)
          success = lo_reproc->update_proc_stat_multi(
                      CHANGING
                        cs_curr_line = <ls_curr_line>
                    ).
        WHEN: 'S'.
          "Einzelsatzverarbeitung (Schleifenlauf durch AIF)
          "Setzen des Fehlerstatus auf E, wenn leer.
         lo_reproc->set_status_e_for_blank(
           EXPORTING
             iv_absolute_name = CONV string( lo_struc->absolute_name+6(lv_offset) )
           CHANGING
             cs_curr_line     = <ls_curr_line>
         ).

          success = lo_reproc->update_proc_stat_single(
                      is_curr_line     = <ls_curr_line>
                      iv_absolute_name = CONV string( lo_struc->absolute_name+6(lv_offset) )
                    ).
      ENDCASE.
    CATCH /thkr/cx_aif INTO DATA(lx_exc).
      Success = 'N'.
      APPEND VALUE #( id = lx_exc->if_t100_message~t100key-msgid
                    number = lx_exc->if_t100_message~t100key-msgno
                    type = lx_exc->if_t100_dyn_msg~msgty
                    message_v1 = lx_exc->if_t100_dyn_msg~msgv1
                    message_v2 = lx_exc->if_t100_dyn_msg~msgv2
                    message_v3 = lx_exc->if_t100_dyn_msg~msgv3
                    message_v4 = lx_exc->if_t100_dyn_msg~msgv4 ) TO return_tab.
  ENDTRY.
*"----------------------------------------------------------------------
ENDFUNCTION.
