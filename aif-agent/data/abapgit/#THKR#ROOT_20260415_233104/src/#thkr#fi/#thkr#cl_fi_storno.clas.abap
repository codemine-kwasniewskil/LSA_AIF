class /THKR/CL_FI_STORNO definition
  public
  create public .

public section.

  constants C_MODUL_FI type /THKR/DTE_FI_MODUL value 'FI' ##NO_TEXT.
  constants C_STATUS_START_10 type /THKR/DTE_FI_WF_STATUS value '10' ##NO_TEXT.
  data C_STATUS_ABGELEHNT_40 type /THKR/DTE_FI_WF_STATUS value '40' ##NO_TEXT.
  data C_STATUS_ABBRUCH_45 type /THKR/DTE_FI_WF_STATUS value '45' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !I_FI_BELEG_STORNO_DATA type /THKR/S_FI_KEY_STORNO_DATA .
  methods START_FI_STORNO
    changing
      !CT_RETURN_TAB type BAPIRET2_TT
    raising
      /THKR/CX_FI .
protected section.

  data MS_STORNO_BKPF type BKPF .
  data MV_LFDNR type LFDNR .
  data MS_FI_STORNO_DATA type /THKR/S_FI_KEY_STORNO_DATA .

  methods CHECK_STORNO_AUTH
    raising
      /THKR/CX_FI .
  methods CHECK_STORNO_BELEG_DATA
    raising
      /THKR/CX_FI .
  methods START_STORNO_WF
    changing
      !CT_RETURN_TAB type BAPIRET2_TT
    raising
      /THKR/CX_FI .
private section.
ENDCLASS.



CLASS /THKR/CL_FI_STORNO IMPLEMENTATION.


  METHOD check_storno_auth.

    DATA:
      lv_subrc TYPE subrc,
      lv_fipex TYPE fm_fipex.


* Prüfung auf Änderungsberechtigung im Buchungskreis
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'BUKRS' FIELD ms_fi_storno_data-bukrs
    ID 'ACTVT' FIELD '06'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_fi  MESSAGE e133(/thkr/fi_wf_bkpf).
      " Keine Berechtigung zur Bearbeitung vorhanden.
    ENDIF.



*   1. Sachkontenzeile für Authcheck lesen
    SELECT belnr, gjahr, buzei, gsber, augdt, koart,
           bukrs, geber, measure, fistl, fipos, lifnr, kunnr
      UP TO 1 ROWS FROM bseg INTO @DATA(ls_bseg)
      WHERE bukrs = @ms_fi_storno_data-bukrs
        AND belnr = @ms_fi_storno_data-belnr
        AND gjahr = @ms_fi_storno_data-gjahr
        AND koart = 'S'
        AND kostl IS NOT NULL
     ORDER BY PRIMARY KEY.
    ENDSELECT.

* Prüfung auf Änderungsberechtigung im Geschäftsbereich
    AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
    ID 'GSBER' FIELD ls_bseg-gsber
    ID 'ACTVT' FIELD '06'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_fi   MESSAGE e133(/thkr/fi_wf_bkpf).
      " Keine Berechtigung zur Bearbeitung vorhanden.
    ENDIF.


* authcheck_beleg
    SELECT SINGLE augrp FROM fmfctr INTO @DATA(lv_auth_grp_fistl)
            WHERE fikrs EQ @ms_storno_bkpf-fikrs AND fictr EQ @ls_bseg-fistl.

    SELECT SINGLE augrp FROM fmci INTO @DATA(lv_auth_grp_fipos)
            WHERE fikrs EQ @ms_storno_bkpf-fikrs AND fipos EQ @ls_bseg-fipos.

    SELECT SINGLE augrp FROM fmfincode INTO @DATA(lv_auth_grp_fond)
            WHERE fincode EQ @ls_bseg-geber AND fikrs   EQ @ms_storno_bkpf-fikrs.

    SELECT SINGLE authgrp FROM fmmeasure INTO @DATA(lv_auth_grp_hhp)
            WHERE measure EQ @ls_bseg-measure AND fmarea  EQ @ms_storno_bkpf-fikrs.

    DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).

    CASE lv_object_fica.
      WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

        CLEAR lv_fipex.

        SELECT SINGLE fipex FROM fmfxpo
              INTO lv_fipex
              WHERE fipos = ls_bseg-fipos.
        IF lv_fipex IS INITIAL.
          lv_fipex = ls_bseg-fipos.
        ENDIF.

        CALL FUNCTION '/THKR/CHECK_FICA_UTK'
          EXPORTING
            activity           = '06'
            fm_area            = ms_storno_bkpf-fikrs
            fm_fincode_authgrp = lv_auth_grp_fond
            fm_fmfctr_authgrp  = lv_auth_grp_fistl
            fm_fipex           = lv_fipex
            fm_measure_authgrp = lv_auth_grp_hhp
