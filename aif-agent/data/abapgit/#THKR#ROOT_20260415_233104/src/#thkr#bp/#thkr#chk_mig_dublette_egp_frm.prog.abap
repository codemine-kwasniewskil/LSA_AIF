*&---------------------------------------------------------------------*
*& Include          /THKR/CHK_MIG_DUBLETTE_EGP_FRM                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& FRM-Include für Formroutinen                                        *
*& Prüfung von Z001 - Einmal-GP zur Archivierung                       *
*& Prüfung von Z009 - MIG-Einmal-GP und Dubletten                      *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        27.02.2026                                            *
*&                                                                     *
*& l. Änderung:  13.04.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form load_but                                                       *
*&---------------------------------------------------------------------*
*& Laden der Daten aus BUT000                                          *
*&---------------------------------------------------------------------*
FORM load_but.
************************************************************************
* Lokale Strukturen                                                    *
************************************************************************
  DATA: ls_but000 TYPE but000,
        lv_strmsg TYPE string,
        lv_max    TYPE i,
        lv_anz    TYPE i,
        lv_canz   TYPE numc08.

************************************************************************
* Initialisierung Interne Tabelle                                      *
************************************************************************
  CLEAR gt_dbbut[].

************************************************************************
* Selektion nach Parametereingaben                                     *
************************************************************************
  IF NOT p_z001 IS INITIAL.
    IF sy-batch IS INITIAL.
      WRITE: /5 sy-datum, ' ', sy-uzeit, ' BUT000 - Z0001'.
    ELSE.
      CONCATENATE sy-datum ' ' sy-uzeit ' BUT000 - Z0001' INTO lv_strmsg RESPECTING BLANKS.
      MESSAGE lv_strmsg TYPE 'S'."
    ENDIF.

    IF sy-batch IS INITIAL.
      SELECT partner,   type,      bpkind,
             bpext,     bu_sort1,  /thkr/gsber,
             /thkr/sst, name_last, name_first,
             name_org1, name_org2, partner_guid
          FROM but000 AS bp
            WHERE bp~bu_group EQ '0001'
            AND   bp~xdele IS INITIAL
            APPENDING CORRESPONDING FIELDS OF TABLE @gt_dbbut
          UP TO @p_max ROWS.
    ELSE.
      SELECT partner,   type,      bpkind,
             bpext,     bu_sort1,  /thkr/gsber,
             /thkr/sst, name_last, name_first,
             name_org1, name_org2, partner_guid
          FROM but000 AS bp
            WHERE bp~bu_group EQ '0001'
            AND   bp~xdele IS INITIAL
            APPENDING CORRESPONDING FIELDS OF TABLE @gt_dbbut.
    ENDIF.

    lv_anz = lines( gt_dbbut ).
    MOVE lv_anz TO lv_canz.
    IF sy-batch IS INITIAL.
      WRITE: /5 'Z001 - Anzahl: ', lv_canz.
    ELSE.
      CONCATENATE 'Z001 - Anzahl: ' lv_canz INTO lv_strmsg RESPECTING BLANKS.
      MESSAGE lv_strmsg TYPE 'S'."
    ENDIF.
  ENDIF.

  IF NOT p_z009 IS INITIAL.
    IF sy-batch IS INITIAL.
      WRITE: /5 sy-datum, ' ', sy-uzeit, ' BUT000 - Z0009'.
    ELSE.
      CONCATENATE sy-datum ' ' sy-uzeit ' BUT000 - Z0009' INTO lv_strmsg RESPECTING BLANKS.
      MESSAGE lv_strmsg TYPE 'S'."
    ENDIF.

    IF sy-batch IS INITIAL.
      lv_max = p_max - lines( gt_dbbut ).
      IF lv_max GT 0.
        SELECT partner,   type,      bpkind,
               bpext,     bu_sort1,  /thkr/gsber,
               /thkr/sst, name_last, name_first,
               name_org1, name_org2, partner_guid
            FROM but000 AS bp
              WHERE bp~bu_group EQ '0009'
              AND   bp~xdele IS INITIAL
              APPENDING CORRESPONDING FIELDS OF TABLE @gt_dbbut
            UP TO @lv_max ROWS.
      ENDIF.
    ELSE.
      SELECT partner,   type,      bpkind,
         bpext,     bu_sort1,  /thkr/gsber,
         /thkr/sst, name_last, name_first,
         name_org1, name_org2, partner_guid
      FROM but000 AS bp
        WHERE bp~bu_group EQ '0009'
        AND   bp~xdele IS INITIAL
        APPENDING CORRESPONDING FIELDS OF TABLE @gt_dbbut.
    ENDIF.

    lv_anz = lines( gt_dbbut ).
    MOVE lv_anz TO lv_canz.
    IF sy-batch IS INITIAL.
      IF NOT p_z001 IS INITIAL.
        WRITE: /5 'Gesamt - Anzahl: ', lv_canz.
      ELSE.
        WRITE: /5 'Z009 - Anzahl: ', lv_canz.
      ENDIF.
    ELSE.
      IF NOT p_z001 IS INITIAL.
        CONCATENATE 'Gesamt - Anzahl: ' lv_canz INTO lv_strmsg RESPECTING BLANKS.
        MESSAGE lv_strmsg TYPE 'S'."
      ELSE.
        CONCATENATE 'Z009 - Anzahl: ' lv_canz INTO lv_strmsg RESPECTING BLANKS.
        MESSAGE lv_strmsg TYPE 'S'."
      ENDIF.
    ENDIF.
  ENDIF.

  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' LOOP GT_DBBUT START'.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' LOOP GT_DBBUT START' INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.
  LOOP AT gt_dbbut ASSIGNING <gfs_dbbut> WHERE type NE 1.
    <gfs_dbbut>-name_last  = <gfs_dbbut>-name_org1.
    <gfs_dbbut>-name_first = <gfs_dbbut>-name_org2.
  ENDLOOP.
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' LOOP GT_DBBUT ENDE'.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' LOOP GT_DBBUT ENDE' INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_dauer_belege                                             *
*&---------------------------------------------------------------------*
*& Geladene - Geschäftspartner auf Dauer-Anordnungen usw. prüfen"      *
*& Sind Belege vorhanden, dann den Geschäftspartner nicht sperren      *
*&---------------------------------------------------------------------*
FORM check_dauer_belege.
************************************************************************
* Lokale Variable                                                      *
************************************************************************
  DATA: lv_kunnr  TYPE kunnr,
        lv_lifnr  TYPE lifnr,
        lv_belnr  TYPE kblnr,
        lv_strmsg TYPE string,
        lv_anz    TYPE i,
        lv_canz   TYPE numc08,
        lv_fexec  TYPE fexec.

