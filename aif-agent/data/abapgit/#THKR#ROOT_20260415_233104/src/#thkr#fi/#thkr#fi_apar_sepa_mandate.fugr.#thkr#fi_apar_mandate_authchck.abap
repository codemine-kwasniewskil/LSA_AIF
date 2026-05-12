FUNCTION /thkr/fi_apar_mandate_authchck.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_MANDATE) TYPE  SEPA_MANDATE
*"     REFERENCE(I_ACT) TYPE  C
*"  EXCEPTIONS
*"      NO_AUTHORITY
*"----------------------------------------------------------------------

  DATA: l_power    TYPE xfeld.   " X = authority-check ok
  DATA: l_fi_check TYPE boolean. " - = default (not changed by implementing application)
  " X = authority-check reqired, SPACE = not required
  IF i_mandate-anwnd <> gc_anwnd_fi
  OR ( i_mandate-snd_type <> gc_bor-araccount
       AND i_mandate-snd_type <> gc_bor-bseg )
  OR i_mandate-rec_type <> gc_bor-companycode.
*   Should not occur
    MESSAGE e007(sepa) WITH 'FI_APAR_MANDATE_AUTHORITY_CHCK'
                            'PARAMETER_HAS_UNKNOWN_VALUE' '' ''.
  ENDIF.
  l_fi_check = '-'.
  GET BADI go_badi.
  CALL BADI go_badi->authority_check
    EXPORTING
      i_mandate    = i_mandate
      i_act        = i_act
    CHANGING
      c_fi_check   = l_fi_check
    EXCEPTIONS
      no_authority = 4.
  IF sy-subrc NE 0.
    RAISE no_authority.
  ELSEIF l_fi_check IS INITIAL.
    RETURN.
  ENDIF.
  gh_zbukr = i_mandate-rec_id.
  IF i_act IS INITIAL.
    PERFORM authority_check_mandate USING gh_zbukr '03'
                                  CHANGING l_power.
  ELSE.

    PERFORM authority_check_mandate USING gh_zbukr i_act
                                 CHANGING l_power.
  ENDIF.
  IF l_power IS INITIAL.
    RAISE no_authority.
  ENDIF.
*to create / delete / display / change a mandate need the authorization to display sender customer
*only the normal customer is checked currently: one-time customer will always be accessed
  IF i_mandate-snd_type = gc_bor-araccount.
    gh_kunnr = i_mandate-snd_id.
    PERFORM authority_check_mandate_kunnr USING gh_kunnr '03'
                             CHANGING l_power.
    IF l_power IS INITIAL.
      RAISE no_authority.
    ENDIF.
  ENDIF.
**** hier kommt das neue Berechtigungsobjekt für den Geschäftsbereich 15.8.2019 d. Krüger Dxc
  if i_act is INITIAL.
  AUTHORITY-CHECK OBJECT 'ZF_MANDATE'
    ID 'ACTVT' FIELD '03'
    ID 'GSBER' FIELD  i_mandate-/thkr/gsber.
  ELSE.
     AUTHORITY-CHECK OBJECT 'ZF_MANDATE'
    ID 'ACTVT' FIELD i_act
    ID 'GSBER' FIELD  i_mandate-/thkr/gsber.
    ENDIF.
  IF sy-subrc <> 0.
    l_power = space.
  ENDIF.
  IF l_power IS INITIAL.
    RAISE no_authority.
  ENDIF.

ENDFUNCTION.
