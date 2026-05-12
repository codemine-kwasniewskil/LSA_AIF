TYPE-POOLS slis.

TYPES: BEGIN OF typ_alv.
         INCLUDE STRUCTURE bkpf.
TYPES:   umkrs       TYPE t007f-umkrs,      "Umsatzsteuerkreis
         lohnind     TYPE rfums_alv-lohnind, "Lohnindikator
         dekr        TYPE c,                "1-Debi, 2-Kredi, 3 Debi
         "berichtigt, 4-Kredi bericht
         dmshb       TYPE rfums_alv-dmshb,  "Warenwert
         mldwaer     TYPE rfums_alv-mldwaer, "Meldewährung
         stceg       TYPE bseg-stceg,
         xegdr       TYPE bseg-xegdr,
         xegsrv      TYPE xegsrv,           "Ind. service in EU  "1384895
         xegcos      TYPE xegcos,           "Ind. Call-off Stock in EU     "2854595
         stceg_orig  TYPE stceg_orig,    "VAT number original buyer     "2854595
         name1_orig  TYPE name1_orig,    "Name of original buyer        "2854595
         buzei       TYPE bseg-buzei,
         bschl       TYPE bseg-bschl,
         koart       TYPE bseg-koart,
         umskz       TYPE bseg-umskz,
         shkzg       TYPE bseg-shkzg,
         gsber       TYPE bseg-gsber,
         tax_country TYPE bseg-tax_country,
         mwskz       TYPE bseg-mwskz,
         txdat_from  TYPE bseg-txdat_from,
         dmbtr       TYPE bseg-dmbtr,
         wrbtr       TYPE bseg-wrbtr,
         hwbas       TYPE bseg-hwbas,
         fwbas       TYPE bseg-fwbas,
         valut       TYPE bseg-valut,
         zuonr       TYPE bseg-zuonr,
         sgtxt       TYPE bseg-sgtxt,
         kokrs       TYPE bseg-kokrs,
         kostl       TYPE bseg-kostl,
         aufnr       TYPE bseg-aufnr,
*--->>> EOL-0083 24.04.2024
         prctr       TYPE bseg-prctr,
*---<<<
         vbeln       TYPE bseg-vbeln,
         vbel2       TYPE bseg-vbel2,
         posn2       TYPE bseg-posn2,
         kunnr       TYPE bseg-kunnr,
         zfbdt       TYPE bseg-zfbdt,
         eglld       TYPE bseg-eglld,
         egbld       TYPE bseg-egbld,
         stbuk       TYPE bseg-stbuk,
         name1       TYPE kna1-name1,                       "530539
         stras       TYPE kna1-stras,                       "530539
         ort01       TYPE kna1-ort01,                       "530539
         pstlz       TYPE kna1-pstlz,                       "530539
         umsks       TYPE bseg-umsks,                       "1434854
         rebzt       TYPE bseg-rebzt,                       "1434854
         cvp_xblck   TYPE cvp_xblck,                        "2169661
         xcpdk       TYPE xcpdk,                            "2169661
         opbel       TYPE aslmfica_opbel,                   "1465562
         lfdnr       TYPE aslmfica_lfdnr,                   "1465562
       END OF typ_alv.

DATA: l_tab_alv TYPE TABLE OF typ_alv WITH HEADER LINE.
DATA: gl_tab_alv TYPE TABLE OF typ_alv WITH HEADER LINE.
DATA: BEGIN OF t_bukrs OCCURS 10,
        bukrs LIKE bkpf-bukrs,
      END OF t_bukrs.
*---------------------------------------------------------------------*
*       FORM print_ep                                                 *
*---------------------------------------------------------------------*
*       Print table tt_ep with the ALV                                *
*---------------------------------------------------------------------*
FORM print_ep.

  DATA: lt_fieldcat  TYPE slis_t_fieldcat_alv,  "Field catalog
        lt_alv_event TYPE slis_t_event, "Table of events to perform
        l_repid      TYPE sy-repid,    "Report-Name
        l_layout     TYPE slis_layout_alv,
        l_print      TYPE slis_print_alv.

  DATA lt_sort       TYPE slis_t_sortinfo_alv.

