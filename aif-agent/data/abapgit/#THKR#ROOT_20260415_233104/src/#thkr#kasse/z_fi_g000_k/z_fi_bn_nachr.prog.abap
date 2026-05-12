*&---------------------------------------------------------------------*
*& Report Z_FI_BN_NACHR
*&---------------------------------------------------------------------*
*& Benachrichtigungsobjekte anzeigen
*&---------------------------------------------------------------------*

INCLUDE z_fi_bn_nachr_top                       .    " Global Data

************************************************************************
INITIALIZATION.
************************************************************************
* ---- Parameter-ID besorgen:
  IF s_bukrs-low IS INITIAL.
    GET PARAMETER ID 'BUK' FIELD s_bukrs-low.  " 2025-08-19 js: Parameter-ID ergänzt
    IF s_bukrs-low IS NOT INITIAL.
      s_bukrs-sign = 'I'.
      s_bukrs-option = 'EQ'.
      APPEND s_bukrs.
    ENDIF.
  ENDIF.
  IF s_fistl-low IS INITIAL.
    GET PARAMETER ID 'FIS' FIELD s_fistl-low.  " 2025-08-19 js: Parameter-ID ergänzt
    IF s_fistl-low IS NOT INITIAL.
      s_fistl-sign = 'I'.
      s_fistl-option = 'EQ'.
      APPEND s_fistl.
    ENDIF.
  ENDIF.

************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_belnr-low.
************************************************************************

  SELECT bukrs gjahr belnr FROM zfi_bn_nachricht INTO TABLE gt_belege
         WHERE gjahr IN s_gjahr
           AND bukrs IN s_bukrs
           AND belnr IN s_belnr
           AND blart IN s_blart
           AND fipos IN s_fipos.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'S_BELNR-LOW'
      value_org    = 'S'
      window_title = 'Belege für Benachrichtigungen'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
    TABLES
      value_tab    = gt_belege
      return_tab   = gt_retval.

  LOOP AT gt_retval ASSIGNING FIELD-SYMBOL(<field>).
    WRITE <field>-fieldval TO s_belnr-low.
  ENDLOOP.


************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_belnr-high.
************************************************************************

  SELECT bukrs gjahr belnr FROM zfi_bn_nachricht INTO TABLE gt_belege
         WHERE gjahr IN s_gjahr
           AND bukrs IN s_bukrs
           AND belnr IN s_belnr
           AND blart IN s_blart
           AND fipos IN s_fipos.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'S_BELNR-HIGH'
      value_org    = 'S'
      window_title = 'Belege für Benachrichtigungen'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
    TABLES
      value_tab    = gt_belege
      return_tab   = gt_retval.

  LOOP AT gt_retval ASSIGNING FIELD-SYMBOL(<field>).
    WRITE <field>-fieldval TO s_belnr-high.
  ENDLOOP.

************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_blart-low.
************************************************************************

  SELECT bukrs gjahr belnr FROM zfi_bn_nachricht INTO TABLE gt_belege
         WHERE gjahr IN s_gjahr
           AND bukrs IN s_bukrs
           AND belnr IN s_belnr
           AND blart IN s_blart
           AND fipos IN s_fipos.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'S_BLART-LOW'
      value_org    = 'S'
      window_title = 'Belege für Benachrichtigungen'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
    TABLES
      value_tab    = gt_belege
      return_tab   = gt_retval.

  LOOP AT gt_retval ASSIGNING FIELD-SYMBOL(<field>).
    WRITE <field>-fieldval TO s_belnr-low.
  ENDLOOP.


************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_blart-high.
************************************************************************

  SELECT bukrs gjahr belnr FROM zfi_bn_nachricht INTO TABLE gt_belege
         WHERE gjahr IN s_gjahr
           AND bukrs IN s_bukrs
           AND belnr IN s_belnr
           AND blart IN s_blart
           AND fipos IN s_fipos.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield     = 'S_BLART-HIGH'
      value_org    = 'S'
      window_title = 'Belege für Benachrichtigungen'
      dynpprog     = sy-repid
      dynpnr       = sy-dynnr
    TABLES
      value_tab    = gt_belege
      return_tab   = gt_retval.

  LOOP AT gt_retval ASSIGNING FIELD-SYMBOL(<field>).
    WRITE <field>-fieldval TO s_belnr-high.
  ENDLOOP.

