*&---------------------------------------------------------------------*
*& Include          /THKR/PSM_UPLOAD_PAYAC_S1_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_filename
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- PA_FILE
*&---------------------------------------------------------------------*
FORM get_filename  CHANGING p_v_file TYPE localfile.

  DATA: lt_files TYPE filetable,
        ls_files TYPE file_table,
        lv_rc    TYPE i.

  CONSTANTS: lc_title TYPE string VALUE 'Dateiauswahl'.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = lc_title
      default_extension       = '*.CSV'
      default_filename        = '*.CSV'
      file_filter             = '*.CSV'
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
*     user_action             =
*     file_encoding           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0 AND lt_files IS NOT INITIAL.
    READ TABLE lt_files INTO ls_files INDEX 1.
    IF sy-subrc = 0.
      p_v_file = ls_files-filename.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_filelen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PA_FILE
*&---------------------------------------------------------------------*
FORM check_filelen  USING    p_v_file TYPE localfile.

  DATA: lv_filelen TYPE i.

  lv_filelen = strlen( p_v_file ).

  IF lv_filelen GT 128.
    MESSAGE e300(/thkr/fi_init).
*   Der Dateiname ist zu lang.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Protokoll_ausgeben
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UPLOAD
*&---------------------------------------------------------------------*
FORM protokoll_ausgeben  USING    p_t_upload TYPE gtt_upload.

  DATA: lv_title TYPE lvc_title.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.

* Feldkatalog aufbauen
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-cprog
      i_internal_tabname     = 'GT_UPLOAD'
      i_structure_name       = '/THKR/PSM_UPL_PAYAC'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_INCLNAME             =
*     I_BYPASSING_BUFFER     =
*     I_BUFFER_ACTIVE        =
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc NE 0.
* Implement suitable error handling here
  ENDIF.


* Protokoll ausgeben

  IF p_test IS INITIAL.
    lv_title = TEXT-002.
  ELSE.
    lv_title = TEXT-001.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER = ' '
*     I_BUFFER_ACTIVE    = ' '
      i_callback_program = sy-cprog
      i_structure_name   = '/THKR/PSM_UPL_PAYAC'
      i_grid_title       = lv_title
*     I_GRID_SETTINGS    =
*     IS_LAYOUT          =
      it_fieldcat        = lt_fieldcat
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
*     IT_SORT            =
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
*     I_SAVE             = ' '
*     IS_VARIANT         =
*     IT_EVENTS          =
*     IT_EVENT_EXIT      =
    TABLES
      t_outtab           = p_t_upload
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form check_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_UPLOAD
*&---------------------------------------------------------------------*
FORM check_data
       CHANGING
         ct_upload TYPE gtt_upload.

*
  DATA: lv_tabix TYPE sy-tabix.

  FIELD-SYMBOLS: <ls_upload> TYPE gts_upload.
*
  DATA: lv_saknr TYPE saknr.
*
  DATA: lv_dbcnt TYPE sydbcnt.

*
  LOOP AT ct_upload ASSIGNING <ls_upload>.

* --- Default: Grüne Ampel
    <ls_upload>-ampel = gc_green.

* --- GJahr
    IF ( <ls_upload>-gjhid < 2020 ) OR
       ( <ls_upload>-gjhid > 9999 ).
* --- ---
      <ls_upload>-message = 'GJahr Identifikation ungültig'(003).
      <ls_upload>-ampel   = gc_red.
* ---
    ENDIF.


* --- Buchungskreisgruppe
    IF ( <ls_upload>-bukfm IS INITIAL ).
* --- ---
      <ls_upload>-message = 'Buchungskreisgruppe nicht gefüllt'(004).
      <ls_upload>-ampel   = gc_red.
* ---
    ELSE.
* --- ---
      SHIFT   <ls_upload>-bukfm RIGHT DELETING TRAILING space.
      OVERLAY <ls_upload>-bukfm WITH '0000'.
* --- ---
      SELECT COUNT( * )
        FROM payac05
        INTO lv_dbcnt
        WHERE bukfm = <ls_upload>-bukfm.
* --- ---
      IF ( lv_dbcnt = 0 ).