*--->>> EOL-0083 24.04.2024
  DATA: lt_bseg TYPE TABLE OF bseg.

  LOOP AT gl_tab_alv ASSIGNING FIELD-SYMBOL(<fs_tab_alv>).
    DATA(lv_tabix) = sy-tabix.
    AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
     ID 'GSBER' FIELD <fs_tab_alv>-gsber
     ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      DELETE gl_tab_alv INDEX lv_tabix.
    ENDIF.
  ENDLOOP.

  IF s_gsber IS NOT INITIAL OR s_prctr IS NOT INITIAL.
    LOOP AT gl_tab_alv ASSIGNING <fs_tab_alv>.
      SELECT gsber prctr
        FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE lt_bseg
        WHERE bukrs = <fs_tab_alv>-bukrs AND
              belnr = <fs_tab_alv>-belnr AND
              gjahr = <fs_tab_alv>-gjahr.
      LOOP AT lt_bseg INTO DATA(ls_bseg) WHERE prctr IS NOT INITIAL.
        <fs_tab_alv>-prctr = ls_bseg-prctr.
        EXIT.
      ENDLOOP.
    ENDLOOP.

    DELETE gl_tab_alv WHERE gsber NOT IN s_gsber OR
                            prctr NOT IN s_prctr.
  ENDIF.
*---<<<

  l_repid = sy-repid.

* Create Table lt_alv_event
  PERFORM append_event USING    slis_ev_top_of_page 'TOP_OF_PAGE'
                       CHANGING lt_alv_event.

* Create field catalog lt_fieldcat
  PERFORM create_fieldcat CHANGING lt_fieldcat.

* Create layout for ALV
  PERFORM create_layout CHANGING l_layout.


* Create print option
*  PERFORM create_print CHANGING l_print.

* Print tab_alv
  IF cf_fot_common=>create_system_utility( )->is_cloud( ).
    PERFORM create_sort CHANGING lt_sort.

    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = l_repid
        it_fieldcat        = lt_fieldcat
        i_save             = 'A'
        is_layout          = l_layout
        it_events          = lt_alv_event
        is_print           = l_print
        i_default          = ''
        it_sort            = lt_sort
      TABLES
        t_outtab           = gl_tab_alv.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = l_repid
        it_fieldcat        = lt_fieldcat
        i_save             = 'A'
        is_layout          = l_layout
        it_events          = lt_alv_event
        is_print           = l_print
      TABLES
        t_outtab           = gl_tab_alv.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM create_layout                                            *
*---------------------------------------------------------------------*
*  -->  c_layout                                                      *
*---------------------------------------------------------------------*
FORM create_layout CHANGING c_layout TYPE slis_layout_alv.
  c_layout-group_change_edit = 'X'.    "Aufbereitungsoptionen änderbar
  c_layout-no_totalline = 'X'.
  c_layout-min_linesize = 135.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM create_print                                             *
*---------------------------------------------------------------------*
FORM create_print CHANGING c_print TYPE slis_print_alv.
* c_print-print = 'X'.
  c_print-no_print_selinfos  = 'X'.
  c_print-no_print_listinfos = 'X'.
  c_print-no_coverpage       = 'X'.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM append_event                                             *
*---------------------------------------------------------------------*
*  -->  l_name           Event-name                                   *
*  -->  l_form           Form-name                                    *
*---------------------------------------------------------------------*
*  <--  lt_event         Table of events                              *
*---------------------------------------------------------------------*
FORM append_event USING    u_name   TYPE slis_alv_event-name
                           u_form   TYPE slis_alv_event-form
                  CHANGING ct_event TYPE slis_t_event.

  DATA: l_alv_event TYPE slis_alv_event.

  l_alv_event-name = u_name.
  l_alv_event-form = u_form.
  APPEND l_alv_event TO ct_event.
ENDFORM.



*---------------------------------------------------------------------*
*       FORM create_fieldcat                                          *
*---------------------------------------------------------------------*
*       Create Field catalog with field descriptions                  *
*---------------------------------------------------------------------*
*  -->  ct_fieldcat                                                   *
*---------------------------------------------------------------------*
FORM create_fieldcat CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: l_fieldcat TYPE slis_fieldcat_alv,        "field string
        l_repid    TYPE sy-repid.         "Report name

  l_repid = sy-repid.

