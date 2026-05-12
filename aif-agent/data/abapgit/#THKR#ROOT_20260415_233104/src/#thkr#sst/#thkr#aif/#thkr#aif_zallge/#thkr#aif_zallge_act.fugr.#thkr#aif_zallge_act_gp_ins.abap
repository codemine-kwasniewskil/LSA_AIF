* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_gp_ins .
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
*  BREAK-POINT.


  DATA: lv_partner       TYPE bu_partner,
        ls_dto_bp_create TYPE /thkr/s_dto_bp_create.

  ASSIGN curr_line TO FIELD-SYMBOL(<ls_curr_line>).
  FIELD-SYMBOLS <lt_gp> TYPE /thkr/t_dto_bp_create.

  ASSIGN data TO FIELD-SYMBOL(<ls_data>).
*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_ZALLGE_ACT_GP_INS' ) TO return_tab.
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

* GP anlegen
      MOVE-CORRESPONDING curr_line TO ls_dto_bp_create.
      /thkr/cl_bp_appl=>get_instance( )->create_partner(
        EXPORTING
          i_dto_bp_create = ls_dto_bp_create
        IMPORTING
          e_partner       = lv_partner ).
*          <ls_curr_line>-partner = lv_partner.

      curr_line-bp_proc_status = 'S'.


      IF 0 = 1. MESSAGE s111(b0). ENDIF.
      APPEND VALUE #( id         = 'B0'
                        number     = 111
                        type       = 'S'
                        message_v1 = lv_partner  ) TO return_tab.

      "Usually AIF handle the commit work.
      "But in this case the business partner which was created successfully
      "should be commited. Otherwise a success message occurs in the monitoring
      "But a roll back happends after an error in another business partner
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true
*                 IMPORTING
*         RETURN        =
        .
      "Geschäftspartner setzen
      curr_line-partner = lv_partner.
      ASSIGN COMPONENT 'GP' OF STRUCTURE <ls_data> TO <lt_gp>.
      IF sy-subrc = 0.
        LOOP AT <lt_gp> ASSIGNING FIELD-SYMBOL(<ls_gp>) WHERE bu_bpext = curr_line-bu_bpext
                                                               AND /thkr/sst = curr_line-/thkr/sst
                                                               AND bu_type = curr_line-bu_type.
          "Bei nicht vorhanden Geschäftspartner im SAP
          "Aber gleicher Geschäftspartner mehrmals in derselben Datei
          "Geschäftspartneraktion bei allen GP in der Datei = I -> Insert, weil noch nicht vorhanden
          "GP kann aber andere IBAN haben. Gpp-Aktion muss von I auf U (update)
          "geändert werden.
          "zusätzlich muss auch die neu angelegte Partner-ID hinterlegt werden.
          <ls_gp>-bp_action = 'U'.
          <ls_gp>-partner = lv_partner.
        ENDLOOP.
      ENDIF.
*"----------------------------------------------------------------------
* Die genauen AO müssen noch identifiziert werden.
*        LOOP AT <ls_data>-ao ASSIGNING FIELD-SYMBOL(<ls_ao>) WHERE ao_bpext = <ls_curr_line>-bu_bpext.
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
