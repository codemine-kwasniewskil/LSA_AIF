*&---------------------------------------------------------------------*
*& Report  RFVITXBA                                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  /thkr/ea_text_edit NO STANDARD PAGE HEADING.
*ALV
TYPE-POOLS: slis.

TABLES: stxh,ttxbs,ttxid,ttxit.

INCLUDE <icon>.
INCLUDE <symbol>.
INCLUDE /THKR/EA_TEXT_EDIT_BAF.

CONSTANTS: gc_formname_user_command TYPE slis_formname
                        VALUE 'USER_COMMAND_REACTION'.
DATA: gt_fieldcat   TYPE slis_t_fieldcat_alv,
      gt_layout     TYPE slis_layout_alv,
      gt_sp_group   TYPE slis_t_sp_group_alv,
      gt_events     TYPE slis_t_event,
      gt_event_exit TYPE slis_t_event_exit.
* Data to be displayed
DATA: BEGIN OF gt_stxh OCCURS 0.
        INCLUDE STRUCTURE stxh.
        DATA: box,
        anz_verw(4) TYPE c.
DATA: END OF gt_stxh.

DATA: g_repid LIKE sy-repid.
DATA: gt_list_top_of_page TYPE slis_t_listheader.

DATA: img_project LIKE tstath-project.

* Report Selections
SELECT-OPTIONS p_tdob FOR stxh-tdobject
       DEFAULT 'TEXT'.
SELECT-OPTIONS p_tdname FOR stxh-tdname
       DEFAULT '/THKR/EA_*' OPTION CP.
SELECT-OPTIONS p_tdid FOR stxh-tdid
       DEFAULT 'FIKO'.
SELECT-OPTIONS p_spras FOR stxh-tdspras.
SELECTION-SCREEN SKIP 1.


SELECT-OPTIONS p_freles FOR stxh-tdfreles no-display.
SELECT-OPTIONS p_fuser FOR stxh-tdfuser.
SELECT-OPTIONS p_fdate FOR stxh-tdfdate.
SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS p_lreles FOR stxh-tdfreles no-display.
SELECT-OPTIONS p_luser FOR stxh-tdfuser.
SELECT-OPTIONS p_ldate FOR stxh-tdfdate.

SELECTION-SCREEN SKIP 1.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS p_rantyp FOR ttxbs-rantyp DEFAULT '3' NO-DISPLAY.
PARAMETERS:    p_dverw TYPE c            DEFAULT 'X' NO-DISPLAY.

* SELECTION-SCREEN END OF BLOCK 0.
DATA: g_save(1)    TYPE c,
      g_default(1) TYPE c,
      g_exit(1)    TYPE c,
      gx_variant   LIKE disvariant,
      g_variant    LIKE disvariant.

INITIALIZATION.

* Customizing-Berechtigung abfragen
  AUTHORITY-CHECK OBJECT 'S_IMG_ACTV'
           ID 'PROJAUTH' FIELD img_project
           ID 'ACTVT' FIELD '02'
           ID 'IMG_ACTIV' FIELD 'ACT'.
  IF sy-subrc NE 0.
    MESSAGE e300(sf).
  ENDIF.
  g_repid = sy-repid.
  PERFORM fieldcat_init USING gt_fieldcat[].
  PERFORM eventtab_build USING gt_events[].

  g_save = 'A'.
  PERFORM variant_init.
  gx_variant = g_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = gx_variant-variant.
  ENDIF.
* Process on value request
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

* PAI
AT SELECTION-SCREEN.
  PERFORM pai_of_selection_screen.

START-OF-SELECTION.

  PERFORM selection.

END-OF-SELECTION.
  PERFORM layout_build USING gt_layout.
* Call ABAP/4 List Viewer
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
*     i_callback_user_command  = gc_formname_user_command
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_structure_name         = 'STXH'
      is_layout                = gt_layout
      it_fieldcat              = gt_fieldcat[]
*     IT_EXCLUDING             =
*     it_special_groups        = gt_sp_group[]
*     IT_SORT                  =
*     IT_FILTER                =
*     IS_SEL_HIDE              =
*     i_default                = g_default
      i_save                   = g_save
      is_variant               = g_variant
      it_events                = gt_events[]
