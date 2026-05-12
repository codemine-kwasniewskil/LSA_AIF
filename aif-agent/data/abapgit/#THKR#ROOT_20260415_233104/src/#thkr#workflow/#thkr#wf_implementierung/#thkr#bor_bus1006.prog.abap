*****           Implementation of object type /THKR/1006           *****
INCLUDE <object>.
begin_data object. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
  " begin of private,
  "   to declare private attributes remove comments and
  "   insert private attributes here ...
  " end of private,
  BEGIN OF key,
    businesspartner LIKE but000-partner,
  END OF key.
end_data object. " Do not change.. DATA is generated
****************************************************************
* Konstanten
CONSTANTS gc_x TYPE c LENGTH 1 VALUE 'X'.

****************************************************************
begin_method zgetemailadress changing container.
DATA:
  lv_wfinitiator   TYPE wfsyst-initiator,
  lt_emailadressen TYPE TABLE OF swd_sdynp-m_recipnt,
  ls_emailadressen TYPE swd_sdynp-m_recipnt,
  lv_xsubrc        TYPE syst-subrc,
  lv_uname         TYPE bapibname-bapibname,
  lt_smtp          TYPE bapiadsmtp_t,
  ls_smtp          TYPE bapiadsmtp,
  lt_bapiret2      TYPE bapiret2_t,
  ls_logond        TYPE bapilogond.



swc_get_element container 'V_USERNAME' lv_wfinitiator .
swc_get_table container 'T_EMAILADRESSEN' lt_emailadressen.

lv_xsubrc = 2.
* Auslesen Benutzername - kann so oder so lauten
IF lv_wfinitiator(2) = 'US'.
  lv_uname = lv_wfinitiator+2(12).
ELSE.
  lv_uname = lv_wfinitiator.
ENDIF.



CALL FUNCTION 'BAPI_USER_GET_DETAIL'
  EXPORTING
    username  = lv_uname
  IMPORTING
    logondata = ls_logond
  TABLES
    return    = lt_bapiret2
    addsmtp   = lt_smtp.

IF ls_logond-ustyp EQ 'A' .   " Nur Dialoguser - relevant
  IF lt_smtp IS NOT INITIAL.

    READ TABLE lt_smtp INTO ls_smtp INDEX 1.

    MOVE ls_smtp-e_mail TO ls_emailadressen.
    APPEND ls_emailadressen TO lt_emailadressen.
    lv_xsubrc = 0.

  ENDIF.
ENDIF.

swc_set_table container 'T_EMAILADRESSEN' lt_emailadressen.
swc_set_element container 'XSUBRC' lv_xsubrc.
end_method.
****************************************************************

begin_method zsetzenloeschkennzeichen changing container.
DATA:
  lv_xsubrc    TYPE syst-subrc,
  ls_wf_bp_del TYPE /THKR/wf_bp_del.

DATA lt_return TYPE bapiret2_t.

CALL METHOD /thkr/cl_wf_bupa=>set_deleteflag
  EXPORTING
    iv_businesspartner = object-key-businesspartner
  IMPORTING
    et_return          = lt_return.

READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_return>)
   WITH KEY type = 'E'.
IF sy-subrc = 0.
  MESSAGE 'Der Geschäftspartner konnte nicht zum Löschen vorgemerkt werden!' TYPE 'E'.
ENDIF.

ls_wf_bp_del-partner = object-key-businesspartner.
ls_wf_bp_del-ablehnungsdatum = sy-datum.

INSERT /THKR/WF_BP_DEL FROM ls_wf_bp_del.

swc_set_element container 'XSUBRC' lv_xsubrc.
end_method.
****************************************************************




****************************************************************

begin_method zsetzensperrflag changing container.
DATA:
      lv_xsubrc TYPE syst-subrc.

DATA lt_return TYPE bapiret2_t.

CALL METHOD /thkr/cl_wf_bupa=>nonreleasekennz_exxen
  EXPORTING
    iv_businesspartner = object-key-businesspartner
  IMPORTING
    et_return          = lt_return.

READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_return>)
WITH KEY type = 'E'.
IF sy-subrc = 0.
  MESSAGE 'Der Geschäftspartner konnte nicht entsperrt werden!.' TYPE 'E'.
ENDIF.


* Bei den Nachfolgenden Methoden das Return nicht abfragen,
* da nicht sicher , ob über LFA oder KNA Daten vorhanden
CALL METHOD /thkr/cl_wf_bupa=>kna_sperre_exxen
  EXPORTING
    iv_businesspartner = object-key-businesspartner
*  IMPORTING
*   et_return          =
  .

CALL METHOD /thkr/cl_wf_bupa=>lfa_sperre_exxen
  EXPORTING
    iv_businesspartner = object-key-businesspartner
*  IMPORTING
*   et_return          =
  .

DATA: lv_partner_4_lock TYPE bu_partner.
MOVE object-key TO lv_partner_4_lock.
CALL FUNCTION 'BUPA_DEQUEUE'
  EXPORTING
    iv_partner      = lv_partner_4_lock
*   IV_PARTNER_GUID =
*   IV_CHECK_NOT_NUMBER       =
*   IV_REQ_BLK_MSG  =
  TABLES
    et_return       = lt_return
  EXCEPTIONS
    blocked_partner = 1
    OTHERS          = 2.
