"Name: \PR:SAPLKKHI\FO:SAVE_HIERARCHY\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_ERW_SAVE_HIERACHY.
Data: lv_actvt Type activ_auth.
  " KAH1/2/3 and KDH1/2/3
  IF sy-tcode CP 'KAH+' or sy-tcode CP 'KDH+'.
    LOOP AT global_nodes ASSIGNING FIELD-SYMBOL(<fs_global_node>) WHERE action NE space.
      IF global_mode    EQ '01' OR
       ( global_mode    EQ '02' AND
<fs_global_node>-action EQ 'N' ).
        lv_actvt = '01'.
      ELSEIF global_mode EQ '02' AND <fs_global_node>-action EQ 'U'.
        lv_actvt = '02'.
      ELSE.
        CONTINUE.
      ENDIF.
       AUTHORITY-CHECK OBJECT 'Z_CSKA_SET'
        ID 'KOSTL' FIELD <fs_global_node>-setid+8
        ID 'ACTVT' FIELD lv_actvt.
      IF sy-subrc <> 0.
        CASE lv_actvt.
          WHEN '01'.
            " Anlegen
            MESSAGE e000(/THKR/RUB_MESSG) WITH <fs_global_node>-shortname.
          WHEN '02'.
            " Ändern
            MESSAGE e001(/THKR/RUB_MESSG) WITH <fs_global_node>-shortname.
        ENDCASE.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDENHANCEMENT.
