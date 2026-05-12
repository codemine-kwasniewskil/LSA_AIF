"Name: \PR:RFFMFITABS\FO:OUTPUT_LIST\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/E_LSA_PSM_RFFMFITABS.
* Notwendige Erweiterung für den automatischen Tagesabschluss

  TYPES: BEGIN OF ty_f845_best,
           abschlgrp TYPE fm_abschlgrp,
           psov1     TYPE psov1,
           ibest     TYPE esbtr_eb,
           waers     TYPE waers,
         END OF ty_f845_best.

  DATA:
    l_enh_f_layout   TYPE slis_layout_alv,
    l_enh_title      TYPE lvc_title,
    l_enh_psobt(10)  TYPE c,
    l_enh_f_org_data TYPE fmpan_org_data,
    l_enh_f_variant  TYPE disvariant,
    l_enh_flg_weiter TYPE c,
    lt_f845_best_imp TYPE TABLE OF ty_f845_best,
    ls_f845_best_imp TYPE ty_f845_best.

  WRITE u_f_fmpso_tagrp-psobt TO l_enh_psobt.
  CONCATENATE TEXT-100 l_enh_psobt INTO l_enh_title SEPARATED BY space.
  READ TABLE u_t_org_data INDEX 1 INTO l_enh_f_org_data.

*----- Kopfdaten vorbereiten
  PERFORM set_top_data  USING    u_f_fmpso_tagrp
                                 l_enh_f_org_data
                        CHANGING g_t_top_data
                                 g_t_top_data_zb.

*----- Feldkatalog erzeugen
  PERFORM get_field_cat USING  l_enh_f_org_data
                        CHANGING c_t_fieldcat.

*----- Ausgabepotionen
  PERFORM set_layout CHANGING l_enh_f_layout.

*----- allow distinct variant for distinct lists
  l_enh_f_variant-report = con_repid.
  l_enh_f_variant-handle = con_handle_tabs.

*----- Aktuelle Bestände importieren (nur bei Aufruf von Z_FI_TA gefüllt)
  IMPORT lt_best TO lt_f845_best_imp FROM MEMORY ID 'F845_BEST'.

  LOOP AT c_t_verds ASSIGNING FIELD-SYMBOL(<ls_verds>).
    IF  <ls_verds>-ksoll_akt    EQ 0
    AND <ls_verds>-ksschweb_akt EQ 0
    AND <ls_verds>-kiext_kum    EQ 0.
      CASE <ls_verds>-vsart.
        WHEN 'BB'.
          <ls_verds>-vsart = 'ZB'.
          SELECT bez FROM fmvartt INTO <ls_verds>-vsart_txt
            WHERE spras    = 'D'
              AND psov_art = <ls_verds>-vsart.
          ENDSELECT.
        WHEN 'BS'.
          <ls_verds>-vsart = 'ZS'.
          SELECT bez FROM fmvartt INTO <ls_verds>-vsart_txt
                      WHERE spras    = 'D'
                        AND psov_art = <ls_verds>-vsart.
          ENDSELECT.
      ENDCASE.
    ENDIF.
  ENDLOOP.

*----- send output list data to reuse function module
  IF sy-batch IS INITIAL AND sy-binpt IS INITIAL AND
     lines( lt_f845_best_imp ) = 0.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program          = con_repid
        i_callback_pf_status_set    = 'SET_PF_STATUS'
        i_callback_user_command     = 'USER_COMMAND'
        i_callback_top_of_page      = 'TOP_OF_PAGE'
        i_callback_html_top_of_page = 'HTML_TOP_OF_PAGE'
        i_grid_title                = l_enh_title
        i_save                      = 'A'
        is_layout                   = l_enh_f_layout
        it_fieldcat                 = c_t_fieldcat
        is_variant                  = l_enh_f_variant
        i_html_height_top           = '22'
      TABLES
        t_outtab                    = c_t_verds.

  ELSE.
    IF p_abschl = con_on. "Parameter 'Abschluss ausführen'

      LOOP AT c_t_verds ASSIGNING FIELD-SYMBOL(<v>).
        READ TABLE lt_f845_best_imp INTO ls_f845_best_imp
                   WITH KEY abschlgrp = g_f_fmpso_tagrp-abschlgrp
                            psov1     = <v>-verds.
        IF sy-subrc = 0.
          <v>-kiext_kum = ls_f845_best_imp-ibest.
          g_mode = con_abschluss.
        ENDIF.

      ENDLOOP.
      IF sy-subrc = 4.
        CLEAR g_mode.
      ENDIF.

*     CALL SCREEN 100. "ohne Dynpro 100
      IF g_mode = con_abschluss. " Istergebnisse übernommen

        PERFORM get_saldo TABLES c_t_verds.

* -> Überspringen Popup in 'save_abschluss' durch Rücksetzen 'kdiff' auf 0
        LOOP AT c_t_verds ASSIGNING <v>.
          CLEAR <v>-kdiff.
        ENDLOOP.

*    User-Command = 'ABSV' ausführen (ohne Refresh des ALV)
        PERFORM save_abschluss TABLES c_t_verds
                                      g_t_fmtabbst
                                      so_bukrs
                               USING  g_f_fmpso_tagrp
                               CHANGING  l_enh_flg_weiter.
      ENDIF. "g_mode
    ENDIF.   "p_abschl
  ENDIF.

* Die originale Formroutine wird nicht mehr durchlaufen
  RETURN.



ENDENHANCEMENT.
