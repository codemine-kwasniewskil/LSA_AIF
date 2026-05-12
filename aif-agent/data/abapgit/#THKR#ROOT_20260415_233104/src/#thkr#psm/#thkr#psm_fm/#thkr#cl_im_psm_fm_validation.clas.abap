class /THKR/CL_IM_PSM_FM_VALIDATION definition
  public
  final
  create public .

*"* public components of class CL_EXM_IM_FMKU_BUDGET_EVNT
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_FMKU_BUDGET_EVNT .
protected section.
*"* protected components of class CL_EXM_IM_FMKU_BUDGET_EVNT
*"* do not include other source files here!!!
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_data,
      linenb   TYPE  buku_linenb,
      fm_area  TYPE  fikrs,
      techorg  TYPE  buku_techorg,
      process  TYPE  buku_process,
      fiscyear TYPE	gjahr,
      budtype  TYPE  buku_budtype.
      INCLUDE TYPE  fmku_s_dimpart.
      INCLUDE TYPE  buku_s_tvalxxpart.
      INCLUDE TYPE fmku_s_lvalxxpart.
  TYPES: END OF ty_data .
  TYPES:
    tty_data TYPE TABLE OF ty_data .
  TYPES:
    BEGIN OF ty_calc,
      cmmtitem TYPE  fm_fipex.
      INCLUDE TYPE  buku_s_tvalxxpart.
      INCLUDE TYPE fmku_s_lvalxxpart.
  TYPES: END OF ty_calc .
  TYPES:
    tty_calc TYPE TABLE OF ty_calc .
  TYPES:
    BEGIN OF ty_check_hier,
      fikrs       TYPE fikrs,
      hivarnt     TYPE fm_hivarnt,
      fistl       TYPE fistl,
      hiroot_st   TYPE fm_fictr_t,
      parent_st   TYPE fm_fictr_p,
      next_st     TYPE fm_fictr_n,
      child_st    TYPE fm_fictr_c,
      hilevel     TYPE fm_hilevel,
      cmmtitem    TYPE fm_fipex,
      HSART_fistl TYPE fm_hsart,
      HSART_par   TYPE fm_hsart,
      HSART_chi   TYPE fm_hsart,
      send        TYPE abap_bool,
    END OF ty_check_hier .
  TYPES:
    tty_check_hier TYPE TABLE OF ty_check_hier .

  DATA t_messages TYPE bubas_t_msg .
  CONSTANTS c_sender TYPE buku_process VALUE 'SEND' ##NO_TEXT.
  CONSTANTS c_receiver TYPE buku_process VALUE 'RECV' ##NO_TEXT.
  CONSTANTS c_vrg_tran TYPE buku_process_ui VALUE 'TRAN' ##NO_TEXT.
  CONSTANTS c_vrg_entr TYPE buku_process_ui VALUE 'ENTR' ##NO_TEXT.
  CONSTANTS c_vrg_retn TYPE buku_process_ui VALUE 'RETN' ##NO_TEXT.
  CONSTANTS c_budart_df TYPE buku_budtype VALUE 'DF' ##NO_TEXT.
  CONSTANTS c_budart_bee TYPE buku_budtype VALUE 'BEE' ##NO_TEXT.
  CONSTANTS c_budart_vu TYPE buku_budtype VALUE 'VU' ##NO_TEXT.
  CONSTANTS c_hsart_b TYPE fm_hsart VALUE 'B' ##NO_TEXT.
  CONSTANTS c_hsart_a TYPE fm_hsart VALUE 'A' ##NO_TEXT.

  METHODS get_funddistr_lvl
    IMPORTING
      !is_header      TYPE fmku_s_badi_doc_header
      !is_data        TYPE ty_data
    RETURNING
      VALUE(rv_value) TYPE /thkr/fundist_lvl .
  METHODS add_message_from_syst
    IMPORTING
      !iv_detlevel  TYPE ballevel OPTIONAL
      !iv_probclass TYPE balprobcl OPTIONAL
      !iv_alsort    TYPE balsort OPTIONAL
      !is_context   TYPE bubas_s_context OPTIONAL
      !is_detail    TYPE bubas_s_doc OPTIONAL
      !it_param     TYPE bubas_t_param OPTIONAL
    CHANGING
      !ct_messages  TYPE bubas_t_msg .
  METHODS check_process_tran
    IMPORTING
      !is_header   TYPE fmku_s_badi_doc_header
      !it_data     TYPE tty_data
    EXPORTING
      !et_messages TYPE bubas_t_msg .
  METHODS check_process_entr
    IMPORTING
      !is_header   TYPE fmku_s_badi_doc_header
      !it_data     TYPE tty_data
    EXPORTING
      !et_messages TYPE bubas_t_msg .
  METHODS check_process_retn
    IMPORTING
      !is_header   TYPE fmku_s_badi_doc_header
      !it_data     TYPE tty_data
    EXPORTING
      !et_messages TYPE bubas_t_msg .
  METHODS get_hsart
    IMPORTING
      !iv_gjahr       TYPE gjahr
      !iv_fikrs       TYPE fikrs
      !iv_fipex       TYPE fm_fipex
    RETURNING
      VALUE(rv_value) TYPE fm_hsart .
