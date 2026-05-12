FUNCTION /thkr/fi_apar_mandate_defmndid.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_WA) TYPE  RFSEPA_WA
*"     REFERENCE(I_COUNT_NUMBER) TYPE  I DEFAULT 1
*"  EXPORTING
*"     REFERENCE(E_MNDID) TYPE  SEPA_MNDID
*"     REFERENCE(E_FIRST_NUMBER) TYPE  N
*"     REFERENCE(E_LAST_NUMBER) TYPE  N
*"----------------------------------------------------------------------
  DATA: lv_orgf1 TYPE rfsepa_wa-orgf1,
        lv_act   TYPE activ_auth.
  CLEAR: e_mndid,
         e_first_number,
         e_last_number.
  CHECK i_wa-anwnd    = gc_anwnd_fi
    AND i_wa-rec_type = gc_bor-companycode.
  IF i_wa-snd_type NE gc_bor-araccount AND i_wa-snd_type NE gc_bor-bseg.
    RETURN. "function
  ENDIF.
  IF i_wa-mndid IS NOT INITIAL.
    e_mndid = i_wa-mndid.
    RETURN. " function
  ELSE.
    IF sy-tcode = 'FSEPA_M1' OR sy-xform = 'BAPI_SEPA_MANDATE_CREATE1' OR i_wa-orgf1 IS INITIAL.
      lv_act   = '01'.
      AUTHORITY-CHECK OBJECT 'ZF_MANDATE'
        ID 'ACTVT' FIELD lv_act
        ID 'GSBER' FIELD i_wa-/thkr/gsber.
      IF sy-subrc <> 0.
        MESSAGE e032(/thkr/fi_nachr) WITH  i_wa-/thkr/gsber.
      ENDIF.
      CONCATENATE i_wa-/thkr/gsber sy-datum sy-uzeit INTO e_mndid.
    ELSE.
      lv_orgf1 = i_wa-orgf1.
      SHIFT lv_orgf1 LEFT DELETING LEADING space.
      CONCATENATE lv_orgf1+0(4) sy-datum sy-uzeit INTO e_mndid.
    ENDIF.
  ENDIF.

ENDFUNCTION.
