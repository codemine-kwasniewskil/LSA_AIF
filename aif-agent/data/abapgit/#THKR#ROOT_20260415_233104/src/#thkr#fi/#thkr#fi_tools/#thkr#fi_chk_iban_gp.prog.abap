*&---------------------------------------------------------------------*
*& Report /THKR/FI_CHK_IBAN_GP                                         *
*&---------------------------------------------------------------------*
*& Beschreibung:                                                       *
*&                                                                     *
*& Bei der Übernahme von Datenlieferungen aus Fachvorverfahren werden  *
*& Auszahlungsanordnungen erstellt. Diese haben in der Regel eine      *
*& Angabe des Zahlungsempfängers. Bei wiederholter Verwendung des      *
*& Zahlungsempfängers kann es vorkommen, daß abweichende Kontoinforma- *
*& tionen verwendet werden. Für die Auswertung der bei der anstehenden *
*& Zahlung verwendeten Zahlungsempfänger - IBAN ist dieser Bericht vor-*
*& gesehen.                                                            *
*&                                                                     *
*& Notwendige Tabelle:                                                 *
*&    - BKPF                                                           *
*&    - BSWG                                                           *
*&    - /THKR/GPSSTTXT                                                 *
*&    - BUT000                                                         *
*&    - BUT0BK                                                         *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:       Frank Brähler (Orexes GmbH)                            *
*& Anlage:      21.01.2026                                             *
*& Transaktion: /THKR/ZIBAN_CHK                                        *
*&                                                                     *
*& Änderer:     Frank Brähler                                          *
*& l.Datum:     05.02.2026                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/fi_chk_iban_gp.

************************************************************************
* TOP - Include für Datendeklarationen                                 *
************************************************************************
INCLUDE /thkr/fi_chk_iban_gp_top.

************************************************************************
* Selektionsscreen                                                     *
************************************************************************
INCLUDE /thkr/fi_chk_iban_gp_scr.

************************************************************************
* Programm-Klassen Definition                                          *
************************************************************************
INCLUDE /thkr/fi_chk_iban_gp_cla.

************************************************************************
* Initialisierung des Programms                                        *
************************************************************************
INITIALIZATION.
************************************************************************
* Initialisierung Selektions-Title                                     *
************************************************************************
  a1_titel = TEXT-t01.
  p_gjahr  = sy-datum+0(4).
  p_cpudt  = sy-datum - 1.

************************************************************************
* Vorbelegung der Belegart für den Selektons-Screen                    *
************************************************************************
  CLEAR: gra_blart[].
  gsa_blart-sign   = 'I'.
  gsa_blart-option = 'EQ'.
  gsa_blart-low    = 'K1'.
  APPEND gsa_blart TO so_blart.
  gsa_blart-low    = 'K2'.
  APPEND gsa_blart TO so_blart.
  gsa_blart-low    = 'K3'.
  APPEND gsa_blart TO so_blart.
  gsa_blart-low    = 'D1'.
  APPEND gsa_blart TO so_blart.
  gsa_blart-low    = 'D2'.
  APPEND gsa_blart TO so_blart.
  gsa_blart-low    = 'D3'.
  APPEND gsa_blart TO so_blart.
  gsa_blart-low    = 'D4'.
  APPEND gsa_blart TO so_blart.
  gsa_blart-low    = 'D5'.
  APPEND gsa_blart TO so_blart.
  gsa_blart-low    = 'D6'.
  APPEND gsa_blart TO so_blart.

