*&---------------------------------------------------------------------*
*& Include          /THKR/WF_HANDLE_WFEVENTS_TOP
*&---------------------------------------------------------------------*

" Konstanten
CONSTANTS: gc_tcode  TYPE sytcode VALUE '/THKR/WF_WFEVENTS'.    "#EC NEEDED

" Tabellen
DATA: gt_events_chg TYPE TABLE OF swfdvevtyp,               "#EC NEEDED
      gt_fieldcat   TYPE slis_t_fieldcat_alv,               "#EC NEEDED
      gt_excluding  TYPE slis_t_extab,                      "#EC NEEDED
      gt_exit       TYPE slis_t_event_exit.                 "#EC NEEDED

" Strukturen
DATA: gs_layout TYPE slis_layout_alv.                       "#EC NEEDED

" Felder

" Feld Symbole
FIELD-SYMBOLS: <gs_exit> TYPE slis_event_exit.              "#EC NEEDED

* Definitionen für ALV
DATA: go_grid1             TYPE REF TO cl_gui_alv_grid,     "#EC NEEDED
      go_custom_container1 TYPE REF TO cl_gui_custom_container, "#EC NEEDED
      go_events            TYPE REF TO lcl_events,          "#EC NEEDED
      go_ref               TYPE REF TO data,                "#EC NEEDED
      gt_fieldcat1         TYPE lvc_t_fcat,                 "#EC NEEDED
      gv_container1        TYPE scrfname VALUE 'GRID_COND_100', "#EC NEEDED
      okcode               TYPE syucomm.
