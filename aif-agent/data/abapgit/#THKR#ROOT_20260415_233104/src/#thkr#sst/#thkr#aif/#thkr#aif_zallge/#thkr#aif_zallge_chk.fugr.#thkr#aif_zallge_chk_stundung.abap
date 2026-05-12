*"----------------------------------------------------------------------
* Gereon Koks  TSI  3.4.2025
*"----------------------------------------------------------------------
* Prüfen, ob es eine
* - Stundung oder
* - Niederschlagung
* ist.
*"----------------------------------------------------------------------
* Input
* VALUE_IN  01_BTYP
* VALUE_IN2 19_TXTSL
* VALUE_IN3 %06 (Stundung); %07 (Niederschlagung)
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_chk_stundung .
*"--------------------------------------------------------------------
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
*"         OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"      DATA_TABLE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"--------------------------------------------------------------------
  DATA: l_/aif/t_vmapval5 TYPE /aif/t_vmapval5.
*"--------------------------------------------------------------------
  SELECT SINGLE * FROM /aif/t_vmapval5 INTO l_/aif/t_vmapval5
    WHERE ns         = 'ZALLGE'
      AND vmapname   = 'MAP_PSOTY'
      AND ext_value1 = value1
      AND ext_value2 = value2.

  IF sy-subrc = 0.
    IF l_/aif/t_vmapval5-int_value = value3.
      error = abap_false.

      CASE value3.
* Stundung
        WHEN '06'.
          APPEND VALUE #( id         = '/THKR/SST'
                           number     = 001
                           type       = 'I'
                           message_v1 = 'CHK_STU Stundungsanordnung.' )
                           TO return_tab.
* Niederschlagung
        WHEN '07'.
          APPEND VALUE #( id         = '/THKR/SST'
                           number     = 001
                           type       = 'I'
                           message_v1 = 'CHK_STU Niederschlagungsanordnung.' )
                           TO return_tab.
        WHEN OTHERS.
          APPEND VALUE #( id         = '/THKR/SST'
                           number     = 001
                           type       = 'I'
                           message_v1 = 'CHK_STU Weder Stundungs- noch Niederschlagungsanordnung.' )
                           TO return_tab.
      ENDCASE.
    ELSE.
      error = abap_true.
    ENDIF.
  ENDIF.
*"--------------------------------------------------------------------
ENDFUNCTION.
