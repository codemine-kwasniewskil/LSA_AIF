FUNCTION /thkr/_bupa_bupa_event_auth1.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------

*------ local data declarations    ----------------------------------------
  DATA: lv_status LIKE bus000flds-char1.
  " BREAK-POINT.

  TYPES:
    BEGIN OF lty_chk_auth_rslt,
      bp_actvt   TYPE bu_aktyp,
      data_ctrlr TYPE bu_data_ctrlr,
      purpose    TYPE bu_purpose,
      status     TYPE sy-subrc,
    END OF lty_chk_auth_rslt .
  TYPES:
    BEGIN OF lty_dc_pur,
      Data_ctrlr TYPE bu_data_ctrlr,
      purpose    TYPE bu_purpose,
    END OF lty_dc_pur .
  DATA:lv_msgv1          LIKE sy-msgv1,
       ls_return         TYPE bapiret2,
       lt_dc_purpose     TYPE TABLE OF lty_dc_pur,
       ls_dc_purpose     TYPE lty_dc_pur,
       lt_dcpd_auth_rslt TYPE TABLE OF lty_chk_auth_rslt,
       lt_dc             LIKE but_dc_link OCCURS 0 WITH HEADER LINE,
       lt_error          TYPE bapiret2_t.
  DATA:
    ls_but000    TYPE but000,
    ls_bus_istat TYPE bus_istat.

* Prüfung nur im Änderungs und Anzeigemodus

  CALL FUNCTION 'BUP_BUPA_BUT000_GET'
    IMPORTING
      e_but000      = ls_but000
      e_but000_stat = ls_bus_istat.

  CHECK ls_bus_istat-aktyp = '03' OR ls_bus_istat-aktyp = '02'.
*------ authority check B_BUPA_GRP (authority group) ----------------------
*------ ... process check ----------------------------------------------------
  IF NOT ls_but000-/thkr/gsber IS INITIAL.
*
*    AUTHORITY-CHECK OBJECT 'Z_BUPA_GSB'
*     ID 'ACTVT' FIELD ls_bus_istat-aktyp
*     ID 'GSBER' FIELD ls_but000-/thkr/gsber.

    DATA(lv_no_auth) = /thkr/cl_auth_check=>check_bupa_object(
                              EXPORTING iv_act = ls_bus_istat-aktyp
                              iv_augrp = ls_but000-augrp
                              iv_gsber = ls_but000-/thkr/gsber
                              "iv_object = iv_object
                               ).


*------ ... no authority: error message --------------------------
*------ ...... acivity create ---------------------------------------
    IF lv_no_auth = abap_true.

*------ dequeue paartner  ---------------------------------------------
      IF but000_stat-aktdb = gc_aktyp_change.
        CALL FUNCTION 'BUP_DEQUEUE'
          EXPORTING
            i_partner = ls_but000-partner
            i_aktyp   = ls_bus_istat-aktyp
            i_aktdb   = ls_bus_istat-aktdb
            i_xsave   = gv_xsave.
      ENDIF.
      CALL FUNCTION 'BUS_MESSAGE_STORE'
        EXPORTING
          arbgb = '/THKR/BP'
          msgty = 'E'
          txtnr = '002'
          msgv1 = gv_zzgsber.
    ENDIF.
  ENDIF.


ENDFUNCTION.
