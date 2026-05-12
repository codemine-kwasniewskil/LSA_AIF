FUNCTION /thkr/bcs_keyfigures_read.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_REPORT) TYPE  REPID OPTIONAL
*"     VALUE(I_LIST_VARIANT) TYPE  SLIS_VARI OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_T_KEYFIGS) TYPE  FMKF_KFTAB
*"----------------------------------------------------------------------

  DATA: l_keyfig     TYPE bukf_keyfig,
        l_f_variant  TYPE ltdxkey,
        l_t_fieldcat LIKE ltdxdata OCCURS 0 WITH HEADER LINE.


* Zuordnung Kennzahlen <-> Datasource
  SELECT keyfig FROM /thkr/kf_kfdsrc INTO TABLE e_t_keyfigs    "  Kennzahlen - Relation Kennzahl/Datenquellen
                WHERE applic = con_applic.

  SORT e_t_keyfigs.
  DELETE ADJACENT DUPLICATES FROM e_t_keyfigs.

* Wenn eine Variante angegeben wird, nur die Felder der Variante
* berechnen
  IF NOT i_list_variant IS INITIAL.
    l_f_variant-report  = i_report.
    l_f_variant-variant = i_list_variant.
    l_f_variant-type    = 'F'.

* Feldkatalog holen
    CALL FUNCTION 'LT_DBDATA_READ_FROM_LTDX'
      EXPORTING
        is_varkey    = l_f_variant
      TABLES
        t_dbfieldcat = l_t_fieldcat
      EXCEPTIONS
        OTHERS       = 1.

    CHECK sy-subrc = 0.

    DELETE l_t_fieldcat WHERE param <> 'NO_OUT'.
    DELETE l_t_fieldcat WHERE value = 'X'.
    SORT l_t_fieldcat BY key1.

    LOOP AT e_t_keyfigs INTO l_keyfig.
      READ TABLE l_t_fieldcat WITH KEY key1 = l_keyfig BINARY SEARCH.
      IF sy-subrc <> 0.
        DELETE e_t_keyfigs.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFUNCTION.
