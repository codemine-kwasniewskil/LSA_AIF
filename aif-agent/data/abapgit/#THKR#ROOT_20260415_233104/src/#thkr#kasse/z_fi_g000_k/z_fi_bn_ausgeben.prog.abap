*&---------------------------------------------------------------------*
*& Report Z_FI_BN_AUSGEBEN
*&---------------------------------------------------------------------*
*& Benachrichtigungen versenden
*&---------------------------------------------------------------------*

INCLUDE z_fi_bn_ausgeben_top                    .    " Global Data

* INCLUDE Z_FI_BN_AUSGEBEN_O01                    .  " PBO-Modules
* INCLUDE Z_FI_BN_AUSGEBEN_I01                    .  " PAI-Modules
* INCLUDE Z_FI_BN_AUSGEBEN_F01                    .  " FORM-Routines

************************************************************************
START-OF-SELECTION.
************************************************************************

  DATA: l_bn_selection TYPE zfi_f_bn_selection,
        lo_nachrichten TYPE REF TO zcl_fi_bn_nachrichten,
        lo_oerror      TYPE REF TO cx_root,
        l_message      TYPE string,
        l_tdto_nachr   TYPE zfi_t_dto_nachr,
        l_dto_nachr    TYPE zfi_f_dto_nachr,
        l_error        TYPE syst_subrc,
        l_kz_send      TYPE xfeld,
        l_anzbn        TYPE i,
        lt_data_ref    TYPE REF TO data.

  FIELD-SYMBOLS: <nachr> TYPE zfi_f_dto_nachr.

* Berechtigung
  DATA: lv_fm_fmfctr_authgrp TYPE fm_authgrc,    "Finanzstelle
        lv_subrc             TYPE n.             "Subrc

* Selektionsstruktur füllen
  l_bn_selection-herk    = p_herk.
  l_bn_selection-r_fnr   = s_fnr[].
  l_bn_selection-r_erfd  = s_erfd[].
  l_bn_selection-r_uname = s_unam[].
  l_bn_selection-aktiv = 'X'.
  l_bn_selection-inaktiv = ' '.
  IF p_herk = 'Z'.
    l_bn_selection-laufd   = p_laufd.
    l_bn_selection-laufi   = p_laufi.
    l_bn_selection-zbukr   = p_zbukr.
    l_bn_selection-versdat_i = 'X'.
  ENDIF.
  IF p_herk = 'A'.
    l_bn_selection-hbkid   = p_hbkid.
    l_bn_selection-hktid   = p_hktid.
    l_bn_selection-kukey   = p_kukey.
    l_bn_selection-esnum   = p_esnum.
    l_bn_selection-vgext   = p_vgext.
    l_bn_selection-versdat_i = 'X'.
  ENDIF.
  IF p_herk = 'R'.
    l_bn_selection-hbkid   = p_hbkid.
    l_bn_selection-hktid   = p_hktid.
    l_bn_selection-kukey   = p_kukey.
    l_bn_selection-esnum   = p_esnum.
    l_bn_selection-vgext   = p_vgext.
    l_bn_selection-versdat_i = 'X'.
  ENDIF.
  IF p_herk = 'Y'.
    l_bn_selection-kukey   = p_kukey.
    l_bn_selection-esnum   = p_esnum.
    l_bn_selection-r_fistl = s_fistl[].
    l_bn_selection-r_blart = s_blart[].
    l_bn_selection-r_fipos = s_fipos[].
    l_bn_selection-versdat_i = 'X'.
  ENDIF.
* Zu benachrichtigende Objekte lesen
  zcl_fi_bn_nachrichten=>get_instance( )->get_tdto_nachr(
    EXPORTING
      i_selection = l_bn_selection
    IMPORTING
     e_tdto      = l_tdto_nachr ).

  IF p_test <> 'X'.

    LOOP AT l_tdto_nachr ASSIGNING <nachr>.

* Berechtigungsprüfung
      lv_fm_fmfctr_authgrp = <nachr>-fistl.    "Finanzstelle

      IF 1 = 2.
        AUTHORITY-CHECK OBJECT 'Z_FICA_TRG'
          ID 'FM_AUTHACT' FIELD gc_auth_activ
          ID 'FM_FIKRS'   FIELD gc_fikrs
          ID 'FM_AUTHGRF' DUMMY
          ID 'FM_AUTHGRC' FIELD lv_fm_fmfctr_authgrp
          ID 'FM_AUTHGRP' DUMMY
          ID 'FM_AUTHGRM' DUMMY
          ID 'FM_GRP_FAR' DUMMY.
      ENDIF.

      CALL FUNCTION 'Z_CHECK_FICA_TRG'
        EXPORTING
          activity          = gc_auth_activ     "aktuell auf 03
          fm_area           = gc_fikrs          "1000
          fm_fmfctr_authgrp = lv_fm_fmfctr_authgrp
