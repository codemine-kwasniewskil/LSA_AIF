*&---------------------------------------------------------------------*
*& Report /THKR/MIG_AO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_lif.

TABLES: /thkr/migd_lif,/thkr/mig_mvw_sp.


PARAMETERS: p_epl    TYPE /thkr/mig_mvw_sp-epl.

*alt
*            p_zpnr   TYPE /thkr/migd_lif-zp_nummer,
*            p_zplfnr TYPE /thkr/migd_lif-zp_lfd_nummer.

*neu
SELECT-OPTIONS: s_zpnr   FOR /thkr/migd_lif-zp_nummer,
                s_zplfnr FOR /thkr/migd_lif-zp_lfd_nummer,
                s_stat   FOR /thkr/mig_mvw_sp-status_mvw NO INTERVALS.

START-OF-SELECTION.
  DATA: l_salv      TYPE REF TO /thkr/cl_salv_mig_lif_sap,
*  DATA: l_salv      TYPE REF TO /thkr/cl_salv_mig_mvw_sap,
        l_selection TYPE /thkr/s_mig_lif_sap_selection.

**** /thkr/s_mig_lif_sap_selection  um ranges erweiteren
**** Seletion um Werte aus ranges erweitern


  CREATE OBJECT l_salv.

  TRY.

*      l_selection-zp_nummer      = p_zpnr.
*      l_selection-zp_lfd_nummer  = p_zplfnr.

      l_selection-epl             = p_epl.
      l_selection-r_zp_nummer     = s_zpnr[].
      l_selection-r_zp_lfd_nummer = s_zplfnr[].
      l_selection-r_status        = s_stat[].


      l_salv->display(
        EXPORTING
          i_selection = l_selection
*         i_vari      =
      ).

    CATCH cx_root INTO DATA(l_oerror).

      /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

  ENDTRY.
