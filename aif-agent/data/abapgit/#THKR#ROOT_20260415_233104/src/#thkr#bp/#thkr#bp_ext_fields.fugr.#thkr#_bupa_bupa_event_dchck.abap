FUNCTION /thkr/_bupa_bupa_event_dchck.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
  DATA:
    lv_check  TYPE xfeld,
    ls_but000 TYPE but000,
    lv_view   TYPE bus_sicht,
    lv_dynfld TYPE busreqfld.
  FIELD-SYMBOLS:
<fs_role> TYPE bup_bprole.

* Prüfung nur im Anlage-/Änderungsmodus
  CHECK: gs_current_control-aktyp EQ '01' OR
         gs_current_control-aktyp EQ '02'.
  CALL FUNCTION 'BUP_BUPA_BUT000_GET'
    IMPORTING
      e_but000 = ls_but000.

  IF gv_zzgsber IS INITIAL.
*    MESSAGE e001(00) WITH 'Feld Geschäftsbereich ist zu pflegen!'.
* &1&2&3&4&5&6&7&8
    CALL FUNCTION 'BUS_MESSAGE_STORE'
      EXPORTING
        arbgb = 'AA'
        msgty = 'E'
        txtnr = '918'
*       msgv1 =
*       msgv2 = ls_return-message_v2
*       msgv3 = ls_return-message_v3
*       msgv4 = ls_return-message_v4.
      .
  ELSE.

     DATA(lv_no_auth) = /thkr/cl_auth_check=>check_bupa_object(
                          EXPORTING iv_act = gs_current_control-aktyp
                          iv_augrp = ls_but000-augrp
                          iv_gsber = gv_zzgsber
                          "iv_object =
                           ).
*    AUTHORITY-CHECK OBJECT 'Z_BUPA_GSB'
*     ID 'ACTVT' FIELD gs_current_control-aktyp
*     ID 'GSBER' FIELD gv_zzgsber.
    IF lv_no_auth = abap_true.
      CALL FUNCTION 'BUS_MESSAGE_STORE'
        EXPORTING
          arbgb = '/THKR/BP'
          msgty = 'E'
          txtnr = '002'
          msgv1 = gv_zzgsber
*         msgv2 = ls_return-message_v2
*         msgv3 = ls_return-message_v3
*         msgv4 = ls_return-message_v4.
        .
    ENDIF.


  ENDIF.
  IF   gv_zzgsber  <> gv_gsberold AND gv_zzgsber IS NOT INITIAL.
* Prüfung auf Inhaltscheck

  ENDIF.




ENDFUNCTION.
