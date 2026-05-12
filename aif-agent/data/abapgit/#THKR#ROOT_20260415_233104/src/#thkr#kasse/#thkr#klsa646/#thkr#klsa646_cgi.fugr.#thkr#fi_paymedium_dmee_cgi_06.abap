FUNCTION /thkr/fi_paymedium_dmee_cgi_06.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_FPAYH) LIKE  FPAYH STRUCTURE  FPAYH
*"     VALUE(IS_FPAYHX) LIKE  FPAYHX STRUCTURE  FPAYHX
*"     VALUE(I_PAYMEDIUM) TYPE  XFELD OPTIONAL
*"  EXPORTING
*"     REFERENCE(ES_FPAYHX) LIKE  FPAYHX_FREF STRUCTURE  FPAYHX_FREF
*"  TABLES
*"      T_FPAYP STRUCTURE  FPAYP
*"----------------------------------------------------------------------
  DATA: lo_cgi_call05 TYPE REF TO if_idfi_cgi_call05.
* ---------------------------------------------------------------------
* START OF DMEE without EXIT
* ---------------------------------------------------------------------
* New fiori app processing requires logging of non-persistent info

  TABLES: /thkr/gsber_exce.

  CONSTANTS: lc_lhkd  TYPE name1 VALUE 'LHK Dessau'.

  DATA: lv_gsber      TYPE gsber,
        lv_gtext      TYPE gtext,
        ls_gsber_exce TYPE /thkr/gsber_exce.
  FIELD-SYMBOLS: <fs_fpayp> TYPE fpayp.


  IF i_paymedium = abap_true.

    CALL METHOD cl_idfi_cgi_call05_factory=>get_instance
      EXPORTING
        is_fpayh     = is_fpayh
        is_fpayhx    = is_fpayhx
        iv_paymedium = i_paymedium
        it_fpayp     = t_fpayp[]
      RECEIVING
        ro_instance  = lo_cgi_call05.
    IF lo_cgi_call05 IS BOUND.
      CALL METHOD lo_cgi_call05->fill_fpay_fref
        EXPORTING
          is_fpayh       = is_fpayh
          is_fpayhx      = is_fpayhx
          iv_paymedium   = i_paymedium
        CHANGING
          cs_fpayhx_fref = es_fpayhx
          ct_fpayp_fref  = t_fpayp[].
    ENDIF. "IF lo_cgi_call05 IS BOUND.

* Neu
    IF is_fpayh-srtgb IS NOT INITIAL.
      lv_gsber = is_fpayh-srtgb.
    ELSE.
      READ TABLE t_fpayp ASSIGNING <fs_fpayp> INDEX 1.
      IF sy-subrc IS INITIAL.
        lv_gsber = <fs_fpayp>-gsber.
      ENDIF.
    ENDIF.

    IF lv_gsber IS NOT INITIAL.

      SELECT * FROM /thkr/gsber_exce INTO ls_gsber_exce UP TO 1 ROWS
               WHERE gsber = lv_gsber.
      ENDSELECT.

      IF sy-subrc IS NOT INITIAL.

        SELECT gtext FROM tgsbt INTO lv_gtext UP TO 1 ROWS
                 WHERE spras  = 'D'
                 AND gsber = lv_gsber.
        ENDSELECT.

        CALL METHOD /thkr/cl_pmw_exit=>check_text
          EXPORTING
            iv_gtext = lv_gtext
          IMPORTING
            ev_gtext = lv_gtext.

        IF is_fpayh-rzawe = 'D'.           "Überweisung

          es_fpayhx-ref07(70) = lv_gtext.
          LOOP AT t_fpayp ASSIGNING <FS_fpayp>.
            <FS_fpayp>-bname = lv_gtext.
          ENDLOOP.
        ELSE.
          es_fpayhx-ref10(80) = lv_gtext.
          LOOP AT t_fpayp ASSIGNING <FS_fpayp>.
            <FS_fpayp>-bname = lv_gtext.
          ENDLOOP.
        ENDIF.
      ELSE.
        IF is_fpayh-rzawe = 'D'.           "Überweisung

          es_fpayhx-ref07(70) = lv_gtext.
          LOOP AT t_fpayp ASSIGNING <FS_fpayp>.
            <FS_fpayp>-bname = lc_lhkd.
          ENDLOOP.
        ELSE.
          es_fpayhx-ref10(80) = lc_lhkd.
          LOOP AT t_fpayp ASSIGNING <FS_fpayp>.
            <FS_fpayp>-bname = lc_lhkd.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ELSE.
      IF is_fpayh-rzawe = 'D'.           "Überweisung

        es_fpayhx-ref07(70) = lv_gtext.
        LOOP AT t_fpayp ASSIGNING <FS_fpayp>.
          <FS_fpayp>-bname = lc_lhkd.
        ENDLOOP.
      ELSE.
        es_fpayhx-ref10(80) = lc_lhkd.
        LOOP AT t_fpayp ASSIGNING <FS_fpayp>.
          <FS_fpayp>-bname = lc_lhkd.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
