*&---------------------------------------------------------------------*
*& Include          /THKR/GP_CHANGE_GSBER_TOP
*&---------------------------------------------------------------------*

************************************************************************
* Gloable Struktur                                                     *
************************************************************************
TYPES: BEGIN OF ty_excel,
         s1_partner TYPE string,
         s2_butext  TYPE string,
         s3_ogsber  TYPE string,
         s4_ngsber  TYPE string,
         s5_txt     TYPE string,
         s6_dummy   TYPE string,
         s7_dummy   TYPE string,
       END OF ty_excel.

************************************************************************
* Gloable Variablen                                                    *
************************************************************************
DATA: gt_raw_data      TYPE truxs_t_text_data,
      gt_target        TYPE TABLE OF ty_excel,
      gs_target        TYPE ty_excel,
      gv_rc            TYPE i,
      gt_filetable     TYPE filetable,
      gv_filename      TYPE string,
      gs_but000        TYPE but000,
      gt_gsber         TYPE TABLE OF tgsb,
      gv_lines         TYPE i,
      gv_nlines        TYPE numc06,
      gv_nindex        TYPE numc06,
      gv_prozent       TYPE p DECIMALS 2,
      gv_msg           TYPE string,
      gv_partner       TYPE bu_partner,
      gv_npartner      TYPE numc10.

************************************************************************
* Gloable Feldsymbole                                                  *
************************************************************************
FIELD-SYMBOLS: <gfs_table>       TYPE STANDARD TABLE.
