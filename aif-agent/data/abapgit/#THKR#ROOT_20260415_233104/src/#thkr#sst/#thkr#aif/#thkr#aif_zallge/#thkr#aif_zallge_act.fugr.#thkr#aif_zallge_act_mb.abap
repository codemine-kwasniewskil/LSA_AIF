*"----------------------------------------------------------------------
* Gereon Koks  TSI  14.11.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Mittelbindung"
*"----------------------------------------------------------------------
* Entwicklung ist erster Wurf.
* Noch nicht fertig entwickelt.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_mb .
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
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_MV
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  CONSTANTS: lc_ns_gp_for_mb TYPE /aif/ns VALUE 'ZALLGE'.
  CONSTANTS: lc_vmap_gp_for_mb TYPE /aif/vmapname VALUE 'MAP_GP_FOR_MB'.
  DATA: l_dto_psm_mv_create TYPE /thkr/s_dto_psm_mv_create,
        ls_aif_obj          TYPE /thkr/t_aif_obj.
*"----------------------------------------------------------------------
  TRY.
*"----------------------------------------------------------------------
      APPEND VALUE #( id         = 'KM'
                       number     = 418
                       type       = 'I'
                       message_v1 = '/THKR/AIF_ZALLGE_ACT_MB' ) TO return_tab.
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
      success = 'Y'.
      curr_line-mv_proc_status = 'E'.

* Wenn es den Geschäftspartner schon gibt und PARTNER daher gefüllt ist,
* muss man ihn hier nicht nochmal lesen.
* Wenn der Geschäftspartner neu angelegt wurde, muss die ID nachgelesen werden.
      TRY.
          "Lese nur den Geschäftspartner für eine allg. Anordnung oder Mittelbindung aus, wenn es vorgesehen ist.
          "Feld GB_FOR_MB = X -> Geschäftspartner gewüschnt. Also aus Struktur nachlesen sofern nicht schon im Mapping erfolgt
          "Feld GB_FOR_MB = <lee> -> Geschäftsparner nicht gewüschnt. Partner muss nicht identifiziert werden.
          IF curr_line-t_kont[ 1 ]-partner IS INITIAL and curr_line-GB_FOR_MB = abap_true.
            READ TABLE data-gp ASSIGNING FIELD-SYMBOL(<gp>) WITH KEY bu_bpext = curr_line-mv_bpext.

            IF sy-subrc <> 0.
              APPEND VALUE #( id         = '/CPD/SS_MESSAGES'
                              number     = 346
                              type       = 'E'
                              message_v1 = curr_line-mv_bpext ) TO return_tab.
              curr_line-mv_proc_status = 'E'.
              RETURN.
            ENDIF.

            curr_line-t_kont[ 1 ]-partner = <gp>-partner.
          ENDIF.
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      MOVE-CORRESPONDING curr_line TO l_dto_psm_mv_create.
      /thkr/cl_psm_mv_appl=>get_instance( )->create_psm_mv(
         EXPORTING
           i_dto_psm_mv_bel_create = l_dto_psm_mv_create
         IMPORTING
           e_kblnr                 = DATA(lv_blnr)               "Beleg Nummer zu AO
       ).
      curr_line-mv_proc_status = 'S'.
      curr_line-belnr = lv_blnr.
      IF curr_line-long_text-lines IS NOT INITIAL.
        "Hinzfügen des Schlüssels für Langtexte.
        "Belegnummer erst nach Buchung im System.
        curr_line-long_text-header-tdname = |{ sy-mandt }{ curr_line-belnr }000|.
      ENDIF.
      IF 1 = 0. MESSAGE s241(fkkorder) WITH lv_blnr. ENDIF.
      APPEND VALUE #( id         = 'FKKORDER'
                       number     = 241
                       type       = 'S'
                       message_v1 = lv_blnr ) TO return_tab.


    CATCH /thkr/cx_psm_int_fi INTO DATA(lxc_psm_mb).
      IF lxc_psm_mb->bapiret2_tab IS NOT INITIAL.
        APPEND LINES OF lxc_psm_mb->bapiret2_tab TO return_tab.
      ELSE.
        APPEND VALUE #( id         = lxc_psm_mb->if_t100_message~t100key-msgid
                        number     = lxc_psm_mb->if_t100_message~t100key-msgno
                        type       = lxc_psm_mb->if_t100_dyn_msg~msgty
                        message_v1 = lxc_psm_mb->if_t100_dyn_msg~msgv1
                        message_v2 = lxc_psm_mb->if_t100_dyn_msg~msgv2
                        message_v3 = lxc_psm_mb->if_t100_dyn_msg~msgv3
                        message_v4 = lxc_psm_mb->if_t100_dyn_msg~msgv4 ) TO return_tab.
      ENDIF.
      ls_aif_obj-status = 'E'.
      MODIFY /thkr/t_aif_obj FROM ls_aif_obj.
      success = 'N'.
  ENDTRY.
*----------------------------------------------------------------------
  curr_line-msg = return_tab[].
ENDFUNCTION.
*"----------------------------------------------------------------------
