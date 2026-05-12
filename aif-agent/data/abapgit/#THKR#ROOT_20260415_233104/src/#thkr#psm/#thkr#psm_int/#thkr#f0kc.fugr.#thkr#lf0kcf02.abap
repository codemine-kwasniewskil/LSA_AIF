*&---------------------------------------------------------------------*
*& Include          /THKR/LF0KCF02
*&---------------------------------------------------------------------*
FORM clearing_request_fill2 TABLES   c_t_bbseg       STRUCTURE bbseg_fm
                                    c_t_bbtax       STRUCTURE bbtax_fm
                                    c_t_pso         STRUCTURE pso02
                                    c_t_item        STRUCTURE pso02s
                                    c_t_pssec       TYPE fipso_bsec_tab
                           USING    u_who_activ     STRUCTURE pso43
                                    u_flg_convert   LIKE boole-boole
                                    u_activity      LIKE tact-actvt
                                    u_no_f_stat     LIKE boole-boole
                                    u_no_acc_determ LIKE boole-boole
                           CHANGING c_f_bbkpf       STRUCTURE bbkpf_fm
                                    c_f_pso         STRUCTURE pso02.

  DATA: l_t_fieldmod TYPE fipso_fieldmod OCCURS 0 WITH HEADER LINE,
        l_t_pso_old  LIKE pso02          OCCURS 0 WITH HEADER LINE,
        l_t_item_old LIKE pso02s         OCCURS 0 WITH HEADER LINE,
        l_t_payac01  LIKE payac01        OCCURS 0 WITH HEADER LINE,
        l_f_pso_save LIKE pso02,
        l_f_pso_tax  LIKE pso02,
        l_f_t001     LIKE t001.

  DATA: stabline     LIKE sy-tabix,
        l_count_sach LIKE sy-tabix,
        l_buzei      LIKE pso02-buzei,
        l_bzkey      LIKE pso02-bzkey,
        l_subrc      LIKE sy-subrc,
        l_pid_fo2(3) TYPE c.

  STATICS: s_bukrs      LIKE bbkpf-bukrs,
           s_blart      LIKE bbkpf-blart,
           s_t_fieldmod TYPE fipso_fieldmod OCCURS 0 WITH HEADER LINE.

*  GET PARAMETER ID 'FO2' FIELD L_PID_FO2.

  MOVE-CORRESPONDING: c_f_pso TO l_f_pso_save.
  l_buzei = 1.
  l_bzkey = 1.

  LOOP AT c_t_bbseg.
    l_count_sach = l_count_sach + 1.
    stabline = sy-tabix.

*   Kopfdaten werden direkt in C_T_PSO kopiert
    IF l_count_sach = 1.
      CLEAR: c_t_pso.
      MOVE-CORRESPONDING l_f_pso_save TO c_t_pso.
      MOVE: 1            TO c_t_pso-itabkey,
            1            TO c_t_pso-bzkey,
            l_buzei      TO c_t_pso-buzei,
            con_item_old TO c_t_pso-bzalt,
            char_s       TO c_t_pso-koart.
      APPEND: c_t_pso.
    ENDIF.


*   Fuer jede Sachkontenzeile die C_T_ITEM fuellen
    CLEAR: c_t_item.
    MOVE-CORRESPONDING l_f_pso_save TO c_t_item.
    MOVE-CORRESPONDING c_t_bbseg TO c_t_item.
*   some fields have different names in BSEG and VBSEG
    CALL FUNCTION 'FUNC_AREA_CONVERSION_INBOUND'
      EXPORTING
        i_func_area      = c_t_bbseg-fkber
        i_func_area_long = c_t_bbseg-fkber_long
      IMPORTING
        e_func_area_long = c_t_item-fkber.
    c_t_item-kdein = c_t_bbseg-eten2.     "Einteilungsnum
    c_t_item-kdauf = c_t_bbseg-vbel2.     "Kundenauftragsnummer
    c_t_item-kdpos = c_t_bbseg-posn2.     "Position im Kundenauftrag
    c_t_item-rmvct = c_t_bbseg-bewar.     "Bewegungsart
    c_t_item-ps_psp_pnr = c_t_bbseg-projk."Kontierung Projekt
    c_t_item-pprctr = c_t_bbseg-pprct.    "Partner-Profitcenter
    MOVE c_t_bbseg-newbs TO c_t_item-bschl.
    PERFORM conv_datformat_item
                USING       u_flg_convert
                            char_s
                            char_x
                CHANGING    c_f_bbkpf
                            c_t_bbseg
                            c_t_bbtax
                            c_t_item.

    MOVE: 1            TO c_t_item-itabkey,
          l_buzei      TO c_t_item-buzei,
          l_bzkey      TO c_t_item-bzkey,
          con_item_old TO c_t_item-bzalt.

    IF c_t_item-koart IS INITIAL.
      CALL FUNCTION 'FI_POSTING_KEY_DATA'
        EXPORTING
          i_bschl = c_t_item-bschl
          i_umskz = c_f_pso-umskz
        IMPORTING
          e_koart = c_t_item-koart
          e_shkzg = c_t_item-shkzg
        EXCEPTIONS
          OTHERS  = 1.
    ENDIF.
    "In der normalen Verarbeitung wird zwischen 1. Sachkontenzeile und weitere Unterschieden.
    "In der 1. Sachkontozeile steht der Geschäftspartner drin
    "ab der 2. Sachkontozeile stehen die richtigen Sachkonto drin.
    IF l_count_sach NE 1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = c_t_bbseg-newko
        IMPORTING
          output = c_t_bbseg-newko.

      IF c_t_bbseg-newko CO '0123456789'.
