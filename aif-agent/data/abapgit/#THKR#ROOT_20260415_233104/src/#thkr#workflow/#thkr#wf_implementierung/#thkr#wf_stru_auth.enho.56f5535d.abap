"Name: \FU:RH_STRU_AUTHORITY_CHECK\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/WF_STRU_AUTH.
  " Bei einigen Prozessen soll die Strukturberechtigung nicht geprüft werden
  DATA: lo_struc TYPE REF TO data.

  FIELD-SYMBOLS: <ls_struc> TYPE any,
                 <lv_field> TYPE any.

  " Auslesen der Prozesse
  SELECT value_von, value_bis INTO TABLE @DATA(lt_param) FROM /thkr/t_wf_param WHERE object = 'STRUC_NO_CHECK'.
  IF sy-subrc = 0.

    " Datenstruktur
    CREATE DATA lo_struc TYPE syst.
    ASSIGN lo_struc->* TO <ls_struc>.
    <ls_struc> = syst.

    DATA(lv_exit) = abap_false.
    LOOP AT lt_param ASSIGNING FIELD-SYMBOL(<ls_param>).
      " Ermitteln Wert aus Systemdaten
      ASSIGN COMPONENT <ls_param>-value_von OF STRUCTURE <ls_struc> TO <lv_field>.
      IF <lv_field> IS ASSIGNED.
        " Prüfung gegen Wert aus Parametertabelle
        IF <lv_field> = <ls_param>-value_bis.
          " Ausnahme gefunden
          lv_exit = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
      UNASSIGN <lv_field>.
    ENDLOOP.

    IF lv_exit IS NOT INITIAL.
      " Strukturberechtigung wird nicht geprüft
      EXIT.
    ENDIF.

  ENDIF.

ENDENHANCEMENT.
