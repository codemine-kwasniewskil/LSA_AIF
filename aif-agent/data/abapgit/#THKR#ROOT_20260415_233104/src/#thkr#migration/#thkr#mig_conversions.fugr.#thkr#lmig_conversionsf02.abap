*----------------------------------------------------------------------*
***INCLUDE /THKR/LMIG_CONVERSIONSF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init_mig_mvw_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_mig_mvw_status .

  IF mig_mvw_status_texts IS INITIAL.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = '/THKR/MIG_MVW_SAP_STATUS'
        text      = 'X'
      TABLES
        dd07v_tab = mig_mvw_status_texts.

    IF sy-subrc <> 0.
    ENDIF.

  ENDIF.

ENDFORM.
