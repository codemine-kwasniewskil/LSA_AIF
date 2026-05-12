*----------------------------------------------------------------------*
***INCLUDE /THKR/LBFW_CONVERSIONSF01.
*----------------------------------------------------------------------*

FORM init_mig_ao_status .

  IF mig_ao_status_texts IS INITIAL.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = '/THKR/MIG_AO_SAP_STATUS'
        text      = 'X'
      TABLES
        dd07v_tab = mig_ao_status_texts.

    IF sy-subrc <> 0.
    ENDIF.

  ENDIF.

ENDFORM.
