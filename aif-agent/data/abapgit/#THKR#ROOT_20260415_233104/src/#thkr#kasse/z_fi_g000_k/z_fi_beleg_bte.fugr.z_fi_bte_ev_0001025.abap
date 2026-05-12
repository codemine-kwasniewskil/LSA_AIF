function z_fi_bte_ev_0001025.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BKDF) LIKE  BKDF STRUCTURE  BKDF OPTIONAL
*"  TABLES
*"      T_AUSZ1 STRUCTURE  AUSZ1 OPTIONAL
*"      T_AUSZ2 STRUCTURE  AUSZ2 OPTIONAL
*"      T_AUSZ3 STRUCTURE  AUSZ_CLR OPTIONAL
*"      T_BKP1 STRUCTURE  BKP1
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEC STRUCTURE  BSEC
*"      T_BSED STRUCTURE  BSED
*"      T_BSEG STRUCTURE  BSEG
*"      T_BSET STRUCTURE  BSET
*"      T_BSEU STRUCTURE  BSEU OPTIONAL
*"----------------------------------------------------------------------

  types: begin of t_belnr,
           bukrs type bukrs,
           gjahr type gjahr,
           belnr type belnr_d,
           buzei type buzei,
           zlspr type dzlspr,
         end of t_belnr.

  field-symbols: <f_ausz3> type ausz_clr,
                 <f_bkpf>  type bkpf.
  data: ls_belnr type t_belnr,
        lt_belnr type standard table of t_belnr,
        lt_ausz3 type standard table of ausz_clr.

*----------------------------------------------------------------------
* Tabelle für Select
*----------------------------------------------------------------------
  lt_ausz3[] =  t_ausz3[].
  delete lt_ausz3[] where koart ne c_char_d.

  describe table lt_ausz3 lines data(lv_lines).
  check lv_lines gt 0.
*----------------------------------------------------------------------
* Storno immer zulassen
*----------------------------------------------------------------------
  loop at t_bkpf assigning <f_bkpf> where xreversing = c_on.
  endloop.
  check sy-subrc ne 0.

*----------------------------------------------------------------------
*  Select auf Zahlsperre E
*----------------------------------------------------------------------
  select  bukrs, gjahr, belnr, buzei, zlspr from bseg into table @lt_belnr
    for all entries in @lt_ausz3
    where bukrs = @lt_ausz3-bukrs
      and gjahr = @lt_ausz3-gjahr
      and belnr = @lt_ausz3-belnr
      and buzei = @lt_ausz3-buzei
      and zlspr = @c_char_e.
*----------------------------------------------------------------------
*  Meldung zu Zahlsperre E
*----------------------------------------------------------------------
  describe table lt_belnr lines lv_lines.
  if lv_lines gt 0.
    message  e130 with lv_lines.
  endif.
endfunction.
