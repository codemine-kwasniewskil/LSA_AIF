FUNCTION /thkr/aif_fremdv_act_wrt_rk_er .
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

  "Lese Anordnungsstatus aus Datenverarbeitung aus
  "Wenn erfolgreich (AO_STATUS = S), dann übergebe Datensatz an Polizei
  "Wenn fehlerhaft, dann Leere Datenzeile
  "Ein Löschen des Datensatzes aus data-rko_polizei-line geht nicht,
  "Weil AIF Zeilenweise verarbeitet und am Ende mit einem
  "Feldsymbol nicht zugewiesen Fehler abbricht.
  DATA: ls_error_line TYPE /thkr/t_rko_err.
  DATA: lo_struc TYPE REF TO cl_abap_structdescr.
*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_FREMDV_ACT_WRT_RK_ER' ) TO return_tab.
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
  DATA(lv_glblid) = |{ curr_line-49_dstnr }{ curr_line-04_hhj }{ curr_line-05_quelle  }{ curr_line-06_qbelnr }|.
  TRY.
      IF data-ao[ glblid = lv_glblid ]-ao_proc_status <> 'S' AND data-ao[ glblid = lv_glblid ]-ao_proc_status <> 'W'.
        lo_struc ?= cl_abap_structdescr=>describe_by_data( p_data = curr_line ).
        DATA(lt_comp) = lo_struc->components.
        LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>).
          ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE curr_line TO FIELD-SYMBOL(<ls_curr_val>).
          ASSIGN COMPONENT <ls_comp>-name+3 OF STRUCTURE ls_error_line TO FIELD-SYMBOL(<ls_err_val>).
          IF <ls_err_val> IS ASSIGNED AND <ls_curr_val> IS ASSIGNED.
            <ls_err_val> = <ls_curr_val>.
          ENDIF.
        ENDLOOP.
        ls_error_line-filename = |{ data-bic_struc-header-start+3 }{ data-bic_struc-header-verfa }{ data-bic_struc-header-gennr }.{ to_lower( data-bic_struc-header-empf )  }.{ data-bic_struc-header-dienstnr }|.
        ls_error_line-receive_dats = sy-datum.
        ls_error_line-receive_tims = sy-uzeit.
        MODIFY /thkr/t_rko_err FROM ls_error_line.
        IF sy-subrc = 0.
          CLEAR: curr_line.
        ELSE.
          "Aktualisierung Fehlertabelle nicht erfolgreich.
          success = 'N'.
        ENDIF.
      ENDIF.

    CATCH cx_sy_itab_line_not_found.
      "Zeile kann in AO nicht gefunden werden.
      "Schreibe in Puffertabelle und Lösche aus Weiterleitung Polizei
      lo_struc ?= cl_abap_structdescr=>describe_by_data( p_data = curr_line ).
      lt_comp = lo_struc->components.
      LOOP AT lt_comp ASSIGNING <ls_comp>.
        ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE curr_line TO <ls_curr_val>.
        ASSIGN COMPONENT <ls_comp>-name+3 OF STRUCTURE ls_error_line TO <ls_err_val>.
        IF <ls_err_val> IS ASSIGNED AND <ls_curr_val> IS ASSIGNED.
          <ls_err_val> = <ls_curr_val>.
        ENDIF.
      ENDLOOP.
      ls_error_line-filename = |{ data-bic_struc-header-start+3 }{ data-bic_struc-header-verfa }{ data-bic_struc-header-gennr }.{ to_lower( data-bic_struc-header-empf )  }.{ data-bic_struc-header-dienstnr }|.
      ls_error_line-receive_dats = sy-datum.
      ls_error_line-receive_tims = sy-uzeit.
      MODIFY /thkr/t_rko_err FROM ls_error_line.
      IF sy-subrc = 0.
        CLEAR: curr_line.
      ENDIF.
  ENDTRY.
  success = 'Y'.
ENDFUNCTION.
