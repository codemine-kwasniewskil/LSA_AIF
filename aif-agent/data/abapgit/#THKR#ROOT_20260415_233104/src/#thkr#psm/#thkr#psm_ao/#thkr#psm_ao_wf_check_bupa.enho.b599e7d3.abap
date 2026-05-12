"Name: \FU:FI_PSO_FMPSO_DOC_CHECK\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/PSM_AO_WF_CHECK_BUPA.
DATA: lv_recurring LIKE boole-boole,
      lt_pso       TYPE STANDARD TABLE OF psowf,
      lv_partner   TYPE bu_partner,
      lt_partner   TYPE STANDARD TABLE OF bu_partner,
      lv_objkey    TYPE sweinstcou-objkey,
      lt_worklist  TYPE STANDARD TABLE OF swr_wihdr,
      lv_psoty     LIKE vbkpf-psoty.


SELECT SINGLE psoty FROM  bkpf INTO lv_psoty
                    WHERE lotkz EQ i_lotkz    AND
                          bukrs EQ i_bukrs.

IF lv_psoty IS INITIAL.

  CALL FUNCTION 'FI_PSO_DOCS_FROM_LOTKZ_GET'
    EXPORTING
      i_lotkz     = i_lotkz
      i_bukrs     = i_bukrs
    IMPORTING
      e_recurring = lv_recurring
    TABLES
      t_psowf     = lt_pso
    EXCEPTIONS
      not_found   = 1
      OTHERS      = 2.

  IF sy-subrc NE 0.
*      MESSAGE e840(fq) WITH u_lotkz u_bukrs RAISING not_found.
  ENDIF.

  IF lv_recurring IS NOT INITIAL.

    LOOP AT lt_pso ASSIGNING FIELD-SYMBOL(<fs_pso>)
      WHERE kunnr IS NOT INITIAL OR lifnr IS NOT INITIAL.

      IF <fs_pso>-kunnr IS NOT INITIAL.
        lv_partner = <fs_pso>-kunnr.
      ELSEIF <fs_pso>-lifnr IS NOT INITIAL.
        lv_partner = <fs_pso>-lifnr.
      ELSE.
        CONTINUE.
      ENDIF.
      APPEND lv_partner TO lt_partner.
      CLEAR lv_partner.

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

*        MESSAGE e005(/thkr/bp) WITH <fs_partner>.
          e_subrc = 4.
          e_msgno = '005'.
          e_msgid = '/THRK/BP'.
          EXIT.

        ENDIF.

        IF ls_but000-xdele IS NOT INITIAL.

*        MESSAGE e007(/thkr/bp) WITH <fs_partner>.
          e_subrc = 4.
          e_msgno = '007'.
          e_msgid = '/THRK/BP'.
          EXIT.

        ENDIF.

      ENDIF.
      CLEAR lt_worklist.
      MOVE <fs_partner> TO lv_objkey.
      "Prüfe zusätzlich, ob hier noch ein Workflow am laufen ist.
      CALL FUNCTION 'SAP_WAPI_WORKITEMS_TO_OBJECT'
        EXPORTING
*         OBJECT_POR               =
          objtype                  = 'BUS1006'
          objkey                   = lv_objkey
          top_level_items          = 'X'
          selection_status_variant = 0003
*         TIME                     =
*         TEXT                     = 'X'
*         OUTPUT_ONLY_TOP_LEVEL    = ' '
*         LANGUAGE                 = SY-LANGU
*         DETERMINE_TASK_FILTER    = 'X'
*         REMOVED_OBJECTS          = ' '
*   IMPORTING
*         RETURN_CODE              =
        TABLES
*         TASK_FILTER              =
          worklist                 = lt_worklist
*         MESSAGE_LINES            =
*         MESSAGE_STRUCT           =
        .
      IF lt_worklist IS NOT INITIAL.

*        MESSAGE e006(/thkr/bp) WITH <fs_partner>.
        e_subrc = 4.
        e_msgno = '006'.
        e_msgid = '/THRK/BP'.
        EXIT.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDIF.

ENDENHANCEMENT.
