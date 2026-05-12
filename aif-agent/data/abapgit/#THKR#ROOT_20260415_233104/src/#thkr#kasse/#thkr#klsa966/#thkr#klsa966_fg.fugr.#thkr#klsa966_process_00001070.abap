FUNCTION /thkr/klsa966_process_00001070.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_AUSDT) LIKE  F150V-AUSDT
*"     VALUE(I_MHNK) LIKE  MHNK STRUCTURE  MHNK
*"     VALUE(I_MHND) LIKE  MHND STRUCTURE  MHND
*"  TABLES
*"      T_FIMSG STRUCTURE  FIMSG
*"  CHANGING
*"     VALUE(C_ZINSS) LIKE  MHND-ZINSS
*"     VALUE(C_ZINST) LIKE  MHND-ZINST
*"     VALUE(C_WZSBT) LIKE  MHND-WZSBT
*"     VALUE(C_ZSBTR) LIKE  MHND-ZSBTR
*"     VALUE(C_XZINS) LIKE  MHND-XZINS
*"----------------------------------------------------------------------

  "kLSA966 Zinskennzeichen
  DATA: ls_bkpf_int TYPE bkpf.
  DATA: ls_bseg_int TYPE bseg.
  DATA: lt_t047n TYPE TABLE OF t047n.
  DATA: ls_t047n TYPE t047n.
  DATA: lv_wzsbt LIKE mhnd_ext-wzsbt.
  DATA: lv_zsbtr LIKE mhnd_ext-zsbtr.
  DATA: h_ref1(16) TYPE p.
  DATA: h_ref2(16) TYPE p.
  DATA: lv_bdat LIKE pso02-zfbdt.
  DATA: lv_months TYPE i.
  DATA: lv_pskw5 TYPE pskw5.
  DATA: lv_betrag(15) TYPE p.

  SELECT * FROM t047n INTO TABLE lt_t047n WHERE spras = 'D'.
  SELECT SINGLE * FROM bkpf INTO ls_bkpf_int
         WHERE bukrs = i_mhnd-bbukrs
           AND belnr = i_mhnd-belnr
           AND gjahr = i_mhnd-gjahr.
*           and buzei = <fs_items>-buzei.
  SELECT SINGLE * FROM bseg INTO ls_bseg_int
         WHERE bukrs = i_mhnd-bbukrs
           AND belnr = i_mhnd-belnr
           AND gjahr = i_mhnd-gjahr
           AND buzei = i_mhnd-buzei.
  IF sy-subrc = 0.

    "Anzahl angefangener Monate berechnen
    CLEAR lv_bdat.
    CLEAR lv_months.
    lv_bdat = i_ausdt - 1.
    CALL FUNCTION 'FI_PSO_DAYS_MONTHS_YEARS_GET'
      EXPORTING
        i_date_from = i_mhnd-zfbdt
        i_date_to   = lv_bdat
      IMPORTING
*       E_DAYS      =
        e_months    = lv_months
*       E_YEARS     =
      .

    "Customizing Schonfrist etc. holen
    CLEAR lv_pskw5.
    CALL FUNCTION 'FI_PSO_PSKW5_READ'
      EXPORTING
        i_mahna   = i_mhnk-mahna
        i_waers   = i_mhnd-waers
      IMPORTING
        e_pskw5   = lv_pskw5
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    "check Nebenforderungen -> nicht verzinsen
    CASE ls_bkpf_int-blart.
      WHEN 'MG' OR 'SN' OR 'SG'.
        CLEAR c_zinst.
        CLEAR c_wzsbt.
        CLEAR c_zsbtr.
      WHEN OTHERS.

        CASE ls_bseg_int-maber.
          WHEN 'M8'.
            "check maber=M8 -> Schonfrist
            IF lv_months = 1.
              CLEAR c_zinst.
              CLEAR c_wzsbt.
              CLEAR c_zsbtr.
            ELSE.
              c_zinst = 30 * lv_months.
              CLEAR c_wzsbt.
              CLEAR c_zsbtr.
              IF lv_pskw5 IS NOT INITIAL. "aufrunden/abrunden
                lv_betrag = i_mhnd-wrshb * 100.
                PERFORM fi_pso_round_value
                  USING lv_pskw5-psorri lv_pskw5-psori
                  CHANGING lv_betrag.
              ENDIF.
              h_ref1 = lv_betrag * c_zinss * lv_months.
*              h_ref1 = h_ref1 * c_zinst.
*              h_ref2 = h_ref1 / 360.
              lv_wzsbt = h_ref1 / 10000.

              CALL FUNCTION 'ROUND_AMOUNT'
                EXPORTING
                  company    = i_mhnd-bukrs
                  currency   = i_mhnd-waers
                  amount_in  = lv_wzsbt
                IMPORTING
                  amount_out = lv_wzsbt.

              c_wzsbt = lv_wzsbt.
              c_zsbtr = lv_wzsbt.
            ENDIF.
          WHEN OTHERS.
            "check ZAO -> nur ZAO individueller Zinssatz
            READ TABLE lt_t047n INTO ls_t047n WITH KEY bukrs = ls_bseg_int-bukrs
                                                       maber = ls_bseg_int-maber.
            IF sy-subrc = 0 AND ls_t047n-text1 CS 'ZAO'.
*>>Gerdes-BTC (INS) DF-1375
* Sonderlocke wg. falscher Füllung des Zinssatzes bei Migrationsbelegen
              IF ls_bkpf_int-z_intrate IS INITIAL.
                ls_bkpf_int-z_intrate = '0'.
              ENDIF.