************************************************************************
* Offene Posten                                                        *
************************************************************************
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' LOOP BSID / BSIK START'.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' LOOP BSID / BSIK START' INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.

  lv_anz = lines( gt_dbbut ).
  MOVE lv_anz TO lv_canz.
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' Anzahl DBBUT (BSI*) ', lv_canz.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' Anzahl DBBUT (BSI*) ' lv_canz
                INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.
  LOOP AT gt_dbbut ASSIGNING <gfs_dbbut> WHERE not_avail IS INITIAL.
************************************************************************
*   Offene Posten - Debitoren                                          *
************************************************************************
    SELECT SINGLE kunnr FROM bsid_view INTO @lv_kunnr
                       WHERE kunnr = @<gfs_dbbut>-partner.
    IF 0 EQ sy-subrc.
      MOVE 'X' TO <gfs_dbbut>-not_avail.
    ELSE.
************************************************************************
*     Offene Posten - Kreditoren                                       *
************************************************************************
      SELECT SINGLE lifnr FROM bsik_view INTO @lv_lifnr
                         WHERE lifnr = @<gfs_dbbut>-partner.
      IF 0 EQ sy-subrc.
        MOVE 'X' TO <gfs_dbbut>-not_avail.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' LOOP BSID / BSIK ENDE'.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' LOOP BSID / BSIK ENDE' INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.
  DELETE gt_dbbut WHERE not_avail EQ 'X'.

