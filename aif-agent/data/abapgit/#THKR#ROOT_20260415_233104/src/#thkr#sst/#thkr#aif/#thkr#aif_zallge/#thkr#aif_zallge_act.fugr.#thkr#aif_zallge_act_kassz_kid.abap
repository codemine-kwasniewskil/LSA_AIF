FUNCTION /thkr/aif_zallge_act_kassz_kid .
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
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_SAP_BIENE_KIDI
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA:
    mo_cut             TYPE REF TO /thkr/cl_psm_ao_appl,
    ls_document_number TYPE /thkr/s_psm_ao_document_number,
    ls_dto_psm_ao      TYPE /thkr/s_dto_psm_ao_bel_create,
    ls_gp              TYPE /thkr/s_aif_sap_gp.
*"----------------------------------------------------------------------
  success = 'N'.
*"----------------------------------------------------------------------
  IF curr_line IS NOT INITIAL.
*"----------------------------------------------------------------------
    APPEND VALUE #( id         = 'KM'
                     number     = 418
                     type       = 'I'
                     message_v1 = '/THKR/AIF_ZALLGE_ACT_KASSZ_KID' ) TO return_tab.
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
    "Kassenzeichen aus Anordnung und Verarbeitungsstatus holen.
    TRY.
        curr_line-bzg_kassz = data-ao[ glblid = curr_line-glblid ]-xblnr.
        IF curr_line-bzg_kassz IS INITIAL.
          "Kassenzeichen neu gebildet, muss von DB nachgelesen werden.
          DATA(lv_burks) = data-ao[ glblid = curr_line-glblid ]-bukrs.
          DATA(lv_belnr) = data-ao[ glblid = curr_line-glblid ]-belnr.
          DATA(lv_gjahr) = data-ao[ glblid = curr_line-glblid ]-gjahr.
          SELECT SINGLE xblnr
     FROM bkpf
     WHERE bukrs = @lv_burks
       AND belnr = @lv_belnr
       AND gjahr = @lv_gjahr
       INTO @curr_line-bzg_kassz.
        ENDIF.
        curr_line-status = data-ao[ glblid = curr_line-glblid ]-ao_proc_status.
        success = 'Y'.
      CATCH cx_sy_itab_line_not_found.
        CLEAR: curr_line-bzg_kassz.
        IF 1 = 0. MESSAGE w070(/thkr/sst) WITH curr_line-glblid .ENDIF.
        APPEND VALUE bapiret2( id         = '/THKR/SST'
                      number     = 070
                      type       = 'W'
                      message_v1 = curr_line-glblid ) TO return_tab.
        success = 'N'.
    ENDTRY.
*"----------------------------------------------------------------------
  ENDIF.
*"----------------------------------------------------------------------
* Über AIF Customizing
*  COMMIT WORK AND WAIT.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
