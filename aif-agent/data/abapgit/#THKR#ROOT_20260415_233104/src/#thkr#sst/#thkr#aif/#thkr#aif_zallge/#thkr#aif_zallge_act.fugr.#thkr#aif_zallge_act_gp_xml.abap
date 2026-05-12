*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_gp_xml .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_XML_SAP
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_XML_BELEG
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.                                             "#EC NOBREAK
*"----------------------------------------------------------------------
  DATA: lv_partner       TYPE bu_partner,
        ls_dto_bp_modify TYPE /thkr/s_dto_bp_modify,
        lv_idx_table     TYPE string,
        ls_dto_gp        TYPE /THKR/S_DTO_BP_CREATE.

  ASSIGN curr_line  TO FIELD-SYMBOL(<ls_curr_line>).
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).
*"----------------------------------------------------------------------
  IF <ls_curr_line> IS ASSIGNED AND <ls_curr_line> IS NOT INITIAL.
    LOOP AT <ls_curr_line>-gp ASSIGNING FIELD-SYMBOL(<ls_gp>).
      TRY.
          IF  ( <ls_gp>-bp_proc_status IS INITIAL OR <ls_gp>-bp_proc_status = 'E' OR <ls_gp>-bp_proc_status = 'A' ).
            IF <ls_gp>-partner IS INITIAL.
              "Create BP
              MOVE-CORRESPONDING <ls_gp> TO ls_dto_gp.
              /thkr/cl_bp_appl=>get_instance( )->create_partner(
                EXPORTING
                  i_dto_bp_create = ls_dto_gp
                IMPORTING
                  e_partner       =  lv_partner ).
            ELSE.
              "Change BP
              MOVE-CORRESPONDING <ls_gp> TO ls_dto_bp_modify EXPANDING NESTED TABLES.
              /thkr/cl_bp_appl=>get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify ).
            ENDIF.
            <ls_gp>-bp_proc_status = 'S'.
            "Usually AIF handle the commit work.
            "But in this case the business partner which was created successfully
            "should be commited. Otherwise a success message occurs in the monitoring
            "But a roll back happends after an error in another business partner
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true
*                 IMPORTING
*               RETURN        =
              .
            <ls_gp>-partner = lv_partner.
          ENDIF.

          IF 0 = 1. MESSAGE s111(b0). ENDIF.
          APPEND VALUE #( id = 'B0'
                          number = 111
                          type = 'S'
                          message_v1 = lv_partner  ) TO return_tab.

        CATCH /thkr/cx_bp INTO DATA(lxc_bp).
          IF lxc_bp->bapiret2_tab IS NOT INITIAL.
            APPEND LINES OF lxc_bp->bapiret2_tab TO return_tab.
          ELSE.
            APPEND VALUE #( id = lxc_bp->if_t100_message~t100key-msgid
                            number = lxc_bp->if_t100_message~t100key-msgno
                            type = lxc_bp->if_t100_dyn_msg~msgty
                            message_v1 = lxc_bp->if_t100_dyn_msg~msgv1
                            message_v2 = lxc_bp->if_t100_dyn_msg~msgv2
                            message_v3 = lxc_bp->if_t100_dyn_msg~msgv3
                            message_v4 = lxc_bp->if_t100_dyn_msg~msgv4 ) TO return_tab.
          ENDIF.
          "Processing not successful
          "Set AIF sucess to no
          success = 'N'.
          <ls_gp>-bp_proc_status = 'E'.
          "Start with next business partner
          CONTINUE.
      ENDTRY.

    ENDLOOP.
    IF success <> 'N'.
      "During the loop errors could occur by creating business partners.
      "However the loop shall be finished
      "No Error during BP creation and modification.
      "Set AIF Success to yes
      success = 'Y'.
    ENDIF.

  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