*"* private components of class CL_EXM_IM_FMKU_BUDGET_EVNT
*"* do not include other source files here!!!
ENDCLASS.



CLASS /THKR/CL_IM_PSM_FM_VALIDATION IMPLEMENTATION.


  METHOD add_message_from_syst.

    DATA: ls_msg TYPE bubas_s_msg.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    MOVE-CORRESPONDING syst TO ls_msg.

    ls_msg-detlevel   = iv_DETLEVEL .
    ls_msg-probclass  = iv_PROBCLASS.
    ls_msg-alsort     = iv_ALSORT   .
    ls_msg-context    = is_context  .
    ls_msg-detail     = is_detail   .
    ls_msg-param      = it_param    .

    APPEND ls_msg TO ct_messages.

  ENDMETHOD.


  METHOD check_process_entr.
**********************************************************************
*2  Der Vorgang ENTR ERFASSUNG darf nur von der Mittelverteiler Stufe MFH angewendet werden
*   Außnahme: TAC FMCYLOADN für EPL 11
*********************************************************************

    DATA: ls_return TYPE bapiret2.
    DATA: ls_msg TYPE bubas_s_msg.
    DATA: lt_msg TYPE bubas_t_msg.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    IF sy-tcode NE 'FMCYLOADN'.

      LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_data>).

        SELECT SINGLE zz_funddistr_lvl
          FROM fmfctr
          INTO @DATA(lv_value)
          WHERE fikrs   = @is_header-fm_area
          AND   fictr   = @<fs_data>-fundsctr
          AND   datab   <= @is_header-docdate
          AND   datbis  >= @is_header-docdate.

        IF lv_value NE 'MFH'.
          "Belegpos. &: Erfassen ist nur für Mittelverteiler Stufe MFH erlaubt
          MESSAGE e012(/thkr/psm_fm) WITH <fs_data>-linenb INTO DATA(lv_dummy).
          add_message_from_syst( CHANGING ct_messages = et_messages ).
        ENDIF.

      ENDLOOP.

      APPEND LINES OF lt_msg TO et_messages.

    ENDIF.




  ENDMETHOD.


  METHOD CHECK_PROCESS_RETN.
**********************************************************************
*1.1 Der Vorgang RETN Rückgabe darf nur von der Mittelverteiler Stufe MFH angewendet werden
*    Ausnahme: keine
*********************************************************************

    DATA: ls_return TYPE bapiret2.
    DATA: ls_msg TYPE bubas_s_msg.
    DATA: lt_msg TYPE bubas_t_msg.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


      LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_data>).

        SELECT SINGLE zz_funddistr_lvl
          FROM fmfctr
          INTO @DATA(lv_value)
          WHERE fikrs   = @is_header-fm_area
          AND   fictr   = @<fs_data>-fundsctr
          AND   datab   <= @is_header-docdate
          AND   datbis  >= @is_header-docdate.

        IF lv_value NE 'MFH'.
          "Belegpos. &: Rückgabe ist nur für Mittelverteiler Stufe MFH erlaubt
          MESSAGE e014(/thkr/psm_fm) WITH <fs_data>-linenb INTO DATA(lv_dummy).
          add_message_from_syst( CHANGING ct_messages = et_messages ).
        ENDIF.

      ENDLOOP.

      APPEND LINES OF lt_msg TO et_messages.





  ENDMETHOD.


  METHOD check_process_tran.
