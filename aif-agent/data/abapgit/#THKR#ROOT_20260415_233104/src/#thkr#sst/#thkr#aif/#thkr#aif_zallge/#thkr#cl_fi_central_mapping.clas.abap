class /THKR/CL_FI_CENTRAL_MAPPING definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_s_central_map,
        fikrs TYPE fikrs,
        gsber TYPE gsber,
        bukrs TYPE bukrs,
        saknr TYPE saknr,
        kostl TYPE kostl,
        prctr TYPE prctr,
        fistl TYPE fm_fictr,
        fkber TYPE fkber,
        fonds TYPE fm_fonds,
        aufnr TYPE aufnr,
      END OF ty_s_central_map .
  types:
    BEGIN OF ty_s_instance,
        key   TYPE /aif/sxmssmguid,
        value TYPE REF TO /thkr/cl_fi_central_mapping,
      END OF ty_s_instance .
  types:
    BEGIN OF ty_s_run_info,
        ximsgguid      TYPE  /aif/sxmssmguid,
        msgdate        TYPE  sydatum,
        msgtime        TYPE  syuzeit,
        variant        TYPE  /aif/t_variant,
        trace_level    TYPE  /aif/trace_level,
        sending_system TYPE  /aif/aif_business_system_key,
        log_handle     TYPE  balloghndl,
        testrun        TYPE  /aif/iftestrun,
        ns             TYPE  /aif/ns,
        ifname         TYPE  /aif/ifname,
        ifversion      TYPE  /aif/ifversion,
        finf           TYPE  /aif/t_finf,
        process_id     TYPE  /aif/process_id_e,
      END OF ty_s_run_info .
  types:
    ty_t_instances TYPE STANDARD TABLE OF ty_s_instance .

  class-data MO_INSTANCE type ref to /THKR/CL_FI_CENTRAL_MAPPING .
  data MS_CENTRAL_MAP type TY_S_CENTRAL_MAP .
  data MV_RANDOM type NUM4 .
  class-data MT_INSTANCES type TY_T_INSTANCES .

  class-methods GET_INSTANCE
    returning
      value(RO_INSTANCE) type ref to /THKR/CL_FI_CENTRAL_MAPPING .
  methods READ_CENTRAL_MAPPING
    importing
      !IV_EP type /THKR/MIG_EPL
      !IV_OEH type /THKR/MIG_OEH_OLD
      !IV_KAPITEL type /THKR/MIG_KAPITEL
      !IV_TITEL type /THKR/MIG_TITEL
      !IV_MSN type /THKR/MIG_KAM_SUB_ACC_OLD optional
      !IV_DST type /THKR/MIG_DST_OLD optional .
  methods DETERMINE_EP_OEH_FOR_ANE
    importing
      !IS_RAW_LINE type /THKR/S_AIF_BIC_ZEILE
      !IS_RAW_STRUCT type /THKR/S_AIF_BIC
    exporting
      !EV_EP type /THKR/MIG_EPL
      !EV_OEH type /THKR/MIG_OEH_OLD
      !EV_KAPITEL type /THKR/MIG_KAPITEL
      !EV_TITEL type /THKR/MIG_TITEL .
  methods BTYP_IS_ANE
    importing
      !IS_RAW_LINE type /THKR/S_AIF_BIC_ZEILE
    returning
      value(RV_BTYP_IS_ANE) type FLAG .
  methods GET_KRK_INFORMATION
    importing
      !IS_RAW_STRUC type /THKR/S_AIF_BIC
      !IS_RAW_LINE type /THKR/S_AIF_BIC_ZEILE
    exporting
      !EV_SACHKONTO type /THKR/MIG_SAKTO_ALT
      !EV_INNENAUFTRAG type /THKR/MIG_IAUF_ALT
      !EV_KOSTENSTELLE type /THKR/MIG_FUNCTR_ALT .
  methods READ_CENTR_MAP_WITH_ADD_FIELDS
    importing
      !IV_EP type /THKR/MIG_EPL
      !IV_OEH type /THKR/MIG_OEH_OLD
      !IV_SACHKONTO type /THKR/MIG_SAKTO_ALT optional
      !IV_KOSTENSTELLE type /THKR/MIG_IAUF_ALT optional
      !IV_INNENAUFTRAG type /THKR/MIG_FUNCTR_ALT optional
      !IV_MSN type /THKR/MIG_KAM_SUB_ACC_OLD
      !IV_TITEL type /THKR/MIG_TITEL
      !IV_KAPITEL type /THKR/MIG_KAPITEL .
  methods SELECT_DATA_CM_KASSE
    importing
      !IV_EP type /THKR/MIG_EPL
      !IV_OEH type /THKR/MIG_OEH_OLD
      !IV_KAPITEL type /THKR/MIG_KAPITEL
      !IV_TITEL type /THKR/MIG_TITEL .
  methods SELECT_DATA_CM_OTHERS
    importing
      !IV_EP type /THKR/MIG_EPL
      !IV_OEH type /THKR/MIG_OEH_OLD .
  methods CONSTRUCTOR
    importing
      !IS_RUN_INFO type TY_S_RUN_INFO .