*     it_event_exit            = gt_event_exit
*     IS_PRINT                 =
*     I_SCREEN_START_COLUMN    = 0
*     I_SCREEN_START_LINE      = 0
*     I_SCREEN_END_COLUMN      = 0
*     I_SCREEN_END_LINE        = 0
*      IMPORTING
*     E_EXIT_CAUSED_BY_CALLER  =
    TABLES
      t_outtab                 = gt_stxh.

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM variant_init.

  CLEAR g_variant.
  g_variant-report = g_repid.
ENDFORM.                               " VARIANT_INIT
**---------------------------------------------------------------------*
**       FORM F4_FOR_VARIANT                                           *
**---------------------------------------------------------------------*
**       ........                                                      *
**---------------------------------------------------------------------*
FORM f4_for_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
*     it_default_fieldcat =
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      p_vari = gx_variant-variant.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pai_of_selection_screen.

  IF NOT p_vari IS INITIAL.
    MOVE g_variant TO gx_variant.
    MOVE p_vari TO gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = g_save
      CHANGING
        cs_variant = gx_variant.
    g_variant = gx_variant.
  ELSE.
    PERFORM variant_init.
  ENDIF.
ENDFORM.                               " PAI_OF_SELECTION_SCREEN
*---------------------------------------------------------------------*
*       FORM SELECTION                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM selection.
  SELECT * FROM stxh INTO CORRESPONDING FIELDS OF TABLE gt_stxh
                     WHERE tdobject IN p_tdob
                     AND   tdname IN p_tdname
                     AND   tdid IN p_tdid
                     AND   tdspras IN p_spras
                     AND   tdfreles IN p_freles
                     AND   tdfuser IN p_fuser
                     AND   tdfdate IN p_fdate
                     AND   tdlreles IN p_lreles
                     AND   tdluser IN p_luser
                     AND   tdldate IN p_ldate
    ORDER BY tdobject tdid tdspras tdname.
  .
  IF NOT ( p_dverw IS INITIAL ).
    PERFORM proc01_data_add TABLES gt_stxh.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROC01_DATA_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_STXH  text
*----------------------------------------------------------------------*
FORM proc01_data_add TABLES p_gt_stxh STRUCTURE gt_stxh.
  TYPES:
    BEGIN OF t_ttxbs_textmodule,
      xobject TYPE ttxbs-xobject,
      xbstnm  TYPE ttxbs-xbstnm,
    END OF t_ttxbs_textmodule.

  DATA:
    lt_ttxbs_textmodule TYPE TABLE OF t_ttxbs_textmodule,
    ls_ttxbs_textmodule TYPE t_ttxbs_textmodule,
    ls_ttxbs_tm_tmp     TYPE t_ttxbs_textmodule,
    li_tabix            TYPE sytabix.

  SELECT     xobject xbstnm
    INTO     TABLE lt_ttxbs_textmodule
    FROM     ttxbs
    WHERE    ( rantyp IN p_rantyp )
      AND    ( xobject IN p_tdob )
      AND    ( xbstnm  IN p_tdname ).

  SORT lt_ttxbs_textmodule BY xobject xbstnm.


  LOOP AT p_gt_stxh.

    READ TABLE lt_ttxbs_textmodule WITH KEY xobject = p_gt_stxh-tdobject
                                            xbstnm  = p_gt_stxh-tdname
                                   BINARY SEARCH
                                   INTO ls_ttxbs_tm_tmp.

    IF sy-subrc = 0.

      p_gt_stxh-anz_verw = 1.
      li_tabix = sy-tabix + 1.
      LOOP AT lt_ttxbs_textmodule INTO ls_ttxbs_textmodule
                                  FROM li_tabix.
        IF ( ls_ttxbs_textmodule-xobject = ls_ttxbs_tm_tmp-xobject ) AND
           ( ls_ttxbs_textmodule-xbstnm  = ls_ttxbs_tm_tmp-xbstnm ).
          ADD 1 TO p_gt_stxh-anz_verw.
        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.

    ELSE.

      p_gt_stxh-anz_verw = 0.

    ENDIF.

    MODIFY p_gt_stxh.

  ENDLOOP.