**********************************************************************
*3  "Der Vorgang TRAN UMBUCHUNG muss der festgelegten Hierarchivariante folgen
*   Aussnahme: DF/BeE-Buchungen, BEE"

*********************************************************************

    DATA: lt_calc TYPE tty_calc.
    DATA: ls_calc TYPE ty_calc.
    DATA: ls_return TYPE bapiret2.
    DATA: ls_msg TYPE bubas_s_msg.

    DATA: ls_buku  TYPE buku_s_tvalxxpart.
    DATA: ls_fmku  TYPE fmku_s_lvalxxpart.
    DATA: lv_sum_buku TYPE buku_s_tvalxxpart-tval01.
    DATA: lv_sum_fmku TYPE fmku_s_lvalxxpart-lval01.
    DATA: lv_hivar  TYPE fm_hivarnt.
    DATA: lv_budtype TYPE  buku_budtype.
    DATA: lv_hsart_a TYPE abap_bool VALUE ' '.

    DATA: lt_check_tmp  TYPE tty_check_hier.
    DATA: ls_check_tmp  TYPE ty_check_hier.
    DATA: lt_check_hier TYPE tty_check_hier.

    FIELD-SYMBOLS: <fv> TYPE any.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    CHECK it_data[] IS NOT INITIAL.

*--------------------------------------------------------------------*
*4  "Der Vorgang TRAN UMBUCHUNG muss im Sender/Empfänger immer mit der gleichen Budgetart erfolgen
*   Aussnahme: müssen geprüft werden - derzeit keine
*--------------------------------------------------------------------*
    READ TABLE it_data ASSIGNING FIELD-SYMBOL(<fs_data>) INDEX 1.
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_check>) WHERE budtype NE <fs_data>-budtype.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      "Budgetarten für Sender und Empfänger müssen identisch sein
      MESSAGE e010(/thkr/psm_fm) INTO DATA(lv_dummy).
      add_message_from_syst( CHANGING ct_messages = et_messages ).
    ENDIF.

* Wenn bis hier Probleme aufgetreten sind, sollen  keine weiteren Meldunger angezeigt werden
    IF et_messages[] IS NOT INITIAL.
      EXIT.
    ENDIF.

    lv_budtype = <fs_data>-budtype.

*--------------------------------------------------------------------*
* 5 Der Vorgang TRAN UMBUCHUNG muss im Sender/Empfänger immer die gleiche Finanzposition ansprechen
*   Aussnahme: DF/BeE-Buchungen, BEE"
*--------------------------------------------------------------------*
    LOOP AT it_data ASSIGNING <fs_data> WHERE budtype EQ c_budart_vu
                                        AND   process EQ c_sender.
*     Ermitteln ob alle Sender von der Haushaltsart Unterposition sind
      DATA(lv_snd_hsart) = get_hsart( iv_gjahr = <fs_data>-fiscyear
                                      iv_fikrs = <fs_data>-fm_area
                                      iv_fipex = <fs_data>-cmmtitem  ).
      IF lv_snd_hsart EQ c_hsart_a.
        lv_hsart_a = abap_true.
      ENDIF.
    ENDLOOP.

* Summen pro Finanzposition bilden
    IF lv_budtype NE c_budart_vu
    OR ( lv_budtype EQ c_budart_vu AND lv_hsart_a NE abap_true ).
      LOOP AT it_data ASSIGNING <fs_data> WHERE budtype NE c_budart_df AND budtype NE c_budart_bee.
        MOVE-CORRESPONDING <fs_data> TO ls_calc.
        COLLECT ls_calc INTO lt_calc.
      ENDLOOP.
    ELSE.
      LOOP AT it_data ASSIGNING <fs_data> WHERE budtype EQ c_budart_vu.
        MOVE-CORRESPONDING <fs_data> TO ls_calc.
        CLEAR ls_calc-cmmtitem.
        COLLECT ls_calc INTO lt_calc.
      ENDLOOP.
    ENDIF.

* Die Summen pro Finanzposition müssen ausgeglichen sein
    LOOP AT lt_calc ASSIGNING FIELD-SYMBOL(<fs_calc>).

      CLEAR: lv_sum_buku, lv_sum_fmku.

