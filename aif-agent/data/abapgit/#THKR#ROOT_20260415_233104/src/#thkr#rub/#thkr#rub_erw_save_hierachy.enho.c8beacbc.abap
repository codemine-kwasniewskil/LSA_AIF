"Name: \PR:SAPLKKHI\FO:AUTHORITY\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_ERW_SAVE_HIERACHY.
DATA: l_actvt_TEMP  LIKE tact-actvt.

IF sy-tcode CP 'KAH+' OR sy-tcode CP 'KDH+'.

  IF p_class <> gsetc_temporary_setclass.

    IF p_class <> gsetc_fisl_setclass.
      CASE p_mode.
        WHEN show.
          l_actvt_TEMP = show.
        WHEN delmode.
          IF saknr_class CS p_class OR
             p_class = gsetc_costcenter_setclass OR
             p_class = gsetc_profitcenter_setclass OR
             p_class = gsetc_activity_setclass.
            l_actvt_TEMP = delmode.
          ELSE.
            l_actvt_TEMP = change.
          ENDIF.
        WHEN create.
          l_actvt_TEMP = create.
        WHEN OTHERS.
          IF ( saknr_class CS p_class OR
               p_class = gsetc_costcenter_setclass OR
               p_class = gsetc_profitcenter_setclass OR
               p_class = gsetc_activity_setclass ) AND
               fcode = 'MDEL' .
            l_actvt_TEMP = delmode.
          ELSE.
            l_actvt_TEMP = change.
          ENDIF.
      ENDCASE.
    ENDIF.


    AUTHORITY-CHECK OBJECT 'Z_CSKA_SET'
     ID 'ACTVT' FIELD l_actvt_TEMP
     ID 'KOSTL' FIELD p_name+8.
    IF sy-subrc <> 0.
      CASE l_actvt_temp.
        WHEN delmode.
          MESSAGE s002(/thkr/rub_messg) WITH p_name+8 DISPLAY LIKE 'E'.
        WHEN change.
          MESSAGE s001(/thkr/rub_messg) WITH p_name+8 DISPLAY LIKE 'E'.
        WHEN show.
          MESSAGE s003(/thkr/rub_messg) WITH p_name+8 DISPLAY LIKE 'E'.
        WHEN OTHERS.

      ENDCASE.
      LEAVE TO SCREEN sy-dynnr.
    ENDIF.

  ENDIF.
ENDIF.
ENDENHANCEMENT.