* --- --- ---
        <ls_upload>-message = 'Buchungskreisgruppe ungültig'(005).
        <ls_upload>-ampel   = gc_red.
* --- ---
      ENDIF.
* ---
    ENDIF.


* --- MKto-Findung
    IF ( <ls_upload>-acind IS INITIAL ).
      IF <ls_upload>-bkz <> 'N'.
* --- --- Merkmal muss bei vorhandenen Einträgen gefüllt sein
        <ls_upload>-message = 'Merkmal zur Kontenfindung nicht angegeben'(007).
        <ls_upload>-ampel   = gc_red.
      ENDIF.
* ---
    ELSE.
* --- ---
      SELECT COUNT( * )
      FROM payac08
      INTO lv_dbcnt
      WHERE acind = <ls_upload>-acind.
* --- ---
      IF ( lv_dbcnt = 0 ).
* --- --- ---
        <ls_upload>-message = 'Merkmal zur Kontenfindung ungültig'(006).
        <ls_upload>-ampel   = gc_red.
* --- ---
      ENDIF.
* ---
    ENDIF.


* --- Finanzposition
    IF ( <ls_upload>-fipex IS NOT INITIAL ).
* --- --- Punkte löschen, falls Daten manuell eingefügt wurden
      REPLACE ALL OCCURRENCES OF '.' IN <ls_upload>-fipex WITH ''.
* --- ---
      SELECT COUNT( * )
        FROM fmci
        INTO lv_dbcnt
        WHERE fikrs = gc_fikrs
          AND gjahr = <ls_upload>-gjhid
          AND fipex = <ls_upload>-fipex.
* --- ---
      IF ( sy-subrc <> 0 ).
        <ls_upload>-message = 'Finanzposition ist ungültig'(009).
        <ls_upload>-ampel   = gc_red.
      ENDIF.
* ---
    ELSE.
* --- ---
      <ls_upload>-message = 'Finanzposition nicht gefüllt'(008).
      <ls_upload>-ampel   = gc_red.
* ---
    ENDIF.


* --- Fonds
    IF ( <ls_upload>-geber IS NOT INITIAL ).
* --- ---
      SELECT COUNT( * )
        FROM fmfincode
        INTO lv_dbcnt
        WHERE fikrs   = gc_fikrs
          AND fincode = <ls_upload>-geber.
* --- ---
      IF ( lv_dbcnt = 0 ).
* --- --- ---
        <ls_upload>-message = 'Fonds ungültig'(010).
        <ls_upload>-ampel   = gc_red.
* --- ---
      ENDIF.
* ---
    ENDIF.


* --- Budgetperiode
    IF ( <ls_upload>-budget_pd IS NOT INITIAL ).
* --- ---
      SELECT COUNT( * )
        FROM psm_fmfundbpd "psmfmfundbpd
        INTO @lv_dbcnt
        WHERE fikrs     = @gc_fikrs
          AND fincode   = @<ls_upload>-geber
          AND budget_pd = @<ls_upload>-budget_pd.
* --- ---
      IF ( lv_dbcnt = 0 ).
* --- --- ---
        <ls_upload>-message = 'Budgetperiode ungültig'(012).
        <ls_upload>-ampel   = gc_red.
* --- ---
      ENDIF.
* ---
    ENDIF.


* --- Finanzstelle
    IF ( <ls_upload>-fistl IS NOT INITIAL ).
* --- ---
      SELECT fictr
        FROM fmfctr
        INTO <ls_upload>-fistl
        UP TO 1 ROWS
        WHERE fikrs   = gc_fikrs
          AND fictr   = <ls_upload>-fistl
          AND datbis >= sy-datum.
      ENDSELECT.
* --- ---
      IF ( sy-subrc <> 0 ).
        <ls_upload>-message = 'Finanzstelle ungültig'(014).
        <ls_upload>-ampel   = gc_red.
      ENDIF.
* ---
    ENDIF.


* --- Funktionsbereich
    IF ( <ls_upload>-fkber IS NOT INITIAL ).
* --- ---
      SELECT COUNT( * )
        FROM tfkb
        INTO lv_dbcnt
        WHERE fkber = <ls_upload>-fkber.
* --- ---
      IF ( lv_dbcnt = 0 ).
