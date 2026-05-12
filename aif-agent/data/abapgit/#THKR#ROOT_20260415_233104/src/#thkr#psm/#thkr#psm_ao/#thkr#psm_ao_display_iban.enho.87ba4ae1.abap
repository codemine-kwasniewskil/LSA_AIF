"Name: \PR:SAPLF0KA\FO:PSO02_FILL\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_AO_DISPLAY_IBAN.
DATA: lv_iban_str TYPE string.
IF c_pso02-bnkid IS INITIAL.
  IF c_pso02-lifnr IS NOT INITIAL.
    SELECT SINGLE iban FROM but0bk
      INTO @DATA(lv_iban)
      WHERE partner = @c_pso02-lifnr
      AND bkvid = @c_pso02-bvtyp.
*    IF sy-subrc = 0.
*      lv_iban_str = |IBAN: { lv_iban }|.
*      c_pso02-bnkid = lv_iban_str.
*    ENDIF.
    IF lv_iban IS INITIAL.
      SELECT SINGLE banks, bankl, bankn FROM but0bk
    INTO @DATA(ls_bank)
    WHERE partner = @c_pso02-lifnr
    AND bkvid = @c_pso02-bvtyp.
      IF ls_bank IS NOT INITIAL.

        CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
          EXPORTING
            i_bank_account = ls_bank-bankn
*           I_BANK_CONTROL_KEY       = ' '
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
    IF lv_iban IS NOT INITIAL.
      lv_iban_str = |IBAN: { lv_iban }|.
      c_pso02-bnkid = lv_iban_str.
    ENDIF.
  ELSEIF c_pso02-kunnr IS NOT INITIAL.
    SELECT SINGLE iban FROM but0bk
     INTO @lv_iban
     WHERE partner = @c_pso02-kunnr
        AND bkvid = @c_pso02-bvtyp.
    IF lv_iban IS INITIAL.
      SELECT SINGLE banks, bankl, bankn FROM but0bk
    INTO @ls_bank
    WHERE partner = @c_pso02-kunnr
    AND bkvid = @c_pso02-bvtyp.
      IF ls_bank IS NOT INITIAL.

        CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
          EXPORTING
            i_bank_account = ls_bank-bankn
*           I_BANK_CONTROL_KEY       = ' '
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
    IF lv_iban IS NOT INITIAL.
      lv_iban_str = |IBAN: { lv_iban }|.
      c_pso02-bnkid = lv_iban_str.
    ENDIF.
  ENDIF.
ENDIF.
ENDENHANCEMENT.
