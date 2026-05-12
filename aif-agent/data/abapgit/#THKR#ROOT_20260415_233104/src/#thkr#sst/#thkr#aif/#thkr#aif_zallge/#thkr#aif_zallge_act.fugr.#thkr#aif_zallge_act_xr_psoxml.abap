*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_ZALLGE_ACT_XR_PSOXML .
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
"Das Feld XREF1_HD kann in der internen Schnittstelle
" /thkr/cl_psm_ao_appl=>get_instance( )->create_psm_ao_beleg verarbeitet werden.
" dort wird die Struktur fm_t_bbkpf für den Belegkopf verwendet,
" die dieses Feld nicht beinhaltet. Also Update auf Beleg im Nachgang.
  ASSIGN curr_line  TO FIELD-SYMBOL(<ls_curr_line>).
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).

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
    "Verarbeitung Annahmeanordung, Auszahlungsanordnung
    /thkr/cl_pso_xml_processing=>get_instance( )->upd_xref1_hd(
      EXPORTING
        it_ao      = <ls_curr_line>-ao
      CHANGING
        ct_return  = return_tab[]
        cv_success = success                 " Erfolgskennzeichen
    ).

    "Verarbeitung Sollabgang, Sollzugang
    /thkr/cl_pso_xml_processing=>get_instance( )->upd_xref1_hd(
      EXPORTING
        it_ao      = <ls_curr_line>-ao_reference
      CHANGING
        ct_return  = return_tab[]
        cv_success = success                 " Erfolgskennzeichen
    ).
  ENDIF.

*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
