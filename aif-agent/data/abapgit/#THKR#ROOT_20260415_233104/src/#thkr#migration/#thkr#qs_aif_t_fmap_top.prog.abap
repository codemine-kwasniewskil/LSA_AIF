*&---------------------------------------------------------------------*
*& Include          /THKR/QS_AIF_T_FMAP_TOP                            *
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
*& TOP - Inlcude für /THKR/QS_AIF_T_FMAP                               *
*&                                                                     *
*& Definitionen von globalen Daten                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Änderungshistorie:                                                  *
*& Datum    Änderer      Beschreibung                                  *
*& -------- ------------ --------------------------------------------- *
*& 20250505 ZHM000000307 Anlage des Reports                            *
*& 20250619 ZHM000000307 Erweiterung der Ausgabe im ALV                *
*&                                                                     *
*&---------------------------------------------------------------------*

************************************************************************
* Globale Feldsymbole                                                  *
************************************************************************
FIELD-SYMBOLS: <gs_f> TYPE /thkr/s_aif_t_fmap_small,
               <gs_a> TYPE /aif/t_fmap.

************************************************************************
* Globale Strukturen                                                   *
************************************************************************
DATA: gs_t_fmap     TYPE /thkr/s_aif_t_fmap_small,
      gs_alv_t_fmap TYPE /thkr/s_aif_t_fmap_alv.

************************************************************************
* Globale Interne Tabelle                                              *
************************************************************************
DATA: gt_t_fmap         TYPE HASHED TABLE OF /thkr/s_aif_t_fmap_small
      WITH UNIQUE KEY
       ns
       fieldname
       rectype
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
       chkba,
      gt_aif_t_fmap     TYPE TABLE OF /aif/t_fmap,
      gt_tmp_t_fmap_sst TYPE TABLE OF /aif/t_fmap,
      gt_alv_t_fmap_sst TYPE TABLE OF /thkr/s_alv_t_aif_t_fmap,
      gs_alv_t_fmap_sst TYPE /thkr/s_alv_t_aif_t_fmap,
      gt_alv_t_fmap     TYPE TABLE OF /thkr/s_aif_t_fmap_alv,
      gt_tmp_t_fmap     TYPE TABLE OF /thkr/s_aif_t_fmap_small.

************************************************************************
* Globale Variable                                                     *
************************************************************************
DATA: gv_lfd_nr TYPE /thkr/lfd_nr_6.
