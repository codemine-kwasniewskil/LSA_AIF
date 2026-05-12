*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Anordnung"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_storno .
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
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_STORNO
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA: lo_storno  TYPE REF TO /thkr/cl_fi_storno.
  DATA: ls_storno  TYPE /thkr/s_fi_key_storno_data.
*"----------------------------------------------------------------------
  IF curr_line IS NOT INITIAL.
*"----------------------------------------------------------------------
    APPEND VALUE #( id         = 'KM'
                     number     = 418
                     type       = 'I'
                     message_v1 = '/THKR/AIF_ZALLGE_ACT_STORNO' ) TO return_tab.
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
        MOVE-CORRESPONDING curr_line TO ls_storno.
        lo_storno = NEW /thkr/cl_fi_storno( i_fi_beleg_storno_data = ls_storno ).

        lo_storno->start_fi_storno(
          CHANGING
            ct_return_tab = return_tab[]
        ).
        curr_line-proc_status = 'S'.
        success = 'Y'.
        APPEND VALUE #( id         = '/THKR/SST'
                       number     = 017
                       type       = 'S'
                       message_v1 = curr_line-lotkz
                       message_v2 = curr_line-belnr ) TO return_tab.

      CATCH /thkr/cx_fi INTO DATA(lxc_storno). " Ausnahmeklasse für FI
        IF lxc_storno->bapiret2_tab IS NOT INITIAL.
          APPEND LINES OF lxc_storno->bapiret2_tab TO return_tab.
        ELSE.
          APPEND VALUE #( id         = lxc_storno->if_t100_message~t100key-msgid
                          number     = lxc_storno->if_t100_message~t100key-msgno
                          type       = lxc_storno->if_t100_dyn_msg~msgty
                          message_v1 = lxc_storno->if_t100_dyn_msg~msgv1
                          message_v2 = lxc_storno->if_t100_dyn_msg~msgv2
                          message_v3 = lxc_storno->if_t100_dyn_msg~msgv3
                          message_v4 = lxc_storno->if_t100_dyn_msg~msgv4 ) TO return_tab.
        ENDIF.
        success = 'N'.
        curr_line-proc_status = 'E'.
    ENDTRY.
*"----------------------------------------------------------------------
  ENDIF.
*"----------------------------------------------------------------------
   curr_line-msg = return_tab[].
ENDFUNCTION.
*"----------------------------------------------------------------------
