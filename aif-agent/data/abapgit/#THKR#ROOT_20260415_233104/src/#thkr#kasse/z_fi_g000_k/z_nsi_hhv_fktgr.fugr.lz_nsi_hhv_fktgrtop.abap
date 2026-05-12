FUNCTION-POOL Z_NSI_HHV_FKTGR.              "MESSAGE-ID ..
type-pools: rsds,    " Types for dynamic selections
            szadr,   " BAS-Types
            vrm.     " Types for VRM (e.g. dropdown list)  " \TP 1161096



************************************************************************
*   Global macros                                                      *
************************************************************************
define gm_check_for_continuation.   " &1 is of type BAPIRET1
                                    " &2 is of type BAPIRET1_LIST
  if &1-type is not initial.
    append &1 to &2.
    return. " processing block (form, function module, ...)
  endif.
end-of-definition. " gm_check_for_continuation



************************************************************************
*   Global constants                                                   *
************************************************************************
constants:
* Message ID
  gc_msgid type symsgid value 'SEPA',

* Activity of authorization objects
  begin of gc_actvt,
    create  type activ_auth value '01',
    modify  type activ_auth value '02',
    display type activ_auth value '03',
    delete  type activ_auth value '06',
  end of gc_actvt,

* BOR Objects
  begin of gc_BOR,
    ARAccount     type swo_objtyp value 'BUS3007',   " Debitor
    CompanyCode   type swo_objtyp value 'BUS0002',   " Buchungskreis
    AccountingDoc type swo_objtyp value 'BKPF',      " FI-Beleg
    PaymentOrder  type swo_objtyp value 'PYORD',     " Zahlungsauftrag
    bseg          type swo_objtyp value 'BSEG',      " Belegreferenz
  end of gc_BOR,

* Mandate status
  begin of gc_status,
    created  type c value '0',
    active   type c value '1',
    wait     type c value '2',   " Wait for approval
    blocked  type c value '3',
    canceled type c value '4',
    obsolete type c value '5',
    closed   type c value '6',
  end of gc_status,

* Miscellaneous
  gc_dfpm_numb_obj(6) type c          value 'BF_MND',
  gc_anwnd_FI         type sepa_anwnd value 'F',
  gc_mvers_0          type sepa_mvers value '0000'.



************************************************************************
*   Global data                                                        *
************************************************************************
data:
  begin of screen_field,           " Screen fields
    kunnr    type kunnr,
    kunname  type name1_gp,
    zbukr    type dzbukr,
    bukname  type butxt,
    ref_type type fsepa_ref_type,                          " \TP 1161096
    ref_id   type fsepa_ref_id,                            " \TP 1161096
    ref_desc type fsepa_ref_desc,                          " \TP 1161096
    docref   TYPE fsepa_ref_belnr,                         "note 1611602
    bukrs    TYPE fsepa_ref_belnr,                         "note 1611602
    belnr    TYPE fsepa_ref_belnr,                         "note 1611602
    gjahr    TYPE fsepa_ref_belnr,                         "note 1611602
    buzei    TYPE fsepa_ref_belnr,                         "note 1611602
  end of screen_field,
  g_activity  type activ_auth,
  gs_mandate  type sepa_mandate,   " Current mandate
  gs_fix_data type sepa_mandate.   " Unchangeable fields


*******************************************************************
*   Global help variables: these variables are needed as help     *
*   variables in lots of functions and form routines. To avoid    *
*   declaring them again and again everywhere they are needed,    *
*   they are declared here once. Nevertheless, they should be     *
*   always initialized and assigned a value before(!) their use.  *
*******************************************************************
data:
  gh_kunnr       type kunnr,        " Debtor number
  gh_zbukr       type dzbukr,       " Paying company code
  gh_docref  type fsepa_ref_belnr, "document reference, note 1611602
  gh_mandate_IDs type rfsepa_IDs,   " Various IDs in a mandate
  gh_msg         type bapiret1.     " Message

data:
  gv_dynnr       type  dynnr.                         "note 1611602




* INCLUDE LZ_NSI_HHV_FKTGRD...               " Local class definition
