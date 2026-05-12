*----------------------------------------------------------------------*
***INCLUDE LZ_FI_ELKO_BTEO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_8000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
module status_8000 output.

*----------------------------------------------------------------------*
* alle bereits vorhandenen Daten werden ermittelt
*----------------------------------------------------------------------*
*  if g_febep-kukey = g_febep_new-kukey
*  and g_febep-esnum = g_febep_new-esnum.
**----------------------------------------------------------------------*
** hier selektieren, da Buchung und Storno nicht berücksichtigt
** werden
**----------------------------------------------------------------------*
*    select single  zz_status  zz_wdvdat
*     zz_avviso   into
*    ( g_febep_new-zz_status,
*      g_febep_new-zz_wdvdat,
*      g_febep_new-zz_avviso )   from febep
*      where kukey = g_febep-kukey
*      and   esnum = g_febep-esnum.
*
*    zfi_dynp_elko_bte-wdvdat = g_febep_new-zz_wdvdat.
*    zfi_dynp_elko_bte-status = g_febep_new-zz_status.
*    zfi_dynp_elko_bte-avviso = g_febep_new-zz_avviso.
*
**falls wir mehrfach schalten
*    g_febep-zz_wdvdat = g_febep_new-zz_wdvdat.
*    g_febep-zz_status = g_febep_new-zz_status.
*    g_febep-zz_avviso = g_febep_new-zz_avviso.
*
**----------------------------------------------------------------------*
**neuer Satz
**----------------------------------------------------------------------*
*  else.
*    zfi_dynp_elko_bte-wdvdat = g_febep-zz_wdvdat.
*    zfi_dynp_elko_bte-status = g_febep-zz_status.
*    zfi_dynp_elko_bte-avviso = g_febep-zz_avviso.
*    clear:  /thkr/dynp_elko_bte-variant,  /thkr/dynp_elko_bte-formid.
*endif.

*----------------------------------------------------------------------*
* hier wird das Verwahrkassenzeichen ermittelt
*----------------------------------------------------------------------*
*if g_ok_code ne 'REP_KASSZ' .
*    perform n2p_read.
*endif.

*----------------------------------------------------------------------*
*  keine Bearbeitervermerke
*  bereits vorhandene Bearbeitervermerke interessieren nicht
*----------------------------------------------------------------------*
***if g_ok_code ne 'REP_BAVM' and
***   g_ok_code ne 'ENTER'.
***    clear zfi_dynp_elko_bte-BAVWEZW.
***endif.


* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
endmodule.
