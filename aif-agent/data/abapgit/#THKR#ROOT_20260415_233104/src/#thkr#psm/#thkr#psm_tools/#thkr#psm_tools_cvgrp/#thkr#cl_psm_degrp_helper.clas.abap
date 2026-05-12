class /THKR/CL_PSM_DEGRP_HELPER definition
  public
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !TESTMODE type XFLAG default ABAP_TRUE .
  methods SET_COVERGRP
    importing
      !CVGRP_DATA type /THKR/PSM_DECKGRP_TRANSFER
    raising
      /THKR/CX_PSM_TOOLS .
  methods GET_COVERGRP
    importing
      !FM_AREA type FIKRS default '1000'
      !FISCYEAR type GJAHR
      !LEDGER type BUBAS_LDNR
      !CVGRP type FMCE_CVRGRP
      !IT_SO_CGADDRIND type ANY TABLE
    returning
      value(CVGRP_DATA) type /THKR/PSM_DECKGRP_TRANSFER
    raising
      /THKR/CX_PSM_TOOLS .
  methods GET_ALL_COVERGRPS
    importing
      !IT_SO_CGADDRIND type ANY TABLE
      !CVGRP_TYPE type FMCE_CGAUTOIND
    returning
      value(CVGRPS) type /THKR/PSM_DECKGRPS_TRANSFER
    raising
      /THKR/CX_PSM_TOOLS .
  methods SET_COVERGRPS
    importing
      value(CVGRPS) type /THKR/PSM_DECKGRPS_TRANSFER
    raising
      /THKR/CX_PSM_TOOLS .
protected section.

  data TESTMODE type XFLAG .

  methods ADJUST_ASSIGNED_ADDRESS
    changing
      !ASSIGNED_ADDRESS type FMCE_T_ASSIGNED_ADDRESS .
private section.
ENDCLASS.



