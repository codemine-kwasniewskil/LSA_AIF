*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* CUSTOMER anhängen.
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_AMAP_MV .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT)
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_AIF_BIC_ZEILE
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_DTO_PSM_MV_CREATE
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_PSM_MV_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------

  "Tabelle T_KONT füllen
  APPEND INITIAL LINE TO dest_line-t_kont ASSIGNING FIELD-SYMBOL(<ls_kont>).

  "Originalbetrag in Transaktionswährung
  <ls_kont>-wtorig = conv i( raw_line-15_betr1 ) / 100.

  "Finanzposition
  FIELD-SYMBOLS: <ls_raw_line_10_kap>  TYPE /thkr/s_aif_bic_zeile-10_kap.
  ASSIGN COMPONENT '10_kap' OF STRUCTURE raw_line TO <ls_raw_line_10_kap>.
  FIELD-SYMBOLS: <ls_raw_line_11_titel>  TYPE /thkr/s_aif_bic_zeile-11_titel.
  ASSIGN COMPONENT '11_titel' OF STRUCTURE raw_line TO <ls_raw_line_11_titel>.
  CONCATENATE raw_line-10_kap+0(4)
              raw_line-11_titel+0(3)
              raw_line-11_titel+4(2)
              INTO <ls_kont>-fipex.

  "Finanzstelle
  <ls_kont>-fistl = '1101000001'.

  "Kostenstelle
  <ls_kont>-kostl = '1101000000'.

  "Funktionsbereich
  <ls_kont>-fkber = '0401'.

  "Fonds
  <ls_kont>-geber = '04'.

  "Sachkonto der Hauptbuchhaltung
  <ls_kont>-hkont = '5200000000'.

  "Fälligkeitsdatum der Mittelvormerkung
  <ls_kont>-fdatk = raw_line-17_fdatum.
*"----------------------------------------------------------------------
append_flag = abap_true.
ENDFUNCTION.
*"----------------------------------------------------------------------