*           FM_FAREA_AUTHGRP   =
          IMPORTING
            ex_subrc           = lv_subrc.

        IF lv_subrc <> 0.
          RAISE EXCEPTION TYPE /thkr/cx_fi  MESSAGE e201(/thkr/fi_wf_bkpf).
        ENDIF.

      WHEN OTHERS.

        CALL FUNCTION 'Z_CHECK_FICA_TRG'
          EXPORTING
            activity           = '06'
            fm_area            = ms_storno_bkpf-fikrs
            fm_fincode_authgrp = lv_auth_grp_fond
            fm_fmfctr_authgrp  = lv_auth_grp_fistl
            fm_fipex_authgrp   = lv_auth_grp_fipos
            fm_measure_authgrp = lv_auth_grp_hhp
*           FM_FAREA_AUTHGRP   =
          IMPORTING
            ex_subrc           = lv_subrc.

        IF lv_subrc <> 0.
          RAISE EXCEPTION TYPE /thkr/cx_fi  MESSAGE e200(/thkr/fi_wf_bkpf).
        ENDIF.


    ENDCASE.

    IF ls_bseg-kunnr IS NOT INITIAL.
      DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                                    iv_partner = ls_bseg-kunnr
                                    iv_type = 'D'  ).
      IF no_auth_l EQ abap_true.
        RAISE EXCEPTION TYPE /thkr/cx_fi   MESSAGE e010(/thkr/bp) WITH ls_bseg-kunnr.


      ENDIF.
    ELSEIF ls_bseg-lifnr IS NOT INITIAL.
      no_auth_l = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = ls_bseg-lifnr
                              iv_type = 'K'  ).
      IF no_auth_l EQ abap_true.
        RAISE EXCEPTION TYPE /thkr/cx_fi   MESSAGE e010(/thkr/bp) WITH ls_bseg-lifnr.


      ENDIF.
    ENDIF.

    IF ls_bseg-augdt IS NOT INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_fi   MESSAGE e362(/thkr/fi_wf_bkpf).
      " Keine Änderung möglich, Beleg ist ausgeglichen.
    ENDIF.
  ENDMETHOD.


  METHOD check_storno_beleg_data.


    IF ms_fi_storno_data-stgrd IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_fi MESSAGE e364(/thkr/fi_wf_bkpf).
      " Bitte geben Sie einen Stornogrund an.
    ENDIF.


    IF ms_fi_storno_data-bukrs IS INITIAL OR ms_fi_storno_data-belnr IS INITIAL OR ms_fi_storno_data-gjahr IS INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_fi MESSAGE w360(/thkr/fi_wf_bkpf).
      " Bitte geben Sie Belegnummer, Buchungskreis und Geschäftsjahr an.
    ENDIF.

* prüfen ob FI Beleg existiert
    SELECT SINGLE * FROM bkpf INTO @ms_storno_bkpf
      WHERE bukrs EQ @ms_fi_storno_data-bukrs AND gjahr EQ @ms_fi_storno_data-gjahr AND belnr EQ @ms_fi_storno_data-belnr.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE /thkr/cx_fi
       MESSAGE w389(f5a) WITH ms_fi_storno_data-belnr ms_fi_storno_data-bukrs ms_fi_storno_data-gjahr.
    ENDIF.

* Prüfen, ob der Beleg für Stornierung vorgesehen ist
    SELECT SINGLE * FROM /thkr/stornoc
                        INTO @DATA(ls_stornoc)
                       WHERE bukrs = @ms_fi_storno_data-bukrs
                         AND modul = @c_modul_fi
                         AND gjahr = @ms_fi_storno_data-gjahr
                         AND belnr = @ms_fi_storno_data-belnr.
    mv_lfdnr = ls_stornoc-lfdnr.
    IF sy-subrc = 0 AND ls_stornoc-status NE c_status_abgelehnt_40 AND ls_stornoc-status NE c_status_abbruch_45. "Abgelehnt und Abbruch durch SA
      " Der Beleg &1/&2/&3 ist unter der Nummer &4 zum Storno vorgesehen.
      RAISE EXCEPTION TYPE /thkr/cx_fi
        MESSAGE e356(/thkr/fi_wf_bkpf) WITH ms_fi_storno_data-belnr ms_fi_storno_data-bukrs ms_fi_storno_data-gjahr mv_lfdnr.
    ENDIF.

