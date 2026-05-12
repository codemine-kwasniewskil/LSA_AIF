*&---------------------------------------------------------------------*
*& Include          /THKR/GP_SET_KORR_CODEPAGE_TOP                     *
*&---------------------------------------------------------------------*

************************************************************************
* Gloable Typendefinitinen                                             *
************************************************************************
TYPES: BEGIN OF ty_csv,
         as_partner    TYPE string,
         bs_bu_sort1   TYPE string,
         cs_name_org1  TYPE string,
         ds_name_first TYPE string,
         es_name_last  TYPE string,
         fs_mv_name1   TYPE string,
         gs_mv_name2   TYPE string,
         hs_street     TYPE string,
         is_house_num1 TYPE string,
         js_city1      TYPE string,
         ks_post_code1 TYPE string,
         ls_bu_sort1   TYPE string,
         ms_name_org1  TYPE string,
         ns_name_first TYPE string,
         os_name_last  TYPE string,
         ps_mv_name1   TYPE string,
         qs_mv_name2   TYPE string,
         rs_street     TYPE string,
         ss_house_num1 TYPE string,
         ts_city1      TYPE string,
         us_post_code1 TYPE string,
       END OF ty_csv.

TYPES: BEGIN OF ty_newdata,
         partner    TYPE bu_partner,
         bu_sort1   TYPE bu_sort1,
         name_org1  TYPE bu_nameor1,
         name_first TYPE bu_namep_f,
         name_last  TYPE bu_namep_l,
         mv_name1   TYPE bu_mcname1,
         mv_name2   TYPE bu_mcname2,
         street     TYPE ad_street,
         house_num1 TYPE ad_hsnm1,
         city1      TYPE ad_city1,
         post_code1 TYPE ad_pstcd1,
       END OF ty_newdata.

TYPES: BEGIN OF ty_upddata,
         partner      TYPE bu_partner,
         bu_sort1     TYPE bu_sort1,
         name_org1    TYPE bu_nameor1,
         name_first   TYPE bu_namep_f,
         name_last    TYPE bu_namep_l,
         mv_name1     TYPE bu_mcname1,
         mv_name2     TYPE bu_mcname2,
         street       TYPE ad_street,
         house_num1   TYPE ad_hsnm1,
         city1        TYPE ad_city1,
         post_code1   TYPE ad_pstcd1,
         partner_guid TYPE bu_partner_guid,
         addrnumber   TYPE ad_addrnum,
       END OF ty_upddata.

************************************************************************
* Gloable Variablen                                                    *
************************************************************************
DATA: gt_raw_data   TYPE truxs_t_text_data,
      gt_target     TYPE TABLE OF ty_csv,
      gt_upddata    TYPE TABLE OF ty_newdata,
      gt_chgdata    TYPE TABLE OF ty_upddata,
      gs_target     TYPE ty_csv,
      gs_upddata    TYPE ty_newdata,
      gs_chgdata    TYPE ty_upddata,
      gv_rc         TYPE i,
      gt_filetable  TYPE filetable,
      gv_filename   TYPE string,
      gs_but000     TYPE but000,
      gv_lines      TYPE i,
      gv_nlines     TYPE numc06,
      gv_nindex     TYPE numc06,
      gv_prozent    TYPE i,
      gv_msg        TYPE string,
      gv_partner    TYPE bu_partner,
      gv_npartner   TYPE numc10,
      gv_length_f   TYPE i,
      gv_offset_f   TYPE i,
      gv_char       TYPE c,
      gv_wrong_char TYPE c,
      gv_trenner    TYPE c LENGTH 3 VALUE ' | ',
      gv_strmsg     TYPE string.

************************************************************************
* Gloable Feldsymbole                                                  *
************************************************************************
FIELD-SYMBOLS <gfs_chg> TYPE ty_upddata.
