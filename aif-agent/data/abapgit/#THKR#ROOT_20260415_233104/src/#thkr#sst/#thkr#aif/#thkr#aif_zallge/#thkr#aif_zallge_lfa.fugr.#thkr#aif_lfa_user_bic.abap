*"----------------------------------------------------------------------
* Gereon Koks  TSI  10.9.2024
*"----------------------------------------------------------------------
* File as Strings is transferred to BIC Structure
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_lfa_user_bic .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_FILECONFNS) TYPE  /AIF/LFA_FILECONFNS
*"     REFERENCE(IV_FILECONF) TYPE  /AIF/LFA_FILECONF
*"     REFERENCE(IV_DATA_STRING) TYPE  STRING
*"     REFERENCE(IV_DATA_BINARY) TYPE  XSTRING
*"     REFERENCE(IR_APPL) TYPE REF TO  /AIF/CL_APPL_ENGINE_LFA
*"     REFERENCE(IV_COUNTER) TYPE  I
*"  EXPORTING
*"     REFERENCE(ES_RAW_STRUCT) TYPE REF TO  DATA
*"     REFERENCE(ET_RETURN) TYPE  BAPIRETTAB
*"     REFERENCE(EV_MORE_DATA) TYPE  ABAP_BOOL
*"  CHANGING
*"     REFERENCE(CV_USER_LINE_NR) TYPE  I
*"  EXCEPTIONS
*"      CUSTOMIZING_INCOMPLETE
*"      NO_DATA
*"      WRONG_FORMAT
*"----------------------------------------------------------------------
  DATA: lt_iv_data_string       TYPE TABLE OF string,
        ls_iv_data_string       TYPE string,
        lv_line                 TYPE /thkr/s_aif_bic_zeile,
        lt_felder               TYPE TABLE OF string,
        ls_felder               TYPE string,
        lv_delimiter_cr_lf(2)   VALUE cl_abap_char_utilities=>cr_lf,
        lv_delimiter_newline(2) VALUE cl_abap_char_utilities=>newline,
        ls_raw_struct           TYPE /thkr/s_aif_bic,
        l_/aif/t_tfix           TYPE /aif/t_tfix,
        ls_/thkr/ano_zuord      TYPE /thkr/ano_zuord,
        ls_/thkr/ano_set        TYPE /thkr/ano_set,
        ls_/thkr/ano_system     TYPE /thkr/ano_system,
        ls_/aif/t_vmapval       TYPE /aif/t_vmapval,
* last 2 chars from sy-tabix + '%'
        lv_tabix(4)             TYPE n,
        lv_bic(3).

  FIELD-SYMBOLS: <fs_value> TYPE any.
*"----------------------------------------------------------------------
* Aus dem Select-Screen des rufenden Reports den Dateinamen holen.
*  ASSIGN ('(/AIF/UPLOAD_FILES_LFA)P_PATH') TO FIELD-SYMBOL(<v>).

  DATA: lo_init_check      TYPE REF TO /thkr/cl_if_initial_check,
        lv_data_string(17),
        flg_error.

  lo_init_check = NEW /thkr/cl_if_initial_check( ).
  lv_data_string = iv_data_string+3(17).

  CALL METHOD lo_init_check->gen_check
    EXPORTING
      i_data_string = lv_data_string
    IMPORTING
      e_error       = flg_error
      et_return     = et_return.

  IF flg_error = 'E'.
    EXIT.
  ENDIF.
*"----------------------------------------------------------------------
* Datei komplett als String in Tabelle (Handling UNIX und Windows)
  SPLIT iv_data_string AT lv_delimiter_cr_lf INTO TABLE lt_iv_data_string.
  IF lines( lt_iv_data_string ) = 0.
    SPLIT iv_data_string AT lv_delimiter_newline INTO TABLE lt_iv_data_string.
  ENDIF.
*"----------------------------------------------------------------------
* Header aus Tabelle lesen
  READ TABLE lt_iv_data_string INDEX 1 INTO ls_raw_struct-header.

  IF ls_raw_struct-header-start <> '000BI'.
    APPEND VALUE #( id         = '/THKR/SST'
                     number     = 001
                     type       = 'E'
                     message_v1 = 'Die Schnittstellen-Datei beinhaltet'
                     message_v2 = 'keinen Header-Satz und kann daher'
                     message_v3 = 'nicht verarbeitet werden.' ) TO et_return.

    EXIT.
  ENDIF.
