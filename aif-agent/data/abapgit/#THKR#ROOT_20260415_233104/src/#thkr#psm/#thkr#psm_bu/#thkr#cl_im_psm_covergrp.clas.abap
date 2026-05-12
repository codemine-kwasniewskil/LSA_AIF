class /THKR/CL_IM_PSM_COVERGRP definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FMCE_COVER_GROUP .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_IM_PSM_COVERGRP IMPLEMENTATION.


  method IF_FMCE_COVER_GROUP~CHECK_COVER_GROUP.

*--- During check, please first raise error message,
*--- then raise warning message and then information message

  INCLUDE ifmcecon.
  CONSTANTS: on TYPE xfeld VALUE 'X'.
  DATA: l_f_member_address       TYPE fmce_s_member,
        l_f_fmci                 TYPE fmci,
        l_flg_fund_ref_set       TYPE xfeld,
        l_fund_ref               TYPE fm_fund,
        l_flg_ci_type_ref_set    TYPE xfeld,
        l_cmmtitem_type_ref      TYPE fm_hsart,
        l_cmmtitem_type          TYPE fm_hsart,
        l_sender_flg             TYPE xfeld,
        l_rec_flg                TYPE xfeld,
        l_count_not_empty_member TYPE i.

  l_count_not_empty_member = 0.

  LOOP AT im_t_member_addresses INTO l_f_member_address.

    CHECK NOT l_f_member_address-address IS INITIAL.

    l_count_not_empty_member = l_count_not_empty_member + 1.

    CASE l_f_member_address-cgaddrind .
      WHEN con_fmce_cgaddrind_r_and_s.
        l_sender_flg = on.
        l_rec_flg = on.
      WHEN con_fmce_cgaddrind_only_s.
        l_sender_flg = on.
      WHEN con_fmce_cgaddrind_only_r.
        l_rec_flg = on.
      WHEN con_fmce_cgaddrind_call_rib.
        l_sender_flg = on.
    ENDCASE.

    IF l_flg_fund_ref_set IS INITIAL.
      l_flg_fund_ref_set = 'X'.
      l_fund_ref = l_f_member_address-address-fund.
    ENDIF.

    IF NOT ( l_f_member_address-address-cmmtitem IS INITIAL ).
      CALL FUNCTION 'FM_COM_ITEM_READ_SINGLE_DATA'
        EXPORTING
          i_fikrs  = im_fm_area
          i_gjahr  = im_fiscyear
          i_fipex  = l_f_member_address-address-cmmtitem
        IMPORTING
          e_f_fmci = l_f_fmci
        EXCEPTIONS
          OTHERS   = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING invalid_cover_group.
      ELSE.
        l_cmmtitem_type = l_f_fmci-hsart.
        IF l_flg_ci_type_ref_set IS INITIAL.
          l_flg_ci_type_ref_set = 'X'.
          l_cmmtitem_type_ref = l_f_fmci-hsart.
        ENDIF.
      ENDIF.
    ENDIF.

**--- Check if all members belong to the same fund:
*    IF l_fund_ref <> l_f_member_address-address-fund.
*      MESSAGE e423(fmce) WITH im_cover_group
*              RAISING invalid_cover_group.
*    ENDIF.

*--- For German customers only: check if all members
*--- use a commitment item of the same "commitment item
*--- type" (HSART):
    IF NOT ( l_flg_ci_type_ref_set IS INITIAL ) AND
       l_cmmtitem_type_ref <> l_cmmtitem_type.
      MESSAGE e424(fmce) WITH im_cover_group
              RAISING invalid_cover_group.
    ENDIF.

  ENDLOOP.


*--- Check the AVC ledger attributes, if automatic cover group:
  IF im_s_attributes-cgautoind = con_fmce_cgautoind_auto.
    CALL FUNCTION 'FMAVC_GET_ATTRIBUTES_ALDNR'
      EXPORTING
        i_aldnr    = im_s_attributes-aldnr
        i_fm_area  = im_fm_area
        i_fiscyear = im_fiscyear
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING invalid_cover_group.
    ENDIF.
  ENDIF.


*--- Check if there is at least one member in the cover group:
  IF l_count_not_empty_member = 0.
    MESSAGE e609(fmce) WITH im_cover_group
            RAISING invalid_cover_group.
  ENDIF.


*--- Check if there is only one member in the cover group.
*--- => Warning for all kinds of cover groups:
  IF l_count_not_empty_member = 1.
    MESSAGE w612(fmce) WITH im_cover_group
            RAISING invalid_cover_group.
  ENDIF.


*--- Check if cover group contains both sender and receiver budget
*--- addresses.
*--- => Warning for automatic and manual cover groups:
  IF im_s_attributes-cgautoind = con_fmce_cgautoind_auto OR
     im_s_attributes-cgautoind = con_fmce_cgautoind_manual.
    IF l_sender_flg NE on.
      MESSAGE w610(fmce) WITH im_cover_group
              RAISING invalid_cover_group.
    ENDIF.
    IF l_rec_flg NE on.
      MESSAGE w611(fmce) WITH im_cover_group
              RAISING invalid_cover_group.
    ENDIF.
  ENDIF.

  endmethod.


  method IF_FMCE_COVER_GROUP~COPY_COVER_GROUP.
  endmethod.


  METHOD if_fmce_cover_group~sort_bud_receiver.
    SORT ct_receiver_list BY address.
  ENDMETHOD.


  METHOD if_fmce_cover_group~sort_bud_sender.
**==> Default implementation for sorting budget sender by different business process,
**=>  for example: Sort RIB rules by value and  sort expenditure budget addresses by FMAA

    INCLUDE ibukucon.
    INCLUDE ifmcecon.

    DATA: ls_sender_list      TYPE fmce_s_member_avc_data,
          lt_sender_list_sort TYPE fmce_t_member_avc_data.


    CASE im_process_ui.
      WHEN con_rib_ui. "RIB rules in automatic cover groups
        LOOP AT ct_sender_list INTO ls_sender_list.
          IF ls_sender_list-cgaddrind = con_fmce_cgaddrind_call_rib.
            DELETE ct_sender_list INDEX sy-tabix.
            APPEND ls_sender_list TO lt_sender_list_sort.
          ENDIF.
        ENDLOOP.

        SORT lt_sender_list_sort BY anval.  " sort by annual value

      WHEN con_transfer. " Normal expenditure budget addresses in automatic cover groups
        LOOP AT ct_sender_list INTO ls_sender_list.
          IF ls_sender_list-cgaddrind NE con_fmce_cgaddrind_call_rib.
            DELETE ct_sender_list INDEX sy-tabix.
            APPEND ls_sender_list TO lt_sender_list_sort.
          ENDIF.
        ENDLOOP.

        SORT lt_sender_list_sort BY address.    " sort by address

    ENDCASE.

* append sort data to sender list
    LOOP AT lt_sender_list_sort INTO ls_sender_list.
      APPEND ls_sender_list TO ct_sender_list.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
