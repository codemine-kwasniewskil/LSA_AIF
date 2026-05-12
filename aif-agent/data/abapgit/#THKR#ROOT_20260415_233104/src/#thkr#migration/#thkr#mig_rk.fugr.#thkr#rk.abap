FUNCTION /thkr/rk.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_XBLNR) TYPE  /THKR/MIG_RK_KASS_ZEICHEN OPTIONAL
*"  EXPORTING
*"     VALUE(E_ALLGEMEIN) TYPE  /THKR/S_MIG_RK_ALLG
*"     VALUE(E_WEITERESCHULDNER) TYPE  /THKR/S_MIG_RK_WEIT_SCHULDN
*"     VALUE(ET_AMTSHILFE) TYPE  /THKR/T_MIG_RK_AHE_FB
*"     VALUE(ET_ADRESS_RK) TYPE  /THKR/T_MIG_RK_ADRH
*"     VALUE(ET_VERKETT_RK) TYPE  /THKR/T_MIG_RK_KZ_VERKETTET
*"     VALUE(ET_BAPIRET2) TYPE  BAPIRET2_T
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      NOT_FOUND
*"----------------------------------------------------------------------


  IF i_xblnr IS INITIAL.
    RAISE wrong_input.
  ENDIF.

  TRY.
      /thkr/cl_mig_rk=>get_instance( )->fb_rk(
        EXPORTING
          i_xblnr             =   i_xblnr                  " Rückstandskonto Kassenzeichen
        IMPORTING
          e_allgemein        =    e_allgemein              " Export allgemeine Daten für FB /THKR/RK
          e_weitereschuldner =    e_weitereschuldner       " Export weitere Schuldner für FB /THKR/RK
          et_amtshilfe        =   et_amtshilfe              " Export Amtshilfe für FB /THKR/RK
          et_adress_rk       =    et_adress_rk              " Adresshistorie Schuldner für FB /THKR/RK
          et_verkett_rk      =    et_verkett_rk             " Export verkettete RK für FB /THKR/RK
      ).

    CATCH /thkr/cx_lsa1 INTO DATA(l_oerror).
      et_bapiret2 = l_oerror->get_bapi_return_table( ).

  ENDTRY.


*  DATA: wa_/THKR/MIG_AO_SAP TYPE /thkr/mig_ao_sap.
*  DATA: wa_/THKR/s_mig_rk TYPE /THKR/s_mig_rk.
*
*  DATA: appl   TYPE REF TO /thkr/cl_mig_appl.
***  DATA: wa_/THKR/MIG_AO_SAP TYPE /thkr/mig_ao_sap.
***  DATA: wa_/THKR/s_mig_rk TYPE /THKR/s_mig_rk.
***
***  DATA: appl   TYPE REF TO /thkr/cl_mig_appl.
***
***  IF xblnr IS INITIAL.
***    RAISE wrong_input.
***  ENDIF.
***
***
**** Satz ID lesen
***  SELECT SINGLE * INTO wa_/THKR/MIG_AO_SAP FROM /thkr/mig_ao_sap WHERE xblnr = xblnr.
***
***  appl = /thkr/cl_mig_appl=>get_instance( ).
***
**** RK Daten lesen
***  appl->get_dto_mig_rk(
***    EXPORTING
***      i_satz_id = wa_/THKR/MIG_AO_SAP-satz_id
***    IMPORTING
***      e_dto     = DATA(l_dto_mig_rk) ).
***
******  DATA: wa_/THKR/MIG_AO_SAP TYPE /thkr/mig_ao_sap.
******  DATA: wa_/THKR/s_mig_rk TYPE /THKR/s_mig_rk.
***
**** Satz ID lesen
***  SELECT SINGLE * INTO wa_/THKR/MIG_AO_SAP FROM /thkr/mig_ao_sap WHERE xblnr = xblnr.
***
**** Verkette Konten ausgeben
***  SELECT kez_kett_kennz, kez_name INTO TABLE @verketteterk FROM /thkr/migd_rk WHERE kassenzeichen = @xblnr.
***
**** weitere Schuldner
***  SELECT SINGLE weitere_schuldner INTO weitereschuldner FROM /thkr/migd_rk_zp WHERE satz_id = wa_/THKR/MIG_AO_SAP-satz_id.
***
**** Adresshistorie
***  SELECT '11.11.2024', namezeile1, namezeile2, namezeile3, strasse, laenderkennzeichen, plz, ort
***      INTO TABLE @adresshistorieschuldner FROM  /thkr/migd_rk_zp WHERE satz_id = @wa_/THKR/MIG_AO_SAP-satz_id.


ENDFUNCTION.
