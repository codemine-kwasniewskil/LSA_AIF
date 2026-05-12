FUNCTION /thkr/rkn.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_XBLNR) TYPE  /THKR/MIG_RK_KASS_ZEICHEN OPTIONAL
*"  EXPORTING
*"     VALUE(ET_NOTIZEN) TYPE  /THKR/T_MIG_RK_NOTIZ
*"     VALUE(ET_BAPIRET2) TYPE  BAPIRET2_T
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      NOT_FOUND
*"----------------------------------------------------------------------
  TRY.
      /thkr/cl_mig_rk=>get_instance( )->fb_rkn(
        EXPORTING
          i_xblnr    = i_xblnr
        IMPORTING
         et_notizen  = et_notizen ).

    CATCH /thkr/cx_lsa1 INTO DATA(l_oerror).
      et_bapiret2 = l_oerror->get_bapi_return_table( ).

  ENDTRY.



***  DATA: wa_/THKR/MIG_AO_SAP TYPE /thkr/mig_ao_sap. "Migrationsobjekt Anordnung
***  DATA: l_dto_mig_rk TYPE /thkr/s_dto_mig_rk_sap.  "DTO: Migration Rückstandskonto - Status
***  DATA: t_rkn TYPE  /thkr/t_mig_rkn.               "Migration: RKNotizen
***  DATA: wa_t_rkn TYPE  /thkr/s_mig_rkn_k.          "Migration: Notizen zu offene Rückstanskonten
***  DATA: wa_notizen TYPE /thkr/s_thkr_rk_rfc_notizen_rk. "Export Notizen für FB /THKR/RKN
***  DATA: appl   TYPE REF TO /thkr/cl_mig_appl. "Anwendung: Migration
***
***  IF xblnr IS INITIAL.
***    RAISE wrong_input.
***  ENDIF.
***
**** Satz ID lesen
***  SELECT SINGLE * INTO wa_/THKR/MIG_AO_SAP FROM /thkr/mig_ao_sap WHERE xblnr = xblnr.
***
**** RK instanziieren
***  appl = /thkr/cl_mig_appl=>get_instance( ).
***
**** RK Daten lesen
***  appl->get_dto_mig_rk(
***    EXPORTING
***      i_satz_id = wa_/THKR/MIG_AO_SAP-satz_id
***    IMPORTING
***      e_dto     = l_dto_mig_rk ).
***
****Migration: Notizen zu offene Rückstanskonten
***  t_rkn = l_dto_mig_rk-t_rkn.
***  IF t_rkn IS INITIAL.
***    RAISE not_found.
***  ELSE.
***    LOOP AT t_rkn INTO wa_t_rkn.
***      wa_notizen-bearbeiter  = wa_t_rkn-login_name.
***      wa_notizen-datum = wa_t_rkn-datum.
***      wa_notizen-rkntext = wa_t_rkn-text.
***      wa_notizen-rknzeile = wa_t_rkn-zeile.
***    ENDLOOP.
***  ENDIF.
ENDFUNCTION.
