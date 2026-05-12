class /THKR/CL_FMBS_VALIDATION definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_FMBS_VALID_ADDRESS .
protected section.
private section.

  methods CONVERSION_FIPEX
    importing
      !IV_FIPEX type FM_FIPEX
    returning
      value(RV_OUT) type STRING .
ENDCLASS.



CLASS /THKR/CL_FMBS_VALIDATION IMPLEMENTATION.


  METHOD conversion_fipex.
    CHECK iv_fipex IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_FMCIL_OUTPUT'
      EXPORTING
        input  = iv_fipex
      IMPORTING
        output = rv_out.
  ENDMETHOD.


  method IF_EX_FMBS_VALID_ADDRESS~EXTEND_GRANT_VALIDITY.
  endmethod.


  METHOD if_ex_fmbs_valid_address~fill_address_suppl.
  ENDMETHOD.


  METHOD if_ex_fmbs_valid_address~validate_bo.
    DATA: l_f_fmci TYPE fmci.
    CALL FUNCTION 'FM_COM_ITEM_READ_SINGLE_DATA'
      EXPORTING
        i_fikrs                  = im_fm_area
        i_gjahr                  = im_fiscyear
        i_fipex                  = im_address-cmmtitem
        i_flg_text               = abap_false
        i_flg_hierarchy          = abap_false
      IMPORTING
        e_f_fmci                 = l_f_fmci
      EXCEPTIONS
        master_data_not_found    = 1
        hierarchy_data_not_found = 2
        input_error              = 3
        OTHERS                   = 4.
    IF l_f_fmci-fivor = '30' AND l_f_fmci-potyp = '2' AND im_budcat = '9G'.
      MESSAGE e001(/thkr/psm_bu) WITH l_f_fmci-fipex im_budcat RAISING invalid_bo.
    ENDIF.

    IF im_address-fund <> '93' AND   "Ausnahme für Kasse, nicht prüfen
       im_address-fund <> '94' AND
       im_address-fund <> '95' AND
       im_address-fund <> '96'.

      IF im_address-fund(2)     <> im_address-funcarea(2) OR
         im_address-funcarea(4) <> im_address-cmmtitem(4).
        "MESSAGE e004(/thkr/psm_bu) WITH im_address-cmmtitem im_address-fund im_address-funcarea RAISING invalid_po.
        MESSAGE e004(/thkr/psm_bu) WITH |Finanzposition { conversion_fipex( im_address-cmmtitem ) } ist mit dem angegebenen|
                                        |Fonds { im_address-fund }|
                                        |und Funktionsbereich { im_address-funcarea } nicht pflegbar.|
                                        RAISING invalid_bo.
      ENDIF.

    ENDIF.

*    IF im_address-fundsctr NP '*02'.
*      MESSAGE e003(/thkr/psm_bu) WITH im_address-fundsctr RAISING invalid_bo.
*    ENDIF.
  ENDMETHOD.


  METHOD if_ex_fmbs_valid_address~validate_po.
    DATA: l_f_fmci TYPE fmci.
    CALL FUNCTION 'FM_COM_ITEM_READ_SINGLE_DATA'
      EXPORTING
        i_fikrs                  = im_fm_area
        i_gjahr                  = im_fiscyear
        i_fipex                  = im_address-cmmtitem
        i_flg_text               = abap_false
        i_flg_hierarchy          = abap_false
      IMPORTING
        e_f_fmci                 = l_f_fmci
      EXCEPTIONS
        master_data_not_found    = 1
        hierarchy_data_not_found = 2
        input_error              = 3
        OTHERS                   = 4.
    IF l_f_fmci-fivor = '30' AND l_f_fmci-potyp = '2' AND im_pldnr = '9B'.
      MESSAGE e001(/thkr/psm_bu) WITH l_f_fmci-fipex im_pldnr RAISING invalid_po.
    ENDIF.

    IF im_address-fund <> '93' AND   "Ausnahme für Kasse, nicht prüfen
       im_address-fund <> '94' AND
       im_address-fund <> '95' AND
       im_address-fund <> '96'.

      IF im_address-fund(2)     <> im_address-funcarea(2) OR
         im_address-funcarea(4) <> im_address-cmmtitem(4).
        "MESSAGE e004(/thkr/psm_bu) WITH im_address-cmmtitem im_address-fund im_address-funcarea RAISING invalid_po.
        MESSAGE e004(/thkr/psm_bu) WITH |Finanzposition { conversion_fipex( im_address-cmmtitem ) } ist mit dem angegebenen|
                                        |Fonds { im_address-fund }|
                                        |und Funktionsbereich { im_address-funcarea } nicht pflegbar.|
                                        RAISING invalid_po.
      ENDIF.

    ENDIF.

    IF im_address-fundsctr NP '*02'.
      MESSAGE e003(/thkr/psm_bu) WITH im_address-fundsctr RAISING invalid_po.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
