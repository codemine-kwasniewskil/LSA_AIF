function zfi_feb_call_fb09.
*"----------------------------------------------------------------------
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
*"----------------------------------------------------------------------

*----------------------------------------------------------------------*
* Export der Parameter ins Memory für den Ablauf der Transaktion FB09  *
*----------------------------------------------------------------------*

  data: begin of bdc occurs 12.        "Struktur für den Aufruf von
          include structure bdcdata.         "Transaktionen
  data: end of bdc.
  data: begin of msg occurs 0.         "Messages zur Fehleranalyse
          include structure bdcmsgcoll.
  data: end of msg.


  data:
    xsimu(1) type c value 'X',
    xcall(1) type c value 'X'.


* Berechtigung prüfen
  if i_no_auth = space.
    call function 'AUTHORITY_CHECK_TCODE'
      exporting
        tcode  = 'FB09'
      exceptions
        ok     = 0
        others = 4.
  endif.
  if sy-subrc ne 0.
    message e172(00) with 'FB09' raising not_possible.
  endif.

* Transaktion im Simulationsmodus aufrufen?
  if i_xsimu ne space.
    export xsimu to memory id 'XSIMU'.
  endif.

*----------------------------------------------------------------------*
* Zahlsperre bei kreditorischen und debitorischen Rückläufer
* auf 'R' setzen                                                       *
*----------------------------------------------------------------------*
  refresh bdc.
  clear bdc.
  bdc-program  = 'SAPMF05L'.
  bdc-dynpro   = '102'.
  bdc-dynbegin = 'X'.
  append bdc.
  clear bdc.
  bdc-fnam     = 'RF05L-BELNR'.
  bdc-fval     = i_belnr.
  append bdc.
  clear bdc.
  bdc-fnam     = 'RF05L-BUKRS'.
  bdc-fval     = i_bukrs.
  append bdc.
  clear bdc.
  bdc-fnam     = 'RF05L-GJAHR'.
  data ld_gjahr type gjahr.           " note 01151040
  write i_gjahr to ld_gjahr.          " note 01151040
  bdc-fval     = ld_gjahr.            " note 01151040
  append bdc.
  clear bdc.
  bdc-fnam     = 'RF05L-BUZEI'.
  bdc-fval     = i_buzei.
  append bdc.
  clear bdc.
  bdc-fnam     = 'BDC_OKCODE'.
  bdc-fval     = '/00'.
  append bdc.

  clear bdc.
  if i_koart = 'K'.
    bdc-program  = 'SAPMF05L'.
    bdc-dynpro   = '302'.
    bdc-dynbegin = 'X'.
  elseif i_koart = 'D'.
    bdc-program  = 'SAPMF05L'.
    bdc-dynpro   = '301'.
    bdc-dynbegin = 'X'.
  endif.
  append bdc.

  clear bdc.
  bdc-fnam     = 'BSEG-ZLSPR'.
  bdc-fval     = 'W'.                " W statt R
  append bdc.

  clear bdc.
  bdc-fnam     = 'BDC_OKCODE'.
  bdc-fval     = '=AE'.
  append bdc.

  if i_xsimu = abap_false.
    if i_no_auth = abap_false.
      call transaction 'FB09' with authority-check
                              using bdc mode i_mode update i_update
                              messages into msg.
    else.
      call transaction 'FB09' without authority-check
                              using bdc mode i_mode update i_update
                              messages into msg.
    endif.
  endif.

  free memory id: 'XSIMU'.

* Log zur Fehleranalyse (RFUTFBRA)
  export bkpf-bukrs from i_bukrs
         bkpf-belnr from i_belnr
         bkpf-gjahr from i_gjahr
         msg to database rfdt(ra) id 'FB09'.

* Fehlermeldung weiterreichen
  if sy-msgty ca 'AE'.
    message id sy-msgid type 'E' number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising not_possible.
  endif.

endfunction.
