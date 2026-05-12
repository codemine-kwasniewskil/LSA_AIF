FUNCTION /thkr/fi_apar_mandate_check.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_MANDATE) TYPE  SEPA_MANDATE
*"  EXPORTING
*"     REFERENCE(ET_MESSAGES) TYPE  BAPIRET1_LIST
*"----------------------------------------------------------------------

  DATA: ls_message  TYPE bapiret1.
  DATA: lt_messages TYPE bapiret1_list.
  DATA: lx_swift_optional TYPE xfeld.
  DEFINE check_field_not_empty.
    PERFORM check_field_filled USING i_mandate &1 CHANGING ls_message.
    IF NOT ls_message IS INITIAL.
      APPEND ls_message TO et_messages.
      RETURN.
    ENDIF.
  END-OF-DEFINITION.
  DEFINE check_field_value.
    PERFORM check_field_content
      USING i_mandate &1 &3 CHANGING ls_message.
    IF NOT ls_message IS INITIAL AND 1 &2 1.
      APPEND ls_message TO et_messages.
      RETURN.
    ENDIF.
  END-OF-DEFINITION.

* overall mandatory fields and values ----------------------------------
  check_field_value: 'ANWND' = gc_anwnd_fi,    "SEPA application
           'REC_TYPE' = gc_bor-companycode.    "recipient type

  check_field_not_empty: 'PAY_TYPE',           "transaction type 1/N
                         'STATUS',             "mandate status
                         'SND_ID',             "sender identification
                         'SND_COUNTRY',        "sender coutry
                         'REC_ID',             "receiver identification
                         'REC_COUNTRY'.        "receiver country

* receiver identification - white list check (company code exists)
  gh_zbukr = i_mandate-rec_id.
  PERFORM plausi_zbukr USING gh_zbukr CHANGING ls_message.
  IF NOT ls_message IS INITIAL.
    APPEND ls_message TO et_messages.
    RETURN.
  ENDIF.

* common debtor mandatory fields and values ----------------------------
  IF i_mandate-snd_type = gc_bor-araccount.
    gh_kunnr = i_mandate-snd_id.
    gh_zbukr = i_mandate-rec_id.
*   sender identification white list check (customer exists)
    PERFORM plausi_kunnr USING gh_kunnr CHANGING ls_message.
    IF NOT ls_message IS INITIAL.
      APPEND ls_message TO et_messages.
      RETURN.
    ENDIF.
*   sender-receiver relation check (customer created in company code)
    PERFORM plausi_kunnr_zbukr USING gh_kunnr gh_zbukr
                            CHANGING ls_message.
    IF NOT ls_message IS INITIAL.
      APPEND ls_message TO et_messages.
      RETURN.
    ENDIF.

* one-time debtor mandatory fields and values --------------------------
  ELSEIF i_mandate-snd_type = gc_bor-bseg.
    check_field_value 'PAY_TYPE' = '1'.        "transaction type = 1!
  ELSE.
    PERFORM set_message USING 'E' 'FIN_SEPA' 004
      'SND_TYPE' gc_bor-araccount gc_bor-bseg ''
      CHANGING ls_message.
    IF 1 = 2.
      MESSAGE e004(fin_sepa).                               "#EC *
    ENDIF.
    APPEND ls_message TO et_messages.
    RETURN.
  ENDIF.

* fields mandatory when status active or wait for approval(needed for WF)-------------------------
  IF i_mandate-status = gc_status-active or i_mandate-status = gc_status-wait.
    check_field_not_empty: 'SND_IBAN',         "sender IBAN
                           'SIGN_CITY',        "location of signature
                           'SIGN_DATE'.        "signature date
    IF i_mandate-snd_bic IS INITIAL.
      CALL FUNCTION 'SEPA_COUNTRY_SPECIFIC_CHECKS'
        EXPORTING
          i_anwnd          = i_mandate-anwnd
          i_iban           = i_mandate-snd_iban
        IMPORTING
          e_swift_optional = lx_swift_optional.
      IF lx_swift_optional IS INITIAL.
        check_field_not_empty 'SND_BIC'.       "sender BIC
      ENDIF.
    ENDIF.
  ENDIF.

* sender IBAN check                                          "N2109583
  CASE i_mandate-snd_type.
    WHEN gc_bor-araccount. "IBAN belongs to customer master
      IF NOT i_mandate-snd_iban IS INITIAL     AND
      ( i_mandate-status <> gc_status-canceled AND
        i_mandate-status <> gc_status-obsolete AND
        i_mandate-status <> gc_status-closed ).
        PERFORM plausi_iban_bic USING gh_kunnr
                                      i_mandate-snd_iban
                                      i_mandate-snd_bic
                             CHANGING ls_message.
        IF NOT ls_message IS INITIAL.
          APPEND ls_message TO et_messages.
          RETURN.
        ENDIF.
      ENDIF.
    WHEN gc_bor-bseg. "IBAN belongs to fi document
      IF ( i_mandate-snd_id = gh_docref )      AND
         ( i_mandate-snd_iban IS NOT INITIAL   OR
           i_mandate-snd_bic  IS NOT INITIAL ) AND
      ( i_mandate-status <> gc_status-canceled AND
        i_mandate-status <> gc_status-obsolete AND
        i_mandate-status <> gc_status-closed ).
        PERFORM plausi_iban_bic_bseg USING gh_docref
                                           i_mandate-snd_iban
                                           i_mandate-snd_bic
                                  CHANGING ls_message.
        IF NOT ls_message IS INITIAL.
          APPEND ls_message TO et_messages.
          RETURN.
        ENDIF.
      ENDIF.
  ENDCASE.

  GET BADI go_badi.
  CALL BADI go_badi->check_before_save
    EXPORTING
      i_mandate   = i_mandate
    CHANGING
      ct_messages = lt_messages.
  APPEND LINES OF lt_messages TO et_messages.
  "----------------------------------------------------------
  "Pruefung, ob B2B verwendet wurde  16.7.2019
* In der TA FI_APAR_SEPA_FIELDS  ist das Feld bereits auf nicht eingabebereit gesetzt
* daher ist diese coding nur für den Fall relevant, dass es dort versehentlich entfernt wird.
  IF i_mandate-b2b IS NOT INITIAL.
    PERFORM set_message USING 'E' 'FIN_SEPA' 007
      'SND_TYPE' gc_bor-araccount gc_bor-bseg ''
      CHANGING ls_message.
    IF NOT ls_message IS INITIAL.
      APPEND ls_message TO et_messages.
      RETURN.
    ENDIF.

  ENDIF.
***** Fehler in den Sepamandaten
  IF i_mandate-/thkr/gsber IS INITIAL.
    PERFORM set_message USING 'E' '/THKR/FI_NACHR' 031
           '' '' '' '' CHANGING ls_message.
    IF 1 = 2.  " only for the where-used list
      MESSAGE e031(/thkr/fi_nachr).   "#EC
    ENDIF.
    IF NOT ls_message IS INITIAL.
      APPEND ls_message TO et_messages.
      RETURN.
    ENDIF.

    ELSE.



  ENDIF.


ENDFUNCTION.