ENDFORM.                               " PROC01_DATA_ADD
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM fieldcat_init USING  p_gt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDOBJECT'.
  ls_fieldcat-ref_tabname    = 'STXH'.
  ls_fieldcat-hotspot   = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDNAME'.
  ls_fieldcat-ref_tabname    = 'STXH'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDID'.
  ls_fieldcat-ref_tabname    = 'STXH'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDSPRAS'.
  ls_fieldcat-ref_tabname    = 'STXH'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  IF NOT ( p_dverw IS INITIAL ).
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ANZ_VERW'.
    ls_fieldcat-datatype    = 'I'.
    ls_fieldcat-outputlen    = 4.
    ls_fieldcat-no_out    = 'X'.
*    ls_fieldcat-hotspot   = 'X'.
    ls_fieldcat-seltext_l = 'Verwendungsnachweis für Textbaustein'(002).
    ls_fieldcat-seltext_m = 'Verwendung Textbaustein'(003).
    ls_fieldcat-seltext_l = 'Verw. Textbaustein'(004).
    APPEND ls_fieldcat TO p_gt_fieldcat.
  ENDIF.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'LOGSYS'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDTITLE'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDFRELES'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDFUSER'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDFDATE'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDFTIME'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDLRELES'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDLUSER'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDLDATE'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDLTIME'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDVERSION'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDSTYLE'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDFORM'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDHYPHENAT'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDTRANSTAT'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDOSPRAS'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDMACODE1'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDMACODE2'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDTXTLINES'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDREF'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDREFOBJ'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDREFNAME'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDREFID'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDTEXTTYPE'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDCOMPRESS'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TDOCLASS'.
  ls_fieldcat-no_out    = 'X'.
  APPEND ls_fieldcat TO p_gt_fieldcat.

ENDFORM.                               " FIELDCAT_INIT
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build USING    p_gt_layout TYPE slis_layout_alv.
  p_gt_layout-colwidth_optimize        = 'X'.
  p_gt_layout-zebra                    = 'X'.
  p_gt_layout-detail_popup             = 'X'.
  p_gt_layout-box_fieldname            = 'BOX'.
ENDFORM.                               " LAYOUT_BUILD
*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build USING p_gt_events TYPE slis_t_event.
  DATA: ls_event TYPE slis_alv_event.
*
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = p_gt_events.
  READ TABLE p_gt_events WITH KEY name = slis_ev_user_command
                         INTO ls_event.
  ls_event-form = 'USER_COMMAND_REACTION'.
  APPEND ls_event TO p_gt_events.
ENDFORM.                               " EVENTTAB_BUILD

* Behandlung der user-commands
FORM user_command_reaction USING r_ucomm LIKE sy-ucomm
                                 rs_selfield TYPE slis_selfield.
  DATA: p_gt_stxh LIKE gt_stxh OCCURS 0 WITH HEADER LINE,
        wa_stxh   LIKE p_gt_stxh,
        it_ttxbs  LIKE ttxbs OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF it_ttxid OCCURS 0,
          tdobject LIKE ttxid-tdobject,
          tdid     LIKE ttxid-tdid,
          tdtext   LIKE ttxit-tdtext,
        END OF it_ttxid.
  DATA: wa_it_ttxid LIKE it_ttxid.
  DATA: wa1_it_ttxid LIKE it_ttxid.
  DATA: feldname(20).
  DATA: l_g_repid     LIKE sy-repid,
        l_gt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: wa_l_gt_fieldcat TYPE slis_fieldcat_alv.
  DATA: ausgabe, zaehler, zaehler1 TYPE i.
  DATA: txt_copy LIKE itctc OCCURS 0 WITH HEADER LINE.
  DATA: error_flag0(1), error_flag(1) TYPE c.
  DATA: anz_mod(1),
        show(1),
        edit(1).
  DATA: l_sysubrc LIKE sy-subrc.
  DATA: antwort(1) TYPE c.
  DATA: destthead LIKE thead,
        destlines LIKE tline OCCURS 0.

  show = 'X'.
  edit = ' '.
  MOVE edit TO anz_mod.
  CASE r_ucomm.
    WHEN '&IC1'.
      READ TABLE gt_stxh INTO p_gt_stxh INDEX rs_selfield-tabindex.
      APPEND p_gt_stxh.
      GET CURSOR FIELD feldname.
      CASE feldname.
        WHEN 'GT_STXH-TDOBJECT'.
          l_g_repid = sy-repid.
