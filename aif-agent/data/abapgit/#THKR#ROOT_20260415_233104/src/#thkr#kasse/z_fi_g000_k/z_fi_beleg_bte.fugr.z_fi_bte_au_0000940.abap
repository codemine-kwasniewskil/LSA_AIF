FUNCTION Z_FI_BTE_AU_0000940.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_RF05A) LIKE  RF05A STRUCTURE  RF05A
*"  TABLES
*"      T_BKPF STRUCTURE  BKPF
*"      T_POSTAB STRUCTURE  RFOPS
*"      T_RSGTAB STRUCTURE  IRSGTAB OPTIONAL
*"  EXCEPTIONS
*"      CANCEL
*"----------------------------------------------------------------------
*2000001868_220_B437 >>
DATA: ls_postab  TYPE rfops,
      l_zz_bktxt TYPE bktxt.
* Belegkopftext zum Erhalt des ELKO-Bezugs aus Quellzahlung übernehmen
  LOOP AT t_postab INTO ls_postab
        WHERE xaktp = 'X'
          AND koart = 'D'
          AND bschl = '19'.
    SELECT SINGLE bktxt INTO l_zz_bktxt
      FROM bkpf
      WHERE bukrs = ls_postab-bukrs
        AND belnr = ls_postab-belnr
        AND gjahr = ls_postab-gjahr.
  ENDLOOP.

  IF l_zz_bktxt NE space.
    EXPORT l_zz_bktxt TO MEMORY ID 'ZZ_MEM_BKTXT'.
  ENDIF.
* >> 2000001868_220_B437
ENDFUNCTION.
