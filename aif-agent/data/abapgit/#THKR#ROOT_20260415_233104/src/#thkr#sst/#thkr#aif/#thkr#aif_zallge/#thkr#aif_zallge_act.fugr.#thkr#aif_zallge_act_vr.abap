* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Verrechnungsanordnung"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_vr .
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
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_VR
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.


  DATA: l_dto_psm_vr       TYPE /thkr/s_dto_psm_ao_verrechnung,
        ls_document_number TYPE /thkr/s_psm_ao_document_number.
*"----------------------------------------------------------------------
  TRY.
      success = 'Y'.
      curr_line-vr_proc_status = 'E'.
      MOVE-CORRESPONDING curr_line TO l_dto_psm_vr.
      /thkr/cl_psm_ao_appl=>get_instance( )->create_psm_ao_verrechnung(
        EXPORTING
          i_psm_ao_verrechnung     =  l_dto_psm_vr     " VErrechnungsanordnung
        IMPORTING
          e_psm_ao_document_number =  ls_document_number  " Beleg Nummer zu AO
      ).
      curr_line-vr_proc_status = 'S'.
      curr_line-belnr = ls_document_number-belnr.
      curr_line-lotkz = ls_document_number-lotkz.
      IF  curr_line-long_text-lines IS NOT INITIAL.
        "Hinzfügen des Schlüssels für Langtexte.
        "Belegnummer erst nach Buchung im System.
        curr_line-long_text-header-tdname = |{  curr_line-bukrs }{  curr_line-belnr }{  curr_line-gjahr }|.
      ENDIF.
      IF 1 = 0. MESSAGE s823(fq) WITH ls_document_number-lotkz ls_document_number-belnr. ENDIF.
      APPEND VALUE #( id         = 'FQ'
                       number     = 823
                       type       = 'S'
                       message_v1 = ls_document_number-lotkz
                       message_v2 = ls_document_number-belnr ) TO return_tab.
    CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_ao).
      IF lx_psm_ao->bapiret2_tab IS NOT INITIAL.
        APPEND LINES OF lx_psm_ao->bapiret2_tab TO return_tab.
      ELSE.
        APPEND VALUE #( id         = lx_psm_ao->if_t100_message~t100key-msgid
                        number     = lx_psm_ao->if_t100_message~t100key-msgno
                        type       = lx_psm_ao->if_t100_dyn_msg~msgty
                        message_v1 = lx_psm_ao->if_t100_dyn_msg~msgv1
                        message_v2 = lx_psm_ao->if_t100_dyn_msg~msgv2
                        message_v3 = lx_psm_ao->if_t100_dyn_msg~msgv3
                        message_v4 = lx_psm_ao->if_t100_dyn_msg~msgv4 ) TO return_tab.
      ENDIF.
      curr_line-vr_proc_status = 'E'.
      success = 'N'.
*"----------------------------------------------------------------------
  ENDTRY.
*----------------------------------------------------------------------
  curr_line-msg = return_tab[].
*----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