* lokalen FELDKATALOG definieren
          CLEAR wa_l_gt_fieldcat.
          wa_l_gt_fieldcat-fieldname = 'TDID'.
          wa_l_gt_fieldcat-ref_tabname    = 'TTXID'.
          wa_l_gt_fieldcat-key = 'X'.
          APPEND wa_l_gt_fieldcat TO l_gt_fieldcat.
          CLEAR wa_l_gt_fieldcat.
          wa_l_gt_fieldcat-fieldname = 'TDTEXT'.
          wa_l_gt_fieldcat-ref_tabname    = 'TTXIT'.
          wa_l_gt_fieldcat-key = 'X'.
          APPEND wa_l_gt_fieldcat TO l_gt_fieldcat.
          SELECT tdobject tdid FROM ttxid
           INTO CORRESPONDING FIELDS OF wa_it_ttxid
          WHERE tdobject = p_gt_stxh-tdobject.
            SELECT SINGLE * FROM ttxit
             INTO CORRESPONDING FIELDS OF wa1_it_ttxid
             WHERE tdobject = wa_it_ttxid-tdobject
             AND   tdid     = wa_it_ttxid-tdid
             AND   tdspras  = p_gt_stxh-tdspras.
            APPEND wa1_it_ttxid TO it_ttxid.
          ENDSELECT.
          LOOP AT it_ttxid.
            IF it_ttxid <> space.
              ausgabe = 1.
            ENDIF.
          ENDLOOP.
          IF ausgabe <> 0.
            SET TITLEBAR 'TEXTID'.
            CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
              EXPORTING
                i_callback_program    = l_g_repid
                it_fieldcat           = l_gt_fieldcat[]
                i_screen_start_column = 5
                i_screen_start_line   = 5
                i_screen_end_column   = 46
                i_screen_end_line     = 15
              TABLES
                t_outtab              = it_ttxid.
          ENDIF.
        WHEN 'GT_STXH-TDNAME'.
          CALL FUNCTION 'ENQUEUE_ESSSTXT'
            EXPORTING
*             MODE_STXH      = 'E'
              mandt          = sy-mandt
              tdobject       = p_gt_stxh-tdobject
              tdname         = p_gt_stxh-tdname
              tdid           = p_gt_stxh-tdid
              tdspras        = p_gt_stxh-tdspras
*             _SCOPE         = '2'
*             _WAIT          = ' '
*             _COLLECT       = ' '
            EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.

          CASE sy-subrc.
            WHEN 1.
              sy-subrc = l_sysubrc.
              MESSAGE e049(sv) WITH sy-msgv1(12).
            WHEN 2.
            WHEN 3.
          ENDCASE.
          PERFORM baustein_pflegen USING p_gt_stxh anz_mod.
          CALL FUNCTION 'DEQUEUE_ESSSTXT'
            EXPORTING
*             MODE_STXH  = 'E'
              mandt    = sy-mandt
              tdobject = p_gt_stxh-tdobject
              tdname   = p_gt_stxh-tdname
              tdid     = p_gt_stxh-tdid
              tdspras  = p_gt_stxh-tdspras
*             X_TDOBJECT = ' '
*             X_TDNAME = ' '
*             X_TDID   = ' '
*             X_TDSPRAS  = ' '
*             _SCOPE   = '3'
*             _SYNCHRON  = ' '
*             _COLLECT = ' '
            .

        WHEN 'GT_STXH-ANZ_VERW'.
          l_g_repid = sy-repid.
