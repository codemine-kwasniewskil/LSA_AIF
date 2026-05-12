FUNCTION /thkr/gi_shlp_dd03m.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------
* EXIT immediately, if you do not want to handle this step
  IF callcontrol-step <> 'PRESEL1' AND callcontrol-step <> 'SELECT'.
    EXIT.
  ENDIF.

*"----------------------------------------------------------------------
* STEP PRESEL  (Enter selection conditions)
*"----------------------------------------------------------------------
* This step allows you, to influence the selection conditions either
* before they are displayed or in order to skip the dialog completely.
* If you want to skip the dialog, you should change CALLCONTROL-STEP
* to 'SELECT'.
* Normaly only SHLP-SELOPT should be changed in this step.
  IF callcontrol-step = 'PRESEL1'.

    DATA: l_interface LIKE LINE OF shlp-interface,
          l_filter_id TYPE /thkr/gi_filter_id,
          l_gi_id     TYPE /thkr/gi_id,
          l_gi_mc     TYPE /thkr/gi_mc,
          l_gi_mp_tab TYPE /thkr/gi_mp_tab,
          l_field     TYPE ty_field.

*   ID der generischen Schnittstelle auslesen
    READ TABLE shlp-interface
    WITH KEY shlpfield = 'GI_ID'
    INTO l_interface.

    IF l_interface-value IS INITIAL.
      "Absprung aus Filter-Regel?
      READ TABLE shlp-interface
      WITH KEY shlpfield = 'FILTER_ID'
      INTO l_interface.

      IF l_interface-value IS INITIAL.
        callcontrol-step = 'EXIT'.
      ENDIF.

      l_filter_id = l_interface-value.

*     Zielfeld der Suchhilfe bestimmern
      CLEAR l_interface.
      READ TABLE shlp-interface
      WITH KEY shlpfield = 'FIELDNAME'
      INTO l_interface.

      l_field = l_interface-valfield.

      PERFORM set_tabname_filter
        USING l_filter_id l_field.

    ELSE.
      l_gi_id = l_interface-value.

*     Methodenaufruf bestimmen
      CLEAR l_interface.
      READ TABLE shlp-interface
      WITH KEY shlpfield = 'GI_MC'
      INTO l_interface.

      l_gi_mc = l_interface-value.

*     Tabellen-Mapping bestimmen
      CLEAR l_interface.
      READ TABLE shlp-interface
      WITH KEY shlpfield = 'GI_MP_TAB'
      INTO l_interface.

      l_gi_mp_tab = l_interface-value.

      IF l_interface-valtabname = '/THKR/V_GIMPTAB'.
        "Es soll das DTO-Feld vom Typ Tabelle als Basis des Tabellen-Mappings bestimmt werden.
        "Daher sollen nicht die Felder der Tabellenzeile angezeigt werden, sondern die des DTO.
        CLEAR l_gi_mp_tab.
        g_no_prefix   = 'X'.  "Kein Prefix '{PARAM}-' in der Trefferliste
        g_tables_only = 'X'.  "Nur Felder mit Typ 'Tabelle'
      ELSE.
        CLEAR: g_no_prefix, g_tables_only.
      ENDIF.

*     Zielfeld der Suchhilfe bestimmern
      CLEAR l_interface.
      READ TABLE shlp-interface
      WITH KEY shlpfield = 'FIELDNAME'
      INTO l_interface.

      l_field = l_interface-valfield.

      PERFORM set_tabname USING l_gi_id l_gi_mc l_gi_mp_tab l_field.

      LOOP AT shlp-interface INTO l_interface WHERE shlpfield = 'TABNAME'.

        l_interface-value = g_tabname.
        MODIFY shlp-interface FROM l_interface.

      ENDLOOP.

    ENDIF.

    EXIT.
  ENDIF.
*"----------------------------------------------------------------------
* STEP SELECT    (Select values)
*"----------------------------------------------------------------------
* This step may be used to overtake the data selection completely.
* To skip the standard seletion, you should return 'DISP' as following
* step in CALLCONTROL-STEP.
* Normally RECORD_TAB should be filled after this step.
* Standard function module F4UT_RESULTS_MAP may be very helpfull in this
* step.
  IF callcontrol-step = 'SELECT'.
    DATA rc TYPE i.

    PERFORM step_select TABLES record_tab shlp_tab
                        CHANGING shlp callcontrol rc.
    IF rc = 0.
      callcontrol-step = 'DISP'.
    ELSE.
      callcontrol-step = 'EXIT'.
    ENDIF.
    EXIT. "Don't process STEP DISP additionally in this call.
  ENDIF.
*"----------------------------------------------------------------------
* STEP DISP     (Display values)
*"----------------------------------------------------------------------
* This step is called, before the selected data is displayed.
* You can e.g. modify or reduce the data in RECORD_TAB
* according to the users authority.
* If you want to get the standard display dialog afterwards, you
* should not change CALLCONTROL-STEP.
* If you want to overtake the dialog on you own, you must return
* the following values in CALLCONTROL-STEP:
* - "RETURN" if one line was selected. The selected line must be
*   the only record left in RECORD_TAB. The corresponding fields of
*   this line are entered into the screen.
* - "EXIT" if the values request should be aborted
* - "PRESEL" if you want to return to the selection dialog
* Standard function modules F4UT_PARAMETER_VALUE_GET and
* F4UT_PARAMETER_RESULTS_PUT may be very helpfull in this step.
  IF callcontrol-step = 'DISP'.
*   PERFORM AUTHORITY_CHECK TABLES RECORD_TAB SHLP_TAB
*                           CHANGING SHLP CALLCONTROL.
    EXIT.
  ENDIF.

ENDFUNCTION.
