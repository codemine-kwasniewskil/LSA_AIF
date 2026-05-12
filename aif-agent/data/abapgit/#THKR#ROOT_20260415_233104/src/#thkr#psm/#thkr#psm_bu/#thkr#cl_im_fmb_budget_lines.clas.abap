class /THKR/CL_IM_FMB_BUDGET_LINES definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_FMKU_BUDGET_LINES .
protected section.
private section.

  methods SUBSTITUTEFMAA_FROM_SUBDIV
    changing
      !C_F_LINE_SUBST_SOURCE type FMKU_S_SUBSTITUTE_SOURCE
      !C_F_LINE type FMKU_S_SUBSTITUTION .
ENDCLASS.



CLASS /THKR/CL_IM_FMB_BUDGET_LINES IMPLEMENTATION.


  METHOD if_ex_fmku_budget_lines~add_lines.

    CHECK i_s_header-process_ui = 'TRAN'. " Just TRANSFER of budget
    TRY.
*        DATA(sender) = i_t_lines[ process = 'SEND' ]. "Get first sender
*        DATA(receiver) = i_t_lines[ process = 'RECV' ]. "Get first receiver

        LOOP AT i_t_lines INTO DATA(sender) WHERE process = 'SEND'.
          DATA(receiver) = i_t_lines[ address-cmmtitem = sender-address-cmmtitem  process = 'RECV' ].

          CHECK sender-address-fundsctr IS NOT INITIAL
            AND receiver-address-fundsctr IS NOT INITIAL.

          "" Try to walk form SENDER to RECEIVER upwards
          DATA(nodes) = /thkr/cl_fundctr_hier_crawler=>get( hivarnt = CONV #( i_s_header-docyear+2(2) ) )->get_node_path_up( fictr_from = receiver-address-fundsctr fictr_to = sender-address-fundsctr ).
          "" If nothing is found, rry to walk form SENDER to RECEIVER downwards by changing direction
          IF nodes IS INITIAL.
            nodes = /thkr/cl_fundctr_hier_crawler=>get( hivarnt = CONV #( i_s_header-docyear+2(2) ) )->get_node_path_up( fictr_from = sender-address-fundsctr fictr_to = receiver-address-fundsctr ).
          ENDIF.
          "" Walk through hierarchy an add nodes:
          LOOP AT nodes ASSIGNING FIELD-SYMBOL(<node>) .
            " Check if functr already existent:
            CHECK NOT line_exists( i_t_lines[ address-fundsctr = <node> ] ).
            " Copy Receiver data:
            DATA(copy) = receiver.
            copy-address-fundsctr = <node>.
            e_t_lines = VALUE #( BASE e_t_lines ( copy ) ).
            " Copy Sender data and adjust accounting to receiver
            copy = sender.
            copy-address = receiver-address.
            copy-address-fundsctr = <node>.
            e_t_lines = VALUE #( BASE e_t_lines ( copy ) ).
          ENDLOOP.
        ENDLOOP.

      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.


  METHOD if_ex_fmku_budget_lines~substitute_data.
    INCLUDE ibukucon.
  DATA:l_f_source_line        TYPE fmku_s_substitute_source,
       l_f_msg                TYPE bubas_s_msg,
       l_f_target_line        TYPE fmku_s_substitute_target,
       l_f_target_sub_line    TYPE fmku_s_substitute_target,
       l_f_suppl_sub_line     TYPE fmku_s_substitute_source_suppl,
       l_f_fmci               TYPE fmci,
       l_ctem_category_source TYPE fm_potyp,
       l_ctem_category_target TYPE fm_potyp.

*
* Convert the format of the BADI to the substitution format
  MOVE-CORRESPONDING c_f_line TO l_f_source_line.
  MOVE-CORRESPONDING c_f_line-address TO l_f_source_line.
  MOVE-CORRESPONDING i_s_header TO l_f_source_line.

  CALL METHOD me->substitutefmaa_from_subdiv
    CHANGING
      c_f_line_subst_source = l_f_source_line
      c_f_line = c_f_line.

*-------------------------------------------------
* Call the derivation tool using the CO-PA tool
*-------------------------------------------------


* We initialize the values of the target fields to those of the source
  MOVE-CORRESPONDING l_f_source_line TO l_f_target_line.
  MOVE c_f_line-text50 TO l_f_target_line-text50.
*( note 3311162 )*
  MOVE c_f_line-text50 to l_f_source_line-text50."note 3311162

  CALL FUNCTION 'FMKU_CALL_DERIVATION_SUB'
    EXPORTING
      i_s_source_line     = l_f_source_line
      i_s_target_line     = l_f_target_line
    IMPORTING
      e_s_sub_line_suppl  = l_f_suppl_sub_line
      e_s_sub_line_target = l_f_target_sub_line
    EXCEPTIONS
      substitution_failed = 1.
*Note 1328655:
  IF sy-subrc <> 0.
    CLEAR l_f_msg.
    l_f_msg-context-area = con_msg_sub.
    l_f_msg-msgty = sy-msgty.
    l_f_msg-msgid = sy-msgid.
    l_f_msg-msgno = sy-msgno.
    l_f_msg-msgv1 = sy-msgv1.
    l_f_msg-msgv2 = sy-msgv2.
    l_f_msg-msgv3 = sy-msgv3.
    l_f_msg-msgv4 = sy-msgv4.
    CALL METHOD i_ref_msg->cumulate_message
      EXPORTING
        i_s_msg = l_f_msg.
    MESSAGE ID l_f_msg-msgid TYPE l_f_msg-msgty NUMBER l_f_msg-msgno
            WITH l_f_msg-msgv1 l_f_msg-msgv2
                 l_f_msg-msgv3 l_f_msg-msgv4
            RAISING substitution_failed.
  ENDIF.

* If no substitutions are required, exit
  IF l_f_target_sub_line-flg_substitute = con_off.
    EXIT.
  ENDIF.

* Ctem Ctgy of source
  l_ctem_category_source = l_f_suppl_sub_line-ctem_category.

* Ctem Ctgy of target
  IF NOT l_f_target_sub_line-cmmtitem IS INITIAL
  AND NOT l_f_source_line-fm_area IS INITIAL
      AND NOT l_f_source_line-fiscyear IS INITIAL.

    CALL FUNCTION 'FM_COM_ITEM_READ_SINGLE_DATA'
      EXPORTING
        i_fikrs                  = l_f_source_line-fm_area
        i_gjahr                  = l_f_source_line-fiscyear
        i_fipex                  = l_f_target_sub_line-cmmtitem
      IMPORTING
        e_f_fmci                 = l_f_fmci
      EXCEPTIONS
        hierarchy_data_not_found = 0
        OTHERS                   = 1.
*Note 1328655:
    IF sy-subrc <> 0.
      CLEAR l_f_msg.
      l_f_msg-context-area = con_msg_sub.
      l_f_msg-msgty = sy-msgty.
      l_f_msg-msgid = sy-msgid.
      l_f_msg-msgno = sy-msgno.
      l_f_msg-msgv1 = sy-msgv1.
      l_f_msg-msgv2 = sy-msgv2.
      l_f_msg-msgv3 = sy-msgv3.
      l_f_msg-msgv4 = sy-msgv4.
      CALL METHOD i_ref_msg->cumulate_message
        EXPORTING
          i_s_msg = l_f_msg.
      MESSAGE ID l_f_msg-msgid TYPE l_f_msg-msgty NUMBER l_f_msg-msgno
              WITH l_f_msg-msgv1 l_f_msg-msgv2
                   l_f_msg-msgv3 l_f_msg-msgv4
              RAISING substitution_failed.
    ENDIF.

* CTEM CTGY of additional line
    l_ctem_category_target = l_f_fmci-potyp.

  ENDIF.
**-------------------------------------------------
** Change the fields in the lines with the fields derived
**-------------------------------------------------
*
  MOVE-CORRESPONDING l_f_target_sub_line TO c_f_line.
  MOVE-CORRESPONDING l_f_target_sub_line TO c_f_line-address.

*-------------------------------------------------
* If the Commitment item Categories of target and source are different,
* reverse the sign of the amounts
*-------------------------------------------------
  IF ( NOT l_ctem_category_target IS INITIAL ) AND ( NOT
  l_ctem_category_source IS INITIAL ).
    IF l_ctem_category_target NE l_ctem_category_source.

* For values in Transaction currency
      CALL FUNCTION 'BUKU_MOVE_PERIOD_VALUES'
        EXPORTING
          i_f_source         = c_f_line
          i_prefix_source    = 'TVAL'
          i_prefix_target    = 'TVAL'
          i_flg_reverse_sign = 'X'
        CHANGING
          c_f_target         = c_f_line.

* For values in Local currency
      CALL FUNCTION 'BUKU_MOVE_PERIOD_VALUES'
        EXPORTING
          i_f_source         = c_f_line
          i_prefix_source    = 'LVAL'
          i_prefix_target    = 'LVAL'
          i_flg_reverse_sign = 'X'
        CHANGING
          c_f_target         = c_f_line.
    ENDIF.

* endif target commitment item initial
  ENDIF.



  ENDMETHOD.


  method SUBSTITUTEFMAA_FROM_SUBDIV.

    DATA l_flg_active_functionalrea TYPE xfeld.
    DATA l_flg_active_funds TYPE xfeld.
    DATA l_flg_active_fundscenter TYPE xfeld.
    DATA l_flg_active_commitmentitem TYPE xfeld.
    DATA: l_fnsub1 TYPE fm_fnsub1,
          l_fnsub2 TYPE fm_fnsub2,
          l_fnsub3 TYPE fm_fnsub3,
          l_masdat TYPE char30.

    IF c_f_line_subst_source-funcarea IS INITIAL.
      CALL FUNCTION 'FM_SELECT_ACTIV_FLAG'
        EXPORTING
          i_masdat_id = '4'
        IMPORTING
          e_strbcs    = l_flg_active_functionalrea.

      IF l_flg_active_functionalrea IS NOT INITIAL.

        CLEAR l_masdat.
        CALL FUNCTION 'FM_MASDAT_CONCAT_DECONCAT'
          EXPORTING
            i_masdatid = '4'
            i_strid    = c_f_line_subst_source-functionalareasubdivisionid
          CHANGING
            c_sub1     = c_f_line_subst_source-functionalarea1subdivision
            c_sub2     = c_f_line_subst_source-functionalarea2subdivision
            c_sub3     = c_f_line_subst_source-functionalarea3subdivision
            c_masdat   = l_masdat.

        MOVE l_masdat TO c_f_line_subst_source-funcarea.
        MOVE c_f_line_subst_source-funcarea TO c_f_line-address-funcarea.
      ENDIF.
    ENDIF.

    IF c_f_line_subst_source-fund IS INITIAL.
      CALL FUNCTION 'FM_SELECT_ACTIV_FLAG'
        EXPORTING
          i_masdat_id = '3'
        IMPORTING
          e_strbcs    = l_flg_active_funds.
      IF l_flg_active_funds IS NOT INITIAL.

        CLEAR l_masdat.
        CALL FUNCTION 'FM_MASDAT_CONCAT_DECONCAT'
          EXPORTING
            i_masdatid = '3'
            i_strid    = c_f_line_subst_source-fundssubdivisionid
          CHANGING
            c_sub1     = c_f_line_subst_source-funds1subdivision
            c_sub2     = c_f_line_subst_source-funds2subdivision
            c_masdat   = l_masdat.

        MOVE l_masdat TO c_f_line_subst_source-fund.
        MOVE c_f_line_subst_source-fund TO c_f_line-address-fund.
      ENDIF.
    ENDIF.

    IF c_f_line_subst_source-fundsctr IS INITIAL.
      CALL FUNCTION 'FM_SELECT_ACTIV_FLAG'
        EXPORTING
          i_masdat_id = '2'
        IMPORTING
          e_strbcs    = l_flg_active_fundscenter.
      IF l_flg_active_fundscenter IS NOT INITIAL.

        CLEAR l_masdat.
        CALL FUNCTION 'FM_MASDAT_CONCAT_DECONCAT'
          EXPORTING
            i_masdatid = '3'
            i_strid    = c_f_line_subst_source-fundscentersubdivisionid
          CHANGING
            c_sub1     = c_f_line_subst_source-fundscenter1subdivision
            c_sub2     = c_f_line_subst_source-fundscenter2subdivision
            c_sub3     = c_f_line_subst_source-fundscenter3subdivision
            c_masdat   = l_masdat.

        MOVE l_masdat TO c_f_line_subst_source-fundsctr.
        MOVE c_f_line_subst_source-fundsctr TO c_f_line-address-fundsctr.
      ENDIF.
    ENDIF.

    IF c_f_line_subst_source-cmmtitem IS INITIAL.
      CALL FUNCTION 'FM_SELECT_ACTIV_FLAG'
        EXPORTING
          i_masdat_id = '1'
        IMPORTING
          e_strbcs    = l_flg_active_commitmentitem.

      IF l_flg_active_commitmentitem IS NOT INITIAL.

        CLEAR l_masdat.
        CALL FUNCTION 'FM_MASDAT_CONCAT_DECONCAT'
          EXPORTING
            i_masdatid = '1'
            i_strid    = c_f_line_subst_source-commitmentitemsubdivisionid
          CHANGING
            c_sub1     = c_f_line_subst_source-commitmentitem1subdivision
            c_sub2     = c_f_line_subst_source-commitmentitem2subdivision
            c_sub3     = c_f_line_subst_source-commitmentitem3subdivision
            c_sub4     = c_f_line_subst_source-commitmentitem4subdivision
            c_sub5     = c_f_line_subst_source-commitmentitem5subdivision
            c_masdat   = l_masdat.

        MOVE l_masdat TO c_f_line_subst_source-cmmtitem.
        MOVE c_f_line_subst_source-cmmtitem TO c_f_line-address-cmmtitem.
      ENDIF.
    ENDIF.
  endmethod.
ENDCLASS.
