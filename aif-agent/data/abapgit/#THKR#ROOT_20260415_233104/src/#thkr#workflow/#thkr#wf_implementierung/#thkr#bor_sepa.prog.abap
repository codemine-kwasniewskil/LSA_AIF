*****           Implementation of object type /THKR/SEPA           *****
INCLUDE <object>.
begin_data object. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
  " begin of private,
  "   to declare private attributes remove comments and
  "   insert private attributes here ...
  " end of private,
  BEGIN OF key,
    creditorid LIKE sepa_mandate-origin_rec_crdid,
    mandateid  LIKE sepa_mandate-origin_mndid,
  END OF key,
  _sepa_mandate LIKE sepa_mandate.
end_data object. " Do not change.. DATA is generated

begin_method zgetbasicdata changing container.
DATA:
  xsubrc     TYPE syst-subrc,
  v_gsber    TYPE sepa_mandate-/thkr/gsber,
  v_bukrs    TYPE t001-bukrs,
  lv_cred_id TYPE sepa_mandate-origin_rec_crdid,
  lv_mand_id TYPE sepa_mandate-origin_mndid.

swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.

DATA: "lApplication   type bapi_s_sepa_mandate_id-application,
  "lReadForChange type bapiflag,
  ls_MandateRead TYPE bapi_s_sepa_mandate_data,
  ls_Return      TYPE bapiret2.

IF lv_mand_id IS INITIAL
  OR lv_cred_id IS INITIAL.
  xsubrc = 4.
  swc_set_element container 'XSUBRC' xsubrc.
ENDIF.
*  swc_get_element container 'IApplication'   lApplication.
*  swc_get_element container 'IReadForChange' lReadForChange.
*  if sy-subrc <> 0.
*    lReadForChange = space.
*  endif.
CALL FUNCTION 'BAPI_SEPA_MANDATE_READ1'
  EXPORTING
    i_application   = 'F'
    creditorId      = lv_cred_id
    mandateId       = lv_mand_id
*   i_read_for_change = lReadForChange
  IMPORTING
    es_mandate_read = ls_MandateRead
    return          = ls_Return
  EXCEPTIONS
    OTHERS          = 01.
CASE sy-subrc.
  WHEN 0.            " OK
    xsubrc = sy-subrc.
    v_gsber = ls_mandateread-/thkr/gsber.
  WHEN OTHERS.       " to be implemented
    xsubrc = sy-subrc.
ENDCASE.

IF v_gsber IS INITIAL.
  xsubrc = 4.
ENDIF.

SELECT SINGLE * FROM /thkr/t_wf_param
  INTO @DATA(ls_param)
  WHERE object = 'WF_SEPA_DEFAULT_BUKRS'.

IF sy-subrc = 0.
  v_bukrs = ls_param-value_von.
ENDIF.

swc_set_element container 'V_BUKRS' v_bukrs.
swc_set_element container 'XSUBRC' xsubrc.
swc_set_element container 'V_GSBER' v_gsber.
end_method.

begin_method zchangemandatedialog changing container.
DATA:
      xsubrc TYPE syst-subrc.

DATA: ls_MandateRead TYPE bapi_s_sepa_mandate_data,
      ls_Return      TYPE bapiret2,
      ls_IntKey      TYPE rfsepa_intkey,
      lv_cred_id     TYPE sepa_mandate-origin_rec_crdid,
      lv_mand_id     TYPE sepa_mandate-origin_mndid.

swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.

CALL FUNCTION 'BAPI_SEPA_MANDATE_READ1'
  EXPORTING
    i_application   = 'F'
    creditorId      = lv_cred_id
    mandateId       = lv_mand_id
  IMPORTING
    es_mandate_read = ls_MandateRead
    return          = ls_Return
  EXCEPTIONS
    OTHERS          = 01.
CASE sy-subrc.
  WHEN 0.
    IF ls_Return-number IS INITIAL
    OR ( ls_Return-type   = 'W'    AND                    " \TP 1292562
         ls_Return-id     = 'SEPA' AND                    " \TP 1292562
         ls_Return-number = '147' ).                      " \TP 1292562
      ls_IntKey-anwnd     = ls_MandateRead-application.
      ls_IntKey-rec_crdid = ls_MandateRead-sepa_creditor_id.
      ls_IntKey-mndid     = ls_MandateRead-sepa_mandate_id.
      CALL FUNCTION 'SEPA_MANDATE_UI_CHANGE'
        EXPORTING
          i_do_commit  = 'X'
          i_intkey     = ls_IntKey
          i_fullscreen = 'X'.
      IF 1 = 2.   " Only for the where-used list         " \TP 1292562
        MESSAGE w147(sepa).    "#EC *                     " \TP 1292562
      ENDIF.                                             " \TP 1292562
    ENDIF.
  WHEN OTHERS.
    xsubrc = sy-subrc.

