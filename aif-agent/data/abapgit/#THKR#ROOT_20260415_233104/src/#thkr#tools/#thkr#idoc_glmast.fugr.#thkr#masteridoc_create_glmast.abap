FUNCTION /THKR/MASTERIDOC_CREATE_GLMAST .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(SKA1KEY) LIKE  BDISKA1KEY STRUCTURE  BDISKA1KEY
*"     VALUE(RCVPFC) LIKE  BDALEDC-RCVPFC
*"     VALUE(RCVPRN) LIKE  BDALEDC-RCVPRN
*"     VALUE(RCVPRT) LIKE  BDALEDC-RCVPRT
*"     VALUE(SNDPFC) LIKE  BDALEDC-SNDPFC
*"     VALUE(SNDPRN) LIKE  BDALEDC-SNDPRN
*"     VALUE(SNDPRT) LIKE  BDALEDC-SNDPRT
*"     VALUE(MESTYP) LIKE  TBDME-MESTYP
*"  EXPORTING
*"     VALUE(CREATED_COMM_IDOCS) LIKE  SY-TABIX
*"  TABLES
*"      SKATKEY STRUCTURE  BDISKATKEY
*"      SKB1KEY STRUCTURE  BDISKB1KPL
*"----------------------------------------------------------------------



  DATA: BEGIN OF f_idoc_header.
      INCLUDE STRUCTURE edidc.
  DATA: END OF f_idoc_header.

  DATA: BEGIN OF t_idoc_data OCCURS 10.
      INCLUDE STRUCTURE edidd.
  DATA: END OF t_idoc_data.

  DATA: BEGIN OF t_communication_idoc_control OCCURS 10.
      INCLUDE STRUCTURE edidc.
  DATA: END OF t_communication_idoc_control.

  DATA: active.

  DATA: comm_control_lines LIKE sy-tabix.

  DATA: waers LIKE tcurc-isocd.

  DATA: lv_glob_bukrs LIKE t001-bukrs_glob.


* Append for SKA1, SKB1
  INCLUDE lks03fop.

* Data for ledger group specific clearing.
  DATA: lv_xlgclr LIKE skb1-xlgclr.
* Data for check if New GL is active and if more than one ledger is defined within an company code.
  DATA: lv_newgl_active TYPE fagl_glflex_active,
        it_ledgers      TYPE fagl_rldnr_tab,
        lv_ledger_count TYPE i VALUE 0.
  DATA: lv_glaccount_type LIKE SKA1-GLACCOUNT_TYPE.


* Check if New GL active.
    CALL FUNCTION 'FAGL_CHECK_GLFLEX_ACTIVE'
    IMPORTING
      E_GLFLEX_ACTIVE = LV_NEWGL_ACTIVE.


* allow only committed read
  CALL FUNCTION 'DB_SET_ISOLATION_LEVEL'.

* initial
  CLEAR t_communication_idoc_control.
  REFRESH t_communication_idoc_control.
  REFRESH t_idoc_data.
  active = ' '.

* Merge between G/L Accounts and Cost Elements: Do not send secondary cost elements
*  DATA:
*    BEGIN OF ls_check_secondary,
*      ktopl TYPE ska1-ktopl,
*      saknr TYPE ska1-saknr,
*    END OF  ls_check_secondary.
*  MOVE-CORRESPONDING ska1key TO ls_check_secondary.
*  IF ls_check_secondary IS INITIAL.
*    LOOP AT skatkey WHERE mandt = sy-mandt.
*      MOVE-CORRESPONDING skatkey TO ls_check_secondary.
*      EXIT.
*    ENDLOOP.
*  ENDIF.
*  IF ls_check_secondary IS INITIAL.
*    LOOP AT skb1key WHERE mandt = sy-mandt.
*      MOVE-CORRESPONDING skb1key TO ls_check_secondary.
*      SELECT SINGLE ktopl INTO ls_check_secondary-ktopl FROM t001 WHERE bukrs = skb1key-bukrs.
*      EXIT.
*    ENDLOOP.
*  ENDIF.
*  SELECT SINGLE glaccount_type INTO lv_glaccount_type FROM ska1      "n2747998
*    BYPASSING BUFFER
*    WHERE ktopl          = ls_check_secondary-ktopl
*    AND   saknr          = ls_check_secondary-saknr.
*  CHECK lv_glaccount_type <> if_gl_account_master=>gc_glaccount_type-pl_secondary.

