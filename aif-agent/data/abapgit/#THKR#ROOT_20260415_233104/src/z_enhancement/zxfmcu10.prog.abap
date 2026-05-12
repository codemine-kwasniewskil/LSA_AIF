*&---------------------------------------------------------------------*
*& Include          ZXFMCU10
*&---------------------------------------------------------------------*

"Ersteller:           ZHM000000038 Andreas Baier
"Anforderung:         EOL-0014_A2.6.9 / A2.6.63 - Allgemeine Anordnung
"Angefordert durch:   ZHM000000041 Theresa Berenbold
"Beschreibung:
"Bei Allgemeinen Anordnungen darf nur eine Belegzeile als Kontierungshülle
"erfasst werden. Allgemeine Anordnungen umfassen die Belegarten AU und AN.
"Sollte mehr als eine Belegzeile erfasst werden, wird eine entsprechende
"Fehlermeldung ausgegeben.
"Außerdem wird geprüft, ob der Geschäftspartner gesperrt ist.
"Für einen gesperrten Geschäftspartner darf keine Anlage möglich sein

DATA: lv_partner  TYPE bu_partner,
      lt_partner  TYPE STANDARD TABLE OF bu_partner,
      lv_objkey   TYPE sweinstcou-objkey,
      lt_worklist TYPE STANDARD TABLE OF swr_wihdr,
      lv_blart    TYPE fmre_blart,
      lv_bukrs    TYPE bukrs.

LOOP AT t_kbld ASSIGNING FIELD-SYMBOL(<fs_kbld_pos>).

  IF i_tctype = '01'.
    PERFORM set_kassenzeichen_pos CHANGING <fs_kbld_pos>.
  ENDIF.

ENDLOOP.

DATA: lv_lines TYPE i.

CASE sy-tcode.

  WHEN 'FMZ1' OR 'FMZ2'.

    LOOP AT t_kbld ASSIGNING FIELD-SYMBOL(<fs_kbld>).


      IF <fs_kbld>-blart = 'AU'.

        DESCRIBE TABLE t_kbld LINES lv_lines.

        IF lv_lines > 1.

          MESSAGE 'Bitte nur eine Zeile erfassen!' TYPE 'E'.

        ENDIF.


        """"

        CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
          EXPORTING
            i_bukrs  = <fs_kbld>-bukrs
            i_hkont  = <fs_kbld>-saknr  "Sach-/oder Abstimmkonto
            i_koart  = 'S'
            i_mwskz  = <fs_kbld>-zz_mwskz
            i_stbuk  = <fs_kbld>-bukrs
            i_umsks  = ' '
            x_dialog = ' '.


        """"


      ENDIF.

    ENDLOOP.


  WHEN 'FMV1' OR 'FMV2'.

    LOOP AT t_kbld ASSIGNING <fs_kbld>.

      IF <fs_kbld>-blart = 'AN'.

        DESCRIBE TABLE t_kbld LINES lv_lines.

        IF lv_lines > 1.

          MESSAGE 'Bitte nur eine Zeile erfassen!' TYPE 'E'.

        ENDIF.


        """"

        CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
          EXPORTING
            i_bukrs  = <fs_kbld>-bukrs
            i_hkont  = <fs_kbld>-saknr  "Sach-/oder Abstimmkonto
            i_koart  = 'S'
            i_mwskz  = <fs_kbld>-zz_mwskz
            i_stbuk  = <fs_kbld>-bukrs
            i_umsks  = ' '
            x_dialog = ' '.


        """"


      ENDIF.

    ENDLOOP.

ENDCASE.

