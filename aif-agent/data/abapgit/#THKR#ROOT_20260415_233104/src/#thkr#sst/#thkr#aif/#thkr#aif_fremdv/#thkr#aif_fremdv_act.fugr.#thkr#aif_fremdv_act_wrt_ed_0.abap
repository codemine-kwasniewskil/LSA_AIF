FUNCTION /thkr/aif_fremdv_act_wrt_ed_0 .
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
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_BIC_ZEILE
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

  "Schreibe BIC-Datensätze mit Betrag 0 in die Tabelle.
  "Muss gespeichert werden, um sich die Finanzierungsparameter zu sichern.
  "SZU hat keine eigenen Finanzierungsparameter, sondern nur eine Referenz über ein Kassenzeichen.
  "Wenn eine SZU von EDAS / OASIS geliefert wird, wird diese Zeile später für die Finanzpositionen verwendet.
  DATA: ls_edas_0 TYPE /thkr/t_edas_0.
  DATA: lo_struc TYPE REF TO cl_abap_structdescr.
*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_FREMDV_ACT_WRT_ED_0' ) TO return_tab.
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
  lo_struc ?= cl_abap_structdescr=>describe_by_data( p_data = curr_line ).
  DATA(lt_comp) = lo_struc->components.
  LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>).
    ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE curr_line TO FIELD-SYMBOL(<ls_curr_val>).
    ASSIGN COMPONENT <ls_comp>-name+3 OF STRUCTURE ls_edas_0 TO FIELD-SYMBOL(<ls_err_val>).
    IF <ls_err_val> IS ASSIGNED AND <ls_curr_val> IS ASSIGNED.
      <ls_err_val> = <ls_curr_val>.
    ENDIF.
  ENDLOOP.
  ls_edas_0-filename = |{ data-bic_struc-header-start+3 }{ data-bic_struc-header-verfa }{ data-bic_struc-header-gennr }.{ to_lower( data-bic_struc-header-empf )  }.{ data-bic_struc-header-dienstnr }|.
  ls_edas_0-receive_dats = sy-datum.
  ls_edas_0-receive_tims = sy-uzeit.
  MODIFY /thkr/t_edas_0 FROM ls_edas_0.
  IF sy-subrc = 0.
    if 1 = 0. MESSAGE i059(/THRK/SST) with ls_edas_0-hhj ls_edas_0-quelle ls_edas_0-qbelnr.endif.
    APPEND value bapiret2( id = '/THKR/SST'
                           number = 059
                           type = 'S'
                           message_v1 = ls_edas_0-hhj
                           message_v2 = ls_edas_0-quelle
                           message_v3 = ls_edas_0-qbelnr ) to return_tab[].
    success = 'Y'.
  ELSE.
    "Aktualisierung Fehlertabelle nicht erfolgreich.
    success = 'N'.
  ENDIF.

ENDFUNCTION.
