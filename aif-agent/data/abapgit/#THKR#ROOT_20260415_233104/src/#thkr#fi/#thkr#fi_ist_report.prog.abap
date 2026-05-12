*&---------------------------------------------------------------------*
*& Report /THKR/FI_IST_REPORT
*&---------------------------------------------------------------------*
**& Description
*& Das ist ein ABAP-Report, der die erforderlichen Daten für die
*& externen Verfahren PersoKH und HAVWeb exportiert
*&---------------------------------------------------------------------*
*& created: 28.10.2024
*& from:    Sergei Iastrebov, T-Systems Iberia
*&---------------------------------------------------------------------*
REPORT /thkr/fi_ist_report.

INCLUDE /thkr/fi_ist_report_top.
INCLUDE /thkr/fi_ist_report_ssc.
INCLUDE /thkr/fi_ist_report_c01.

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
  lcl_appl=>display( ).
