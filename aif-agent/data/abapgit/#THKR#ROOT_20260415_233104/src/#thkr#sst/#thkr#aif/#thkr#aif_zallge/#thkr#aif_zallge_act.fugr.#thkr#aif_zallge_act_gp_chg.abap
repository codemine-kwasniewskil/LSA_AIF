* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_gp_chg .
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
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_GP
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.


  DATA: lv_partner       TYPE bu_partner,
        ls_dto_bp_modify TYPE /thkr/s_dto_bp_modify.

  ASSIGN curr_line TO FIELD-SYMBOL(<ls_curr_line>).
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).
*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_ZALLGE_ACT_GP_CHG' ) TO return_tab.
*"----------------------------------------------------------------------
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
  TRY.
      success = 'Y'.

*"----------------------------------------------------------------------
* GP ändern

        MOVE-CORRESPONDING <ls_curr_line> TO ls_dto_bp_modify EXPANDING NESTED TABLES.
        /thkr/cl_bp_appl=>get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify ).

        curr_line-bp_proc_status = 'S'.

        IF 0 = 1. MESSAGE s112(b0). ENDIF.
        APPEND VALUE #( id         = 'B0'
                          number     = 112
                          type       = 'S'
                          message_v1 = <ls_curr_line>-partner  ) TO return_tab.
        "Usually AIF handle the commit work.
        "But in this case the business partner which was created successfully
        "should be commited. Otherwise a success message occurs in the monitoring
        "But a roll back happends after an error in another business partner
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true
*                 IMPORTING
*           RETURN        =
          .
*"----------------------------------------------------------------------
* Die genauen AO müssen noch identifiziert werden.
*        LOOP AT <ls_data>-ao ASSIGNING FIELD-SYMBOL(<ls_ao>) WHERE partner = <ls_curr_line>-bu_bpext.
*          <ls_ao>-partner = lv_partner.
*        ENDLOOP.
*"----------------------------------------------------------------------
    CATCH /thkr/cx_bp INTO DATA(lxc_bp).
      IF lxc_bp->bapiret2_tab IS NOT INITIAL.
        APPEND LINES OF lxc_bp->bapiret2_tab TO return_tab.
      ELSE.
        APPEND VALUE #( id         = lxc_bp->if_t100_message~t100key-msgid
                        number     = lxc_bp->if_t100_message~t100key-msgno
                        type       = lxc_bp->if_t100_dyn_msg~msgty
                        message_v1 = lxc_bp->if_t100_dyn_msg~msgv1
                        message_v2 = lxc_bp->if_t100_dyn_msg~msgv2
                        message_v3 = lxc_bp->if_t100_dyn_msg~msgv3
                        message_v4 = lxc_bp->if_t100_dyn_msg~msgv4 ) TO return_tab.
      ENDIF.
      curr_line-bp_proc_status = 'E'.
      success = 'N'.
*"----------------------------------------------------------------------
  ENDTRY.
   curr_line-msg = return_tab[].
ENDFUNCTION.
*"----------------------------------------------------------------------
