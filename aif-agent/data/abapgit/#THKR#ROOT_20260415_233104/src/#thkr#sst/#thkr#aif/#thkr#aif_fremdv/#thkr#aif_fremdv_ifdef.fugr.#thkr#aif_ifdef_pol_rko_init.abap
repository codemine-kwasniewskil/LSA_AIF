FUNCTION /thkr/aif_ifdef_pol_rko_init .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(CONTEXT) TYPE  STRING OPTIONAL
*"     REFERENCE(FINF) TYPE  /AIF/T_FINF
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) OPTIONAL
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_AIF_BIC OPTIONAL
*"  EXCEPTIONS
*"      CANCEL
*"----------------------------------------------------------------------
  DATA: lo_struc TYPE REF TO cl_abap_structdescr.
  DATA: lo_tab TYPE REF TO cl_abap_tabledescr.

  DATA(lv_file) = |{ raw_struct-header-start+3 }{ raw_struct-header-verfa }{ raw_struct-header-gennr }.{ to_lower( raw_struct-header-empf )  }.{ raw_struct-header-dienstnr }|.

  SELECT *
   FROM /thkr/t_rko_err
   WHERE filename <> @lv_file
    INTO TABLE @DATA(lt_errors).
  IF sy-subrc = 0.
    lo_tab ?= cl_abap_tabledescr=>describe_by_data( p_data = raw_struct-line ).
    lo_struc ?= cl_abap_structdescr=>describe_by_name( p_name = lo_tab->get_table_line_type( )->absolute_name+6 ).
    DATA(lt_comp) = lo_struc->components.
    LOOP AT lt_errors ASSIGNING FIELD-SYMBOL(<ls_errors>).
      APPEND INITIAL LINE TO raw_struct-line ASSIGNING FIELD-SYMBOL(<ls_line>).
      LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>).
        ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE <ls_line> TO FIELD-SYMBOL(<ls_curr_val>).
        ASSIGN COMPONENT <ls_comp>-name+3 OF STRUCTURE <ls_errors> TO FIELD-SYMBOL(<ls_err_val>).
        IF <ls_err_val> IS ASSIGNED AND <ls_curr_val> IS ASSIGNED.
          <ls_curr_val> = <ls_err_val>.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