*     nur Ziffern -> letzten 10 Stellen übernehmen
        c_t_item-saknr = c_t_bbseg-newko+7(10).
      ELSE.
*     erste 10 Stellen übernehmen.
        c_t_item-saknr = c_t_bbseg-newko.
      ENDIF.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = c_t_bbseg-hkont
        IMPORTING
          output = c_t_bbseg-hkont.

      IF c_t_bbseg-hkont CO '0123456789'.
        c_t_item-saknr = c_t_bbseg-hkont.
      ENDIF.
    ENDIF.
    IF c_t_bbseg-mwskz NE space AND l_pid_fo2 EQ space.
*     tax amount field in bbtax?
      READ TABLE c_t_bbtax WITH KEY mwskz = c_t_bbseg-mwskz.


      IF sy-subrc EQ 0.
*       move tax amount to item-information:
        c_t_item-wmwst = c_t_bbtax-hwste.
        c_f_pso-psosf = c_t_bbtax-psosf.
      ELSE.
        CALL FUNCTION 'FI_COMPANY_CODE_DATA'
          EXPORTING
            i_bukrs = c_f_pso-bukrs
          IMPORTING
            e_t001  = l_f_t001.

        MOVE-CORRESPONDING c_f_pso TO l_f_pso_tax.
        l_f_pso_tax-wrbtr = c_t_item-wrbtr.
        l_f_pso_tax-dmbtr = c_t_item-dmbtr.
        l_f_pso_tax-mwskz = c_t_item-mwskz.
*       die Steuer wird aus dem Brutto-Betrag berechnet:
        PERFORM calculate_tax_from_grossamount(saplf0ka) USING
                                                     l_f_pso_tax-bukrs
                                                     l_f_pso_tax-mwskz
                                                     l_f_pso_tax-waers
                                                     l_f_pso_tax-zbd1p
                                                     l_f_pso_tax-wrbtr
                                                     l_f_pso_tax-budat
                                                     l_f_pso_tax-bldat
                                                     l_f_t001
                                               CHANGING
                                                     l_f_pso_tax-wmwst.
*       wegen neuer Waehrungsumrechnung:
        CLEAR l_f_pso_tax-dmbtr.

*       Waehrungsumrechnung, etc.:
        PERFORM currency_convert_all(saplf0ka)
                                USING u_activity
                                      l_f_pso_tax-waers
                                      l_f_pso_tax-hwaer
                                      l_f_pso_tax-budat
                                     'M'
                                CHANGING l_f_pso_tax-dmbtr
                                         l_f_pso_tax-wrbtr
                                         l_f_pso_tax-mwsts
                                         l_f_pso_tax-wwert
                                         l_f_pso_tax-kursf
                                         l_f_pso_tax-wmwst.

        DATA: lv_dmbtr TYPE dmbtr,
              lv_wrbtr TYPE wrbtr.
        lv_dmbtr = l_f_pso_tax-dmbtr.
        lv_wrbtr = l_f_pso_tax-wrbtr.
        CALL FUNCTION 'FI_PSO_AMOUNT_MOVE'
          EXPORTING
            i_f_pso = l_f_pso_tax
          CHANGING
            c_wrbtr = lv_wrbtr
            c_dmbtr = lv_dmbtr.

        l_f_pso_tax-dmbtr = lv_dmbtr.
        l_f_pso_tax-wrbtr = lv_wrbtr.

        c_t_item-wrbtr = l_f_pso_tax-wrbtr.
        c_t_item-dmbtr = l_f_pso_tax-dmbtr.
        c_t_item-wmwst = l_f_pso_tax-wmwst.


      ENDIF.
    ELSE.

*   Waehrungsumrechnung, etc.:
      PERFORM currency_convert_all(saplf0ka)
                              USING u_activity
                                    c_f_pso-waers
                                    c_f_pso-hwaer
                                    c_f_pso-budat
                                   'M'
                              CHANGING c_t_item-dmbtr
                                       c_t_item-wrbtr
                                       c_f_pso-mwsts
                                       c_f_pso-wwert
                                       c_f_pso-kursf
                                       c_f_pso-wmwst.

    ENDIF.

    PERFORM reservation_read(saplf0ka)
                            TABLES   l_t_pso_old
                                     l_t_item_old
                            USING    c_f_pso-psoty
                            CHANGING c_f_pso
                                     c_t_item.

*   set and check account
    PERFORM set_check_account USING    u_activity
                                       u_no_acc_determ
                              CHANGING c_f_pso
                                       c_t_item.

    APPEND: c_t_item.

    l_buzei = l_buzei + 1.
    l_bzkey = l_bzkey + 1.

  ENDLOOP.

*-----ABGLEICH mit Feldstatus: Mußfelder pruefen, ob gefuellt
  IF u_no_f_stat IS INITIAL.

    IF c_f_bbkpf-bukrs NE s_bukrs OR
       c_f_bbkpf-blart NE s_blart.

      s_bukrs = c_f_bbkpf-bukrs.
      s_blart = c_f_bbkpf-blart.
      REFRESH: s_t_fieldmod.

*     read field status
      PERFORM fieldstatus_get(saplf0ka)
                              TABLES s_t_fieldmod
                              USING  s_blart
                                     s_bukrs.
*     reduce field list to the mandatory fields
      DELETE s_t_fieldmod WHERE kennz NE '+'.
    ENDIF.

*   check mandatory fields
    PERFORM check_fieldstatus TABLES s_t_fieldmod
                                     c_t_pso
                                     c_t_item.
  ENDIF.

ENDFORM.                               " CLEARING_REQUEST_FILL
