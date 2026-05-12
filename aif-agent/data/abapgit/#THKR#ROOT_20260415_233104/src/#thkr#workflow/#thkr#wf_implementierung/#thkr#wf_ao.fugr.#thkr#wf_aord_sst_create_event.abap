FUNCTION /thkr/wf_aord_sst_create_event.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_AORD TYPE  /THKR/T_AORD_BUKRS
*"----------------------------------------------------------------------

  INCLUDE <cntn01>.

  DATA: BEGIN OF ls_aord_key,
          SourceCompanyCode TYPE ausbk,
          RequestNumber     TYPE pso_lotkz,
        END OF ls_aord_key.
  DATA: lv_objkey             TYPE sweinstcou-objkey,
        lh_container          TYPE REF TO if_swf_cnt_container,
        g_evt_param_container TYPE REF TO if_swf_cnt_container,
        lt_aord_obj_ref       TYPE REF TO swfborptab,
        ls_aord_obj_ref       TYPE swotobjid,
        lt_aord_obj           TYPE swfborptab,
        ls_aord_obj           TYPE swotobjid,
        lo_aord               TYPE swc_object,
        lex_root              TYPE REF TO cx_root,
        ls_agents             TYPE REF TO data,
        value_ref             TYPE REF TO data,
        value_ref1            TYPE REF TO data,
        unit_ref              TYPE REF TO data,
        swotobjid             TYPE swotobjid,
        l_item_guid           TYPE crmt_object_guid,
        exception_return      TYPE REF TO cx_swf_cnt_container,
        exception_return1     TYPE REF TO cx_swf_cnt_container,
        l_event_container     TYPE REF TO if_swf_ifs_parameter_container,
        l_event_ref           TYPE REF TO if_swf_evt_event,
        l_string              TYPE string.

  FIELD-SYMBOLS: <fs_obj> TYPE swfborptab.

  LOOP AT t_aord ASSIGNING FIELD-SYMBOL(<fs_aord>).

    CLEAR ls_aord_key.
    CLEAR ls_aord_obj.
    ls_aord_key-sourcecompanycode = <fs_aord>-bukrs.
    ls_aord_key-requestnumber = <fs_aord>-lotzk.

    MOVE ls_aord_key TO ls_aord_obj-objkey.
    ls_aord_obj-objtype = 'FMPSO'.

    APPEND ls_aord_obj TO lt_aord_obj.

  ENDLOOP.

  TRY.
      CALL METHOD cl_swf_evt_utilities=>get_specific_container
        EXPORTING
          im_objcateg  = 'BO'
          im_objtype   = 'FMPSO'
          im_event     = 'ZSAMMELANORDNUNG'
        RECEIVING
          re_container = lh_container.
*   --- container handle will be buffered, do not change it --- note 2172899 ---
      IF lh_container IS BOUND.
        g_evt_param_container = lh_container->clone( ).
      ELSE.
        CLEAR g_evt_param_container.
      ENDIF.
    CATCH cx_swf_ifs_exception.
      CLEAR g_evt_param_container.
  ENDTRY.

  GET REFERENCE OF lt_aord_obj INTO lt_aord_obj_ref.

  TRY.
      CALL METHOD g_evt_param_container->if_swf_cnt_element_access_1~element_set_value_ref
        EXPORTING
          name             = 'T_AORD'
          value_ref        = lt_aord_obj_ref
        IMPORTING
          exception_return = exception_return.
    CATCH cx_swf_cnt_cont_access_denied.
    CATCH cx_swf_cnt_elem_access_denied.
    CATCH cx_swf_cnt_elem_not_found.
    CATCH cx_swf_cnt_elem_type_conflict.
    CATCH cx_swf_cnt_invalid_qname.
    CATCH cx_swf_cnt_container.
  ENDTRY.

  IF g_evt_param_container IS BOUND.
    l_event_container ?= g_evt_param_container.
  ENDIF.

  READ TABLE t_aord INDEX 1 ASSIGNING <fs_aord>.
  IF sy-subrc = 0.
    CLEAR ls_aord_key.
    ls_aord_key-sourcecompanycode = <fs_aord>-bukrs.
    ls_aord_key-requestnumber = <fs_aord>-lotzk.
    MOVE ls_aord_key TO lv_objkey.

    CALL METHOD cl_swf_evt_event=>get_instance
      EXPORTING
        im_objcateg        = 'BO'
        im_objtype         = 'FMPSO'
        im_event           = 'ZSAMMELANORDNUNG'
        im_objkey          = lv_objkey
        im_event_container = l_event_container
      RECEIVING
        re_event           = l_event_ref.
*---- adapt standards --- note 2103728 ---
    CALL METHOD lcl_event_services=>set_standards( l_event_ref ).

    TRY.
*           refresh the buffers -> requested by RGö 010220
        cl_swf_evt_services=>reset_buffers( ).

        CALL METHOD l_event_ref->raise.
      CATCH cx_root INTO lex_root. " should never occur
        IF lex_root IS BOUND.
          l_string = lex_root->get_text( ).
          MESSAGE l_string TYPE 'I'.
        ENDIF.
    ENDTRY.

  ENDIF.

  COMMIT WORK.

ENDFUNCTION.
