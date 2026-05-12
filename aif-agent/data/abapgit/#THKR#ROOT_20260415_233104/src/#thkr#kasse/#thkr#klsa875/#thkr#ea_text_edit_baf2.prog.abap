*----------------------------------------------------------------------*
***INCLUDE RFVITXBAF2 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BAUSTEINE_KOPIEREN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_STXH  text
*----------------------------------------------------------------------*
FORM bausteine_kopieren TABLES p_gt_stxh STRUCTURE gt_stxh
                      CHANGING p_zaehler.

  DATA: BEGIN OF stxh_copy_struc OCCURS 0.
          INCLUDE STRUCTURE itctc.
          DATA:   text(60) TYPE c.
  DATA: END OF stxh_copy_struc.

  DATA: wa_stxh            LIKE gt_stxh,
        wa_stxh_copy_struc LIKE stxh_copy_struc,
        txt_copy           LIKE itctc OCCURS 0 WITH HEADER LINE,
        l_sysubrc          LIKE sy-subrc,
        error_flag(1)      TYPE c,
        count              TYPE i.

  DATA: it_fieldcat         TYPE slis_t_fieldcat_alv,
        it_layout           TYPE slis_layout_alv,
        exit_caused_by_user TYPE slis_exit_by_user.

  DATA: loc_repid LIKE sy-repid.

  DATA: destthead LIKE thead,
        destlines LIKE tline OCCURS 0.

  DATA: BEGIN OF fields OCCURS 1.
          INCLUDE STRUCTURE sval.
        DATA: END OF fields,
        returncode(1)   TYPE c,
        popup_title(30) TYPE c.

  DATA: lv_tdname_neu     TYPE tdobname,
        lv_tdname_pre_alt TYPE string,
        lv_tdname_pre_neu TYPE string,
        lv_tdid           TYPE tdid,
        lv_tdspras        TYPE spras,
        lv_ok             TYPE xfeld.

  CLEAR lv_ok.

  READ TABLE p_gt_stxh WITH KEY box = 'X'.
  IF sy-subrc EQ 0.
    CLEAR fields.
    fields-tabname    = 'STXH'.
    fields-fieldname  = 'TDNAME'.
    fields-fieldtext  = 'Name Präfix Vorlage'(100).
    fields-value      = p_gt_stxh-tdname(10).
    fields-field_attr = ' '.
    APPEND fields.
    CLEAR fields.
    fields-tabname    = 'ZFI_EA_FO_TB'.
    fields-fieldname  = 'TDNAME'.
    fields-fieldtext  = 'Name Präfix neu'(101).
    fields-value      = p_gt_stxh-tdname(10).
    fields-field_attr = ' '.
    APPEND fields.
    CLEAR fields.
    fields-tabname    = 'ZFI_EA_FO_TB'.
    fields-fieldname  = 'TDID'.
    fields-fieldtext  = 'ID neu'(104).
    fields-value      = p_gt_stxh-tdid.
    fields-field_attr = ' '.
    APPEND fields.
    CLEAR fields.
    fields-tabname    = 'ZFI_EA_FO_TB'.
    fields-fieldname  = 'TDSPRAS'.
    fields-fieldtext  = 'Sprache neu'(106).
    fields-value      = p_gt_stxh-tdspras.
    fields-field_attr = ' '.
    APPEND fields.

    popup_title = 'Kopieren mit Mustervorlage?'(102).

    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title = popup_title
      IMPORTING
        returncode  = returncode
      TABLES
        fields      = fields.

    IF returncode <> 'A'.
      LOOP AT fields.
        IF fields-tabname EQ 'STXH'.       "Quelle
          IF fields-fieldname EQ 'TDNAME'.
            lv_tdname_pre_alt = fields-value.
          ENDIF.
        ELSE.                              "Ziel
          CASE fields-fieldname.
            WHEN 'TDNAME'.
              lv_tdname_pre_neu = fields-value.
            WHEN 'TDID'.
              lv_tdid           = fields-value.
            WHEN 'TDSPRAS'.
              lv_tdspras        = fields-value.
          ENDCASE.
        ENDIF.
      ENDLOOP.
      lv_ok = 'X'.
    ELSE.
      lv_ok = ' '.
    ENDIF.
  ENDIF.

