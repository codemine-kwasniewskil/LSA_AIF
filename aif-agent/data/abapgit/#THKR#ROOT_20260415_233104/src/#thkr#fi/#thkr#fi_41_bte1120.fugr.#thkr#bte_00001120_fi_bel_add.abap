FUNCTION /thkr/bte_00001120_fi_bel_add.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BKDF) TYPE  BKDF OPTIONAL
*"  TABLES
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEG STRUCTURE  BSEG
*"      T_BKPFSUB STRUCTURE  BKPF_SUBST
*"      T_BSEGSUB STRUCTURE  BSEG_SUBST
*"      T_BSEC STRUCTURE  BSEC OPTIONAL
*"  CHANGING
*"     REFERENCE(I_BKDFSUB) TYPE  BKDF_SUBST OPTIONAL
*"----------------------------------------------------------------------

  CALL FUNCTION '/THKR/WF_4A_PROCESS_BTE1120'
    EXPORTING
      i_bkdf    = i_bkdf
    tables
      t_bkpf    = t_bkpf
      t_bseg    = t_bseg
      t_bkpfsub = t_bkpfsub
      t_bsegsub = t_bsegsub
      t_bsec    = t_bsec
    CHANGING
      i_bkdfsub = i_bkdfsub
      .


  CALL FUNCTION '/THKR/BP_PROCESS_BTE1120'
*   EXPORTING
*     I_BKDF          =
    TABLES
      t_bkpf          = t_bkpf
      t_bseg          = t_bseg
*     T_BKPFSUB       =
*     T_BSEGSUB       =
*     T_BSEC          =
*   CHANGING
*     I_BKDFSUB       =
            .





ENDFUNCTION.
