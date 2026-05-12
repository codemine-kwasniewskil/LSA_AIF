*&---------------------------------------------------------------------*
*& Report /THKR/ADRCITY_EXPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE /thkr/adrcity_export_top                .    " Global Data
INCLUDE /thkr/adrcity_export_ssc.
INCLUDE /thkr/adrcity_export_c01.

*&---------------------------------------------------------------------*
*&      AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  lcl_appl=>ss_pbo( ).
*&---------------------------------------------------------------------*
*&      AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  lcl_appl=>f4_path( ).

*&---------------------------------------------------------------------*
*&      AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  lcl_appl=>screen_check( ).

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_appl=>main( ).

*&---------------------------------------------------------------------*
*&      END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
  IF p_user IS NOT INITIAL.
    lcl_appl=>display( ).
  ELSEIF p_aif IS NOT INITIAL.
    lcl_appl=>send_aif( ).
  ENDIF.
