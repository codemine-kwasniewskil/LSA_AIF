FUNCTION Z_FI_BTE_AU_0001120.
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
*2000001868_220_B437 >>
DATA: ls_bkpf    TYPE bkpf,
      l_zz_bktxt TYPE bktxt.
FIELD-SYMBOLS: <bkpf_subst> TYPE bkpf_subst.
*---------------------------------------------------------------------
*Übernahme Belegkopftextes (aus Quell-Zahlung) in einen Ausgleichbeleg
*siehe auch 00000900 bzw. 00000940 zur Belegung der MEM-IDs
* --> wird aus Z_BTE_00001120_FI_BELEG_ADD_ON gerufen, da 1120 schon belegt
* --------------------------------------------------------------------

* Holen der Memory ID
  CLEAR: l_zz_bktxt.
  IMPORT l_zz_bktxt FROM MEMORY ID 'ZZ_MEM_BKTXT'.
  FREE MEMORY ID 'ZZ_MEM_BKTXT'.

* Prüfung, ob Voraussetzungen erfüllt sind
  READ TABLE t_bkpf INDEX 1 INTO ls_bkpf.
  IF sy-subrc = 0 AND ls_bkpf-blart = 'AB'
     AND ( ls_bkpf-bktxt = 'Ausgleichsbeleg' OR ls_bkpf-bktxt IS INITIAL ) .
*     Bearbeitung Belegkopftext
      IF l_zz_bktxt IS NOT INITIAL.
        LOOP AT t_bkpfsub ASSIGNING <bkpf_subst>.
          <bkpf_subst>-bktxt = l_zz_bktxt.
        ENDLOOP.
      ENDIF.
  ENDIF.
* >> 2000001868_220_B437
ENDFUNCTION.
