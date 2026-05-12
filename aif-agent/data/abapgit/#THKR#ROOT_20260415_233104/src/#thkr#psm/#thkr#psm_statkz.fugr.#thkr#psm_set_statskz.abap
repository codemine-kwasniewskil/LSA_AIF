FUNCTION /THKR/PSM_SET_STATSKZ.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_F_ACCIT) TYPE  ACCIT
*"  CHANGING
*"     REFERENCE(CH_FMIFIIT) TYPE  FMIFIIT
*"----------------------------------------------------------------------

DATA: ls_fmci     TYPE fmci,
        ls_fmifiit  TYPE fmifiit,
        ls_fmistorn TYPE fmifiit,
        ls_bkpf     TYPE bkpf,
        lv_knbelnr  TYPE fmifiit-knbelnr,
        lv_strblg   TYPE bkpf-stblg,
        lv_strflg   TYPE boolean.

  DATA: lr_tab      TYPE REF TO data.

  FIELD-SYMBOLS: <ft_blart_range> TYPE /THKR/T_FI_BLART.


*  "  alle Fipos, die mit 7*,8* oder 9* beginnen, brauchen nicht berücksichtigt zu werden
*  IF i_f_accit-fipos(1) CA '789'.
*    " keine weitere Verarbeitung
*    RETURN.
*  ENDIF.

*  " Belegart auf Gültigkeit prüfen über Tabelle ZTPBR_PARAM
  CALL METHOD /THKR/CL_FI_HELPER=>get_param
    EXPORTING
      iv_programm  = '/THKR/PSM_SET_STATSKZ'
      iv_fieldname = 'BLART'
      iv_entrykey  = '00000001'
    IMPORTING
      et_range     = lr_tab
    EXCEPTIONS
      no_data      = 1
      OTHERS       = 2.
  IF sy-subrc <> 0 OR lr_tab IS INITIAL.
    " keine Belegart definiert
    RETURN.
  ELSE.
    " Aufbau einer Range zur Abfrage
    ASSIGN lr_tab->* TO <ft_blart_range>.
    " Prüfung Belegart relevant
    IF i_f_accit-blart IN <ft_blart_range>.
      " Prozess wird fortgesetzt
    ELSE.
      " Belegart ist nicht relevant
      RETURN.
    ENDIF.
  ENDIF.

  IF i_f_accit-stgrd NE ''.

    " Rechnung zu Stornobeleg von FMIFIIT selektiern
    SELECT SINGLE * FROM fmifiit INTO ls_fmifiit
      WHERE knbelnr EQ i_f_accit-awref_rev
      AND   bukrs   EQ ch_fmifiit-bukrs
      AND   gjahr   EQ ch_fmifiit-gjahr.

    IF sy-subrc EQ 0 AND ls_fmifiit-stats EQ 'X'.
      " ..ja, es handelt sich um einen Rechnung mit Stornobeleg
      lv_strblg = 'X'.
      ch_fmifiit-stats = 'X'.

    ENDIF.

  ENDIF.

  " Setzen Statistik-Kennzeichen
  IF lv_strblg NE 'X'.

    " Lesen der Stammdaten der Finanzposition
    SELECT SINGLE fivor, potyp FROM fmci INTO CORRESPONDING FIELDS OF @ls_fmci
                                              WHERE fikrs = @ch_fmifiit-fikrs
                                                AND gjahr = @ch_fmifiit-gjahr
                                                AND fipex = @ch_fmifiit-fipex.

*    "Bei Belegart FS Finanzvorgang Finanzpositionstyp 30/3 direkt Statistikkennzeichen setzen
*    IF sy-subrc EQ 0 AND i_f_accit-blart EQ 'FS'
*      AND ls_fmci-potyp EQ '3' AND ls_fmci-fivor EQ '30'.
*      " setzen Statistikkennzeichen
*      ch_fmifiit-stats = 'X'.
*      EXIT.
*    ENDIF.

    " nur bei den relevanten Werttypen
    IF ch_fmifiit-wrttp EQ '54' OR ch_fmifiit-wrttp EQ '60'.

      " Prüfung der Betragsart
      CASE ch_fmifiit-btart.

        WHEN '0100' OR '0350'.

          IF ls_fmci-potyp EQ '3' AND ls_fmci-fivor EQ '30'.
            " Prüfung Betrag in Finanzkreiswährung
            IF ch_fmifiit-fkbtr > 0.
              " setzen Statistikkennzeichen
              ch_fmifiit-stats = 'X'.
            ENDIF.
          ENDIF.

        WHEN '0200' OR '0300'.

          " Lesen Haushaltsmanagement mit FI Belegnummer
          SELECT btart, stats FROM fmifiit INTO TABLE @DATA(lt_fmifiit)
                                           WHERE knbelnr EQ @ch_fmifiit-knbelnr
                                             AND gjahr   EQ @ch_fmifiit-gjahr
                                             AND fikrs   EQ @ch_fmifiit-fikrs.
          IF sy-subrc = 0.

            LOOP AT lt_fmifiit ASSIGNING FIELD-SYMBOL(<lf_fmifiit>).

              IF <lf_fmifiit>-btart EQ '0100' AND <lf_fmifiit>-stats EQ 'X'
                OR <lf_fmifiit>-btart EQ '0350' AND <lf_fmifiit>-stats EQ 'X'.
                " setzen Statistikkennzeichen
                ch_fmifiit-stats = 'X'.
              ENDIF.

            ENDLOOP.

          ENDIF.

      ENDCASE.

    ENDIF.

  ENDIF.



ENDFUNCTION.
