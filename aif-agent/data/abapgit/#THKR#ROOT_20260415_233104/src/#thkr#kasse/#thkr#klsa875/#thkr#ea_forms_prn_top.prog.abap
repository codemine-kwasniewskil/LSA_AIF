*&---------------------------------------------------------------------*
*& Include /thkr/EA_FORMS_PRN_TOP                     - Report /thkr/EA_FORMS_PRN
*&---------------------------------------------------------------------*
REPORT /thkr/ea_forms_prn MESSAGE-ID /thkr/fi_ea_forms.

TYPE-POOLS slis.

CONSTANTS:
  gc_true           TYPE char1  VALUE 'X',
  gc_unbekannt      TYPE string VALUE 'unbekannt',
  gc_land1          TYPE land1 VALUE 'DE',
  gc_screen_display TYPE char1 VALUE 'X',
  gc_14_days        TYPE i VALUE 14,
  gc_28_days        TYPE i VALUE 28,
  gc_42_days        TYPE i VALUE 42,
  gc_49_days        TYPE i VALUE 49,
  gc_max_comp       TYPE i VALUE 255,
  gc_35_strlen      TYPE i VALUE 35,
  gc_produkt        TYPE string VALUE 'DstAnfragen',
  gc_log_path_s_bw  TYPE pathintern VALUE 'Z_SST_OUT_0099_S-BW',
  BEGIN OF gc_device,
    printer  TYPE output_device VALUE 'P',
    fax      TYPE output_device VALUE 'F',
    email    TYPE output_device VALUE 'E',
    file     TYPE output_device VALUE 'D',
    mail_int TYPE output_device VALUE 'I',
  END OF gc_device.

TYPES: BEGIN OF gs_emailaddr_ty,
         receiver TYPE so_recname,
       END OF gs_emailaddr_ty.

DATA: gs_outputparams   TYPE sfpoutputparams,
      gs_docparams      TYPE sfpdocparams,
      gv_form           TYPE tdsfname,
      gv_fm_name        TYPE rs38l_fnam,
      gs_pdf_file       TYPE fpformoutput,
      gv_device         TYPE char1,                  "output_device
      gv_language       TYPE sylangu,
      gs_zfi_ea_fo      TYPE /thkr/ea_fo,
      gv_formid         TYPE /thkr/ea_formid,
      gv_variant        TYPE /thkr/ea_variant,
      gv_formtype_bez   TYPE /thkr/ea_formtype_bez,
      gs_absender       TYPE /thkr/ea_fo_abs,
      gv_screen_display TYPE char1,
      gs_worklist_fe    TYPE feb_bsproc_worklist_fe,
      gt_febre          TYPE TABLE OF febre,
      gt_febre_orig     TYPE TABLE OF febre_orig,
      gs_fp_data        TYPE /thkr/ea_fp_data,
      gt_zfi_ea_fo_tb   TYPE SORTED TABLE OF /thkr/ea_fo_tb WITH UNIQUE KEY formid variant objectid,
      gt_email_addr     TYPE STANDARD TABLE OF gs_emailaddr_ty,
* screen variables
      gv_mail_rc_user   TYPE xubname,                 "Mail Empfänger intern
      gs_email_addr     TYPE gs_emailaddr_ty,
      gv_email_addr     TYPE so_recname,              "Mail Empfänger extern
      gv_tland          TYPE land1,                   "Fax  Empfänger Land
      gv_telfx          TYPE na_telfx,                "Fax  Empfänger
      gv_printer        TYPE rspopname VALUE 'PDF1',  "Drucker
      okcode            TYPE okcode,
      gv_fikrs          TYPE fikrs VALUE '1000',
      gv_fictr          TYPE fistl,
      gv_fictr_bezei    TYPE fm_bezeich,
      gv_frist          TYPE datum,
      gv_banks          TYPE banks,
      gv_bankl          TYPE bankk,
      gv_bankl_old      TYPE bankk,
      gv_banka          TYPE banka,
      gv_abskey         TYPE /thkr/ea_abskey,
      gv_kunnr          TYPE kunnr,
      gv_name1          TYPE name1,
      gv_zuviel1        TYPE xflag,
      gv_zuviel2        TYPE xflag,
      gv_fax            TYPE xflag,
      gv_druck          TYPE xflag,
      gv_mail_ex        TYPE xflag,
      gv_mail_in        TYPE xflag,
      gv_betreff        TYPE text50,
      gv_ao_kassze      TYPE xblnr1,
      gv_status_alt     TYPE /thkr/ea_status_alt,
      gv_kukey          TYPE kukey_eb,
      gv_esnum          TYPE esnum_eb,
      gv_service_bw     TYPE xflag,
      gv_bankvermerk    TYPE /thkr/ea_bank_vermerk,
      gv_kennzeichen    TYPE string,
      gv_postfach_id    TYPE string,
      gv_new            type xfeld.


DATA: gv_line_length      TYPE i VALUE 254,
      gr_editor_container TYPE REF TO cl_gui_custom_container,
      gr_text_editor      TYPE REF TO cl_gui_textedit,
      gv_text             TYPE string,
      gv_edit_cont        TYPE string.


SELECTION-SCREEN BEGIN OF BLOCK one WITH FRAME TITLE TEXT-s01.
  PARAMETERS: p_kukey TYPE febep-kukey OBLIGATORY,                        "MATCHCODE OBJECT /thkr/ea_febep_hlp
              p_esnum TYPE febep-esnum OBLIGATORY.                        "MATCHCODE OBJECT /thkr/ea_febep_hlp
SELECTION-SCREEN END OF BLOCK one.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK two WITH FRAME TITLE TEXT-s02.
  PARAMETERS: p_formid TYPE /thkr/ea_fo-formid OBLIGATORY,                  "MATCHCODE OBJECT /thkr/ea_formid_hlp
              p_vari   TYPE /thkr/ea_fo-variant OBLIGATORY.                 "MATCHCODE OBJECT /thkr/ea_formid_hlp
SELECTION-SCREEN END OF BLOCK two.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'GTC_EMAIL_ADDR' ITSELF
CONTROLS: GTC_EMAIL_ADDR TYPE TABLEVIEW USING SCREEN 0105.
