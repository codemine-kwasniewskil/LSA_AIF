*&---------------------------------------------------------------------*
*& Include /THKR/ADRCITY_EXPORT_TOP                 - Report /THKR/ADRCITY_EXPORT
*&---------------------------------------------------------------------*
REPORT /thkr/adrcity_export.

*&---------------------------------------------------------------------*
*&       TYPES
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_data,
    country	  TYPE land1,
    post_code	TYPE post_code,
    city     	TYPE string,
  END OF ty_data,
  tt_data TYPE TABLE OF ty_data.
