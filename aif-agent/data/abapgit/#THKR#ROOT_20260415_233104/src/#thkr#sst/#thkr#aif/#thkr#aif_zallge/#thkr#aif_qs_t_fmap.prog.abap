*&---------------------------------------------------------------------*
*& Report /THKR/AIF_QS_T_FMAP                                          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:    Frank Brähler (Orexes GmbH) (ZHM000000307)                *
*& Erstellt am: 05.05.2025                                             *
*&                                                                     *
*& l. Änderer : Frank Brähler (ZHM000000307)                           *
*& l. Datum   : 19.06.2025                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Anzeige für die Qualitätsprüfung der Tabelle /AIF/T_FMAP            *
*&                                                                     *
*& Optionen: Es wird im Selectionsscreen nach dem Namensraum selektiert*
*& Es wird die Option angegeben, alle Daten, oder Collectiv, damit man *
*& die Unterschiede ermitteln kann                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Änderungshistorie:                                                  *
*& Datum    Änderer      Beschreibung                                  *
*& -------- ------------ --------------------------------------------- *
*& 20250505 ZHM000000307 Anlage des Reports                            *
*& 20250619 ZHM000000307 Erweiterung der Ausgabe im ALV                *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/aif_qs_t_fmap MESSAGE-ID /thkr/mig.

************************************************************************
* TOP - Include                                                        *
************************************************************************
INCLUDE /thkr/qs_aif_t_fmap_top.

************************************************************************
* Screen - Include                                                     *
************************************************************************
INCLUDE /thkr/qs_aif_t_fmap_scr.

************************************************************************
* CLASS - Include ALV                                                  *
************************************************************************
INCLUDE /thkr/qs_aif_alv_cl.

************************************************************************
* PBO - Includes für Dynpros                                           *
************************************************************************
INCLUDE /thkr/qs_aif_alv_pbo_0100.
INCLUDE /thkr/qs_aif_alv_pbo_0200.

************************************************************************
* PAI - Includes für Dynpros                                           *
************************************************************************
INCLUDE /thkr/qs_aif_alv_pai_0100.
INCLUDE /thkr/qs_aif_alv_pai_0200.

************************************************************************
* Initialiserungen für das Programm                                    *
************************************************************************
INITIALIZATION.
  lc_coll = TEXT-001.

************************************************************************
* EREIGNIS: Start-of-selection                                         *
************************************************************************
START-OF-SELECTION.
  SELECT * FROM /aif/t_fmap INTO TABLE gt_aif_t_fmap
           WHERE ns EQ pa_ns
           AND   fieldname IN so_field
         ORDER BY ns fieldname rectype
           sap_fieldname1
           sap_fieldname2
           sap_fieldname3
           sap_fieldname4
           sap_fieldname5
           fieldname_link
           convdtel
           convexit
           convexitdir
           ns_vmapname
           vmapname
           valmapfunction
           fieldoffset
           fieldlength
           fieldoffset1
           fieldlength1
           fieldoffset2
           fieldlength2
           fieldoffset3
           fieldlength3
           fieldoffset4
           fieldlength4
           fieldoffset5
           fieldlength5
           separatorstring
           tabname
           tabselfield
           operator
           tabselcompfield
           nstabselvalue
           tabselvaluename
           tabselvalue
           tabselformat
           tabselfield2
           operator2
           tabselcompfield2
           nstabselvalue2
           tabselvaluename2
           tabselvalue2
           tabselformat2
           tabselfield3
           operator3
           tabselcompfield3
           nstabselvalue3
           tabselvaluename3
           tabselvalue3
           tabselformat3
           nscheck
           aifcheck
           chkba.

  LOOP AT gt_aif_t_fmap ASSIGNING <gs_a>.
    MOVE-CORRESPONDING <gs_a> TO gs_t_fmap.
    MOVE 1 TO gs_t_fmap-anzhl.
    IF pa_coll IS INITIAL.
      APPEND  gs_t_fmap TO gt_tmp_t_fmap.
    ELSE.
      COLLECT gs_t_fmap INTO gt_t_fmap.
    ENDIF.
  ENDLOOP.

  IF NOT pa_coll IS INITIAL.
    gt_tmp_t_fmap[] = gt_t_fmap[].
  ENDIF.

* Sortierung für die Ausgabe vorbereiten
  SORT gt_tmp_t_fmap BY ns fieldname rectype anzhl DESCENDING.
  CLEAR gv_lfd_nr.
  LOOP AT gt_tmp_t_fmap INTO gs_t_fmap.
    ADD 1 TO gv_lfd_nr.
    MOVE-CORRESPONDING gs_t_fmap TO gs_alv_t_fmap.
    MOVE gv_lfd_nr               TO gs_alv_t_fmap-lfd_nr.
    APPEND gs_alv_t_fmap         TO gt_alv_t_fmap.
  ENDLOOP.

END-OF-SELECTION.
  CREATE OBJECT ref_alv.
  ref_alv->alvscreen-strucnam = '/THKR/S_AIF_T_FMAP_ALV'.
  ref_alv->alvscreen-dynnr    = '0100'.

  CALL SCREEN 0100.

  IF ref_alv->alvscreen-r_grid IS NOT INITIAL.
    ref_alv->alvscreen-r_grid->free( ).
  ENDIF.
  IF ref_alv->alvscreen-r_dbcont IS NOT INITIAL.
    ref_alv->alvscreen-r_dbcont->free( ).
  ENDIF.
  IF ref_alv->alvscreen-r_dccont IS NOT INITIAL.
    ref_alv->alvscreen-r_dccont->free( ).
  ENDIF.
  FREE ref_alv.
  cl_gui_cfw=>flush( ).
