*&---------------------------------------------------------------------*
*& Include          Z_PSM_DOWNLOAD_PAYAC_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& F4_DATNAM
*&---------------------------------------------------------------------*
*& Lokalen Dateinamen setzen
*&---------------------------------------------------------------------*
FORM f4_datnam
       CHANGING
         c_datnam TYPE localfile.

  DATA: fullpath TYPE string,
        path     TYPE string,
        filename TYPE string.

  CONSTANTS: lc_title TYPE string VALUE 'Dateiauswahl'.
  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      window_title              = lc_title
      default_extension         = '*.CSV'
      default_file_name         = |PAYAC_{ sy-sysid }_{ sy-mandt }_{ sy-datum }.CSV|
      file_filter               = '*.CSV'
    CHANGING
      filename                  = filename          " Dateiname für Sichern
      path                      = path              " Pfad zu Datei
      fullpath                  = fullpath          " Pfad + Dateiname
*     user_action               = user_action       " Benutzeraktion ( K.Konst. ACTION_OK, ACTION_OVERWRITE usw.)
*     file_encoding             = file_encoding
    EXCEPTIONS
      cntl_error                = 1                 " Controlfehler
      error_no_gui              = 2                 " Kein GUI verfügbar
      not_supported_by_gui      = 3                 " Nicht unterstützt von GUI
      invalid_default_file_name = 4                 " Invalider default Dateiname
  ).
  IF sy-subrc = 0.
    p_datnam =  fullpath.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form pruef_datnam
*&---------------------------------------------------------------------*
*& Dateiname prüfen
*&---------------------------------------------------------------------*
FORM pruef_datnam
       USING
         iv_datnam TYPE localfile.

  DATA: lv_datnam_len TYPE i.

  lv_datnam_len = strlen( iv_datnam ).
  IF ( lv_datnam_len > 128 ).
    MESSAGE e300.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form pruef_gjahr_neu
*&---------------------------------------------------------------------*
*& Bei "Jahreswechsel" Eingabe für neues GJAHR prüfen
*&---------------------------------------------------------------------*
FORM pruef_gjahr_neu
  USING
    i_flag_jahreswechsel
    i_gjahr  TYPE gjahr
    i_gj_neu TYPE gjahr.

*
  IF ( i_flag_jahreswechsel IS INITIAL ).
    RETURN.
  ENDIF.

  IF ( i_gj_neu IS INITIAL ).
    MESSAGE e291.
  ENDIF.

  IF ( i_gj_neu <= i_gjahr ).
    MESSAGE e292.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form selektion
*&---------------------------------------------------------------------*
*& Selektion
*&---------------------------------------------------------------------*
FORM selektion
       USING
         iv_fikrs    TYPE fikrs
         iv_gjahr    TYPE gjahr
         iv_druck    TYPE druck
       CHANGING
         ev_dbcnt    TYPE sydbcnt.

*
  CLEAR gt_payac01_d_v.

*
  SELECT *
           FROM /thkr/psmpayac01
           INTO TABLE gt_payac01_d_v
          WHERE fikrs    = iv_fikrs
            AND gjahr    = iv_gjahr
            AND bukfm    IN s_bukfm
            AND druck    = iv_druck
          "  AND zzwfverm IN s_zwfvm
            AND xloeb    = abap_false
            AND xspeb    = abap_false.
*
  ev_dbcnt = sy-dbcnt.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form selektion_zu_download
*&---------------------------------------------------------------------*
*& Abbildung auf Struktur für Download
*&---------------------------------------------------------------------*
FORM selektion_zu_download
  USING
    iv_flag_jahreswechsel
    iv_gjahr  TYPE gjahr
    iv_gj_neu TYPE gjahr
    iv_maxlin TYPE sytabix.

*
  FIELD-SYMBOLS: <ls_payac01_d_v> TYPE /thkr/psmpayac01.
*
  DATA: ls_dl_paya_01 TYPE /thkr/psm_dl_paya_01.
*
  DATA: lv_bkz TYPE /thkr/psm_bkz_upl_payac.
*
  DATA: lv_gjhid TYPE gjhid.

*
  CLEAR gt_dl_paya_01.

*
  IF ( iv_flag_jahreswechsel IS INITIAL ).
    lv_bkz = 'L'.
    lv_gjhid = iv_gjahr.
  ELSE.
    lv_bkz = 'N'.
    lv_gjhid = iv_gj_neu.
  ENDIF.

*
  LOOP AT gt_payac01_d_v ASSIGNING <ls_payac01_d_v>.
* ---
    MOVE: lv_gjhid               TO ls_dl_paya_01-gjhid.
*   move: <ls_payac01_d_v>-gjhid to ls_dl_paya_01-gjhid,
*
    MOVE: <ls_payac01_d_v>-bukfm TO ls_dl_paya_01-bukfm,
          <ls_payac01_d_v>-acind TO ls_dl_paya_01-acind,
          <ls_payac01_d_v>-fipex TO ls_dl_paya_01-fipex,
          <ls_payac01_d_v>-geber TO ls_dl_paya_01-geber,
          <ls_payac01_d_v>-fistl TO ls_dl_paya_01-fistl,
          <ls_payac01_d_v>-psoty TO ls_dl_paya_01-psoty,
          <ls_payac01_d_v>-fkber TO ls_dl_paya_01-fkber,
          <ls_payac01_d_v>-prio1 TO ls_dl_paya_01-prio1,
          <ls_payac01_d_v>-saknr TO ls_dl_paya_01-saknr.
*
    MOVE: lv_bkz                 TO ls_dl_paya_01-bkz.
* ---
    APPEND ls_dl_paya_01 TO gt_dl_paya_01.
* ---
    IF ( iv_maxlin > 0 ).
      IF ( sy-tabix > iv_maxlin ).
        EXIT.
      ENDIF.
    ENDIF.
*
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form download
*&---------------------------------------------------------------------*
*& Download
*&---------------------------------------------------------------------*
FORM download
    USING
      iv_datnam TYPE localfile
    CHANGING
      ev_subrc  TYPE sysubrc.

*
  DATA: lv_fnam TYPE string.
*
  TYPES truxs_t_text_data(4096) TYPE c OCCURS 0.
  DATA: lt_output   TYPE truxs_t_text_data.
*
  lv_fnam = iv_datnam.

  CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
    EXPORTING
      i_field_seperator    = ';'
    TABLES
      i_tab_sap_data       = gt_dl_paya_01
    CHANGING
      i_tab_converted_data = lt_output
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

*
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_fnam
      filetype                = 'ASC'
      append                  = space
      write_field_separator   = abap_true
    CHANGING
      data_tab                = lt_output
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
*
  ev_subrc = sy-subrc.

ENDFORM.