*     Summen erzeugen
      MOVE-CORRESPONDING <fs_calc> TO ls_fmku.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE ls_fmku TO <fv>.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        ADD <fv> TO lv_sum_fmku.
      ENDDO.

      MOVE-CORRESPONDING <fs_calc> TO ls_buku.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE ls_buku TO <fv>.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        ADD <fv> TO lv_sum_buku.
      ENDDO.

      IF lv_sum_buku <> 0 OR lv_sum_fmku <> 0.
        "Finanzposition & ist nicht ausgeglichen
        MESSAGE e011(/thkr/psm_fm) WITH <fs_calc>-cmmtitem INTO lv_dummy.
        add_message_from_syst( CHANGING ct_messages = et_messages ).
      ENDIF.

    ENDLOOP.

* Wenn bis hier Probleme aufgetreten sind, sollen  keine weiteren Meldunger angezeigt werden
    IF et_messages[] IS NOT INITIAL.
      EXIT.
    ENDIF.


*--------------------------------------------------------------------*
*3  "Der Vorgang TRAN UMBUCHUNG muss der festgelegten Hierarchivariante folgen
*   Verteilt werden darf:
*    - innerhalb der gleichen Finazstelle
*    - Von Oben nach unten genau 1 Ebene weit
*    - Von unten nach oben genau 1 Ebene weit
*
*   Aussnahme: Buchungsart = DF/BeE-Buchungen oder BEE
*              FMFCTR-ZZ_FUNDDISTR_LVL = BFH
*
*--------------------------------------------------------------------*

* pro Sender feststellen wohin verteilt werden darf.
    LOOP AT it_data ASSIGNING <fs_data> WHERE budtype NE c_budart_df AND budtype NE c_budart_bee
                                        AND   process EQ c_sender.

      FREE lt_check_tmp.
      CLEAR ls_check_tmp.

      lv_hivar = <fs_data>-fiscyear+2(2).

*    oben nach unten
      SELECT fikrs,	hivarnt, fistl, child_st, parent_st
        FROM fmhisv
        APPENDING TABLE @lt_check_tmp
        WHERE fikrs = @is_header-fm_area
        AND   hivarnt = @lv_hivar
        AND   parent_st = @<fs_data>-fundsctr.

*    unten nach oben
      SELECT SINGLE fikrs,hivarnt, fistl, child_st, parent_st
        FROM fmhisv
        INTO CORRESPONDING FIELDS OF @ls_check_tmp
        WHERE fikrs = @is_header-fm_area
        AND   hivarnt = @lv_hivar
        AND   fistl = @<fs_data>-fundsctr.
      IF sy-subrc EQ 0.
        APPEND ls_check_tmp TO lt_check_tmp.
      ENDIF.

*    gleiche Finanzstelle
      APPEND INITIAL LINE TO lt_check_tmp ASSIGNING FIELD-SYMBOL(<fs_check_tmp>).
      <fs_check_tmp>-child_st  = <fs_data>-fundsctr.
      <fs_check_tmp>-parent_st = <fs_data>-fundsctr.
      <fs_check_tmp>-fistl     = <fs_data>-fundsctr.


      LOOP AT lt_check_tmp ASSIGNING <fs_check_tmp>.
        <fs_check_tmp>-cmmtitem = <fs_data>-cmmtitem.
*       Haushaltsstellenart des Senders
        <fs_check_tmp>-hsart_fistl = get_hsart( iv_gjahr = <fs_data>-fiscyear
                                                iv_fikrs = <fs_data>-fm_area
                                                iv_fipex = <fs_data>-cmmtitem  ).
      ENDLOOP.

      APPEND LINES OF lt_check_tmp TO lt_check_hier.

    ENDLOOP.

    SORT lt_check_hier BY fikrs	hivarnt parent_st fistl cmmtitem.
    DELETE ADJACENT DUPLICATES FROM lt_check_hier COMPARING fikrs	hivarnt parent_st fistl cmmtitem.

*--------------------------------------------------------------------*
*   prüfen, ob die Empfänger zum Sender passen / Hiearchien
*--------------------------------------------------------------------*
    LOOP AT it_data ASSIGNING <fs_data> WHERE budtype NE c_budart_df AND budtype NE c_budart_bee
                                        AND   process EQ c_receiver.

      DATA(lv_value) = get_funddistr_lvl( EXPORTING is_header = is_header
                                                    is_data   = <fs_data> ).

