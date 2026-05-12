FUNCTION /thkr/feb_call_fb09.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BUKRS) LIKE  RF05L-BUKRS
*"     VALUE(I_BELNR) LIKE  RF05L-BELNR
*"     VALUE(I_GJAHR) LIKE  RF05L-GJAHR
*"     VALUE(I_BUZEI) LIKE  RF05L-BUZEI OPTIONAL
*"     VALUE(I_KOART) TYPE  ZFI_F_BELPOS-KOART OPTIONAL
*"     VALUE(I_XSIMU) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_UPDATE) DEFAULT 'S'
*"     VALUE(I_MODE) DEFAULT 'N'
*"     VALUE(I_NO_AUTH) DEFAULT SPACE
*"  EXCEPTIONS
*"      NOT_POSSIBLE
*"--------------------------------------------------------------------

*----------------------------------------------------------------------*
* Export der Parameter ins Memory für den Ablauf der Transaktion FB09  *
*----------------------------------------------------------------------*

  DATA: BEGIN OF bdc OCCURS 12.        "Struktur für den Aufruf von
          INCLUDE STRUCTURE bdcdata.         "Transaktionen
  DATA: END OF bdc.
  DATA: BEGIN OF msg OCCURS 0.         "Messages zur Fehleranalyse
          INCLUDE STRUCTURE bdcmsgcoll.
  DATA: END OF msg.


  DATA:
    xsimu(1) TYPE c VALUE 'X',
    xcall(1) TYPE c VALUE 'X'.


* Berechtigung prüfen
  IF i_no_auth = space.
    CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
      EXPORTING
        tcode  = 'FB09'
      EXCEPTIONS
        ok     = 0
        OTHERS = 4.
    IF sy-subrc NE 0.
      MESSAGE e172(00) WITH 'FB09' RAISING not_possible.
    ENDIF.
  ENDIF.


* Transaktion im Simulationsmodus aufrufen?
  IF i_xsimu NE space.
    EXPORT xsimu TO MEMORY ID 'XSIMU'.
  ENDIF.

*----------------------------------------------------------------------*
* Zahlsperre bei kreditorischen und debitorischen Rückläufer
* auf 'R' setzen                                                       *
*----------------------------------------------------------------------*
  REFRESH bdc.
  CLEAR bdc.
  bdc-program  = 'SAPMF05L'.
  bdc-dynpro   = '102'.
  bdc-dynbegin = 'X'.
  APPEND bdc.
  CLEAR bdc.
  bdc-fnam     = 'RF05L-BELNR'.
  bdc-fval     = i_belnr.
  APPEND bdc.
  CLEAR bdc.
  bdc-fnam     = 'RF05L-BUKRS'.
  bdc-fval     = i_bukrs.
  APPEND bdc.
  CLEAR bdc.
  bdc-fnam     = 'RF05L-GJAHR'.
  DATA ld_gjahr TYPE gjahr.           " note 01151040
  WRITE i_gjahr TO ld_gjahr.          " note 01151040
  bdc-fval     = ld_gjahr.            " note 01151040
  APPEND bdc.
  CLEAR bdc.
  bdc-fnam     = 'RF05L-BUZEI'.
  bdc-fval     = i_buzei.
  APPEND bdc.
  CLEAR bdc.
  bdc-fnam     = 'BDC_OKCODE'.
  bdc-fval     = '/00'.
  APPEND bdc.

  CLEAR bdc.
  IF i_koart = 'K'.
    bdc-program  = 'SAPMF05L'.
    bdc-dynpro   = '302'.
    bdc-dynbegin = 'X'.
  ELSEIF i_koart = 'D'.
    bdc-program  = 'SAPMF05L'.
    bdc-dynpro   = '301'.
    bdc-dynbegin = 'X'.
  ENDIF.
  APPEND bdc.

  CLEAR bdc.
  bdc-fnam     = 'BSEG-ZLSPR'.
  bdc-fval     = 'W'.                " W statt R
  APPEND bdc.

  CLEAR bdc.
  bdc-fnam     = 'BDC_OKCODE'.
  bdc-fval     = '=AE'.
  APPEND bdc.

  IF i_xsimu = abap_false.
    IF i_no_auth = abap_false.
      CALL TRANSACTION 'FB09' WITH AUTHORITY-CHECK
                              USING bdc MODE i_mode UPDATE i_update
                              MESSAGES INTO msg.
    ELSE.
      CALL TRANSACTION 'FB09' WITHOUT AUTHORITY-CHECK
                              USING bdc MODE i_mode UPDATE i_update
                              MESSAGES INTO msg.
    ENDIF.
  ENDIF.

  FREE MEMORY ID: 'XSIMU'.

* Log zur Fehleranalyse (RFUTFBRA)
  EXPORT bkpf-bukrs FROM i_bukrs
         bkpf-belnr FROM i_belnr
         bkpf-gjahr FROM i_gjahr
         msg TO DATABASE rfdt(ra) ID 'FB09'.

* Fehlermeldung weiterreichen
  IF sy-msgty CA 'AE'.
    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_possible.
  ENDIF.

ENDFUNCTION.
