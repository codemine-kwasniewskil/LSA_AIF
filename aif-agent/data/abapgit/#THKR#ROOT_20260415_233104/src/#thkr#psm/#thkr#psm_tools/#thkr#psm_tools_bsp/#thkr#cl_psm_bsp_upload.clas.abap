class /THKR/CL_PSM_BSP_UPLOAD definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_upload,
        fm_area  TYPE fikrs,
        fiscyear TYPE gjahr,
        fundsctr TYPE fistl,
        bs_name  TYPE fmbs_name,
        budcat   TYPE buku_budcat,
        fund     TYPE bp_geber,
        funcarea TYPE fm_farea,
        measure  TYPE fm_measure,
        cmmtitem TYPE fm_fipex,
      END OF ty_upload .
  types:
    tty_upload TYPE TABLE OF ty_upload .
  types:
    BEGIN OF ty_daten.
             INCLUDE TYPE ty_upload.
    TYPES:   ampel  TYPE  icon_d,
             msg_id TYPE  msgid,
             msg_no TYPE  msgno,
             message TYPE  msgtxt,
           END OF ty_daten .
  types:
    tty_daten TYPE TABLE OF ty_daten .
  types:
    BEGIN OF ty_fehler,
             msg_id  TYPE  msgid,
             msg_no  TYPE  msgno,
             message TYPE  msgtxt,
           END OF ty_fehler .

  methods GET_DATA
    exporting
      value(PROCESSED_DATA) type TTY_DATEN .
  methods RUN
    importing
      !PATH type STRING
      !TESTMODE type XFLAG
      !DELETE type XFLAG optional .
  methods CHECK_PATH_FOR_FILE_OR_DIR
    importing
      !IV_IS_DIR type FLAG
      !IV_IS_FILE type FLAG
      !IV_PATH type IBIPPARMS-PATH
    returning
      value(RV_PATH_OK) type FLAG
    raising
      /THKR/CX_PSM_TOOLS .
  methods GET_FILES
    importing
      !IV_PATH type IBIPPARMS-PATH
      !IV_IS_FILE type FLAG
      !IV_IS_DIR type FLAG
    exporting
      value(ET_FILE_TABLE) type FILETABLE
    raising
      /THKR/CX_PSM_TOOLS .
protected section.

  constants GREEN type ICON_D value '@08@' ##NO_TEXT.
  constants YELLOW type ICON_D value '@09@' ##NO_TEXT.
  constants RED type ICON_D value '@0A@' ##NO_TEXT.
  data UPLOADED_DATA type TTY_UPLOAD .
  data PROCESSED_DATA type TTY_DATEN .

  methods DELETE_BO_OBJECT
    importing
      !TESTMODE type XFLAG .
  methods CREATE_PO_OBJECT
    importing
      !TESTMODE type XFLAG .
  methods CREATE_BO_OBJECT
    importing
      !TESTMODE type XFLAG .
  methods ENHANCE_DATA
    importing
      !DATALINE type TY_UPLOAD .
  methods READ_FILE
    importing
      !PATH type STRING .
private section.
ENDCLASS.



