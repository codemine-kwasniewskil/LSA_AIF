"Name: \PR:SAPLF0KA\FO:STUNDUNG_INTEREST_CALCULATE\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_AO_STUNDUNG_ZINS_MB.
 IF sy-tcode = 'F886' AND g_psotyp = '06' and u_sav_okcode = 'INTE'.

  LOOP AT g_t_pso ASSIGNING FIELD-SYMBOL(<fs_pso>) where maber is INITIAL.

    if <fs_pso>-rebzg is not INITIAL and <fs_pso>-rebzj is NOT INITIAL
      and <fs_pso>-rebzz is not INITIAL.

      Select SINGLE maber, manst from bseg
        into @DATA(ls_mahndata)
         where belnr = @<fs_pso>-rebzg
        and gjahr = @<fs_pso>-rebzj and buzei = @<fs_pso>-rebzz
        and bukrs = @<fs_pso>-bukrs.
        if sy-subrc = 0.

          <fs_pso>-maber = ls_mahndata-maber.
          <fs_pso>-manst = ls_mahndata-manst.

          ENDIF.

      ENDIF.

  ENDLOOP.

  ENDIF.
ENDENHANCEMENT.
