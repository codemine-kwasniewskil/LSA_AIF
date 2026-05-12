FUNCTION-POOL /THKR/WF_AO.                  "MESSAGE-ID ..

" INCLUDE /THKR/LWF_AOD...                   " Local class definition


CLASS lcl_event_services DEFINITION.

  PUBLIC SECTION.
    CONSTANTS:
      c_creator TYPE swfdname VALUE 'CREATOR',
      c_langu   TYPE swfdname VALUE 'LANGU'.

    CLASS-METHODS:
      get_instance IMPORTING im_objcat      TYPE c
                             im_objtyp      TYPE c
                             im_objkey      TYPE c
                             im_event       TYPE c
                   RETURNING VALUE(re_inst) TYPE REF TO lcl_event_services,
      set_standards IMPORTING im_event_ref  TYPE REF TO if_swf_evt_event.
    METHODS:
      constructor IMPORTING im_objcat TYPE c
                            im_objtyp TYPE c
                            im_objkey TYPE c
                            im_event  TYPE c,
      call_editor.

  PRIVATE SECTION.
    CLASS-DATA:
       mh_instance TYPE REF TO lcl_event_services.
    DATA:
      mh_event   TYPE REF TO cl_swf_evt_event,
      m_standard TYPE swfrevtstd,
      m_changed  TYPE xflag.

    METHODS:
      get_standard_container
        RETURNING VALUE(re_cnt) TYPE REF TO if_swf_cnt_container.



ENDCLASS.                    "lcl_event_services DEFINITION

*&---------------------------------------------------------------------*
*&  Include           LSWUSF05
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS lcl_gp_tab IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_services IMPLEMENTATION.


  METHOD constructor.

    mh_event ?= cl_swf_evt_event=>get_instance(
        im_objcateg = im_objcat
        im_objtype  = im_objtyp
        im_event    = im_event
        im_objkey   = im_objkey ).

    IF mh_event IS BOUND.
      m_standard = mh_event->m_standard_elements.
    ENDIF.

    m_standard-creator-otype = 'US'.
    m_standard-creator-objid = sy-uname.
    m_standard-langu         = sy-langu.

  ENDMETHOD.

  METHOD get_instance.

    IF mh_instance IS BOUND.
      IF mh_instance->m_standard-objtype = im_objtyp  AND
         mh_instance->m_standard-objkey  = im_objkey  AND
         mh_instance->m_standard-event   = im_event.
        re_inst = mh_instance.
        RETURN.
      ENDIF.
    ENDIF.

    CREATE OBJECT mh_instance
      EXPORTING
        im_objcat = im_objcat
        im_objtyp = im_objtyp
        im_event  = im_event
        im_objkey = im_objkey.

    re_inst = mh_instance.

  ENDMETHOD.

  METHOD set_standards.
    DATA l_event  TYPE string.
    DATA l_objtyp TYPE string.
    DATA l_objkey TYPE string.
    DATA l_event_ref TYPE REF TO cl_swf_evt_event.

    CHECK mh_instance IS BOUND.
    CHECK im_event_ref IS BOUND.

    IF mh_instance->m_changed IS NOT INITIAL.
      l_event  = im_event_ref->get_event_name( ).
      l_objkey = im_event_ref->get_object_key( ).
      l_objtyp = im_event_ref->get_objtype_name( ).

      IF mh_instance->m_standard-objtype = l_objtyp  AND
         mh_instance->m_standard-objkey  = l_objkey  AND
         mh_instance->m_standard-event   = l_event.

        CALL METHOD im_event_ref->set_creator( mh_instance->m_standard-creator ).
        CALL METHOD im_event_ref->set_language( mh_instance->m_standard-langu ).

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD get_standard_container.

    DATA lh_struc    TYPE REF TO cl_abap_structdescr.
    DATA l_comp      TYPE abap_compdescr.
    DATA l_name      TYPE swfdname.

    FIELD-SYMBOLS <data> TYPE any.

    IF mh_event IS BOUND.
      me->m_standard-crea_date = sy-datum.
      me->m_standard-crea_time = sy-uzeit.
      GET TIME STAMP FIELD me->m_standard-crea_stmp .

      TRY.
          re_cnt = cl_swf_cnt_factory=>create( ).
        CATCH cx_swf_ifs_exception.
          RETURN.
      ENDTRY.

      lh_struc ?= cl_abap_typedescr=>describe_by_data( m_standard ).
      IF lh_struc IS BOUND.
        LOOP AT lh_struc->components INTO l_comp.
          l_name = l_comp-name.
          ASSIGN COMPONENT l_comp-name OF STRUCTURE m_standard TO <data>.
          TRY.
              CALL METHOD re_cnt->if_swf_cnt_element_access_1~element_set_value(
                  name  = l_name
                  value = <data> ).
              IF l_name <> c_creator AND
                 l_name <> c_langu.
                CALL METHOD re_cnt->if_swf_cnt_element_access_1~element_set_props(
                    name       = l_name
                    properties = swfcn_p_read_only ).
              ENDIF.
            CATCH cx_swf_ifs_exception.                 "#EC NO_HANDLER
          ENDTRY.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD call_editor.
    DATA lh_cnt    TYPE REF TO if_swf_cnt_container.

    lh_cnt = me->get_standard_container( ).

    CALL FUNCTION 'SWF_CNT_INSTANCE_EDITOR'
      EXPORTING
        container_ref  = lh_cnt
        start_in_popup = 'X'
        title          = 'Bereits gesetzte Standardwerte'(h01)
      IMPORTING
        changed        = m_changed.

    IF m_changed IS NOT INITIAL.
      TRY.
          CALL METHOD lh_cnt->element_get
            EXPORTING
              name  = c_creator
            IMPORTING
              value = m_standard-creator.
          CALL METHOD lh_cnt->element_get
            EXPORTING
              name  = c_langu
            IMPORTING
              value = m_standard-langu.
        CATCH cx_swf_ifs_exception.
          CLEAR m_changed.
      ENDTRY.
    ENDIF.

  ENDMETHOD.

ENDCLASS.    "lcl_event_services IMPLEMENTATION