*     Bei VU muss der Empfänger immer HSART B haben
      DATA(lv_rcv_hsart) = get_hsart( iv_gjahr = <fs_data>-fiscyear
                                      iv_fikrs = <fs_data>-fm_area
                                      iv_fipex = <fs_data>-cmmtitem  ).
      IF lv_rcv_hsart NE c_hsart_b
      AND lv_budtype EQ c_budart_vu.
        "Belegpos. &: FiPos muss der Haushaltstelle Unterkonto angehörenn
        MESSAGE e015(/thkr/psm_fm) WITH <fs_data>-linenb INTO lv_dummy.
        add_message_from_syst( CHANGING ct_messages = et_messages ).
      ENDIF.


*     Ausnahmen dürfen beliegig verteilen
      IF lv_value = 'BFH'                                               "Mittelverteilstufe BFH
      OR <fs_data>-fundsctr EQ '4203000002'                             "Finanzstelle Bezügestelle
      OR <fs_data>-fundsctr EQ '3300000001'.                            "Finanzstelle des LVwA
        CONTINUE.
      ENDIF.


*     Verteilung von oben nach unten
      READ TABLE lt_check_hier WITH KEY fistl    = <fs_data>-fundsctr
                                        cmmtitem = <fs_data>-cmmtitem
      ASSIGNING FIELD-SYMBOL(<fs_hier>).
      IF sy-subrc NE 0.

*       Verteilen von unten nach oben
        READ TABLE lt_check_hier WITH KEY parent_st = <fs_data>-fundsctr
                                          cmmtitem  = <fs_data>-cmmtitem
        ASSIGNING <fs_hier>.
        IF sy-subrc NE 0.

*         irgendein Sender hat die gleiche FinSt wie der Empfänger
          READ TABLE lt_check_hier WITH KEY fistl = <fs_data>-fundsctr
          ASSIGNING <fs_hier>.
          IF sy-subrc NE 0.
            "Belegpos. &1: &2 gehört keiner gültigen Hierarchiestufe an
            MESSAGE e013(/thkr/psm_fm) WITH <fs_data>-linenb <fs_data>-fundsctr INTO lv_dummy.
            add_message_from_syst( CHANGING ct_messages = et_messages ).
          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.


  METHOD get_funddistr_lvl.


    SELECT SINGLE zz_funddistr_lvl
      FROM fmfctr
      INTO @rv_value
      WHERE fikrs   = @is_header-fm_area
      AND   fictr   = @is_data-fundsctr
      AND   datab   <= @is_header-docdate
      AND   datbis  >= @is_header-docdate.



  ENDMETHOD.


  METHOD get_hsart.


    SELECT SINGLE hsart
      FROM fmci
      INTO @rv_value
      WHERE fikrs = @iv_fikrs
      AND gjahr   = @iv_gjahr
      AND fipex   = @iv_fipex.

  ENDMETHOD.


METHOD if_ex_fmku_budget_evnt~document_checks.
*&---------------------------------------------------------------------*
*& Auftrag/Incident:  4000000818/INC08600636 - Validierung FMBB
*& Datum           :  20.03.2026
*& Benutzer        :  ZHM000000379
*& Beschreibung
*& Mittelverteilbuchungen erfolgen im HKR System hauptsächlich mit
*& der TAC FMBB unter Verwendung unterschiedlicher Vorgänge,
*& Budgetarten und Kontierungskombinationen"
*&---------------------------------------------------------------------*
*& Änderungen
*&---------------------------------------------------------------------
*& Auftrag/Incident        Datum     Benutzer (ÄnderungsKz.)
*& Beschreibung
*&
**********************************************************************


  DATA: ls_data TYPE ty_data,
        lt_data TYPE tty_data.

  DATA: lt_bu_msg     TYPE bubas_t_msg,
        lt_bu_msg_all TYPE bubas_t_msg.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



*--------------------------------------------------------------------*
* Daten aufbereiten
*--------------------------------------------------------------------*
  LOOP AT i_t_lines ASSIGNING FIELD-SYMBOL(<fs_line>).

    MOVE-CORRESPONDING i_s_header TO ls_data.
    MOVE-CORRESPONDING <fs_line> TO ls_data.
    MOVE-CORRESPONDING <fs_line>-address TO ls_data.
    ls_data-linenb = <fs_line>-docln.
    APPEND ls_data TO lt_data.

  ENDLOOP.

