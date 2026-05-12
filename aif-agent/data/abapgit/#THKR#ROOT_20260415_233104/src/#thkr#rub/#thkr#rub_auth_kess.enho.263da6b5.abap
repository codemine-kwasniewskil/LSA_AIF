"Name: \PR:SAPLKESS\FO:SS_200_SAVE_SCR\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_AUTH_KESS.
    DATA: lv_aktvt TYPE char1 VALUE 'N'.
    IF gs_screen-user_spec IS NOT INITIAL.
      MESSAGE I108(/THKR/RUB_MESSG).
      RETURN.
    endif.
    SELECT SINGLE mandt FROM TKESS_SCR INTO @Data(dummy)
      WHERE PRGNAME   = @GS_SCR-PRGNAME AND
            TABNAME   = @GS_SCR-TABNAME AND
            SCRNAME   = @GS_SCREEN-SCRNAME.
    IF sy-subrc = 0.
      lv_aktvt = 'C'.
    ENDIF.
    IF GS_SCREEN-SCRNAME IS INITIAL.
      MESSAGE I383(G0) WITH 'Name'(103).
      RETURN.
    ENDIF.
      /thkr/cl_auth_variants=>rep_auth_check(
        EXPORTING
          iv_variant     = CONV #( gs_screen-scrname )
          iv_aktvt       = 'N'
        EXCEPTIONS
          not_authorized = 1          " Keine Berechtigung
      ).
    IF sy-subrc = 1.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      RETURN.
    ENDIF.
ENDENHANCEMENT.