* --- ---
        <ls_upload>-message = 'Funktionsbereich ungültig'(016).
        <ls_upload>-ampel   = gc_red.
* --- ---
      ENDIF.
* ---
    ENDIF.


* --- Anordnungstyp
    IF ( <ls_upload>-psoty IS NOT INITIAL ).
* --- ---
      SELECT COUNT( * )
        FROM psotp
        INTO lv_dbcnt
        WHERE psotyp = <ls_upload>-psoty.
* --- ---
      IF ( lv_dbcnt = 0 ).
        <ls_upload>-message = 'Anordnungstyp ungültig'(018).
        <ls_upload>-ampel   = gc_red.
      ENDIF.
* ---
    ENDIF.


* Priorität
    IF ( <ls_upload>-prio1 IS NOT INITIAL ).
      IF ( <ls_upload>-prio1 GT 000 AND <ls_upload>-prio1 GE 999 ).
        <ls_upload>-message = 'Priorität ungültig'(020).
        <ls_upload>-ampel   = gc_red.
      ENDIF.
    ENDIF.


*	--- Sachkonto
    IF ( <ls_upload>-saknr IS INITIAL ).
* --- ---
      <ls_upload>-message = 'Sachkonto nicht gefüllt'(023).
      <ls_upload>-ampel   = gc_red.
* ---
    ELSE.
* --- ---
      MOVE <ls_upload>-saknr TO lv_saknr.               "BTO_20210318
* --- ---
      SHIFT lv_saknr RIGHT DELETING TRAILING ' '.
      OVERLAY lv_saknr WITH '0000000000'.
* --- ---
      IF ( lv_saknr CO '0123456789' ).                      "BTO_20210318
        MOVE lv_saknr TO <ls_upload>-saknr.           "BTO_20210318
      ENDIF.                                            "BTO_20210318
* --- ---
      SELECT COUNT( * )
        FROM ska1
        INTO lv_dbcnt
        WHERE ktopl = gc_ktopl
          AND saknr = <ls_upload>-saknr.
* ---
      IF ( lv_dbcnt = 0 ).
        <ls_upload>-message = 'Sachkonto ungültig'(022).
        <ls_upload>-ampel   = gc_red.
      ENDIF.

    ENDIF.


* --- Kennzeichen
    IF ( <ls_upload>-bkz IS INITIAL ).
* --- ---
      <ls_upload>-message = 'Bearbeitungskennzeichen nicht gefüllt'(025).
      <ls_upload>-ampel   = gc_red.
* ---
    ELSE.
* --- ---
      SELECT domvalue_l
        FROM dd07l
        INTO <ls_upload>-bkz
        UP TO 1 ROWS
        WHERE domname = '/THKR/PSM_BKZ_UPL_PAYAC'
          AND domvalue_l = <ls_upload>-bkz.
* --- ---
      ENDSELECT.
* --- ---
      IF ( sy-subrc <> 0 ).
        <ls_upload>-message = 'Bearbeitungskennzeichen ist ungültig'(024).
        <ls_upload>-ampel = gc_red.
      ENDIF.
* ---
    ENDIF.

* ---
    IF ( <ls_upload>-ampel = gc_red ).
      gv_fehler = abap_true.
    ENDIF.

*
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form get_upl_data
*&---------------------------------------------------------------------*
*& Upload lokal
*&---------------------------------------------------------------------*
FORM get_upl_data_local
  USING
    p_file TYPE localfile
  CHANGING
    p_t_upload TYPE gtt_upload.

*
  DATA: BEGIN OF ls_upload,
          gjhid     TYPE gjhid,
          bukfm     TYPE bukfm,
          acind     TYPE acind,
          fipex     TYPE fipps,
          geber     TYPE bp_geber,
          budget_pd TYPE fm_budget_period,
          fistl     TYPE fistl,
          psoty     TYPE psoty_d,
          fkber     TYPE fkber,
          prio1     TYPE prior,
          saknr     TYPE saknr,
          bkz       TYPE /thkr/psm_bkz_upl_payac,
        END OF ls_upload,
        lt_upload LIKE TABLE OF ls_upload.

  DATA: lv_file TYPE string.
  DATA: lt_data TYPE textline_t,
        ls_data TYPE textline.

  DATA: lo_csv TYPE REF TO cl_rsda_csv_converter.

  lv_file = p_file.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_file
      filetype                = 'ASC'
      has_field_separator     = abap_true
    CHANGING
      data_tab                = lt_data
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
*
  IF ( sy-subrc <> 0 ).