protected section.
private section.

  data MV_EP type /THKR/MIG_EPL .
  data MV_OEH type /THKR/MIG_OEH_OLD .
  data MV_KAPITEL type /THKR/MIG_KAPITEL .
  data MV_TITEL type /THKR/MIG_TITEL .
  data MV_MSN type /THKR/MIG_KAM_SUB_ACC_OLD .
  data MS_AIF_GLOBALES type TY_S_RUN_INFO .
  data:
    MT_EXCEPTION_KRK type STANDARD TABLE OF /AIF/T_VMAPVAL5 .

  methods SELECT_DATA_CM_JUSTIZ
    importing
      !IV_EP type /THKR/MIG_EPL
      !IV_OEH type /THKR/MIG_OEH_OLD
      !IV_KAPITEL type /THKR/MIG_KAPITEL
      !IV_TITEL type /THKR/MIG_TITEL
      !IV_MSN type /THKR/MIG_KAM_SUB_ACC_OLD
      !IV_DST type /THKR/MIG_DST_OLD .
  methods IS_EXCEPTION_FOR_KRK
    importing
      !IV_DST_OLD type /THKR/MIG_DST_OLD
    returning
      value(RV_IS_EXCEPTION) type FLAG .
ENDCLASS.



CLASS /THKR/CL_FI_CENTRAL_MAPPING IMPLEMENTATION.


  method BTYP_IS_ANE.
    "Methode wird benötigt, ob den Funktionsbaustein /THKR/AIF_VMAP_CENTRALMAP
    "auch für nicht BIC Formate zu nutzen.
    "Typisierung der BIC-Datensätze findet dann über die Methoden statt
    if is_raw_line-01_btyp = 'ANE'.
      rv_btyp_is_ane = abap_true.
    else.
      rv_btyp_is_ane = abap_false.
    endif.
  endmethod.


  METHOD constructor.
    ms_aif_globales = is_run_info.

    "Zufallszahl generieren, um Klasseninstanziierung nachzuverfolgen.
    "Mit jeder neuen Klasseninstanz gibt es eine Zufallszahl.
    "Diese Zufallszahl wird bei höhreren Trace-Level ausgegeben.
    DATA: lv_random TYPE qf00-ran_int.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max   = 9999
        ran_int_min   = 1
      IMPORTING
        ran_int       = lv_random
      EXCEPTIONS
        invalid_input = 1
        OTHERS        = 2.
    mv_random = lv_random.
  ENDMETHOD.


  method DETERMINE_EP_OEH_FOR_ANE.
    try.
      ev_ep = is_raw_struct-line[ 01_btyp = 'FEB' 22_res1 = is_raw_line-41_urkass ]-09_aob.
      ev_oeh = is_raw_struct-line[ 01_btyp = 'FEB' 22_res1 = is_raw_line-41_urkass ]-12_oeh.
      ev_kapitel = is_raw_struct-line[ 01_btyp = 'FEB' 22_res1 = is_raw_line-41_urkass ]-10_kap.
      DATA(lv_titel) = is_raw_struct-line[ 01_btyp = 'FEB' 22_res1 = is_raw_line-41_urkass ]-11_titel.
      CONDENSE lv_titel NO-GAPS.
      ev_titel = lv_titel.
    CATCH cx_sy_itab_line_not_found.
      clear: ev_ep, ev_oeh.
    ENDTRY.
  endmethod.


  METHOD get_instance.
