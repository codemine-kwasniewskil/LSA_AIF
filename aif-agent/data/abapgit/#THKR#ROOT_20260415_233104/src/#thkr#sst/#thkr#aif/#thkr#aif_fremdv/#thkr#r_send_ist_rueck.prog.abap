*&---------------------------------------------------------------------*
*& Report /THKR/R_SEND_IST_RUECK
*&---------------------------------------------------------------------*
**& Description
*& Das ist ein ABAP-Report zur Informationssammlung
*& für die Zahlungsbestätigung
*&---------------------------------------------------------------------*
*& created: 28.11.2024
*& from:    Sergei Iastrebov, T-Systems Iberia
*& last Change: 16.05.2025 ZHM000000307
*&---------------------------------------------------------------------*
REPORT /thkr/r_send_ist_rueck.

INCLUDE /thkr/r_send_ist_rueck_top.
INCLUDE /thkr/r_send_ist_rueck_ssc.
INCLUDE /thkr/r_send_ist_rueck_c01.

*&---------------------------------------------------------------------*
*&      AT SELECTION-SCREEN ON VALUE-REQUEST
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_q_ns.
  lcl_appl=>f4_ns( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_sst.
  lcl_appl=>f4_sst( ).

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
