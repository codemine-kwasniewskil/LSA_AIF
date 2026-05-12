*&---------------------------------------------------------------------*
*& Report /THKR/AIF_MSG_READ
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/aif_msg_read LINE-SIZE 255.
*&---------------------------------------------------------------------*
* Gereon Koks  16.5.2019  T-Systems
*&---------------------------------------------------------------------*
* Testdatei für AIF aufgrund von Nachrichten erzeugen.
*&---------------------------------------------------------------------*
TABLES: /aif/pers_qmsg.
*&---------------------------------------------------------------------*
DATA: l_/aif/pers_qmsg  TYPE /aif/pers_qmsg,
      lr_appl_engine    TYPE REF TO /aif/if_application_engine,
      ls_xmlparse       TYPE /aif/xmlparse_data,
      lv_sxmsguid       TYPE sxmsguid,
      lv_ifdirection    TYPE /aif/ifdirection,
      lt_return         TYPE STANDARD TABLE OF bapiret2,
      lref_data_src     TYPE REF TO data,
      lref_data_trg     TYPE REF TO data,

      lv_transform_data TYPE flag,
      lv_index(3)       TYPE n,
      lv_feld(8),
      ls_dd03l          TYPE dd03l,
      ls_/aif/t_finf    TYPE /aif/t_finf,
      gv_nr             TYPE string,
* Wurde in eine Sub-Tabelle abgestiegen ?
      gv_sub.
*&---------------------------------------------------------------------*
FIELD-SYMBOLS: <ls_src>  TYPE data,
               <ls_trg>  TYPE any,
               <gs_any>  TYPE any,
               <gs_line> TYPE any.
*&---------------------------------------------------------------------*
TYPES:
* Polypoint-Dateiformat
  BEGIN OF ts_file,
    feld_001(40),
    feld_002(30),
    feld_003(30),
    feld_004(30),
    feld_005(30),
    feld_006(30),
    feld_007(30),
    feld_008(30),
    feld_009(30),
    feld_010(30),
    feld_011(30),
    feld_012(30),
    feld_013(30),
    feld_014(30),
    feld_015(30),
    feld_016(30),
    feld_017(30),
    feld_018(30),
    feld_019(30),
    feld_020(30),
    feld_021(30),
    feld_022(30),
    feld_023(30),
    feld_024(30),
    feld_025(30),
    feld_026(30),
    feld_027(30),
    feld_028(30),
    feld_029(30),
    feld_030(30),
    feld_031(30),
    feld_032(30),
    feld_033(30),
    feld_034(30),
    feld_035(30),
    feld_036(30),
    feld_037(30),
    feld_038(30),
    feld_039(30),
    feld_040(30),
    feld_041(30),
    feld_042(30),
    feld_043(30),
    feld_044(30),
    feld_045(30),
    feld_046(30),
    feld_047(30),
    feld_048(30),
    feld_049(30),
    feld_050(30),
    feld_051(30),
    feld_052(30),
    feld_053(30),
    feld_054(30),
    feld_055(30),
    feld_056(30),
    feld_057(30),
    feld_058(30),
    feld_059(30),
    feld_060(30),
    feld_061(30),
    feld_062(30),
    feld_063(30),
    feld_064(30),
    feld_065(30),
    feld_066(30),
    feld_067(30),
    feld_068(30),
    feld_069(30),
    feld_070(30),
    feld_071(30),
    feld_072(30),
    feld_073(30),
    feld_074(30),
    feld_075(30),
    feld_076(30),
    feld_077(30),
    feld_078(30),
    feld_079(30),
    feld_080(30),
    feld_081(30),
    feld_082(30),
    feld_083(30),
    feld_084(30),
    feld_085(30),
    feld_086(30),
    feld_087(30),
    feld_088(30),
    feld_089(30),
    feld_090(30),
    feld_091(30),
    feld_092(30),
    feld_093(30),
    feld_094(30),
    feld_095(30),
    feld_096(30),
    feld_097(30),
    feld_098(30),
    feld_099(30),
    feld_100(30),
  END OF ts_file.

TYPES:
  tt_file TYPE TABLE OF ts_file.

DATA:
  lt_file TYPE TABLE OF ts_file,
  ls_file TYPE ts_file.
TYPE-POOLS:
  slis.    " Datentypen für Listviewer/Grid