* fill T_IDOC_DATA for Segment E1SKA1M with SKA1
  CALL FUNCTION 'IDOC_REDUCTION_SEGMENT_TEST'
    EXPORTING
      message_type = mestyp
      segment_type = 'E1SKA1M'
    IMPORTING
      active       = active.

  IF active = 'X'.

    SELECT SINGLE * FROM ska1 BYPASSING BUFFER
                              WHERE ktopl = ska1key-ktopl
                              AND   saknr = ska1key-saknr.

    IF sy-subrc = 0.
      e1ska1m-msgfn = ska1key-msgfn.
      e1ska1m-ktopl = ska1-ktopl.
      e1ska1m-saknr = ska1-saknr.
      e1ska1m-bilkt = ska1-bilkt.
      e1ska1m-gvtyp = ska1-gvtyp.
      e1ska1m-ktoks = ska1-ktoks.
      e1ska1m-mustr = ska1-mustr.
      e1ska1m-vbund = ska1-vbund.
      e1ska1m-xbilk = ska1-xbilk.
      e1ska1m-xloev = ska1-xloev.
      e1ska1m-xspea = ska1-xspea.
      e1ska1m-xspeb = ska1-xspeb.
      e1ska1m-xspep = ska1-xspep.
      e1ska1m-func_area         = ska1-func_area.
      e1ska1m-glaccount_type    = ska1-glaccount_type.
      e1ska1m-glaccount_subtype = ska1-glaccount_subtype.
      e1ska1m-main_saknr        = ska1-main_saknr.

      CLEAR t_idoc_data.
      t_idoc_data-segnam = c_segnam_e1ska1m.
      t_idoc_data-mandt = sy-mandt.
      t_idoc_data-sdata  = e1ska1m.

      CALL FUNCTION 'IDOC_REDUCTION_FIELD_REDUCE'
        EXPORTING
          message_type = mestyp
          segment_type = 'E1SKA1M'
          segment_data = t_idoc_data-sdata
          empty_symbol = '/'
        IMPORTING
          segment_data = t_idoc_data-sdata.

      APPEND t_idoc_data.

*     Append for SKA1 (for 4.6 only)
      IF x_append = 'X'.
        CLEAR e1skatm.
        e1skatm-msgfn = ska1key-msgfn.
        MOVE-CORRESPONDING ska1 TO append_ska1.
        e1skatm-txt50 = append_ska1.
        CLEAR t_idoc_data.
        t_idoc_data-segnam = c_segnam_e1skatm.
        t_idoc_data-mandt = sy-mandt.
        t_idoc_data-sdata  = e1skatm.
        APPEND t_idoc_data.
      ENDIF.

    ELSEIF ska1key-ktopl <> space.
      EXIT.
    ENDIF.                             "SY-SUBRC

  ENDIF.                               "ACTIVE