* Ausgabeliste aufbauen
  REFRESH stxh_copy_struc.
  LOOP AT p_gt_stxh.
    IF p_gt_stxh-box = 'X'.
      wa_stxh_copy_struc-srcobject
         = wa_stxh_copy_struc-destobject = p_gt_stxh-tdobject.
* Name bestimmen
      IF lv_ok = 'X'.
        lv_tdname_neu = p_gt_stxh-tdname.
        REPLACE FIRST OCCURRENCE OF lv_tdname_pre_alt IN lv_tdname_neu WITH lv_tdname_pre_neu.
        wa_stxh_copy_struc-srcname  = p_gt_stxh-tdname.
        wa_stxh_copy_struc-destname = lv_tdname_neu.
      ELSE.
        wa_stxh_copy_struc-srcname  =
        wa_stxh_copy_struc-destname = p_gt_stxh-tdname.
      ENDIF.
* Text ID  bestimmen
      IF lv_ok = 'X'.
        wa_stxh_copy_struc-srcid      = p_gt_stxh-tdid.
        wa_stxh_copy_struc-destid     = lv_tdid.
      ELSE.
        wa_stxh_copy_struc-srcid      =
        wa_stxh_copy_struc-destid     = p_gt_stxh-tdid.
      ENDIF.
* Sprache bestimmen
      IF lv_ok = 'X'.
        wa_stxh_copy_struc-srclang    = p_gt_stxh-tdspras.
        wa_stxh_copy_struc-destlang   = lv_tdspras.
      ELSE.
        wa_stxh_copy_struc-srclang    =
        wa_stxh_copy_struc-destlang   = p_gt_stxh-tdspras.
      ENDIF.

      wa_stxh_copy_struc-text = 'wird kopiert nach'(050).
      APPEND wa_stxh_copy_struc TO stxh_copy_struc.
    ENDIF.
  ENDLOOP.
* Feldkatalog erstellen
  PERFORM fieldcat_build_for_copy
                         USING it_fieldcat.
* Layout erstellen.
  PERFORM layout_build_for_copy
                         USING it_layout.

* Liste ausgeben
  loc_repid = sy-repid.
  SET TITLEBAR 'KOPIEREN'.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = loc_repid
      i_callback_pf_status_set = ' '
*     i_structure_name         = 'ITCTC'
      is_layout                = it_layout
      it_fieldcat              = it_fieldcat
      i_screen_start_column    = 5
      i_screen_start_line      = 5
      i_screen_end_column      = 100
      i_screen_end_line        = 20
    IMPORTING
*        E_EXIT_CAUSED_BY_CALLER
      es_exit_caused_by_user   = exit_caused_by_user
    TABLES
      t_outtab                 = stxh_copy_struc.

  IF exit_caused_by_user-cancel = space AND
     exit_caused_by_user-back = space  AND
     exit_caused_by_user-exit = space.

    LOOP AT stxh_copy_struc INTO wa_stxh_copy_struc.

      CALL FUNCTION 'READ_TEXT'
        EXPORTING
*         CLIENT                  = SY-MANDT
          id                      = wa_stxh_copy_struc-destid
          language                = wa_stxh_copy_struc-destlang
          name                    = wa_stxh_copy_struc-destname
          object                  = wa_stxh_copy_struc-destobject
*         ARCHIVE_HANDLE          = 0
        IMPORTING
          header                  = destthead
        TABLES
          lines                   = destlines
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      l_sysubrc = sy-subrc.

      IF l_sysubrc = 0.
        MESSAGE i859(6a) WITH wa_stxh_copy_struc-destobject
                              wa_stxh_copy_struc-destname
                              wa_stxh_copy_struc-destid
                              wa_stxh_copy_struc-destlang.
      ELSE.
        MOVE-CORRESPONDING wa_stxh_copy_struc TO txt_copy.
        APPEND txt_copy.
      ENDIF.
    ENDLOOP.
    CALL FUNCTION 'COPY_TEXTS'
      EXPORTING
        savemode_direct = 'X'
        insert          = 'X'
      IMPORTING
        error           = error_flag
      TABLES
        texts           = txt_copy.

    count = 0.
    LOOP AT txt_copy.
      IF txt_copy-subrc = 0.
        count = count + 1.
        SELECT SINGLE * FROM stxh INTO wa_stxh
        WHERE tdobject = txt_copy-destobject
        AND   tdname   = txt_copy-destname
        AND   tdid     = txt_copy-destid
        AND   tdspras  = txt_copy-destlang.
        wa_stxh-box = space. wa_stxh-anz_verw = 0.
        APPEND wa_stxh TO p_gt_stxh.
        SORT p_gt_stxh BY tdobject tdname tdid tdspras.
      ENDIF.
    ENDLOOP.
  ENDIF.
  p_zaehler = count.