* Deklarationen für ALV-List/Grid-View
DATA:
  lt_fieldcat TYPE slis_t_fieldcat_alv,  "Tabelle ohne Kopfzeile
  ls_fieldcat TYPE slis_fieldcat_alv,
  ls_layout   TYPE slis_layout_alv.      "Layoutstruktur
DATA:
  lc_repid    LIKE sy-repid,
  ln_index(2) TYPE n.
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b_sel WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: p_msggui FOR  /aif/pers_qmsg-msgguid.
  SELECT-OPTIONS: p_status FOR  /aif/pers_qmsg-status.
*  PARAMETERS:     p_user   TYPE /aif/create_user.
  SELECT-OPTIONS: p_date   FOR  /aif/pers_qmsg-create_date.
  SELECT-OPTIONS: p_time   FOR  /aif/pers_qmsg-create_time.
  PARAMETERS:     p_ns     TYPE /aif/pers_qmsg-ns.
  PARAMETERS:     p_ifname TYPE /aif/pers_qmsg-ifname.
  PARAMETERS:     p_ifver  TYPE /aif/pers_qmsg-ifversion.
SELECTION-SCREEN END OF BLOCK b_sel.
*&---------------------------------------------------------------------*
* Nachrichten-Tabelle aufgrund von Selektions-Attributen durchlesen.
* Die GUID wird benötigt.
SELECT SINGLE * FROM /aif/pers_qmsg INTO l_/aif/pers_qmsg
  WHERE msgguid     IN p_msggui
    AND status      IN p_status
*    AND create_user =  p_user
    AND create_date IN p_date
    AND create_time IN p_time
    AND ns          =  p_ns
    AND ifname      =  p_ifname
    AND ifversion   =  p_ifver.
*&---------------------------------------------------------------------*
IF sy-subrc = 0.
*&---------------------------------------------------------------------*
  PERFORM nachricht_parameter.
  PERFORM nachricht_lesen.
*&---------------------------------------------------------------------*
  PERFORM schnittstelle_info.

  SELECT * FROM /aif/t_finf INTO ls_/aif/t_finf
    WHERE ns        = p_ns
      AND ifname    = p_ifname
      AND ifversion = p_ifver.

    PERFORM header_underline.
    PERFORM header USING 'Inbound' '0' ''.
    gv_nr = '1.0'.
    PERFORM struktur USING ls_/aif/t_finf-ddicstructureraw <ls_src>.

    PERFORM header_underline.
    PERFORM header USING 'Outbound' '0' ''.
    gv_nr = '2.0'.
    PERFORM struktur USING ls_/aif/t_finf-ddicstructure <ls_trg>.
  ENDSELECT.
*&---------------------------------------------------------------------*
  PERFORM alv_show.
*&---------------------------------------------------------------------*
ENDIF.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form schnittstelle_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM schnittstelle_info .
*&---------------------------------------------------------------------*
* Schnittstellen-Info's
  CLEAR ls_file.
  ls_file-feld_001 = 'Schnittstelle'.
  APPEND ls_file TO lt_file.

  CLEAR ls_file.
  ls_file-feld_001 = 'System:'.
  CONCATENATE sy-sysid '(' sy-mandt ')' INTO ls_file-feld_002.
  APPEND ls_file TO lt_file.

  CLEAR ls_file.
  ls_file-feld_001 = 'Namensraum:'.
  ls_file-feld_002 = p_ns.
  APPEND ls_file TO lt_file.

  CLEAR ls_file.
  ls_file-feld_001 = 'Schnittstellennamen:'.
  ls_file-feld_002 = p_ifname.
  APPEND ls_file TO lt_file.

  CLEAR ls_file.
  ls_file-feld_001 = 'Version:'.
  ls_file-feld_002 = p_ifver.
  APPEND ls_file TO lt_file.

*  CLEAR ls_file.
*  ls_file-feld_001 = 'User:'.
*  ls_file-feld_002 = p_user.
*  APPEND ls_file TO lt_file.

  CLEAR ls_file.
  ls_file-feld_001 = 'Datum:'.
  WRITE p_date-low TO ls_file-feld_002.
  APPEND ls_file TO lt_file.

  CLEAR ls_file.
  ls_file-feld_001 = 'Uhrzeit:'.
  WRITE p_time-low TO ls_file-feld_002.
  APPEND ls_file TO lt_file.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form alv_show
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_show .
*&---------------------------------------------------------------------*
* Feldkatalog ALV-Liste
  REFRESH lt_fieldcat.
