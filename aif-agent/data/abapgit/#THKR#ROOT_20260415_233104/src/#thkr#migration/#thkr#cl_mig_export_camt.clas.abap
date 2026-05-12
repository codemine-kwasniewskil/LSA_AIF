CLASS /thkr/cl_mig_export_camt DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_bfw_process
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS class_constructor .
    METHODS constructor
      IMPORTING
        !i_process_id TYPE /thkr/process_id OPTIONAL
        !i_selection  TYPE /thkr/s_mig_ao_sap_selection OPTIONAL
        !i_test       TYPE xfeld OPTIONAL .
    METHODS process
      IMPORTING
        !i_path     TYPE /thkr/file_w_path
        !i_frontend TYPE xfeld .
    METHODS get_attr
      EXPORTING
        !e_attr         TYPE /thkr/s_mig_exp
        !e_attr_process TYPE /thkr/s_process .
    METHODS init_header
      IMPORTING
        !i_bookg_dt                 TYPE budat
        !i_cr_timestamp             TYPE timestampl OPTIONAL
        !i_miliseconds              TYPE i DEFAULT 6
      EXPORTING
        !e_iso_current_datetime_utc TYPE char35
        !e_iso_current_date         TYPE char10
        !e_iso_current_datetime     TYPE char35
        !e_iso_bookgdttm_utc        TYPE char35
        !e_iso_bookgdt              TYPE char10
        !e_iso_bookgdttm            TYPE char35 .

    METHODS read
        REDEFINITION .
    METHODS save
        REDEFINITION .
protected section.

  types:
    BEGIN OF ty_camt_grp,
        val_dt    TYPE char10,
        Summe     TYPE decfloat16,
        camt_part TYPE STANDARD TABLE OF /thkr/s_mig_camt WITH EMPTY KEY,
      END OF ty_camt_grp .
  types:
    tt_camt_grp TYPE STANDARD TABLE OF ty_camt_grp WITH EMPTY KEY .
  types:
*   begin of ty_camt_header_alias,
*     Include TYPE /thkr/s_mig_camt_header,
*   end of ty_camt_header_alias,
*
*    BEGIN OF TY_CAMT_FILE,
*      header TYPE ty_camt_header_alias,
*      T_CAMT Type tt_camt_grp,
*    end of ty_camt_file.
    BEGIN OF TY_CAMT_FILE,
      Include TYPE /thkr/s_mig_camt_header,
      T_CAMT Type tt_camt_grp,
    end of ty_camt_file .

  methods BUILD_LINES_4_VWZ
    importing
      !IS_DTO_MIG_AO_SAP type /THKR/S_DTO_MIG_AO_SAP
      !IS_MIG_CAMT_H type /THKR/S_MIG_CAMT_HEADER
    changing
      !CS_MIG_CAMT type /THKR/S_MIG_CAMT .
  methods CREATE_EXPORT_FILE
    raising
      /THKR/CX_LSA1 .
  methods GROUP_CAMT_DATA
    importing
      !IT_CAMT type /THKR/T_MIG_CAMT
      !I_MIG_OBJECT type /THKR/MIGRATIONSOBJEKT
    exporting
      !ET_CAMT_GRP type TT_CAMT_GRP .
private section.

  types:
    BEGIN OF ty_result,
        satz_id TYPE /thkr/de_satz_id,
      END OF ty_result .

  data APPL type ref to /THKR/CL_MIG_APPL .
  data ATTR type /THKR/S_MIG_EXP .
  data FILENAME type FILE_NAME .
  data FRONTEND type XFELD .
  data SELECTION type /THKR/S_MIG_AO_SAP_SELECTION .
  data:
    t_result TYPE STANDARD TABLE OF ty_result .
  data XML_STRING type XSTRING .
  data SERVER_PATH type /THKR/FILE_W_PATH .
  data IS_TEST type XFELD .
  data T_CAMT_FILE type TY_CAMT_FILE .
  data T_CAMT_GRP type TT_CAMT_GRP .