*<<Gerdes-BTC (INS) DF-1375

              IF ls_bkpf_int-z_intrate IS NOT INITIAL.
                REPLACE '.' IN ls_bkpf_int-z_intrate WITH ''.
                REPLACE ',' IN ls_bkpf_int-z_intrate WITH '.'.
                c_zinss = ls_bkpf_int-z_intrate.
                IF c_zinss <> 0.
                  "Zinsen berechnen (Zinssatz <> 0)
                  CLEAR c_wzsbt.
                  CLEAR c_zsbtr.
                  h_ref1 = i_mhnd-wrshb * c_zinss.
                  h_ref1 = h_ref1 * c_zinst.
                  h_ref2 = h_ref1 / 365.
                  lv_wzsbt = h_ref2 / 100.

                  CALL FUNCTION 'ROUND_AMOUNT'
                    EXPORTING
                      company    = i_mhnd-bukrs
                      currency   = i_mhnd-waers
                      amount_in  = lv_wzsbt
                    IMPORTING
                      amount_out = lv_wzsbt.

                  c_wzsbt = lv_wzsbt.
                  c_zsbtr = lv_wzsbt.
                ELSE.
                  "keine Zinsen berechnen (Zinssatz = 0)
                  CLEAR c_zinst.
                  CLEAR c_wzsbt.
                  CLEAR c_zsbtr.
                ENDIF.
              ELSE.
                "Zinsen berechnen (365 Tage)
                CLEAR c_wzsbt.
                CLEAR c_zsbtr.

                h_ref1 = i_mhnd-wrshb * c_zinss.
                h_ref1 = h_ref1 * c_zinst.
                h_ref2 = h_ref1 / 365.
                lv_wzsbt = h_ref2 / 100.

                CALL FUNCTION 'ROUND_AMOUNT'
                  EXPORTING
                    company    = i_mhnd-bukrs
                    currency   = i_mhnd-waers
                    amount_in  = lv_wzsbt
                  IMPORTING
                    amount_out = lv_wzsbt.

                c_wzsbt = lv_wzsbt.
                c_zsbtr = lv_wzsbt.

              ENDIF.
            ELSE.
              CASE ls_bseg_int-maber.
                WHEN 'P2' OR 'P3' OR 'P5'.
                  "Zinsen berechnen (365 Tage)
                  CLEAR c_wzsbt.
                  CLEAR c_zsbtr.
                  h_ref1 = i_mhnd-wrshb * c_zinss.
                  h_ref1 = h_ref1 * c_zinst.
                  h_ref2 = h_ref1 / 365.
                  lv_wzsbt = h_ref2 / 100.

                  CALL FUNCTION 'ROUND_AMOUNT'
                    EXPORTING
                      company    = i_mhnd-bukrs
                      currency   = i_mhnd-waers
                      amount_in  = lv_wzsbt
                    IMPORTING
                      amount_out = lv_wzsbt.

                  c_wzsbt = lv_wzsbt.
                  c_zsbtr = lv_wzsbt.
              ENDCASE.
            ENDIF.
        ENDCASE.
    ENDCASE.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  FI_PSO_ROUND_VALUE
*&---------------------------------------------------------------------*
*  Abbild des  Bausteines  FIMA_NUMERICAL_VALUE_ROUND
*----------------------------------------------------------------------*
*  Motivation fuer Kopie: der Originalbaustein kann keine
*  Rundungseinheiten groesser 1 verarbeiten....
*  Es wird immer der Absolutbetrag gerundet und dann das Vorzeichen
*  gesetzt, so daß betragsmaessig das gleiche Ergebnis erzielt wird
*  beim Runden von +(-)c_value
*----------------------------------------------------------------------*
FORM fi_pso_round_value USING    u_rtype  LIKE  pskw5-psorri
                                 u_runit  LIKE  pskw5-psori
                        CHANGING c_value.

  DATA: l_wrk_feld_p(16) TYPE p,
        l_modulo(16)     TYPE p,
        l_wrk_f_type     TYPE c.
  CONSTANTS: con_add_flp        TYPE p DECIMALS 11 VALUE '0.00000000001'.

  DESCRIBE FIELD c_value TYPE l_wrk_f_type.

  IF l_wrk_f_type = 'F'.
    IF u_rtype NE '+'.
      ADD con_add_flp TO c_value.
    ENDIF.
  ENDIF.

  IF u_runit = 0.

  ELSE.

    CASE u_rtype.

*      WHEN ' '.
*        l_wrk_feld_p  = c_value / u_runit.

      WHEN '1'.
*-----Aufrunden:

        l_wrk_feld_p = abs( c_value ) DIV u_runit.
        l_modulo = abs( c_value ) MOD u_runit.
        IF l_modulo <> 0.
          l_wrk_feld_p = l_wrk_feld_p + 1.
        ENDIF.
        IF c_value < 0.
          l_wrk_feld_p = - l_wrk_feld_p.
        ENDIF.

      WHEN '0'.
*-----Abrunden:

        l_wrk_feld_p = abs( c_value ) DIV u_runit.
        IF c_value < 0.
          l_wrk_feld_p = - l_wrk_feld_p.
        ENDIF.

*      WHEN OTHERS.
*        l_wrk_feld_p  = c_value / u_runit.

    ENDCASE.

    c_value = l_wrk_feld_p * u_runit.

  ENDIF.
ENDFORM.                               " FI_PSO_ROUND_VALUE
