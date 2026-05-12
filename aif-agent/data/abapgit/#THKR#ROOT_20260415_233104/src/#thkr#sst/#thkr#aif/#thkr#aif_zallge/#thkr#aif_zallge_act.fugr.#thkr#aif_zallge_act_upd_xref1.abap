*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_upd_xref1 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_AO
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.                                             "#EC NOBREAK
*"----------------------------------------------------------------------

  DATA: lv_start_time      TYPE timestampl,
        lv_current_time    TYPE timestampl,
        lv_elapsed_seconds TYPE i,
        lv_loop_count      TYPE i VALUE 0,
        lv_ns              TYPE /aif/ns,
        lv_ifname          TYPE /aif/ifname,
        lv_xref1_trys      TYPE c LENGTH 10,
        lv_xref1_sec       TYPE c LENGTH 10.

  "Das Feld XREF1_HD kann in der internen Schnittstelle
  " /thkr/cl_psm_ao_appl=>get_instance( )->create_psm_ao_beleg verarbeitet werden.
  " dort wird die Struktur fm_t_bbkpf für den Belegkopf verwendet,
  " die dieses Feld nicht beinhaltet. Also Update auf Beleg im Nachgang.
* Check if Actions are allowed.
  CALL FUNCTION '/THKR/AIF_ZALLGE_ACT_OFF'
    TABLES
      return_tab = return_tab
    EXCEPTIONS
      off        = 1
      OTHERS     = 2.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

*"----------------------------------------------------------------------

  success = 'N'.

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns     = lv_ns
      ifname = lv_ifname.

  SELECT SINGLE int_value
    FROM /aif/t_mvmapval5
    INTO @lv_xref1_trys
    WHERE vmapname = 'MAP_RUN_CONFIG'
    AND ns = 'ZALLGE'
    AND ext_value1 = @lv_ns
    AND ext_value2 = @lv_ifname
    AND ext_value3 = 'XREF1_TRYS'.

  IF sy-subrc <> 0.
    SELECT SINGLE int_value
      FROM /aif/t_mvmapval5
      INTO @lv_xref1_trys
      WHERE vmapname = 'MAP_RUN_CONFIG'
      AND ns = 'ZALLGE'
      AND ext_value1 = '*'
      AND ext_value2 = '*'
      AND ext_value3 = 'XREF1_TRYS'.
    IF sy-subrc <> 0.
      lv_xref1_trys = '5'.
    ENDIF.
  ENDIF.

  SELECT SINGLE int_value
    FROM /aif/t_mvmapval5
    INTO @lv_xref1_sec
    WHERE vmapname = 'MAP_RUN_CONFIG'
    AND ns = 'ZALLGE'
    AND ext_value1 = @lv_ns
    AND ext_value2 = @lv_ifname
    AND ext_value3 = 'XREF1_SEC'.

  IF sy-subrc <> 0.
    SELECT SINGLE int_value
      FROM /aif/t_mvmapval5
      INTO @lv_xref1_sec
      WHERE vmapname = 'MAP_RUN_CONFIG'
      AND ns = 'ZALLGE'
      AND ext_value1 = '*'
      AND ext_value2 = '*'
      AND ext_value3 = 'XREF1_SEC'.
    IF sy-subrc <> 0.
      lv_xref1_sec = '1'.
    ENDIF.
  ENDIF.

  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_ZALLGE_ACT_UPD_XREF1' ) TO return_tab.

  WHILE lv_loop_count < lv_xref1_trys AND success = 'N'.

    UPDATE bkpf
    SET xref1_hd = curr_line-xref1_hd
    WHERE bukrs = curr_line-bukrs
      AND belnr = curr_line-belnr
      AND gjahr = curr_line-gjahr
      AND lotkz = curr_line-lotkz.

    IF sy-subrc = 0.
      success = 'Y'.
      IF 1 = 0. MESSAGE e031(/thkr/sst) WITH curr_line-xref1_hd curr_line-lotkz curr_line-belnr.ENDIF.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                             number = 031
                             type = 'S'
                             message_v1 = curr_line-xref1_hd
                             message_v2 = curr_line-lotkz
                             message_v3 = curr_line-belnr ) TO return_tab[].
      EXIT.
    ELSE.
      "SAP legt die Belege mit dem Jahr aus dem Buchungsdatum an.
      "Daher wird im 2. Schritt versucht, die Anordnung mit Buchungsdatum zu finden.
      IF curr_line-budat IS NOT INITIAL.
        UPDATE bkpf
          SET xref1_hd = curr_line-xref1_hd
          WHERE bukrs = curr_line-bukrs
            AND belnr = curr_line-belnr
            AND gjahr = curr_line-budat(4)
            AND lotkz = curr_line-lotkz.

        IF sy-subrc <> 0.
          success = 'N'.
          IF 1 = 0. MESSAGE e030(/thkr/sst) WITH curr_line-bukrs curr_line-gjahr curr_line-belnr.ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    lv_loop_count = lv_loop_count + 1.

    WAIT UP TO lv_xref1_sec SECONDS.

  ENDWHILE.

  IF success = 'N'.
    APPEND VALUE bapiret2( id = '/THKR/SST'
                           number = 030
                           type = 'E'
                           message_v1 = curr_line-bukrs
                           message_v2 = curr_line-gjahr
                           message_v3 = curr_line-belnr ) TO return_tab[].
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
