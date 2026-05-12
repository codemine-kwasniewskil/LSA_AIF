*&---------------------------------------------------------------------*
*& Include          ZXFKEU02
*&---------------------------------------------------------------------*
"Ersteller:           ZHM000000038 Andreas Baier
"Anforderung:         DEFECT 1064 - Konto zum Buchen gesperrt
"Angefordert von:     Frau Jäger
"Beschreibung:
"Bei Anordnungen egal welcher Art darf es nicht möglich sein,
"eine Anordnung mit einem nicht freigegebenen oder zur Archivierung
"vorgesehenen Geschöftspartner anzulegen/freizugeben/zu buchen.


DATA: lv_partner  TYPE bu_partner,
      lt_partner  TYPE STANDARD TABLE OF bu_partner,
      lv_objkey   TYPE sweinstcou-objkey,
      lt_worklist TYPE STANDARD TABLE OF swr_wihdr.

"Ausnahme für Kasse im Mahndruck
  IF sy-uname = '9999-KASSE' AND sy-cprog = 'SAPF150D2'.
    RETURN.
  ENDIF.

IF i_okcode EQ 'CHEC'    OR
   i_okcode EQ 'VOLL'    OR
   i_okcode EQ 'POST'    OR
   i_okcode EQ 'APPV'.

  CLEAR lt_partner.
  "Ermitteln aller betroffenen GP
  LOOP AT t_pso02 ASSIGNING FIELD-SYMBOL(<fs_pso2>)
    WHERE kunnr IS NOT INITIAL OR lifnr IS NOT INITIAL.

    IF <fs_pso2>-kunnr IS NOT INITIAL.
      lv_partner = <fs_pso2>-kunnr.
    ELSEIF <fs_pso2>-lifnr IS NOT INITIAL.
      lv_partner = <fs_pso2>-lifnr.
    ELSE.
      CONTINUE.
    ENDIF.
    APPEND lv_partner TO lt_partner.
    clear lv_partner.

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
