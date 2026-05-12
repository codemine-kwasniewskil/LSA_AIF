"Name: \PR:SAPLF0KE\FO:DOCUMENT_DEFERRAL_READ\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_AO_STUNDUNG_PREFILL.
IF sy-tcode = 'F886' AND u_psotyp = '06'.

  LOOP AT c_t_pso_sum ASSIGNING FIELD-SYMBOL(<fs_pso>).
    <fs_pso>-mansp = '5'.

    IF <fs_pso>-rebzg IS NOT INITIAL AND <fs_pso>-rebzj IS NOT INITIAL
      AND <fs_pso>-rebzz IS NOT INITIAL.

      SELECT SINGLE manst FROM bseg
        INTO @DATA(lv_manst)
         WHERE belnr = @<fs_pso>-rebzg
        AND gjahr = @<fs_pso>-rebzj AND buzei = @<fs_pso>-rebzz
        AND bukrs = @<fs_pso>-bukrs.
      IF sy-subrc = 0.

        <fs_pso>-manst = lv_manst.

      ENDIF.

    ENDIF.

  ENDLOOP.

ELSEIF sy-tcode = 'F880' AND u_psotyp = '06'.

  LOOP AT c_t_pso_sum ASSIGNING <fs_pso> WHERE mansp IS NOT INITIAL.
    <fs_pso>-mansp = ' '.

    IF <fs_pso>-rebzg IS NOT INITIAL AND <fs_pso>-rebzj IS NOT INITIAL
      AND <fs_pso>-rebzz IS NOT INITIAL.

      SELECT SINGLE manst FROM bseg
        INTO @lv_manst
         WHERE belnr = @<fs_pso>-rebzg
        AND gjahr = @<fs_pso>-rebzj AND buzei = @<fs_pso>-rebzz
        AND bukrs = @<fs_pso>-bukrs.
      IF sy-subrc = 0.

        <fs_pso>-manst = lv_manst.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDIF.

ENDENHANCEMENT.