************************************************************************
* Offene Posten - Kreditoren                                           *
************************************************************************
*  IF sy-batch IS INITIAL.
*    WRITE: /5 sy-datum, ' ', sy-uzeit, ' LOOP BSIK START'.
*  ELSE.
*    CONCATENATE sy-datum ' ' sy-uzeit ' LOOP BSIK START' INTO lv_strmsg RESPECTING BLANKS.
*    MESSAGE lv_strmsg TYPE 'S'."
*  ENDIF.
*  LOOP AT gt_dbbut ASSIGNING <gfs_dbbut> WHERE not_avail IS INITIAL.
*    SELECT SINGLE lifnr FROM bsik_view INTO @lv_lifnr
*                       WHERE lifnr = @<gfs_dbbut>-partner.
*    IF 0 EQ sy-subrc.
*      MOVE 'X' TO <gfs_dbbut>-not_avail.
*    ENDIF.
*  ENDLOOP.
*  IF sy-batch IS INITIAL.
*    WRITE: /5 sy-datum, ' ', sy-uzeit, ' LOOP BSIK ENDE'.
*  ELSE.
*    CONCATENATE sy-datum ' ' sy-uzeit ' LOOP BSIK ENDE' INTO lv_strmsg RESPECTING BLANKS.
*    MESSAGE lv_strmsg TYPE 'S'."
*  ENDIF.
*
*  DELETE gt_dbbut WHERE not_avail EQ 'X'.

************************************************************************
* Dauer-Belege - Debitoren / Kreditoren                                *
************************************************************************
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' LOOP PSOSEGD / PSOSEGK START'.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' LOOP PSOSEGD / PSOSEGK START'
                INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.

  lv_anz = lines( gt_dbbut ).
  MOVE lv_anz TO lv_canz.
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' Anzahl DBBUT (PSOSEG*) ', lv_canz.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' Anzahl DBBUT (PSOSEG*) ' lv_canz
                INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.

  LOOP AT gt_dbbut ASSIGNING <gfs_dbbut> WHERE not_avail IS INITIAL.
    SELECT SINGLE kunnr FROM psosegd INTO lv_kunnr
                       WHERE kunnr = <gfs_dbbut>-partner.
    IF 0 EQ sy-subrc.
      MOVE 'X' TO <gfs_dbbut>-not_avail.
    ELSE.
      SELECT SINGLE lifnr FROM psosegk INTO lv_lifnr
                         WHERE lifnr = <gfs_dbbut>-partner.
      IF 0 EQ sy-subrc.
        MOVE 'X' TO <gfs_dbbut>-not_avail.
      ENDIF.
    ENDIF.
  ENDLOOP.
  DELETE gt_dbbut WHERE not_avail EQ 'X'.

************************************************************************
* Dauer-Belege - Kreditoren                                            *
************************************************************************
*  LOOP AT gt_dbbut ASSIGNING <gfs_dbbut> WHERE not_avail IS INITIAL.
*    SELECT SINGLE lifnr FROM psosegk INTO lv_lifnr
*                       WHERE lifnr = <gfs_dbbut>-partner.
*    IF 0 EQ sy-subrc.
*      MOVE 'X' TO <gfs_dbbut>-not_avail.
*    ENDIF.
*  ENDLOOP.
*  DELETE gt_dbbut WHERE not_avail EQ 'X'.

