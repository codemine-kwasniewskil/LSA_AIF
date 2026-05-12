class ZCL_FI_BN_NACHR_SALV definition
  public
  inheriting from ZCL_GUI_SALV
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !I_CHOOSE type XFELD optional .
protected section.

  methods FILL_DATA
    redefinition .
  methods HANDLE_ADDED_FUNCTION
    redefinition .
  methods SET_EVENT_HANDLING
    redefinition .
private section.

  data T_NACHRICHTEN type ZFI_T_BN_NACHR .
  constants C_NAME_FUGR type SYREPID value 'SAPLZGUI_SALV' ##NO_TEXT.
  constants C_GUI_STATUS type SYPFKEY value 'SALV_STANDARD' ##NO_TEXT.
  constants C_GUI_STATUS_CHOOSE type SYPFKEY value 'SALV_CHOOSE' ##NO_TEXT.
  constants C_GUI_TITEL type LVC_TITLE value 'Benachrichtigungen' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'ZCL_FI_BN_NACHR_SALV' ##NO_TEXT.
  data APPL type ref to ZCL_FI_BN_NACHRICHTEN .
  data T_NACHR type ZFI_T_DTO_NACHR .
  data CHOSEN_LINE type ZFI_F_DTO_NACHR .

  methods HANDLE_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
  methods HANDLE_LINK_CLICK
    for event LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
ENDCLASS.



CLASS ZCL_FI_BN_NACHR_SALV IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    IF i_choose IS INITIAL.
      gui_status  = c_gui_status.

      APPEND 'BELNR'  TO hotspots.
      APPEND 'VBLNR'  TO hotspots.
      APPEND 'KUKEY'  TO hotspots.
      APPEND 'LIFNR'  TO hotspots.
      APPEND 'KUNNR'  TO hotspots.
      APPEND 'VBELN'  TO hotspots.
    ELSE.
      gui_status  = c_gui_status_choose.
    ENDIF.

*    gui_status  = c_gui_status.
    gui_title   = c_gui_titel.
    report_name = c_report_name.
    name_fugr   = c_name_fugr.

    appl = zcl_fi_bn_nachrichten=>get_instance( ).

    APPEND 'BNKEY' TO techfields.

  ENDMETHOD.


  METHOD fill_data.
    data: i_ges type i,
          i_auth type i.
    FIELD-SYMBOLS <selection> TYPE zfi_f_bn_selection.

    ASSIGN selection->* TO <selection>.

    appl->get_tdto_nachr(
      EXPORTING
        i_selection = <selection>
      IMPORTING
       e_tdto      = t_nachr ).
    describe table t_nachr lines i_ges.

    appl->check_auth_tdto_nachr(
      changing
        ct_dto_nachr = t_nachr )
        .
    describe table t_nachr lines i_auth.
    if i_auth ne i_ges.
        MESSAGE i041(Z_FI_NACHR).
    endif.
    GET REFERENCE OF t_nachr INTO t_data_ref.

*   Felder ausblenden, die nicht benötigt werden
    IF <selection>-herk = 'Z'.
      APPEND 'ANWND' TO techfields.
      APPEND 'ABSND' TO techfields.
      APPEND 'AZIDT' TO techfields.
      APPEND 'AZNUM' TO techfields.
      APPEND 'KUKEY' TO techfields.
      APPEND 'ESNUM' TO techfields.
      APPEND 'VGINT' TO techfields.
      APPEND 'VGEXT' TO techfields.
      APPEND 'KWAER' TO techfields.
      APPEND 'KWBTR' TO techfields.
      APPEND 'HBKID' TO techfields.
      APPEND 'HKTID' TO techfields.
    ENDIF.
    IF <selection>-herk = 'R' OR <selection>-herk = 'A'.
      APPEND 'LAUFD' TO techfields.
      APPEND 'LAUFI' TO techfields.
      APPEND 'ZBUKR' TO techfields.
    ENDIF.
  ENDMETHOD.


  METHOD handle_added_function.

    super->handle_added_function(
     e_salv_function = e_salv_function ).

    DATA: l_selections TYPE REF TO cl_salv_selections,
          l_rows       TYPE salv_t_row,
          l_row        TYPE i.

    IF e_salv_function = 'CHOOSE'.

      get_selected_rows(
        IMPORTING
          et_rows = l_rows ).

      READ TABLE l_rows INDEX 1 INTO l_row.

      handle_double_click(
        row    = l_row
        column = '0' ).

    ENDIF.

  ENDMETHOD.


  METHOD handle_double_click.

*    DATA: l_ftext TYPE zfi_cu_bn_ftext.


    FIELD-SYMBOLS: <line> TYPE LINE OF zfi_t_dto_nachr.

    READ TABLE t_nachr INDEX row ASSIGNING <line>.
    IF sy-subrc = 0.
*      chosen_line = <line>.
*      salv->close_screen( ).

