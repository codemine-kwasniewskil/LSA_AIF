FUNCTION /thkr/bp_f4if_shlp_exit_disp.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_PARAM) TYPE  CHAR30
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

  DATA: lt_results     TYPE bup_partner_guid_t,
        lt_selopt_knr  TYPE /THKR/t_BP_bukrs_range,
        lt_selopt_lief TYPE /THKR/t_BP_bukrs_range,
        lt_selopt      TYPE bus_partner_range_t,
        lt_selopt_cp   TYPE piq_selopt_t,
        lt_selopt_hash TYPE /thkr/t_bp_shlp_hash,
        lv_tabix       TYPE sy-tabix,
        lt_help_record TYPE STANDARD TABLE OF seahlpres.
  CONSTANTS: cv_mulitplicator TYPE i VALUE 2.
  IF callcontrol-step = 'SELECT'.
    CLEAR: gv_backup_max.
    gv_backup_max = callcontrol-maxrecords.
    TRY.
        " Verfünffache zur Sicherheit die Anzahl an Einträgen
        " Nicht zu viele, ansonsten könnte es Probleme geben
        callcontrol-maxrecords = callcontrol-maxrecords * cv_mulitplicator.
      CATCH cx_sy_arithmetic_error.
        " Fall das nicht geht, lösche und selektiere somit alle
        CLEAR: callcontrol-maxrecords.
    ENDTRY.
  ENDIF.
  " Rufe Standard-Exit auf
  CALL FUNCTION '/THKR/BP_F4IF_CLASS_STD_EXIT'
    TABLES
      shlp_tab    = shlp_tab
      record_tab  = record_tab
    CHANGING
      shlp        = shlp
      callcontrol = callcontrol.
  CHECK lines( record_tab ) NE 0.

  IF callcontrol-step = 'DISP' OR callcontrol-step = 'SELECT'.
    " Lese Partner aus
    CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
      EXPORTING
        parameter         = iv_param
        fieldname         = 'PARTNER'
      TABLES
        shlp_tab          = shlp_tab
        record_tab        = record_tab
        results_tab       = lt_results
      CHANGING
        shlp              = shlp
        callcontrol       = callcontrol
      EXCEPTIONS
        parameter_unknown = 1
        OTHERS            = 2.
    IF sy-subrc NE 0.
      MESSAGE e004(/thkr/bp).
    ENDIF.
    IF sy-ucomm NE 'INIT'.
      CHECK lines( record_tab ) NE 0.
      CALL FUNCTION '/THKR/BP_F4IF_CREATE_FILTER'
        EXPORTING
          it_check_partners       = lt_results
          iv_use_guid             = abap_false
          iv_f4_type              = iv_param
        IMPORTING
          et_selopts_partner      = lt_selopt
          et_selopts_partner_cp   = lt_selopt_cp
          et_selopts_partner_hash = lt_selopt_hash
        EXCEPTIONS
          no_selopts              = 1
          OTHERS                  = 2.
      IF lines( lt_selopt ) GT 0.
*        DELETE record_tab WHERE string NOT IN lt_selopt_cp.
*        lt_help_record = VALUE #( FOR l_record IN record_tab WHERE
*        ( string IN lt_selopt_hash )
*       (
*          string = l_record-string
*          dummy = l_record-dummy
*          pack_kind = l_record-pack_kind
*          pack_no = l_record-pack_no
*        ) ).
*
*        record_tab[] = lt_help_record[].

        LOOP AT record_tab ASSIGNING FIELD-SYMBOL(<lf_rectab>).
          lv_tabix = sy-tabix.
          IF NOT <lf_rectab>-string IN lt_selopt_cp.
            DELETE record_tab INDEX lv_tabix.
          ENDIF.
        ENDLOOP.
      ELSE.
        FREE: record_tab.
      ENDIF.
      " Beschränke auf Anzahl Einträge
      DELETE record_tab FROM gv_backup_max + 1.
      CLEAR: lv_tabix.
    ENDIF.
    " Setze Limit wieder
    callcontrol-maxrecords = gv_backup_max.
    IF record_tab[] IS INITIAL.
      MESSAGE 'Keine Einträge zur Selektion vorhanden'
        TYPE 'S'.
    ENDIF.
  ELSEIF callcontrol-step <> 'RETURN' AND callcontrol-step NS 'PRESEL'
    AND  callcontrol-step <> 'SELONE'.

    IF sy-ucomm NE 'INIT'.
      CALL FUNCTION '/THKR/BP_F4IF_CREATE_FILTER'
        EXPORTING
          it_check_partners       = lt_results
          iv_use_guid             = abap_false
          iv_f4_type              = iv_param
        IMPORTING
          et_selopts_partner      = lt_selopt
          et_selopts_partner_cp   = lt_selopt_cp
          et_selopts_partner_hash = lt_selopt_hash
        EXCEPTIONS
          no_selopts              = 1
          OTHERS                  = 2.
      IF lines( lt_selopt_cp ) GT 0.
        LOOP AT record_tab ASSIGNING FIELD-SYMBOL(<lf_rec2>).
          lv_tabix = sy-tabix.
          IF NOT <lf_rec2>-string IN lt_selopt_cp.
            DELETE record_tab INDEX lv_tabix.
          ENDIF.
        ENDLOOP.
*        DELETE record_tab WHERE string NOT IN lt_selopt_cp.
*        lt_help_record = VALUE #( FOR l_record IN record_tab WHERE
*   ( string IN lt_selopt_hash )
*  (
*     string = l_record-string
*     dummy = l_record-dummy
*     pack_kind = l_record-pack_kind
*     pack_no = l_record-pack_no
*   ) ).

        record_tab[] = lt_help_record[].
      ELSE.
        FREE: record_tab.
      ENDIF.
      CLEAR: lv_tabix.
    ENDIF.
    IF record_tab[] IS INITIAL.
      MESSAGE 'Keine Einträge zur Selektion vorhanden'
        TYPE 'S'.
    ENDIF.
  ENDIF.



ENDFUNCTION.
