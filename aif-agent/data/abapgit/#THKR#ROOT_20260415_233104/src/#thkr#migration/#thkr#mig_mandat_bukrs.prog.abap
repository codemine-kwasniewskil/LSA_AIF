*&---------------------------------------------------------------------*
*& Report /THKR/MIG_MANDAT_BUKRS
*&---------------------------------------------------------------------*
*& Das Programm soll eine Tabelle übergebener Mandate auf den Buchungskreis zu dem GP prüfen
*& und den BUKRS am Partner ggf. ergnäzen
*&---------------------------------------------------------------------*
REPORT /thkr/mig_mandat_bukrs.

TYPES: BEGIN OF ty_message,
         type         TYPE syst-msgty,
         mndid        TYPE sepa_mndid,
         bukrs        TYPE bukrs,
         partner      TYPE bu_partner,
         dienststelle TYPE /thkr/dte_dienst,
         gsber        TYPE /thkr/dte_bu_gsber,
         message      TYPE char100,
         cnt          TYPE int4,
       END OF ty_message.

DATA:
  lv_partner      TYPE bu_partner,
  lv_dienststelle TYPE /thkr/dte_dienst,
  lv_gsber        TYPE /thkr/dte_bu_gsber,
  lv_bukrs        TYPE bukrs,
  lv_mndid        TYPE sepa_mndid,
  gt_messages     TYPE TABLE OF ty_message,
  gt_file_data    TYPE string_table,
  gv_sepa_mndid   TYPE sepa_mndid,
  gt_filetable    TYPE filetable,
  gs_filetable    TYPE file_table,
  gv_rc           TYPE i.



SELECT-OPTIONS: s_key FOR gv_sepa_mndid.
PARAMETERS: p_file TYPE /thkr/file_w_path LOWER CASE OBLIGATORY,
            p_head TYPE c AS CHECKBOX DEFAULT 'X',
            p_test TYPE c AS CHECKBOX DEFAULT 'X'.


*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*----------------------------------------------------------------------*
  CLEAR: gt_filetable, gv_rc.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      initial_directory       = CONV #( p_file )
    CHANGING
      file_table              = gt_filetable
      rc                      = gv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  READ TABLE gt_filetable INTO gs_filetable INDEX 1.
  IF sy-subrc EQ 0.
    p_file = gs_filetable-filename.
  ENDIF.


START-OF-SELECTION.

* Datei einlesen
  cl_gui_frontend_services=>gui_upload(
    EXPORTING
      filename = CONV #( p_file )
      filetype = 'ASC'
    CHANGING
      data_tab = gt_file_data ).

* Datei Zeilenweise verarveiten
  LOOP AT gt_file_data INTO DATA(lv_data).
    IF p_head = abap_true AND sy-tabix = 1.
      CONTINUE.
    ENDIF.
    CLEAR: lv_bukrs, lv_partner, lv_mndid.

    SPLIT lv_data AT cl_abap_char_utilities=>horizontal_tab INTO TABLE DATA(lt_line).

    " Dienststelle Spalte 23
    lv_dienststelle = lt_line[ 23 ].
    " Geschäftsbereich Spalte 4 oder 5
    lv_gsber = lt_line[ 4 ].
    IF lv_gsber IS INITIAL.
      lv_gsber = lt_line[ 5 ].
    ENDIF.

    " BUKRS  Spalte 2 oder Spalte 3
    lv_bukrs = lt_line[ 2 ].
    IF lv_bukrs IS INITIAL.
      lv_bukrs = lt_line[ 3 ].
    ENDIF.

    " Mandat Spalte 6
    lv_mndid = lt_line[ 6 ].
    IF lv_mndid NOT IN s_key.
      CONTINUE.
    ENDIF.

    IF lv_bukrs IS INITIAL.
      APPEND VALUE #( mndid = lv_mndid  message = 'kein Buchungskreis' type = 'E' cnt = 1 dienststelle = lv_dienststelle gsber = lv_gsber ) TO gt_messages.
      CONTINUE.
    ENDIF.

    IF lv_mndid IS INITIAL.
      APPEND VALUE #(  message = 'keine Mandatsid' type = 'E' cnt = 1 dienststelle = lv_dienststelle gsber = lv_gsber ) TO gt_messages.
      CONTINUE.
    ENDIF.

* Selektion des Mandats
    SELECT SINGLE snd_id FROM sepa_mandate INTO @lv_partner WHERE mndid = @lv_mndid.
    IF sy-subrc <> 0.
      APPEND VALUE #( mndid = lv_mndid bukrs = lv_bukrs message = 'Mandat nicht gefunden' type = 'E' cnt = 1 dienststelle = lv_dienststelle gsber = lv_gsber ) TO gt_messages.
      CONTINUE.
    ENDIF.
* Prüfung ob Buchungskreis vorhanden
    SELECT SINGLE bukrs FROM knb1 INTO @DATA(lv_knb1) WHERE bukrs = @lv_bukrs AND kunnr = @lv_partner.
    IF sy-subrc <> 0.
      TRY.
          IF p_test IS INITIAL.
* Buchungskreis an GP hinzufügen
            /thkr/cl_mig_bp_appl=>mig_get_instance( )->create_new_bukrs(
              i_partner =   lv_partner               " Geschäftspartnernummer
              i_bukrs   =   lv_bukrs               " Buchungskreis
            ).
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          ENDIF.

          APPEND VALUE #( mndid = lv_mndid bukrs = lv_bukrs message = 'BUKRS hinzugefügt' partner = lv_partner type = 'S' cnt = 1 dienststelle = lv_dienststelle gsber = lv_gsber ) TO gt_messages.

        CATCH /thkr/cx_bp INTO DATA(lx_bp).
          APPEND VALUE #( mndid = lv_mndid bukrs = lv_bukrs partner = lv_partner message = lx_bp->get_text( ) type = 'E' cnt = 1 dienststelle = lv_dienststelle gsber = lv_gsber ) TO gt_messages.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDTRY.
    ELSE.
      APPEND VALUE #( mndid = lv_mndid bukrs = lv_bukrs partner = lv_partner message = 'BUKRS vorhanden' type = 'I' cnt = 1 dienststelle = lv_dienststelle gsber = lv_gsber ) TO gt_messages.
    ENDIF.

  ENDLOOP.

* Ausgabe
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                              CHANGING  t_table      = gt_messages ).

      SET PARAMETER ID 'EXCEL_INPLACE' FIELD space.
      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).

      lo_salv->display( ).

    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.
