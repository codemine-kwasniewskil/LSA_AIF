FUNCTION /thkr/fi_bte_process_00107050 .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BELNR) LIKE  KBLE-BELNR OPTIONAL
*"     VALUE(I_BLPOS) LIKE  KBLE-BLPOS OPTIONAL
*"     VALUE(I_BPENT) LIKE  KBLE-BPENT OPTIONAL
*"     VALUE(I_BKPF) LIKE  BKPF STRUCTURE  BKPF OPTIONAL
*"  TABLES
*"      T_BSEG STRUCTURE  BSEG OPTIONAL
*"      T_BSEC STRUCTURE  BSEC OPTIONAL
*"      T_BSET STRUCTURE  BSET OPTIONAL
*"      T_BBKPF STRUCTURE  BBKPF_FM OPTIONAL
*"      T_BBSEG STRUCTURE  BBSEG_FM OPTIONAL
*"      T_BBTAX STRUCTURE  BBTAX_FM OPTIONAL
*"--------------------------------------------------------------------
  LOOP AT t_bbkpf ASSIGNING FIELD-SYMBOL(<ls_bkpf>).
    CLEAR: <ls_bkpf>-xmwst.
  ENDLOOP.

  "** Store VM für F8Q9 processing in FI_PSO_FI_HEADER_FILL Enhancement!
  /thkr/cl_data_store=>get( 'SSTF8Q9' )->set_attr( key = 'VE_NO' value = CONV #( i_belnr ) ).

ENDFUNCTION.