IF sy-ucomm = 'SAVE' OR sy-ucomm = 'CHEC'
  OR sy-ucomm = 'WFAP'.

  LOOP AT t_kbld ASSIGNING <fs_kbld_pos>
    WHERE kunnr IS NOT INITIAL OR lifnr IS NOT INITIAL.

    IF <fs_kbld_pos>-blart <> 'AN' AND <fs_kbld_pos>-blart <> 'AU'.
      EXIT.
    ENDIF.

    lv_blart = <fs_kbld_pos>-blart.
    lv_bukrs = <fs_kbld_pos>-bukrs.

    IF <fs_kbld_pos>-kunnr IS NOT INITIAL.
      lv_partner = <fs_kbld_pos>-kunnr.
    ELSEIF <fs_kbld_pos>-lifnr IS NOT INITIAL.
      lv_partner = <fs_kbld_pos>-lifnr.
    ELSE.
      CONTINUE.
    ENDIF.
    APPEND lv_partner TO lt_partner.

  ENDLOOP.
  "Aussortieren doppelter Geschäftspartner
  SORT lt_partner ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_partner.

  LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).
    "Sperrflags prüfen
    SELECT SINGLE not_released, xblck, xdele FROM but000
   INTO @DATA(ls_but000)
   WHERE partner = @<fs_partner>.
    IF sy-subrc = 0.

      IF ls_but000-not_released = 'X' OR ls_but000-xblck = 'X'.

        MESSAGE e005(/thkr/bp) WITH <fs_partner>.

      ENDIF.

      IF ls_but000-xdele IS NOT INITIAL.

        MESSAGE e007(/thkr/bp) WITH <fs_partner>.

      ENDIF.

    ENDIF.

    IF lv_blart = 'AU'.

      SELECT SINGLE sperr FROM lfa1
        INTO @DATA(ls_lfa1)
        WHERE lifnr = @<fs_partner>.
      IF sy-subrc = 0 AND ls_lfa1 IS NOT INITIAL.

        MESSAGE e005(/thkr/bp) WITH <fs_partner>.

      ENDIF.

      SELECT SINGLE sperr FROM lfb1
        INTO @DATA(ls_lfb1)
        WHERE lifnr = @<fs_partner>
        AND bukrs = @lv_bukrs.
      IF sy-subrc = 0 AND ls_lfb1 IS NOT INITIAL.

        MESSAGE e008(/thkr/bp) WITH lv_bukrs <fs_partner>.

      ENDIF.

    ELSEIF lv_blart = 'AN'.

      SELECT SINGLE sperr FROM kna1
      INTO @DATA(ls_kna1)
      WHERE kunnr = @<fs_partner>.
      IF sy-subrc = 0 AND ls_kna1 IS NOT INITIAL.

        MESSAGE e005(/thkr/bp) WITH <fs_partner>.

      ENDIF.

      SELECT SINGLE sperr FROM knb1
        INTO @DATA(ls_knb1)
        WHERE kunnr = @<fs_partner>
        AND bukrs = @lv_bukrs.
      IF sy-subrc = 0 AND ls_knb1 IS NOT INITIAL.

        MESSAGE e009(/thkr/bp) WITH lv_bukrs <fs_partner>.

      ENDIF.


    ENDIF.
    CLEAR lt_worklist.
    MOVE <fs_partner> TO lv_objkey.
    "Prüfe zusätzlich, ob hier noch ein Workflow am laufen ist.
    CALL FUNCTION 'SAP_WAPI_WORKITEMS_TO_OBJECT'
      EXPORTING
*       OBJECT_POR               =
        objtype                  = 'BUS1006'
        objkey                   = lv_objkey
        top_level_items          = 'X'
        selection_status_variant = 0003
*       TIME                     =
*       TEXT                     = 'X'
*       OUTPUT_ONLY_TOP_LEVEL    = ' '
*       LANGUAGE                 = SY-LANGU
*       DETERMINE_TASK_FILTER    = 'X'
*       REMOVED_OBJECTS          = ' '
*   IMPORTING
*       RETURN_CODE              =
      TABLES
*       TASK_FILTER              =
        worklist                 = lt_worklist
*       MESSAGE_LINES            =
*       MESSAGE_STRUCT           =
      .
    IF lt_worklist IS NOT INITIAL.

      MESSAGE e006(/thkr/bp) WITH <fs_partner>.

    ENDIF.

  ENDLOOP.

ENDIF.