* lokalen FELDKATALOG definieren
          CLEAR wa_l_gt_fieldcat.
          wa_l_gt_fieldcat-fieldname = 'SUBANWDG'.
          wa_l_gt_fieldcat-ref_tabname    = 'TTXBS'.
          wa_l_gt_fieldcat-key    = 'X'.
          APPEND wa_l_gt_fieldcat TO l_gt_fieldcat.
          CLEAR wa_l_gt_fieldcat.
          wa_l_gt_fieldcat-fieldname = 'BRFNM'.
          wa_l_gt_fieldcat-ref_tabname    = 'TTXBS'.
          wa_l_gt_fieldcat-key    = 'X'.
          APPEND wa_l_gt_fieldcat TO l_gt_fieldcat.
          CLEAR wa_l_gt_fieldcat.
          wa_l_gt_fieldcat-fieldname = 'BSTLF'.
          wa_l_gt_fieldcat-ref_tabname    = 'TTXBS'.
          wa_l_gt_fieldcat-key    = 'X'.
          APPEND wa_l_gt_fieldcat TO l_gt_fieldcat.
          SELECT * FROM ttxbs INTO TABLE it_ttxbs
              WHERE ( rantyp IN p_rantyp )
               AND  xobject = p_gt_stxh-tdobject
*               AND  ( xspras  = p_gt_stxh-tdspras OR
*                      xspras  = space )
               AND  xbstnm  = p_gt_stxh-tdname.
          IF sy-subrc = 0.
            ausgabe = 1.
          ENDIF.
          IF ausgabe <> 0.
            SET TITLEBAR 'VERW_NACH'.
            CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
              EXPORTING
                i_callback_program    = l_g_repid
                i_structure_name      = 'TTXBS'
                it_fieldcat           = l_gt_fieldcat[]
                i_screen_start_column = 5
                i_screen_start_line   = 5
                i_screen_end_column   = 100
                i_screen_end_line     = 20
              TABLES
                t_outtab              = it_ttxbs.

          ENDIF.
      ENDCASE.
    WHEN 'PFLEGEN'.
      LOOP AT gt_stxh.
        IF gt_stxh-box = 'X'.
          MOVE-CORRESPONDING gt_stxh TO p_gt_stxh.
          APPEND p_gt_stxh.
        ENDIF.
      ENDLOOP.
      zaehler = 0.
      LOOP AT p_gt_stxh.
        zaehler = zaehler + 1.
      ENDLOOP.
      IF sy-subrc <> 0.
        MESSAGE e006(0k).
      ELSEIF zaehler > 1.
        MESSAGE e035(0k).
      ENDIF.
      l_sysubrc = sy-subrc.
      CALL FUNCTION 'ENQUEUE_ESSSTXT'
        EXPORTING
*         MODE_STXH      = 'E'
          mandt          = sy-mandt
          tdobject       = p_gt_stxh-tdobject
          tdname         = p_gt_stxh-tdname
          tdid           = p_gt_stxh-tdid
          tdspras        = p_gt_stxh-tdspras
*         _SCOPE         = '2'
*         _WAIT          = ' '
*         _COLLECT       = ' '
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.

      CASE sy-subrc.
        WHEN 1.
          sy-subrc = l_sysubrc.
          MESSAGE e049(sv) WITH sy-msgv1(12).
        WHEN 2.
        WHEN 3.
      ENDCASE.
      PERFORM baustein_pflegen USING p_gt_stxh anz_mod.
      CALL FUNCTION 'DEQUEUE_ESSSTXT'
        EXPORTING
*         MODE_STXH  = 'E'
          mandt    = sy-mandt
          tdobject = p_gt_stxh-tdobject
          tdname   = p_gt_stxh-tdname
          tdid     = p_gt_stxh-tdid
          tdspras  = p_gt_stxh-tdspras