ENDCASE.


swc_set_element container 'XSUBRC' xsubrc.
end_method.

begin_method zdeclinemandat changing container.
DATA:
      xsubrc TYPE syst-subrc.

DATA: ls_MandateRead    TYPE bapi_s_sepa_mandate_data,
      ls_mandate_change TYPE bapi_s_sepa_mandate_change,
      ls_Return         TYPE bapiret2,
      ls_IntKey         TYPE rfsepa_intkey,
      lv_cred_id        TYPE sepa_mandate-origin_rec_crdid,
      lv_mand_id        TYPE sepa_mandate-origin_mndid.

swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.

CALL FUNCTION 'BAPI_SEPA_MANDATE_READ1'
  EXPORTING
    i_application   = 'F'
    creditorId      = lv_cred_id
    mandateId       = lv_mand_id
  IMPORTING
    es_mandate_read = ls_MandateRead
    return          = ls_Return
  EXCEPTIONS
    OTHERS          = 01.
IF sy-subrc <> 0.
  xsubrc = sy-subrc.
ELSE.
  MOVE-CORRESPONDING ls_MandateRead TO ls_mandate_change.

  ls_mandate_change-status = '4'.

  CALL FUNCTION 'BAPI_SEPA_MANDATE_CHANGE1'
    EXPORTING
      i_application     = 'F'
      creditorId        = lv_cred_id
      mandateId         = lv_mand_id
      is_data_to_change = ls_mandate_change
    IMPORTING
      return            = ls_Return
    EXCEPTIONS
      OTHERS            = 01.
  CASE sy-subrc.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
      xsubrc = sy-subrc.
  ENDCASE.

ENDIF.

swc_set_element container 'XSUBRC' xsubrc.
end_method.

begin_method zsetlock changing container.
DATA:
  xsubrc     TYPE syst-subrc,
  ls_mandate TYPE sepa_mandate,
  lv_cred_id TYPE sepa_mandate-origin_rec_crdid,
  lv_mand_id TYPE sepa_mandate-origin_mndid.

swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.


SELECT SINGLE * FROM sepa_mandate
INTO ls_mandate
WHERE  origin_rec_crdid = lv_cred_id
AND origin_mndid = lv_mand_id
AND mvers = '0'.
IF sy-subrc = 0.

  ls_mandate-glock = 'X'.
  ls_mandate-glock_val_from = sy-datum.
  ls_mandate-glock_val_to = '99991231'.

  UPDATE sepa_mandate FROM ls_mandate.

  xsubrc = sy-subrc.

ELSE.
  xsubrc = sy-subrc.

ENDIF.


swc_set_element container 'XSUBRC' xsubrc.
end_method.

begin_method zunlock changing container.
DATA:
  xsubrc     TYPE syst-subrc,
  ls_mandate TYPE sepa_mandate,
  lv_cred_id TYPE sepa_mandate-origin_rec_crdid,
  lv_mand_id TYPE sepa_mandate-origin_mndid.

swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.


SELECT SINGLE * FROM sepa_mandate
INTO ls_mandate
WHERE  origin_rec_crdid = lv_cred_id
AND origin_mndid = lv_mand_id
AND mvers = '0'.
IF sy-subrc = 0.

  ls_mandate-glock = ''.
  ls_mandate-glock_val_from = ''.
  ls_mandate-glock_val_to = ''.

  UPDATE sepa_mandate FROM ls_mandate.

  xsubrc = sy-subrc.
ELSE.

  xsubrc = sy-subrc.

ENDIF.

swc_set_element container 'XSUBRC' xsubrc.
end_method.

begin_method zchecklock changing container.
DATA:
  xsubrc     TYPE syst-subrc,
  ls_mandate TYPE sepa_mandate,
  lv_cred_id TYPE sepa_mandate-origin_rec_crdid,
  lv_mand_id TYPE sepa_mandate-origin_mndid.

swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.

SELECT SINGLE * FROM sepa_mandate
INTO ls_mandate
WHERE  origin_rec_crdid = lv_cred_id
AND origin_mndid = lv_mand_id
AND mvers = '0'.
IF sy-subrc = 0.
  IF ls_mandate-glock IS INITIAL.

    ls_mandate-glock = 'X'.
    ls_mandate-glock_val_from = sy-datum.
    ls_mandate-glock_val_to = '99991231'.

    UPDATE sepa_mandate FROM ls_mandate.

    xsubrc = sy-subrc.
  ELSE.

    xsubrc = 0.

  ENDIF.