* fill T_IDOC_DATA for Segment E1SKATM with SKAT
  LOOP AT skatkey WHERE mandt = sy-mandt.
    active = ' '.
    CALL FUNCTION 'IDOC_REDUCTION_SEGMENT_TEST'
      EXPORTING
        message_type = mestyp
        segment_type = 'E1SKATM'
      IMPORTING
        active       = active.

    IF active = 'X'.
      SELECT SINGLE * FROM skat BYPASSING BUFFER
                                WHERE ktopl = skatkey-ktopl
                                AND   saknr = skatkey-saknr
                                AND   spras = skatkey-spras.

      IF sy-subrc = 0.
        e1skatm-msgfn = skatkey-msgfn.
        e1skatm-spras = skat-spras.
        e1skatm-txt20 = skat-txt20.
        e1skatm-txt50 = skat-txt50.

        CLEAR t_idoc_data.
        t_idoc_data-segnam = c_segnam_e1skatm.
        t_idoc_data-mandt = sy-mandt.
        t_idoc_data-sdata  = e1skatm.

        CALL FUNCTION 'IDOC_REDUCTION_FIELD_REDUCE'
          EXPORTING
            message_type = mestyp
            segment_type = 'E1SKATM'
            segment_data = t_idoc_data-sdata
            empty_symbol = '/'
          IMPORTING
            segment_data = t_idoc_data-sdata.

        APPEND t_idoc_data.
      ENDIF.                           "SY_SUBRC

    ENDIF.                             "ACTIVE

  ENDLOOP.                             "at SKATKEY

* fill T_IDOC_DATA for Segment E1SKB1M with SKB1
  LOOP AT skb1key WHERE mandt = sy-mandt.


CLEAR lv_ledger_count.
* Check if more than one ledger defined within this company code.
 IF NOT LV_NEWGL_ACTIVE IS INITIAL.
      CALL FUNCTION 'FAGL_GET_ALL_LEDGERS_IN_BUKRS'
      EXPORTING
        i_bukrs    = skb1key-bukrs
      IMPORTING
        et_ledgers = it_ledgers.
    DESCRIBE TABLE it_ledgers LINES lv_ledger_count.
 ENDIF.
.
*$*$-End:   EHP603_MASTERIDOC_CREATE_4----------------------------------------------------------$*$*

    active = ' '.

    CALL FUNCTION 'IDOC_REDUCTION_SEGMENT_TEST'
      EXPORTING
        message_type = mestyp
        segment_type = 'E1SKB1M'
      IMPORTING
        active       = active.

    IF active = 'X'.

      SELECT SINGLE * FROM skb1 BYPASSING BUFFER
                                WHERE bukrs = skb1key-bukrs
                                AND saknr = skb1key-saknr.

      IF sy-subrc = 0.
        CLEAR e1skb1m.
        e1skb1m-msgfn = skb1key-msgfn.
        e1skb1m-bukrs = skb1-bukrs.
        e1skb1m-begru = skb1-begru.
        e1skb1m-busab = skb1-busab.
        e1skb1m-fdlev = skb1-fdlev.
        e1skb1m-fstag = skb1-fstag.
        e1skb1m-hbkid = skb1-hbkid.
        e1skb1m-hktid = skb1-hktid.
        e1skb1m-kdfsl = skb1-kdfsl.
        e1skb1m-mitkz = skb1-mitkz.
        e1skb1m-mwskz = skb1-mwskz.
        e1skb1m-vzskz = skb1-vzskz.
        CALL FUNCTION 'CURRENCY_CODE_SAP_TO_ISO'
          EXPORTING
            sap_code  = skb1-waers
          IMPORTING
            iso_code  = waers
          EXCEPTIONS
            not_found = 01.
        IF sy-subrc <> 0.
          MOVE skb1-waers TO waers.
        ENDIF.
        MOVE waers TO e1skb1m-waers.
        e1skb1m-wmeth = skb1-wmeth.
        e1skb1m-xgkon = skb1-xgkon.
        e1skb1m-xintb = skb1-xintb.
        e1skb1m-xkres = skb1-xkres.
        e1skb1m-xloeb = skb1-xloeb.
        e1skb1m-xnkon = skb1-xnkon.
        e1skb1m-xopvw = skb1-xopvw.
        e1skb1m-xspeb = skb1-xspeb.
        e1skb1m-zinrt = skb1-zinrt.
        e1skb1m-zuawa = skb1-zuawa.
        e1skb1m-altkt = skb1-altkt.
        e1skb1m-xmitk = skb1-xmitk.
        e1skb1m-recid = skb1-recid.
        e1skb1m-fipos = skb1-fipos.
        e1skb1m-xmwno = skb1-xmwno.
        e1skb1m-xsalh = skb1-xsalh.
        e1skb1m-bewgp = skb1-bewgp.
        e1skb1m-infky = skb1-infky.
        e1skb1m-togru = skb1-togru.
        IF NOT cl_fagl_switch_check=>fagl_fin_mca( ) IS INITIAL.
          e1skb1m-mcakey = skb1-mcakey.
        ENDIF.
        e1skb1m-x_uj_clr = skb1-x_uj_clr.
