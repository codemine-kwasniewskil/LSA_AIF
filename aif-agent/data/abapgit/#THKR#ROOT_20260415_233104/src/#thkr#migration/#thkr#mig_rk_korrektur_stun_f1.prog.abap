*----------------------------------------------------------------------*
***INCLUDE /THKR/MIG_RK_KORREKTUR_STUN_F1.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_mid_ao_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mid_ao_data .

  SELECT a~belnr,
         a~bukrs,
         a~gjahr,
         a~xblnr,
         a~rk_pos_nr,
         a~rk_pos_nr_haushaltsjahr,
         a~satz_id,
         b~satz_id as reference,
         b~sollnf,
         b~haup_nebenforderung,
         c~posnr_dkw,
         c~pos_nr
    INTO CORRESPONDING FIELDS OF TABLE @gt_data
    FROM /thkr/mig_ao_sap AS a
    INNER JOIN /thkr/migd_rkfap AS b
    ON a~xblnr = b~satz_id
    INNER JOIN /thkr/migd_rk_si AS c
    ON  c~satz_id       = b~satz_id
    AND c~rksi_position = b~pos_nr
    AND c~rksi_haujahr  = b~haushaltsjahr
    AND a~rk_pos_nr = b~pos_nr
    AND a~rk_pos_nr_haushaltsjahr = b~hAUSHALTSJAHR
    WHERE a~xblnr                 IN @so_xblnr
    AND   a~satz_id               IN @so_satz
    AND   a~haup_nebenforderung   IN @so_hf
    AND   a~belnr                 IN @so_belnr
    AND   a~bukrs                 IN @so_bukrs
    AND   c~quelle                IN @so_quell.
  IF sy-subrc NE 0 AND gv_error NE abap_true.
    MESSAGE s001(00) WITH 'Keine Daten gefunden' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_erhebenf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_erhebenf .

  IF gt_data[] IS NOT INITIAL.
    SELECT satz_id, rksi_position, rksi_haujahr, soll, posnr_dkw
      FROM /thkr/migd_rk_si
      INTO TABLE @gt_erhebe
      FOR ALL ENTRIES IN @gt_data
      WHERE pos_nr        = @gt_data-posnr_dkw
      and   satz_id       = @gt_data-reference
      AND   rksi_haujahr  = @gt_data-rk_pos_nr_haushaltsjahr
      AND   quelle = 'ERHEBENF'
      AND   haup_neben_forderung = 'N'.
  ENDIF.


ENDFORM.