IF sy-subrc <> 0.

  READ TABLE lt_return TRANSPORTING NO FIELDS
  WITH KEY type = 'E'.
  IF sy-subrc = 0.
    MESSAGE 'Der Funktionsbaustein BUPA_DEQUEUE konnte nicht richtig verwendet werden.' TYPE 'E'.
  ENDIF.
ENDIF.



swc_set_element container 'XSUBRC' lv_xsubrc.
end_method.
****************************************************************
begin_method zentfernensperrflag changing container.
DATA:
      lv_xsubrc TYPE syst-subrc.
DATA lt_return TYPE bapiret2_t.

CALL METHOD /thkr/cl_wf_bupa=>nonreleasekennz_entexxen
  EXPORTING
    iv_businesspartner = object-key-businesspartner
  IMPORTING
    et_return          = lt_return.

READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_return>)
WITH KEY type = 'E'.
IF sy-subrc = 0.
  MESSAGE 'Der Geschäftspartner konnte nicht entsperrt werden!.' TYPE 'E'.
ENDIF.


* Bei den Nachfolgenden Methoden das Return nicht abfragen,
* da nicht sicher , ob über LFA oder KNA Daten vorhanden

CALL METHOD /thkr/cl_wf_bupa=>kna_sperreentexxen
  EXPORTING
    iv_businesspartner = object-key-businesspartner
*  IMPORTING
*   et_return          =
  .


CALL METHOD /thkr/cl_wf_bupa=>lfa_sperreentexxen
  EXPORTING
    iv_businesspartner = object-key-businesspartner
*  IMPORTING
*   et_return          =
  .


swc_set_element container 'XSUBRC' lv_xsubrc.
end_method.

****************************************************************

begin_method zemittelnsperrflags changing container.
DATA:
      lt_sperrflags TYPE /thkr/tt_wf_bpspr.
DATA lv_wiid TYPE sww_wiid.


swc_set_element container 'V_WIID' lv_wiid.


CALL METHOD /thkr/cl_wf_bupa=>lesen_sperren
  EXPORTING
    iv_businesspartner = object-key-businesspartner
  IMPORTING
    et_sperren         = lt_sperrflags.


IF lt_sperrflags IS NOT INITIAL.
  LOOP AT lt_sperrflags ASSIGNING FIELD-SYMBOL(<fs_sperre>).
    <fs_sperre>-wiid = lv_wiid.
  ENDLOOP.

ENDIF.

swc_set_table container 'T_SPERRFLAGS' lt_sperrflags.
end_method.
****************************************************************

begin_method zsetdeletflag changing container.
DATA:
      xsubrc TYPE syst-subrc.
DATA lt_return TYPE bapiret2_t.


CALL METHOD /thkr/cl_wf_bupa=>set_deleteflag
  EXPORTING
    iv_businesspartner = object-key-businesspartner
  IMPORTING
    et_return          = lt_return.



swc_set_element container 'XSUBRC' xsubrc.
end_method.
****************************************************************
begin_method zaddattachments changing container.
DATA:
  lv_xsubrc TYPE syst-subrc,
  lv_wiid   TYPE swwwihead-wi_id.
DATA lv_objkey TYPE swo_typeid.

swc_get_element container 'V_WIID' lv_wiid.

MOVE object-key-businesspartner TO  lv_objkey  .

CALL FUNCTION '/THKR/WF_OBJ_RELAT_CREATE'
  EXPORTING
    iv_objkey                      = lv_objkey
    iv_objtype                     = 'BUS1006'
    iv_wi_id                       = lv_wiid
  EXCEPTIONS
    relation_could_not_create      = 1
    error_reading_attachements     = 2
    error_reading_attachement_type = 3
    OTHERS                         = 4.
IF sy-subrc <> 0.
  lv_xsubrc = 2.
ENDIF.

" Fehlerhandling im WF?
swc_set_element container 'XSUBRC' lv_xsubrc.
end_method.
****************************************************************

begin_method zgetgenehmigungswerte changing container.
DATA:
  lv_gsber  TYPE but000-/thkr/gsber,
  xsubrc    TYPE syst-subrc,
  lv_bukrs  TYPE t001-bukrs,
  lv_gprole TYPE but000-bu_group.

DATA ls_but000 TYPE but000.


SELECT SINGLE * INTO ls_but000 FROM but000
  WHERE partner = object-key-businesspartner.

IF sy-subrc EQ 0.
  lv_gsber = ls_but000-/thkr/gsber.
  lv_gprole = ls_but000-bu_group .


  SELECT SINGLE bukrs INTO lv_bukrs
    FROM lfb1
    WHERE lifnr = object-key-businesspartner.

  IF sy-subrc NE 0.

    SELECT SINGLE bukrs INTO lv_bukrs
    FROM knb1
    WHERE kunnr = object-key-businesspartner.

    IF sy-subrc NE 0.
      xsubrc = 5.  " Genehmigung geht zu Admin
    ENDIF.
  ENDIF.

ELSE.
  xsubrc = 7.  "gar kein BP ???
ENDIF.


swc_set_element container 'V_GSBER' lv_gsber.
swc_set_element container 'XSUBRC' xsubrc.
swc_set_element container 'V_BUKRS' lv_bukrs.
swc_set_element container 'V_GPROLE' lv_gprole.
end_method.

****************************************************************
