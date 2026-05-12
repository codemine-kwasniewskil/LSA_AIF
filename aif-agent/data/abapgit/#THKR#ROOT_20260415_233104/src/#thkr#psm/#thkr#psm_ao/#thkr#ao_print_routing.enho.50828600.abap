"Name: \PR:SAPLFMKW\FO:INIT_SCRIPT_FORM\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/AO_PRINT_ROUTING.
    "** Missing PSOTY for differ later on in SAP standard
    p_l_t_ifmkanor-psoty = vbkpf-psoty.
    "** SAP do NOT differ AnAO and AusAO for Daueranordnung.
    "** This type is added in SM30: V_FORMAN and determinated here before standard:
    "** Dauer-AusAO:
    IF  p_l_t_ifmkanor-recurring  = abap_true.
      IF p_l_t_ifmkanor-ausgabe    = abap_true.
        DATA(atyp) = COND #( WHEN p_l_t_ifmkanor-sammel2 = abap_true THEN '94' ELSE '90' ).
      ELSEIF p_l_t_ifmkanor-annahme    = abap_true.
        atyp = COND #( WHEN p_l_t_ifmkanor-sammel2 = abap_true THEN '95' ELSE '14' ).
      ENDIF.
    ELSE.
      "** Split/List -> AnAO or AusAO
      IF  p_l_t_ifmkanor-sammel4    = abap_true.
        IF  p_l_t_ifmkanor-psoty = '02'.
          atyp = '97'.
        ENDIF.
      ELSEIF  p_l_t_ifmkanor-sammel2    = abap_true.
        IF p_l_t_ifmkanor-annahme   = abap_true
        AND p_l_t_ifmkanor-psoty   <> '06' .
          atyp = '91'.
        ELSEIF p_l_t_ifmkanor-ausgabe = abap_true.
          atyp = '92'.
        ENDIF.
        IF p_l_t_ifmkanor-psoty = '04'.
          atyp = '93'.
        ELSEIF p_l_t_ifmkanor-psoty = '05'.
          atyp = '96'.
        ENDIF.
      ELSE.
        "** Overwrite AbsAO's
        atyp = COND #( WHEN p_l_t_ifmkanor-psoty = '05' THEN '04' ELSE atyp ).
        atyp = COND #( WHEN p_l_t_ifmkanor-psoty = '04' THEN '03' ELSE atyp ).
      ENDIF.
    ENDIF.
    "** Read related data from customizing OR hand over to standard
    IF atyp IS NOT INITIAL.
      SELECT SINGLE form_name FROM fmforman
                 INTO l_form_name
                 WHERE aoform = atyp.
      IF sy-subrc = 0.
        l_formtype = 'P'.
        RETURN.
      ENDIF.
    ENDIF.
ENDENHANCEMENT.