ENDFORM.                               " BAUSTEINE_KOPIEREN
*&---------------------------------------------------------------------*
*&      Form  fieldcat_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_build_for_copy
                    USING    p_it_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SRCOBJECT'.
  ls_fieldcat-ref_tabname    = 'ITCTC'.
  ls_fieldcat-key            = 'X'.
  ls_fieldcat-key_sel        = 'X'.
  APPEND ls_fieldcat TO p_it_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SRCNAME'.
  ls_fieldcat-ref_tabname    = 'ITCTC'.
  ls_fieldcat-key            = 'X'.
  ls_fieldcat-key_sel        = 'X'.
  APPEND ls_fieldcat TO p_it_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SRCID'.
  ls_fieldcat-ref_tabname    = 'ITCTC'.
  ls_fieldcat-key            = 'X'.
  ls_fieldcat-key_sel        = 'X'.
  APPEND ls_fieldcat TO p_it_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SRCLANG'.
  ls_fieldcat-ref_tabname    = 'ITCTC'.
  ls_fieldcat-key            = 'X'.
  ls_fieldcat-key_sel        = 'X'.
  APPEND ls_fieldcat TO p_it_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TEXT'.
*  ls_fieldcat-ref_tabname    = 'ITCTC'.
  ls_fieldcat-datatype    = 'C'.
  ls_fieldcat-outputlen    = 60.
  ls_fieldcat-row_pos        = 2.
  APPEND ls_fieldcat TO p_it_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DESTOBJECT'.
*  ls_fieldcat-ref_tabname    = 'ITCTC'.
  ls_fieldcat-datatype    = 'C'.
  ls_fieldcat-outputlen    = 10.
  ls_fieldcat-input          = 'X'.
  ls_fieldcat-row_pos        = 3.
  ls_fieldcat-seltext_m      = 'Zielobjekt'(080).
  APPEND ls_fieldcat TO p_it_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DESTNAME'.
*  ls_fieldcat-ref_tabname = 'ITCTC'.
  ls_fieldcat-datatype    = 'C'.
  ls_fieldcat-outputlen    = 70.
  ls_fieldcat-input          = 'X'.
  ls_fieldcat-row_pos        = 3.
  ls_fieldcat-seltext_m      = 'Zielname'(081).
  APPEND ls_fieldcat TO p_it_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DESTID'.
*  ls_fieldcat-ref_tabname    = 'ITCTC'.
  ls_fieldcat-datatype    = 'C'.
  ls_fieldcat-outputlen    = 4.
  ls_fieldcat-input          = 'X'.
  ls_fieldcat-row_pos        = 3.
  ls_fieldcat-seltext_m      = 'Z-Id'(082).
  APPEND ls_fieldcat TO p_it_fieldcat.
*
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'DESTLANG'.
  ls_fieldcat-ref_tabname    = 'ITCTC'.
  ls_fieldcat-datatype    = 'C'.
*  ls_fieldcat-outputlen    = 1.
  ls_fieldcat-input          = 'X'.
  ls_fieldcat-row_pos        = 3.
  ls_fieldcat-seltext_m      = 'S'(083).
  APPEND ls_fieldcat TO p_it_fieldcat.

ENDFORM.                               " fieldcat_build

*&---------------------------------------------------------------------*
*&      Form  layout_build_for_copy
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_build_for_copy USING p_it_layout
                                      TYPE slis_layout_alv.
*  p_it_layout-colwidth_optimize        = 'X'.
  p_it_layout-zebra                    = 'X'.
  p_it_layout-no_vline                 = ' '.
  p_it_layout-detail_popup             = 'X'.

ENDFORM.                               " layout_build_for_copy
