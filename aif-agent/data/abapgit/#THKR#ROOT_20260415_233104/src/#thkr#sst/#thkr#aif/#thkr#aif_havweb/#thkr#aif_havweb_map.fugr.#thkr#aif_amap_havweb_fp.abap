FUNCTION /thkr/aif_amap_havweb_fp .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_HVW_FILE
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_DE_HVW_TITEL
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_DE_HVW_SAP
*"     REFERENCE(DEST_LINE) TYPE  /THKR/DTO_CREATE_PSM_FP
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_CREATE_PSM_FP
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  READ TABLE raw_line-t_fp_vermerk WITH KEY typ = 'ÜV' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    dest_line-cfflg = abap_true.
  ENDIF.

  LOOP AT raw_line-t_zt INTO DATA(zs).
    CASE zs-nummer.
      WHEN '50'.
        IF zs-value IS NOT INITIAL.
          SPLIT zs-value AT '.' INTO dest_line-zz_oz1 dest_line-zz_uz1.
          dest_line-zz_uz1 = zs-value.
        ENDIF.
      WHEN '51'.
        IF dest_line-zz_oz2 IS INITIAL.
          dest_line-zz_oz2 = zs-value.
        ELSEIF dest_line-zz_oz3 IS INITIAL.
          dest_line-zz_oz3 = zs-value.
        ELSEIF dest_line-zz_oz4 IS INITIAL.
          dest_line-zz_oz4 = zs-value.
        ELSEIF dest_line-zz_oz5 IS INITIAL.
          dest_line-zz_oz5 = zs-value.
        ENDIF.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.
  ENDLOOP.
ENDFUNCTION.
