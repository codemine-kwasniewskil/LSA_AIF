*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_ZALLGE_ACT_ST_PSOXML .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_PSO_XML_SAP
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_PSO_XML_SAP_OBJECTS
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

  IF <ls_curr_line> IS ASSIGNED AND <ls_curr_line> IS NOT INITIAL.
    "Verarbeitung Storno
    /thkr/cl_pso_xml_processing=>get_instance( )->process_storno(
      CHANGING
        ct_storno  = <ls_curr_line>-storno                 " Tabelle für Stornierungen
        ct_return  = return_tab[]
        cv_success = success                  " Erfolgskennzeichen
    ).

  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