*       Merge between G/L Accounts and Cost Elements
        CLEAR sy-subrc.
        IF lv_glaccount_type <> if_gl_account_master=>gc_glaccount_type-pl_neutral.
          SELECT SINGLE katyp mgefl msehi INTO CORRESPONDING FIELDS OF e1skb1m
          FROM cskb JOIN tka02 ON tka02~kokrs = cskb~kokrs "#EC CI_BUFFJOIN
          WHERE tka02~bukrs = skb1key-bukrs
          AND   cskb~kstar  = skb1key-saknr
          AND   cskb~datbi >= sy-datum
          AND   cskb~datab <= sy-datum.
        ENDIF.
        IF sy-subrc <> 0 OR
           lv_glaccount_type = if_gl_account_master=>gc_glaccount_type-pl_neutral.
          e1skb1m-katyp = '!'.
        ELSEIF e1skb1m-msehi IS NOT INITIAL.
          CALL FUNCTION 'UNIT_OF_MEASURE_SAP_TO_ISO'
            EXPORTING
              sap_code = e1skb1m-msehi
            IMPORTING
              iso_code = e1skb1m-msehi
            EXCEPTIONS
              OTHERS   = 0.
        ENDIF.

        CLEAR t_idoc_data.
        t_idoc_data-segnam = c_segnam_e1skb1m.
        t_idoc_data-mandt = sy-mandt.
        t_idoc_data-sdata  = e1skb1m.

        CALL FUNCTION 'IDOC_REDUCTION_FIELD_REDUCE'
          EXPORTING
            message_type = mestyp
            segment_type = 'E1SKB1M'
            segment_data = t_idoc_data-sdata
            empty_symbol = '/'
          IMPORTING
            segment_data = t_idoc_data-sdata.

        APPEND t_idoc_data.

*       Transfer Global Company Code also for SKB1-Data      "Note 1090786
*       which are transported by using E1SKATM.              "Note 1090786

        IF x_append = 'X'.                                   "Note 1090786
          CALL FUNCTION 'FI_CC_CONVERT_LOCAL_TO_GLOBAL'        "Note 1090786
            EXPORTING                                          "Note 1090786
              bukrs_local  = skb1-bukrs            "Note 1090786
            IMPORTING                                           "Note 1090786
              bukrs_global = lv_glob_bukrs         "Note 1090786
            EXCEPTIONS                                          "Note 1090786
              OTHERS       = 0.      "Error handling in BASIS      "Note 1090786
        ENDIF.                                               "Note 1090786

*$*$-Start: EHP603_MASTERIDOC_CREATE_6----------------------------------------------------------$*$*

        IF x_append = 'X' OR lv_ledger_count >= 1.                                  "Note 1090786
        CALL FUNCTION 'FI_CC_CONVERT_LOCAL_TO_GLOBAL'        "Note 1090786
          EXPORTING                                          "Note 1090786
            bukrs_local              = skb1-bukrs            "Note 1090786
         IMPORTING                                           "Note 1090786
           BUKRS_GLOBAL              = lv_glob_bukrs         "Note 1090786
         EXCEPTIONS                                          "Note 1090786
           OTHERS                      = 0.      "Error handling in BASIS      "Note 1090786
        ENDIF.                                               "Note 1090786