*&---------------------------------------------------------------------*
* Generische Zeile aufbauen
  DO 100 TIMES.
    CLEAR ls_fieldcat.
    lv_index = sy-index.
    CONCATENATE 'FELD_' lv_index INTO lv_feld.
    ls_fieldcat-fieldname    = lv_feld.
    ls_fieldcat-seltext_m    = ''.
    ls_fieldcat-seltext_l    = ''.
    ls_fieldcat-just         = 'L'.
    ls_fieldcat-key          = 'X'.
    APPEND ls_fieldcat TO lt_fieldcat.
  ENDDO.
*----------------------------------------------------------------------*
* Layout
  CLEAR ls_layout.
  ls_layout-colwidth_optimize = 'X'.
  ls_layout-zebra             = 'X'.
  ls_layout-expand_all        = 'X'.
  ls_layout-coltab_fieldname  = 'SPECIALCOL_ALV'.
*----------------------------------------------------------------------*
* ALV anzeigen
  lc_repid = sy-repid.
*----------------------------------------------------------------------*
  DATA lv_title TYPE lvc_title.

  lv_title = 'AIF Mapping Übersicht'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = lc_repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE_ALV'
      i_grid_title             = lv_title
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
      i_save                   = ' '
    TABLES
      t_outtab                 = lt_file
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

* Absprung in FORM USER_COMMAND zur Behandlung der OK-Codes


  IF sy-subrc <> 0.
    MESSAGE a016(pn) WITH 'Programmfehler in ALV-Funktion'.
  ENDIF.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form nachricht_lesen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM nachricht_lesen .
*&---------------------------------------------------------------------*
* Die Engine wird zum Lesen der Nachrichten benötigt.
  lr_appl_engine = /aif/cl_aif_engine_factory=>get_engine(
        iv_ns            = p_ns
        iv_ifname        = p_ifname
        iv_ifversion     = p_ifver
           ).

  lv_sxmsguid = l_/aif/pers_qmsg-msgguid.

* Nachrichten zur GUID lesen
  CALL METHOD lr_appl_engine->read_msg_from_persistency
    EXPORTING
      iv_msgguid  = lv_sxmsguid
      iv_ns       = p_ns
      iv_ifname   = p_ifname
      iv_ifver    = p_ifver
    CHANGING
      cs_xmlparse = ls_xmlparse.

  ASSIGN ls_xmlparse-xi_data->* TO <ls_src>.
*&---------------------------------------------------------------------*
  lv_ifdirection    = 'I'.
  lv_transform_data = 'X'.

  CREATE DATA lref_data_trg TYPE ('/thkr/s_aif_sap').
  ASSIGN lref_data_trg->* TO <ls_trg>.

  CALL FUNCTION '/AIF/FILE_TRANSFORM_DATA'
    EXPORTING
      ns                     = p_ns
      ifname                 = p_ifname
      ifversion              = p_ifver
      xi_flag                = abap_true
      ifdirection            = lv_ifdirection
      transform_data         = lv_transform_data
    IMPORTING
      out_struct             = <ls_trg>
    TABLES
      return_tab             = lt_return
    CHANGING
      raw_struct             = <ls_src>
    EXCEPTIONS
      not_found              = 1
      customizing_incomplete = 2
      max_errors_reached     = 3
      cancel                 = 4
      OTHERS                 = 5.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form nachricht_parameter
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM nachricht_parameter .
*&---------------------------------------------------------------------*
  WRITE: /1 'msgguid       :', l_/aif/pers_qmsg-msgguid.
  WRITE: /1 'runid         :', l_/aif/pers_qmsg-runid.
  WRITE: /1 'status        :', l_/aif/pers_qmsg-status.
  WRITE: /1 'create_user   :', l_/aif/pers_qmsg-create_user.
  WRITE: /1 'create_user   :', l_/aif/pers_qmsg-create_date.
  WRITE: /1 'create_time   :', l_/aif/pers_qmsg-create_time.
  WRITE: /1 'queue_ns      :', l_/aif/pers_qmsg-queue_ns.
  WRITE: /1 'queue_name    :', l_/aif/pers_qmsg-queue_name.
  WRITE: /1 'ns            :', l_/aif/pers_qmsg-ns.
  WRITE: /1 'ifname        :', l_/aif/pers_qmsg-ifname.
  WRITE: /1 'ifversion     :', l_/aif/pers_qmsg-ifversion.
  WRITE: /1 'packnr        :', l_/aif/pers_qmsg-packnr.
  WRITE: /1 'ts_msg_crea   :', l_/aif/pers_qmsg-ts_msg_crea.
  WRITE: /1 'ts_pers_run   :', l_/aif/pers_qmsg-ts_pers_run.
  WRITE: /1 'ts_pers_proc  :', l_/aif/pers_qmsg-ts_pers_proc.
  WRITE: /1 'ns_repr_action:', l_/aif/pers_qmsg-ns_repr_action.
  WRITE: /1 'repr_action   :', l_/aif/pers_qmsg-repr_action.
  ULINE.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_FILE
