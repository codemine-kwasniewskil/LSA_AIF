*"----------------------------------------------------------------------
* Gereon Koks  TSI  27.1.2025
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Stundung"
* Action für
* 06 Stundungsanordnung        =>	Neue AO mit Raten
* 07 Niederschlagungsanordnung => Alte AO bekommt Mahnsperre
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_stu .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_AO
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA:
    mo_cut             TYPE REF TO /thkr/cl_psm_ao_appl,
    ls_document_number TYPE /thkr/s_psm_ao_document_number,
*    ls_dto_psm_ao      TYPE /thkr/s_dto_psm_ao_bel_create,
    ls_dto_psm_stu     TYPE /thkr/s_dto_psm_ao_bel_create,
*    ls_dto_psm_stu_chg TYPE /thkr/s_dto_psm_ao_bel_change,
    ls_gp              TYPE /thkr/s_aif_sap_gp.
*"----------------------------------------------------------------------
  success = 'N'.
*"----------------------------------------------------------------------
  IF curr_line IS NOT INITIAL.
*"----------------------------------------------------------------------
    APPEND VALUE #( id         = 'KM'
                     number     = 418
                     type       = 'I'
                     message_v1 = '/THKR/AIF_ZALLGE_ACT_STU' ) TO return_tab.
*"----------------------------------------------------------------------
* Check if Actions are allowed.
    CALL FUNCTION '/THKR/AIF_ZALLGE_ACT_OFF'
      TABLES
        return_tab = return_tab
      EXCEPTIONS
        off        = 1
        OTHERS     = 2.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
*"----------------------------------------------------------------------
    TRY.
* Wenn der Geschäftspartner neu ist, wird PARTNER erst durch die Anlage
* des Geschäftspartner gefüllt.
* D.h.: Im Mapping ist er noch nicht vorhanden.
        curr_line-ao_proc_status = 'E'.
*"----------------------------------------------------------------------
        MOVE-CORRESPONDING curr_line TO ls_dto_psm_stu.
*"----------------------------------------------------------------------
        CASE ls_dto_psm_stu-psoty.
*"----------------------------------------------------------------------
* 06 Stundungsanordnung        =>	Neue AO mit Raten
          WHEN '06'.

            /thkr/cl_psm_ao_appl=>get_instance( )->create_due_date_deferral(
              EXPORTING
                i_dto_psm_ao_bel_create  = ls_dto_psm_stu
              IMPORTING
                e_psm_ao_document_number = ls_document_number ).

            APPEND VALUE #( id         = '/THKR/SST'
                             number     = 001
                             type       = 'I'
                             message_v1 = 'ACT_STU Stundung (neue BELNR:'
                             message_v2 = ls_document_number-belnr
                             message_v3 = ')' ) TO return_tab.

            curr_line-ao_proc_status = 'S'.

            APPEND VALUE #( id         = '/THKR/SST'
                            number     = 001
                            type       = 'I'
                            message_v1 = 'ACT_STU erfolgreich angelegt' ) TO return_tab.
*"----------------------------------------------------------------------
* 07 Niederschlagungsanordnung => Alte AO bekommt Mahnsperre
          WHEN '07'.
            APPEND VALUE #( id          = '/THKR/SST'
                             number     = 001
                             type       = 'I'
                             message_v1 = 'ACT_STU Niederschlagung (alte BELNR:'
                             message_v2 = ls_dto_psm_stu-belnr
                             message_v3 = ')' ) TO return_tab.

            DATA: ls_bseg     TYPE bseg,
                  lt_bseg     TYPE trty_bseg,
                  ls_bseg_old TYPE fbseg,
                  ls_bseg_new TYPE fbseg,
                  lt_bseg_old TYPE STANDARD TABLE OF fbseg,
                  lt_bseg_new TYPE STANDARD TABLE OF fbseg.

* BSEG lesen
            CALL FUNCTION 'READ_BSEG'
              EXPORTING
                xbelnr         = ls_dto_psm_stu-belnr
                xbukrs         = ls_dto_psm_stu-bukrs
                xbuzei         = '01'
                xgjahr         = ls_dto_psm_stu-gjahr
                no_auth_check  = 'X'
              IMPORTING
*               XBSEC          =
*               XBSED          =
                xbseg          = ls_bseg
*               XBSEGA         =
              EXCEPTIONS
                key_incomplete = 1
                not_authorized = 2
                not_found      = 3
                OTHERS         = 4.

* BSEG anpassen
            IF sy-subrc = 0.
              MOVE-CORRESPONDING ls_bseg TO ls_bseg_old.
              APPEND ls_bseg_old TO lt_bseg_old.

              ls_bseg-zfbdt = ls_dto_psm_stu-psodt.
              ls_bseg-mansp = ls_dto_psm_stu-mansp.

              MOVE-CORRESPONDING ls_bseg TO ls_bseg_new.
              APPEND ls_bseg_new TO lt_bseg_new.
            ENDIF.

            APPEND ls_bseg TO lt_bseg.

* BSEG schreiben
            CALL FUNCTION 'FVD_UPDATE_BSEG'
              EXPORTING
*               I_TAB_INSERT =
                i_tab_update = lt_bseg
*               I_TAB_DELETE =
              EXCEPTIONS
                error        = 1
                OTHERS       = 2.

* Änderungsbeleg
            DATA: lv_objectid TYPE cdobjectv,
                  lv_pos_upd  TYPE cdchngind VALUE 'U'.


            lv_objectid(3)    = sy-mandt.
            lv_objectid+3(4)  = ls_dto_psm_stu-bukrs.
            lv_objectid+7(10) = ls_dto_psm_stu-belnr.
            lv_objectid+17(4) = ls_dto_psm_stu-gjahr.

            CALL FUNCTION 'BELEG_WRITE_DOCUMENT'
              EXPORTING
                objectid = lv_objectid
                tcode    = 'FB02'
                utime    = sy-uzeit
                udate    = sy-datum
                username = sy-uname
*               n_bkpf   = ls_bkpf
*               o_bkpf   = ls_bkpf_old
*               upd_bkpf = lv_kopf_upd
                upd_bseg = lv_pos_upd
              TABLES
                xbseg    = lt_bseg_new
                ybseg    = lt_bseg_old.


            COMMIT WORK AND WAIT.

            IF sy-subrc = 0.
              APPEND VALUE #( id         = '/THKR/SST'
                              number     = 001
                              type       = 'I'
                              message_v1 = 'ACT_STU erfolgreich geändert' ) TO return_tab.
            ENDIF.
*"----------------------------------------------------------------------
          WHEN OTHERS.
*"----------------------------------------------------------------------
        ENDCASE.
*"----------------------------------------------------------------------
      CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_ao).
        IF lxc_ao->bapiret2_tab IS NOT INITIAL.
          APPEND LINES OF lxc_ao->bapiret2_tab TO return_tab.
        ELSE.
          APPEND VALUE #( id         = lxc_ao->if_t100_message~t100key-msgid
                          number     = lxc_ao->if_t100_message~t100key-msgno
                          type       = lxc_ao->if_t100_dyn_msg~msgty
                          message_v1 = lxc_ao->if_t100_dyn_msg~msgv1
                          message_v2 = lxc_ao->if_t100_dyn_msg~msgv2
                          message_v3 = lxc_ao->if_t100_dyn_msg~msgv3
                          message_v4 = lxc_ao->if_t100_dyn_msg~msgv4 ) TO return_tab.
        ENDIF.
    ENDTRY.
  ENDIF.
*"----------------------------------------------------------------------
  curr_line-msg = return_tab[].

  IF sy-subrc = 0.
    success = 'Y'.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
