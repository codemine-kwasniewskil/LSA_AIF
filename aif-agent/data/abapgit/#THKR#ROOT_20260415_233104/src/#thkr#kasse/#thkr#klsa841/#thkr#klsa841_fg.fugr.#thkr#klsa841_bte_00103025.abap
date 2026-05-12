FUNCTION /thkr/klsa841_bte_00103025.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_F_MHNK) LIKE  MHNK STRUCTURE  MHNK
*"     VALUE(I_F_PSKW4) LIKE  PSKW4 STRUCTURE  PSKW4
*"  TABLES
*"      T_MHND STRUCTURE  MHND
*"      T_BBKPF STRUCTURE  BBKPF_FM
*"      T_BBSEG STRUCTURE  BBSEG_FM
*"      T_BBTAX STRUCTURE  BBTAX_FM
*"----------------------------------------------------------------------

  FIELD-SYMBOLS: <fs_bbkpf> TYPE bbkpf_fm.
  FIELD-SYMBOLS: <fs_bbseg> TYPE bbseg_fm.
  data: ls_bseg type bseg.
  data: ls_bkpf type bkpf.

  LOOP AT t_bbkpf ASSIGNING <fs_bbkpf>.
    CASE <fs_bbkpf>-blart.
      WHEN 'MG' or 'MO'.    "2025-09-25 jseifert:  MO ergänzt (DF-1630)
        <fs_bbkpf>-xblnr = i_f_mhnk-cpdky.
        clear: ls_bseg, ls_bkpf.
        select single * from bkpf into ls_bkpf
               where ( blart = 'DR' or
                       blart = 'DD' or
                       blart = 'DE' or
                       blart = 'D1' or
                       blart = 'D2' or
                       blart = 'D3' or
                       blart = 'D4' )
                 and xblnr = i_f_mhnk-cpdky.
        if sy-subrc = 0.
          select single * from bseg into ls_bseg
                 where bukrs = ls_bkpf-bukrs
                   and belnr = ls_bkpf-belnr
                   and gjahr = ls_bkpf-gjahr
                   and koart = 'S'.
        endif.
        LOOP AT t_bbseg ASSIGNING <fs_bbseg> where newbs = '50'.
          if ls_bseg is not initial.
            <fs_bbseg>-zfbdt = ls_bseg-zfbdt.
            <fs_bbseg>-kostl = ls_bseg-kostl.
*            <fs_bbseg>-fkber = ls_bseg-fkber.
            <fs_bbseg>-geber = ls_bseg-geber.
            <fs_bbseg>-gsber = ls_bseg-gsber.
            <fs_bbseg>-fistl = ls_bseg-fistl.
          endif.
        ENDLOOP.

      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.



ENDFUNCTION.
