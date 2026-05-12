FUNCTION /thkr/feb_set_kontierung .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_AUGLV)
*"     REFERENCE(I_FEBEP) LIKE  FEBEP STRUCTURE  FEBEP
*"     REFERENCE(I_FEBKO) LIKE  FEBKO STRUCTURE  FEBKO
*"     REFERENCE(I_AREA) TYPE  T033F-EIGR2
*"  TABLES
*"      T_FEBCL STRUCTURE  FEBCL
*"      T_FEBRE STRUCTURE  FEBRE
*"      T_FTCLEAR STRUCTURE  FTCLEAR
*"      T_FTPOST STRUCTURE  FTPOST
*"      T_FTTAX STRUCTURE  FTTAX
*"----------------------------------------------------------------------

  DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).
  DATA: lv_hkont  TYPE hkont,
        lv_count  TYPE ftpost-count,
        lv_book   TYPE t033f-attr2.

*--- 1. Ermittlung der Buchungsart aus der Kontenfindung für Buchungsbereich 1 oder 2
  SELECT SINGLE attr2 FROM t033f INTO lv_book WHERE anwnd = '0001'
                                                AND eigr1 = i_febep-vgint
                                                AND eigr2 = i_area
                                                AND eigr3 = space
                                                AND eigr4 = space.
*--- 2. Ermittlung der Buchungszeile
  CASE lv_book.
    WHEN '2'.
      lv_count = '002'.
    WHEN '1'.
      lv_count = '001'.
    WHEN OTHERS.
      lv_count = '001'.
  ENDCASE.

  lr_elko->set_ftpost_soll( EXPORTING is_febko  = i_febko
                                      is_febep  = i_febep
                            CHANGING  xt_ftpost = t_ftpost[]
                                      xv_count  = lv_count
                                      xv_hkont  = lv_hkont ).
  CHECK lv_count IS NOT INITIAL AND lv_hkont IS NOT INITIAL.
  lr_elko->set_ftpost_from_kontier_k( EXPORTING iv_bukrs  = i_febko-bukrs
                                                iv_hkont  = lv_hkont
                                                iv_count  = lv_count
                                                iv_mwskz  = 'V0'
                                      CHANGING  xt_ftpost = t_ftpost[] ).

  CLEAR: lv_count, lv_hkont.

ENDFUNCTION.
