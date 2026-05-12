*&---------------------------------------------------------------------*
*& Report /THKR/MIG_AO
*&---------------------------------------------------------------------*
*& Änderungen 05112025  DF-1752
*& Abgrenzungsdatum 01.11.2025 ist in der Methode PROCESS_MIG_MANDAT !
*&---------------------------------------------------------------------*
REPORT /thkr/mig_mandat.

TABLES: /thkr/mig_mvw_sp.




SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001.
*  PARAMETERS: p_epl TYPE  /thkr/mig_mvw_sp-epl,            "Einzelplan
*              p_key TYPE  /thkr/mig_mvw_sp-schluessel,     "Vom Nutzer festgelegter Schlüssel des Mandates
*              p_uci TYPE  /thkr/mig_mvw_sp-uci.            "Migrationsobjekt: Mandat

  PARAMETERS: p_epl  TYPE  /thkr/mig_mvw_sp-epl.

  SELECT-OPTIONS: s_key FOR /thkr/mig_mvw_sp-schluessel,
                  s_uci FOR /thkr/mig_mvw_sp-uci,
                  s_stat FOR /thkr/mig_mvw_sp-status_mvw NO INTERVALS.



SELECTION-SCREEN END OF BLOCK 001.

SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_show   TYPE char01 RADIOBUTTON GROUP grp1,           " Mandate anzeigen
*              p_status TYPE char01 RADIOBUTTON GROUP grp1,          " Status setzen   DEL05112025
              p_create TYPE char01 RADIOBUTTON GROUP grp1.           " Mandate anlegen
SELECTION-SCREEN END OF BLOCK 002.



START-OF-SELECTION.
  DATA: l_salv      TYPE REF TO /thkr/cl_salv_mig_mvw_sap,
        l_selection TYPE /thkr/s_mig_mvw_sap_selection.

  TRY.

      l_selection-epl          = p_epl.

*alt
*      l_selection-schluessel   = p_key.
*      l_selection-uci          = p_uci.

*neu
      l_selection-r_schluessel = s_key[].
      l_selection-r_uci        = s_uci[].
      l_selection-r_status     = s_stat[].




      IF p_show IS NOT INITIAL.                                      " Übersicht anzeigen

        CREATE OBJECT l_salv.

        l_salv->display(
          EXPORTING
            i_selection = l_selection
        ).

* DEL05112025 START *********************************************************************
*      ELSEIF p_status IS NOT INITIAL.                                " Verbindungen suchen und Status setzen

*        /thkr/cl_mig_appl=>get_instance( )->initialize_mvw(
*              EXPORTING
*                i_selection = l_selection
*              ).
* DEL05112025 ENDE  *********************************************************************

      ELSEIF p_create IS NOT INITIAL.                                " Mandate anlegen

        /thkr/cl_mig_appl=>get_instance( )->process_mig_mandats( i_selection  = l_selection ).

      ENDIF.

    CATCH cx_root INTO DATA(l_oerror).

      /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

  ENDTRY.
