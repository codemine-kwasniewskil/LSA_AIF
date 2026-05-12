FUNCTION /thkr/wf_obj_relat_create.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_OBJKEY) TYPE  SWO_TYPEID
*"     REFERENCE(IV_OBJTYPE) TYPE  SWO_OBJTYP
*"     REFERENCE(IV_WI_ID) TYPE  SWW_WIID
*"  EXCEPTIONS
*"      RELATION_COULD_NOT_CREATE
*"      ERROR_READING_ATTACHEMENTS
*"      ERROR_READING_ATTACHEMENT_TYPE
*"----------------------------------------------------------------------
  DATA: ls_obja TYPE borident.
  DATA: ls_objb TYPE borident.
  DATA: lt_wf_data TYPE STANDARD TABLE OF swotobjid.
  DATA: lv_value TYPE file_ext.
  DATA: ls_binrel TYPE gbinrel.
  DATA: lt_binatt TYPE STANDARD TABLE OF brelattr.
  DATA: lv_object TYPE SWC_ELEM.


  CALL FUNCTION 'SWW_WI_OBJECTHANDLES_READ'
    EXPORTING
      wi_id       = iv_wi_id
*     ELEMENT_NAME              = 'FILEEXTENSION'
*     WI_HEADER   =
*     I_WI_RELEASE              =
*     I_NOTE_EXIST              =
*     NO_NOTE_UPGRADE           = ' '
    TABLES
      object_ids  = lt_wf_data
*     OBJECT_IDS_IBF            =
* CHANGING
*     WI_CONTAINER_HANDLE       =
    EXCEPTIONS
      read_failed = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    RAISE error_reading_attachements.
  ENDIF.

  ls_obja-objtype = iv_objtype.
  ls_obja-objkey = iv_objkey.

    CONCATENATE 'WF_ANLAGE_' iv_objtype into lv_object.

  SELECT * FROM /thkr/t_wf_param
      INTO TABLE @DATA(lt_wf_param)
      WHERE object = @lv_object.

  LOOP AT lt_wf_data ASSIGNING FIELD-SYMBOL(<fs_data>).

    CALL FUNCTION 'SWO_PROPERTY_GET'
      EXPORTING
        object          = <fs_data>
        attribute       = 'FileExtension'
      CHANGING
        value           = lv_value
      EXCEPTIONS
        error_create    = 1
        error_invoke    = 2
        error_container = 3
        OTHERS          = 4.
    IF sy-subrc <> 0.
      RAISE error_reading_attachement_type.
    ENDIF.

    READ TABLE lt_wf_param ASSIGNING FIELD-SYMBOL(<fs_param>)
    WITH KEY value_von = lv_value.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    ls_objb-objtype = 'MESSAGE'.
    ls_objb-objkey = <fs_data>-objkey.

    CALL FUNCTION 'BINARY_RELATION_CREATE_COMMIT'
      EXPORTING
        obj_rolea      = ls_obja
        obj_roleb      = ls_objb
        relationtype   = 'ATTA'
      IMPORTING
        binrel         = ls_binrel
      TABLES
        binrel_attrib  = lt_binatt
      EXCEPTIONS
        no_model       = 1
        internal_error = 2
        unknown        = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      RAISE relation_could_not_create.
    ENDIF.

  ENDLOOP.




ENDFUNCTION.