*&      --> P_
*&---------------------------------------------------------------------*
FORM header  USING    VALUE(p_header)
                      p_nr
                      p_type. "Tabelle oder Zeile
*&---------------------------------------------------------------------*
* Überschrift des Objektes (HEADER, LINE, FOOTER, GP, AO, ...)
*&---------------------------------------------------------------------*
  DATA: lv_praefix TYPE string.
*&---------------------------------------------------------------------*
  CLEAR ls_file.

  IF p_nr = '1'.
    CONCATENATE gv_nr ')' INTO lv_praefix.
    CONDENSE lv_praefix NO-GAPS.
    CONCATENATE lv_praefix p_header '(' p_type ')' INTO ls_file-feld_001 SEPARATED BY space.
  ELSE.
    CONCATENATE p_header p_type INTO ls_file-feld_001.
  ENDIF.

  APPEND ls_file TO lt_file.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form struktur
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> <LS_SRC>
*&---------------------------------------------------------------------*
FORM struktur  USING    VALUE(p_struktur)
                        p_ls_data.
*&---------------------------------------------------------------------*
* Es werden
* 1.) die Überschrift
* 2.) die Kopfzeile
* 3.) die Werte der Zeile
* ausgegeben.
*&---------------------------------------------------------------------*
* P_STRUKTUR  Struktur
* P_LS_DATA   <src> bzw <trg>
*&---------------------------------------------------------------------*
  FIELD-SYMBOLS: <ls_any>  TYPE any,
                 <ls_line> TYPE any,
                 <ls_sub>  TYPE any.
*&---------------------------------------------------------------------*
  DATA: lv_anz       TYPE i,
        ls_dd03l     TYPE dd03l,
        ls_dd40l     TYPE dd40l,
        flg_sub,
        flg_others,
        lv_index(3)  TYPE n,
        p_index_n(3) TYPE c,
        p_nr         TYPE string.
*&---------------------------------------------------------------------*
  CLEAR lv_index.
*&---------------------------------------------------------------------*
* Erstmal alle Felder auf der obersten Ebene.
* Wenn es eine Sub-Tabelle gibt, muss in die nach dem ersten Satz abgestiegen werden.
  SELECT * FROM dd03l INTO ls_dd03l
    WHERE tabname = p_struktur
      AND ( datatype = 'TTYP' OR datatype = 'STRU' )
      AND fieldname <> 'RKO_POLIZEI'
    order by position.
*&---------------------------------------------------------------------*
    CASE ls_dd03l-datatype.
*&---------------------------------------------------------------------*
      WHEN 'TTYP'. "Tabelle
* Ist die Sub-Tabelle gefüllt ?
        ASSIGN COMPONENT ls_dd03l-fieldname OF STRUCTURE p_ls_data TO <ls_sub>.

        IF sy-subrc = 0 AND NOT <ls_sub> IS INITIAL.
          PERFORM header_underline.
          PERFORM praefix_add CHANGING gv_nr.
          PERFORM header USING ls_dd03l-fieldname '1' 'Tabelle'.

          SELECT * FROM dd40l INTO ls_dd40l
            WHERE typename = ls_dd03l-rollname.

            PERFORM header_line USING ls_dd03l-fieldname
                                      ls_dd40l-rowtype
                                      '1'
                                      p_ls_data
                                      'TTYP'.
          ENDSELECT.
        ENDIF.
