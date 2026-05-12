*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* CUSTOMER anhängen.
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_AMAP_COMPACTING_GP .
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
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_XML_SAP
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_GP
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_BP_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
DATA: lv_exists TYPE flag.
if dest_line is INITIAL.
  return.
else.
  LOOP at dest_table ASSIGNING FIELD-SYMBOL(<ls_dest_tab>).
    if <ls_dest_tab> = dest_line.
      lv_exists = abap_true.
      exit.
    else.
      lv_exists = abap_false.
    endif.
  ENDLOOP.
endif.
if lv_exists = abap_false.
  append_flag = abap_true.
else.
  append_flag = abap_false.
endif.

ENDFUNCTION.
*"----------------------------------------------------------------------