*--------------------------------------------------------------------*
* ENTR - Erfassung
*--------------------------------------------------------------------*
  IF i_s_header-process_ui = c_vrg_entr.
    check_process_entr(
      EXPORTING
        is_header   = i_s_header
        it_data     = lt_data
      IMPORTING
        et_messages = lt_bu_msg ).
    APPEND LINES OF lt_bu_msg TO lt_bu_msg_all.
  ENDIF.
  FREE lt_bu_msg.

*--------------------------------------------------------------------*
* RETN - Rückgabe
*--------------------------------------------------------------------*
  IF i_s_header-process_ui = c_vrg_retn.
    check_process_retn(
      EXPORTING
        is_header   = i_s_header
        it_data     = lt_data
      IMPORTING
        et_messages = lt_bu_msg ).
    APPEND LINES OF lt_bu_msg TO lt_bu_msg_all.
  ENDIF.
  FREE lt_bu_msg.

*--------------------------------------------------------------------*
* TRAN - Umbuchnung
*--------------------------------------------------------------------*
  IF i_s_header-process_ui = c_vrg_tran.
    check_process_tran(
      EXPORTING
        is_header   = i_s_header
        it_data     = lt_data
      IMPORTING
        et_messages = lt_bu_msg ).
    APPEND LINES OF lt_bu_msg TO lt_bu_msg_all.
  ENDIF.
  FREE lt_bu_msg.


*--------------------------------------------------------------------*
* Meldungen ans Framework übergeben
*--------------------------------------------------------------------*
  LOOP AT lt_bu_msg_all ASSIGNING FIELD-SYMBOL(<fs_bu_msg>).

    i_ref_msg->cumulate_message(
      EXPORTING
         i_s_msg              = <fs_bu_msg>
         i_compare_attributes = abap_true
*  IMPORTING
*    e_s_msg_handle       =
      EXCEPTIONS
        log_not_found        = 1
        msg_inconsistent     = 2
        log_is_full          = 3
        OTHERS               = 4 ).
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDLOOP.

ENDMETHOD.


method IF_EX_FMKU_BUDGET_EVNT~LINE_CHECKS.

*** This sample implementation is for Multi-annual
*** Budgeting checks for Spanish Customers.
***
*** No manual entries are allowed for budget lines with years of
*** years of cash effectivity inside time horizon.
***
*** Budget lines for future years are not allowed
*** for not multi-annual budget addresses
***
*** The Settings of multi-annual budgeting are read:
*** - Time horizon (N);
*** - Budget Option (Original or Current Budget).
*** IMG path is: Public Sector Management->Funds Management Governement
*** ->Budget Control System->BCS Availability Control->Business Add Ins
*** for Availability Control-> Setting of Multi-annual Budgeting
***
*** Use the sample implementation for the following BADIs:
*** FMAVC_ADD_LINES (create additional lines in AVC table)
*** FMAVC_ENTRY_FILTER (apply percentages to the additional lines)
***
***

  DATA: l_diff_years TYPE fmmaact-perc_time_hor,
        l_s_lines TYPE fmku_s_badi_line,
        l_s_fmci TYPE fmci,
        l_active_process_entry TYPE xflag,
        l_active_process_return TYPE xflag,
        l_active_process_suppl TYPE xflag,
        l_active_process_trans TYPE xflag,
        l_active_process_carryover TYPE xflag,
        l_s_address TYPE fmku_s_dimpart,
        l_t_address TYPE fmku_t_dimpart,
        l_t_fmbdt TYPE fmbd_t_t,
        l_s_fmbdt TYPE fmbdt,
        l_perc_time_hor TYPE fmmaact-perc_time_hor,
        l_budget_option TYPE fmmaact-ma_bud_option.

  DATA: l_s_msg TYPE bubas_s_msg.

*** Read the budcat and fm area
  LOOP AT i_t_lines INTO l_s_lines FROM 1 TO 1.
  ENDLOOP.

*** Read multi-annual customizing
  CALL FUNCTION 'FMMA_CHECK_ACTIVATION'
    EXPORTING
      I_FM_AREA       = i_s_header-fm_area
      I_BUDCAT        = l_s_lines-budcat
    IMPORTING
      E_PERC_TIME_HOR = l_perc_time_hor
      E_BUDGET_OPTION = l_budget_option
    EXCEPTIONS
      NOT_ACTIVE      = 1
      OTHERS          = 2.

  IF SY-SUBRC <> 0 .
    l_perc_time_hor = 0.
  ENDIF.


