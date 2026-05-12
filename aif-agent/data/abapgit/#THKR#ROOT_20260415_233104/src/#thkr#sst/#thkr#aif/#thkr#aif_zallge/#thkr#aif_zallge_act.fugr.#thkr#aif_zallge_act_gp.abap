* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_gp .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.


  DATA: lv_partner       TYPE bu_partner,
        lv_ns            TYPE /aif/ns,
        lv_ifname        TYPE /aif/ifname,
        lv_ifversion     TYPE /aif/ifversion,
        lv_msg_id        TYPE /aif/sxmssmguid,
        ls_aif_obj       TYPE /thkr/t_aif_obj,
        ls_dto_bp_modify TYPE /thkr/s_dto_bp_modify,
        ls_dto_psm_gp    TYPE /THKR/S_DTO_BP_CREATE.

  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ximsgguid = lv_msg_id
      ns        = lv_ns
      ifname    = lv_ifname
      ifversion = lv_ifversion.
*"----------------------------------------------------------------------
  LOOP AT <ls_data>-gp ASSIGNING FIELD-SYMBOL(<ls_gp>).
*"----------------------------------------------------------------------
    TRY.
        success = 'Y'.

        CLEAR ls_aif_obj.

        IF <ls_gp>-bp_proc_status = 'E' OR <ls_gp>-bp_proc_status = 'A'.
          IF ls_aif_obj IS INITIAL.
            ls_aif_obj-msg_id = lv_msg_id.
            ls_aif_obj-ns = lv_ns.
            ls_aif_obj-ifname = lv_ifname.
            ls_aif_obj-ifver = lv_ifversion.
            ls_aif_obj-object = 'GP'.
            ls_aif_obj-objpos_id = <ls_gp>-bu_bpext.
          ENDIF.
          IF <ls_gp>-partner IS INITIAL. " GP existiert nicht und muss angelegt werden
*"----------------------------------------------------------------------
* GP anlegen
            MOVE-CORRESPONDING <ls_gp> to  ls_dto_psm_gp.
            /thkr/cl_bp_appl=>get_instance( )->create_partner(
              EXPORTING
                i_dto_bp_create = ls_dto_psm_gp
              IMPORTING
                e_partner       = lv_partner ).
<ls_gp>-partner = lv_partner.
          ELSE. " GP existiert, aber muss eventuell angepasst werden
            lv_partner = <ls_gp>-partner.
            "FIELD-SYMBOLS <ls_gp_modify> TYPE /thkr/s_dto_bp_modify.
            MOVE-CORRESPONDING <ls_gp> TO ls_dto_bp_modify EXPANDING NESTED TABLES.
            /thkr/cl_bp_appl=>get_instance( )->modify_partner( i_dto_bp_modify = ls_dto_bp_modify ).
          ENDIF.
          ls_aif_obj-status = 'S'.
          MODIFY /thkr/t_aif_obj FROM ls_aif_obj.
        ENDIF.
        IF 0 = 1. MESSAGE s111(b0). ENDIF.
        APPEND VALUE #( id         = 'B0'
                          number     = 111
                          type       = 'S'
                          message_v1 = lv_partner  ) TO return_tab.

*"----------------------------------------------------------------------
* Die genauen AO müssen noch identifiziert werden.
        LOOP AT <ls_data>-ao ASSIGNING FIELD-SYMBOL(<ls_ao>).
<ls_ao>-partner = lv_partner.
        ENDLOOP.
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
        ls_aif_obj-status = 'E'.
        MODIFY /thkr/t_aif_obj FROM ls_aif_obj.
        success = 'N'.
*"----------------------------------------------------------------------
    ENDTRY.
*----------------------------------------------------------------------
  ENDLOOP.
*----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