* Implement suitable error handling here
  ENDIF.

  CALL METHOD cl_rsda_csv_converter=>create
    EXPORTING
      i_separator = ';'
    RECEIVING
      r_r_conv    = lo_csv.

  LOOP AT lt_data INTO ls_data.

    CALL METHOD lo_csv->csv_to_structure
      EXPORTING
        i_data   = ls_data
      IMPORTING
        e_s_data = ls_upload.

    IF ls_upload-gjhid CO '0123456789'.
* Zeile übernehmen
      APPEND ls_upload TO lt_upload.
    ENDIF.
  ENDLOOP.

  MOVE-CORRESPONDING lt_upload TO p_t_upload.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_UPLOAD
*&---------------------------------------------------------------------*
FORM save_data  CHANGING p_t_upload TYPE gtt_upload.

  DATA: lv_index  TYPE sy-index,
        lv_acind  TYPE acind,
        lv_change TYPE xfeld.

  DATA: ls_upload TYPE gts_upload,
        ls_payac  TYPE payac01,
        lt_payac  TYPE TABLE OF payac01.

*--------------------------------------------------------------------*
* löschen
*--------------------------------------------------------------------*
  LOOP AT p_t_upload INTO ls_upload
                    WHERE ampel = gc_green
                      AND bkz = 'L'.
    CLEAR ls_payac.
    MOVE-CORRESPONDING ls_upload TO ls_payac.
    APPEND ls_payac TO lt_payac.
  ENDLOOP.

  IF lt_payac IS NOT INITIAL.
    DELETE payac01 FROM TABLE lt_payac.
    IF sy-subrc NE 0.
      gv_fehler = abap_true.
      ls_upload-ampel = gc_red.
    ELSE.
      lv_change = abap_true.
    ENDIF.
    CLEAR lt_payac.
  ENDIF.

*--------------------------------------------------------------------*
* ändern
*--------------------------------------------------------------------*
  CHECK gv_fehler IS INITIAL.
  CLEAR lt_payac.
  LOOP AT p_t_upload INTO ls_upload
                  WHERE ampel = gc_green
                    AND bkz = 'A'.
    CLEAR ls_payac.
    MOVE-CORRESPONDING ls_upload TO ls_payac.
    APPEND ls_payac TO lt_payac.
  ENDLOOP.

  IF lt_payac IS NOT INITIAL.
    MODIFY payac01 FROM TABLE lt_payac.
    IF sy-subrc NE 0.
      gv_fehler = abap_true.
      ls_upload-ampel = gc_red.
    ELSE.
      lv_change = abap_true.
    ENDIF.
    CLEAR lt_payac.
  ENDIF.

*--------------------------------------------------------------------*
* anlegen
*--------------------------------------------------------------------*
  CHECK gv_fehler IS INITIAL.

  LOOP AT p_t_upload INTO ls_upload
                    WHERE ampel = gc_green
                      AND bkz = 'N'.
    lv_index = sy-tabix.

    IF ls_upload-acind IS INITIAL.
*     Merkmal ermitteln
      PERFORM get_acind CHANGING ls_upload
                                 lv_acind.
    ENDIF.
*   Datensatz anlegen
    CLEAR ls_payac.
    MOVE-CORRESPONDING ls_upload TO ls_payac.
    INSERT payac01 FROM ls_payac.
    IF sy-subrc NE 0.
      gv_fehler = abap_true.
      ls_upload-ampel = gc_red.
    ELSE.
      lv_change = abap_true.
    ENDIF.
*   Änderungen für Protokoll merken
    MODIFY p_t_upload FROM ls_upload INDEX lv_index.
  ENDLOOP.

*--------------------------------------------------------------------*
* Commit
*--------------------------------------------------------------------*
  IF gv_fehler IS INITIAL AND lv_change IS NOT INITIAL.
    COMMIT WORK AND WAIT.
    MESSAGE s304(/thkr/fi_init) .
