FUNCTION /thkr/wf_regel_ao_01 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(WORKFLOW) TYPE  /THKR/DTE_WF_WFTYP OPTIONAL
*"     VALUE(FUNKTION) TYPE  /THKR/DTE_WF_FUNKTION OPTIONAL
*"     VALUE(PREVIOUS_AGENTS) TYPE  SWP_AGENT OPTIONAL
*"     VALUE(IV_WITH_HOLDER_ONLY) TYPE  CHAR1 DEFAULT 'X'
*"  TABLES
*"      ACTOR_TAB STRUCTURE  SWHACTOR
*"      AC_CONTAINER STRUCTURE  SWCONT
*"  EXCEPTIONS
*"      NOBODY_FOUND
*"----------------------------------------------------------------------
  TYPE-POOLS: abap.

  TYPES: BEGIN OF lty_data_tmp, " zur Laufzeit zu ermittelnde Daten, die nicht versorgt werden
           wi       TYPE sww_wiid,
           bukrs    TYPE bukrs,
           zgsber   TYPE gsber,
           zfipos   TYPE fm_fipex,
           zfistl   TYPE fistl,
           zfonds   TYPE bp_geber,
           zfkber   TYPE fkber,
           waers    TYPE waers,
           zgprolle TYPE bu_group,
         END OF lty_data_tmp.

  DATA: lt_attr      TYPE hrtb_attvalue,
        ls_data_tmp  TYPE lty_data_tmp,
        lv_matkl     TYPE matkl,
        ls_fipo_temp TYPE fipos,
        Ls_INPUT_len LIKE sy-fdpos.

  DATA: lo_wf   TYPE REF TO /thkr/cl_wf_funktion_srv.


  CONSTANTS: lc_wf_id      TYPE string VALUE 'WFTYP',
             lc_wf_funk    TYPE string VALUE 'FUNKTION',
             lc_tech_admin TYPE string VALUE 'TECH_WFADMIN',
             lc_wi         TYPE string VALUE 'WI_ID',
             lc_bukrs      TYPE string VALUE 'BUKRS',
             lc_fipos      TYPE string VALUE 'FIPOS',
             lc_fistl      TYPE string VALUE 'FISTL',
             lc_fonds      TYPE string VALUE 'FONDS',
             lc_fkber      TYPE string VALUE 'FKBER',
             lc_gsber      TYPE string VALUE 'GSBER',
             lc_waers      TYPE string VALUE 'WAERS',
             lc_gprole     TYPE string VALUE 'GP_ROLLE'.

  CREATE OBJECT lo_wf.


  TRY.

      " Ermittle Daten aus Container
      DATA(lv_wf_id)    = CONV z_om_dte_wf_id( ac_container[ element = lc_wf_id ]-value ).        " Workflow-ID
      DATA(lv_wf_funk)  = CONV z_om_dte_funktion( ac_container[ element = lc_wf_funk ]-value ).   " Workflow-Funktion
      IF line_exists( ac_container[ element = lc_bukrs ] ).
        ls_data_tmp-bukrs = ac_container[ element = lc_bukrs ]-value.                             " Buchungskreis aus Container
      ELSE.
        "Sonderlogik, falls nicht vorhanden
      ENDIF.

      IF line_exists( ac_container[ element = lc_fipos ] ).                                          " Finanzposition

        ls_fipo_temp = ac_container[ element = lc_fipos ]-value.
        Ls_INPUT_len = strlen( ls_fipo_temp ).
        IF ls_input_len < 14.
          ls_data_tmp-zfipos = ls_fipo_temp.
        ELSE.
          SELECT SINGLE fipex FROM fmfxpo
            INTO ls_data_tmp-zfipos
            WHERE fipos = ls_fipo_temp.
            if sy-subrc <> 0.
              ls_data_tmp-zfipos = ls_fipo_temp.
              ENDIF.
        ENDIF.

      ENDIF.
      IF line_exists( ac_container[ element = lc_fistl ] ).                                          " Finanzstelle
        ls_data_tmp-zfistl = ac_container[ element = lc_fistl ]-value.
      ENDIF.
      IF line_exists( ac_container[ element = lc_fonds ] ).                                          " Fonds
        ls_data_tmp-zfonds = ac_container[ element = lc_fonds ]-value.
      ENDIF.
      IF line_exists( ac_container[ element = lc_fkber ] ).                                          " Funktionsbereich
        ls_data_tmp-zfkber = ac_container[ element = lc_fkber ]-value.
      ENDIF.
      IF line_exists( ac_container[ element = lc_gsber ] ).                                          " Geschäftsbereich
        ls_data_tmp-zgsber = ac_container[ element = lc_gsber ]-value.
      ENDIF.
      IF line_exists( ac_container[ element = lc_waers ] ).                                          " Währung
        ls_data_tmp-waers = ac_container[ element = lc_waers ]-value.
      ENDIF.
      IF line_exists( ac_container[ element = lc_gprole ] ).                                          " GP-Rolle
        ls_data_tmp-zgprolle = ac_container[ element = lc_gprole ]-value.
      ENDIF.

      IF line_exists( ac_container[ element = lc_wi ] ).                                          " Workitem-ID
        ls_data_tmp-wi = ac_container[ element = lc_wi ]-value.
      ENDIF.


      " Ermittle notwendige Attribute für Workflow und Funktion
      SELECT attribut FROM /thkr/wf_control INTO TABLE @DATA(lt_funk) WHERE workflow = @lv_wf_id AND funktion = @lv_wf_funk.
      CHECK sy-subrc IS INITIAL.

      LOOP AT lt_funk ASSIGNING FIELD-SYMBOL(<ls_funk>).

        APPEND INITIAL LINE TO lt_attr ASSIGNING FIELD-SYMBOL(<ls_attr>).
        <ls_attr>-attrib = <ls_funk>-attribut.

        DATA(lv_ref) = 'ls_data_tmp' && '-' && <ls_funk>-attribut.
        ASSIGN (lv_ref) TO FIELD-SYMBOL(<lv_value>).
        CHECK sy-subrc IS INITIAL.
        <ls_attr>-value = <lv_value>.

      ENDLOOP.



      " Ermittle Genehmiger
      DATA(lt_plans) = lo_wf->get_approver( iv_wf_id            = lv_wf_id               " Workflow
                                            iv_funk             = lv_wf_funk             " Genehmigungsfunktion
                                            iv_with_holder_only = iv_with_holder_only    " Nur besetzte Planstellen?
                                            it_attr             = lt_attr             ). " Attribute und Werte

      "Hier ggf. Genehmiger ausschließen, Rückmeldung steht aus


      " Prüfe, ob keine Genehmiger gefunden wurden
      IF lt_plans IS INITIAL.

        " Ermittle OM Support
        lt_plans = lo_wf->get_approver( iv_wf_id            = lv_wf_id                                   " Workflow
                                        iv_funk             = /thkr/cl_wf_funktion_srv=>gc_wf_funk_omsp    " OM-Support
                                        iv_with_holder_only = iv_with_holder_only                        " Nur besetzte Planstellen?
                                        it_attr             = lt_attr                                 ). " Attribute und Werte

      ENDIF.

      " Befülle Rückgabetabelle
      LOOP AT lt_plans ASSIGNING FIELD-SYMBOL(<ls_plans>).
        APPEND VALUE #( otype = 'S' objid = <ls_plans> ) TO actor_tab.
      ENDLOOP.

    CATCH cx_root.

  ENDTRY.

  IF actor_tab[] IS INITIAL.
    " Ermitteln WF Support
    lo_wf->gv_support = abap_true.                   " Supportfunktion gestartet
    lt_plans = lo_wf->get_support( EXPORTING iv_wf_id = lv_wf_id
                                             iv_bukrs = ls_data_tmp-bukrs
                                             iv_gsber = ls_data_tmp-zgsber
                                             it_container = ac_container[] ).

    " Befülle Rückgabetabelle
    LOOP AT lt_plans ASSIGNING <ls_plans>.
      APPEND VALUE #( otype = 'S' objid = <ls_plans> ) TO actor_tab.
    ENDLOOP.
    FREE lo_wf->gv_support.                         " Supportfunktion beendet
  ENDIF.

*  " Setze Workflow-Admin
*  IF actor_tab[] IS INITIAL AND iv_with_holder_only = abap_true.
*
*    SELECT 'S' AS otype, value_von AS objid FROM zwf_t_parameter INTO CORRESPONDING FIELDS OF TABLE @actor_tab[]
*      WHERE object = @lc_tech_admin.
*    IF sy-subrc IS NOT INITIAL.
*
*      SELECT SINGLE plans FROM pa0001 INNER JOIN pa0105 ON pa0001~pernr = pa0105~pernr AND pa0001~plans <> '' AND pa0001~begda <= @sy-datum AND pa0001~endda >= @sy-datum
*        INTO @DATA(lv_plans)
*        WHERE pa0105~usrid = 'SAP_WFRT' AND pa0105~begda <= @sy-datum AND pa0105~endda >= @sy-datum.
*      IF sy-subrc IS INITIAL.
*        APPEND VALUE #( otype = 'S' objid = lv_plans ) TO actor_tab.
*      ENDIF.
*
*    ENDIF.
*  ENDIF.

ENDFUNCTION.