**   Fehlertext lesen
*      SELECT SINGLE * FROM zfi_cu_bn_ftext INTO l_ftext
*         WHERE herk = <line>-herk
*         AND   fehlernr = <line>-fehlernr.
*      IF sy-subrc = 0.
*        IF l_ftext-alterntext IS NOT INITIAL.
*          <line>-ftext = l_ftext-alterntext.
*        ELSE.
*          <line>-ftext = l_ftext-fehlertext.
*        ENDIF.
*      ENDIF.

      CALL FUNCTION 'Z_FI_BN_BEL_CALL_SCREEN_9110'
        CHANGING
          c_dto = <line>.

      refresh( EXPORTING refresh_mode = if_salv_c_refresh=>full ).

    ENDIF.

  ENDMETHOD.


  METHOD handle_link_click.

    DATA: lt_rkukey TYPE feby_range_kukey,
          ls_rkukey TYPE febs_range_kukey,
          lt_resnum TYPE zfi_t_runame,
          ls_resnum TYPE zfi_f_runame,
          l_text(100) TYPE c VALUE space.


    FIELD-SYMBOLS: <row>  TYPE LINE OF zfi_t_dto_nachr.
    FIELD-SYMBOLS <t_data> TYPE STANDARD TABLE.

    IF row IS INITIAL.
      EXIT.
    ENDIF.

    ASSIGN t_data_ref->* TO <t_data>.

   if t_nachr is not initial.
    READ TABLE t_nachr INDEX row ASSIGNING <row>.
   else.
     READ TABLE <t_data> INDEX row ASSIGNING <row>.
   endif.

    CASE column.

      WHEN 'BELNR'.
        IF <row>-belnr IS NOT INITIAL AND
           <row>-bukrs IS NOT INITIAL AND
           <row>-gjahr IS NOT INITIAL .
          IF <row>-herk <> 'A'.
            SET PARAMETER ID 'BLN' FIELD <row>-belnr.
            SET PARAMETER ID 'BUK' FIELD <row>-bukrs.
            SET PARAMETER ID 'GJR' FIELD <row>-gjahr.
            CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
          ELSE.
            IF <row>-belnr(1) <> '7'.
              SET PARAMETER ID 'MRB' FIELD <row>-belnr.
              SET PARAMETER ID 'MRBP' FIELD '001'.
              CALL TRANSACTION 'FMZ3' AND SKIP FIRST SCREEN.
            ELSE.
              SET PARAMETER ID 'MRB' FIELD <row>-belnr.
              SET PARAMETER ID 'MRBP' FIELD '1'.
              CALL TRANSACTION 'FMV3' AND SKIP FIRST SCREEN.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'VBLNR'.
        IF <row>-vblnr IS NOT INITIAL AND
           <row>-bukrs IS NOT INITIAL AND
           <row>-gjahr IS NOT INITIAL .
          SET PARAMETER ID 'BLN' FIELD <row>-vblnr.
          SET PARAMETER ID 'BUK' FIELD <row>-bukrs.
          SET PARAMETER ID 'GJR' FIELD <row>-gjahr.
          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
        ENDIF.

      WHEN 'VBELN'.
        IF <row>-vbeln IS NOT INITIAL.
          SET PARAMETER ID 'VF' FIELD <row>-vbeln.
          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
        ENDIF.


      WHEN 'LIFNR'.
        IF <row>-lifnr IS NOT INITIAL.
        l_text = '/111/120/130/210/215/220/380/600/610'.
        SET PARAMETER ID 'LIF' FIELD <row>-lifnr.
        SET PARAMETER ID 'BUK' FIELD <row>-bukrs.
        SET PARAMETER ID 'KDY' FIELD l_text.
        CALL TRANSACTION 'FK03' AND SKIP FIRST SCREEN.
***        IF <row>-lifnr IS NOT INITIAL.
***          SET PARAMETER ID 'BPA' FIELD <row>-lifnr.
***          CALL TRANSACTION 'BP'.
        ENDIF.

      WHEN 'KUNNR'.
        IF <row>-kunnr IS NOT INITIAL.
      SET PARAMETER ID 'KUN' FIELD <row>-kunnr.
      SET PARAMETER ID 'BUK' FIELD <row>-bukrs.
      CALL TRANSACTION 'FD03' AND SKIP FIRST SCREEN.
****          SET PARAMETER ID 'BPA' FIELD <row>-kunnr.
****          CALL TRANSACTION 'BP'.
        ENDIF.

      WHEN 'KUKEY'.
        IF <row>-anwnd IS NOT INITIAL AND
           <row>-kukey IS NOT INITIAL AND
           <row>-esnum IS NOT INITIAL.

          ls_rkukey-sign = 'I'.
          ls_rkukey-option = 'EQ'.
          ls_rkukey-low = <row>-kukey.
          APPEND ls_rkukey TO lt_rkukey.
          ls_resnum-sign = 'I'.
          ls_resnum-option = 'EQ'.
          ls_resnum-low(5) = <row>-esnum.
          APPEND ls_resnum TO lt_resnum.

          SUBMIT rfebkap0 AND RETURN
*                    USER sy-uname
                    WITH anwnd    = <row>-anwnd
                    WITH r_kukey  IN lt_rkukey
                    WITH r_esnum  IN lt_resnum.
*---------------------------------------------------------------------*
*    die Zahlungsanzeigen  kommen ohne Anwendung
*---------------------------------------------------------------------*
        elseIF <row>-anwnd IS INITIAL AND
           <row>-kukey IS NOT INITIAL AND
           <row>-esnum IS NOT INITIAL.

          ls_rkukey-sign = 'I'.
          ls_rkukey-option = 'EQ'.
          ls_rkukey-low = <row>-kukey.
          APPEND ls_rkukey TO lt_rkukey.
          ls_resnum-sign = 'I'.
          ls_resnum-option = 'EQ'.
          ls_resnum-low(5) = <row>-esnum.
          APPEND ls_resnum TO lt_resnum.

          SUBMIT rfebkap0 AND RETURN
*                    USER sy-uname
*                    WITH anwnd    = <row>-anwnd
                    WITH r_kukey  IN lt_rkukey
                    WITH r_esnum  IN lt_resnum.
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD set_event_handling.

    DATA: l_events  TYPE REF TO cl_salv_events_table.

    super->set_event_handling( ).

    l_events = salv->get_event( ).

    SET HANDLER handle_link_click FOR l_events.
    SET HANDLER handle_double_click FOR l_events.

  ENDMETHOD.
ENDCLASS.