*    IF mo_instance IS INITIAL.
*      mo_instance = NEW #( ).
*    ENDIF.
*
*    ro_instance = mo_instance.

    TRY.
        DATA: ls_run_info TYPE ty_s_run_info.
        CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
          IMPORTING
            ximsgguid      = ls_run_info-ximsgguid
            msgdate        = ls_run_info-msgdate
            msgtime        = ls_run_info-msgtime
            variant        = ls_run_info-variant
            trace_level    = ls_run_info-trace_level
            sending_system = ls_run_info-sending_system
            log_handle     = ls_run_info-log_handle
            testrun        = ls_run_info-testrun
            ns             = ls_run_info-ns
            ifname         = ls_run_info-ifname
            ifversion      = ls_run_info-ifversion
            finf           = ls_run_info-finf
            process_id     = ls_run_info-process_id.
        ro_instance = mt_instances[ key =  ls_run_info-ximsgguid ]-value.
      CATCH cx_sy_itab_line_not_found.
        mo_instance = NEW #( is_run_info = ls_run_info ).
        APPEND VALUE ty_s_instance( key =  ls_run_info-ximsgguid
                                    value = mo_instance ) TO mt_instances.
        ro_instance = mo_instance.
    ENDTRY.
  ENDMETHOD.


  METHOD get_krk_information.
    IF is_exception_for_krk( iv_dst_old = is_raw_line-12_oeh(4) ) = abap_false.
      "Keine Ausnahme, KRK Satz ermitteln.
      READ TABLE is_raw_struc-line WITH KEY 01_btyp = 'KRK'
                                            05_quelle = is_raw_line-05_quelle
                                            06_qbelnr = is_raw_line-06_qbelnr
                                   ASSIGNING FIELD-SYMBOL(<ls_line>).
      IF sy-subrc = 0.
        ev_sachkonto = <ls_line>-22_res1.
        ev_kostenstelle = <ls_line>-24_res2.
        ev_innenauftrag = <ls_line>-26_res3.
      ELSE.
        CLEAR: ev_sachkonto.
        CLEAR: ev_kostenstelle.
        CLEAR: ev_innenauftrag.
      ENDIF.
    ELSE.
      "Ausnahme
      "KRK Satz ignorieren.
      CLEAR: ev_sachkonto.
      CLEAR: ev_kostenstelle.
      CLEAR: ev_innenauftrag.
    ENDIF.
  ENDMETHOD.


  METHOD is_exception_for_krk.
    CONSTANTS: lc_ns TYPE /aif/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_vname TYPE /aif/vmapname VALUE 'MAP_EXCEPTION_KRK'.
    CONSTANTS: lc_asterik TYPE char1 VALUE '*'.

    CLEAR: rv_is_exception.

    IF mt_exception_krk IS INITIAL.
      SELECT *
        FROM /aif/t_vmapval5
       WHERE ns = @lc_ns
         AND vmapname = @lc_vname
       INTO TABLE @mt_exception_krk.
    ENDIF.

    IF mt_exception_krk IS INITIAL.
      "es gibt keine Ausnahmen
      rv_is_exception = abap_false.
    ELSE.
      "Lesen der Ausnahmetabelle für eine Schnittstelle.
      READ TABLE mt_exception_krk ASSIGNING FIELD-SYMBOL(<ls_krk>) WITH KEY ext_value1 = ms_aif_globales-ns
                                                                            ext_value2 = ms_aif_globales-ifname
                                                                            ext_value3 = ms_aif_globales-ifversion.
      IF sy-subrc = 0 AND ( <ls_krk>-int_value = iv_dst_old or <ls_krk>-int_value = lc_asterik ).
        rv_is_exception = abap_true.
      ELSE.
        "Keine konkrete Schnittstelle
        "Prüfe auf Verwendung von Asterik
        LOOP AT mt_exception_krk ASSIGNING <ls_krk> WHERE ( ext_value1 = ms_aif_globales-ns OR ext_value1 = lc_asterik )
                                                      AND ( ext_value2 = ms_aif_globales-ifname OR ext_value2 = lc_asterik )
                                                      AND ( ext_value3 = ms_aif_globales-ifversion OR ext_value3 = lc_asterik )
                                                      AND ( int_value = iv_dst_old OR int_value = lc_asterik ).
          rv_is_exception = abap_true.

        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD read_central_mapping.


    IF iv_ep BETWEEN 93 AND 96.
      "Für Kasse.
      "in zentraler Mappingtabelle ist keine OEH gefüllt. Daher suche über
      "Einzelplan, Kapitel, Titel und Dienststelle
      IF iv_ep <> mv_ep OR iv_oeh <> mv_oeh OR iv_kapitel <> mv_kapitel OR iv_titel <> mv_titel.
        select_data_cm_kasse(
          iv_ep      = iv_ep                 " Einzelplan
          iv_oeh     = iv_oeh                 " OEH  alt
          iv_kapitel = iv_kapitel                 " Kapitel
          iv_titel   = iv_titel                 " PSM Fipos Titel ( Stellen 5-9 )
        ).
      ENDIF.
    ELSEIF iv_ep = 11.
      "Justiz
      "Verwendet noch zusätzlich das kamerale Unterkonto
      IF iv_ep <> mv_ep OR iv_oeh <> mv_oeh OR iv_kapitel <> mv_kapitel OR iv_titel <> mv_titel OR iv_msn <> mv_msn.
        select_data_cm_justiz(
          iv_ep      = iv_ep                 " Einzelplan
          iv_oeh     = iv_oeh                " OEH  alt
          iv_kapitel = iv_kapitel            " Kapitel
          iv_titel   = iv_titel              " PSM Fipos Titel ( Stellen 5-9 )
          iv_msn     = iv_msn                " kamerales Unterkonto alt
          iv_dst     = iv_dst                " DST alt
        ).
      ENDIF.
    ELSE.
      "alle Anderen
      "Suche zweistufig über Einzelplan und OEH
      IF iv_ep <> mv_ep OR iv_oeh <> mv_oeh.
        select_data_cm_others(
          iv_ep  = iv_ep                 " Einzelplan
          iv_oeh = iv_oeh                 " OEH  alt
        ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD read_centr_map_with_add_fields.
    SELECT SINGLE firks, gsber, bukrs, saknr, kostl, prctr, fictr,fkber, fonds, aufnr
      FROM /thkr/centralmap
     WHERE ep = @iv_ep
      AND oeh_old = @iv_oeh
      AND titel = @iv_titel
      AND Kapitel = @iv_Kapitel
      AND kam_sub_acc_old = @iv_msn
      AND sachkonto_old = @iv_sachkonto
      AND fundcenter_old = @iv_kostenstelle
      AND innenauftrag_old = @iv_innenauftrag
      AND valid_from <= @sy-datum
      AND valid_to >= @sy-datum
      INTO @ms_central_map.
    IF sy-subrc <> 0.
      SELECT SINGLE firks, gsber, bukrs, saknr, kostl, prctr, fictr,fkber, fonds, aufnr
      FROM /thkr/centralmap
     WHERE ep = @iv_ep
       AND dst_old = @iv_oeh(4)
       AND titel = @iv_titel
       AND Kapitel = @iv_Kapitel
       AND kam_sub_acc_old = @iv_msn
       AND sachkonto_old = @iv_sachkonto
       AND fundcenter_old = @iv_kostenstelle
       AND innenauftrag_old = @iv_innenauftrag
       AND valid_from <= @sy-datum
       AND valid_to >= @sy-datum
      INTO @ms_central_map.
      IF sy-subrc <> 0.
        CLEAR: ms_central_map.
      ENDIF.
    ENDIF.

    mv_ep = iv_ep.
    mv_oeh = iv_oeh.
    mv_msn = iv_msn.
  ENDMETHOD.


  METHOD select_data_cm_justiz.
    "Die Justiz sendet richtige Diensstellennummern (feld 49_DSTNR), die bei der eindeutigen Selektion der zentralen Mappingtabelle hilfreich sind.
    SELECT SINGLE firks, gsber, bukrs, saknr, kostl, prctr, fictr,fkber, fonds, aufnr
    FROM /thkr/centralmap
    WHERE ep = @iv_ep
     AND oeh_old = @iv_oeh
     AND dst_old = @iv_dst
     AND kapitel = @iv_kapitel
     AND titel = @iv_titel
     AND kam_sub_acc_old = @iv_msn
     AND sachkonto_old IS INITIAL
     AND fundcenter_old IS INITIAL
     AND innenauftrag_old IS INITIAL
     AND valid_from <= @sy-datum
     AND valid_to >= @sy-datum
    INTO @ms_central_map.
    IF sy-subrc <> 0.
      "pTravel schickt auch Datensätze für die Justiz. Da stimmt aber die Dienststelle nicht überein.
      "Ohne Dienststelle lesen.
      SELECT SINGLE firks, gsber, bukrs, saknr, kostl, prctr, fictr,fkber, fonds, aufnr
        FROM /thkr/centralmap
        WHERE ep = @iv_ep
        AND oeh_old = @iv_oeh
        AND kapitel = @iv_kapitel
        AND titel = @iv_titel
        AND kam_sub_acc_old = @iv_msn
        AND sachkonto_old IS INITIAL
        AND fundcenter_old IS INITIAL
        AND innenauftrag_old IS INITIAL
        AND valid_from <= @sy-datum
        AND valid_to >= @sy-datum
        INTO @ms_central_map.
        if sy-subrc <> 0.
          clear: ms_central_map.
        endif.
    ENDIF.

    mv_ep = iv_ep.
    mv_oeh = iv_oeh.
    mv_kapitel = iv_kapitel.
    mv_titel = iv_titel.
    mv_msn = iv_msn.

  ENDMETHOD.


  METHOD select_data_cm_kasse.

    SELECT SINGLE firks, gsber, bukrs, saknr, kostl, prctr, fictr,fkber, fonds, aufnr
    FROM /thkr/centralmap
   WHERE ep = @iv_ep
     AND dst_old = @iv_oeh(4)
     AND kapitel = @iv_kapitel
     AND titel = @iv_titel
     AND valid_from <= @sy-datum
     AND valid_to >= @sy-datum
    INTO @ms_central_map.
    IF sy-subrc <> 0.
      CLEAR: ms_central_map.
    ENDIF.
    mv_ep = iv_ep.
    mv_oeh = iv_oeh.
    mv_kapitel = iv_kapitel.
    mv_titel = iv_titel.


  ENDMETHOD.


  METHOD select_data_cm_others.
    SELECT SINGLE firks, gsber, bukrs, saknr, kostl, prctr, fictr,fkber, fonds, aufnr
      FROM /thkr/centralmap
     WHERE ep = @iv_ep
       AND oeh_old = @iv_oeh
       AND valid_from <= @sy-datum
       AND valid_to >= @sy-datum
      INTO @ms_central_map.
    IF sy-subrc <> 0.
      SELECT SINGLE firks, gsber, bukrs, saknr, kostl, prctr, fictr,fkber, fonds, aufnr
      FROM /thkr/centralmap
     WHERE ep = @iv_ep
       AND dst_old = @iv_oeh(4)
       AND valid_from <= @sy-datum
       AND valid_to >= @sy-datum
      INTO @ms_central_map.
      IF sy-subrc <> 0.
        CLEAR: ms_central_map.
      ENDIF.
    ENDIF.
    mv_ep = iv_ep.
    mv_oeh = iv_oeh.


  ENDMETHOD.
ENDCLASS.
