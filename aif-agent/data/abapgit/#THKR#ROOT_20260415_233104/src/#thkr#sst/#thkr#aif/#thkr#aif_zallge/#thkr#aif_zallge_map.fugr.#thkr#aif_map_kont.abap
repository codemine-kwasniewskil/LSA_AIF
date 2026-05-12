*"----------------------------------------------------------------------
* Gereon Koks  TSI  20.9.2024
*"----------------------------------------------------------------------
* KONT anhängen.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_map_kont .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT)
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"     REFERENCE(DEST_LINE)
*"     REFERENCE(DEST_TABLE)
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  DATA: ls_kont TYPE /thkr/s_dto_psm_ao_kont.

  FIELD-SYMBOLS: <ls_dest_line>  TYPE /thkr/s_dto_psm_ao_bel_create.
  ASSIGN dest_line  TO <ls_dest_line>.
*"----------------------------------------------------------------------
* WRBTR
  FIELD-SYMBOLS: <ls_raw_line_15_betr1>  TYPE /thkr/s_aif_bic_zeile-15_betr1.
  ASSIGN COMPONENT '15_betr1' OF STRUCTURE raw_line TO <ls_raw_line_15_betr1>.
  ls_kont-wrbtr = <ls_raw_line_15_betr1> / 100.

* FIPEX
  FIELD-SYMBOLS: <ls_raw_line_10_kap>  TYPE /thkr/s_aif_bic_zeile-10_kap.
  ASSIGN COMPONENT '10_kap' OF STRUCTURE raw_line TO <ls_raw_line_10_kap>.
  FIELD-SYMBOLS: <ls_raw_line_11_titel>  TYPE /thkr/s_aif_bic_zeile-11_titel.
  ASSIGN COMPONENT '11_titel' OF STRUCTURE raw_line TO <ls_raw_line_11_titel>.
  CONCATENATE <ls_raw_line_10_kap>+0(4)
              <ls_raw_line_11_titel>+0(3)
              <ls_raw_line_11_titel>+4(2)
              INTO ls_kont-fipex.

* FISTL
  ls_kont-fistl = '1101000001'.

* KOSTL
  ls_kont-kostl = '1101000000'.

* FKBER
  ls_kont-fkber = '0401'.

* GEBER
  ls_kont-geber = '04'.

* HKONT
  ls_kont-hkont = '5200000000'.
*"----------------------------------------------------------------------
* Mapping einfügen
*"----------------------------------------------------------------------
  APPEND ls_kont TO <ls_dest_line>-t_kont.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
