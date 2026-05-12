*"----------------------------------------------------------------------
* Gereon Koks  TSI  3.4.2025
*"----------------------------------------------------------------------
* Prüfen, ob es in der Datei schon weiter oben einen Satz gibt,
* der hier referenziert wird.
*"----------------------------------------------------------------------
* Input
* VALUE1  %SST oder %ANE (Buchungstyp nach dem in der Datei gesucht wird)
*         eventuell auch erweitern, wenn für mehrere Buchungsschlüssel gesucht wird
* VALUE2 41_URKASS
* VALUE3 %VORHANDEN (Positiv, wenn Referenz in der Datei existiert)
*           %NICHT_VORHANDEN (Positiv, wenn Referenz in der Datei nicht existiert)
* VALUE4 %22_RES1 oder %32_KASSZ als Referenz verwenden
* VALUE5
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_chk_btyp_i_fi .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT)
*"     REFERENCE(DATA_LINE)
*"     REFERENCE(DATA_FIELD)
*"     REFERENCE(MSGTY) TYPE  SYMSGTY DEFAULT 'E'
*"     REFERENCE(VALUE1) TYPE  STRING
*"     REFERENCE(VALUE2) TYPE  STRING
*"     REFERENCE(VALUE3) TYPE  STRING
*"     REFERENCE(VALUE4) TYPE  STRING
*"     REFERENCE(VALUE5) TYPE  STRING
*"     REFERENCE(T_IFCHECK) TYPE  /AIF/T_IFCHECK OPTIONAL
*"     REFERENCE(T_IFACT) TYPE  /AIF/T_IFACT OPTIONAL
*"     REFERENCE(T_ACCHECK) TYPE  /AIF/T_ACCHECK OPTIONAL
*"     REFERENCE(T_FUNC) TYPE  /AIF/T_FUNC OPTIONAL
*"     REFERENCE(T_FMAPCOND) TYPE  /AIF/T_FMAPCOND OPTIONAL
*"     REFERENCE(T_CHECK) TYPE  /AIF/T_CHECK
*"     REFERENCE(T_TABCHK) TYPE  /AIF/T_TABCHK
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"      DATA_TABLE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <ls_data>      TYPE /thkr/s_aif_bic,
                 <ls_06_qbelnr> TYPE any.
*"--------------------------------------------------------------------
  DATA: lv_message_v1 TYPE symsgv,
        lv_message_v2 TYPE symsgv,
        lv_message_v3 TYPE symsgv,
        lv_message_v4 TYPE symsgv.
*"--------------------------------------------------------------------
  ASSIGN data_struct TO <ls_data>.
*"--------------------------------------------------------------------
* Gibt es in der LINE-Tabelle bereits einen Satz, auf den sich der aktuelle Satz bezieht ?
* Das 41_URKASS wird entweder mit 32_KASSZ oder mit 22_RES1 verglichen.
  CASE value4.
    WHEN '32_KASSZ'.
      READ TABLE <ls_data>-line
           WITH KEY 01_btyp  = value1
                    32_kassz = value2
           TRANSPORTING NO FIELDS.
    WHEN '22_RES1'.
      READ TABLE <ls_data>-line
           WITH KEY 01_btyp  = value1
                    22_res1  = value2
           TRANSPORTING NO FIELDS.
    WHEN OTHERS.
  ENDCASE.


  IF sy-subrc = 0.
    ASSIGN COMPONENT '06_QBELNR' OF STRUCTURE data_line TO <ls_06_qbelnr>.

    CONCATENATE 'CHK_BTYP_IN_FILE:' <ls_06_qbelnr> '(' t_ifcheck-smapnr ')' INTO lv_message_v1 SEPARATED BY space.
    CONCATENATE 'V1(01_BTYP):' value1 '|' INTO lv_message_v2 SEPARATED BY space.
    CONCATENATE 'V2(41_URKASS):' value2 '|' 'V3:' value3 '|' INTO lv_message_v3 SEPARATED BY space.
*    CONCATENATE 'V4:' value4 'in Datei bereits vorhanden.' INTO lv_message_v4 SEPARATED BY space.
    CONCATENATE 'V4:' value4 'POSITIV' INTO lv_message_v4 SEPARATED BY space.

    APPEND VALUE #( id         = '/THKR/SST'
                    number     = 001
                    type       = 'S'
                    message_v1 = lv_message_v1
                    message_v2 = lv_message_v2
                    message_v3 = lv_message_v3
                    message_v4 = lv_message_v4 )
                    TO return_tab.

    APPEND VALUE #( id         = '/THKR/SST'
                    number     = 001
                    type       = 'S'
                    message_v1 = 'CHK_BTYP_IN_FILE:'
                    message_v2 = 'Referenz in Datei vorhanden' )
                    TO return_tab.

    IF value3 = 'VORHANDEN'.
* War vorhanden; Sollte vorhanden sein => kein Fehler
      error = abap_false.
    ELSE.
* War vorhanden; Sollte nicht vorhanden sein => Fehler
      error = abap_true.
    ENDIF.
  ELSE.
    ASSIGN COMPONENT '06_QBELNR' OF STRUCTURE data_line TO <ls_06_qbelnr>.

    CONCATENATE 'CHK_BTYP_IN_FILE:' <ls_06_qbelnr> '(' t_ifcheck-smapnr ')' INTO lv_message_v1 SEPARATED BY space.
    CONCATENATE 'V1(01_BTYP):' value1 '|' INTO lv_message_v2 SEPARATED BY space.
    CONCATENATE 'V2(41_URKASS):' value2 '|' 'V3:' value3 '|' INTO lv_message_v3 SEPARATED BY space.
*    CONCATENATE 'V4:' value4 'in Datei nicht vorhanden.' INTO lv_message_v4 SEPARATED BY space.
    CONCATENATE 'V4:' value4 'NEGATIV' INTO lv_message_v4 SEPARATED BY space.

    APPEND VALUE #( id         = '/THKR/SST'
                    number     = 001
                    type       = 'S'
                    message_v1 = lv_message_v1
                    message_v2 = lv_message_v2
                    message_v3 = lv_message_v3
                    message_v4 = lv_message_v4 )
                    TO return_tab.

    APPEND VALUE #( id         = '/THKR/SST'
                    number     = 001
                    type       = 'S'
                    message_v1 = 'CHK_BTYP_IN_FILE:'
                    message_v2 = 'Referenz in Datei nicht vorhanden' )
                    TO return_tab.

    IF value3 = 'VORHANDEN'.
* War nicht vorhanden; Sollte vorhanden sein => Fehler
      error = abap_true.
    ELSE.
* War nicht vorhanden; Sollte nicht vorhanden sein => kein Fehler
      error = abap_false.
    ENDIF.
  ENDIF.
*"--------------------------------------------------------------------
ENDFUNCTION.
