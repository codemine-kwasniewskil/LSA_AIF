*&---------------------------------------------------------------------*
*& Include          /THKR/WF_BP_EDIT_GSBER_TOP
*&---------------------------------------------------------------------*
"Datendeklarationen
TABLES: sscrfields.

DATA: gv_partner      TYPE bu_partner,
      gv_gsber        TYPE /thkr/dte_bu_gsber,
      gs_partner_data TYPE cvis_ei_extern,
      gt_partner_data TYPE cvis_ei_extern_t,
      gs_bupa_new_x   TYPE BUPA_CENTR_CUST_EXT_X,
      gs_bupa_new     TYPE BUPA_CENTR_CUST_EXT,
      gt_ret          TYPE STANDARD TABLE OF BAPIRET2.

"Selektionsbild
SELECTION-SCREEN: BEGIN OF BLOCK b1.

  SELECTION-SCREEN: PUSHBUTTON 20(25) TEXT-001 USER-COMMAND old_gsber.
  SELECTION-SCREEN: PUSHBUTTON 50(25) TEXT-002 USER-COMMAND new_gsber.
  SELECTION-SCREEN: SKIP 2.
  PARAMETERS: pa_bp TYPE bu_partner.

  PARAMETERS: pa_gsb_o TYPE /thkr/dte_bu_gsber.
  PARAMETERS: pa_gsb_n TYPE /thkr/dte_bu_gsber.

SELECTION-SCREEN: END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-name = 'PA_GSB_O'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'PA_GSB_N'.
      IF pa_gsb_o IS INITIAL OR pa_bp <> gv_partner.
        screen-input = 0.
      ELSE.
        screen-input = 1.
      ENDIF.

      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.
