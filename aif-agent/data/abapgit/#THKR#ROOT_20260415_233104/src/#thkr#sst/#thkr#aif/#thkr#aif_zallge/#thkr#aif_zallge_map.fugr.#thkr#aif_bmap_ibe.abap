*"----------------------------------------------------------------------
* Edina Muhari  17.1.2025
*"----------------------------------------------------------------------

*"----------------------------------------------------------------------
FUNCTION /thkr/aif_bmap_ibe .
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
*"     REFERENCE(OUT_STRUCT)
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_VR
*"     REFERENCE(DEST_TABLE)
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  DATA: ls_bkpf     TYPE bkpf,
        lt_kont     TYPE /thkr/t_dto_psm_ao_kont,
        ls_kont     TYPE /thkr/s_dto_psm_ao_kont,
        ls_bseg     TYPE bseg,
        lv_15_betrl TYPE string,
        lv_wrbtr    TYPE string.

*"----------------------------------------------------------------------
* BKPF
*"----------------------------------------------------------------------

  SELECT SINGLE *  INTO CORRESPONDING FIELDS OF ls_bseg
    FROM bseg
    INNER JOIN bkpf ON bkpf~belnr = bseg~belnr
    WHERE ( bkpf~blart = 'DR' OR bkpf~blart = 'D1' )
      AND  bkpf~xblnr = raw_line-41_urkass.

  IF sy-subrc = 0.
    dest_line-hkont = ls_bseg-hkont.
    dest_line-fipex = ls_bseg-fipos.
    dest_line-fistl = ls_bseg-fistl.
    dest_line-gsber = ls_bseg-gsber.
    dest_line-kostl = ls_bseg-kostl.
    dest_line-fkber = ls_bseg-fkber.
*    dest_line-fikrs = ls_bseg-fikrs.
    dest_line-geber = ls_bseg-geber.

  ELSE.

    APPEND VALUE bapiret2( id = '/THKR/SST'
                       number = 033
                       type = 'E'
                       message_v1 = raw_line-41_urkass ) TO dest_line-msg.
    dest_line-vr_proc_status = 'E'.

  ENDIF.


*"----------------------------------------------------------------------
ENDFUNCTION.