* Prüfung, ob ein Ausgleichsbeleg angegeben wurde
    SELECT augbl FROM bseg
      WHERE bukrs EQ @ms_fi_storno_data-bukrs
      AND   gjahr EQ @ms_fi_storno_data-gjahr
      AND   belnr EQ @ms_fi_storno_data-belnr
      AND   ( koart EQ 'D' OR koart EQ 'K' )
      AND   augbl IS NOT INITIAL
      INTO TABLE @DATA(lt_beleg).

    IF sy-subrc IS INITIAL AND lt_beleg IS NOT INITIAL.
      RAISE EXCEPTION TYPE /thkr/cx_fi MESSAGE e378(/thkr/fi_wf_bkpf).
    ENDIF.



  ENDMETHOD.


  method CONSTRUCTOR.
    me->ms_fi_storno_data = i_fi_beleg_storno_data.
  endmethod.


  METHOD start_fi_storno.


    me->check_storno_beleg_data(  ).

    me->check_storno_auth(  ).

    me->start_storno_wf(
      CHANGING
        ct_return_tab = ct_return_tab
    ).



  ENDMETHOD.


  METHOD start_storno_wf.

    IF mv_lfdnr IS INITIAL.
      ADD 1 TO mv_lfdnr.
    ENDIF.

    IF ms_fi_storno_data-wf_status IS INITIAL.
      ms_fi_storno_data-wf_status = c_status_start_10.
    ENDIF.

    DATA(ls_storno) = VALUE /thkr/stornoc(
                                          mandt  = sy-mandt
                                          bukrs  = ms_fi_storno_data-bukrs
                                          modul  = c_modul_fi
                                          belnr  = ms_fi_storno_data-belnr
                                          gjahr  = ms_fi_storno_data-gjahr
                                          lfdnr  = mv_lfdnr
                                          stgrd  = ms_fi_storno_data-stgrd
                                          status = ms_fi_storno_data-wf_status
                                          usnam  = sy-uname
                                          cpudt  = sy-datum
                                          cputm  = sy-uzeit
    ).

* Daten für WF sichern
    INSERT /thkr/stornoc FROM ls_storno.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.

* WF Starten
      IF ms_fi_storno_data-sst IS INITIAL.
        CALL FUNCTION '/THKR/WF_START_BKPF_STORNO'
          EXPORTING
            is_storno                = ls_storno
          EXCEPTIONS
            no_workflow_start        = 1
            bereits_offener_workflow = 2
            OTHERS                   = 3.
      ELSE.
        CALL FUNCTION '/THKR/WF_START_BKPF_STORNO_SST'
          EXPORTING
            is_storno                = ls_storno
          EXCEPTIONS
            no_workflow_start        = 1
            bereits_offener_workflow = 2
            OTHERS                   = 3.
      ENDIF.
      CASE sy-subrc.
        WHEN '0'.
          if 1 = 0.  MESSAGE s323(f5) WITH | { ms_fi_storno_data-belnr } / { ls_storno-lfdnr }| ms_fi_storno_data-bukrs. endif.
          Append value bapiret2( type = 'S'
                                 id = 'F5'
                                 number = 323
                                 message_v1 = | { ms_fi_storno_data-belnr } / { ls_storno-lfdnr }|
                                 message_v2 = ms_fi_storno_data-bukrs ) to ct_return_tab.
          " Fehlerfrei gestartet
        WHEN '1'.
          RAISE EXCEPTION TYPE /thkr/cx_fi MESSAGE e358(/thkr/fi_wf_bkpf).
          " Der Workflow konnte nicht gestartet werden.
        WHEN '2'.
          RAISE EXCEPTION TYPE /thkr/cx_fi MESSAGE e357(/thkr/fi_wf_bkpf).
          " Zu diesem Beleg wurde bereits ein Workflow gestartet.
        WHEN '3'.
          RAISE EXCEPTION TYPE /thkr/cx_fi MESSAGE e359(/thkr/fi_wf_bkpf).
          " Es ist ein unbekannter Fehler bei der Workflowverarbeitung aufgetreten.
      ENDCASE.

    ELSE.
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE /thkr/cx_fi  MESSAGE e352(/thkr/fi_wf_bkpf).
      " Die Änderungen konnten nicht gespeichert werden.
    ENDIF.



  ENDMETHOD.
ENDCLASS.