*&---------------------------------------------------------------------*
      WHEN 'STRU'. "Struktur
        PERFORM header_underline.
        PERFORM praefix_add CHANGING gv_nr.
        PERFORM header USING ls_dd03l-fieldname '1' 'Zeile'.
        PERFORM header_line USING ls_dd03l-fieldname
                                  ls_dd03l-rollname
                                  '1'
                                  p_ls_data
                                  'STRU'.
*&---------------------------------------------------------------------*
      WHEN ''.     "Include
*&---------------------------------------------------------------------*
      WHEN OTHERS. "Feld
*&---------------------------------------------------------------------*
    ENDCASE.
*&---------------------------------------------------------------------*
  ENDSELECT.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form header_line
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DD03L_ROLLNAME
*&---------------------------------------------------------------------*
FORM header_line  USING    p_fieldname
                           p_tabname
                           p_nr
                           p_ls_data
                           p_typ. "'TTYP' oder 'STRU'
*&---------------------------------------------------------------------*
* 1.) HEADER_LINE ausgeben.
* 2.) Wenn Sub-Tabellen vorhanden, dann rekursiv absteigen.
*&---------------------------------------------------------------------*
* P_FIELDNAME Name des Feldes (der Struktur), das ausgegeben werden soll
* P_ROLLNAME  Strukur, die angezeigt werden soll
* P_LS_DATA   Die Daten
*&---------------------------------------------------------------------*
  FIELD-SYMBOLS: <ls_any>   TYPE any,
                 <ls_sub>   TYPE any,
                 <ls_line>  TYPE any,
                 <ls_value> TYPE any.
*&---------------------------------------------------------------------*
  DATA: ls_dd03l      TYPE dd03l,
        ls_dd40l      TYPE dd40l,
        ls_dd03l_line TYPE dd03l,
        lv_feld(8),
        lv_index      TYPE i.
*&---------------------------------------------------------------------*
  CLEAR ls_file.
*&---------------------------------------------------------------------*
  PERFORM header_line_kopf USING p_tabname.
*&---------------------------------------------------------------------*
* Werte eintragen
* Eine Tabelle oder eine Strukur wird ausgelesen.
  ASSIGN COMPONENT p_fieldname OF STRUCTURE p_ls_data TO <ls_any>.

  IF sy-subrc = 0.
    CASE p_typ.
      WHEN 'TTYP'.
        CLEAR lv_index.
        LOOP AT <ls_any> ASSIGNING <ls_line>.
          ADD 1 TO lv_index.
* Kopf nur erneut ausgeben, wenn in Sub-Tabelle abgestiegen wurde.
* Das ist erst nach dem ersten Durchlauf bekannt.
          IF gv_sub = 'X'.
            PERFORM header USING p_fieldname '1' 'Tabelle'.
            PERFORM header_line_kopf USING p_tabname.
            CLEAR gv_sub.
          ENDIF.

          PERFORM line_create USING <ls_line> p_tabname lv_index.
        ENDLOOP.
* Nach der Schleife alles wie vorher.
        CLEAR gv_sub.
      WHEN 'STRU'.
        PERFORM line_create USING <ls_any> p_tabname 1.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form line_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_LINE>
*&---------------------------------------------------------------------*
FORM line_create  USING    p_ls_line
                           p_tabname
                           p_index.
*&---------------------------------------------------------------------*
* 1.) Zeile mit ihren Werten ausgeben.
* 2.) Feld der Zeile kann Tabelle sein: Dann rekursiv absteigen.
*&---------------------------------------------------------------------*
* P_LS_LINE Daten
* P_INDEX     Zeile der Tabelle
*&---------------------------------------------------------------------*
  FIELD-SYMBOLS: <ls_any>   TYPE any,
                 <ls_value> TYPE any,
                 <ls_sub>   TYPE any.
*&---------------------------------------------------------------------*
  DATA: ls_dd03l_line TYPE dd03l,
        ls_dd40l      TYPE dd04l,
        lv_feld(8),
        p_index_n(3)  TYPE c.
*&---------------------------------------------------------------------*
  CLEAR ls_file.