CLASS /THKR/CL_PSM_BSP_UPLOAD IMPLEMENTATION.


  METHOD check_path_for_file_or_dir.
    CONSTANTS: lc_msgv1_file TYPE symsgv VALUE 'Datei'.
    CONSTANTS: lc_msgv1_dir TYPE symsgv VALUE 'Verzeichnis'.
    CONSTANTS: lc_msgv2_file TYPE symsgv VALUE 'eine Datei'.
    CONSTANTS: lc_msgv2_dir TYPE symsgv VALUE 'ein Verzeichnis'.

    rv_path_ok = abap_false.
    "Prüfung Verzeichnistrenner
    FIND FIRST OCCURRENCE OF '/' IN iv_path.
    IF sy-subrc = 0.
      SPLIT iv_path AT '/' INTO TABLE DATA(lt_part).
    ELSE.
      SPLIT iv_path AT '\' INTO TABLE lt_part.
    ENDIF.

    IF iv_is_dir = abap_true.
      "Der Import soll über ein Verzeichnis erfolgen.
      "Keine Datei darf angegeben werden.
      FIND FIRST OCCURRENCE OF '.' IN lt_part[ lines( lt_part ) ].
      IF sy-subrc = 0.
        "es wurde eine Datei angegeben.
        RAISE EXCEPTION TYPE /thkr/cx_psm_tools MESSAGE e009(/thkr/psm_tools) WITH lc_msgv1_dir lc_msgv2_file.
      ELSE.
        rv_path_ok = abap_true.
      ENDIF.
    ENDIF.

    IF iv_is_file = abap_true.
      "Der Import soll für einzele Datei erfolgen
      "Datei muss angegeben werden
      FIND FIRST OCCURRENCE OF '.' IN lt_part[ lines( lt_part ) ].
      IF sy-subrc = 0.
        rv_path_ok = abap_true.
      ELSE.
        "es wurde eine Datei angegeben.
        RAISE EXCEPTION TYPE /thkr/cx_psm_tools MESSAGE e009(/thkr/psm_tools) WITH lc_msgv1_file lc_msgv2_dir.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD create_bo_object.
    DATA: dimparts TYPE fmku_t_dimpart.
    DATA: returns TYPE bapiret2_tab.
    DATA: processed_line TYPE ty_daten.

    LOOP AT me->uploaded_data INTO DATA(uploaded_line)
      WHERE budcat = '9F'
         OR budcat = '9G'.

      processed_line = CORRESPONDING #( uploaded_line ).

      SELECT SINGLE FROM v_fmbs_bo
         FIELDS COUNT(*)
         WHERE fm_area  = @uploaded_line-fm_area  AND
               bs       = @uploaded_line-bs_name  AND
               fiscyear = @uploaded_line-fiscyear AND
               budcat   = @uploaded_line-budcat   AND
               fund     = @uploaded_line-fund     AND
               fundsctr = @uploaded_line-fundsctr AND
               cmmtitem = @uploaded_line-cmmtitem AND
               funcarea = @uploaded_line-funcarea AND
               measure  = @uploaded_line-measure .
      IF sy-subrc = 0.
        " Already existent
        processed_line = VALUE #( BASE processed_line ampel = me->yellow message = 'Bereits vorhanden' ).
        me->processed_data = VALUE #( BASE processed_data ( processed_line ) ).
      ELSE.

        dimparts = VALUE #( ( CORRESPONDING #( uploaded_line ) ) ).
        CLEAR returns.
        CALL FUNCTION 'FMBS_CREATE_BOBJECT'
          EXPORTING
            im_fm_area           = uploaded_line-fm_area
            im_fiscyear          = uploaded_line-fiscyear
            im_budcat            = uploaded_line-budcat
            im_bs_name           = uploaded_line-bs_name
            im_t_bo_list         = dimparts
            im_flg_test          = testmode
            im_flg_do_not_commit = testmode
          IMPORTING
            e_t_return           = returns.
        IF returns IS INITIAL. " No Error
          processed_line = VALUE #( BASE processed_line ampel = me->green message = 'Erfolgreich' ).
          me->processed_data = VALUE #( BASE processed_data ( processed_line ) ).
        ELSE. " Messages found:
          LOOP AT returns INTO DATA(return).
            processed_line = VALUE #( BASE processed_line
                                      ampel   = COND #( WHEN return-type = 'E' THEN me->red
                                      WHEN return-type CA 'IW' THEN me->yellow
                                      ELSE me->green )
                                      msg_id  = return-id
                                      msg_no  = return-number
                                      message = return-message ).
            me->processed_data = VALUE #( BASE processed_data ( processed_line ) ).
          ENDLOOP.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD create_po_object.
    DATA: dimparts TYPE fmbs_t_po.
    DATA: returns TYPE bapiret2_tab.
    DATA: processed_line TYPE ty_daten.

    LOOP AT me->uploaded_data INTO DATA(uploaded_line)
      WHERE budcat = '9A'
         OR budcat = '9B'.
      processed_line = CORRESPONDING #( uploaded_line ).



      dimparts = VALUE #( ( CORRESPONDING #( uploaded_line ) ) ).
      CLEAR returns.
      CALL FUNCTION 'FMBS_CREATE_POBJECT'
        EXPORTING
          im_fm_area           = uploaded_line-fm_area
          im_fiscyear          = uploaded_line-fiscyear
          im_t_po_list         = dimparts
          im_pldnr             = uploaded_line-budcat
          im_flg_test          = testmode
          im_flg_do_not_commit = testmode
        IMPORTING
          e_t_return           = returns.

      IF returns IS INITIAL. " No Error
        processed_line = VALUE #( BASE processed_line ampel = me->green message = 'Erfolgreich' ).
        me->processed_data = VALUE #( BASE processed_data ( processed_line ) ).
      ELSE. " Messages found:
        LOOP AT returns INTO DATA(return).
          processed_line = VALUE #( BASE processed_line
                                    ampel   = COND #( WHEN return-type = 'E' THEN me->red
                                                      WHEN return-type CA 'IW' THEN me->yellow
                                                      ELSE me->green )
                                    msg_id  = return-id
                                    msg_no  = return-number
                                    message = return-message ).
          me->processed_data = VALUE #( BASE processed_data ( processed_line ) ).
        ENDLOOP.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD delete_bo_object.
    DATA: dimparts TYPE fmku_s_dimpart.
    DATA: returns TYPE bapiret2_tab.
    DATA: processed_line TYPE ty_daten.

    LOOP AT me->uploaded_data INTO DATA(uploaded_line)
      WHERE budcat = '9F'
         OR budcat = '9G'.

      processed_line = CORRESPONDING #( uploaded_line ).

      SELECT SINGLE FROM v_fmbs_bo
        FIELDS COUNT(*)
        WHERE fm_area  = @uploaded_line-fm_area  AND
              bs       = @uploaded_line-bs_name  AND
              fiscyear = @uploaded_line-fiscyear AND
              budcat   = @uploaded_line-budcat   AND
              fund     = @uploaded_line-fund     AND
              fundsctr = @uploaded_line-fundsctr AND
              cmmtitem = @uploaded_line-cmmtitem AND
              funcarea = @uploaded_line-funcarea AND
              measure  = @uploaded_line-measure .
      IF sy-subrc <> 0.
        " Not found
        processed_line = VALUE #( BASE processed_line ampel = me->yellow message = 'Nicht vorhanden' ).
        me->processed_data = VALUE #( BASE processed_data ( processed_line ) ).
      ELSE.
        DATA(bo_list) = NEW cl_fmbs_bo_list( im_fm_area = uploaded_line-fm_area im_fiscyear = uploaded_line-fiscyear ).
        bo_list->set_bs( im_bs = uploaded_line-bs_name ).
        bo_list->set_ldnr( uploaded_line-budcat ).
