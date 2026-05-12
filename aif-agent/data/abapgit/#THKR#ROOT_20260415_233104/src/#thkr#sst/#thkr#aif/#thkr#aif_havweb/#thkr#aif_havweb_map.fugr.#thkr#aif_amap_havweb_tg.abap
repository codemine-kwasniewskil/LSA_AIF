FUNCTION /thkr/aif_amap_havweb_tg .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_HVW_FILE
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_DE_HVW_TITEL_GR
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_DE_HVW_SAP
*"     REFERENCE(DEST_LINE) TYPE  /THKR/DTO_CREATE_PSM_TG
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_CREATE_PSM_TG
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  READ TABLE dest_table WITH KEY fikrs = dest_line-fikrs
                                 gjahr = dest_line-gjahr
                                 fkber = dest_line-fkber
                                 titelgrp = dest_line-titelgrp
                        TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    CLEAR append_flag.
    EXIT.
  ENDIF.

  READ TABLE raw_line-t_vermerk WITH KEY typ = 'ÜV' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    dest_line-cfflg = abap_true.
  ENDIF.
ENDFUNCTION.