* Append some fields to ct_fieldcat
  PERFORM append_fieldcat TABLES ct_fieldcat USING:
    'UMKRS'   'T007F',
    'LOHNIND' 'RFUMS_ALV',
    'DEKR'    'RFUMS_ALV',
    'DMSHB'   'RFUMS_ALV',
    'MLDWAER' 'RFUMS_ALV',
    'STCEG'   'BSEG',
    'XEGDR'   'BSEG',
    'XEGSRV'  'ASL_ITEM',                                   "1384895
    'XEGCOS'  'ASL_ITEM',                                   "2854595
    'STCEG_ORIG'  'ASL_ITEM',                               "2854595
    'BUZEI'   'BSEG',
    'BSCHL'   'BSEG',
    'KOART'   'BSEG',
    'UMSKZ'   'BSEG',
    'UMSKS'   'BSEG',                                       "1434854
    'REBZT'   'BSEG',                                       "1434854
    'OPBEL'   'FOT_FKK_ECSL_OUT',                           "1465562
    'LFDNR'   'FOT_FKK_ECSL_OUT',                           "1465562
    'SHKZG'   'BSEG',
    'GSBER'   'BSEG',
    'TAX_COUNTRY'  'BSEG',
    'MWSKZ'   'BSEG',
    'TXDAT_FROM'  'BSEG',
    'DMBTR'   'BSEG',
    'WRBTR'   'BSEG',
    'HWBAS'   'BSEG',
    'FWBAS'   'BSEG',
    'VALUT'   'BSEG',
    'ZUONR'   'BSEG',
    'SGTXT'   'BSEG',
    'KOKRS'   'BSEG',
    'KOSTL'   'BSEG',
    'AUFNR'   'BSEG',
    'PRCTR'   'BSEG',
    'VBELN'   'BSEG',
    'VBEL2'   'BSEG',
    'POSN2'   'BSEG',
    'KUNNR'   'BSEG',
    'ZFBDT'   'BSEG',
    'EGLLD'   'BSEG',
    'EGBLD'   'BSEG',
    'STBUK'   'BSEG',
    'NAME1_ORIG'  'ASL_ITEM',                               "2854595
    'NAME1'   'KNA1'.                        "Note 816859

* Insert the fields of BSET into ct_fieldcat
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name   = l_repid
      i_structure_name = 'BKPF'
    CHANGING
      ct_fieldcat      = ct_fieldcat.

* Hide the most fields
  PERFORM modify_fieldcat CHANGING ct_fieldcat.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM append_fieldcat                                          *
*---------------------------------------------------------------------*
*       Append one field discription to tt_fieldcat                   *
*---------------------------------------------------------------------*
*  -->  tt_fieldcat                                                   *
*  -->  u_fieldname                                                   *
*  -->  u_ref_tabname                                                 *
*---------------------------------------------------------------------*
FORM append_fieldcat
      TABLES
        tt_fieldcat
      USING
        u_fieldname TYPE slis_fieldcat_alv-fieldname
        u_ref_tabname TYPE slis_fieldcat_alv-ref_tabname.

  DATA: l_fieldcat TYPE slis_fieldcat_alv.        "field string

  l_fieldcat-fieldname      = u_fieldname.
  l_fieldcat-ref_tabname    = u_ref_tabname.
  APPEND l_fieldcat TO tt_fieldcat.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM modify_fieldcat                                          *
