FUNCTION /THKR/BUS_SHLP_EXIT1.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR_T
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------
*
**---- Datendeklaration
*  CLASS cl_exithandler DEFINITION LOAD.
*  DATA:
*        lv_exit_object    TYPE REF TO if_ex_bupa_shlp_control,
*        lt_shlp_tab       TYPE shlp_desct,
*        lv_active_vers    TYPE i,
*        lt_adrv_act       TYPE STANDARD TABLE OF v_saptsadv,
*        lv_addrv_exist    TYPE boole-boole,
*        lv_addrsearch_act TYPE bu_adrsearch_active,
*    lc_shlp_exit1_aba TYPE funcname VALUE 'BUS_SHLP_EXIT1_ABA',
*    lv_is_s4h         TYPE abap_bool.
*
**Start of Authority Check- note 2441447
**Switch check
*  PERFORM switch_check.
*
**Authority Check
*  PERFORM authority_check_2 TABLES   record_tab
*                                     shlp_tab
*                            CHANGING shlp
*                                     callcontrol.
*  IF callcontrol-step = 'EXIT'.
*    EXIT.
*  ENDIF.
**End of Authority Check- note 2441447
*
*  IF callcontrol-step = 'SELONE'.
*
*    CALL FUNCTION 'FUNCTION_EXISTS'
*      EXPORTING
*        funcname           = lc_shlp_exit1_aba
*      EXCEPTIONS
*        function_not_exist = 1
*        OTHERS             = 2.
*
*    IF sy-subrc EQ 0.
*
*      CALL FUNCTION lc_shlp_exit1_aba
*        TABLES
*          shlp_tab    = shlp_tab
*          record_tab  = record_tab
*        CHANGING
*          shlp        = shlp
*          callcontrol = callcontrol.
*
*    ENDIF.
*
** Decoupling
**------ Prüfen, ob Nichtgesicherte Objekte vorhanden sind --------------
**    clear: gv_xrel_mc1.
**    call function 'BUS_TBZ1_SELECT_SINGLE'
**      exporting
**        i_objap   = gt_tbz1-objap
**      importing
**        e_tbz1    = tbz1
**      exceptions
**        not_found = 1.
**    if sy-subrc = 0.
**      if not tbz1-fnmc1 is initial.
**        call function tbz1-fnmc1
**          importing
**            e_xrel = gv_xrel_mc1.
**      endif.
**    endif.
***------ Elem.Suchhilfe für Nichtgesicherte Objekte löschen
**-------------
**    if gv_xrel_mc1 is initial.
**      delete shlp_tab where shlpname = gc_shlp_nso.
**    endif.
*
**------ Elem.Suchhilfe für Adress-Massensuche ausblenden ?  ------------
*    CLEAR lv_addrsearch_act.
*
*    CALL FUNCTION 'BUA_BUTADDRSEARCH_READ'
*      IMPORTING
*        ev_addsearch_active = lv_addrsearch_act.
*
*    IF lv_addrsearch_act IS INITIAL.
**     suppress search help BU_AD
*      DELETE shlp_tab WHERE shlpname = gc_shlp_bu_adr.
*    ENDIF.
*
**------ Elem.Suchhilfe für Adressversionen einblenden ? ----------------
*    CLEAR lv_addrv_exist.
*
**    CALL FUNCTION 'OM_FUNC_MODULE_EXIST'
**      EXPORTING
**        FUNCTION_MODULE       = 'ADDR_TSADV_READ_ALL'
**     EXCEPTIONS
**       NOT_EXISTENT          = 1
**       OTHERS                = 2.
**
**    IF SY-SUBRC = 0.
**     function modules exists, check for address versions
*    CALL FUNCTION 'ADDR_TSADV_READ_ALL'
*      IMPORTING
*        number_of_active_versions = lv_active_vers
*      TABLES
*        active_versions           = lt_adrv_act.
*
**     check result
*    IF lv_active_vers GT 0.
*      lv_addrv_exist = 'X'.
*    ENDIF.
*
**    ENDIF.
*
*    IF lv_addrv_exist EQ space.
**     suppress search help BUPAA_VERS
*      DELETE shlp_tab WHERE shlpname = gc_shlp_addrv.
*    ENDIF.
*
**------ Prüfen ob unscharfe Suche aktiv --------------------------------
*    CALL FUNCTION 'SXC_EXIT_CHECK_ACTIVE'
*      EXPORTING
*        exit_name  = 'ADDRESS_SEARCH'
*      EXCEPTIONS
*        not_active = 1
*        OTHERS     = 2.
*    IF sy-subrc <> 0 OR cl_web_dynpro=>is_active = abap_true.
*      DELETE shlp_tab WHERE shlpname = gc_shlp_bupay.
*    ENDIF.
**------ Prüfungen nachfolgender Anw. ob Suchhilfen aktiv sein dürfen
**---- Instanz für BADI-Aufruf
*     call method cl_exithandler=>get_instance
*       exporting
*         exit_name = 'BUPA_SHLP_CONTROL'
*         null_instance_accepted = space
*       changing
*         instance  = lv_exit_object.
*
*
***---- BADI-Aufruf
*    lt_shlp_tab[] = shlp_tab[].
*     call method lv_exit_object->filter_incl_shlp
*       changing
*         ct_shlp_tab = lt_shlp_tab.
*
*     shlp_tab[] = lt_shlp_tab[].
*
***------ Ende Exit-Verarbeitung -----------------------------
*     exit.
*  ENDIF.

ENDFUNCTION.
