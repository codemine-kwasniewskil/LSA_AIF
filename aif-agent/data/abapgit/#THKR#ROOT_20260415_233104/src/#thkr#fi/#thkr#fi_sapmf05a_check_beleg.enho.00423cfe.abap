"Name: \PR:SAPMF05A\FO:PAI_STORNOBELEG_ERZEUGEN\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/FI_SAPMF05A_CHECK_BELEG.
*
  " Prüfung bei Stornoprozess ob der Beleg laut Tabelle ZFI_Storno
  " stornorelevant ist                       " ZHM000000038 - 24.06.2024
  DATA: lv_belnr    TYPE belnr_d,
        lv_subrc    TYPE subrc,
        ls_tpbr_par TYPE /THKR/c_tpbr_par.


  " Ausnahme für User die direkt storniern dürfen  " REPRO-GANZ12102023
  DATA(lv_isallowed) = /THKR/cl_fi_helper=>check_auth_storno( iv_modul = 'FI' ).

  IF sy-tcode = 'FB08' AND sy-ucomm <> 'KA'.   " Anzeigen vor Storno

    DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).
    CASE lv_object_fica.
      WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

        CALL FUNCTION '/THKR/CHECK_FICA_UTK'
          EXPORTING
            activity = 'ZK'
          IMPORTING
            ex_subrc = lv_subrc.

      WHEN OTHERS.

        CALL FUNCTION 'Z_CHECK_FICA_TRG'
          EXPORTING
            activity = 'ZK'
          IMPORTING
            ex_subrc = lv_subrc.

    ENDCASE.

    "Wenn Berechtigung auf Aktivität 'ZK', dann darf ohne 4AP storniert werden.
    IF lv_subrc <> 0.
      " Prüfung gilt nicht für Notfalluser
      IF sy-uname(3) <> 'NFU' AND lv_isallowed NE 'X'.  " REPRO-GANZ12102023
        lv_belnr = rf05a-belns.
        " Prüfung Beleg
        CALL METHOD /THKR/cl_fi_helper=>check_zfi_storno
          EXPORTING
            iv_modul               = 'FI'
            iv_belnr               = lv_belnr
            iv_bukrs               = bkpf-bukrs
            iv_gjahr               = rf05a-gjahs
          EXCEPTIONS
            bukrs_fehlt            = 1
            gjahr_fehlt            = 2
            beleg_nicht_in_tabelle = 3
            storno_lt_status_nok   = 4
            recnnr_fehlt           = 5
            belnr_fehlt            = 6
            OTHERS                 = 7.
        CASE sy-subrc.
          WHEN 0.
            " Storno kann durchgeführt werden
          WHEN 1.
            MESSAGE e383(/thkr/fi_wf_bkpf).
          WHEN 2.
            MESSAGE e381(/thkr/fi_wf_bkpf).
          WHEN 3.
            MESSAGE e379(/thkr/fi_wf_bkpf).
          WHEN 4.
            MESSAGE e380(/thkr/fi_wf_bkpf).
          WHEN 5.
            MESSAGE e392(/thkr/fi_wf_bkpf).
          WHEN 6.
            MESSAGE e393(/thkr/fi_wf_bkpf).
          WHEN OTHERS.
            MESSAGE e384(/thkr/fi_wf_bkpf).
        ENDCASE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDENHANCEMENT.