*---------------------------------------------------------------------*
*       Change tabel ct_fieldcat                                      *
*---------------------------------------------------------------------*
*  -->  ct_fieldcat                                                   *
*---------------------------------------------------------------------*
FORM modify_fieldcat CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv.

  DATA l_fieldcat TYPE slis_fieldcat_alv.        "Field String

  LOOP AT ct_fieldcat INTO l_fieldcat.
    IF cf_fot_common=>create_system_utility( )->is_cloud( ).
      IF l_fieldcat-fieldname = 'BUZEI'.
        l_fieldcat-col_pos = 1.
      ELSEIF l_fieldcat-fieldname = 'XEGCOS'.
        l_fieldcat-col_pos = 2.
      ELSEIF l_fieldcat-fieldname = 'XEGDR'.
        l_fieldcat-col_pos = 3.
      ELSEIF l_fieldcat-fieldname = 'STCEG'.
        l_fieldcat-col_pos = 4.
      ELSEIF l_fieldcat-fieldname = 'DMSHB'.
        l_fieldcat-col_pos = 5.
      ELSEIF l_fieldcat-fieldname = 'BUKRS'.
        l_fieldcat-col_pos = 6.
      ELSEIF l_fieldcat-fieldname = 'BELNR'.
        l_fieldcat-col_pos = 7.
      ELSEIF l_fieldcat-fieldname = 'GJAHR'.
        l_fieldcat-col_pos = 8.
      ELSEIF l_fieldcat-fieldname = 'MONAT'.
        l_fieldcat-col_pos = 9.
      ELSEIF l_fieldcat-fieldname = 'KUNNR'.
        l_fieldcat-col_pos = 10.
      ELSEIF l_fieldcat-fieldname = 'MWSKZ'.
        l_fieldcat-col_pos = 11.
      ELSE.
        l_fieldcat-no_out = 'X'.         "Do not display
      ENDIF.
      IF l_fieldcat-fieldname = 'DMSHB'.
        l_fieldcat-do_sum = 'X'.
      ENDIF.
    ELSE.
      IF ( l_fieldcat-fieldname     <> 'BELNR'     "Document number
           AND l_fieldcat-fieldname <> 'BUDAT'     "Date
           AND l_fieldcat-fieldname <> 'MONAT'     "Month
           AND l_fieldcat-fieldname <> 'GJAHR'     "Year
           AND l_fieldcat-fieldname <> 'STCEG'     "VAT registr. number
           AND l_fieldcat-fieldname <> 'LOHNIND'   "Wage indicator
           AND l_fieldcat-fieldname <> 'XEGDR'     "Triangle business
           AND l_fieldcat-fieldname <> 'XEGSRV'    "Service   "1384895
           AND l_fieldcat-fieldname <> 'XEGCOS'    "Call-off Stock EU   "2854595
           AND l_fieldcat-fieldname <> 'BUZEI'     "Line item
           AND l_fieldcat-fieldname <> 'DMSHB'     "Goods value
           AND l_fieldcat-fieldname <> 'BUKRS' ).  "Company Code
        l_fieldcat-no_out = 'X'.         "Do not display
      ENDIF.
    ENDIF.

    IF ( NOT l_fieldcat-key IS INITIAL ).
      CLEAR l_fieldcat-key.            "No key field
    ENDIF.

    CASE l_fieldcat-fieldname.         "Define Currencies
      WHEN 'FWBAS'.
        l_fieldcat-cfieldname = 'WAERS'.
      WHEN 'WRBTR'.
        l_fieldcat-cfieldname = 'WAERS'.
      WHEN 'DMSHB'.
        l_fieldcat-cfieldname = 'MLDWAER'.
      WHEN 'HWBAS'.
        l_fieldcat-cfieldname = 'HWAER'.
      WHEN 'DMBTR'.
        l_fieldcat-cfieldname = 'HWAER'.
    ENDCASE.

    IF l_fieldcat-fieldname = 'DUEFL'. "We don´t need 'DUEFL'
      DELETE ct_fieldcat.
    ELSE.
      MODIFY ct_fieldcat FROM l_fieldcat.
    ENDIF.

  ENDLOOP.
ENDFORM.

FORM create_sort CHANGING ct_sort TYPE slis_t_sortinfo_alv.
  DATA: ls_sort TYPE slis_sortinfo_alv.

  CLEAR ls_sort.
  ls_sort-fieldname = 'BUKRS'.
  ls_sort-up        = 'X'.
  ls_sort-group     = '*'.
  ls_sort-subtot    = 'X'.
  ls_sort-spos      = 1.
  APPEND ls_sort TO ct_sort.
  CLEAR ls_sort.
  ls_sort-fieldname = 'STCEG'.
  ls_sort-up        = 'X'.
  ls_sort-group     = space.
  ls_sort-subtot    = 'X'.
  ls_sort-spos      = 2.
  APPEND ls_sort TO ct_sort.
  CLEAR ls_sort.
  ls_sort-fieldname = 'XEGCOS'.
  ls_sort-up        = 'X'.
  ls_sort-group     = space.
  ls_sort-subtot    = 'X'.
  ls_sort-spos      = 3.
  APPEND ls_sort TO ct_sort.
  CLEAR ls_sort.
  ls_sort-fieldname = 'XEGDR'.
  ls_sort-up        = 'X'.
  ls_sort-group     = space.
  ls_sort-subtot    = 'X'.
  ls_sort-spos      = 4.
  APPEND ls_sort TO ct_sort.
ENDFORM.
