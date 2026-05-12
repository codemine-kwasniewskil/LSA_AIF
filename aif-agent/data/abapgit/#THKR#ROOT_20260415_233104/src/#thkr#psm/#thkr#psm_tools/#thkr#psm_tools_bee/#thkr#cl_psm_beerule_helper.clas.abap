class /THKR/CL_PSM_BEERULE_HELPER definition
  public
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !TESTMODE type XFLAG default ABAP_TRUE .
  methods GET_ALL_BEERULES
    returning
      value(BEERULES) type /THKR/PSM_BEERULES_TRANSFER
    raising
      /THKR/CX_PSM_TOOLS .
  methods GET_BEERULE
    importing
      !FM_AREA type FIKRS default '1000'
      !FISCYEAR type GJAHR
      !ADDRESS type FMKU_S_DIMPART
      !LEDGER type BURB_RBBLDNR
    returning
      value(BEERULE_DATA) type /THKR/PSM_BEERULE_TRANSFER
    raising
      /THKR/CX_PSM_TOOLS .
  methods SET_BEERULE
    importing
      !BEERULE_DATA type /THKR/PSM_BEERULE_TRANSFER
    raising
      /THKR/CX_PSM_TOOLS .
  methods SET_BEERULES
    importing
      value(BEERULES) type /THKR/PSM_BEERULES_TRANSFER
    raising
      /THKR/CX_PSM_TOOLS .
protected section.

  data TESTMODE type XFLAG .

  methods SET_RULE_HEADER
    importing
      !BEERULE type /THKR/PSM_BEERULE_TRANSFER
      !API type ref to CL_FMRB_LIST
      !ADDRESS type FMKU_S_DIMPART
    raising
      /THKR/CX_PSM_TOOLS .
  methods CALL_EXCEPTION
    importing
      !API type ref to CL_FMBS_OBJECT_LIST
      !MSG type BUBAS_S_MSGS
      !ADDRESS type FMKU_S_DIMPART
    raising
      /THKR/CX_PSM_TOOLS .
private section.
ENDCLASS.



