FUNCTION /thkr/aif_amap_ao .
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
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_AO
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_PSM_AO_BEL_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
DATA: lv_rc TYPE NRRETURN.

  "Kassenzeichen im Mapping bilden
  if dest_line-xblnr is INITIAL.
  /thkr/cl_kassenzeichen=>create( EXPORTING i_fonds = dest_line-t_kont[ 1 ]-geber
                                                        i_gsber = dest_line-t_kont[ 1 ]-gsber
                                                        i_nrnr  = '00'
                                              IMPORTING e_kaz   = dest_line-xblnr
                                                        e_rc    = lv_rc ).
  endif.

ENDFUNCTION.
