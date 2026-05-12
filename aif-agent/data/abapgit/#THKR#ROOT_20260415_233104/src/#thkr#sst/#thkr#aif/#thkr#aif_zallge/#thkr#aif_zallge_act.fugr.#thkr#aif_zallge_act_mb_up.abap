*"----------------------------------------------------------------------
* Gereon Koks  TSI  14.11.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Wertanpassung"
* "Wertanpassung" ist eine Änderung der ursprünglichen Mittelbindung.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_mb_up .
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
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_MV_UP
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA: l_dto_psm_mv_update_val TYPE /thkr/s_dto_psm_mv_update_val,
        ls_aif_obj              TYPE /thkr/t_aif_obj.
*"----------------------------------------------------------------------
  TRY.
*"----------------------------------------------------------------------
      APPEND VALUE #( id         = 'KM'
                       number     = 418
                       type       = 'I'
                       message_v1 = '/THKR/AIF_ZALLGE_ACT_MB_UP' ) TO return_tab.
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
      success = 'Y'.
      curr_line-mv_up_proc_status = 'E'.
      MOVE-CORRESPONDING curr_line TO l_dto_psm_mv_update_val.
*"----------------------------------------------------------------------
      /thkr/cl_psm_mv_appl=>get_instance( )->update_psm_mv_value(
         EXPORTING
           i_dto_psm_mv_update_val = l_dto_psm_mv_update_val
       ).
*"----------------------------------------------------------------------
      curr_line-mv_up_proc_status = 'S'.
      IF curr_line-long_text-lines IS NOT INITIAL.
        "Hinzfügen des Schlüssels für Langtexte.
        "Belegnummer erst nach Buchung im System.
        curr_line-long_text-header-tdname = |{ sy-mandt }{ curr_line-belnr }000|.
      ENDIF.
*"----------------------------------------------------------------------
      APPEND VALUE #( id         = '/THKR/SST'
                       number     = 001
                       type       = 'I'
                       message_v1 = 'Wertanpassung für Mittelbindung'
                       message_v2 = l_dto_psm_mv_update_val-belnr
                       message_v3  = 'wurde durchgeführt.' ) TO return_tab.
*"----------------------------------------------------------------------
    CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_psm_mb).
      IF lxc_psm_mb->bapiret2_tab IS NOT INITIAL.
        APPEND LINES OF lxc_psm_mb->bapiret2_tab TO return_tab.
      ELSE.
        APPEND VALUE #( id         = lxc_psm_mb->if_t100_message~t100key-msgid
                        number     = lxc_psm_mb->if_t100_message~t100key-msgno
                        type       = lxc_psm_mb->if_t100_dyn_msg~msgty
                        message_v1 = lxc_psm_mb->if_t100_dyn_msg~msgv1
                        message_v2 = lxc_psm_mb->if_t100_dyn_msg~msgv2
                        message_v3 = lxc_psm_mb->if_t100_dyn_msg~msgv3
                        message_v4 = lxc_psm_mb->if_t100_dyn_msg~msgv4 ) TO return_tab.
      ENDIF.

      ls_aif_obj-status = 'E'.
      MODIFY /thkr/t_aif_obj FROM ls_aif_obj.
      success = 'N'.
  ENDTRY.
*----------------------------------------------------------------------
  curr_line-msg = return_tab[].
ENDFUNCTION.
*"----------------------------------------------------------------------