************************************************************************
* Start-Of-Selektion                                                   *
************************************************************************
START-OF-SELECTION.
  BREAK-POINT ID /thkr/fi_chk_iban_gp_selektion.
  CLEAR: gt_alv[], gs_alv, gv_w_message.

  SELECT * FROM bkpf INTO TABLE gt_bkpf
             WHERE gjahr    EQ p_gjahr
             AND   blart    IN so_blart
             AND   cpudt    EQ p_cpudt
             AND   xref1_hd EQ p_sst.
  LOOP AT gt_bkpf ASSIGNING <gfs_bkpf>.
    SELECT * FROM bseg INTO gs_bseg
             WHERE bukrs EQ <gfs_bkpf>-bukrs
             AND belnr   EQ <gfs_bkpf>-belnr
             AND gjahr   EQ <gfs_bkpf>-gjahr.
      APPEND gs_bseg TO gt_bseg.
      IF gs_bseg-koart EQ 'K' OR
         gs_bseg-koart EQ 'D'.
        CASE gs_bseg-koart.
          WHEN 'K'.
            gv_partner     = gs_bseg-lifnr.
          WHEN 'D'.
            gv_partner     = gs_bseg-kunnr.
        ENDCASE.
        SELECT SINGLE * FROM but000 INTO gs_gp
               WHERE partner = gv_partner.
        IF 0 EQ sy-subrc.
          gs_alv-partner     = gv_partner.
          gs_alv-bpkind      = gs_gp-bpkind.
          gs_alv-name_org1   = gs_gp-name_org1.
          gs_alv-/thkr/gsber = gs_gp-/thkr/gsber.
          SELECT COUNT(*) FROM but0bk INTO gv_int
                    WHERE partner EQ gs_gp-partner.
          MOVE gv_int TO gs_alv-anz_gp_bk.
          gs_alv-bukrs       = <gfs_bkpf>-bukrs.
          gs_alv-belnr       = <gfs_bkpf>-belnr.
          gs_alv-wrbtr       = gs_bseg-wrbtr.
          gs_alv-wmwst       = gs_bseg-wmwst.
          gs_alv-blart       = <gfs_bkpf>-blart.
          gs_alv-bldat       = <gfs_bkpf>-bldat.
          gs_alv-budat       = <gfs_bkpf>-budat.
          gs_alv-cpudt       = <gfs_bkpf>-cpudt.
          gs_alv-zlsch       = gs_bseg-zlsch.
          gs_alv-waers       = <gfs_bkpf>-waers.
          gs_alv-bvtyp       = gs_bseg-bvtyp.

************************************************************************
*         Validierung Zahlweg und Währung                              *
************************************************************************
          CLEAR gs_alv-err_zlsch.
          IF gs_alv-waers EQ 'EUR'.
            IF gs_alv-zlsch = 'W'.
              gs_alv-err_zlsch = 'X'.
            ENDIF.
          ELSE.
            IF gs_alv-zlsch <> 'W'.
              gs_alv-err_zlsch = 'X'.
            ENDIF.
          ENDIF.
          IF gs_alv-zlsch IS INITIAL.
            gs_alv-err_zlsch = 'X'.
          ENDIF.

        ENDIF.
      ELSEIF gs_bseg-koart EQ 'S'.
        gs_alv-kokrs       = gs_bseg-kokrs.
        gs_alv-kostl       = gs_bseg-kostl.
      ENDIF.
    ENDSELECT.

************************************************************************
*   Initialisierung der Bankdaten in der Ausgabe                       *
************************************************************************
    CLEAR: gs_alv-banks,
           gs_alv-bankl,
           gs_alv-bankn,
           gs_alv-iban,
           gs_alv-t_iban_kz.

************************************************************************
*   Bank aus GP BUT0BK lesen                                           *
************************************************************************
    IF NOT gs_alv-bvtyp IS INITIAL.
      SELECT SINGLE banks, bankl, bankn, iban FROM but0bk
             INTO ( @gs_alv-banks, @gs_alv-bankl, @gs_alv-bankn, @gs_alv-iban )
          WHERE partner EQ @gs_alv-partner
          AND   bkvid   EQ @gs_alv-bvtyp.
      IF 0 EQ sy-subrc.
************************************************************************
*       IBAN aus der Tabelle TIBAN lesen, da nicht in der BUT0BK       *
************************************************************************
        IF gs_alv-iban IS INITIAL.
          SELECT SINGLE iban FROM tiban INTO gs_alv-iban
                             WHERE banks = gs_alv-banks
                             AND   bankl = gs_alv-bankl
                             AND   bankn = gs_alv-bankn.
          IF 0 EQ sy-subrc.
            gs_alv-t_iban_kz = 'X'.
          ELSE.
            CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
              EXPORTING
                i_bank_account = gs_alv-bankn
                i_bank_country = gs_alv-banks
                i_bank_number  = gs_alv-bankl
                i_bank_key     = gs_alv-bankl
              IMPORTING
                e_iban         = gs_alv-iban
              EXCEPTIONS
                no_conversion  = 1
                OTHERS         = 2.
            IF sy-subrc = 0.
              gs_alv-f_iban_kz = 'X'.
            ELSE.
              CLEAR gs_alv-iban.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR: gs_alv-banks,
             gs_alv-bankl,
             gs_alv-bankn,
             gs_alv-iban,
             gs_alv-t_iban_kz.
    ENDIF.

