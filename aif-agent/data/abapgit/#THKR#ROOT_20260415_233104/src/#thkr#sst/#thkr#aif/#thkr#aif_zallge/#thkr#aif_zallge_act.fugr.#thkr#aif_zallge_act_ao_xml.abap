*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_ao_xml .
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
  DATA: lv_partner    TYPE bu_partner,
        lv_partner_fv TYPE bu_partner,
        ls_dto_psm_ao TYPE /thkr/s_dto_psm_ao_bel_create.

  ASSIGN curr_line  TO FIELD-SYMBOL(<ls_curr_line>).
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

  success = 'Y'.


*"----------------------------------------------------------------------

  IF <ls_curr_line> IS ASSIGNED AND <ls_curr_line> IS NOT INITIAL.
    LOOP AT <ls_curr_line>-ao ASSIGNING FIELD-SYMBOL(<ls_ao>).
      TRY.
          IF  ( <ls_ao>-ao_proc_status IS INITIAL OR <ls_ao>-ao_proc_status = 'E' OR <ls_ao>-ao_proc_status = 'A' ).
            READ TABLE <ls_curr_line>-gp ASSIGNING FIELD-SYMBOL(<ls_gp>) WITH KEY bu_bpext = <ls_ao>-ao_bpext.
            IF sy-subrc <> 0.
              APPEND VALUE #( id         = '/CPD/SS_MESSAGES'
                              number     = 346
                              type       = 'E'
                              message_v1 = <ls_ao>-ao_bpext ) TO return_tab.
              <ls_ao>-ao_proc_status = 'E'.
              CONTINUE.
            ENDIF.
            <ls_ao>-partner = <ls_gp>-partner.
            MOVE-CORRESPONDING <ls_ao> TO ls_dto_psm_ao.
            "kein ordentliches Fehlerhandling in AO-Anlage
            "Daher wird der Status im Vorfeld auf Fehler gesetzt.
            "Ist die Buchung erfolgreich, dann wird später der Status auf S gesetzt.
            <ls_ao>-ao_proc_status = 'E'.
            /thkr/cl_psm_ao_appl=>get_instance( )->create_psm_ao_beleg(
                             EXPORTING
                               i_dto_psm_ao_bel_create = ls_dto_psm_ao
                             IMPORTING
                               e_psm_ao_document_number = DATA(ls_psm_ao_document_number) ).
            MOVE-CORRESPONDING ls_psm_ao_document_number TO <ls_ao>.
            <ls_ao>-ao_proc_status = 'S'.
            IF 1 = 0. MESSAGE s823(fq) WITH ls_psm_ao_document_number-lotkz ls_psm_ao_document_number-belnr. ENDIF.
            APPEND VALUE #( id         = 'FQ'
                             number     = 823
                             type       = 'S'
                             message_v1 = ls_psm_ao_document_number-lotkz
                             message_v2 = ls_psm_ao_document_number-belnr ) TO return_tab.
          ENDIF.
        CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_ao).
          <ls_ao>-ao_proc_status = 'E'.
          APPEND LINES OF lxc_ao->bapiret2_tab TO return_tab.
          success = 'N'.
      ENDTRY.
    ENDLOOP.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