* Do the check only if perc time hor gt 0
  IF l_perc_time_hor gt 0.

*** Active the budget processes depending on the customizing option
    IF l_budget_option EQ 'O'.
      l_active_process_entry = 'X'.
      l_active_process_return = ' '.
      l_active_process_suppl = ' '.
      l_active_process_trans = ' '.
      l_active_process_carryover = ' '.
    ENDIF.
    IF l_budget_option EQ 'C'.
      l_active_process_entry = 'X'.
      l_active_process_return = 'X'.
      l_active_process_suppl = 'X'.
      l_active_process_trans = 'X'.
      l_active_process_carryover = 'X'.
    ENDIF.

*** Take in consideration only the lines containing the
*** year of cash effectivity
    LOOP AT i_t_lines INTO l_s_lines
                      WHERE ceffyear IS NOT INITIAL.

*** Do the check only if ceffyaer is greater than fiscyear
      IF l_s_lines-ceffyear GT l_s_lines-fiscyear.
        CLEAR l_s_fmci.

        CALL FUNCTION 'FM_COM_ITEM_READ_SINGLE_DATA'
          EXPORTING
            i_fikrs                        = i_s_header-fm_area
            i_varnt                        = '000'
            i_gjahr                        = l_s_lines-fiscyear
            i_fipex                        = l_s_lines-address-cmmtitem
*           I_FLG_TEXT                     = ' '
*           I_FLG_HIERARCHY                = ' '
         IMPORTING
           e_f_fmci                       = l_s_fmci
*           E_F_FMCIT                      =
*           E_F_FMHICI                     =
         EXCEPTIONS
           MASTER_DATA_NOT_FOUND          = 1
           HIERARCHY_DATA_NOT_FOUND       = 2
           INPUT_ERROR                    = 3
           OTHERS                         = 4.

        IF sy-subrc <> 0.
          CLEAR l_s_fmci .
        ENDIF.


        IF l_s_fmci-ncbud IS NOT INITIAL.
*** Not multi-annual address: multi-annual entries are not allowed
          l_s_msg-msgty = 'E'.
          l_s_msg-msgid = 'FMMA'.
          l_s_msg-msgno = 009.
          l_s_msg-msgv1 = l_s_lines-address-cmmtitem.
*            l_f_msg-CONTEXT-AREA = con_msg_others.
          CALL METHOD i_ref_msg->cumulate_message
            EXPORTING
              i_s_msg = l_s_msg.
          CLEAR l_s_msg.

        ELSE.

          CASE l_s_lines-process.

            WHEN 'ENTR'.

              IF l_active_process_entry EQ 'X'.

                l_diff_years = l_s_lines-ceffyear - l_s_lines-fiscyear .

*** If the l_diff_year is less than percentage time
*** horizon than raise the error
*** posting on this year of cash effectivity is not allowed
                IF NOT l_diff_years GT l_perc_time_hor.
                  l_s_msg-msgty = 'E'.
                  l_s_msg-msgid = 'FMMA'.
                  l_s_msg-msgno = 008.
                  l_s_msg-msgv1 = l_s_lines-ceffyear .
*            l_f_msg-CONTEXT-AREA = con_msg_others.
                  CALL METHOD i_ref_msg->cumulate_message
                    EXPORTING
                      i_s_msg = l_s_msg.
                  CLEAR l_s_msg.
                ENDIF.

              ENDIF.

            WHEN 'SUPL'.

              IF l_active_process_suppl EQ 'X'.

                l_diff_years = l_s_lines-ceffyear - l_s_lines-fiscyear .

*** If the l_diff_year is less than PTH than raise the error
*** posting on this year of cash effectivity is not allowed
                IF NOT l_diff_years GT l_perc_time_hor.
                  l_s_msg-msgty = 'E'.
                  l_s_msg-msgid = 'FMMA'.
                  l_s_msg-msgno = 008.
                  l_s_msg-msgv1 = l_s_lines-ceffyear .
*            l_f_msg-CONTEXT-AREA = con_msg_others.
                  CALL METHOD i_ref_msg->cumulate_message
                    EXPORTING
                      i_s_msg = l_s_msg.
                  CLEAR l_s_msg.
                ENDIF.

              ENDIF.

            WHEN 'RETN'.

              IF l_active_process_return EQ 'X'.

                l_diff_years = l_s_lines-ceffyear - l_s_lines-fiscyear .

