*&---------------------------------------------------------------------*
*& Report /THKR/KASSZKETTE_EXPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/KASSZKETTE_EXPORT.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
  PARAMETERS: p_user TYPE flag RADIOBUTTON GROUP aif DEFAULT 'X' USER-COMMAND aif,
              p_aif  TYPE flag RADIOBUTTON GROUP aif .

SELECTION-SCREEN END OF BLOCK bl1.
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
  PARAMETERS: p_save TYPE flag AS CHECKBOX MODIF ID lcl.
  PARAMETERS: p_local TYPE dxfields-location RADIOBUTTON GROUP file DEFAULT 'X' USER-COMMAND fls MODIF ID lcl,
              p_appse TYPE dxfields-location RADIOBUTTON GROUP file MODIF ID lcl,
              p_path  TYPE dxfields-longpath LOWER CASE MODIF ID lcl.
SELECTION-SCREEN END OF BLOCK bl2.


INCLUDE /thkr/kasszkette_export_c01.
" CSV-File option


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