************************************************************************
* offene Annahme Anordnungen                                           *
************************************************************************
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' LOOP KBLK / KBLP START'.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' LOOP KBLK / KBLP START'
                INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.

  lv_anz = lines( gt_dbbut ).
  MOVE lv_anz TO lv_canz.
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' Anzahl DBBUT (KBL*) ', lv_canz.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' Anzahl DBBUT (KBL*) ' lv_canz
                INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.

  LOOP AT gt_dbbut ASSIGNING <gfs_dbbut> WHERE not_avail IS INITIAL.
    SELECT SINGLE belnr FROM kblp INTO lv_belnr
                       WHERE ( lifnr = <gfs_dbbut>-partner OR
                               kunnr = <gfs_dbbut>-partner ).
    IF 0 EQ sy-subrc.
      SELECT SINGLE fexec FROM kblk
                         WHERE belnr EQ @lv_belnr
                         AND   blart IN @so_blart
                         AND   fexec IS INITIAL
                     INTO @lv_fexec.
      IF 0 EQ sy-subrc.
        MOVE 'X' TO <gfs_dbbut>-not_avail.
      ENDIF.
    ENDIF.
  ENDLOOP.
  DELETE gt_dbbut WHERE not_avail EQ 'X'.

  lv_anz = lines( gt_dbbut ).
  MOVE lv_anz TO lv_canz.
  IF sy-batch IS INITIAL.
    WRITE: /5 sy-datum, ' ', sy-uzeit, ' Anzahl DBBUT UPDATE ', lv_canz.
  ELSE.
    CONCATENATE sy-datum ' ' sy-uzeit ' Anzahl DBBUT UPDATE ' lv_canz
                INTO lv_strmsg RESPECTING BLANKS.
    MESSAGE lv_strmsg TYPE 'S'."
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_xdele                                                      *
*&---------------------------------------------------------------------*
*& Setzen der Felds XDELE für ausgewählte GP's                         *
*&---------------------------------------------------------------------*
*&      --> GS_DBBUT - gekürzte GP-Struktur                            *
*&---------------------------------------------------------------------*
FORM set_xdele  USING    ps_dbbut TYPE ty_dbbut.
************************************************************************
* Lokale Strukturen                                                    *
************************************************************************
  DATA: ls_partner_data TYPE cvis_ei_extern.

************************************************************************
* Lokale Tabellentypen                                                 *
************************************************************************
  DATA: lt_partner_data TYPE cvis_ei_extern_t.

************************************************************************
* Initialisierung                                                      *
************************************************************************
  CLEAR ls_partner_data.
  ls_partner_data-partner-header-object_instance-bpartner     = ps_dbbut-partner.
  ls_partner_data-partner-header-object_instance-bpartnerguid = ps_dbbut-partner_guid.
  ls_partner_data-partner-header-object_task                  = 'U'.

  ls_partner_data-partner-central_data-common-data-bp_centraldata-centralarchivingflag  = abap_true.
  ls_partner_data-partner-central_data-common-datax-bp_centraldata-centralarchivingflag = abap_true.

  cl_md_bp_maintain=>validate_single(
    EXPORTING
      i_data        = ls_partner_data
    IMPORTING
      et_return_map = DATA(lt_return_map) ).
  IF line_exists( lt_return_map[ type = 'E' ] ) OR line_exists( lt_return_map[ type = 'A' ] ).


    LOOP AT lt_return_map ASSIGNING FIELD-SYMBOL(<fs_return_map>)
      WHERE type = 'E' OR type = 'A'.

      MESSAGE <fs_return_map>-message TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDLOOP.
  ELSE.
    APPEND ls_partner_data TO lt_partner_data.
    cl_md_bp_maintain=>maintain(
      EXPORTING
        i_data   = lt_partner_data
      IMPORTING
        e_return = DATA(lt_return)
    ).

    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ 1 ]-object_msg[ type = 'E' ] ).
      IF sy-batch IS INITIAL.
        WRITE: /5 lt_return[ 1 ]-object_msg[ 1 ]-message.
      ELSE.
        MESSAGE lt_return[ 1 ]-object_msg[ 1 ]-message TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ELSE.
      IF sy-batch IS INITIAL.
        WRITE: /5 'Geschäftsbereich konnte erfolgreich geändert werden.'.
      ELSE.
        MESSAGE 'Geschäftsbereich konnte erfolgreich geändert werden.' TYPE 'S'.
      ENDIF.
      COMMIT WORK.
    ENDIF.
  ENDIF.
ENDFORM.