*"----------------------------------------------------------------------
* Immer auf UPPER CASE. Dann muß man im Customizing nicht unterscheiden.
  TRANSLATE ls_raw_struct-header-empf TO UPPER CASE.
*"----------------------------------------------------------------------
* Check, if delimiter is filled
  IF ls_raw_struct-header-delim IS INITIAL.
    APPEND VALUE #( id         = '/THKR/SST'
                     number     = 001
                     type       = 'E'
                     message_v1 = 'Für die Schnittstelle mit der Kennung:'
                     message_v2 = ls_raw_struct-header-empf
                     message_v3  = 'konnte kein Trennzeichen ermittelt werden.' ) TO et_return.

    EXIT.
  ENDIF.
*"----------------------------------------------------------------------
* Footer aus Tabelle lesen
  READ TABLE lt_iv_data_string INDEX lines( lt_iv_data_string ) INTO ls_raw_struct-footer.
*"----------------------------------------------------------------------

* Which Interface do we have ?
* Necessary to check if an Anonymization-Set has to be processed.
  CLEAR ls_/aif/t_vmapval.

  SELECT * FROM /aif/t_vmapval INTO ls_/aif/t_vmapval
    WHERE ns        = 'ZALLGE'
      AND vmapname  = 'MAP_/THKR/SST'
      AND ext_value = ls_raw_struct-header-empf.

  ENDSELECT.
*"----------------------------------------------------------------------
  LOOP AT lt_iv_data_string INTO ls_iv_data_string.
    IF ls_iv_data_string+0(3) <> '000' AND
       ls_iv_data_string+0(3) <> '999'.

*      SPLIT ls_iv_data_string AT '|' INTO TABLE lt_felder.
      SPLIT ls_iv_data_string AT ls_raw_struct-header-delim INTO TABLE lt_felder.

      LOOP AT lt_felder INTO ls_felder.
        ASSIGN COMPONENT sy-tabix OF STRUCTURE lv_line TO <fs_value>.

* Only when the system is set to 'ACTIVE' for anonymization
        SELECT * FROM /thkr/ano_system INTO ls_/thkr/ano_system
          WHERE active = 'ACTIVE'.

* Does the user have an Anonymization-Set for this Interface ?
          SELECT * FROM /thkr/ano_zuord INTO ls_/thkr/ano_zuord
            WHERE sst   = ls_/aif/t_vmapval-int_value.

            lv_tabix = sy-tabix.
            CONCATENATE lv_tabix+2(2) '%' INTO lv_bic.

* Read all fields of the Set and anonymize accordingly
            SELECT * FROM /thkr/ano_set INTO ls_/thkr/ano_set
              WHERE ano_set = ls_/thkr/ano_zuord-ano_set
                AND field LIKE lv_bic.

              ls_felder = ls_/thkr/ano_set-wert.
            ENDSELECT.
          ENDSELECT.
        ENDSELECT.

        <fs_value> = ls_felder.
      ENDLOOP.

* Festwert-Tabelle gibt Sortierreihenfolge auf Buchungsschlüssel
      SELECT * FROM /aif/t_tfix INTO l_/aif/t_tfix
        WHERE ns           = 'ZALLGE'
          AND fixvaluename = 'FVT_SORT'
          AND fieldvalue   = lv_line-01_btyp.

* Sortierfeld in der BIC-Struktur
        lv_line-onum = l_/aif/t_tfix-rownumber.
      ENDSELECT.

      APPEND lv_line TO ls_raw_struct-line.
    ENDIF.
  ENDLOOP.
*"----------------------------------------------------------------------
  " Sortierung wird nicht mehr benötigt
  " Die richtige Verarbeitung wird durch die Aktionen definiert.
  "Andernfalls stimmt die Reihenfolge der Quellbelegnummern nicht mehr
*  SORT ls_raw_struct-line BY onum.
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <dref> TYPE any.
  CREATE DATA es_raw_struct TYPE /thkr/s_aif_bic.
  ASSIGN es_raw_struct->* TO <dref>.
  <dref> = ls_raw_struct.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
