*&---------------------------------------------------------------------*
*& Report /THKR/PSM_AO_MAINTAIN_XREF1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/psm_ao_maintain_xref1.

DATA: ls_belnr TYPE belnr_d,
      ls_success_string TYPE string.
TABLES: bkpf.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  " Belegnummer mit Mehrfachauswahl
  SELECT-OPTIONS lv_belnr FOR bkpf-belnr.

  PARAMETERS: lv_bukrs TYPE bukrs,

              lv_gjahr TYPE gjahr,

              p_sst    TYPE /thkr/dte_bu_sst.

SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*&      CLASS DEFINITION
*&---------------------------------------------------------------------*
CLASS lcl_appl DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      f4_sst.
ENDCLASS.

*&---------------------------------------------------------------------*
*&      CLASS IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS lcl_appl IMPLEMENTATION.
  METHOD f4_sst.
    DATA: lt_return TYPE STANDARD TABLE OF ddshretval.

    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
      EXPORTING
        tabname           = '/THKR/GPSSTTXT'
        fieldname         = 'SST'
        dynpprog          = 'X'
        dynpnr            = 'X'
        dynprofield       = 'X'
*       VALUE             = ' '
        selection_screen  = 'X'
      TABLES
        return_tab        = lt_return
      EXCEPTIONS
        field_not_found   = 1
        no_help_for_field = 2
        inconsistent_help = 3
        no_values_found   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'.
    cl_gui_cfw=>flush( ).

  ENDMETHOD.
ENDCLASS.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_sst.
  lcl_appl=>f4_sst( ).

START-OF-SELECTION.

  LOOP AT lv_belnr INTO DATA(ls_belnr_list) WHERE sign = 'I'.
    ls_belnr = ls_belnr_list-low.
    IF ls_belnr_list-high = ''.
      ls_belnr_list-high = ls_belnr_list-low.
    ENDIF.
    WHILE ls_belnr <= ls_belnr_list-high.
      IF ls_belnr_list-option = 'EQ'.
        ls_belnr = ls_belnr_list-low.
      ENDIF.

      UPDATE bkpf
      SET xref1_hd = p_sst
      WHERE bukrs = lv_bukrs
        AND belnr = ls_belnr
        AND gjahr = lv_gjahr.

      IF sy-subrc = 0.
        CONCATENATE p_sst ' erfolgreich für Beleg' ls_belnr 'ergänzt.' INTO ls_success_string SEPARATED BY space.
        WRITE / ls_success_string.

        COMMIT WORK.
      ELSE.
        WRITE / 'Fehler bei Beleg: ' && ls_belnr.
      ENDIF.

      ls_belnr = ls_belnr + 1.

    ENDWHILE.
  ENDLOOP.
