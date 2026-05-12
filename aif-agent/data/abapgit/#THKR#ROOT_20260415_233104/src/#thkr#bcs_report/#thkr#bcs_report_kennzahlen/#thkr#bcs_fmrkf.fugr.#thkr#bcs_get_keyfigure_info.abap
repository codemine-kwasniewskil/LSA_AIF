FUNCTION /thkr/bcs_get_keyfigure_info.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_KEYFIGURE) TYPE  CHAR17
*"  EXPORTING
*"     REFERENCE(E_TABLETYPE) TYPE  TABNAME
*"     REFERENCE(E_DATASOURCE) TYPE  BUKF_DATASOURCE
*"  TABLES
*"      T_NAMETAB STRUCTURE  DFIES
*"  EXCEPTIONS
*"      NOT_FOUND
*"      MULTIPLE_SOURCES
*"----------------------------------------------------------------------


  DATA: l_f_kfds TYPE type_kfds,
        l_f_ds   TYPE bukf_dsrc,
        l_cnt    TYPE i.

* Prüfen, ob die Kennzahl existiert und geladen ist
  LOOP AT g_t_kfds INTO l_f_kfds WHERE keyfig = i_keyfigure.
    ADD 1 TO l_cnt.
  ENDLOOP.
  IF sy-subrc <> 0.
    RAISE not_found.
  ENDIF.

* Die Kennzahl darf nur eine Datasource haben
  IF l_cnt > 1.
    RAISE multiple_sources.
  ENDIF.

* Datensource ermitteln
  READ TABLE g_t_ds INTO l_f_ds
                    WITH KEY datasource = l_f_kfds-datasource.
  IF sy-subrc <> 0.
    RAISE not_found.
  ENDIF.
  e_tabletype  = l_f_ds-tabletype.
  e_datasource = l_f_ds-datasource.

* DDIC-Infos besorgen
  CALL FUNCTION 'DDIF_NAMETAB_GET'
    EXPORTING
      tabname   = l_f_ds-structure
    TABLES
      dfies_tab = t_nametab.



ENDFUNCTION.