CLASS /THKR/CL_PSM_BEERULE_HELPER IMPLEMENTATION.


  METHOD call_exception.
    api->free( ).
    RAISE EXCEPTION TYPE /thkr/cx_psm_tools
      EXPORTING
        textid       = /thkr/cx_psm_tools=>beerl_not_created
        msgv1        = CONV #( address )
        bapiret2_tab = VALUE #( ( id = '/THKR/PSM_TOOLS' type = 'E'       number = 02        message_v1 = condense( val = conv char255( address ) ) )
                                ( id = msg-msgid         type = msg-msgty number = msg-msgno message_v1 = msg-msgv1 message_v2 = msg-msgv2 message_v3 = msg-msgv3 message_v4 = msg-msgv4 ) ).

  ENDMETHOD.


  METHOD get_all_beerules.

    SELECT FROM v_fmrbbrecs
      FIELDS fm_area,
             fiscyear,
             rbbldnr,
             fund,
             fundsctr,
             cmmtitem,
             funcarea,
             measure
       INTO TABLE @DATA(beerule_keys).

    LOOP AT beerule_keys INTO DATA(beerule_key).
      DATA(beerule) = me->get_beerule( fm_area  = beerule_key-fm_area
                                       fiscyear = beerule_key-fiscyear
                                       ledger   = beerule_key-rbbldnr
                                       address  = VALUE #( fund     = beerule_key-fund
                                                           fundsctr = beerule_key-fundsctr
                                                           cmmtitem = beerule_key-cmmtitem
                                                           funcarea = beerule_key-funcarea
                                                           measure  = beerule_key-measure ) ).
      APPEND beerule TO beerules.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_beerule.

    DATA(beerule_api) = NEW cl_fmrb_list( im_fm_area = fm_area im_fiscyear = fiscyear ).
    beerule_api->set_ldnr( ledger ).
    beerule_api->refresh_list( ).
    beerule_api->db_fill_with_objects( im_objects  = VALUE #( ( address ) ) im_flg_bypass_buffer = abap_true ).

    beerule_data = value #( fm_area = fm_area fiscyear = fiscyear ledger = ledger address = address  ).

    beerule_api->read_object_ro_data(
      EXPORTING
        im_address         = address         " HHM-Kontierung: BeE-Objekt
      IMPORTING
        e_roactstat        = beerule_data-roactstat
        e_updfilt          = beerule_data-updfilt
        e_calcrule         = beerule_data-calcrule
        e_manualcheckind   = beerule_data-manualcheckind
        e_bm_revenue_part  = beerule_data-bm_revenue_part
        e_bm_expendit_part = beerule_data-bm_expendit_part
        e_resamntind       = beerule_data-resamntind
        e_rib_procedure    = beerule_data-rib_procedure
      EXCEPTIONS
        object_not_in_list = 1                  " Ausgew. BeE-Objekt ist nicht in der Liste
    ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_tools EXPORTING textid = /thkr/cx_psm_tools=>beerl_not_found msgv1 = CONV #( address ).
    ENDIF.

    beerule_api->read_object_ro_rec(
      EXPORTING
        im_address         = address        " HHM-Kontierung
      IMPORTING
        e_t_bud_receivers  = beerule_data-t_bud_receivers " Tabelle für Budgetempfänger (BeE)
      EXCEPTIONS
        object_not_in_list = 1                 " BeE-Objekt ist nicht in Liste
        no_recs            = 2                 " Keine Budgetempf. in Liste gef. (Liste reinitialisieren?)
    ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_tools EXPORTING textid = /thkr/cx_psm_tools=>beerl_not_found msgv1 = CONV #( address ).
    ENDIF.

    beerule_api->read_object_ro_cvg(
      EXPORTING
        im_address         = address
      IMPORTING
        e_t_cvrgrps        = beerule_data-t_cvgrps
      EXCEPTIONS
        object_not_in_list = 1
        no_cvgs            = 2
    ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_tools EXPORTING textid = /thkr/cx_psm_tools=>beerl_not_found msgv1 = CONV #( address ).
    ENDIF.

  ENDMETHOD.


  METHOD set_beerule.

    DATA(beerule_api) = NEW cl_fmrb_list( im_fm_area = beerule_data-fm_area im_fiscyear = beerule_data-fiscyear ).
    beerule_api->check_ldnr( im_ldnr = beerule_data-ledger im_flg_set_value = abap_true ).
    beerule_api->check_fiscyear( beerule_data-fiscyear ).
    beerule_api->add_new_object(
      EXPORTING
        im_address_budget  = beerule_data-address
        im_flg_generate_md = abap_false
      IMPORTING
        e_address          = DATA(new_address)
        e_msg              = DATA(msg) ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = beerule_api msg = msg address = beerule_data-address ).
    ENDIF.

    me->set_rule_header( beerule = beerule_data api = beerule_api address = new_address ).

    msg = beerule_api->modify_object_all_receivers( im_t_bud_receivers = beerule_data-t_bud_receivers im_address = new_address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = beerule_api msg = msg address = new_address ).
    ENDIF.

    msg = beerule_api->modify_object_all_cvgrps( im_t_cvgrps = beerule_data-t_cvgrps im_address = new_address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = beerule_api msg = msg address = new_address ).
    ENDIF.

** Save changes
    IF msg IS INITIAL
    AND me->testmode = abap_false.
      beerule_api->db_save( IMPORTING e_errors_found = DATA(e_errors_found) ).
      IF e_errors_found IS NOT INITIAL.
        beerule_api->free( ).
        RAISE EXCEPTION TYPE /thkr/cx_psm_tools
          EXPORTING
            textid       = /thkr/cx_psm_tools=>beerl_no_commit
            bapiret2_tab = VALUE #( ( id = '/THKR/PSM_TOOLS' type = 'E' number = 006 message_v1 = CONV #( new_address ) ) ).
      ENDIF.
    ELSE.
      beerule_api->free( ).
    ENDIF.

  ENDMETHOD.


  METHOD set_beerules.

    DATA(except) = NEW /thkr/cx_psm_tools( ).
    LOOP AT beerules INTO DATA(beerule).
      TRY.
          me->set_beerule( beerule ).
          except->bapiret2_tab = VALUE #( BASE except->bapiret2_tab ( VALUE #( id = '/THKR/PSM_TOOLS' type = 'S' number = 007 message_v1 = condense( val = conv char255( beerule-address ) ) ) ) ).
        CATCH /thkr/cx_psm_tools INTO DATA(err).
          except->bapiret2_tab = VALUE #( BASE except->bapiret2_tab ( LINES OF err->bapiret2_tab  ) ).
      ENDTRY.
    ENDLOOP.
    IF  except->bapiret2_tab IS NOT INITIAL.
      RAISE EXCEPTION except.
    ENDIF.
  ENDMETHOD.


  METHOD set_rule_header.

    data(msg) = api->modify_object_roactstat( im_roactstat = beerule-roactstat im_address = address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = api msg = msg address = address ).
    ENDIF.
    msg = api->modify_object_updfilt( im_updfilt = beerule-updfilt im_address = address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = api msg = msg address = address ).
    ENDIF.
    msg = api->modify_object_calcrule( im_calcrule = beerule-calcrule im_address = address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = api msg = msg address = address ).
    ENDIF.
    msg = api->modify_object_manualcheckind( im_manualcheckind = beerule-manualcheckind im_address = address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = api msg = msg address = address ).
    ENDIF.
    msg = api->modify_object_bm_expendit_part( im_bm_expendit_part = beerule-bm_expendit_part im_address = address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = api msg = msg address = address ).
    ENDIF.
    msg = api->modify_object_bm_revenue_part( im_bm_revenue_part = beerule-bm_revenue_part im_address = address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = api msg = msg address = address ).
    ENDIF.
    msg = api->modify_object_rib_procedure( im_rib_procedure = beerule-rib_procedure im_address = address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = api msg = msg address = address ).
    ENDIF.
    msg = api->modify_object_resamntind( im_resamntind = beerule-resamntind im_address = address ).
    IF msg IS NOT INITIAL.
      me->call_exception( api = api msg = msg address = address ).
    ENDIF.

  ENDMETHOD.


  method CONSTRUCTOR.
    me->testmode = testmode.
  endmethod.
ENDCLASS.
