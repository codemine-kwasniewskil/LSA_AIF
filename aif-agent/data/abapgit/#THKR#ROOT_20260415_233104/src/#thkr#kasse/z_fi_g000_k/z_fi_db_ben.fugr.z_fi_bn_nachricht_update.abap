function z_fi_bn_nachricht_update.
*"----------------------------------------------------------------------
*"*"Verbuchungsfunktionsbaustein:
*"
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_FI_BN_NACHRICHT STRUCTURE  ZFI_BN_NACHRICHT OPTIONAL
*"      T_FI_BN_NACHRICHT_DEL STRUCTURE  ZFI_BN_NACHRICHT OPTIONAL
*"  EXCEPTIONS
*"      FEHLER
*"----------------------------------------------------------------------
  data: l_uuid type sysuuid_c32.
  field-symbols: <fs_bn> type zfi_bn_nachricht.
  data: lt_bn_nachricht type standard table of  zfi_bn_nachricht.
  data: ls_bn_nachricht type   zfi_bn_nachricht.


  loop at t_fi_bn_nachricht into ls_bn_nachricht where bnkey is initial.
*   Eindeutigen Systemschlüssel erzeugen
    try.
        l_uuid = cl_system_uuid=>create_uuid_c32_static( ).
      catch cx_uuid_error.
        l_uuid = 0.
        return.
    endtry.


*   Datensatz erzeugen
    ls_bn_nachricht-bnkey = l_uuid.
    ls_bn_nachricht-erfdat = sy-datum.
    ls_bn_nachricht-erftim = sy-uzeit.
    append ls_bn_nachricht to lt_bn_nachricht .
*    delete t_fi_bn_nachricht.
  endloop.

  if sy-subrc = 0.
    if lt_BN_NACHRICHT[] is not initial.
*   Datensatz Benachrichtigung einfügen
      insert zfi_bn_nachricht from table lt_BN_NACHRICHT.
      if sy-subrc ne 0.
        raise fehler .
      endif.
    endif.
  endif.

*----------------------------------------------------------------------
* aktuell ist kein UPDATE vorgesehen-> Sätze für Update
* müssten Ihren Benachrichtungskey BNKEY mitbringen
*---------------------------------------------------------------------
*  if t_fi_bn_nachricht[] is not initial.
**   Datensatz Benachrichtigung einfügen
*    update zfi_bn_nachricht from table t_fi_bn_nachricht.
**    delete zfi_bn_nachricht from table t_fi_bn_nachricht.
*    if sy-subrc ne 0.
*      raise fehler .
*    endif.
*endif.

  if t_fi_bn_nachricht_del[] is not initial.
    loop at t_fi_bn_nachricht_del into ls_bn_nachricht.
    delete from zfi_bn_nachricht where bnkey = ls_bn_nachricht-bnkey.
    endloop.
  endif.


endfunction.
