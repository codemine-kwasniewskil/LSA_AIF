*&---------------------------------------------------------------------*
*& Include          /THKR/ELKO_901_SEARCH_TOP
*&---------------------------------------------------------------------*
*.................. Globale Klassen laden ............................ *

* Zeiger
 DATA: gr_cont TYPE REF TO cl_gui_custom_container,
       gr_alv  TYPE REF TO cl_gui_alv_grid.
*.................. Felder für den Selektionsbildschirm .............. *
 DATA: gs_ausgabe TYPE /thkr/ts_901_search,
       gs_febko   TYPE febko,
       gs_febep   TYPE febep,
       gs_febre   TYPE febre.

 DATA: gt_ausgabe  TYPE TABLE OF /thkr/ts_901_search.

* Variablen
 DATA: ok_code      TYPE ok_code.

*.................. interne Tabellen ................................. *

*----------------------------------------------------------------------*
*        I N T E R N E  D A T E N F E L D E R                          *
*----------------------------------------------------------------------*

*.................. Klassendeklarationen ............................. *
 CLASS lcl_eventhandler DEFINITION FINAL.
   PUBLIC SECTION.
     CLASS-METHODS: on_double_click      FOR EVENT double_click
       OF cl_gui_alv_grid
       IMPORTING e_row
                 e_column.
 ENDCLASS.                    "lcl_eventhandler DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_eventhandler IMPLEMENTATION
*---------------------------------------------------------------------*
 CLASS lcl_eventhandler IMPLEMENTATION.
* Methode Doppelklick (Sprungfunktion in OP Transaktion)
   METHOD on_double_click.
     CASE sy-dynnr.
       WHEN '0100'.
         PERFORM double_click USING gt_ausgabe
                                    e_row
                                    e_column.
     ENDCASE.
   ENDMETHOD.                    "on_double_click

 ENDCLASS.                    "lcl_eventhandler IMPLEMENTATION


*----------------------------------------------------------------------*
*        A U S W A H L K R I T E R I E N  SELEKTIONSBILD FESTLEGEN     *
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK 1
   WITH FRAME TITLE TEXT-001.
   PARAMETERS: pa_901   RADIOBUTTON GROUP 1 DEFAULT 'X' USER-COMMAND a.
   PARAMETERS: pa_902   RADIOBUTTON GROUP 1 .
 SELECTION-SCREEN: END OF BLOCK 1.

 SELECTION-SCREEN: BEGIN OF BLOCK 2
   WITH FRAME TITLE TEXT-001.
   PARAMETERS: pa_febre RADIOBUTTON GROUP 2 DEFAULT 'X' .
   PARAMETERS: pa_feld  RADIOBUTTON GROUP 2 .
 SELECTION-SCREEN: END OF BLOCK 2.

 SELECTION-SCREEN: BEGIN OF BLOCK 3
   WITH FRAME TITLE TEXT-002.
   PARAMETERS: pa_vwezw TYPE char30k MODIF ID feb.
   PARAMETERS: pa_kwbtr TYPE kwbtr   MODIF ID feb.
 SELECTION-SCREEN: END OF BLOCK 3.

 SELECTION-SCREEN: BEGIN OF BLOCK 4
   WITH FRAME TITLE TEXT-003.
   SELECT-OPTIONS: so_kukey FOR gs_febko-kukey MODIF ID kuk,
                   so_esnum FOR gs_febep-esnum MODIF ID kuk,
                   so_rsnum FOR gs_febre-rsnum MODIF ID kuk,
                   so_bukrs FOR gs_febko-bukrs MODIF ID kuk,
                   so_gjahr FOR gs_febep-gjahr MODIF ID kuk DEFAULT sy-datum+0(4).
 SELECTION-SCREEN: END OF BLOCK 4.

 SELECTION-SCREEN: BEGIN OF BLOCK 5
   WITH FRAME TITLE TEXT-012.
   PARAMETERS: pa_layo TYPE slis_vari.
 SELECTION-SCREEN: END   OF BLOCK 5.

 AT SELECTION-SCREEN OUTPUT.
   PERFORM modify_screen.

 AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_layo.
   DATA: lv_layout_key TYPE salv_s_layout_key.

   lv_layout_key-report = sy-repid.
   pa_layo = cl_salv_layout_service=>f4_layouts( lv_layout_key )-layout.
