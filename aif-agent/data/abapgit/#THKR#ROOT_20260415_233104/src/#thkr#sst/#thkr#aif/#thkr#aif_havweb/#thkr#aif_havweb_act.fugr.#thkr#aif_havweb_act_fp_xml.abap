*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Funktionskennzahl"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_havweb_act_fp_xml .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_DE_HVW_FKZ_SAP
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  BREAK-POINT.                                             "#EC NOBREAK
*"----------------------------------------------------------------------
  DATA: ls_fkz TYPE /thkr/s_psm_fkz_key.
  DATA: lt_return TYPE bapiret2_t.
  DATA(lo_int_appl) = /thkr/cl_psm_int=>get_instance( ).

  ASSIGN data  TO FIELD-SYMBOL(<ls_data>).

  IF <ls_data> IS ASSIGNED AND <ls_data> IS NOT INITIAL.
    LOOP AT <ls_data>-fkz ASSIGNING FIELD-SYMBOL(<ls_fkz>).
      FREE: ls_fkz, lt_return.
      TRY.
          "Create FKZ
          ls_fkz = lo_int_appl->create_psm_fkz( <ls_fkz> ).
          IF ls_fkz IS NOT INITIAL.
            " Der Funktionskennzahl &1 &2 &3 wurde erfolgreich angelegt
            MESSAGE s033(/thkr/psm_int_fi) WITH <ls_fkz>-fikrs <ls_fkz>-gjahr <ls_fkz>-fkz INTO DATA(lv_message).
            /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = lt_return ).
          ELSE.
            " Die Funktionskennzahl &1 &2 &3 existiert und muss nicht aktualisiert werden
            MESSAGE s034(/thkr/psm_int_fi) WITH <ls_fkz>-fikrs <ls_fkz>-gjahr <ls_fkz>-fkz INTO lv_message.
            /thkr/cl_bapi_helper=>collect_message_from_syst( CHANGING messages = lt_return ).
          ENDIF.

        CATCH /thkr/cx_psm_int_fi INTO DATA(lx_psm_int).
          /thkr/cl_bapi_helper=>collect_message_from_ex( EXPORTING exception = lx_psm_int CHANGING messages = lt_return ).
          "Set AIF sucess to not successful
          success = 'N'.
          "Start with next entity
          CONTINUE.
      ENDTRY.
      APPEND LINES OF lt_return TO return_tab.
    ENDLOOP.

    IF success <> 'N'.
      "During the loop errors could occur by creating business partners.
      "However the loop shall be finished
      "No Error during BP creation and modification.
      "Set AIF Success to yes
      success = 'Y'.
    ENDIF.
  ENDIF.
ENDFUNCTION.
