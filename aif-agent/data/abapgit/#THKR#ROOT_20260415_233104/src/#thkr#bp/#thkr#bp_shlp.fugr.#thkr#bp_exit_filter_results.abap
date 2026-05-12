FUNCTION /THKR/BP_EXIT_FILTER_RESULTS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      RESULTS TYPE  BUS_LOCATOR_SEARCH_RESULT_T
*"----------------------------------------------------------------------
  DATA: lt_lookup       TYPE HASHED TABLE OF but000-partner_guid WITH UNIQUE KEY table_line,
        lt_results      TYPE bup_partner_guid_t,
        lt_selopts_guid TYPE bus_partner_guid_range_t.
  " Bringe Daten in die richtigen Datentypen
  LOOP AT results ASSIGNING FIELD-SYMBOL(<fs_results>).
    APPEND VALUE #( partner_guid = <fs_results>-fieldval ) TO lt_results.
  ENDLOOP.

  CALL FUNCTION '/THKR/BP_F4IF_CREATE_FILTER'
    EXPORTING
      it_check_partners = lt_results
      iv_use_guid       = abap_true
      iv_f4_type        = 'PARTNER'
    IMPORTING
      et_selopts_guid   = lt_selopts_guid
    EXCEPTIONS
      no_selopts        = 1
      OTHERS            = 2.
  " Falls es Filteroptionen gibt, verarbeite die Daten
  IF sy-subrc = 0.
    " Lösche alle EInträge, welche nicht den Selektionsoptionen entsprechen
    DELETE results
      WHERE fieldval NOT IN lt_selopts_guid.
  ELSEIF sy-subrc EQ 1.
    LOOP AT results ASSIGNING FIELD-SYMBOL(<lf_results>).
      DELETE results
        WHERE fieldval EQ <lf_results>-fieldval.
    ENDLOOP.
  ENDIF.




ENDFUNCTION.
