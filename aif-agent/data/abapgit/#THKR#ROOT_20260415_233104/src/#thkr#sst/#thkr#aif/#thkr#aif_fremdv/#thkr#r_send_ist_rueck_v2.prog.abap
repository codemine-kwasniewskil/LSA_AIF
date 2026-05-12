*&---------------------------------------------------------------------*
*& Report /THKR/R_SEND_IST_RUECK
*&---------------------------------------------------------------------*
**& Description
*& Das ist ein ABAP-Report zur Informationssammlung
*& für die Zahlungsbestätigung
*&---------------------------------------------------------------------*
REPORT /thkr/r_send_ist_rueck_v2.

DATA sel TYPE bkpf.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
  PARAMETERS: p_fikrs  TYPE fikrs DEFAULT 1000.
  SELECT-OPTIONS s_cpu FOR sel-cpudt.
  SELECT-OPTIONS s_art FOR sel-blart.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-f03.
  PARAMETERS: p_disp TYPE flag AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK bl3.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
  PARAMETERS: p_q_ns   TYPE /aif/ns DEFAULT 'FREMDV', "/aif/pers_rtcfgr_ns,
              p_q_name TYPE /aif/pers_rtcfgr_name,
              p_sst    TYPE /thkr/dte_bu_sst,
              p_send   TYPE flag AS CHECKBOX,
              p_resend TYPE flag AS CHECKBOX DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK bl2.


*&---------------------------------------------------------------------*
*&      AT SELECTION-SCREEN ON VALUE-REQUEST
**&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_q_ns.
  DATA: lt_return TYPE STANDARD TABLE OF ddshretval.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = '/AIF/T_NS'
      fieldname         = 'NS'
      dynpprog          = 'X'
      dynpnr            = 'X'
      dynprofield       = 'X'
*     VALUE             = ' '
      selection_screen  = 'X'
    TABLES
      return_tab        = lt_return
    EXCEPTIONS
      OTHERS            = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'.
  cl_gui_cfw=>flush( ).
*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_sst.
  DATA: lt_return TYPE STANDARD TABLE OF ddshretval.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = '/THKR/GPSSTTXT'
      fieldname         = 'SST'
      dynpprog          = 'X'
      dynpnr            = 'X'
      dynprofield       = 'X'
*     VALUE             = ' '
      selection_screen  = 'X'
    TABLES
      return_tab        = lt_return
    EXCEPTIONS
      OTHERS            = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'.
  cl_gui_cfw=>flush( ).

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  /thkr/cl_ist_rm_create=>main(
    so_cpudt = s_cpu[]
    so_blart = s_art[]
    fikrs    = p_fikrs    " Finanzkreis
    aif_ns   = p_q_ns    " Namensraum
    aif_name = p_q_name " ID der Laufzeit-Konfigurationsgruppe
    sst      = p_sst      " BP: Schnittstellenpartner
    send     = p_send     " allgemeines flag
    resend   = p_resend   " allgemeines flag
  ).

**&---------------------------------------------------------------------*
**&      END-OF-SELECTION
**&---------------------------------------------------------------------*
END-OF-SELECTION.
  IF p_disp = abap_true.
    /thkr/cl_ist_rm_create=>display( ).
  ENDIF.