*** If the l_diff_year is less than PTH than raise the error
*** posting on this year of cash effectivity is not allowed
                IF NOT l_diff_years GT l_perc_time_hor.
                  l_s_msg-msgty = 'E'.
                  l_s_msg-msgid = 'FMMA'.
                  l_s_msg-msgno = 008.
                  l_s_msg-msgv1 = l_s_lines-ceffyear .
*            l_f_msg-CONTEXT-AREA = con_msg_others.
                  CALL METHOD i_ref_msg->cumulate_message
                    EXPORTING
                      i_s_msg = l_s_msg.
                  CLEAR l_s_msg.
                ENDIF.

              ENDIF.

            WHEN 'SEND'.

              IF l_active_process_trans EQ 'X'.

                l_diff_years = l_s_lines-ceffyear - l_s_lines-fiscyear .

*** If the l_diff_year is less than PTH than raise the error
*** posting on this year of cash effectivity is not allowed
                IF NOT l_diff_years GT l_perc_time_hor.
                  l_s_msg-msgty = 'E'.
                  l_s_msg-msgid = 'FMMA'.
                  l_s_msg-msgno = 008.
                  l_s_msg-msgv1 = l_s_lines-ceffyear .
*            l_f_msg-CONTEXT-AREA = con_msg_others.
                  CALL METHOD i_ref_msg->cumulate_message
                    EXPORTING
                      i_s_msg = l_s_msg.
                  CLEAR l_s_msg.
                ENDIF.

              ENDIF.

            WHEN 'RECV'.

              IF l_active_process_trans EQ 'X'.

                l_diff_years = l_s_lines-ceffyear - l_s_lines-fiscyear .

*** If the l_diff_year is less than PTH than raise the error
*** posting on this year of cash effectivity is not allowed
                IF NOT l_diff_years GT l_perc_time_hor.
                  l_s_msg-msgty = 'E'.
                  l_s_msg-msgid = 'FMMA'.
                  l_s_msg-msgno = 008.
                  l_s_msg-msgv1 = l_s_lines-ceffyear .
*            l_f_msg-CONTEXT-AREA = con_msg_others.
                  CALL METHOD i_ref_msg->cumulate_message
                    EXPORTING
                      i_s_msg = l_s_msg.
                  CLEAR l_s_msg.
                ENDIF.

              ENDIF.


            WHEN 'COSD'.

              IF l_active_process_carryover EQ 'X'.

                l_diff_years = l_s_lines-ceffyear - l_s_lines-fiscyear .

*** If the l_diff_year is less than PTH than raise the error
*** carry over from this year of cash effectivity is not allowed
                IF NOT l_diff_years GT l_perc_time_hor.
                  l_s_msg-msgty = 'E'.
                  l_s_msg-msgid = 'FMMA'.
                  l_s_msg-msgno = 010.
                  l_s_msg-msgv1 = l_s_lines-ceffyear .
*            l_f_msg-CONTEXT-AREA = con_msg_others.
                  CALL METHOD i_ref_msg->cumulate_message
                    EXPORTING
                      i_s_msg = l_s_msg.
                  CLEAR l_s_msg.
                ENDIF.

              ENDIF.

            WHEN 'CORV'.

              IF l_active_process_trans EQ 'X'.

                l_diff_years = l_s_lines-ceffyear - l_s_lines-fiscyear .

*** If the l_diff_year is less than PTH than raise the error
*** carry over to this year of cash effectivity is not allowed
                IF NOT l_diff_years GT l_perc_time_hor.
                  l_s_msg-msgty = 'E'.
                  l_s_msg-msgid = 'FMMA'.
                  l_s_msg-msgno = 010.
                  l_s_msg-msgv1 = l_s_lines-ceffyear .
*            l_f_msg-CONTEXT-AREA = con_msg_others.
                  CALL METHOD i_ref_msg->cumulate_message
                    EXPORTING
                      i_s_msg = l_s_msg.
                  CLEAR l_s_msg.
                ENDIF.

              ENDIF.

          ENDCASE.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.



endmethod.


method IF_EX_FMKU_BUDGET_EVNT~POST.
endmethod.
ENDCLASS.