* Die Änderungen wurden erfolgreich in der Tabelle PAYAC01 gespeichert.
  ELSEIF gv_fehler IS NOT INITIAL.
    ROLLBACK WORK.
    MESSAGE s305(/thkr/fi_init) .
* Die Änderungen konnten nicht gespeichert werden.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_payac
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_UPLOAD
*&---------------------------------------------------------------------*
FORM check_payac
       CHANGING
         ct_upload TYPE gtt_upload.

*
  DATA: lv_index TYPE sy-tabix.

*
  FIELD-SYMBOLS: <ls_upload> TYPE gts_upload.


  DATA: ls_payac TYPE payac01,
        lt_payac LIKE TABLE OF ls_payac.

*
  SELECT * FROM payac01
    INTO CORRESPONDING FIELDS OF TABLE lt_payac
    FOR ALL ENTRIES IN ct_upload
    WHERE gjhid = ct_upload-gjhid
      AND bukfm = ct_upload-bukfm
      AND acind = ct_upload-acind
      AND fipex = ct_upload-fipex
      AND saknr = ct_upload-saknr.

*
  LOOP AT ct_upload ASSIGNING <ls_upload> WHERE ampel = gc_green.

* ---
    CASE <ls_upload>-bkz.

* --- --- Kennzeichen N - Neuanlage in PAYAC01
* --- --- Es darf noch kein Datensatz mit diesem Schlüssel vorhanden sein.
      WHEN 'N'.

        READ TABLE lt_payac WITH KEY  gjhid = <ls_upload>-gjhid
                                      bukfm = <ls_upload>-bukfm
                                      fipex = <ls_upload>-fipex
                                      saknr = <ls_upload>-saknr
                                 INTO ls_payac.
* ---
        IF ( sy-subrc = 0 ).
          <ls_upload>-message = 'Der Datensatz ist bereits vorhanden'(028).
          <ls_upload>-ampel   = gc_red.
          gv_fehler           = 'X'.
        ENDIF.

* --- --- Kennzeichen: A - Ändern in PAYAC01; L - Löschen in PAYAC01
* --- --- Es muss jeweils ein Datensatz mit vollständigem Schlüssel vorhanden sein.
      WHEN OTHERS.

        READ TABLE lt_payac WITH KEY gjhid = <ls_upload>-gjhid
                                     bukfm = <ls_upload>-bukfm
                                     acind = <ls_upload>-acind
                                     fipex = <ls_upload>-fipex
                                     saknr = <ls_upload>-saknr
                                     geber = <ls_upload>-geber
                                     budget_pd  = <ls_upload>-budget_pd
                                     fistl = <ls_upload>-fistl
                                     psoty = <ls_upload>-psoty
                                     fkber = <ls_upload>-fkber
                                 INTO ls_payac.
* ---
        IF ( sy-subrc <> 0 ).
          <ls_upload>-message = 'Der Datensatz ist nicht vorhanden'(029).
          <ls_upload>-ampel   = gc_red.
          gv_fehler           = 'X'.
        ENDIF.

* ---
    ENDCASE.

*
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form get_acind
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_UPLOAD
*&      <-- LV_ACIND
*&---------------------------------------------------------------------*
FORM get_acind  CHANGING p_s_upload   TYPE gts_upload
                         p_v_acind    TYPE acind.

  DATA: lv_num    TYPE i.

  DATA: ls_payac TYPE payac01,
        lt_payac TYPE TABLE OF payac01.

  CLEAR: lt_payac, p_v_acind.

* Initialwert setzen
  p_v_acind = 'M01'.
  lv_num = '1'.

  SELECT * FROM payac01
    INTO CORRESPONDING FIELDS OF TABLE lt_payac
    WHERE gjhid = p_s_upload-gjhid
     AND  bukfm = p_s_upload-bukfm
     AND  fipex = p_s_upload-fipex
     AND  geber = p_s_upload-geber
     AND  budget_pd = p_s_upload-budget_pd
     AND  fistl = p_s_upload-fistl
     AND  psoty = p_s_upload-psoty
     AND  fkber = p_s_upload-fkber.

  IF sy-subrc NE 0.
*   Initialwert übernehmen
    p_s_upload-acind = p_v_acind.
  ELSE.
    SORT lt_payac BY acind.
