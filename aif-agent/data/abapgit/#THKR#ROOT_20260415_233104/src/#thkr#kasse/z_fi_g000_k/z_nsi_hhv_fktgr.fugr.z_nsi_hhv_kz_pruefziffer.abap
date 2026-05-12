FUNCTION Z_NSI_HHV_KZ_PRUEFZIFFER.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IM_XBLNR) TYPE  XBLNR
*"  EXPORTING
*"     VALUE(EX_PRUEFZIFFER) TYPE  N
*"----------------------------------------------------------------------


DATA: l_c12_KZ(12) TYPE C,
      l_i_zaehler  TYPE I,
      l_i_SJ       TYPE I,
      l_i_PJ       TYPE I,
      l_i_SJREST   TYPE I,
      l_n1_prfziff type n.

l_c12_KZ = im_xblnr.
l_i_zaehler = 0.

WHILE l_i_zaehler < 12.

   IF l_i_zaehler = 0.
      l_i_SJ = l_c12_KZ+l_i_zaehler(1).
      l_i_SJ = 10 + l_i_SJ.
     ELSE.
      l_i_SJ = l_c12_KZ+l_i_zaehler(1).
      l_i_SJ = l_i_PJ + l_i_SJ.
   ENDIF.

   l_i_SJREST = l_i_SJ MOD 10.

   IF l_i_SJREST = 0.
      l_i_SJREST = 10.
   ENDIF.

   l_i_PJ =  ( l_i_SJREST * 2 ) MOD 11.
   l_i_zaehler = l_i_zaehler + 1.

ENDWHILE.

if l_i_PJ <= 1.
   l_n1_prfziff = 0.
  else.
   l_n1_prfziff = 11 - l_i_PJ.
endif.

ex_PRUEFZIFFER = l_n1_prfziff.





ENDFUNCTION.