*&---------------------------------------------------------------------*
* 1.) Zeile mit ihren Werten ausgeben.
*&---------------------------------------------------------------------*
  SELECT * FROM dd03l INTO ls_dd03l_line
    WHERE tabname   =  p_tabname
      AND fieldname <> '.INCLUDE'
      AND fieldname <> '.INCLU--AP'
      AND datatype  <> 'TTYP'
      AND datatype  <> 'STRU'
      ORDER BY position.

* Nummerierung
    IF sy-dbcnt = 1.
      lv_feld = 'FELD_001'.
      ASSIGN COMPONENT lv_feld OF STRUCTURE ls_file TO <ls_any>.
      p_index_n = p_index.
      CONCATENATE p_index_n '.' INTO <ls_any>.
    ENDIF.

* In welches Feld ?
    lv_index = sy-dbcnt + 1.
    CONCATENATE 'FELD_' lv_index INTO lv_feld.
    ASSIGN COMPONENT lv_feld OF STRUCTURE ls_file TO <ls_any>.

* Welcher Wert ?
    ASSIGN COMPONENT ls_dd03l_line-fieldname OF STRUCTURE p_ls_line TO <ls_value>.
    <ls_any> = <ls_value>.
  ENDSELECT.

  APPEND ls_file TO lt_file.
*&---------------------------------------------------------------------*
* 2.) Abstieg in Sub-Tabelle (Wenn es eine gibt.)
* In jeder Zeile, die ausgegeben wird, kann eine Sub-Tabelle
* enthalten sein.
*&---------------------------------------------------------------------*
  SELECT * FROM dd03l INTO ls_dd03l
    WHERE tabname   = p_tabname
      AND datatype  = 'TTYP'
      ORDER BY position.

    SELECT * FROM dd40l INTO ls_dd40l
      WHERE typename = ls_dd03l-rollname.

* In die Sub-Tabelle absteigen (aber nur, wenn auch was drin ist)
      ASSIGN COMPONENT ls_dd03l-fieldname OF STRUCTURE p_ls_line TO <ls_sub>.

* Ist die Sub-Tabelle gefüllt ?
* Sonst kein Abstieg.
      IF sy-subrc = 0 AND NOT <ls_sub> IS INITIAL.
        PERFORM praefix_sub CHANGING gv_nr.
        PERFORM header USING ls_dd03l-fieldname '1' 'Tabelle'.
        PERFORM header_line USING ls_dd03l-fieldname
                                  ls_dd40l-domname
                                  '1'
                                  p_ls_line
                                  'TTYP'.
        PERFORM praefix_back CHANGING gv_nr.

* Kennzeichen, dass abgestiegen wurde.
* Beim Aufstieg, muss dann der Header der übergeordneten Tabelle erneut angezeigt werden.
        gv_sub = 'X'.
      ENDIF.
    ENDSELECT.
  ENDSELECT.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
FORM set_pf_status USING it_option.
*&---------------------------------------------------------------------*
  SET PF-STATUS 'STANDARD'.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form praefix_add
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- '3.4.2'
*&---------------------------------------------------------------------*
FORM praefix_add  CHANGING p_praefix.
*&---------------------------------------------------------------------*
* 3.4.2 => 3.4.3
*&---------------------------------------------------------------------*
  DATA: lv_last    TYPE i,
        lv_praefix TYPE string,
        ls_elem    TYPE string.
*&---------------------------------------------------------------------*
  DATA(it_elem) = VALUE stringtab( ).
  SPLIT p_praefix AT '.' INTO TABLE it_elem.
  DESCRIBE TABLE it_elem LINES lv_last.

  IF lv_last <= 1.
    ADD 1 TO p_praefix.
  ELSE.
    READ TABLE it_elem INDEX lv_last INTO ls_elem.
    ADD 1 TO ls_elem.
    MODIFY it_elem FROM ls_elem INDEX lv_last.

    LOOP AT it_elem INTO ls_elem.
      IF sy-tabix = 1.
        lv_praefix = ls_elem.
      ELSE.
        CONCATENATE lv_praefix '.' ls_elem INTO lv_praefix.
      ENDIF.
    ENDLOOP.

    p_praefix = lv_praefix.
  ENDIF.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form praefix_sub
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_NR
*&---------------------------------------------------------------------*
FORM praefix_sub  CHANGING p_praefix.
*&---------------------------------------------------------------------*
* 3.4.2 => 3.4.2.1
*&---------------------------------------------------------------------*
  CONCATENATE p_praefix '.1'INTO p_praefix.
  CONDENSE p_praefix NO-GAPS.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form praefix_back
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GV_NR
*&---------------------------------------------------------------------*
FORM praefix_back  CHANGING p_praefix.
*&---------------------------------------------------------------------*
* 3.4.2.1 => 3.4.2
*&---------------------------------------------------------------------*
  DATA: lv_last TYPE i,
        ls_elem TYPE string.
