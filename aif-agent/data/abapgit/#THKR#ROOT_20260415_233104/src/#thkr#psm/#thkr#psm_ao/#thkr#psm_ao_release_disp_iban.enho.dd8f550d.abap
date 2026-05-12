"Name: \FU:FI_PSO_PSOWF_FILL\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_AO_RELEASE_DISP_IBAN.
"Befüllen der IBAN in der Ausgabestruktur abhängig vom Partnerbanktyp des KREDITOR/DEBITOR

TYPES: BEGIN OF lty_bank,
         banks TYPE bu_banks,
         bankl TYPE bu_bankk,
         bankn TYPE bu_bankn,
       END OF lty_bank.
DATA: ls_bank         TYPE lty_bank,
      lv_iban         TYPE iban,
      lv_gp           TYPE bu_partner,
      l_t_bkpf_temp   LIKE bkpf        OCCURS 0 WITH HEADER LINE,
      l_t_bseg_temp   LIKE bseg        OCCURS 0 WITH HEADER LINE,
      l_t_fvbkpf_TEMP LIKE fvbkpf      OCCURS 0 WITH HEADER LINE,
      l_t_fvbsec_temp LIKE fvbsec      OCCURS 0 WITH HEADER LINE,
      l_t_fvbseg_temp LIKE fvbseg      OCCURS 0 WITH HEADER LINE,
      l_t_fvbset_temp LIKE fvbset      OCCURS 0 WITH HEADER LINE.

IF i_recurring EQ char_x.
  LOOP AT t_psowf ASSIGNING FIELD-SYMBOL(<fs_psowf>).
    IF <fs_psowf>-pyiban IS INITIAL.
      READ TABLE l_t_fvbseg WITH KEY belnr = <fs_psowf>-belnr
      ASSIGNING FIELD-SYMBOL(<fs_bseg>).
      IF sy-subrc = 0.

        IF <fs_bseg>-bvtyp IS NOT INITIAL.
          CLEAR lv_gp.
          IF <fs_psowf>-lifnr IS NOT INITIAL.
            lv_gp = <fs_psowf>-lifnr.
          ELSEIF <fs_psowf>-kunnr IS NOT INITIAL.
            lv_gp = <fs_psowf>-lifnr.
          ENDIF.
          IF lv_gp IS INITIAL.
            CONTINUE.
          ENDIF.
          CLEAR lv_iban.
          SELECT SINGLE iban FROM but0bk
            INTO @lv_iban
            WHERE partner = @lv_gp
            AND bkvid = @<fs_bseg>-bvtyp.
          IF lv_iban IS INITIAL.
            CLEAR ls_bank.
            SELECT SINGLE banks, bankl, bankn FROM but0bk
          INTO @ls_bank
          WHERE partner = @lv_gp
          AND bkvid = @<fs_bseg>-bvtyp.
            IF ls_bank IS NOT INITIAL.

              CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
                EXPORTING
                  i_bank_account = ls_bank-bankn
