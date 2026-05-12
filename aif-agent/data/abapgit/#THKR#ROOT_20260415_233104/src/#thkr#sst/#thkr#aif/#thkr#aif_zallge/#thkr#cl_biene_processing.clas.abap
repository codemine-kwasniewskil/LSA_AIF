class /THKR/CL_BIENE_PROCESSING definition
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
        value TYPE REF TO /thkr/cl_biene_processing,
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

  class-data MO_INSTANCE type ref to /THKR/CL_BIENE_PROCESSING .
  data MV_RANDOM type NUM4 .
  class-data MT_INSTANCES type TY_T_INSTANCES .

  class-methods GET_INSTANCE
    returning
      value(RO_INSTANCE) type ref to /THKR/CL_BIENE_PROCESSING .
  methods CONSTRUCTOR
    importing
      !IS_RUN_INFO type TY_S_RUN_INFO .
  methods CHECK_VR_NEEDED
    importing
      !IV_KAPITEL type ZNSI_KAPITEL
      !IV_TITEL type /THKR/MIG_TITEL_PROFISKAL
    returning
      value(RV_ERROR) type FLAG .
  methods CHECK_VR_NOT_NEEDED
    importing
      !IV_KAPITEL type ZNSI_KAPITEL
      !IV_TITEL type /THKR/MIG_TITEL_PROFISKAL
    returning
      value(RV_ERROR) type FLAG .
  methods CALC_BETR_WITH_PERCENTAGE
    importing
      !IV_KAPITEL type ZNSI_KAPITEL
      !IV_TITEL type /THKR/MIG_TITEL_PROFISKAL
      !IV_WRBTRG type WRBTR
    returning
      value(RV_WRBTRG) type WRBTR .
protected section.
private section.

  types:
    TY_T_VR_INFO TYPE STANDARD TABLE OF /aif/t_vmapval5 .

  data MT_AIF_VR_INFO type TY_T_VR_INFO .
  data MS_AIF_GLOBALES type TY_S_RUN_INFO .

  methods SELECT_AIF_VR_INFORMATION .
ENDCLASS.



CLASS /THKR/CL_BIENE_PROCESSING IMPLEMENTATION.


  method CALC_BETR_WITH_PERCENTAGE.

    try.
      if mt_aif_vr_info[ ext_value1 = iv_kapitel ext_value2 = iv_titel ]-ext_value3 is not INITIAL AND mt_aif_vr_info[ ext_value1 = iv_kapitel ext_value2 = iv_titel ]-ext_value3 > 0.
        rv_wrbtrg = iv_wrbtrg * ( mt_aif_vr_info[ ext_value1 = iv_kapitel ext_value2 = iv_titel ]-ext_value3 / 100 ).
      else.
        "Wert 1:1 zurückgeben.
        rv_wrbtrg = iv_wrbtrg.
      endif.
    catch cx_sy_itab_line_not_found.
      rv_wrbtrg = iv_wrbtrg.
    ENDTRY.

  endmethod.


  METHOD check_vr_needed.

    READ TABLE mt_aif_vr_info ASSIGNING FIELD-SYMBOL(<ls_vr_info>) WITH KEY ext_value1 = iv_kapitel
                                                                            ext_value2 = iv_titel.
    IF sy-subrc <> 0.
      "Kein Datensatz gefunden
      rv_error = abap_true.
    ELSE.
      CASE <ls_vr_info>-int_value.    "int_value = Kennzeichen, ob verrechnet wird.
        WHEN: abap_true.
          "Verrechnung mit Landesanteilen benötigt.
          rv_error = abap_false.
        WHEN: abap_false.
          "keine Verrechnung mit Landesanteil benötigt
          rv_error = abap_true.
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD CHECK_VR_NOT_NEEDED.

    READ TABLE mt_aif_vr_info ASSIGNING FIELD-SYMBOL(<ls_vr_info>) WITH KEY ext_value1 = iv_kapitel
                                                                            ext_value2 = iv_titel.
    IF sy-subrc <> 0.
      rv_error = abap_true.
    ELSE.
      CASE <ls_vr_info>-int_value.  "int_value = Kennzeichen, ob verrechnet wird
        WHEN: abap_true.
          "Verrechnung mit Landesanteilen benötigt.
          rv_error = abap_true.
        WHEN: abap_false.
          "keine Verrechnung mit Landesanteil benötigt
          rv_error = abap_false.
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD CONSTRUCTOR.
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

    select_aif_vr_information( ).
  ENDMETHOD.


  METHOD GET_INSTANCE.
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


  METHOD select_aif_vr_information.
    CONSTANTS: lc_ns TYPE /AIF/ns VALUE 'ZALLGE'.
    CONSTANTS: lc_vmap TYPE /aif/vmapname VALUE 'MAP_BIENE_VR'.
    SELECT  *
      FROM /aif/t_vmapval5
      WHERE ns = @lc_ns
      AND vmapname = @lc_vmap
      ORDER BY ext_value1 ASCENDING, ext_value2 ASCENDING "ext_value1 = Kapitel ext_value2 = Titel
      INTO TABLE @mt_aif_vr_info.
  ENDMETHOD.
ENDCLASS.