ELSE.

  xsubrc = sy-subrc.

ENDIF.



swc_set_element container 'XSUBRC' xsubrc.
end_method.

begin_method zsetactive changing container.
DATA: xsubrc TYPE syst-subrc.

DATA: ls_MandateRead    TYPE bapi_s_sepa_mandate_data,
      ls_mandate_change TYPE bapi_s_sepa_mandate_change,
      ls_Return         TYPE bapiret2,
      ls_IntKey         TYPE rfsepa_intkey,
      ls_mandate        TYPE sepa_mandate,
      lv_cred_id        TYPE sepa_mandate-origin_rec_crdid,
      lv_mand_id        TYPE sepa_mandate-origin_mndid.

swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.

CALL FUNCTION 'BAPI_SEPA_MANDATE_READ1'
  EXPORTING
    i_application   = 'F'
    creditorId      = lv_cred_id
    mandateId       = lv_mand_id
  IMPORTING
    es_mandate_read = ls_MandateRead
    return          = ls_Return
  EXCEPTIONS
    OTHERS          = 01.
IF sy-subrc <> 0.
  xsubrc = sy-subrc.
ELSE.
  MOVE-CORRESPONDING ls_MandateRead TO ls_mandate_change.

  ls_mandate_change-status = '1'.

  CALL FUNCTION 'BAPI_SEPA_MANDATE_CHANGE1'
    EXPORTING
      i_application     = 'F'
      creditorId        = lv_cred_id
      mandateId         = lv_mand_id
      is_data_to_change = ls_mandate_change
    IMPORTING
      return            = ls_Return
    EXCEPTIONS
      OTHERS            = 01.
  CASE sy-subrc.
    WHEN 0.            " OK
    WHEN OTHERS.       " to be implemented
      xsubrc = sy-subrc.
  ENDCASE.


ENDIF.

swc_set_element container 'XSUBRC' xsubrc.
end_method.

begin_method zaddattachements changing container.

DATA:
  xsubrc      TYPE syst-subrc,
  lv_wiid     TYPE swwwihead-wi_id,
  lv_objkey   TYPE swo_typeid,
  lv_cred_id  TYPE sepa_mandate-origin_rec_crdid,
  lv_mand_id  TYPE sepa_mandate-origin_mndid.



swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.
swc_get_element container 'V_WIID' lv_wiid.

MOVE object-key TO lv_objkey.

SELECT mguid FROM sepa_mandate
  INTO TABLE @DATA(lt_sepa_mguid)
  WHERE origin_mndid = @lv_mand_id
  AND origin_rec_crdid = @lv_cred_id.

CALL FUNCTION '/THKR/WF_OBJ_RELAT_CREATE'
  EXPORTING
    iv_objkey                      = lv_objkey
    iv_objtype                     = 'SEPAMANDAT'
    iv_wi_id                       = lv_wiid
  EXCEPTIONS
    relation_could_not_create      = 1
    error_reading_attachements     = 2
    error_reading_attachement_type = 3
    OTHERS                         = 4.
IF sy-subrc <> 0.
  xsubrc = 2.
ENDIF.


LOOP AT lt_sepa_mguid ASSIGNING FIELD-SYMBOL(<fs_mguid>).
  MOVE <fs_mguid>-mguid to lv_objkey.

  CALL FUNCTION '/THKR/WF_OBJ_RELAT_CREATE'
  EXPORTING
    iv_objkey                      = lv_objkey
    iv_objtype                     = 'SEPAMANDAT'
    iv_wi_id                       = lv_wiid
  EXCEPTIONS
    relation_could_not_create      = 1
    error_reading_attachements     = 2
    error_reading_attachement_type = 3
    OTHERS                         = 4.
IF sy-subrc <> 0.
  xsubrc = 2.
ENDIF.

ENDLOOP.


swc_set_element container 'XSUBRC' xsubrc.
end_method.

TABLES sepa_mandate.
*
get_table_property sepa_mandate.
DATA subrc LIKE sy-subrc.
* Fill TABLES SEPA_MANDATE to enable Object Manager Access to Table
* Properties
PERFORM select_table_sepa_mandate USING subrc.
IF subrc NE 0.
  exit_object_not_found.