*                 I_BANK_CONTROL_KEY       = ' '
                  i_bank_country = ls_bank-banks
                  i_bank_number  = ls_bank-bankl
                  i_bank_key     = ls_bank-bankl
                IMPORTING
                  e_iban         = lv_iban
                EXCEPTIONS
                  no_conversion  = 1
                  OTHERS         = 2.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.


        IF lv_iban IS NOT INITIAL.
          <fs_psowf>-pyiban = lv_iban.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ELSE.

  CLEAR: l_t_bkpf, l_t_bseg,l_t_fvbset,
  l_t_fvbseg, l_t_fvbsec, l_t_fvbkpf,
  l_t_bkpf[], l_t_bseg[], l_t_fvbset[],
  l_t_fvbseg[], l_t_fvbsec[], l_t_fvbkpf[].
  LOOP AT t_fikey.
    IF t_fikey-bstat EQ con_bstat_pp.
      CLEAR: l_t_fvbkpf_temp, l_t_fvbsec_temp, l_t_fvbseg_temp, l_t_fvbset_TEMP.
      CLEAR: l_t_fvbkpf_temp[], l_t_fvbsec_temp[], l_t_fvbseg_temp[], l_t_fvbset_TEMP[].
      CALL FUNCTION 'PRELIMINARY_POSTING_DOC_READ'
        EXPORTING
          belnr   = t_fikey-belnr
          bukrs   = t_fikey-bukrs
          gjahr   = t_fikey-gjahr
        TABLES
          t_vbkpf = l_t_fvbkpf_temp
          t_vbsec = l_t_fvbsec_temp
          t_vbseg = l_t_fvbseg_temp
          t_vbset = l_t_fvbset_TEMP.

      APPEND LINES OF l_t_fvbkpf_temp TO l_t_fvbkpf.
      APPEND LINES OF l_t_fvbsec_temp TO l_t_fvbsec.
      APPEND LINES OF l_t_fvbseg_temp TO l_t_fvbseg.
      APPEND LINES OF l_t_fvbset_temp TO l_t_fvbset.

    ELSE.

      CLEAR: l_t_bkpf_temp, l_t_bseg_temp.
      CLEAR: l_t_bkpf_temp[], l_t_bseg_temp[].

      CALL FUNCTION 'FI_DOCUMENT_READ'
        EXPORTING
          i_bukrs = t_fikey-bukrs
          i_belnr = t_fikey-belnr
          i_gjahr = t_fikey-gjahr
        TABLES
          t_bkpf  = l_t_bkpf_temp
          t_bseg  = l_t_bseg_temp.

      APPEND LINES OF l_t_bkpf_temp TO l_t_bkpf.
      APPEND LINES OF l_t_bseg_temp TO l_t_bseg.

    ENDIF.
  ENDLOOP.

  IF l_t_fvbseg[] IS NOT INITIAL.
    LOOP AT t_psowf ASSIGNING <fs_psowf>.
      IF <fs_psowf>-pyiban IS INITIAL.
        """""""""
        READ TABLE l_t_fvbseg WITH KEY belnr = <fs_psowf>-belnr
        ASSIGNING <fs_bseg>.
        IF sy-subrc = 0.

          IF <fs_bseg>-bvtyp IS NOT INITIAL.
            CLEAR lv_gp.
            IF <fs_psowf>-lifnr IS NOT INITIAL.
              lv_gp = <fs_psowf>-lifnr.
            ELSEIF <fs_psowf>-kunnr IS NOT INITIAL.
              lv_gp = <fs_psowf>-lifnr.
            ENDIF.
            IF lv_gp IS INITIAL.
              CONTINUE.
            ENDIF.
            CLEAR lv_iban.
            SELECT SINGLE iban FROM but0bk
              INTO @lv_iban
              WHERE partner = @lv_gp
              AND bkvid = @<fs_bseg>-bvtyp.
            IF lv_iban IS INITIAL.
              CLEAR ls_bank.
              SELECT SINGLE banks, bankl, bankn FROM but0bk
            INTO @ls_bank
            WHERE partner = @lv_gp
            AND bkvid = @<fs_bseg>-bvtyp.
              IF ls_bank IS NOT INITIAL.

                CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
                  EXPORTING
                    i_bank_account = ls_bank-bankn
*                   I_BANK_CONTROL_KEY       = ' '
                    i_bank_country = ls_bank-banks
                    i_bank_number  = ls_bank-bankl
                    i_bank_key     = ls_bank-bankl
                  IMPORTING
                    e_iban         = lv_iban
                  EXCEPTIONS
                    no_conversion  = 1
                    OTHERS         = 2.
                IF sy-subrc <> 0.
* Implement suitable error handling here
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.


          IF lv_iban IS NOT INITIAL.
            <fs_psowf>-pyiban = lv_iban.
          ENDIF.
        ENDIF.

        """""""""""
      ENDIF.
    ENDLOOP.
  ELSEIF l_t_bseg[] IS NOT INITIAL.
    """""""""""

    LOOP AT t_psowf ASSIGNING <fs_psowf>.
      IF <fs_psowf>-pyiban IS INITIAL.

        READ TABLE l_t_bseg WITH KEY belnr = <fs_psowf>-belnr
        ASSIGNING FIELD-SYMBOL(<fs_bseg2>).
        IF sy-subrc = 0.

          IF <fs_bseg2>-bvtyp IS NOT INITIAL.
            CLEAR lv_gp.
            IF <fs_psowf>-lifnr IS NOT INITIAL.
              lv_gp = <fs_psowf>-lifnr.
            ELSEIF <fs_psowf>-kunnr IS NOT INITIAL.
              lv_gp = <fs_psowf>-lifnr.
            ENDIF.
            IF lv_gp IS INITIAL.
              CONTINUE.
            ENDIF.
            CLEAR lv_iban.
            SELECT SINGLE iban FROM but0bk
              INTO @lv_iban
              WHERE partner = @lv_gp
              AND bkvid = @<fs_bseg2>-bvtyp.
            IF lv_iban IS INITIAL.
              CLEAR ls_bank.
              SELECT SINGLE banks, bankl, bankn FROM but0bk
            INTO @ls_bank
            WHERE partner = @lv_gp
            AND bkvid = @<fs_bseg2>-bvtyp.
              IF ls_bank IS NOT INITIAL.

                CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
                  EXPORTING
                    i_bank_account = ls_bank-bankn
*                   I_BANK_CONTROL_KEY       = ' '
                    i_bank_country = ls_bank-banks
                    i_bank_number  = ls_bank-bankl
                    i_bank_key     = ls_bank-bankl
                  IMPORTING
                    e_iban         = lv_iban
                  EXCEPTIONS
                    no_conversion  = 1
                    OTHERS         = 2.
                IF sy-subrc <> 0.
* Implement suitable error handling here
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.


          IF lv_iban IS NOT INITIAL.
            <fs_psowf>-pyiban = lv_iban.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDLOOP.
    """""""""
  ENDIF.
ENDIF.


ENDENHANCEMENT.
