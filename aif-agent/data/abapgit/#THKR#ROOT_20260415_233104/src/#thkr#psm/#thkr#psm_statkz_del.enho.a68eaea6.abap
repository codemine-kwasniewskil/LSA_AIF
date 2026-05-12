"Name: \PR:SAPLFMPU_R\FO:CREATE_REDU_PAID_ITEMS\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_STATKZ_DEL.

"Löschen des Statistikkennzeichens - EOL-043
*  DATA: lr_tab TYPE REF TO data.
*
*  FIELD-SYMBOLS: <ft_blart_range> TYPE zfi_blart_t.
*
*
*  " Belegart auf Gültigkeit prüfen über Tabelle ZTPBR_PARAM
*  CALL METHOD zcl_tpbr_helper=>get_param
*    EXPORTING
*      iv_programm  = 'Z_TPBR_SET_STATSKZ'
*      iv_fieldname = 'BLART'
*      iv_entrykey  = '00000001'
*    IMPORTING
*      et_range     = lr_tab
*    EXCEPTIONS
*      no_data      = 1
*      OTHERS       = 2.
*  IF sy-subrc = 0 AND lr_tab IS NOT INITIAL.
*    " Aufbau einer Range zur Abfrage
*    ASSIGN lr_tab->* TO <ft_blart_range>.
*    " Prüfung Belegart relevant
*    IF u_t_accit_spl-blart IN <ft_blart_range>.
      " Erweiterung, dass bei Werttyp 57 kein Statistikkennzeichen gesetzt wird
      LOOP AT c_t_fmifiit ASSIGNING FIELD-SYMBOL(<ls_fmifiit>) WHERE wrttp = wrttp9.   " 57
        " Statistikkennzeichen wird geleert
        CLEAR <ls_fmifiit>-stats.
      ENDLOOP.
*    ENDIF.
*  ENDIF.
ENDENHANCEMENT.