************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
************************************************************************

  gv_variant-report = g_repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = gv_variant
      i_save     = 'A'
    IMPORTING
      es_variant = gv_variant_help.

  p_vari = gv_variant_help-variant.


************************************************************************
AT SELECTION-SCREEN.
************************************************************************
  IF p_herk = 'Z'.
    CLEAR: p_hbkid, p_hktid, p_kukey, p_esnum, p_vblnr, p_vgext.
  ENDIF.

  IF p_herk = 'R'.
    CLEAR: p_laufd, p_laufi.
  ENDIF.

************************************************************************
START-OF-SELECTION.
************************************************************************
  DATA: l_bn_selection TYPE zfi_f_bn_selection,
        lo_salv_nachr  TYPE REF TO zcl_fi_bn_nachr_salv.


** Berechtigungsprüfung - später einschalten
*  AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCS' FIELD gv_tcode.
*  IF sy-subrc NE 0.
*    MESSAGE e021.
*  ENDIF.

* Selektionsstruktur füllen
  l_bn_selection-herk    = p_herk.
  l_bn_selection-r_fnr   = s_fnr[].
  l_bn_selection-r_erfd  = s_erfd[].
  l_bn_selection-inaktiv = 'X'.
  l_bn_selection-aktiv = 'X'.
* Zahllauf
  IF p_herk = 'Z'.
    l_bn_selection-laufd   = p_laufd.
    l_bn_selection-laufi   = p_laufi.
  ENDIF.

* ELKO
  IF p_herk = 'R' OR p_herk = 'A'.
    l_bn_selection-hbkid   = p_hbkid.
    l_bn_selection-hktid   = p_hktid.
    l_bn_selection-kukey   = p_kukey.
    l_bn_selection-esnum   = p_esnum.
    l_bn_selection-vgext   = p_vgext.
    l_bn_selection-vblnr   = p_vblnr.
  ENDIF.
*-------------------------------------------------------------------------*
* für Zahlungsanzeigen können wir auch KUKEY, ESNUM  und Zahlungs-
* Belegnummer haben
*-------------------------------------------------------------------------*
  IF p_herk = 'Y' .
    l_bn_selection-kukey   = p_kukey.
    l_bn_selection-esnum   = p_esnum.
    l_bn_selection-vblnr   = p_vblnr.
  ENDIF.

* Belegdaten
  l_bn_selection-r_bukrs = s_bukrs[].
  l_bn_selection-r_gjahr = s_gjahr[].
  l_bn_selection-r_belnr = s_belnr[].
  l_bn_selection-r_xblnr = s_xblnr[].
  l_bn_selection-r_uname = s_unam[].
  l_bn_selection-r_fistl = s_fistl[].
  l_bn_selection-r_lifnr = s_lifnr[].
  l_bn_selection-r_kunnr = s_kunnr[].
  l_bn_selection-r_blart = s_blart[].
  l_bn_selection-r_fipos = s_fipos[].



  CREATE OBJECT lo_salv_nachr.

  TRY.

* Anzeigevariante mitgeben
      IF p_vari IS NOT INITIAL.
        gv_vari = p_vari.
      ELSE.
        CASE p_herk.
          WHEN 'Z'.
            gv_vari = '/STANDARD'.
          WHEN 'R'.
            gv_vari = '/STANDARD_RL'.
          WHEN'A'.
            gv_vari = '/STANDARD_AL'.
          WHEN'Y'.
            gv_vari = '/STANDARD_ZA'.
          WHEN OTHERS.
            CLEAR gv_vari.
        ENDCASE.
      ENDIF.

      lo_salv_nachr->display(
        EXPORTING
          i_selection = l_bn_selection
          i_vari      = gv_vari ).

    CATCH cx_salv_not_found.

  ENDTRY.
