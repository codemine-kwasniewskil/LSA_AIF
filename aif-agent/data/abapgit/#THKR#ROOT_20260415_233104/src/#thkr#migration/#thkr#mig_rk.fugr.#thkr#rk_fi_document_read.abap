FUNCTION /thkr/rk_fi_document_read ##RFC_PERFORMANCE_OK.
*"----------------------------------------------------------------------
*"*"Globale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BUKRS) LIKE  ACCIT-BUKRS OPTIONAL
*"     VALUE(I_BELNR) LIKE  BSEG-BELNR OPTIONAL
*"     VALUE(I_GJAHR) LIKE  BSEG-GJAHR OPTIONAL
*"     VALUE(I_XBLNR) TYPE  /THKR/MIG_RK_KASS_ZEICHEN OPTIONAL
*"     VALUE(I_AUTH_RFC) TYPE  XFELD DEFAULT SPACE
*"  EXPORTING
*"     VALUE(ET_BELEG) TYPE  /THKR/T_RK_BELEG
*"     VALUE(ET_BAPIRET2) TYPE  BAPIRET2_T
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      NOT_FOUND
*"----------------------------------------------------------------------

  TRY.
      /thkr/cl_mig_rk=>get_instance( )->fb_rk_fi_document_read(
        EXPORTING
          i_bukrs = i_bukrs
          i_belnr = i_belnr
          i_gjahr = i_gjahr
          i_xblnr = i_xblnr
        IMPORTING
          et_beleg = et_beleg ).

    CATCH /thkr/cx_lsa1 INTO DATA(l_oerror).
      et_bapiret2 = l_oerror->get_bapi_return_table( ).


  ENDTRY.

***  DATA: wa_/THKR/MIG_AO_SAP TYPE /thkr/mig_ao_sap.
****  DATA: wa_/THKR/s_mig_rk TYPE /THKR/s_mig_rk.
***
***  DATA: wa_t_bkpf TYPE /thkr/s_fi_read_rfc_bkpf_rk.
***  DATA: wa_t_bseg TYPE /THKR/S_FI_READ_RFC_Bseg_RK.
***
***  DATA: appl   TYPE REF TO /thkr/cl_mig_appl.
***
***  IF xblnr IS INITIAL.
***    IF bukrs IS INITIAL OR belnr IS INITIAL OR gjahr IS INITIAL.
***      RAISE wrong_input.
***    ELSE.
***      SELECT SINGLE * INTO wa_/THKR/MIG_AO_SAP FROM /thkr/mig_ao_sap WHERE bukrs = bukrs AND gjahr = gjahr AND belnr = belnr.
***      IF sy-subrc = 0.
***        RAISE wrong_input.
***      ELSE.
***        xblnr = wa_/THKR/MIG_AO_SAP-xblnr.
***      ENDIF.
***    ENDIF.
***  ENDIF.
***
**** Satz ID lesen
***  SELECT SINGLE * INTO wa_/THKR/MIG_AO_SAP FROM /thkr/mig_ao_sap WHERE xblnr = xblnr.
***
***  appl = /thkr/cl_mig_appl=>get_instance( ).
***
***  DATA: l_dto_mig_rk TYPE /thkr/s_dto_mig_rk_sap.
***  DATA: t_rk_faell  TYPE  /thkr/t_mig_rk_fa.
***  DATA: wa_t_rk_faell TYPE  /thkr/s_mig_rk_fa_k.
***  DATA: t_rkn TYPE  /thkr/t_mig_rkn.
***  DATA: t_rkv TYPE  /thkr/t_mig_rkv.
***
**** Für Fälligkeit
***  DATA: t_rk_pos  TYPE  /thkr/t_mig_rk_fap.
***
**** RK Daten lesen
***  appl->get_dto_mig_rk(
***    EXPORTING
***      i_satz_id = wa_/THKR/MIG_AO_SAP-satz_id
***    IMPORTING
***      e_dto     = l_dto_mig_rk ).
***
***
***
***  IF 1 = 1.
***    wa_t_bkpf-xblnr  = l_dto_mig_rk-kassenzeichen.
***    APPEND wa_t_bkpf TO t_bkpf.
***
****Rückstandskonto Fälligkeit
***    t_rk_faell = l_dto_mig_rk-t_rk_faell.
****Migration: RKVorgänge
***    t_rkv = l_dto_mig_rk-t_rkv.
****Migration: Notizen zu offene Rückstanskonten
***    t_rkn = l_dto_mig_rk-t_rkn.
***
****Rückstandskonto Fälligkeit Positionen
***    LOOP AT t_rk_faell INTO wa_t_rk_faell.
***      t_rk_pos = wa_t_rk_faell-t_rk_pos.
***    ENDLOOP.
****    wa_t_bseg-manst = l_dto_mig_rk-t_rk_faell-
***  ENDIF.
***
****  SELECT mandt, '2024', 'H', 'AWKEY', kassenzeichen INTO TABLE @t_bkpf FROM /thkr/migd_rk WHERE satz_id = @wa_/THKR/MIG_AO_SAP-satz_id.
***



ENDFUNCTION.