*        dimparts = CORRESPONDING #( uploaded_line ) .
        bo_list->add_object( CORRESPONDING #( uploaded_line ) ).

        bo_list->delete_from_db(
          EXPORTING
            im_test           = testmode                 " Nur Test - für Überspringen der Obj., die nicht gel. w. k.
          IMPORTING
            e_errors_found    = DATA(e_errors_found)    " Schwerwiegende Fehler, es kann nichts gelöscht werden
            e_objects_skipped = DATA(e_objects_skipped) " Einige Objekte konnten nicht gelöscht werden
        ).
        IF e_errors_found = abap_false AND e_objects_skipped = abap_false. " No Error
          processed_line = VALUE #( BASE processed_line ampel = me->green message = 'Erfolgreich gelöscht' ).

        ELSE. " Messages found:
          processed_line = VALUE #( BASE processed_line ampel = me->red message = 'Löschen nicht möglich' ).
          me->processed_data = VALUE #( BASE processed_data ( processed_line ) ).
        ENDIF.
        me->processed_data = VALUE #( BASE processed_data ( processed_line ) ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD enhance_data.
** If wildcard has been used: Replicate line for all releated commitment items!
    DATA fipose TYPE RANGE OF fipex.

    fipose = VALUE #( ( sign   = if_fsbp_const_range=>sign_include
                        option = if_fsbp_const_range=>option_contains_pattern
                        low    = dataline-cmmtitem ) ).
    SELECT FROM fmci
      FIELDS fipex
      WHERE fikrs = @dataline-fm_area
        AND gjahr = @dataline-fiscyear
        AND fipex IN @fipose
      INTO TABLE @DATA(results).

    LOOP AT results INTO DATA(wa).
      IF count( val = dataline-funcarea sub = '*' ) = 0.
        APPEND VALUE #( BASE dataline cmmtitem = wa-fipex ) TO me->uploaded_data.
      ELSE.
        APPEND VALUE #( BASE dataline funcarea = wa-fipex+0(4) cmmtitem = wa-fipex  ) TO me->uploaded_data.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_data.

    processed_data = me->processed_data.

  ENDMETHOD.


  METHOD get_files.
    DATA: lt_files TYPE STANDARD TABLE OF file_info.
    DATA: lv_count TYPE i.
    IF iv_is_dir = abap_true.
      cl_gui_frontend_services=>directory_list_files(
        EXPORTING
          directory                   = conv string( iv_path )                " Suchverzeichnis
*        filter                      = '*.*'            " Dateifilter
*        files_only                  =                  " Gibt nur Dateien zurück, keine Verzeichnisse
*        directories_only            =                  " Gibt nur Verzeichnisse zurück, keine Dateien
        CHANGING
          file_table                  =  lt_files               " Zurückgegebene Tabelle mit gefundenen Dateinamen
          count                       =  lv_count                " Anzahl Dateien / Verzeichnisse gefunden
      EXCEPTIONS
        cntl_error                  = 1                " Controlfehler
        directory_list_files_failed = 2                " Auflisten der Dateien im Verzeichnis fehlgeschlagen
        wrong_parameter             = 3                " Falsche Parameterkombination
        error_no_gui                = 4                " Kein GUI verfügbar
        not_supported_by_gui        = 5                " Nicht unterstützt von GUI
        OTHERS                      = 6
      ).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_tools
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      else.
        loop at lt_files ASSIGNING FIELD-SYMBOL(<ls_file>).
          Find FIRST OCCURRENCE OF '/' in iv_path.
          if sy-subrc = 0.
            APPEND iv_path && '/' && <ls_file>-filename to et_file_table.
          else.
            APPEND iv_path && '\' && <ls_file>-filename to et_file_table.
          endif.
        ENDLOOP.
      ENDIF.
    ENDIF.

    if iv_is_file = abap_true.
      "Dateiverarbeitung.
      "eine Datei einfügen
      Append value file_table( filename = iv_path ) to et_file_table.
    endif.
  ENDMETHOD.


  METHOD read_file.

    DATA: data_tab TYPE textline_t.
    DATA: upload TYPE ty_upload.

    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = path             " Name der Datei
        filetype                = 'ASC'              " Dateityp (Ascii, Binär)
      CHANGING
        data_tab                = data_tab           " Übergabetabelle für Datei-Inhalt
      EXCEPTIONS
        file_open_error         = 1                  " Datei nicht vorhanden, kann nicht geöffnet werde
        file_read_error         = 2                  " Fehler beim Lesen der Datei
        gui_refuse_filetransfer = 4                  " Falsches Frontend oder Fehler im Frontend
        invalid_type            = 5                  " Falscher Parameter FILETYPE
        no_authority            = 6                  " Keine Berechtigung für Upload
        unknown_error           = 99                  " Unbekannter Fehler
        access_denied           = 13                 " Zugriff auf Datei nicht erlaubt.
        dp_out_of_memory        = 14                 " Nicht genug Speicher im Dataprovider
        disk_full               = 15                 " Speichermedium ist voll.
        error_no_gui            = 18                 " GUI nicht verfügbar
    ).
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DATA(csv_conv) = cl_rsda_csv_converter=>create( i_separator = ';' ).
    LOOP AT data_tab ASSIGNING FIELD-SYMBOL(<data>).

      csv_conv->csv_to_structure(
        EXPORTING
          i_data   = <data>
        IMPORTING
          e_s_data = upload ).

      "" Valid line:
      CHECK upload-fiscyear <> '0000'.

      IF count( val = upload-cmmtitem sub = '*') <> 0.
        me->enhance_data( upload ).
      ELSE.
        APPEND upload TO me->uploaded_data.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD run.

    IF me->uploaded_data IS INITIAL.
      me->read_file( path = path ).
    ENDIF.

    IF delete IS INITIAL.
      me->create_bo_object( testmode = testmode ).
      me->create_po_object( testmode = testmode ).
    ELSE.
      me->delete_bo_object( testmode = testmode ).
    ENDIF.

    "Wenn ein Verzeichnis und somit mehrere Dateien hochgeladen werden müssen
    "dann ist es notwendig, die uplaoded_data wieder zu löschen, um den nächsten Lauf / die nächste Datei verarbeiten zu können.
    clear: me->uploaded_data.
  ENDMETHOD.
ENDCLASS.
