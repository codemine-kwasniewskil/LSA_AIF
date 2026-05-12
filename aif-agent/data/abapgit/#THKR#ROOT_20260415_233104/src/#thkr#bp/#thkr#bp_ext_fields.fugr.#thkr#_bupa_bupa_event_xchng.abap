FUNCTION /THKR/_BUPA_BUPA_EVENT_XCHNG.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(E_XCHNG) TYPE  BUS000FLDS-XCHNG
*"----------------------------------------------------------------------

DATA: ls_but000 Type but000.
  CLEAR e_xchng.
  CALL FUNCTION 'BUP_BUPA_BUT000_GET'
    IMPORTING
      e_but000 = ls_but000.

  IF   gv_zzgsber  <> gv_gsberold.
    e_xchng = true.
  ENDIF.



ENDFUNCTION.