*   nächste freie Nummer ermitteln
    LOOP AT lt_payac INTO ls_payac.
      IF ls_payac-acind+1(2) GT  p_v_acind+1(2).
        p_s_upload-acind = p_v_acind.
        EXIT.
      ENDIF.
*     Wert im Intervall hochzählen
      IF lv_num LT 99.
        lv_num =  lv_num + 1.
        p_v_acind+1(2) = lv_num.
        IF lv_num LE 9.
          SHIFT p_v_acind+1(2) RIGHT.
        ENDIF.
        OVERLAY p_v_acind+1(2) WITH '00'.
      ELSE.
*       Nächstes Intervall ermitteln
        CASE p_v_acind(1).
          WHEN 'M'.
            p_v_acind = 'N01'.
          WHEN 'N'.
            p_v_acind = 'O01'.
          WHEN OTHERS.
            MESSAGE e303(/thkr/fi_init) WITH p_v_acind.
*           Nicht ausreichend freie Kontenfindungsmerkmale
*           vorhanden. (Max: &1)
        ENDCASE.
*       Nummer für neues Intervall zurücksetzen
        lv_num = '1'.
      ENDIF.
    ENDLOOP.
    IF p_s_upload-acind IS INITIAL.
*         Keinen freien Wert gefunden, neuen Wert vergeben
      p_s_upload-acind = p_v_acind.
    ENDIF.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form get_upl_data_server
*&---------------------------------------------------------------------*
*& Upload vom Server
*&---------------------------------------------------------------------*
FORM get_upl_data_server
  CHANGING
    ct_upload TYPE gtt_upload.

*
  DATA: lv_path_phys TYPE pathextern,
        lv_dirnam    TYPE epsdirnam.
*
  DATA: lt_epsfili TYPE STANDARD TABLE OF epsfili,
        ls_epsfili TYPE                   epsfili.

*
  DATA: BEGIN OF ls_upload,
          gjhid     TYPE gjhid,
          bukfm     TYPE bukfm,
          acind     TYPE acind,
          fipex     TYPE fipps,
          geber     TYPE bp_geber,
          budget_pd TYPE fm_budget_period,
          fistl     TYPE fistl,
          psoty     TYPE psoty_d,
          fkber     TYPE fkber,
          prio1     TYPE prior,
          saknr     TYPE saknr,
          bkz       TYPE /thkr/psm_bkz_upl_payac,
        END OF ls_upload,
        lt_upload LIKE TABLE OF ls_upload.

  DATA: lv_file TYPE string.
  DATA: lt_data TYPE textline_t,
        ls_data TYPE textline.

  DATA: lo_csv TYPE REF TO cl_rsda_csv_converter.
*
  DATA: lv_data(400).

*
  CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
    EXPORTING
*     CLIENT                     = SY-MANDT
      logical_path               = 'Z_PSM_PAYAC'
*     OPERATING_SYSTEM           = SY-OPSYS
*     PARAMETER_1                = ' '
*     PARAMETER_2                = ' '
*     PARAMETER_3                = ' '
*     USE_BUFFER                 = ' '
      file_name                  = 'Z'
*     USE_PRESENTATION_SERVER    = ' '
*     ELEMINATE_BLANKS           = 'X'
    IMPORTING
      file_name_with_path        = lv_path_phys
    EXCEPTIONS
      path_not_found             = 1
      missing_parameter          = 2
      operating_system_not_found = 3
      file_system_not_found      = 4
      OTHERS                     = 5.
*
  IF ( sy-subrc <> 0 ).
    RETURN.
  ELSE.
    SHIFT lv_path_phys RIGHT DELETING TRAILING space.
    SHIFT lv_path_phys RIGHT.
    SHIFT lv_path_phys LEFT DELETING LEADING space.
    lv_dirnam = lv_path_phys.
  ENDIF.

*
  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name               = lv_dirnam
*     FILE_MASK              = ' '
* IMPORTING
*     DIR_NAME               =
*     FILE_COUNTER           =
*     ERROR_COUNTER          =
    TABLES
      dir_list               = lt_epsfili
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.
*
  IF ( sy-subrc <> 0 ).
    RETURN.
  ENDIF.

