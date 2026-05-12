FUNCTION /thkr/bp_f4if_class_std_exit.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

  DATA: lv_fuba_exists TYPE sxst_pare-exist.
  " Wenn noch nicht geschehen, lese Daten aus der Customizingtabelle
  IF std_exits IS INITIAL.
    PERFORM get_stdexit_names.
  ENDIF.
  " Lese Exit aus dem Customizing aus, falls vorhanden
  READ TABLE std_exits WITH KEY suchhilfe = shlp-shlpname not_exist = '' ASSIGNING FIELD-SYMBOL(<fs_exit>).
  IF sy-subrc = 0.
    " Prüfe, ob der Funktionsbaustein vorhanden ist
    CALL FUNCTION 'CHECK_EXIST_LIMU_FUNC'
      EXPORTING
        name            = CONV e071-obj_name( <fs_exit>-exit_name )
      IMPORTING
        exist           = lv_fuba_exists
      EXCEPTIONS
        tr_invalid_type = 1
        OTHERS          = 2.
    " Wenn ein Fehler autritt oder der FuBa nicht exisitert, gebe eine Meldung aus und merke das FuBa nicht vorhandne
    IF sy-subrc <> 0 OR lv_fuba_exists IS INITIAL.
      <fs_exit>-not_exist = abap_true.
      MESSAGE i003(/THKR/BP) WITH shlp-shlpname.
      RETURN.
    ENDIF.
    " Prüfen, ob die Schnittstelle korrekt ist
    DATA: lv_subrc TYPE sy-subrc.
    SELECT * FROM fupararef
      INTO TABLE @DATA(lt_params)
      WHERE funcname = @<fs_exit>-exit_name.
    READ TABLE lt_params
      WITH KEY funcname = <fs_exit>-exit_name
               parameter = 'SHLP_TAB'
               paramtype = 'T' r3state = 'A'
               TRANSPORTING NO FIELDS.
    ADD sy-subrc TO lv_subrc.
    READ TABLE lt_params
      WITH KEY funcname = <fs_exit>-exit_name
               parameter = 'RECORD_TAB'
               paramtype = 'T' r3state = 'A'
               TRANSPORTING NO FIELDS.
    ADD sy-subrc TO lv_subrc.
    READ TABLE lt_params
      WITH KEY funcname = <fs_exit>-exit_name
               parameter = 'SHLP'
               paramtype = 'C' r3state = 'A'
               TRANSPORTING NO FIELDS.
    ADD sy-subrc TO lv_subrc.
    READ TABLE lt_params
      WITH KEY funcname = <fs_exit>-exit_name
               parameter = 'CALLCONTROL'
               paramtype = 'C' r3state = 'A'
               TRANSPORTING NO FIELDS.
    ADD sy-subrc TO lv_subrc.
    IF lv_subrc NE 0.
      <fs_exit>-not_exist = abap_true.
      MESSAGE i003(/THKR/BP) WITH shlp-shlpname.
      RETURN.
    ENDIF.
    TRY.
        " Rufe FuBa auf mit Übergabe aller Strukturen
        CALL FUNCTION <fs_exit>-exit_name
          TABLES
            shlp_tab    = shlp_tab
            record_tab  = record_tab
          CHANGING
            shlp        = shlp
            callcontrol = callcontrol.
      CATCH cx_root.
        <fs_exit>-not_exist = abap_true.
        MESSAGE i003(/THKR/BP) WITH shlp-shlpname.
        RETURN.
    ENDTRY.
  ENDIF.


ENDFUNCTION.
