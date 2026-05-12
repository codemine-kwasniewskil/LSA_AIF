*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* CUSTOMER anhängen.
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_AMAP_FOOTER .
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
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_AIF_SAP_RUECK_KLRP_RT
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_BIC_ZEILE
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_AIF_BIC_ZEILE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
DATA: lv_exists TYPE flag.

out_struct-footer-anz = |{ lines( dest_table ) + 1 ALIGN = RIGHT WIDTH = 8 PAD = '0' }|.
out_struct-footer-kontoll = conv i( out_struct-footer-kontoll ) + conv i( |{ dest_line-15_betr1 }| ).
out_struct-footer-kontoll = |{ out_struct-footer-kontoll ALPHA = IN }|.
ENDFUNCTION.
*"----------------------------------------------------------------------