ENDCLASS.



CLASS /THKR/CL_MIG_EXPORT_CAMT IMPLEMENTATION.


  METHOD class_constructor.
  ENDMETHOD.


  METHOD constructor.



    super->constructor(
      i_process_id   = i_process_id
      i_process_type = 'MIG_CA'
      i_save_proc    = 'X' ).

    IF i_process_id IS INITIAL.
      selection = i_selection.
      ASSERT i_selection-migrationsobjekt IS NOT INITIAL.
      attr-migrationsobjekt = i_selection-migrationsobjekt.
    ELSE.
      read( ).

    ENDIF.

    appl = /thkr/cl_mig_appl=>get_instance( ).

  ENDMETHOD.


  METHOD create_export_file.

    IF NOT frontend IS INITIAL.
      "Ablage auf dem Frontendserver (Testlauf)
      helpers->gui_download_xstring(
        i_xstring  = xml_string
        i_filename = CONV #( attr-filename ) ).
    ELSE.
      "Ablage auf dem Applikationsserver
      helpers->download_xstring(
        i_xstring  = xml_string
        i_filename = CONV #( attr-filename ) ).
    ENDIF.


*    GET TIME STAMP FIELD cr_file_time_stamp.

  ENDMETHOD.


  METHOD get_attr.

    MOVE-CORRESPONDING attr TO e_attr.
    MOVE-CORRESPONDING attr_process TO e_attr_process.


  ENDMETHOD.


  METHOD group_camt_data.

    CASE i_mig_object.
*     "IOS hat nur MinEinzahldatum als Fälligkeitskriterium
      WHEN 'IOS'.
        LOOP AT it_camt ASSIGNING FIELD-SYMBOL(<ls_camt>) GROUP BY <ls_camt>-mineinzahldatum ASCENDING INTO DATA(key).

          APPEND INITIAL LINE TO et_camt_grp ASSIGNING FIELD-SYMBOL(<ls_camt_grp>).

          DATA lv_sum LIKE <ls_camt_grp>-summe.
          CLEAR lv_sum.
          LOOP AT GROUP key ASSIGNING <ls_camt>.
            lv_sum = lv_sum + <ls_camt>-betrag.
            APPEND INITIAL LINE TO <ls_camt_grp>-camt_part ASSIGNING FIELD-SYMBOL(<ls_camt_part>).
            <ls_camt_part> = <ls_camt>.
          ENDLOOP.
          <ls_camt_grp>-summe = lv_sum.
          <ls_camt_grp>-val_dt = key.

        ENDLOOP.
*     "Bei diesen Migrationsobjekten steht das Fälligkeitsdatum zur Verfügung
      WHEN 'VSA' OR 'SSTE' OR 'SEE_E' OR 'SSTS' OR 'NF'.
        LOOP AT it_camt ASSIGNING <ls_camt> GROUP BY <ls_camt>-val_dt ASCENDING INTO key.

          APPEND INITIAL LINE TO et_camt_grp ASSIGNING <ls_camt_grp>.

          CLEAR lv_sum.
          LOOP AT GROUP key ASSIGNING <ls_camt>.
            lv_sum = lv_sum + <ls_camt>-betrag.
            APPEND INITIAL LINE TO <ls_camt_grp>-camt_part ASSIGNING <ls_camt_part>.
            <ls_camt_part> = <ls_camt>.
          ENDLOOP.
          <ls_camt_grp>-summe = lv_sum.
          <ls_camt_grp>-val_dt = key.

        ENDLOOP.

    ENDCASE.

  ENDMETHOD.


  METHOD init_header.

    DATA: lv_timestamp_long TYPE timestampl,
          lv_tsl_str        TYPE string.

    IF i_cr_timestamp IS NOT INITIAL.
      lv_timestamp_long = i_cr_timestamp.
    ELSE.
      GET TIME STAMP FIELD lv_timestamp_long.
    ENDIF.

    DATA(l_ms) = COND i(
      WHEN i_miliseconds IS NOT INITIAL THEN i_miliseconds
      ELSE 6 ).

    CONVERT TIME STAMP lv_timestamp_long TIME ZONE 'UTC'
      INTO DATE DATA(ld_date)
           TIME DATA(ld_time).


    lv_tsl_str  = lv_timestamp_long.
    DATA(lv_msec) = substring( val = lv_tsl_str off = 15 len = l_ms ).


    e_iso_current_datetime_utc = |{ ld_date DATE = ISO }T{ ld_time TIME = ISO }.{ lv_msec }Z|.
    e_iso_current_datetime = |{ ld_date DATE = ISO }T{ ld_time TIME = ISO }.{ lv_msec }|.
    e_iso_current_date = e_iso_current_datetime+0(10).

*    Migrationsbuchungsdatum für IOS/VSA Kontodatei
    ld_date = i_bookg_dt.

    e_iso_bookgdttm_utc = |{ ld_date DATE = ISO }T{ ld_time TIME = ISO }.{ lv_msec }Z|.
    e_iso_bookgdttm = |{ ld_date DATE = ISO }T{ ld_time TIME = ISO }.{ lv_msec }|.
    e_iso_bookgdt = e_iso_bookgdttm+0(10).

  ENDMETHOD.


  METHOD process.

    TYPES: BEGIN OF lty_param,
             dto_mig_ao_sap TYPE /thkr/s_dto_mig_ao_sap,
             lfd_nr         TYPE n LENGTH 4,
           END OF lty_param.

    TYPES: BEGIN OF lty_param_header,
             process_id LIKE process_id,
           END OF lty_param_header.

    DATA: l_param   TYPE lty_param,
          l_param_h TYPE lty_param_header,
          l_camt    TYPE /thkr/s_mig_camt,
          lt_camt   TYPE /thkr/t_mig_camt,
          l_camt_h  TYPE /thkr/s_mig_camt_header,
          l_message TYPE string,
          l_oerror  TYPE REF TO cx_root.

    IF is_test IS INITIAL.
      save( ).    "Laufnummer holen
    ENDIF.

    frontend = i_frontend.

    /thkr/cl_mig_rk=>get_instance( )->get_tdto_mig_ao(
      EXPORTING
        i_selection = selection
      IMPORTING
        et_dto      = DATA(lt_dto_mig_ao) ).

    TRY.

*       "CAMT-Header: Im Wesentlichen Festwerte des Kreditors und Gutschrift/Lastschriftinformationen
        CASE selection-migrationsobjekt.
*         "Beides Gutschriften, u.a. <BkTxCd> = NTRF+168  <CdtDbtInd> = CRDT
          WHEN 'IOS' OR 'SSTE' OR 'SEE_E' OR 'SSTS' OR 'NF'.

            /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
              EXPORTING
                i_gi_id = 'MIG_CAMT_H'
                i_para  = l_param_h
              CHANGING
                c_data  = l_camt_h ).
*         "Hier Lastschrift, u.a. <BkTxCd> = NDDT-195  <CdtDbtInd> = DBIT
          WHEN 'VSA'.

            /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                EXPORTING
                  i_gi_id = 'MIG_CAMTVSAH'
                  i_para  = l_param_h
                CHANGING
                  c_data  = l_camt_h ).

          WHEN OTHERS.

            ASSERT selection-migrationsobjekt = 'IOS' OR selection-migrationsobjekt = 'VSA'.

        ENDCASE.


      CATCH /thkr/cx_gi INTO l_oerror.
        add_event(
          i_exception = l_oerror
          i_ln_art    = 'MIG_CAMT_H'
          i_ln_key    = CONV #( l_param-dto_mig_ao_sap-satz_id ) ).
    ENDTRY.


*   "AO-Daten für IOS, VSA, SSTE zur Erstellung der Kontoauszugsdatei allgemeingültig
    LOOP AT lt_dto_mig_ao INTO l_param-dto_mig_ao_sap.

      CLEAR l_camt.
      l_param-lfd_nr = sy-tabix.

      IF l_param-dto_mig_ao_sap-sstw_ueberzahlung = abap_true.
        /thkr/cl_mig_rk=>get_instance( )->get_tdto_mig_rk(
           EXPORTING
             i_selection = VALUE #( FLAG_SELECT_DETAILS = abap_true r_satz_id = VALUE #( ( sign = 'I' option = 'EQ' low = l_param-dto_mig_ao_sap-xblnr ) ) )
           IMPORTING
             et_dto      =  DATA(lt_dto_mig_rk)                " TDTO: Migration: Rückstandskonto
).
        " SSTW Überzahlung Sonderfall als NF aus RK abgebildet
        READ TABLE lt_dto_mig_rk ASSIGNING FIELD-SYMBOL(<fs_rk>) INDEX 1.
        IF sy-subrc = 0.
          /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_rk_pos(
             EXPORTING
               i_xblnr         = l_param-dto_mig_ao_sap-xblnr                 " Rückstandskonto Kassenzeichen
               i_pos_nr        = l_param-dto_mig_ao_sap-rk_pos_nr                " Rückstandskonto: Positionsnummer
             IMPORTING
               e_dto           = DATA(ls_rk_pos)                       " DTO: Rückstandskonto - Position der Fälligkeit
).
          l_param-dto_mig_ao_sap-istbetrag = ls_rk_pos-ist.
          l_param-dto_mig_ao_sap-namezeile1 = <fs_rk>-zp-namezeile1.
          l_param-dto_mig_ao_sap-fealligkeit = ls_rk_pos-faellig.
          l_param-dto_mig_ao_sap-verwendungszweck = ls_rk_pos-grund.
          l_param-dto_mig_ao_sap-kassenzeichen = <fs_rk>-kassenzeichen.
        ENDIF.
      ENDIF.

*     "Status sollte mindestens: AO-Beleg erzeugt sein
      IF l_param-dto_mig_ao_sap-status < 40.
        MESSAGE e033(/thkr/mig) WITH l_param-dto_mig_ao_sap-status l_param-dto_mig_ao_sap-satz_id INTO l_message.
        add_event(
          i_event_category = 'E'
          i_mess           = CONV #( l_message ) ).
        CONTINUE.
      ELSEIF l_param-dto_mig_ao_sap-status = 43 AND selection-flag_force_campt IS INITIAL.
        " Datei wurde für Datensatz bereits erzeugt.
        MESSAGE i036(/thkr/mig) WITH l_param-dto_mig_ao_sap-satz_id INTO l_message.
        add_event(
          i_event_category = 'I'
          i_mess           = CONV #( l_message ) ).
        CONTINUE.
      ENDIF.

      TRY.
          /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
            EXPORTING
              i_gi_id = 'MIG_CAMT'
              i_para  = l_param
            CHANGING
              c_data  = l_camt ).

*         "Aufbau der Zeilen für den Verwendungszweck - Todo:176  Aufwand für gi-implementierung?
          build_lines_4_vwz(
            EXPORTING
              is_dto_mig_ao_sap = l_param-dto_mig_ao_sap
              is_mig_camt_h     = l_camt_h
            CHANGING
              cs_mig_camt       = l_camt
          ).

          APPEND l_camt TO lt_camt.

        CATCH cx_root INTO l_oerror.
          add_event(
            i_exception = l_oerror
            i_ln_art    = 'MIG_AO'
            i_ln_key    = CONV #( l_param-dto_mig_ao_sap-satz_id ) ).

      ENDTRY.

    ENDLOOP.

*   "Nach Valuta/Werstellung gruppierte Logik für Massenverarbeitung von Kontoauszugsdateien
    group_camt_data(
      EXPORTING
        it_camt      = lt_camt
        i_mig_object = selection-migrationsobjekt
      IMPORTING
        et_camt_grp  = DATA(lt_camt_grp)
    ).


    IF lt_camt_grp IS NOT INITIAL.

      MOVE-CORRESPONDING l_camt_h TO t_camt_file-include.
      MOVE-CORRESPONDING lt_camt_grp TO t_camt_file-t_camt.


      IF 1 = 2.
        CALL TRANSFORMATION id
          SOURCE camt = t_camt_file
          RESULT XML xml_string.

        CALL FUNCTION 'DISPLAY_XML_STRING'
          EXPORTING
            xml_string = xml_string.
      ENDIF.

      CALL TRANSFORMATION /thkr/ios_vsa_to_camt54
        SOURCE camt = t_camt_file
        RESULT XML xml_string.


      filename = process_id.
      CONDENSE filename.
      CONCATENATE 'E_' attr-migrationsobjekt '_' process_type '_' filename '.xml' INTO filename.

      IF i_frontend IS NOT INITIAL.
        CONCATENATE i_path '/' filename INTO attr-filename.
      ELSE.
        CONCATENATE server_path '/' filename INTO attr-filename.
      ENDIF.

      CONDENSE attr-filename NO-GAPS.

      TRY.
          create_export_file( ).

          MOVE-CORRESPONDING lt_camt TO t_result.
          LOOP AT lt_camt ASSIGNING FIELD-SYMBOL(<cmt>).
            MESSAGE i034(/thkr/mig) WITH l_param-dto_mig_ao_sap-satz_id filename INTO l_message.
            add_event(
              i_event_category = 'I'
              i_mess           = CONV #( l_message ) ).
          ENDLOOP.

        CATCH /thkr/cx_lsa1 INTO l_oerror.
          add_event(
            EXPORTING
              i_exception = l_oerror ).

      ENDTRY.

    ENDIF.

    IF is_test IS INITIAL.
      save( ).
    ENDIF.

  ENDMETHOD.


  METHOD read.
    super->read( ).

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF @attr
      FROM /thkr/mig_exp
      WHERE process_type = @process_type
        AND process_id   = @process_id.

  ENDMETHOD.


  METHOD save.
    super->save( ).

    DATA: l_mig_exp TYPE /thkr/mig_exp.

    MOVE-CORRESPONDING attr TO l_mig_exp.
    l_mig_exp-process_type = process_type.
    l_mig_exp-process_id   = process_id.

    MODIFY /thkr/mig_exp FROM l_mig_exp.

    LOOP AT t_result INTO DATA(l_result).

      UPDATE /thkr/mig_ao_sap
        SET process_id_exp = @process_id,
            status = '43'
        WHERE satz_id = @l_result-satz_id.

    ENDLOOP.

  ENDMETHOD.


  METHOD build_lines_4_vwz.

*   Verwendungszweck der Hauptstruktur
    APPEND INITIAL LINE TO cs_mig_camt-t_svz ASSIGNING FIELD-SYMBOL(<verwendungszeck>).
    <verwendungszeck>-zahlungsgrund = cs_mig_camt-verwendungszweck.
    IF NOT <verwendungszeck>-zahlungsgrund CS cs_mig_camt-kassenzeichen.
      <verwendungszeck>-zahlungsgrund = <verwendungszeck>-zahlungsgrund && | / { cs_mig_camt-kassenzeichen }|.
    ENDIF.
    /thkr/cl_helpers=>get_instance( )->get_xml_escaping( CHANGING cv_xmlstring = <verwendungszeck>-zahlungsgrund ).

*   SVZ - Zusätzliche Zahlungsgründe / Sonderzeichen beachten
    LOOP AT is_dto_mig_ao_sap-t_svz ASSIGNING FIELD-SYMBOL(<fs_svz>).
      DATA(ls_svz) = <fs_svz>.
      /thkr/cl_helpers=>get_instance( )->get_xml_escaping( CHANGING cv_xmlstring = ls_svz-zahlungsgrund ).
      APPEND ls_svz TO cs_mig_camt-t_svz.
    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
