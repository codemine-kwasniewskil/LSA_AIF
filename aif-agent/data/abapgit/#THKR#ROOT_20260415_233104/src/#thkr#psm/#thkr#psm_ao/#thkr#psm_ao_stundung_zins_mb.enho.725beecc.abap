"Name: \PR:SAPLF0KA\FO:DUE_DATES_GENERATE\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_AO_STUNDUNG_ZINS_MB.
IF sy-tcode = 'F886' AND u_psotyp = '06'.

  LOOP AT g_t_pso ASSIGNING FIELD-SYMBOL(<fs_pso>).

    if <fs_pso>-rebzg is not INITIAL and <fs_pso>-rebzj is NOT INITIAL
      and <fs_pso>-rebzz is not INITIAL.

      Select SINGLE manst from bseg
        into @DATA(lv_manst)
         where belnr = @<fs_pso>-rebzg
        and gjahr = @<fs_pso>-rebzj and buzei = @<fs_pso>-rebzz
        and bukrs = @<fs_pso>-bukrs.
        if sy-subrc = 0.

          <fs_pso>-manst = lv_manst.

          ENDIF.

      ENDIF.

  ENDLOOP.

ENDIF.
ENDENHANCEMENT.
