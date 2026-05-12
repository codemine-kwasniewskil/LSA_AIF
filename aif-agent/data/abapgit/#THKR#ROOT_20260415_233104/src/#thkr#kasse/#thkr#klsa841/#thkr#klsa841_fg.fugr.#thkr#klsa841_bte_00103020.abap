FUNCTION /THKR/KLSA841_BTE_00103020.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_F_MHND) LIKE  MHND STRUCTURE  MHND
*"     VALUE(I_F_MHNK) LIKE  MHNK STRUCTURE  MHNK
*"     VALUE(I_F_PSKW4) LIKE  PSKW4 STRUCTURE  PSKW4
*"     VALUE(I_RFFMINTCALC) TYPE  BOOLE-BOOLE OPTIONAL
*"     VALUE(I_NOTIFY_DATE) TYPE  FM_NOTIFY_DATE OPTIONAL
*"  TABLES
*"      T_BBKPF STRUCTURE  BBKPF_FM
*"      T_BBSEG STRUCTURE  BBSEG_FM
*"      T_BBTAX STRUCTURE  BBTAX_FM
*"--------------------------------------------------------------------

  FIELD-SYMBOLS: <fs_bbkpf> TYPE bbkpf_fm.
  FIELD-SYMBOLS: <fs_bbseg> TYPE bbseg_fm.
  data: ls_bseg type bseg.
  DATA: lv_xdele.

*  if i_f_mhnd-maber = 'M8'.
*    lv_xdele = ''.
*    loop at t_bbseg assigning <fs_bbseg>.
*      if i_f_mhnk-ausdt - <fs_bbseg>-zfbdt < 30.
*        lv_xdele = 'X'.
*      endif.
*    endloop.
*    if lv_xdele = 'X'.
*        refresh t_bbkpf.
*        refresh t_bbseg.
*        refresh t_bbtax.
*        lv_xdele = ''.
*    endif.
*  endif.

  LOOP AT t_bbkpf ASSIGNING <fs_bbkpf>.
    CASE <fs_bbkpf>-blart.
      WHEN 'SG' or 'SN'.
        <fs_bbkpf>-xblnr = i_f_mhnk-cpdky.
        select single * from bseg into ls_bseg
               where bukrs = i_f_mhnd-bbukrs
                 and belnr = i_f_mhnd-belnr
                 and gjahr = i_f_mhnd-gjahr
                 and koart = 'S'.
*                 and buzei = i_f_mhnd-buzei.
        if sy-subrc = 0.

          LOOP AT t_bbseg ASSIGNING <fs_bbseg> where NEWBS = '50'.
                <fs_bbseg>-zfbdt = ls_bseg-zfbdt.
                <fs_bbseg>-kostl = ls_bseg-kostl.
*                <fs_bbseg>-maber = ls_bseg-maber.
                <fs_bbseg>-geber = ls_bseg-geber.
                <fs_bbseg>-gsber = ls_bseg-gsber.
                <fs_bbseg>-fistl = ls_bseg-fistl.
          ENDLOOP.

        endif.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.



ENDFUNCTION.
