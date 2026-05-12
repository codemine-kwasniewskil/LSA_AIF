class /THKR/CL_BADI_SEPA_MNDT_ASSIGN definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_SEPA_MANDATE_ASSIGN .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_BADI_SEPA_MNDT_ASSIGN IMPLEMENTATION.


METHOD if_ex_sepa_mandate_assign~assign.
*---------------------------------------------------------------------
*es soll ein Mandat passend zu GSBER und XBLNR ausgewählt
* " 241220 jseifert: kassenzeichenspezif. Mandate haben Vorrang, dürfen nicht durch den
*                    GSBER-LOOP überschrieben werden
* " 241220 jseifert: im GSBER-LOOP dürfen ferner nur die nicht-kassenz-spez. Mandate
*                    berücksichtigt werden
*---------------------------------------------------------------------
  DATA:
    ls_sel         TYPE sepa_get_criteria_mandate,
    lt_mandate     TYPE sepa_tab_data_mandate_data,
    lc_mandat_ohne TYPE sepa_mndid VALUE 'OHNE'.

* Prüfung Zahlweg notwendig?
*---------------------------------------------------------------------
* Item muss einen Geschäftsbereich haben
  IF is_bsid-kunnr IS NOT INITIAL AND ( is_bsid-gsber IS NOT INITIAL OR is_bsid-xblnr IS NOT INITIAL ).
*     Set application and contact type as search criteria
    CLEAR ls_sel.
    ls_sel-anwnd    = 'F'.                  "Financials
    ls_sel-snd_type = 'BUS3007'.            "Customer
    ls_sel-snd_id = is_bsid-kunnr.
*---------------------------------------------------------------------
*     Search for mandates of IBAN
    CALL FUNCTION 'SEPA_MANDATES_API_GET'
      EXPORTING
        i_sel_criteria            = ls_sel
        i_flg_only_valid_mandates = 'X'
        i_date                    = sy-datlo
        i_act                     = '03'
      IMPORTING
        et_mandates               = lt_mandate.
*---------------------------------------------------------------------
*     diese Output-tabelle enthält FELD /THKR/XBLNR
*---------------------------------------------------------------------
    LOOP AT lt_mandate ASSIGNING FIELD-SYMBOL(<ls_mandate>) WHERE /thkr/xblnr = is_bsid-xblnr AND /thkr/xblnr IS NOT INITIAL.
      ev_sepa_mandate = <ls_mandate>-mndid.
      EXIT.
    ENDLOOP.

    IF sy-subrc NE 0.   " 241220 jseifert: nur wenn kein kassenzeichenspezifisches Mandat gefunden...
*---------------------------------------------------------------------
*     diese Output-tabelle enthält FELD /THKR/GSBER
*---------------------------------------------------------------------
      LOOP AT lt_mandate ASSIGNING <ls_mandate> WHERE /thkr/gsber = is_bsid-gsber AND /thkr/gsber IS NOT INITIAL
           AND /thkr/xblnr IS INITIAL. " 241220 jseifert: im GSBER-LOOP dürfen nur die nicht-kassenz-spez. Mandate geklesen werden
        ev_sepa_mandate = <ls_mandate>-mndid.
        EXIT.
      ENDLOOP.
    ENDIF.              " 241220 jseifert

* kann man einen festen falschen Wert mitgeben (?)
    IF sy-subrc NE 0.
      ev_sepa_mandate = lc_mandat_ohne.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
