FUNCTION /thkr/aif_fremdv_act_fwd_rk_po .
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

  DATA: lv_msgid TYPE /aif/sxmssmguid.
* Check if Actions are allowed.
  CALL FUNCTION '/THKR/AIF_ZALLGE_ACT_OFF'
    TABLES
      return_tab = return_tab
    EXCEPTIONS
      off        = 1
      OTHERS     = 2.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
*"----------------------------------------------------------------------
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).
  ASSIGN COMPONENT 'BIC_STRUC' OF STRUCTURE <ls_data> TO FIELD-SYMBOL(<ls_rko_polizei>).
  IF sy-subrc = 0.
    APPEND VALUE #( id         = 'KM'
                number     = 418
                type       = 'I'
                message_v1 = '/THKR/AIF_FREMDV_ACT_FWD_RK_PO' ) TO return_tab.

    TRY.
        /aif/cl_enabler_xml=>transfer_to_aif( EXPORTING is_any_structure = <ls_rko_polizei>
                                                        iv_use_buffer = abap_true
                                              IMPORTING
                                                ev_msgguid = lv_msgid ).

        Success = 'Y'.
        APPEND VALUE #( id         = '/BSNAGT/MESSAGE'
                         number     = 153
                         type       = 'I'
                         message_v1 = lv_msgid ) TO return_tab.
      CATCH /aif/cx_inf_det_base.
        " Generic Exception for AIF Enabler
      CATCH /aif/cx_enabler_base.
        " Generic Exception for AIF Enabler
      CATCH /aif/cx_aif_engine_not_found.
        " General exception class for AIF engines
      CATCH /aif/cx_error_handling_general.
        " AIF Error Handling Exception Class
      CATCH /aif/cx_aif_engine_base.
        " Base Exception Class for AIF Engines
    ENDTRY.
  ENDIF.
ENDFUNCTION.
