class /THKR/CL_PSM_MB_FMKU_BUDGET_DC definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_FMKU_BUDGET_DOC .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_PSM_MB_FMKU_BUDGET_DC IMPLEMENTATION.


  METHOD if_ex_fmku_budget_doc~check_bu_address_auth.
*    Änd.-Nr.    : 1                        Änd.-Datum: 26.03.2025
*    Bearbeiter  : Andreas Baier              User-ID: ZHM00000038
*    Beschreibung:
*    Als Team RuB möchten wir die Berechtigungen der Budgetierungsrollen
*    differenzieren um verschiedene Funktionalitäten in der Transaktion
*    FMBB unterschiedlich zur Verfügung stellen zu können
*    (Budget erfassen / Budget umbuchen).
*    Das Mapping ACTVT - Vorgang wird in Tabelle /THKR/PSM_VORG_ACTVT gepflegt
**********************************************************************
    "Standardimplementierung
    DATA L_s_budget_address TYPE fmku_s_dimpart.
    MOVE-CORRESPONDING i_s_line-address TO l_s_budget_address.
    CALL FUNCTION 'FM_AUTH_CHECK_BU_ADDRESS'
      EXPORTING
        i_fm_area         = i_s_header-fm_area
        i_address         = l_s_budget_address
        i_fiscyear        = i_s_line-fiscyear
        i_actv            = i_actvt
        i_ACTV_A          = i_actvta
      EXCEPTIONS
        no_authorization  = 1
        master_data_error = 2
        OTHERS            = 3.
    IF sy-subrc = 1.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING no_authorization.
    ELSEIF sy-subrc = 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING master_data_error.
    ENDIF.


    DATA ls_vorg_actvt TYPE /thkr/psm_v_act.
    DATA lt_vorg_actvt TYPE STANDARD TABLE OF /thkr/psm_v_act.
    DATA lv_no_auth TYPE char1.
*    DATA lv_no_auth_vorgang TYPE zpsm_vorg_beschr.
    DATA lv_subrc TYPE n.
    DATA lv_check_utk TYPE abap_bool.
    IF i_s_header-process_ui IS NOT INITIAL.
      SELECT * FROM /thkr/psm_v_act WHERE process_ui EQ @i_s_header-process_ui
        INTO TABLE @lt_vorg_actvt.
      "Check für alle Eingetragenen ACTVTs in ZPSM_VORG_ACTVT für den Vorgang
      "Kein Eintrag -> Keine Prüfung


      DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).

      LOOP AT lt_vorg_actvt ASSIGNING FIELD-SYMBOL(<lf_vorg_actvt>).
        CLEAR lv_subrc.
        CASE lv_object_fica.
          WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

            CALL FUNCTION '/THKR/CHECK_FICA_UTK'
              EXPORTING
                activity = <lf_vorg_actvt>-actvt
*               FM_AREA  =
*               FM_FINCODE_AUTHGRP       =
*               FM_FMFCTR_AUTHGRP        =
*               FM_FIPEX_AUTHGRP         =
*               FM_MEASURE_AUTHGRP       =
*               FM_FAREA_AUTHGRP         =
*               IV_USER  = SY-UNAME
              IMPORTING
                ex_subrc = lv_subrc.

          WHEN OTHERS.

            CALL FUNCTION 'Z_CHECK_FICA_TRG'
              EXPORTING
                activity = <lf_vorg_actvt>-actvt
*               FM_AREA  =
*               FM_FINCODE_AUTHGRP       =
*               FM_FMFCTR_AUTHGRP        =
*               FM_FIPEX_AUTHGRP         =
*               FM_MEASURE_AUTHGRP       =
*               FM_FAREA_AUTHGRP         =
*               IV_USER  = SY-UNAME
              IMPORTING
                ex_subrc = lv_subrc.

        ENDCASE.

        IF lv_subrc IS NOT INITIAL.
          lv_no_auth = 'X'.
          "lv_no_auth_vorgang = <lf_vorg_actvt>-process_beschr.
        ENDIF.

      ENDLOOP.
      IF lv_no_auth IS NOT INITIAL.
        MESSAGE ID '/THKR/RUB_MESSG' TYPE 'E' NUMBER '999'
         WITH 'Keine Berechtigung für Vorgang: ' sy-msgv2 RAISING no_authorization.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  method IF_EX_FMKU_BUDGET_DOC~CREATE_NEW_DOC.

    EXIT.

  endmethod.


  method IF_EX_FMKU_BUDGET_DOC~MULTI_DOC_ACTIVE.

    return.
  endmethod.
ENDCLASS.
