FUNCTION z_fi_get_cleared_items.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_BELNR) TYPE  BELNR_D
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_GJAHR) TYPE  GJAHR
*"     REFERENCE(I_BVORG) TYPE  BVORG
*"  EXPORTING
*"     REFERENCE(ET_ITEMS) TYPE  ZFI_T_RFPOS
*"----------------------------------------------------------------------

  INCLUDE rfeposc1.

  DATA: l_items TYPE zfi_f_rfpos.

  REFRESH postab.

* ------ Mit Zahlbeleg bezahlte Rechnungen suchen ----------------------
  CALL FUNCTION 'GET_CLEARED_ITEMS'
    EXPORTING
      i_bvorg                = i_bvorg
      i_bukrs                = i_bukrs
      i_belnr                = i_belnr
      i_gjahr                = i_gjahr
    TABLES
      t_items                = postab
    EXCEPTIONS
      not_found              = 1
      error_cleared_accounts = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT postab ASSIGNING FIELD-SYMBOL(<item>).
    MOVE-CORRESPONDING <item> TO l_items.
    APPEND l_items TO et_items.
  ENDLOOP.

ENDFUNCTION.