CLASS /THKR/CL_PSM_DEGRP_HELPER IMPLEMENTATION.


  method CONSTRUCTOR.
    me->testmode = testmode.
  endmethod.


  METHOD get_all_covergrps.

    SELECT FROM fmcecvgrp
      FIELDS fm_area
            ,fiscyear
            ,budcat
            ,cvrgrp
      WHERE cgautoind = @cvgrp_type
      INTO TABLE @DATA(cvgrp_keys).

    LOOP AT cvgrp_keys INTO DATA(cvgrp_key).
      DATA(cvgrp) = me->get_covergrp( fm_area         = cvgrp_key-fm_area
                                      fiscyear        = cvgrp_key-fiscyear
                                      ledger          = cvgrp_key-budcat
                                      cvgrp           = cvgrp_key-cvrgrp
                                      it_so_cgaddrind = it_so_cgaddrind ).
      APPEND cvgrp TO cvgrps.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_covergrp.

    DATA(cvgrp_api) = NEW cl_fmce_cvgrp_list( im_fm_area = fm_area im_fiscyear = fiscyear ).
    cvgrp_api->set_ldnr( ledger ).
    cvgrp_api->refresh_list( ).
    cvgrp_api->db_read_with_objsel( im_cvrgrp = cvgrp im_read_addresses = abap_true ).

    cvgrp_data = VALUE #( fm_area = fm_area fiscyear = fiscyear ledger = ledger cvgrp = cvgrp ).

    cvgrp_api->read_object_cg_data(
      EXPORTING
        i_cvrgrp                  = cvgrp
      IMPORTING
        e_cgtext                  = cvgrp_data-cgtext
        e_cgautoind               = cvgrp_data-cgautoind
        e_aldnr                   = cvgrp_data-aldnr
        e_bm_receiver             = cvgrp_data-bm_receiver
        e_bm_sender               = cvgrp_data-bm_sender
        e_bm_rec_and_sen          = cvgrp_data-bm_rec_and_sen
        e_other_address_objnr     = cvgrp_data-other_addr_objnr
        e_other_address_grant_nbr = cvgrp_data-other_addr_grant_nbr
        e_authgrp                 = cvgrp_data-authgrp
        e_cgwithgrant             = cvgrp_data-cgwithgrant
      EXCEPTIONS
        object_not_in_list        = 1                         " Selektierte Deckungsgruppe ist nicht in der Liste
    ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_tools EXPORTING textid = /thkr/cx_psm_tools=>cvgrp_not_found msgv1 = CONV #( cvgrp ).
    ENDIF.

    cvgrp_api->read_object_cg_member(
      EXPORTING
        i_cvrgrp             = cvgrp
      IMPORTING
        e_t_assigned_address = cvgrp_data-t_assigned_address
      EXCEPTIONS
        object_not_in_list   = 1
        no_recs              = 2
    ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_tools EXPORTING textid = /thkr/cx_psm_tools=>cvgrp_not_found msgv1 = CONV #( cvgrp ).
    ELSE.
      "Löschung von Kontierungsrollen, die nicht relevant sind.
      "Es gibt Probleme beim Import von Deckungsgruppen die die Kontierungsrolle C ( Beitragende BeE-Regel ) haben
      "bei denen die BeE-Regel aber noch nicht im Zielsystem ist.
      "Da erst die Deckungsgruppen importiert werden, müssen diese Fälle rausgelöscht werden.
      DELETE cvgrp_data-t_assigned_address
      WHERE cgaddrind NOT IN it_so_cgaddrind.
    ENDIF.

  ENDMETHOD.


  METHOD set_covergrp.
    DATA: msg TYPE bubas_s_msgs.
    DATA(cvgrp_api) = NEW cl_fmce_cvgrp_list( im_fm_area = cvgrp_data-fm_area im_fiscyear = cvgrp_data-fiscyear ).


    cvgrp_api->set_ldnr( cvgrp_data-ledger ).

    cvgrp_api->add_new_object(
      EXPORTING
        im_cvrgrp            = space
        im_flg_generate_md   = abap_false
        im_flg_get_cg_number = abap_true
        im_aldnr             = cvgrp_data-aldnr
        im_rbbldnr           = cvgrp_data-rbbldnr
        im_cgautoind         = cvgrp_data-cgautoind
      IMPORTING
        e_msg                = msg
        ex_cvrgrp            = DATA(new_cvrgrp)
    ).
    "msg initial reicht nicht aus.
    "Warnmeldunge würden die Anlage der Deckungsgruppe verhindern.
*    IF msg IS NOT INITIAL.
    IF msg-msgty = 'E' OR msg-msgty = 'A' OR msg-msgty = 'X'.
      cvgrp_api->free( ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_tools
        EXPORTING
          textid       = /thkr/cx_psm_tools=>cvgrp_not_created
          msgv1        = CONV #( cvgrp_data-cvgrp )
          bapiret2_tab = VALUE #( ( id = '/THKR/PSM_TOOLS' type = 'E'       number = 02        message_v1 = cvgrp_data-cvgrp )
                                  ( id = msg-msgid         type = msg-msgty number = msg-msgno message_v1 = msg-msgv1 message_v2 = msg-msgv2 message_v3 = msg-msgv3 message_v4 = msg-msgv4 ) ).
    ENDIF.
    cvgrp_api->modify_object_cgautoind(
      EXPORTING
        im_cvrgrp         = new_cvrgrp
        im_cgtext         = cvgrp_data-cgtext
        im_cgautoind      = cvgrp_data-cgautoind
        im_aldnr          = cvgrp_data-aldnr
        im_bm_receiver    = cvgrp_data-bm_receiver
        im_bm_sender      = cvgrp_data-bm_sender
        im_bm_rec_and_sen = cvgrp_data-bm_rec_and_sen
*       im_do_not_block_missing_bm = off
        im_rbbldnr        = cvgrp_data-rbbldnr
        im_authgrp        = cvgrp_data-authgrp
        im_cgwithgrant    = cvgrp_data-cgwithgrant
      IMPORTING
        r_msg             = msg
    ).

    "Warnmeldunge würden die Anlage der Deckungsgruppe verhindern.
    IF msg-msgty = 'E' OR msg-msgty = 'A' OR msg-msgty = 'X'.
      cvgrp_api->free( ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_tools
        EXPORTING
          textid       = /thkr/cx_psm_tools=>cvgrp_not_created
          msgv1        = CONV #( cvgrp_data-cvgrp )
          bapiret2_tab = VALUE #( ( id = '/THKR/PSM_TOOLS' type = 'E'       number = 02        message_v1 = cvgrp_data-cvgrp )
                                  ( id = msg-msgid         type = msg-msgty number = msg-msgno message_v1 = msg-msgv1 message_v2 = msg-msgv2 message_v3 = msg-msgv3 message_v4 = msg-msgv4 ) ).
    ENDIF.

    data(assigned_addresses) = cvgrp_data-t_assigned_address.
    me->adjust_assigned_address( CHANGING assigned_address = assigned_addresses ).

    msg = cvgrp_api->modify_object_all_members( im_t_assigned_address = assigned_addresses  im_cvrgrp = new_cvrgrp ).

    "Warnmeldunge würden die Anlage der Deckungsgruppe verhindern.
    IF msg-msgty = 'E' OR msg-msgty = 'A' OR msg-msgty = 'X'.
      cvgrp_api->free( ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_tools
        EXPORTING
          textid       = /thkr/cx_psm_tools=>cvgrp_not_created
          msgv1        = CONV #( cvgrp_data-cvgrp )
          bapiret2_tab = VALUE #( ( id = '/THKR/PSM_TOOLS' type = 'E'       number = 02        message_v1 = cvgrp_data-cvgrp )
                                  ( id = msg-msgid         type = msg-msgty number = msg-msgno message_v1 = msg-msgv1 message_v2 = msg-msgv2 message_v3 = msg-msgv3 message_v4 = msg-msgv4 ) ).
    ENDIF.

    "Warnmeldunge würden die Anlage der Deckungsgruppe verhindern.
    if ( msg-msgty <> 'E' OR msg-msgty <> 'A' or msg-msgty <> 'X' ) AND me->testmode = abap_false.
      cvgrp_api->db_save( IMPORTING e_errors_found = DATA(e_errors_found) ).
      IF e_errors_found IS NOT INITIAL.
        cvgrp_api->free( ).
        RAISE EXCEPTION TYPE /thkr/cx_psm_tools
          EXPORTING
            textid       = /thkr/cx_psm_tools=>cvgrp_no_commit
            msgv1        = CONV #( cvgrp_data-cvgrp )
            bapiret2_tab = VALUE #( ( id = '/THKR/PSM_TOOLS' type = 'E' number = 003 message_v1 = cvgrp_data-cvgrp ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD set_covergrps.

    DATA(except) = NEW /thkr/cx_psm_tools( ).
    LOOP AT cvgrps INTO DATA(cvgrp).
      TRY.
          me->set_covergrp( cvgrp ).
          except->bapiret2_tab = VALUE #( BASE except->bapiret2_tab ( VALUE #( id = '/THKR/PSM_TOOLS' type = 'S' number = 008 message_v1 = cvgrp-cvgrp ) ) ).
        CATCH /thkr/cx_psm_tools INTO DATA(err).
          except->bapiret2_tab = VALUE #( BASE except->bapiret2_tab ( LINES OF err->bapiret2_tab  ) ).
      ENDTRY.
    ENDLOOP.
    IF  except->bapiret2_tab IS NOT INITIAL.
      RAISE EXCEPTION except.
    ENDIF.
  ENDMETHOD.


  METHOD adjust_assigned_address.

    LOOP AT assigned_address ASSIGNING FIELD-SYMBOL(<line>) WHERE rev_cvrgrp IS NOT INITIAL.
      SELECT SINGLE FROM fmcecgaddrs AS a
        INNER JOIN fmbasobjnr AS o ON o~objnr = a~addrobjnr
        FIELDS a~cvrgrp
        WHERE o~fund = @<line>-address-fund
          AND o~fundsctr = @<line>-address-fundsctr
          AND o~cmmtitem = @<line>-address-cmmtitem
          AND o~funcarea = @<line>-address-funcarea
          AND o~measure  = @<line>-address-measure
          AND a~cgaddrind = 'A'
        INTO @<line>-rev_cvrgrp.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
