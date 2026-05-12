function /THKR/FEB_GET_KREDIT_LINE.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BUKRS) LIKE  RF05L-BUKRS
*"     VALUE(I_BELNR) LIKE  RF05L-BELNR
*"     VALUE(I_GJAHR) LIKE  RF05L-GJAHR
*"  CHANGING
*"     REFERENCE(CT_BEL_ORIG) TYPE  ZFI_F_BELPOS_T
*"     REFERENCE(CT_ZBELEG) TYPE  ZFI_F_ZBELEG_T
*"  EXCEPTIONS
*"      NOT_FOUND
*"--------------------------------------------------------------------

*----------------------------------------------------------------------*
* Kreditor. Belegzeile für FB09 ermitteln                              *
*----------------------------------------------------------------------*
  types: begin of t_bseg,
           bukrs type bukrs,
           belnr type belnr_d,
           gjahr type gjahr,
           buzei type buzei,
           augdt type augdt,
           koart type koart,
           lifnr type lifnr,
           kunnr type kunnr,
         end of t_bseg.

  data: ls_bkpf     type bkpf,
        lt_bkpf     type table of bkpf,
        lt_bseg     type standard table of t_bseg,
        lt_bseg_k   type standard table of t_bseg,
        lt_bseg_d   type standard table of t_bseg,
        ls_bseg     type t_bseg,
        ls_bsak     type bsak,
        lt_bsak     type table of bsak,
        lv_lifnr    type bsak-lifnr,
        lv_augdt    type augdt,
        ls_bel_orig type zfi_f_belpos,
        ls_zbeleg   type zfi_f_zbeleg.

*  CLEAR:   e_bukrs, e_belnr, e_gjahr, e_buzei.
  clear ct_bel_orig[].
  refresh: lt_bseg, lt_bkpf.
  clear ct_zbeleg[].
  select single * from bkpf into ls_bkpf
                 where belnr = i_belnr
                   and bukrs = i_bukrs
                   and gjahr = i_gjahr.
  if sy-subrc = 0.
    if ls_bkpf-bvorg is initial.
      append ls_bkpf to lt_bkpf.
    else.
      select * from bkpf into table lt_bkpf
              where bvorg = ls_bkpf-bvorg.
    endif.
    if lt_bkpf[] is not initial.
      select bukrs, belnr,gjahr, buzei, augdt, koart, lifnr, kunnr  from bseg into table @lt_bseg
                for all entries in @lt_bkpf
              where belnr = @lt_bkpf-belnr
                and bukrs = @lt_bkpf-bukrs
                and gjahr = @lt_bkpf-gjahr.
    endif.
*----------------------------------------------------------------------*
* die Kontok. Zeile hat auch das Ausgleichsdatum
*----------------------------------------------------------------------*
*    LOOP AT lt_BSEG ASSIGNING FIELD-SYMBOL(<fs_bseg>) WHERE koart = 'K'.
*      e_belnr  = <fs_bseg>-belnr.
*      e_bukrs  = <fs_bseg>-bukrs.
*      e_gjahr  = <fs_bseg>-gjahr.
*      e_buzei  = <fs_bseg>-buzei.
*      lv_lifnr = <fs_bseg>-lifnr.
*      lv_augdt = <fs_bseg>-augdt.
*    ENDLOOP.
    loop at lt_bseg into ls_bseg where koart = 'K' and augdt ne lv_augdt.
      append  ls_bseg to lt_bseg_k.
    endloop.

    loop at lt_bseg into ls_bseg where koart = 'D' and augdt ne lv_augdt.
      append  ls_bseg to lt_bseg_d.
    endloop.


***    SELECT * FROM BSAK INTO TABLE lt_BSAK
***            FOR ALL ENTRIES IN lt_bseg
***            WHERE
***              bukrs = e_bukrs
***              AND LIFNR = lv_lifnr
***              and augdt = lv_augdt
***              and AUGBL = e_belnr
***              AND SHKZG = 'H'.
****----------------------------------------------------------------------*
**** Können das auch mehrere sein ?
****----------------------------------------------------------------------*
***    READ TABLE lt_BSAK INTO ls_BSAK INDEX 1.
***    IF SY-SUBRC = 0.
***      e_belnr = ls_bsak-belnr.
***      e_buzei = ls_bsak-buzei.
***    ENDIF.
***  ENDIF.

*------------------------------------------------------------
* Kreditoren "gewinnt"-> es ist nicht von D und K
* auszugehen
*------------------------------------------------------------
    if lt_bseg_k[] is not initial.
      select bukrs, belnr, gjahr, buzei, lifnr, waers, wrbtr
         from bsak into corresponding fields of table @ct_bel_orig
                  for all entries in @lt_bseg_k
                  where
                    bukrs = @lt_bseg_k-bukrs
                    and lifnr = @lt_bseg_k-lifnr
                    and augdt = @lt_bseg_k-augdt
                    and augbl = @lt_bseg_k-belnr
                    and shkzg = 'H'.
*alle Sätze bekommen die Kontoart
      ls_bel_orig-koart = 'K'.
      modify  ct_bel_orig from ls_bel_orig
      transporting koart where bukrs is not initial.
*------------------------------------------------------------
    else.
*------------------------------------------------------------
      if lt_bseg_d[] is not initial.
        select bukrs, belnr, gjahr, buzei, kunnr, waers, wrbtr
           from bsad into corresponding fields of table @ct_bel_orig
                    for all entries in @lt_bseg_d
                    where
                      bukrs = @lt_bseg_d-bukrs
                      and kunnr = @lt_bseg_d-kunnr
                      and augdt = @lt_bseg_d-augdt
                      and augbl = @lt_bseg_d-belnr
                      and shkzg = 'S'.
*alle Sätze bekommen die Kontoart
        ls_bel_orig-koart = 'D'.
        modify  ct_bel_orig from ls_bel_orig
        transporting koart where bukrs is not initial.

      endif.
*------------------------------------------------------------
    endif.
*------------------------------------------------------------
* aus allen Belegnummern, die zur Zahlung gehören, die Belegnummer
* aus Bukrs der Ursprungsbelege ermitteln
* ggf. gibt es mehrere -> dann erweitern
*------------------------------------------------------------
    loop at  ct_bel_orig into ls_bel_orig.
      loop at lt_bkpf into ls_bkpf where bukrs = ls_bel_orig-bukrs.
        move-corresponding ls_bkpf to ls_zbeleg.
        append ls_zbeleg to ct_zbeleg.
      endloop .
    endloop.
    sort ct_zbeleg.
    delete adjacent duplicates from ct_zbeleg.
*------------------------------------------------------------
  endif.
endfunction.