************************************************************************
*   Prüfung ob die Bank, wenn eingetragen, noch weitere GP's hat       *
************************************************************************
    CLEAR: gv_bank_i.
    IF NOT gs_alv-iban IS INITIAL OR
       NOT gs_alv-banks IS INITIAL OR
       NOT gs_alv-bankl IS INITIAL OR
       NOT gs_alv-bankn IS INITIAL.
      IF NOT gs_alv-iban IS INITIAL AND
         gs_alv-t_iban_kz IS INITIAL.       "Nur wenn die Kennzeichnung NICHT gesetzt ist.
        SELECT COUNT( * ) FROM but0bk INTO gv_bank_i
                     WHERE iban EQ gs_alv-iban.
      ELSE.
        SELECT COUNT( * ) FROM but0bk INTO gv_bank_i
                     WHERE banks EQ gs_alv-banks
                     AND   bankl EQ gs_alv-bankl
                     AND   bankn EQ gs_alv-bankn.
      ENDIF.
    ENDIF.
    MOVE gv_bank_i TO gs_alv-anz_bank_other.

    AUTHORITY-CHECK OBJECT 'K_CSKS'
     ID 'KOKRS' FIELD gs_alv-kokrs
     ID 'KOSTL' FIELD gs_alv-kostl
     ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      IF gv_w_message IS INITIAL.
        MOVE 'X' TO gv_w_message.
      ENDIF.
    ELSE.
      APPEND gs_alv TO gt_alv.
    ENDIF.
  ENDLOOP.

END-OF-SELECTION.

************************************************************************
* Wenn gesichert werden soll. dann die Summierung aufbauen und in einer*
* Kundentabelle /THKR/DB_IBAN_SUM für den Abgleich speichern.          *
************************************************************************
  BREAK-POINT ID /thkr/fi_chk_iban_gp_summe.
  CLEAR gt_sum[].
  IF NOT p_sitab IS INITIAL AND
     lines( gt_alv ) GT 0.
    LOOP AT gt_alv ASSIGNING <gfs_alv>.
      CLEAR gs_sum.
      MOVE-CORRESPONDING <gfs_alv> TO gs_sum.
      MOVE sy-mandt                TO gs_sum-mandt.
      MOVE p_gjahr                 TO gs_sum-gjahr.
      MOVE p_sst                   TO gs_sum-sst.
      COLLECT gs_sum INTO gt_sum.
    ENDLOOP.
  ENDIF.

************************************************************************
* Wenn Summierungen vorhanden dann die Summierung aufbauen und in einer*
* Kundentabelle /THKR/DB_IBAN_SUM für den Abgleich speichern.          *
************************************************************************
  LOOP AT gt_sum INTO gs_sum.
    SELECT SINGLE iban FROM /thkr/db_iban_s INTO gv_iban
                       WHERE iban  = gs_sum-iban
                       AND   gjahr = gs_sum-gjahr
                       AND   cpudt = gs_sum-cpudt
                       AND   sst   = gs_sum-sst.
    IF 0 EQ sy-subrc.       "Vorhanden, Datensatz ändern
      UPDATE /thkr/db_iban_s SET wrbtr = gs_sum-wrbtr
                       WHERE iban  = gs_sum-iban
                       AND   gjahr = gs_sum-gjahr
                       AND   cpudt = gs_sum-cpudt
                       AND   sst   = gs_sum-sst.
    ELSE.                 "Nicht vorhanden, Datensatz anlegen
      INSERT /thkr/db_iban_s FROM gs_sum.
    ENDIF.
  ENDLOOP.

************************************************************************
* ALV - Ausgabe starten, wenn nicht BATCH                              *
************************************************************************
  IF sy-batch IS INITIAL.
    IF NOT p_vari IS INITIAL.
      SELECT SINGLE variant FROM ltdxt INTO p_vari
                    WHERE report  = sy-repid
                    AND   variant = p_vari.
      IF 0 NE sy-subrc.
        CLEAR p_vari.
      ENDIF.
    ENDIF.
    IF NOT gv_w_message IS INITIAL.
      MESSAGE 'Es werden aus Berechtigungsgründen weniger Datensätze angezeigt!' TYPE 'S'.
    ENDIF.
    lcl_appl=>display( gt_alv ).
  ENDIF.