*
  CALL METHOD cl_rsda_csv_converter=>create
    EXPORTING
      i_separator = ';'
    RECEIVING
      r_r_conv    = lo_csv.

*
  LOOP AT lt_epsfili INTO ls_epsfili.
* ---
*    if ( ls_epsfili-name ns 'T_02' ). continue. endif.   "BTO 220105 Wofür, daher auskommentiert

* ---
    CONCATENATE lv_dirnam ls_epsfili-name INTO lv_path_phys.
* ---
    OPEN DATASET lv_path_phys FOR INPUT IN TEXT MODE ENCODING DEFAULT.
* ---
    DO.
* --- ---
      READ DATASET lv_path_phys INTO lv_data.
* --- ---
      IF ( sy-subrc <> 0 ).
        EXIT.
      ENDIF.
* --- ---
      CALL METHOD lo_csv->csv_to_structure
        EXPORTING
          i_data   = lv_data "ls_data
        IMPORTING
          e_s_data = ls_upload.
* --- ---
      IF ( ls_upload-gjhid CO '0123456789' ).
        APPEND ls_upload TO lt_upload.
      ENDIF.
* ---
    ENDDO.
* ---
    CLOSE DATASET lv_path_phys.
*
  ENDLOOP.

*
  MOVE-CORRESPONDING lt_upload TO ct_upload.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form db_tmp_insert
*&---------------------------------------------------------------------*
*& Db Insert: temp. Table
*&---------------------------------------------------------------------*
FORM db_tmp_insert
  USING
    it_upload TYPE gtt_upload
  CHANGING
    ev_upl_tmp TYPE sydbcnt.

*
  DATA: lt_tmp TYPE STANDARD TABLE OF /thkr/psmulpaytm,
        ls_tmp TYPE                    /thkr/psmulpaytm.


  DATA: lv_acind       TYPE acind,
        lv_acind_char1 TYPE char1,
        lv_acind_numc2 TYPE numc2.
*
  FIELD-SYMBOLS: <ls_tmp> TYPE  /thkr/psmulpaytm.
*
  DATA: ls_tmp_pred TYPE  /thkr/psmulpaytm.


*
  MOVE-CORRESPONDING it_upload TO lt_tmp.

*
  SORT lt_tmp BY gjhid
                 bukfm
*                acind   "REPRO-FUM 20220113
                 fipex
                 geber
                 budget_pd
                 fistl
                 psoty
                 fkber
                 saknr.   "BTO 20220105
*
  DELETE ADJACENT DUPLICATES FROM lt_tmp
       COMPARING gjhid
                 bukfm
*                acind     "REPRO-FUM 20220113
                 fipex
                 geber
                 budget_pd
                 fistl
                 psoty
                 fkber
                 saknr.    "BTO 20220105

* >>> START INSERT REPRO-FUM 20220110

* Init
  lv_acind_char1 = 'M'.
  lv_acind_numc2 = '00'.

*
  LOOP AT lt_tmp ASSIGNING <ls_tmp>
                 WHERE bkz = 'N'.

* --- Gleiche Zuordnung: Hochzählen kann Intervallwechsel erforderlich machen
    IF ( <ls_tmp>-gjhid     = ls_tmp_pred-gjhid ) AND
       ( <ls_tmp>-bukfm     = ls_tmp_pred-bukfm ) AND
       ( <ls_tmp>-fipex     = ls_tmp_pred-fipex ) AND
       ( <ls_tmp>-geber     = ls_tmp_pred-geber ) AND
       ( <ls_tmp>-budget_pd = ls_tmp_pred-budget_pd ) AND
       ( <ls_tmp>-fistl     = ls_tmp_pred-fistl ) AND
       ( <ls_tmp>-psoty     = ls_tmp_pred-psoty ) AND
       ( <ls_tmp>-fkber     = ls_tmp_pred-fkber ).
* --- ---
      IF ( lv_acind_numc2 = '99' ).
* --- --- --- Nächstes Intervall ermitteln
        CASE lv_acind_char1.
          WHEN 'M'.
            lv_acind_char1 = 'N'.
            lv_acind_numc2 = '00'.
          WHEN 'N'.
            lv_acind_char1 = 'O'.
            lv_acind_numc2 = '00'.
          WHEN OTHERS.
            MESSAGE e303(/thkr/fi_init) WITH lv_acind.
