FUNCTION /thkr/bp_process_bte1120.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BKDF) TYPE  BKDF OPTIONAL
*"  TABLES
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEG STRUCTURE  BSEG
*"      T_BKPFSUB STRUCTURE  BKPF_SUBST OPTIONAL
*"      T_BSEGSUB STRUCTURE  BSEG_SUBST OPTIONAL
*"      T_BSEC STRUCTURE  BSEC OPTIONAL
*"  CHANGING
*"     REFERENCE(I_BKDFSUB) TYPE  BKDF_SUBST OPTIONAL
*"----------------------------------------------------------------------
"Ausnahme für Kasse im Mahndruck
  IF sy-uname = '9999-KASSE' AND sy-cprog = 'SAPF150D2'.
    RETURN.
  ENDIF.

  "Dieser Baustein soll sicherstellen, dass keine Belege gebucht werden,
  " die einen gesperrten Geschätspartner enthalten.
  DATA: lv_partner  TYPE bu_partner,
        lt_partner  TYPE STANDARD TABLE OF bu_partner,
        lv_objkey   TYPE sweinstcou-objkey,
        lt_worklist TYPE STANDARD TABLE OF swr_wihdr.
  "Ermitteln aller verwendeten GP im Beleg
  LOOP AT t_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>).
    CLEAR lv_partner.
    IF <fs_bseg>-lifnr IS NOT INITIAL.
      lv_partner = <fs_bseg>-lifnr.
    ELSEIF <fs_bseg>-kunnr IS NOT INITIAL.
      lv_partner = <fs_bseg>-kunnr.
    ELSE.
      CONTINUE.
    ENDIF.
    APPEND lv_partner TO lt_partner.
  ENDLOOP.
  "Aussortieren doppelter Einträge
  SORT lt_partner ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_partner.

  LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).
    "Sperrflags prüfen
    SELECT SINGLE not_released, xblck FROM but000
   INTO @DATA(ls_but000)
   WHERE partner = @<fs_partner>.
    IF sy-subrc = 0.

      IF ls_but000-not_released = 'X' OR ls_but000-xblck = 'X'.

        MESSAGE e005(/thkr/bp) WITH lv_partner.

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

ENDFUNCTION.