*         fm_fipex_authgrp  = lv_fm_fipex_authgrp
*         FM_MEASURE_AUTHGRP       = LS_AUTH_GRP_HHP
*         FM_FAREA_AUTHGRP  =
        IMPORTING
          ex_subrc          = lv_subrc.
      IF lv_subrc <> 0.
        MESSAGE i028 WITH <nachr>-belnr.
        CONTINUE.
      ELSE.
        AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
            ID 'ACTVT' FIELD gc_auth_activ
            ID 'BUKRS' FIELD <nachr>-bukrs.
        IF sy-subrc NE 0.
          MESSAGE i028 WITH <nachr>-belnr.
          CONTINUE.
        ENDIF.
      ENDIF.


* E-Mails/Mails an SBWP versenden
      TRY.

          IF <nachr>-fistl IS INITIAL.
            CONTINUE.
          ENDIF.

*       Kann Nachricht erneut gesendet werden?
          zcl_fi_bn_nachrichten=>get_instance( )->get_dupl_nachr(
            EXPORTING
              i_nachr = <nachr>
            IMPORTING
              e_kz_send = l_kz_send ).

          IF l_kz_send IS INITIAL.
            CONTINUE.
          ENDIF.

*       Benachrichtigung als e-Mail / SAP WP
          zcl_fi_bn_nachrichten=>get_instance( )->mail_versenden(
            EXPORTING
              i_nachr = <nachr>
            IMPORTING
              e_nachr = <nachr>
              e_error = l_error ).

          IF l_error = 0 AND <nachr>-versdat IS NOT INITIAL.
            zcl_fi_bn_nachrichten=>get_instance( )->modify_nachricht(
              EXPORTING
                i_nachr = <nachr> ).
          ENDIF.

          IF <nachr>-kzbnart <> 'D' AND <nachr>-kzbnart IS NOT INITIAL.
            CONTINUE.
          ENDIF.

*       Benachrichtigung als PDF-Datei auf Apllikationsserver ablegen
          IF p_herk = 'Y'.
            zcl_fi_bn_nachrichten=>get_instance( )->create_za_pdf(
              EXPORTING
                i_nachr = <nachr>
              IMPORTING
               e_nachr = <nachr> ).

            zcl_fi_bn_nachrichten=>get_instance( )->modify_nachricht(
              EXPORTING
                i_nachr = <nachr> ).
          ELSE.
            zcl_fi_bn_nachrichten=>get_instance( )->create_pdf(
              EXPORTING
                i_nachr = <nachr>
              IMPORTING
               e_nachr = <nachr> ).
            IF <nachr>-kzbnart = 'D' AND <nachr>-versdat IS NOT INITIAL.

              zcl_fi_bn_nachrichten=>get_instance( )->write_pdf(
                EXPORTING
                  i_nachr  = <nachr>
                IMPORTING
                  e_nachr = <nachr> ).

              zcl_fi_bn_nachrichten=>get_instance( )->modify_nachricht(
                EXPORTING
                  i_nachr = <nachr> ).
            ENDIF.
          ENDIF.
        CATCH zcx_fi_gen INTO lo_oerror.
          l_message = lo_oerror->get_text( ).
          MESSAGE e002 WITH l_message.
      ENDTRY.

    ENDLOOP.
  ENDIF.

* Protokoll ausgeben
  IF p_prot = 'X' AND p_test <> 'X'.

    zcl_fi_bn_nachrichten=>get_instance( )->display_prot(
        EXPORTING
          i_herk  = p_herk
        IMPORTING
          e_anzbn = l_anzbn ).

    IF sy-batch IS INITIAL.
      IF l_anzbn = 0.
        MESSAGE i024 WITH 'keine'.
      ELSE.
        MESSAGE i024 WITH l_anzbn.
      ENDIF.
    ENDIF.
  ENDIF.

* Testlauf und Liste der zu sendenden Benachrichtigungen
  IF p_test = 'X'.

    GET REFERENCE OF l_tdto_nachr INTO lt_data_ref.

    zcl_fi_bn_nachrichten=>get_instance( )->display_prot(
        EXPORTING
          i_herk       = p_herk
          i_t_data_ref = lt_data_ref
        IMPORTING
          e_anzbn = l_anzbn ).

    IF sy-batch IS INITIAL.
      IF l_anzbn = 0.
        MESSAGE i025 WITH 'keine'.
      ELSE.
        MESSAGE i025 WITH l_anzbn.
      ENDIF.
    ENDIF.
  ENDIF.
