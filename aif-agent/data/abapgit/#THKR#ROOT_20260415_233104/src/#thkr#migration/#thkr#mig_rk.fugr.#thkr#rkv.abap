FUNCTION /thkr/rkv.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_XBLNR) TYPE  /THKR/MIG_RK_KASS_ZEICHEN
*"  EXPORTING
*"     VALUE(ET_RKV) TYPE  /THKR/T_MIG_AVVISO_RKV
*"     VALUE(ET_RKFA) TYPE  /THKR/T_MIG_AVVISO_RKFA
*"     VALUE(ET_BORH) TYPE  /THKR/T_MIG_AVVISO_BORH
*"     VALUE(ET_BAPIRET2) TYPE  BAPIRET2_T
*"  EXCEPTIONS
*"      WRONG_INPUT
*"      NOT_FOUND
*"----------------------------------------------------------------------
  TRY.

      /thkr/cl_mig_rk=>get_instance( )->fb_rkv(
         EXPORTING
           i_xblnr =  i_xblnr
         IMPORTING
          et_rkv                         = et_rkv
          et_rkfa                        = et_rkfa
          et_borh                        = et_borh ).


    CATCH /thkr/cx_lsa1 INTO DATA(l_oerror).
      et_bapiret2 = l_oerror->get_bapi_return_table( ).

  ENDTRY.

*****  DATA: wa_/THKR/MIG_AO_SAP TYPE /thkr/mig_ao_sap.
*****  DATA: wa_/THKR/s_mig_rk TYPE /THKR/s_mig_rk.
*****
*****  DATA: appl   TYPE REF TO /thkr/cl_mig_appl.
*****
*****  IF xblnr IS INITIAL.
*****    RAISE wrong_input.
*****  ENDIF.
*****
****** Satz ID lesen
*****  SELECT SINGLE * INTO wa_/THKR/MIG_AO_SAP FROM /thkr/mig_ao_sap WHERE xblnr = xblnr.
*****
*****  appl = /thkr/cl_mig_appl=>get_instance( ).
*****
****** RK Daten lesen
*****  appl->get_dto_mig_rk(
*****    EXPORTING
*****      i_satz_id = wa_/THKR/MIG_AO_SAP-satz_id
*****    IMPORTING
*****      e_dto     = DATA(l_dto_mig_rk) ).
****** Hilfsvariable Migrationsobjekt Anordnung
********  DATA: wa_/THKR/MIG_AO_SAP TYPE /thkr/mig_ao_sap.
*****
****** Satz ID lesen
*****  SELECT SINGLE * INTO wa_/THKR/MIG_AO_SAP FROM /thkr/mig_ao_sap WHERE xblnr = xblnr.
*****
****** Export weitere Wiedervorlage Standard für FB /THKR/RKV
*****  SELECT  lauf_vorgang, '11112024' INTO TABLE @wvltermine_standard FROM /thkr/MIGD_RK_SI WHERE satz_id = @wa_/THKR/MIG_AO_SAP-satz_id.
*****
****** Export Stundung und Niederschlagung für FB /THKR/RKV
*****  SELECT SINGLE bearbeitungsstatus, mahnstatus, vollstr_status, dat_stundung_ende, '11112024'  INTO @wvltermine_stundung_niederschl FROM /thkr/MIGD_RKFAP WHERE satz_id = @wa_/THKR/MIG_AO_SAP-satz_id.
*****
****** Export Insolvenz für FB /THKR/RKV
*****  SELECT SINGLE adf_schluessel INTO @wvltermine_insolvenz FROM /thkr/MIGD_RK_SI WHERE satz_id = @wa_/THKR/MIG_AO_SAP-satz_id.
*****
****** Export Vorgaenge BO für FB /THKR/RKV
*****
******REPORT
******DATUMUHRZEIT
******SB_KENNUNG
*****
****** Export Vorgaenge RVK für FB /THKR/RKV
*****  SELECT  faellig_dtu, '17' INTO TABLE @schuldnerhistorie_rvk FROM /thkr/MIGD_RKFAP WHERE satz_id = @wa_/THKR/MIG_AO_SAP-satz_id.
*****
*****
******* Verkette Konten ausgeben
******  SELECT kez_kett_kennz, kez_name INTO TABLE @verketteterk FROM /thkr/migd_rk WHERE kassenzeichen = @xblnr.
******
******* weitere Schuldner
******  SELECT SINGLE weitere_schuldner INTO weitereschuldner FROM /thkr/migd_rk_zp WHERE satz_id = wa_/THKR/MIG_AO_SAP-satz_id.
******
******* Adresshistorie
******  SELECT '11.11.2024', namezeile1, namezeile2, namezeile3, strasse, laenderkennzeichen, plz, ort
******      INTO TABLE @adresshistorieschuldner FROM  /thkr/migd_rk_zp WHERE satz_id = @wa_/THKR/MIG_AO_SAP-satz_id.
*****
*****


ENDFUNCTION.