ENDIF.
end_property.
*
* Use Form also for other(virtual) Properties to fill TABLES
* SEPA_MANDATE
FORM select_table_sepa_mandate USING subrc LIKE sy-subrc.
* Select single * from SEPA_MANDATE, if OBJECT-_SEPA_MANDATE is initial
  IF object-_sepa_mandate-mandt IS INITIAL
  AND object-_sepa_mandate-mguid IS INITIAL.
    SELECT SINGLE * FROM sepa_mandate CLIENT SPECIFIED
        WHERE mandt = sy-mandt
        AND ( mguid = object-key OR (
       origin_rec_crdid = object-key-creditorid
  AND origin_mndid = object-key-mandateid ) )
      .
    subrc = sy-subrc.
    IF subrc NE 0. EXIT. ENDIF.
    object-_sepa_mandate = sepa_mandate.
  ELSE.
    subrc = 0.
    sepa_mandate = object-_sepa_mandate.
  ENDIF.
ENDFORM.
"Verlinken der Attachements an den richtigen Objektschlüssel
begin_method linkattachementstokey changing container.
TYPES: BEGIN OF lty_key,
         creditorid LIKE sepa_mandate-origin_rec_crdid,
         mandateid  LIKE sepa_mandate-origin_mndid,
       END OF lty_key.

DATA: lv_object         TYPE sibflporb,
      lv_object_temp    TYPE sibflporb,
      lv_cred_id        TYPE sepa_mandate-origin_rec_crdid,
      lv_mand_id        TYPE sepa_mandate-origin_mndid,
      lv_objec_key      TYPE lty_key,
      lv_objec_key_temp TYPE sibfboriid,
      lt_atta           TYPE gos_t_atta,
      lt_atta_temp      TYPE gos_t_atta,
      lt_atta_list_all  TYPE gos_t_atta,
      ls_obja           TYPE borident,
      ls_objb           TYPE borident,
      ls_binrel         TYPE gbinrel,
      lt_binatt         TYPE STANDARD TABLE OF brelattr.

*MOVE object-key TO lv_object-instid.
lv_object-objtype = 'SEPAMANDAT'.
lv_object-catid = 'BO'.

swc_get_property self 'RealCredId' lv_cred_id.
swc_get_property self 'RealMandId' lv_mand_id.

lv_objec_key-creditorid = lv_cred_id.
lv_objec_key-mandateid = lv_mand_id.
MOVE lv_objec_key TO lv_objec_key_temp.
MOVE lv_objec_key_temp TO lv_object-instid.
"Auslesen aller Unique Ids, um dort Attachements zu finden
SELECT mguid FROM sepa_mandate
  INTO TABLE @DATA(lt_sepa_mguid)
  WHERE origin_mndid = @lv_mand_id
  AND origin_rec_crdid = @lv_cred_id.
IF sy-subrc = 0.
  "Auslesen der Attachements an unserem Kernobjekt
  CALL FUNCTION 'GOS_API_GET_ATTA_LIST'
    EXPORTING
      is_object = lv_object
*     IT_FILTER =
*     IV_HANDLE =
    IMPORTING
      et_atta   = lt_atta
*     ES_RETURN =
    EXCEPTIONS
      error     = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  lv_object_temp-objtype = 'SEPAMANDAT'.
  lv_object_temp-catid = 'BO'.

  "Auslesen der Attachements von den Unique IDs
  LOOP AT lt_sepa_mguid ASSIGNING FIELD-SYMBOL(<fs_guid>).
    lv_object_temp-instid = <fs_guid>-mguid.
    CALL FUNCTION 'GOS_API_GET_ATTA_LIST'
      EXPORTING
        is_object = lv_object_temp
*       IT_FILTER =
*       IV_HANDLE =
      IMPORTING
        et_atta   = lt_atta_temp
*       ES_RETURN =
      EXCEPTIONS
        error     = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    APPEND LINES OF lt_atta_temp TO lt_atta_list_all.
    CLEAR lt_atta_temp.

  ENDLOOP.
  SORT lt_atta_list_all BY atta_id ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_atta_list_ALL COMPARING atta_id.

  IF lt_atta_list_all IS NOT INITIAL.
    ls_obja-objtype = 'SEPAMANDAT'.
    MOVE object-key TO ls_obja-objkey.
    ls_objb-objtype = 'MESSAGE'.
    "Prüfen aller Attachements, ob sie auch am Kernobjekt existieren
    LOOP AT lt_atta_list_all ASSIGNING FIELD-SYMBOL(<fs_atta>).
      "Wenn nicht vorhanden, dann Verknüpfung erstellen
      READ TABLE lt_atta WITH KEY atta_id = <fs_atta>-atta_id
      TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.

        MOVE <fs_atta>-atta_id TO ls_objb-objkey.

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
*      RAISE relation_could_not_create.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDIF.

end_method.