*         X_TDOBJECT = ' '
*         X_TDNAME = ' '
*         X_TDID   = ' '
*         X_TDSPRAS  = ' '
*         _SCOPE   = '3'
*         _SYNCHRON  = ' '
*         _COLLECT = ' '
        .

      l_sysubrc = sy-subrc.
    WHEN 'ANZEIGEN'.
      anz_mod = show.
      LOOP AT gt_stxh.
        IF gt_stxh-box = 'X'.
          MOVE-CORRESPONDING gt_stxh TO p_gt_stxh.
          APPEND p_gt_stxh.
        ENDIF.
      ENDLOOP.
      zaehler = 0.
      LOOP AT p_gt_stxh.
        zaehler = zaehler + 1.
      ENDLOOP.
      IF sy-subrc <> 0.
        MESSAGE e006(0k).
      ELSEIF zaehler > 1.
        MESSAGE e035(0k).
      ENDIF.
      PERFORM baustein_pflegen USING p_gt_stxh anz_mod.
    WHEN 'TRANSPORT'.
      LOOP AT gt_stxh.
        IF gt_stxh-box = 'X'.
          MOVE-CORRESPONDING gt_stxh TO p_gt_stxh.
          APPEND p_gt_stxh.
        ENDIF.
      ENDLOOP.
      LOOP AT p_gt_stxh.
      ENDLOOP.
      IF sy-subrc <> 0.
        MESSAGE e006(0k).
      ENDIF.
      PERFORM transport TABLES p_gt_stxh.
    WHEN 'KOPE'.
      PERFORM bausteine_kopieren TABLES gt_stxh
                               CHANGING zaehler.
      MESSAGE s014(sv) WITH zaehler.

      rs_selfield-refresh = 'X'.
    WHEN 'DELE'.
      zaehler = 0.
      LOOP AT gt_stxh.
        IF gt_stxh-box = 'X'.
          MOVE-CORRESPONDING gt_stxh TO p_gt_stxh.
          APPEND p_gt_stxh.
        ENDIF.
      ENDLOOP.
      IF sy-subrc <> 0.
        MESSAGE e006(0k).
      ENDIF.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          defaultoption = 'N'
          textline1     = 'Wollen Sie die Textbausteine'(010)
          textline2     = 'wirklich löschen?'(011)
          titel         = 'Textbaustein löschen'(012)
*         START_COLUMN  = 25
*         START_ROW     = 6
*         CANCEL_DISPLAY = 'X'
        IMPORTING
          answer        = antwort.
      IF antwort = 'Y' OR antwort = 'J'.
        LOOP AT p_gt_stxh.
          CALL FUNCTION 'DELETE_TEXT'
            EXPORTING
*             CLIENT          = SY-MANDT
              id              = p_gt_stxh-tdid
              language        = p_gt_stxh-tdspras
              name            = p_gt_stxh-tdname
              object          = p_gt_stxh-tdobject
              savemode_direct = 'X'
*             TEXTMEMORY_ONLY = ' '
            EXCEPTIONS
              not_found       = 1
              OTHERS          = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ELSE.
            zaehler1 = zaehler1 + 1.
          ENDIF.
          LOOP AT p_gt_stxh INTO wa_stxh.
            DELETE TABLE gt_stxh FROM wa_stxh.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
      MESSAGE s011(sv) WITH zaehler1.
      rs_selfield-refresh = 'X'.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM SET_PF_STATUS                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RT_EXTAB                                                      *
*---------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab.
ENDFORM.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BAUSTEIN_PFLEGEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GT_STXH  text
*----------------------------------------------------------------------*
FORM baustein_pflegen USING i_gt_stxh LIKE gt_stxh anz_mod.

  DATA: l_activity(4).

  IF anz_mod = ' '.
    l_activity = 'EDIT'.
  ELSE.
    l_activity = 'SHOW'.
  ENDIF.

*  CALL FUNCTION 'CHECK_TEXT_AUTHORITY'
*       EXPORTING
*            ACTIVITY     = L_ACTIVITY
*            ID           = I_GT_STXH-TDID
*            LANGUAGE     = I_GT_STXH-TDSPRAS
*            NAME         = I_GT_STXH-TDNAME
**           OBJECT       = 'TEXT      '
*      EXCEPTIONS
*           NO_AUTHORITY = 1
*           OTHERS       = 2
*            .
*  IF SY-SUBRC <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.

  CALL FUNCTION 'EDITOR_AUFRUF'
    EXPORTING
      f_tdobject = i_gt_stxh-tdobject
      f_tdname   = i_gt_stxh-tdname
      f_tdid     = i_gt_stxh-tdid
      f_tdspras  = i_gt_stxh-tdspras
      p_anz_mod  = anz_mod.
ENDFORM.                               " BAUSTEIN_PFLEGEN

INCLUDE /THKR/EA_TEXT_EDIT_BAF2.
*INCLUDE ZFI_EA_TEXT_EDIT_BAF2.
