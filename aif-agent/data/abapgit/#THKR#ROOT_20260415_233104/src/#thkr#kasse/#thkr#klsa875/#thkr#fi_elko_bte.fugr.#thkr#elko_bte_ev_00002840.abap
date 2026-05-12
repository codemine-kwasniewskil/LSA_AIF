FUNCTION /thkr/elko_bte_ev_00002840 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_FEBEP) TYPE  FEBEP
*"     REFERENCE(I_ALV_MENU) TYPE  N DEFAULT 0
*"  EXPORTING
*"     VALUE(E_DYNNR) TYPE  SCRADNUM
*"     VALUE(E_REPID) TYPE  CUA_PROG
*"     REFERENCE(E_APPL_TAB_TITLE) TYPE  FIELDNAME
*"----------------------------------------------------------------------

* i_febep für die Folgebearbeitung global sichern
  g_febep = i_febep.
* aktuell keine Unterscheidung
  e_dynnr = '8000'.
  e_repid = '/THKR/SAPLFI_ELKO_BTE'.

* das wäre der Titel für unseren Tab
  IF e_appl_tab_title IS SUPPLIED.
    e_appl_tab_title = 'Zusatz'(010).
  ENDIF.


ENDFUNCTION.
