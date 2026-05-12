*"----------------------------------------------------------------------
* Gereon Koks  TSI  18.11.2024
*"----------------------------------------------------------------------
* Check BTYP against SST.
* If interface sends a BTYP which is not allowed,
* the interface stops directly.
*"----------------------------------------------------------------------
* Input
*"----------------------------------------------------------------------
* Output
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_chk_btyp_sst .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_AIF_BIC
*"     REFERENCE(RETURN_TAB_MAPPING) TYPE  BAPIRETTAB
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(CLEAR_ERROR_MESSAGES) TYPE  BOOLEAN
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"----------------------------------------------------------------------
* Which interface ?
  DATA: db_/aif/t_vmapval TYPE /aif/t_vmapval.

  SELECT * FROM /aif/t_vmapval INTO db_/aif/t_vmapval
    WHERE ns        = 'ZALLGE'
      AND vmapname  = 'MAP_/THKR/SST'
      AND ext_value = raw_struct-header-empf.

  ENDSELECT.
*"----------------------------------------------------------------------
  DATA: ls_/thkr/s_aif_bic_zeile TYPE /thkr/s_aif_bic_zeile,
        db_/thkr/chk_btyp        TYPE /thkr/chk_btyp,
        ls_bapiret2              TYPE bapiret2,
        ls_string                TYPE string.

  LOOP AT raw_struct-line INTO ls_/thkr/s_aif_bic_zeile.
    SELECT * FROM /thkr/chk_btyp INTO db_/thkr/chk_btyp
      WHERE sst  = db_/aif/t_vmapval-int_value
        AND btyp = ls_/thkr/s_aif_bic_zeile-01_btyp.

    ENDSELECT.

    IF sy-subrc <> 0.
* Exit
      ls_bapiret2-type   = 'E'.
      ls_bapiret2-id     = '/THKR/SST'.
      ls_bapiret2-number = '001'.
      CONCATENATE 'Zur Schnittstelle'
                  db_/aif/t_vmapval-int_value
                  INTO ls_string SEPARATED BY space.
      ls_bapiret2-message_v1 = ls_string.
      CONCATENATE 'ist der Buchungsschlüssel'
                  ls_/thkr/s_aif_bic_zeile-01_btyp
                  INTO ls_string SEPARATED BY space.
      ls_bapiret2-message_v2 = ls_string.
      ls_string = 'nicht vorgesehen und kann'.
      ls_bapiret2-message_v3 = ls_string.
      ls_string = 'nicht verarbeitet werden.'.
      ls_bapiret2-message_v4 = ls_string.

      APPEND ls_bapiret2 TO return_tab.
    ENDIF.
  ENDLOOP.
*"----------------------------------------------------------------------
ENDFUNCTION.