*$*$-End:   EHP603_MASTERIDOC_CREATE_6----------------------------------------------------------$*$*
*       Append for SKB1 (for 4.6 only)

        IF x_append = 'X'.
          CLEAR e1skatm.
          e1skatm-msgfn = skb1key-msgfn.
          CONCATENATE skb1-bukrs lv_glob_bukrs INTO e1skatm-txt20 RESPECTING BLANKS.
          MOVE-CORRESPONDING skb1 TO append_skb1.
          e1skatm-txt50 = append_skb1.
          CLEAR t_idoc_data.
          t_idoc_data-segnam = c_segnam_e1skatm.
          t_idoc_data-mandt = sy-mandt.
          t_idoc_data-sdata  = e1skatm.
          APPEND t_idoc_data.
        ENDIF.

*$*$-Start: EHP603_MASTERIDOC_CREATE_5----------------------------------------------------------$*$*

*       If user-exit executed, the field xlgclr have to be transfered also, however, without the 'tag'
*       If user-exit not executed but new GL is active and more than one ledger is defined within the
*          company code., all fields defined in append should also be transfered

        IF x_append = 'X' OR lv_ledger_count >= 1.
          CLEAR e1skatm.
          e1skatm-msgfn = skb1key-msgfn.
          CONCATENATE skb1-bukrs lv_glob_bukrs INTO e1skatm-txt20 RESPECTING BLANKS.
          MOVE-CORRESPONDING skb1 TO append_skb1.
*         If sender transfers the field xlgclr, the "tag" is filled, so that
*         the destination system can differ the field with value SPACE from the case that
*         the sender did not transfer the value of the field xlgclr.
          IF lv_ledger_count >= 1.
             append_skb1-tag = cgd_tag_lgclr.
          ENDIF.
          e1skatm-txt50 = append_skb1.
          CLEAR t_idoc_data.
          t_idoc_data-segnam = c_segnam_e1skatm.
          t_idoc_data-mandt = sy-mandt.
          t_idoc_data-sdata  = e1skatm.
          APPEND t_idoc_data.

        ENDIF.

*$*$-End:   EHP603_MASTERIDOC_CREATE_5----------------------------------------------------------$*$*

      ENDIF.                           "SY-SUBRC
    ENDIF.                             "ACTIVE

  ENDLOOP.                             "SKB1KEY


* Sort
  SORT t_idoc_data BY segnam.
  READ TABLE t_idoc_data WITH KEY segnam = c_segnam_e1ska1m.
  IF sy-tabix > 1.
    DELETE t_idoc_data INDEX sy-tabix.
    INSERT t_idoc_data INDEX 1.
  ENDIF.

* fill IDOC_HEADER
  f_idoc_header-mestyp = mestyp.
  f_idoc_header-idoctp = c_idoctp_glmast01.
  f_idoc_header-cimtyp = space.
  f_idoc_header-sndpfc = sndpfc.
  f_idoc_header-sndprn = sndprn.
  f_idoc_header-sndprt = sndprt.
  f_idoc_header-rcvpfc = rcvpfc.
  f_idoc_header-rcvprn = rcvprn.
  f_idoc_header-rcvprt = rcvprt.
  f_idoc_header-serial = space.


  CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
    EXPORTING
      master_idoc_control            = f_idoc_header
    TABLES
      communication_idoc_control     = t_communication_idoc_control
      master_idoc_data               = t_idoc_data
    EXCEPTIONS
      error_in_idoc_control          = 01
      error_writing_idoc_status      = 02
      error_in_idoc_data             = 03
      sending_logical_system_unknown = 04.

  IF sy-subrc = 0.
    DESCRIBE TABLE t_communication_idoc_control LINES comm_control_lines.
    created_comm_idocs = comm_control_lines.
  ELSE.
    created_comm_idocs = -1.
  ENDIF.

* back again to dirty read
  CALL FUNCTION 'DB_RESET_ISOLATION_TO_DEFAULT'.

ENDFUNCTION.