*           Nicht ausreichend freie Kontenfindungsmerkmale
*           vorhanden. (Max: &1)
* --- ---  ---
        ENDCASE.
* --- ---
      ENDIF.

* --- Wechsel von Schlüssel / Zuordnung: Init
    ELSE.
* --- ---
      lv_acind_char1 = 'M'.
      lv_acind_numc2 = '00'.
* ---
    ENDIF.

* --- Hochzählen
    ADD 1 TO lv_acind_numc2.
* --- Merkmal zusammensetzen
    CONCATENATE lv_acind_char1 lv_acind_numc2 INTO lv_acind.
* --- Merkmal übernehmen
    <ls_tmp>-acind = lv_acind.

* --- Wert des Vorgängers merken
    MOVE-CORRESPONDING <ls_tmp> TO ls_tmp_pred.

*
  ENDLOOP.
* >>> ENDE  INSERT REPRO-FUM 20220110

** TEST
*  loop at lt_tmp into ls_tmp.
*    insert zpsm_ul_paya_tmp from ls_tmp.
*    if ( sy-subrc <> 0 ).
*      write: sy-tabix.
*      exit.
*    else.
*      commit work.
*    endif.
*  endloop.
**
*  return.
** TEST

*
  INSERT /thkr/psmulpaytm FROM TABLE lt_tmp.
*
  COMMIT WORK.
*
  ev_upl_tmp = sy-dbcnt.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form db_tmp_select
*&---------------------------------------------------------------------*
*& Select TMP
*&---------------------------------------------------------------------*
FORM db_tmp_select
  CHANGING
     ct_upload  TYPE gtt_upload.
*    ev_upl_tmp type sydbcnt. " >>> REPRO-FUM 20220113

*
  DATA: lt_tmp TYPE STANDARD TABLE OF  /thkr/psmulpaytm.
*
  DATA: lv_ampel TYPE icon_d.

*
  SELECT *
    FROM /thkr/psmulpaytm
    INTO TABLE lt_tmp
*   up to gc_sel_max rows " >>> REPRO-FUM 20220113
    WHERE ampel = lv_ampel.

*
  MOVE-CORRESPONDING lt_tmp TO ct_upload.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form db_tmp_update
*&---------------------------------------------------------------------*
*& TMP Update
*&---------------------------------------------------------------------*
FORM db_tmp_update
  USING
    ct_upload.

*
  DATA: lt_tmp TYPE STANDARD TABLE OF  /thkr/psmulpaytm,
        ls_tmp TYPE                    /thkr/psmulpaytm.
*
  DATA: lv_ampel TYPE icon_d.

*
  MOVE-CORRESPONDING ct_upload TO lt_tmp.

*
  LOOP AT lt_tmp INTO ls_tmp.
* ---
    IF ( gv_fehler IS INITIAL ).
* --- ---
      UPDATE  /thkr/psmulpaytm
        SET ampel    = gc_green
            upl_dats = sy-datum
            upl_tims = sy-uzeit
        WHERE gjhid = ls_tmp-gjhid
          AND bukfm = ls_tmp-bukfm
          AND acind = ls_tmp-acind
          AND fipex = ls_tmp-fipex
          AND geber = ls_tmp-geber
          AND budget_pd = ls_tmp-budget_pd
          AND fistl = ls_tmp-fistl
          AND psoty = ls_tmp-psoty
          AND fkber = ls_tmp-fkber.
* --- ---
      COMMIT WORK.
* ---
    ELSE.
* --- ---
      UPDATE  /thkr/psmulpaytm
        SET ampel    = gc_red
        WHERE gjhid = ls_tmp-gjhid
          AND bukfm = ls_tmp-bukfm
          AND acind = ls_tmp-acind
          AND fipex = ls_tmp-fipex
          AND geber = ls_tmp-geber
          AND budget_pd = ls_tmp-budget_pd
          AND fistl = ls_tmp-fistl
          AND psoty = ls_tmp-psoty
          AND fkber = ls_tmp-fkber.
* --- ---
      COMMIT WORK.
* ---
    ENDIF.
*
  ENDLOOP.

ENDFORM.
