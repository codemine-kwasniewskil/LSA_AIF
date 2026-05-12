FUNCTION /THKR/PROCESS_00001060.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_MHND) LIKE  MHND STRUCTURE  MHND
*"     VALUE(I_MAHNA) LIKE  MHNK-MAHNA
*"     VALUE(I_AUSDT) LIKE  MHNK-AUSDT OPTIONAL
*"  TABLES
*"      T_FIMSG STRUCTURE  FIMSG
*"      T_T047B STRUCTURE  T047B OPTIONAL
*"  CHANGING
*"     VALUE(C_XFAEL) LIKE  MHND-XFAEL
*"     VALUE(C_XZALB) LIKE  MHND-XZALB
*"     VALUE(C_MANSP) LIKE  MHND-MANSP
*"     VALUE(C_FAEDT) LIKE  MHND-FAEDT OPTIONAL
*"     VALUE(C_VERZN) LIKE  MHND-VERZN OPTIONAL
*"----------------------------------------------------------------------

if i_mhnd-ZLSCH = 'E' and c_xzalb = 'X'.
  clear c_xzalb.
endif.



ENDFUNCTION.
