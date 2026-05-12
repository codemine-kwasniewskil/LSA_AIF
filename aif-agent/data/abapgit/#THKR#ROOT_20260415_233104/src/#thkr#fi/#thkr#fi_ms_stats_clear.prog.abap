*&---------------------------------------------------------------------*
*& Report /THKR/MS_STATS_CLEAR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE /thkr/fi_ms_stats_clear_top               .    " Global Data
INCLUDE /thkr/fi_ms_stats_clear_ssc               .    " Selection Screen
INCLUDE /thkr/fi_ms_stats_clear_c01               .    " Classes

*&---------------------------------------------------------------------*
*&      START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  lcl_appl=>main( it_belnr = so_belnr[] iv_gjahr = p_gjahr iv_test = p_test ).