*&---------------------------------------------------------------------*
  DATA(it_elem) = VALUE stringtab( ).
  SPLIT p_praefix AT '.' INTO TABLE it_elem.
  DESCRIBE TABLE it_elem LINES lv_last.
*&---------------------------------------------------------------------*
  LOOP AT it_elem INTO ls_elem.
    IF sy-tabix < lv_last.
      IF sy-tabix = 1.
        p_praefix = ls_elem.
      ELSE.
        CONCATENATE p_praefix '.' ls_elem INTO p_praefix.
      ENDIF.
    ENDIF.
  ENDLOOP.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form header_underline
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM header_underline .
*&---------------------------------------------------------------------*
  CLEAR ls_file.

  ls_file-feld_001 = '------------------------------'.
  ls_file-feld_002 = '------------------------------'.
  ls_file-feld_003 = '------------------------------'.
  ls_file-feld_004 = '------------------------------'.
  ls_file-feld_005 = '------------------------------'.
  ls_file-feld_006 = '------------------------------'.
  ls_file-feld_007 = '------------------------------'.
  ls_file-feld_008 = '------------------------------'.
  ls_file-feld_009 = '------------------------------'.
  ls_file-feld_010 = '------------------------------'.
  ls_file-feld_011 = '------------------------------'.
  ls_file-feld_012 = '------------------------------'.
  ls_file-feld_013 = '------------------------------'.
  ls_file-feld_014 = '------------------------------'.
  ls_file-feld_015 = '------------------------------'.
  ls_file-feld_016 = '------------------------------'.
  ls_file-feld_017 = '------------------------------'.
  ls_file-feld_018 = '------------------------------'.
  ls_file-feld_019 = '------------------------------'.
  ls_file-feld_020 = '------------------------------'.

  APPEND ls_file TO lt_file.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form header_line_kopf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_TABNAME
*&---------------------------------------------------------------------*
FORM header_line_kopf  USING    p_tabname.
*&---------------------------------------------------------------------*
* Kopf-Zeile mit allen Feldern ausgeben.
*&---------------------------------------------------------------------*
  DATA: lv_index(3) TYPE n,
        ls_dd03l    TYPE dd03l,
        ls_dd04t    TYPE dd04t,
        lv_feld(8),
        ls_file     TYPE ts_file,
        ls_file_bez TYPE ts_file.
*&---------------------------------------------------------------------*
  FIELD-SYMBOLS: <ls_any>   TYPE any.
*&---------------------------------------------------------------------*
  lv_index = 1.
*&---------------------------------------------------------------------*
* 1.) Header-Line
  SELECT * FROM dd03l INTO ls_dd03l
    WHERE tabname   =  p_tabname
      AND fieldname <> '.INCLUDE'
      AND fieldname <> '.INCLU--AP'
      AND datatype  <> 'TTYP'
      ORDER BY position.

    ADD 1 TO lv_index.
    CONCATENATE 'FELD_' lv_index INTO lv_feld.

* technischer Schlüssel
    ASSIGN COMPONENT lv_feld OF STRUCTURE ls_file TO <ls_any>.
    <ls_any> = ls_dd03l-fieldname.

* Kurzbezeichnung
    ASSIGN COMPONENT lv_feld OF STRUCTURE ls_file_bez TO <ls_any>.
    SELECT * FROM dd04t INTO ls_dd04t
      WHERE rollname   = ls_dd03l-rollname
        AND ddlanguage = 'D'.

      <ls_any> = ls_dd04t-scrtext_l.
    ENDSELECT.
  ENDSELECT.

  APPEND ls_file     TO lt_file.
  APPEND ls_file_bez TO lt_file.
*&---------------------------------------------------------------------*
ENDFORM.
