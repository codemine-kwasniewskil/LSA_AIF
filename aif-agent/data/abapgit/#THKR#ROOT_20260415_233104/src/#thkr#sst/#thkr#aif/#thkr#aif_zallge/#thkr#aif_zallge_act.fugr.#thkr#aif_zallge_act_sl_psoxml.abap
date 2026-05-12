*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
* Action speichert Langtext.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_sl_psoxml .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_PSO_XML_SAP
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_PSO_XML_SAP_OBJECTS
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <ls_longtext> TYPE /thkr/s_aif_longtext.
  ASSIGN data TO FIELD-SYMBOL(<ls_data>).
  ASSIGN curr_line  TO FIELD-SYMBOL(<ls_curr_line>).
*"----------------------------------------------------------------------
  IF curr_line IS NOT INITIAL.
*"----------------------------------------------------------------------
    APPEND VALUE #( id         = 'KM'
                     number     = 418
                     type       = 'I'
                     message_v1 = '/THKR/AIF_ZALLGE_ACT_SAVE_TEXT' ) TO return_tab.
*"----------------------------------------------------------------------
* Check if Actions are allowed.
    CALL FUNCTION '/THKR/AIF_ZALLGE_ACT_OFF'
      TABLES
        return_tab = return_tab
      EXCEPTIONS
        off        = 1
        OTHERS     = 2.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "Anordnungen Langtext speichern.
    LOOP AT <ls_curr_line>-ao ASSIGNING FIELD-SYMBOL(<ls_ao>).
      success = /thkr/cl_pso_xml_processing=>get_instance( )->save_longtext(
        EXPORTING
          is_data_struct = <ls_ao>
          iv_insert = abap_true
        CHANGING
          ct_return      = return_tab[]
      ).
    ENDLOOP.

    "Sollzugang / Sollabgang Langtext speichern.
    LOOP AT <ls_curr_line>-ao_reference ASSIGNING <ls_ao>.
      success = /thkr/cl_pso_xml_processing=>get_instance( )->save_longtext(
        EXPORTING
          is_data_struct = <ls_ao>
          iv_insert = abap_true
        CHANGING
          ct_return      = return_tab[]
      ).
    ENDLOOP.

    "Stundung Langtext speichern.
    LOOP AT <ls_curr_line>-ao_stu ASSIGNING <ls_ao>.
      success = /thkr/cl_pso_xml_processing=>get_instance( )->save_longtext(
        EXPORTING
          is_data_struct = <ls_ao>
          iv_insert = abap_true
        CHANGING
          ct_return      = return_tab[]
      ).
    ENDLOOP.

    "Mittelbindung Langtext speichern.
    LOOP AT <ls_curr_line>-mb ASSIGNING FIELD-SYMBOL(<ls_mb>).
      DATA(lv_insert) = cond flag( WHEN <ls_mb>-mv_action = 'I' THEN abap_true
                                   WHEN <ls_mb>-mv_action = 'U' THEN abap_false ).
      success = /thkr/cl_pso_xml_processing=>get_instance( )->save_longtext(
        EXPORTING
          is_data_struct = <ls_mb>
          iv_insert = lv_insert
        CHANGING
          ct_return      = return_tab[]
      ).
    ENDLOOP.

    "Mittelbindungsaktualisierung Langtext speichern.
    LOOP AT <ls_curr_line>-mb_up ASSIGNING FIELD-SYMBOL(<ls_mb_up>).
      success = /thkr/cl_pso_xml_processing=>get_instance( )->save_longtext(
        EXPORTING
          is_data_struct = <ls_mb_up>
          iv_insert = abap_false
        CHANGING
          ct_return      = return_tab[]
      ).
    ENDLOOP.

    "Verrechnungsanordnung Langtext speichern.
    LOOP AT <ls_curr_line>-vr ASSIGNING FIELD-SYMBOL(<ls_vr>).
      success = /thkr/cl_pso_xml_processing=>get_instance( )->save_longtext(
        EXPORTING
          is_data_struct = <ls_vr>
          iv_insert = abap_true
        CHANGING
          ct_return      = return_tab[]
      ).
    ENDLOOP.
  ENDIF.

*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
