*&---------------------------------------------------------------------*
*& Include          /THKR/EA_FORMS_PRN_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form ENTRY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_RETURNCODE
*&      --> GC_SCREEN_DISPLAY
*&      --> START_OF_SELECTION
*&---------------------------------------------------------------------*
FORM entry.


* Initialisierung globaler Daten
  PERFORM initialize_data.

* Lesen globaler Daten
  PERFORM get_dynpro_data.

* Dynpro Aufruf
  CASE gv_formid.
* alt zu 1.3
    WHEN '491'.
      PERFORM prepare_dynp_data_0491.
      CALL SCREEN '0491'. "ursprünglich: 0507

    WHEN '492'.
      PERFORM prepare_dynp_data_0492.
      CALL SCREEN '0492'. "ursprünglich: 0510

    WHEN '493'.
      CALL SCREEN '0493'. "ursprünglich: 0509

    WHEN '494'.
      CALL SCREEN '0494'. "ursprünglich: 0508

    WHEN '495'.
      PERFORM prepare_dynp_data_0495.
      CALL SCREEN '0495'.

    WHEN '496'.
      CALL SCREEN '0496'. "ursprünglich: 0521

    WHEN '497'.
      CALL SCREEN '0497'. "ursprünglich: 0480


*    WHEN '508'.
*      PERFORM prepare_dynp_data_0508.
*      CALL SCREEN '0508'.

*    WHEN '510'.
*      CALL SCREEN '0510'.
*    WHEN '520'.
*      PERFORM prepare_dynp_data_0520.
*      CALL SCREEN '0520'.
* neu zu 2.1

*    WHEN '507'.
*      PERFORM prepare_dynp_data_0507.
*      CALL SCREEN '0507'.
*    WHEN '509'.
*      CALL SCREEN '0509'.
*    WHEN '511'.
*      CALL SCREEN '0511'.
*    WHEN '521'.
*      PERFORM prepare_dynp_data_0521.
*      CALL SCREEN '0521'.
* neu zu 2.2
*    WHEN '528'.
*      PERFORM prepare_dynp_data_0528.
*      CALL SCREEN '0528'.
*    WHEN '480'.
*      CALL SCREEN '0480'.
** neu zu 2.3
*    WHEN '515'.
*      CALL SCREEN '0515'.
  ENDCASE.

* Weiterverarbeitung erfolgt mit Form "PROCESSING" nach der Dynpro Verarbeitung

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIALIZE_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialize_data .
  CLEAR: gs_fp_data, gv_form, gv_frist, gv_edit_cont, gt_email_addr,
         gs_email_addr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESSING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM processing
      USING uv_screen            TYPE char1.

  PERFORM check_media_fields USING uv_screen.

  PERFORM get_data.

  PERFORM print_data USING uv_screen.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: lv_city1         TYPE ad_city1,
        ls_address       TYPE bapiaddr3,
        lt_return        TYPE TABLE OF bapiret2,
        ls_febre         TYPE febre,
        lv_amount        TYPE feb_bsproc_worklist_fe-kwbtr,
        lv_amount_act    TYPE feb_bsproc_worklist_fe-kwbtr,
        lv_value_text    TYPE char100,
        lv_xblnr         TYPE xblnr1,
        lv_name1         TYPE kunnr,
        lv_waers         TYPE waers,
        lv_ddtext        TYPE dd07v-ddtext,
        lv_domvalue      TYPE dd07v-domvalue_l,
        ls_zom_addr_attr TYPE zom_addr_attr,
        ls_zom_addr_out  TYPE zom_addr_out.


* Verwendungszweck "neu" lesen
  SELECT * FROM febre INTO TABLE gt_febre
         WHERE kukey = p_kukey
           AND esnum = p_esnum
          ORDER BY PRIMARY KEY.
  IF sy-subrc EQ 0.

    DELETE gt_febre WHERE vwezw+0(1) = '+' AND vwezw+5(1) = '+'.


    LOOP AT gt_febre INTO ls_febre.
* Verwahrkassenzeichen lesen
      IF ls_febre-vwezw+0(1) = 'V' AND ls_febre-vwezw+14(1) = 'V'.
        IF ( gv_formid EQ '521' AND gs_zfi_ea_fo-formtype EQ '2' ) OR
           ( gv_formid EQ '494' AND gs_zfi_ea_fo-formtype EQ '2' ).
        ELSE.
          gs_fp_data-kasze = ls_febre-vwezw+1(13).
        ENDIF.
        DELETE TABLE gt_febre  FROM ls_febre.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Verwendungszweck "original" lesen
  SELECT * FROM febre_orig INTO TABLE gt_febre_orig
         WHERE kukey = p_kukey
           AND esnum = p_esnum
          ORDER BY PRIMARY KEY.
  IF sy-subrc EQ 0.
    DELETE gt_febre_orig WHERE vwezw+0(1) = '+' AND vwezw+5(1) = '+'.
  ENDIF.

* Textelemente lesen
  SELECT * FROM /thkr/ea_fo_tb INTO TABLE gt_zfi_ea_fo_tb
      WHERE formid  EQ gv_formid
        AND variant EQ gv_variant
    ORDER BY PRIMARY KEY.
  IF sy-subrc NE 0.
    MESSAGE w021 WITH '/THKR/EA_FO_TB' gv_formid gv_variant
      DISPLAY LIKE 'E'.
    LEAVE PROGRAM.
  ENDIF.

* Zuordnung
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = ls_address
    TABLES
      return   = lt_return.

  lv_city1 = ls_address-city.


  SELECT SINGLE abskey FROM /thkr/ea_fo_zu INTO gv_abskey
      WHERE  city1  EQ lv_city1
        AND  area   EQ gs_zfi_ea_fo-area.
  IF sy-subrc NE 0.
    MESSAGE w021 WITH '/THKR/EA_FO_ZU' lv_city1 gs_zfi_ea_fo-area
      DISPLAY LIKE 'E'.
    LEAVE PROGRAM.
  ENDIF.

* Absendertexte lesen
  SELECT SINGLE * FROM /thkr/ea_fo_abs INTO gs_absender
      WHERE abskey EQ gv_abskey.
  IF sy-subrc NE 0.
    MESSAGE w023 WITH '/THKR/EA_FO_ABS' gv_abskey DISPLAY LIKE 'E'.
    LEAVE PROGRAM.
  ENDIF.


* Formular ID setzen
  gs_fp_data-formid  = gv_formid.

* Variante setzen
  gs_fp_data-variant  = gv_variant.

* Formular Ausgabeart
  gs_fp_data-formtype = gs_zfi_ea_fo-formtype.


* Einzahleranfrage bei Zuvielzahlung
  IF gv_zuviel1 EQ 'X'.
    gs_fp_data-/thkr/option = 1.
  ELSE.
    gs_fp_data-/thkr/option = 2.
  ENDIF.

* Datümer und Fristen abhängig vom Tagesdatum
  gs_fp_data-datum   = sy-datlo.
  gs_fp_data-datum14 = sy-datlo + gc_14_days.
  gs_fp_data-datum28 = sy-datlo + gc_28_days.
  gs_fp_data-datum49 = sy-datlo + gc_49_days.

* Datümer und Fristen abhängig vom Buchungsdatum.
  IF NOT gs_worklist_fe-budat IS INITIAL.
    gs_fp_data-budat   = gs_worklist_fe-budat.
    gs_fp_data-budat14 = gs_worklist_fe-budat + gc_14_days.
    gs_fp_data-budat42 = gs_worklist_fe-budat + gc_42_days.
  ELSE.
    gs_fp_data-budat   = sy-datlo.
    gs_fp_data-budat14 = sy-datlo + gc_14_days.
    gs_fp_data-budat42 = sy-datlo + gc_42_days.
  ENDIF.

* Frist aus Eingabedialog
  gs_fp_data-frist = gv_frist.

* Status übernehmen
  IF NOT gv_status_alt IS INITIAL.
    gs_fp_data-status = gv_status_alt.
  ENDIF.

* Nummer der Dienststelle
  gs_fp_data-fictr   = gv_fictr.

* Fälligkeit für Rücklastschrift
  gs_fp_data-faellig = gs_worklist_fe-budat.

  IF NOT gv_bankvermerk IS INITIAL AND
     gs_fp_data-bankvermerk IS INITIAL.

    lv_domvalue = gv_bankvermerk.

    CALL FUNCTION 'DOMAIN_VALUE_GET'
      EXPORTING
        i_domname  = '/THKR/EA_BANK_VERMERK'
        i_domvalue = lv_domvalue
      IMPORTING
        e_ddtext   = lv_ddtext
      EXCEPTIONS
        not_exist  = 1
        OTHERS     = 2.

    IF sy-subrc = 0.
      gs_fp_data-bankvermerk = lv_ddtext.
    ENDIF.
  ENDIF.

  IF gv_service_bw EQ gc_true.

* hier nochmal, falls Service-BW manuell ausgewählt wurde
    IF gv_postfach_id IS INITIAL.
      ls_zom_addr_attr-zpgsbr     =  gs_fp_data-fictr(4).
      ls_zom_addr_attr-acc_fcentr =  gs_fp_data-fictr.

      CALL FUNCTION 'Z_OM_FIND_ADDRESS'
        EXPORTING
          is_addr_attr            = ls_zom_addr_attr
        IMPORTING
          es_addr_out             = ls_zom_addr_out
        EXCEPTIONS
          is_addr_attr_is_initial = 1
          invalid_addr_type       = 2
          no_object_found         = 3
          OTHERS                  = 4.
      IF sy-subrc EQ 0.
        gv_postfach_id   = ls_zom_addr_out-zzbepo.
      ENDIF.
    ENDIF.

* Check Service-BW
    IF gv_postfach_id IS INITIAL.
      MESSAGE w038 DISPLAY LIKE 'E'.
      SET SCREEN sy-dynnr.
      LEAVE SCREEN.
    ENDIF.

* Kennzeichen für Dateiname
    IF NOT gs_fp_data-kasze IS INITIAL.
      gv_kennzeichen = gs_fp_data-kasze.
    ELSEIF NOT gv_ao_kassze IS INITIAL.
      gv_kennzeichen = gv_ao_kassze.
    ELSE.
      CONCATENATE gs_worklist_fe-belnr gs_worklist_fe-gjahr
        INTO gv_kennzeichen.
      CONDENSE gv_kennzeichen NO-GAPS.
    ENDIF.
  ENDIF.

  gs_fp_data-ao_kasze = gv_ao_kassze.

* AO Detailinformationen bei Überzahlung
  IF ( gs_fp_data-formid EQ '507' AND gs_fp_data-formtype EQ '3' ) OR
     ( gs_fp_data-formid EQ '521' AND gs_fp_data-formtype EQ '2' ) OR
     ( gs_fp_data-formid EQ '494' AND gs_fp_data-formtype EQ '2' ) .

    IF NOT gs_fp_data-ao_kasze IS INITIAL.
      PERFORM ueberzahlung.
    ENDIF.
  ENDIF.
** spezielle PKH Varianten
*  IF ( gs_fp_data-formid EQ '507' AND gs_fp_data-formtype EQ '4' ) OR
*     ( gs_fp_data-formid EQ '507' AND gs_fp_data-formtype EQ '5' ) OR
*     ( gs_fp_data-formid EQ '507' AND gs_fp_data-formtype EQ '6' ) .
*
*    IF NOT gs_fp_data-kasze  IS INITIAL.
**      PERFORM get_pkh_data.
*    ENDIF.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRINT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_data
      USING uv_screen            TYPE char1.

  DATA: ls_toa_dara      TYPE toa_dara,
        lv_pdf           TYPE fpcontent,
        ls_pdf_file_next TYPE fpformoutput,
        lr_pdf_merger    TYPE REF TO cl_rspo_pdf_merge,
        lr_ex            TYPE REF TO cx_rspo_pdf_merge,
        lv_ex_txt        TYPE string.

  DATA: lv_flength  TYPE sapb-length,
        lv_anzahl   TYPE i,
        lv_filename TYPE toaat-filename,
        lv_descr    TYPE toaat-descr,
        lv_rc       TYPE sysubrc,
        lt_binar    TYPE STANDARD TABLE OF tbl1024.

  CLEAR: gs_outputparams, gs_docparams, gv_device, ls_toa_dara.

* Ausgabeparameter setzen
  PERFORM get_output_params USING uv_screen
                            CHANGING gs_outputparams
                                     gs_docparams
                                     gv_device.

* Formularname ermitteln
  TRY.
      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
        EXPORTING
          i_name     = gv_form
        IMPORTING
          e_funcname = gv_fm_name.

    CATCH cx_fp_api_repository
          cx_fp_api_usage
          cx_fp_api_internal.
      MESSAGE e004 WITH gv_form.
      RETURN.
  ENDTRY.


*  Formular ausgeben im Anzeigemodus und auf dem Drucker
  IF uv_screen EQ gc_true OR gv_device EQ gc_device-printer.

* Neuen Ausgabejob öffnen
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = gs_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.

    IF sy-subrc <> 0.
      MESSAGE e024 WITH gv_form.
      RETURN.
    ENDIF.
* Formularaufruf
    CALL FUNCTION gv_fm_name
      EXPORTING
        /1bcdwb/docparams  = gs_docparams
        es_worklist_fe     = gs_worklist_fe
        et_febre           = gt_febre
        et_febre_orig      = gt_febre_orig
        es_fp_data         = gs_fp_data
        et_zfi_ea_fo_tb    = gt_zfi_ea_fo_tb
        es_sender          = gs_absender
      IMPORTING
        /1bcdwb/formoutput = gs_pdf_file
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      RETURN.
    ENDIF.

*Folgeformular aktiv?
    IF NOT gs_zfi_ea_fo-formid_next  IS INITIAL AND
       NOT gs_zfi_ea_fo-variant_next IS INITIAL.

* Formulardaten aufbauen
      PERFORM formular_next CHANGING ls_pdf_file_next.
    ENDIF.

*   Ausgabejob schliessen
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      MESSAGE e026 WITH gv_form.
      RETURN.
    ENDIF.
  ENDIF.

*********************************************************************************


* Archivieren und im Nachgang versenden
  IF uv_screen IS INITIAL.
    gs_outputparams-getpdf  = gc_true.

* Neuen Ausgabejob öffnen
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = gs_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.

    IF sy-subrc <> 0.
      MESSAGE e024 WITH gv_form.
      RETURN.
    ENDIF.

*  Formular für Archivierung aufrufen
    CALL FUNCTION gv_fm_name
      EXPORTING
        /1bcdwb/docparams  = gs_docparams
        es_worklist_fe     = gs_worklist_fe
        et_febre           = gt_febre
        et_febre_orig      = gt_febre_orig
        es_fp_data         = gs_fp_data
        et_zfi_ea_fo_tb    = gt_zfi_ea_fo_tb
        es_sender          = gs_absender
      IMPORTING
        /1bcdwb/formoutput = gs_pdf_file
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      RETURN.
    ENDIF.

* Folgeformular aktiv?
    IF NOT gs_zfi_ea_fo-formid_next  IS INITIAL AND
       NOT gs_zfi_ea_fo-variant_next IS INITIAL.
* Formulardaten aufbauen
      PERFORM formular_next CHANGING ls_pdf_file_next.
* Merge - beide PDF Dateien zusammenführen.
    ENDIF.
*   Ausgabejob schliessen
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      MESSAGE e026 WITH gv_form.
      RETURN.
    ENDIF.

* Folgeformular aktiv/Attachment verfügbar --> PDF zusammenführen
    IF ( NOT gs_zfi_ea_fo-formid_next  IS INITIAL AND
     NOT gs_zfi_ea_fo-variant_next IS INITIAL ).
      TRY.
          CREATE OBJECT lr_pdf_merger.
        CATCH cx_rspo_pdf_merge INTO lr_ex.
          lv_ex_txt = lr_ex->get_text( ).
          MESSAGE e002 WITH lv_ex_txt.
          RETURN.
      ENDTRY.

      lr_pdf_merger->add_document( gs_pdf_file-pdf ).
      IF NOT ls_pdf_file_next-pdf IS INITIAL.
        lr_pdf_merger->add_document( ls_pdf_file_next-pdf ).
      ENDIF.
      CLEAR lv_rc.
      lr_pdf_merger->merge_documents( IMPORTING merged_document = lv_pdf rc = lv_rc ).
    ELSE.
* nur ein PDF / Formular
      lv_pdf = gs_pdf_file-pdf.
    ENDIF.


* Vorbereitung für Archivierung

* Beschreibung aufbauen
    CONCATENATE gv_formtype_bez '-' gv_formid gv_variant INTO lv_descr SEPARATED BY space.
* Dateiname aufbauen
    CONCATENATE gs_outputparams-covtitle '.pdf' INTO lv_filename.

*   Konvertiere RAWSTRING in Binärtabelle
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lv_pdf
      TABLES
        binary_tab = lt_binar.

    lv_anzahl = lines( lt_binar ).

*   Dateigröße bestimmen. Sonst wird nur leeres Dokument archiviert
    lv_flength = lv_anzahl * 1024.

*   übergebene Archivtabelle lesen
    READ TABLE gs_docparams-daratab INTO ls_toa_dara
      INDEX 1.
    IF sy-subrc EQ 0.
* Aufruf der Archivierung
      CALL FUNCTION 'ARCHIV_CREATE_TABLE'
        EXPORTING
          ar_object                = ls_toa_dara-ar_object
          object_id                = ls_toa_dara-object_id
          sap_object               = ls_toa_dara-sap_object
          flength                  = lv_flength
          filename                 = lv_filename
          descr                    = lv_descr
        TABLES
          binarchivobject          = lt_binar
        EXCEPTIONS
          error_archiv             = 1
          error_communicationtable = 2
          error_connectiontable    = 3
          error_kernel             = 4
          error_parameter          = 5
          error_user_exit          = 6
          error_mandant            = 7
          blocked_by_policy        = 8
          OTHERS                   = 9.
      IF sy-subrc <> 0.
        MESSAGE w028.
      ENDIF.
    ENDIF.

    CASE gv_device.
* Fax und Mailverarbeitung
      WHEN gc_device-fax.
        PERFORM send_fax USING gv_device
                                lv_pdf.
      WHEN gc_device-email.
        PERFORM send_external USING lv_pdf.
      WHEN gc_device-mail_int.
        PERFORM send_internal USING lv_pdf.
* Service BW
      WHEN gc_device-file.
        PERFORM create_file USING lv_pdf.
    ENDCASE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FEBEP_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM febep_values.

  DATA: ls_shlp   TYPE shlp_descr,
        lt_retval TYPE TABLE OF ddshretval,
        ls_retval TYPE ddshretval,
        lt_fields TYPE TABLE OF dynpread,
        ls_fields TYPE dynpread.

  FIELD-SYMBOLS <if> TYPE ddshiface.

  CLEAR lt_fields.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = '/THKR/EA_FEBEP_HLP'
      shlptype = 'SH'
    IMPORTING
      shlp     = ls_shlp.

  LOOP AT ls_shlp-interface ASSIGNING <if>.
    IF <if>-shlpfield = 'KUKEY'.
      <if>-valfield   = 'KUKEY'.
    ENDIF.
    IF <if>-shlpfield = 'ESNUM'.
      <if>-valfield   = 'ESNUM'.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
    TABLES
      return_values = lt_retval.

  IF NOT lt_retval IS INITIAL.

* Rückgabetabelle ist gefüllt:
    READ TABLE lt_retval INTO ls_retval WITH KEY fieldname = 'KUKEY'.
    IF sy-subrc = 0.
      ls_fields-fieldvalue  = ls_retval-fieldval.
      ls_fields-fieldname   = 'P_KUKEY'.
      APPEND ls_fields TO lt_fields.
    ENDIF.

    READ TABLE lt_retval INTO ls_retval WITH KEY fieldname = 'ESNUM'.
    IF sy-subrc = 0.
      ls_fields-fieldvalue  = ls_retval-fieldval.
      ls_fields-fieldname   = 'P_ESNUM'.
      APPEND ls_fields TO lt_fields.
    ENDIF.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-cprog
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_fields.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FORM_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM form_values.

  DATA: ls_shlp   TYPE shlp_descr,
        ls_selopt TYPE ddshselopt,
        lt_retval TYPE TABLE OF ddshretval,
        ls_retval TYPE ddshretval,
        lt_fields TYPE TABLE OF dynpread,
        ls_fields TYPE dynpread.


  FIELD-SYMBOLS: <if> TYPE ddshiface.

  CLEAR lt_fields.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = '/THKR/EA_FORMID_HLP'
      shlptype = 'SH'
    IMPORTING
      shlp     = ls_shlp.



  LOOP AT ls_shlp-interface ASSIGNING <if>.
    IF <if>-shlpfield = 'FORMID'.
      <if>-valfield   = 'FORMID'.
    ENDIF.
    IF <if>-shlpfield = 'VARIANT'.
      <if>-valfield   = 'VARIANT'.
    ENDIF.
  ENDLOOP.

* Benutzereingabe vor PAI holen
  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      i_field = 'P_FORMID'
      i_repid = sy-cprog
      i_dynnr = sy-dynnr
    CHANGING
      o_value = p_formid.

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      i_field = 'P_VARI'
      i_repid = sy-cprog
      i_dynnr = sy-dynnr
    CHANGING
      o_value = p_vari.


  IF NOT p_formid IS INITIAL.
    ls_selopt-shlpfield  = 'FORMID'.
    ls_selopt-sign       = 'I'.
    IF p_formid CS '*'.
      ls_selopt-option     = 'CP'.
    ELSE.
      ls_selopt-option     = 'EQ'.
    ENDIF.
    ls_selopt-low        = p_formid.

    APPEND ls_selopt TO ls_shlp-selopt.
  ENDIF.

  IF NOT p_vari IS INITIAL.
    ls_selopt-shlpfield  = 'VARIANT'.
    ls_selopt-sign       = 'I'.
    IF p_vari CS '*'.
      ls_selopt-option     = 'CP'.
    ELSE.
      ls_selopt-option     = 'EQ'.
    ENDIF.
    ls_selopt-low        = p_vari.

    APPEND ls_selopt TO ls_shlp-selopt.
  ENDIF.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
    TABLES
      return_values = lt_retval.

  IF NOT lt_retval IS INITIAL.
* Rückgabetabelle ist gefüllt:
    READ TABLE lt_retval INTO ls_retval WITH KEY fieldname = 'FORMID'.
    IF sy-subrc = 0.
      ls_fields-fieldvalue  = ls_retval-fieldval.
      ls_fields-fieldname   = 'P_FORMID'.
      APPEND ls_fields TO lt_fields.
    ENDIF.

    READ TABLE lt_retval INTO ls_retval WITH KEY fieldname = 'VARIANT'.
    IF sy-subrc = 0.
      ls_fields-fieldvalue  = ls_retval-fieldval.
      ls_fields-fieldname   = 'P_VARI'.
      APPEND ls_fields TO lt_fields.
    ENDIF.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-cprog
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_fields.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_OUTPUT_PARAMS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_OUTPUTPARAMS
*&      <-- LS_DOCPARAMS
*&      <-- LV_DEVICE
*&---------------------------------------------------------------------*
FORM get_output_params
      USING uv_screen TYPE char1
     CHANGING
        cs_outputparams  TYPE sfpoutputparams
        cs_docparams     TYPE sfpdocparams
        cv_device        TYPE char1.

  DATA: ls_toa_dara      TYPE toa_dara.

  CLEAR: ls_toa_dara.


* Device setzen
  IF gv_mail_ex EQ gc_true.                           "Mail extern
    cv_device               = gc_device-email.
  ELSEIF gv_mail_in EQ gc_true.                       "Mail intern
    cv_device               = gc_device-mail_int.
  ELSEIF gv_fax EQ gc_true.                           "Fax
    cv_device               = gc_device-fax.
  ELSEIF gv_druck EQ gc_true.                         "Drucker
    cv_device               = gc_device-printer.
    IF uv_screen IS INITIAL.
      cs_outputparams-reqimm  = gc_true.
      cs_outputparams-reqnew  = gc_true.
    ENDIF.
  ELSEIF gv_service_bw EQ gc_true.                    "Datei
    cv_device               = gc_device-file.
  ELSE.
    cv_device               = gc_device-printer.
    IF uv_screen IS INITIAL.
      cs_outputparams-reqimm  = gc_true.
      cs_outputparams-reqnew  = gc_true.
    ENDIF.
  ENDIF.

* Ausgabeparameter setzen
  cs_outputparams-preview   = uv_screen.

* Sofortausgabe
  cs_outputparams-reqfinal  = 'X'.

* Archiv Mode nur Drucken * archivieren im Nachgang
  cs_outputparams-arcmode   = '1'.
  gs_outputparams-copies  = 1.  "Anzahl Formulare

  cs_outputparams-nodialog  = gc_true.
  cs_outputparams-dest      = gv_printer.

*  cs_outputparams-copies    =
*  cs_outputparams-dataset   =
*  cs_outputparams-suffix1   =
*  cs_outputparams-suffix2   =
*  cs_outputparams-cover     =

* Titel aufbauen -> wird auch als Dateiname genutzt
  CONCATENATE gs_zfi_ea_fo-formid gs_zfi_ea_fo-variant cv_device sy-uname
              sy-datum sy-uzeit
   INTO cs_outputparams-covtitle SEPARATED BY '_'.


*  cs_outputparams-authority =
*  cs_outputparams-receiver  =
*  cs_outputparams-division  =
*  cs_outputparams-reqdel    =
*  cs_outputparams-senddate  =
*  cs_outputparams-sendtime  =

* Dokumentparameter setzen
  cs_docparams-langu     = sy-langu.
  cs_docparams-country   = gc_land1.

*   cs_docparams-fillable  = 'N'.
*   cs_docparams-DYNAMIC   = 'X'.
*   cs_docparams-UPDATE_INTERACTION_CODE = 'X'.


* Parameter für Archivierung setzen
  ls_toa_dara-function    = 'DARA'.
  ls_toa_dara-mandant     = sy-mandt.
  ls_toa_dara-sap_object  = 'BUS4498'.
  ls_toa_dara-ar_object   = 'ZFEBEPPDF'.
  ls_toa_dara-notiz       = cs_outputparams-covtitle.

* ID aus Kurzschlüssel und Einzelsatznummer (Nr. des Einzelpostens im Kontoauszug)
  CONCATENATE gv_kukey gv_esnum INTO ls_toa_dara-object_id.

  APPEND ls_toa_dara TO cs_docparams-daratab.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_FAX
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_DEVICE
*&      --> LS_PDF_FILE
*&---------------------------------------------------------------------*
FORM send_fax
  USING uv_device       TYPE output_device
        uv_pdf          TYPE fpcontent.

  DATA: lv_mail_subject TYPE so_obj_des,
        lt_mail_text    TYPE bcsy_text,
        lv_send_to_all  TYPE os_boolean,
        ls_main_data    TYPE fpformoutput,
        ls_address      TYPE sdprt_addr_s.


  ls_main_data-pdf = uv_pdf.

*--- Determine the subject text
  IF gv_betreff IS INITIAL.
    lv_mail_subject = gs_outputparams-covtitle.
  ELSE.
    lv_mail_subject = gv_betreff.
  ENDIF.

*--- Empfänger Faxnummer und Land
  ls_address-recip_fax_country = gv_tland.
  ls_address-recip_fax_number  = gv_telfx(30).

*--- Fax Sender festlegen
*      ls_address-sender_fax_country = gv_tland_sender.
*      ls_address-sender_fax_number  = gv_telfx_sender.

  gv_language = sy-langu.

  CALL FUNCTION 'SD_PDF_SEND_DATA'
    EXPORTING
      iv_device        = uv_device
      iv_email_subject = lv_mail_subject
*     it_email_text    = lt_mail_text
      is_main_data     = ls_main_data
      iv_language      = gv_language
      is_address       = ls_address
    IMPORTING
      ev_send_to_all   = lv_send_to_all
    EXCEPTIONS
      exc_document     = 1
      exc_send_request = 2
      exc_address      = 3
      OTHERS           = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ELSE.
* Dokument gesendet
    MESSAGE s022(so).
  ENDIF.

*   ---------- explicit 'commit work' is mandatory! ----------------
  COMMIT WORK.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAIL_BODY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_MAIL_TEXT
*&---------------------------------------------------------------------*
FORM get_mail_body
  CHANGING
        ct_mail_text    TYPE bcsy_text.

  DATA: ls_mail_text TYPE soli,
        lt_string    TYPE STANDARD TABLE OF swastrtab,
        ls_string    TYPE swastrtab.

* Text Mailinhalt.
  CALL FUNCTION 'SWA_STRING_SPLIT'
    EXPORTING
      input_string                 = gv_text
      max_component_length         = gc_max_comp
*     TERMINATING_SEPARATORS       =
*     OPENING_SEPARATORS           =
    TABLES
      string_components            = lt_string
    EXCEPTIONS
      max_component_length_invalid = 1
      OTHERS                       = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    LOOP AT lt_string INTO ls_string.
      ls_mail_text-line = ls_string-str.
      APPEND ls_mail_text TO ct_mail_text.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_INTERNAL_MAIL_BODY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_MAIL_TEXT
*&---------------------------------------------------------------------*
FORM get_internal_mail_body
  CHANGING
        ct_mail_text    TYPE swftlisti1.

  DATA: ls_mail_text TYPE solisti1,
        lt_string    TYPE STANDARD TABLE OF swastrtab,
        ls_string    TYPE swastrtab.


* Text Mailinhalt.
  CALL FUNCTION 'SWA_STRING_SPLIT'
    EXPORTING
      input_string                 = gv_text
      max_component_length         = gc_max_comp
*     TERMINATING_SEPARATORS       =
*     OPENING_SEPARATORS           =
    TABLES
      string_components            = lt_string
    EXCEPTIONS
      max_component_length_invalid = 1
      OTHERS                       = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    LOOP AT lt_string INTO ls_string.
      ls_mail_text-line = ls_string-str.
      APPEND ls_mail_text TO ct_mail_text.
    ENDLOOP.

  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form GET_DYNPRO_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_dynpro_data .

  SELECT SINGLE * FROM febko INTO CORRESPONDING FIELDS OF gs_worklist_fe
    WHERE kukey EQ p_kukey.
  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM febep INTO CORRESPONDING FIELDS OF gs_worklist_fe
      WHERE kukey EQ p_kukey
        AND esnum EQ p_esnum.
    IF sy-subrc NE 0.
      MESSAGE e013 WITH p_kukey p_esnum.
    ENDIF.
  ELSE.
    MESSAGE e013 WITH p_kukey p_esnum.
  ENDIF.

  gs_worklist_fe-gjahr = gs_worklist_fe-budat(4).

  AUTHORITY-CHECK OBJECT 'F_BL_BANK'
   ID 'BUKRS' FIELD gs_worklist_fe-bukrs
   ID 'HBKID' FIELD gs_worklist_fe-hbkid
   ID 'HKTID' FIELD gs_worklist_fe-hktid
   ID 'ZLSCH' FIELD '*'
   ID 'ACTVT' FIELD '03'. "Display
  IF sy-subrc <> 0.
    MESSAGE e052.
  ENDIF.


* Formulardaten lesen
 SELECT * FROM /thkr/ea_fo INTO gs_zfi_ea_fo UP TO 1 ROWS
      WHERE formid  EQ gv_formid
        AND variant EQ gv_variant
      ORDER BY PRIMARY KEY.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE w031 WITH gv_formid gv_variant.
  ENDIF.

  SELECT SINGLE formtype_bez FROM /thkr/ea_fo_type INTO gv_formtype_bez
      WHERE formid   EQ gs_zfi_ea_fo-formid
        AND formtype EQ gs_zfi_ea_fo-formtype.
  IF sy-subrc NE 0.
    MESSAGE w031 WITH gv_formid gv_variant.
  ENDIF.


  gv_form = gs_zfi_ea_fo-formname.

  gs_fp_data-ename = gs_worklist_fe-partn.
  gs_fp_data-kasze = gs_worklist_fe-xblnr.

  gv_zuviel1 = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_FIELDS_0494
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0494 .
  DATA: ls_bnka    TYPE bnka,
        lt_string  TYPE STANDARD TABLE OF swastrtab,
        ls_string  TYPE swastrtab,
        lv_string  TYPE string,
        lv_string2 TYPE string,
        lv_string3 TYPE string,
        lv_string4 TYPE string,
        lv_landx50 TYPE landx50.

  IF gv_bankl NE gv_bankl_old.
    IF NOT gv_bankl IS INITIAL AND NOT gv_banks IS INITIAL.
      SELECT SINGLE * FROM bnka INTO ls_bnka
        WHERE banks EQ gv_banks
          AND bankl EQ gv_bankl.
      IF sy-subrc EQ 0.
        CLEAR: gs_fp_data-bank_addr_z1, gs_fp_data-bank_addr_z2, gs_fp_data-bank_addr_z3,
               gs_fp_data-bank_addr_z4, gs_fp_data-bank_addr_z5.

        gs_fp_data-bank_addr_z1 = ls_bnka-banka.
* Strasse
        gs_fp_data-bank_addr_z2 = ls_bnka-stras.
* Ort -> Postleitzahl ggf. nach Ortsnamen im System
        SPLIT ls_bnka-ort01 AT ' ' INTO lv_string lv_string2.
        IF lv_string2 CO '0123456789'.
          CONCATENATE lv_string2 lv_string INTO gs_fp_data-bank_addr_z3
            SEPARATED BY space.
        ELSEIF NOT lv_string2 IS INITIAL.
          SPLIT lv_string2 AT ' ' INTO lv_string2 lv_string3.
          IF lv_string3 CO '0123456789'.
            CONCATENATE lv_string3 lv_string lv_string2 INTO gs_fp_data-bank_addr_z3
              SEPARATED BY space.
          ELSEIF NOT lv_string3 IS INITIAL.
            SPLIT lv_string3 AT ' ' INTO lv_string3 lv_string4.
            IF lv_string4 CO '0123456789'.
              CONCATENATE lv_string4 lv_string lv_string2 lv_string3 INTO gs_fp_data-bank_addr_z3
                SEPARATED BY space.
            ELSEIF NOT lv_string4 IS INITIAL.
              gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
            ELSE.
              gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
            ENDIF.
          ELSE.
            gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
          ENDIF.
        ELSE.
          gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
        ENDIF.

        SHIFT gs_fp_data-bank_addr_z3 LEFT DELETING LEADING ' '.
* Land
        IF ls_bnka-banks NE 'DE'.
          SELECT SINGLE landx FROM t005t INTO lv_landx50
                      WHERE land1 EQ ls_bnka-banks
                        AND spras EQ 'D'.
          IF sy-subrc EQ 0.
            gs_fp_data-bank_addr_z4 = lv_landx50.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    gv_bankl_old = gv_bankl.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_FIELDS_0495
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_fields_0495 .
  DATA: ls_bnka    TYPE bnka,
        lt_string  TYPE STANDARD TABLE OF swastrtab,
        ls_string  TYPE swastrtab,
        lv_string  TYPE string,
        lv_string2 TYPE string,
        lv_string3 TYPE string,
        lv_string4 TYPE string,
        lv_landx50 TYPE landx50.

  IF gv_bankl NE gv_bankl_old.
    IF NOT gv_bankl IS INITIAL AND NOT gv_banks IS INITIAL.
      SELECT SINGLE * FROM bnka INTO ls_bnka
        WHERE banks EQ gv_banks
          AND bankl EQ gv_bankl.
      IF sy-subrc EQ 0.
        CLEAR: gs_fp_data-bank_addr_z1, gs_fp_data-bank_addr_z2, gs_fp_data-bank_addr_z3,
               gs_fp_data-bank_addr_z4, gs_fp_data-bank_addr_z5.

        gs_fp_data-bank_addr_z1 = ls_bnka-banka.
* Strasse
        gs_fp_data-bank_addr_z2 = ls_bnka-stras.
* Ort Postleitzahl ggf. nach Ortsnamen im System
        SPLIT ls_bnka-ort01 AT ' ' INTO lv_string lv_string2.
        IF lv_string2 CO '0123456789'.
          CONCATENATE lv_string2 lv_string INTO gs_fp_data-bank_addr_z3
            SEPARATED BY space.
        ELSEIF NOT lv_string2 IS INITIAL.
          SPLIT lv_string2 AT ' ' INTO lv_string2 lv_string3.
          IF lv_string3 CO '0123456789'.
            CONCATENATE lv_string3 lv_string lv_string2 INTO gs_fp_data-bank_addr_z3
              SEPARATED BY space.
          ELSEIF NOT lv_string3 IS INITIAL.
            SPLIT lv_string3 AT ' ' INTO lv_string3 lv_string4.
            IF lv_string4 CO '0123456789'.
              CONCATENATE lv_string4 lv_string lv_string2 lv_string3 INTO gs_fp_data-bank_addr_z3
                SEPARATED BY space.
            ELSEIF NOT lv_string4 IS INITIAL.
              gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
            ELSE.
              gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
            ENDIF.
          ELSE.
            gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
          ENDIF.
        ELSE.
          gs_fp_data-bank_addr_z3 = ls_bnka-ort01.
        ENDIF.

        SHIFT gs_fp_data-bank_addr_z3 LEFT DELETING LEADING ' '.
* Land
        IF ls_bnka-banks NE 'DE'.
          SELECT SINGLE landx FROM t005t INTO lv_landx50
                      WHERE land1 EQ ls_bnka-banks
                        AND spras EQ 'D'.
          IF sy-subrc EQ 0.
            gs_fp_data-bank_addr_z4 = lv_landx50.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    gv_bankl_old = gv_bankl.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_INTERNAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_DEVICE
*&      --> GS_PDF_FILE
*&---------------------------------------------------------------------*
FORM send_internal
     USING uv_pdf       TYPE fpcontent.

  DATA:
    lv_mailtxt_size TYPE i,               " Text in mail size
    lt_mailpack     TYPE TABLE OF sopcklsti1,  " Objektbestandteile
    lt_mailhead     TYPE TABLE OF solisti1,    " Kopfdaten
    lt_reclist      TYPE TABLE OF somlreci1,   " Empfängerliste
    lt_mailtxt      TYPE swftlisti1,           " Mail Text
    ls_doc_att      TYPE sodocchgi1,           " Attribute
    ls_mailpack     TYPE sopcklsti1,           " Objektbestandteile
    ls_reclist      TYPE somlreci1.            " Empfängerliste



  DATA:
    lt_att_content_hex TYPE solix_tab,
    lv_length          TYPE i.


* PDF nach BIN konvertieren
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = uv_pdf
*     APPEND_TO_TABLE       = ' '
    IMPORTING
      output_length = lv_length
    TABLES
      binary_tab    = lt_att_content_hex.

*--- Get the e-mail-text
  PERFORM get_internal_mail_body CHANGING lt_mailtxt.
  lv_mailtxt_size = lines( lt_mailtxt ).

* Attribute setzen
  IF gv_betreff IS INITIAL.
    ls_doc_att-obj_descr = gs_outputparams-covtitle.
  ELSE.
    ls_doc_att-obj_descr  = gv_betreff.
  ENDIF.
  ls_doc_att-sensitivty = 'F'.
  ls_doc_att-doc_size   = lv_mailtxt_size * gc_max_comp.

* für Mail Körper
  ls_mailpack-transf_bin   = space.
  ls_mailpack-head_start   = 1.
  ls_mailpack-head_num     = 0.
  ls_mailpack-body_start   = 1.
  ls_mailpack-body_num     = lv_mailtxt_size.
  ls_mailpack-doc_type     = 'RAW'.
  APPEND ls_mailpack TO lt_mailpack.

* für Anhang
  ls_mailpack-transf_bin   = 'X'.
  ls_mailpack-head_start   = 1.
  ls_mailpack-head_num     = 1.
  ls_mailpack-body_start   = 1.
  ls_mailpack-body_num     = lv_length.
  ls_mailpack-doc_type     = 'PDF'.
  WRITE gv_betreff TO ls_mailpack-obj_descr.
  ls_mailpack-doc_size     = lv_length * gc_max_comp.
  APPEND ls_mailpack TO lt_mailpack.

* Empfänger => SAP User
  ls_reclist-receiver   = gv_mail_rc_user.
  ls_reclist-rec_type   = 'B'.
  ls_reclist-express    = 'X'.

*ls_reclist-notif_del  = 'X'. " request delivery notification
*ls_reclist-notif_ndel = 'X'. " request not delivered notification
  APPEND ls_reclist TO lt_reclist.

* interne E-Mail senden
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = ls_doc_att
      put_in_outbox              = 'X'
      commit_work                = 'X'
    TABLES
      packing_list               = lt_mailpack
      object_header              = lt_mailhead
      contents_txt               = lt_mailtxt
      contents_hex               = lt_att_content_hex
      receivers                  = lt_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ELSE.
* Dokument gesendet
    MESSAGE s022(so).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FORMULAR_NEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LS_PDF_FILE_NEXT
*&---------------------------------------------------------------------*
FORM formular_next  CHANGING cs_pdf_file_next TYPE fpformoutput.

  DATA: lv_form_next    TYPE tdsfname,
        lv_fm_name_next TYPE rs38l_fnam,
        ls_zfi_ea_fo    TYPE /thkr/ea_fo,
        lt_zfi_ea_fo_tb TYPE SORTED TABLE OF /thkr/ea_fo_tb WITH UNIQUE KEY formid variant objectid.

* Formulardaten lesen
  SELECT * FROM /thkr/ea_fo INTO ls_zfi_ea_fo UP TO 1 ROWS
      WHERE formid  EQ gs_zfi_ea_fo-formid_next
        AND variant EQ gs_zfi_ea_fo-variant_next
      ORDER BY PRIMARY KEY.
  ENDSELECT.

* Textelemente lesen
  SELECT * FROM /thkr/ea_fo_tb INTO TABLE lt_zfi_ea_fo_tb
      WHERE formid  EQ gs_zfi_ea_fo-formid_next
        AND variant EQ gs_zfi_ea_fo-variant_next
    ORDER BY PRIMARY KEY.

* erste Zeile Adressenanschrift aus Einzahler vorbelegen
  IF gs_fp_data-formid EQ '494' AND gs_zfi_ea_fo-formid_next EQ '521'.
    gs_fp_data-addr_z1 = gs_fp_data-ename.
  ENDIF.

* Formular Formular ID auf Nachfolgeformular setzen
  gs_fp_data-formid = gs_zfi_ea_fo-formid_next.

* Formular Ausgabeart
  gs_fp_data-formtype = ls_zfi_ea_fo-formtype.


  lv_form_next = ls_zfi_ea_fo-formname.
* Formularname Folgeformular ermitteln
  TRY.
      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
        EXPORTING
          i_name     = lv_form_next
        IMPORTING
          e_funcname = lv_fm_name_next.

    CATCH cx_fp_api_repository
          cx_fp_api_usage
          cx_fp_api_internal.
      MESSAGE e004 WITH lv_form_next.
      RETURN.
  ENDTRY.

  CALL FUNCTION lv_fm_name_next
    EXPORTING
      /1bcdwb/docparams  = gs_docparams
      es_worklist_fe     = gs_worklist_fe
      et_febre           = gt_febre
      et_febre_orig      = gt_febre_orig
      es_fp_data         = gs_fp_data
      et_zfi_ea_fo_tb    = lt_zfi_ea_fo_tb
      es_sender          = gs_absender
    IMPORTING
      /1bcdwb/formoutput = cs_pdf_file_next
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_MEDIA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_media_fields USING uv_screen TYPE char1.
  IF uv_screen IS INITIAL.
    IF gv_mail_ex EQ gc_true.  "Mail extern
*  check E-Mail Adresse
      IF gv_email_addr IS INITIAL.
        MESSAGE w030 DISPLAY LIKE 'E'.
        SET SCREEN sy-dynnr.
        LEAVE SCREEN.
      ENDIF.
    ELSEIF gv_mail_in EQ gc_true. "Mail intern
      IF gv_mail_rc_user IS INITIAL.
        MESSAGE w030 DISPLAY LIKE 'E'.
        SET SCREEN sy-dynnr.
        LEAVE SCREEN.
      ENDIF.
    ELSEIF gv_fax EQ gc_true.     "Fax
* Check Faxnummer
      IF gv_telfx IS INITIAL.
        MESSAGE w029 DISPLAY LIKE 'E'.
        SET SCREEN sy-dynnr.
        LEAVE SCREEN.
      ENDIF.
    ELSEIF gv_service_bw EQ gc_true.     "Service-BW
* Check Service-BW
      IF gv_postfach_id IS INITIAL.
        MESSAGE w038 DISPLAY LIKE 'E'.
        SET SCREEN sy-dynnr.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.
    IF gv_mail_in EQ gc_true OR gv_mail_ex EQ gc_true.
      IF gv_betreff IS INITIAL.
        MESSAGE w034 DISPLAY LIKE 'E'.
        SET SCREEN sy-dynnr.
        LEAVE SCREEN.
      ENDIF.
      IF gv_text IS INITIAL.
        PERFORM check_mail_text.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mail_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_mail_text.

  DATA: lv_answer TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Kontrolle Mailanschreiben'(004)
      text_question         = 'Es ist kein Mail Anschreibentext gepflegt, Verarbeitung fortsetzen ?'(005)
      text_button_1         = 'Ja'(002)
*     ICON_BUTTON_1         = ' '
      text_button_2         = 'Nein'(003)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = 'X'
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = lv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc = 0.
    IF lv_answer NE '1'.
      SET SCREEN sy-dynnr.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PDF
*&---------------------------------------------------------------------*
FORM create_file
       USING uv_pdf       TYPE fpcontent.

  DATA: lv_filename  TYPE string,
        lv_timestamp TYPE timestampl,
        lv_ts_char   TYPE char100,
        lv_file_appl TYPE string,
        lv_mess      TYPE string.

* Zeitstempel
  GET TIME STAMP FIELD lv_timestamp.

  WRITE lv_timestamp TIME ZONE sy-zonlo TO lv_ts_char DECIMALS 4.

  REPLACE ALL OCCURRENCES OF REGEX `\D` IN lv_ts_char WITH ``.
  CONDENSE lv_ts_char.

*   Dateiname aufbauen
  CONCATENATE gv_postfach_id '_' gc_produkt '_' gv_kennzeichen '_' lv_ts_char '.pdf' INTO lv_filename.

  lv_file_appl = lv_filename.

  CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
    EXPORTING
      logical_path               = gc_log_path_s_bw
      file_name                  = lv_file_appl
    IMPORTING
      file_name_with_path        = lv_file_appl
    EXCEPTIONS
      path_not_found             = 1
      missing_parameter          = 2
      operating_system_not_found = 3
      file_system_not_found      = 4
      OTHERS                     = 5.
  IF sy-subrc EQ 0.
*  Speichern PDF-Datei auf Applikationsserver
    OPEN DATASET lv_file_appl FOR OUTPUT IN BINARY MODE MESSAGE lv_mess. "Datei wird geöffnet

    IF sy-subrc <> 0.
      MESSAGE e531(0u) WITH lv_mess.                                     "Datei konnte vom Betriebssystem nicht geöffnet werden
    ENDIF.

    TRANSFER uv_pdf TO lv_file_appl.                                     "Inhalt wird in Datei geschrieben

    CLOSE DATASET lv_file_appl.                                          "Datei wird geschlossen

* Datei & erfolgreich erstellt!
    MESSAGE s060(z_fi_ea_forms) WITH lv_filename.


  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ueberzahlung
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ueberzahlung .

  TYPES: BEGIN OF s_fields,
           kunnr TYPE kunnr,
           bukrs TYPE bukrs,
           belnr TYPE belnr_d,
           gjahr TYPE gjahr,
           buzei TYPE buzei,
           budat TYPE budat,                                "Buchungsdatum
           blart TYPE blart,                                "Belegart
           shkzg TYPE shkzg,                                "Soll/Haben
           dmbtr TYPE dmbtr,                                "Betrag in Hauswährung
           wrbtr TYPE wrbtr,                                "Betrag in Transaktionswährung
           waers TYPE waers,                                "Währungskennzeichen
           xblnr TYPE xblnr,                                "Referenz
         END OF s_fields.

  DATA: lv_amount     TYPE feb_bsproc_worklist_fe-kwbtr,
        lv_amount_act TYPE feb_bsproc_worklist_fe-kwbtr,
        lv_value_text TYPE char100,
        lv_xblnr      TYPE xblnr1,
        lv_name1      TYPE kunnr,
        lv_waers      TYPE waers,
        ls_fields     TYPE s_fields,
        lt_fields     TYPE STANDARD TABLE OF s_fields,
        lt_fields2    TYPE STANDARD TABLE OF s_fields.

  lv_xblnr = gs_fp_data-ao_kasze.

* Offene Posten zur Annordnung lesen
  SELECT kunnr, bukrs, belnr, gjahr, buzei, budat, blart, shkzg, dmbtr, wrbtr, waers, xblnr FROM bsid
                WHERE xblnr = @lv_xblnr
    INTO TABLE @lt_fields.

* Ausgeglichene Posten zur Annordnung lesen
  SELECT kunnr, bukrs, belnr, gjahr, buzei, budat, blart, shkzg, dmbtr, wrbtr, waers, xblnr FROM bsad
                WHERE xblnr = @lv_xblnr
    INTO TABLE @lt_fields2.

* aufsteigend nach Datum sortieren
  SORT lt_fields BY budat buzei.

  CLEAR: lv_amount, lv_amount_act, lv_waers.

  IF NOT lt_fields[] IS INITIAL OR NOT lt_fields2[] IS INITIAL.

* Offene Posten
    LOOP AT lt_fields INTO ls_fields.
      IF lv_waers IS INITIAL.
        SELECT SINGLE waers FROM t001 INTO lv_waers
           WHERE bukrs EQ ls_fields-bukrs.
      ENDIF.
* Nach Soll/Haben Kennzeichen
      IF ls_fields-shkzg EQ 'S'.
        IF gs_fp_data-ao_faellig IS INITIAL.
          SELECT SINGLE netdt FROM bseg INTO gs_fp_data-ao_faellig
             WHERE bukrs EQ ls_fields-bukrs
               AND belnr EQ ls_fields-belnr
               AND gjahr EQ ls_fields-gjahr
               AND buzei EQ ls_fields-buzei.
        ENDIF.
        lv_amount = lv_amount + ls_fields-dmbtr.
      ENDIF.
    ENDLOOP.

* Ausgeglichene Posten
    LOOP AT lt_fields2 INTO ls_fields.
      IF lv_waers IS INITIAL.
        SELECT SINGLE waers FROM t001 INTO lv_waers
           WHERE bukrs EQ ls_fields-bukrs.
      ENDIF.
* Nach Soll/Haben Kennzeichen
      IF ls_fields-shkzg EQ 'S'.
        IF gs_fp_data-ao_faellig IS INITIAL.
          SELECT SINGLE netdt FROM bseg INTO gs_fp_data-ao_faellig
             WHERE bukrs EQ ls_fields-bukrs
               AND belnr EQ ls_fields-belnr
               AND gjahr EQ ls_fields-gjahr
               AND buzei EQ ls_fields-buzei.
        ENDIF.
        lv_amount     = lv_amount     + ls_fields-dmbtr.
        lv_amount_act = lv_amount_act + ls_fields-dmbtr.

        IF gs_fp_data-ao_einzahler IS INITIAL.
          SELECT SINGLE name1 FROM kna1 INTO lv_name1
             WHERE kunnr EQ ls_fields-kunnr.
          IF sy-subrc EQ 0.
            gs_fp_data-ao_einzahler = lv_name1.
          ENDIF.
          gs_fp_data-ao_budat = ls_fields-budat.
        ENDIF.
      ELSE.
        lv_amount     = lv_amount     - ls_fields-dmbtr.
        lv_amount_act = lv_amount_act - ls_fields-dmbtr.
      ENDIF.
    ENDLOOP.


* Soll Betrag aufbereiten und mit Währung versehen.
    WRITE lv_amount TO lv_value_text CURRENCY lv_waers .

    gs_fp_data-ao_soll_betrag_text = lv_value_text.

    IF lv_waers EQ 'EUR'.
      CONCATENATE gs_fp_data-ao_soll_betrag_text '€'
        INTO gs_fp_data-ao_soll_betrag_text SEPARATED BY space.
    ELSE.
      CONCATENATE gs_fp_data-ao_soll_betrag_text lv_waers
        INTO gs_fp_data-ao_soll_betrag_text SEPARATED BY space.
    ENDIF.
    SHIFT gs_fp_data-ao_soll_betrag_text LEFT DELETING LEADING space.

    CLEAR lv_amount.
* Ist Betrag aufbereiten und mit Währung versehen.
    WRITE lv_amount_act TO lv_value_text CURRENCY lv_waers.

    gs_fp_data-ao_ist_betrag_text = lv_value_text.

    IF lv_waers EQ 'EUR'.
      CONCATENATE gs_fp_data-ao_ist_betrag_text '€'
        INTO gs_fp_data-ao_ist_betrag_text SEPARATED BY space.
    ELSE.
      CONCATENATE gs_fp_data-ao_ist_betrag_text lv_waers
        INTO gs_fp_data-ao_ist_betrag_text SEPARATED BY space.
    ENDIF.
    SHIFT gs_fp_data-ao_ist_betrag_text LEFT DELETING LEADING space.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_pkh_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_pkh_data .
*
** Ratenverarbeitung SD
*  DATA: lv_anordnungsbetrag      TYPE vbak-zz_021,
*        ls_raten_summen          TYPE zst_raten_summen,
*        ls_faellige_raten_summen TYPE zst_raten_summen,
*        lv_zahlungseingaenge     TYPE wrbtr,
*        lv_saldo                 TYPE wrbtr,
*        lv_kontostand            TYPE wrbtr,
*        ls_druck                 TYPE /thkr/bn_druck,
*        ls_adrc                  TYPE adrc,
*        ls_vbak                  TYPE vbak,
*        lv_temp                  TYPE char100,
*        lv_belnr                 TYPE belnr_d VALUE '1',
*        lv_formid                TYPE zde_form_id,
*        lv_init_posnr            TYPE posnr,
*        lv_adrnr                 TYPE adrnr,
*        ls_vbap_first            TYPE vbap,
*        ls_zsachbearbpkh         TYPE zsachbearbpkh.
*
** Auftrag zu Kassenzeichen ermitteln
*
*  SELECT * FROM vbak INTO ls_vbak
*                          UP TO 1 ROWS
*                          WHERE auart EQ 'ZLE7'
*                            AND xblnr EQ gs_fp_data-kasze
*                          ORDER BY PRIMARY KEY.
** Rechnungsempfänger
*    SELECT adrnr FROM vbpa INTO lv_adrnr
*                            UP TO 1 ROWS
*                           WHERE vbeln EQ ls_vbak-vbeln
*                             AND posnr EQ lv_init_posnr
*                             AND parvw EQ 'RE'
*                          ORDER BY PRIMARY KEY.
*    ENDSELECT.
*
*    IF NOT lv_adrnr IS INITIAL.
** Standard Adressdaten des Rechnungsempfängers beschaffen
*      ls_adrc = zcl_db_address=>get_adrc( EXPORTING iv_addrnumber = lv_adrnr ).
*
**Formatierte Adressdaten des Rechnungsempfängers beschaffen
*      IF NOT ls_adrc IS INITIAL.
*        gs_fp_data-pkh_daten-recipient = zcl_db_sd_formulare=>get_adressdaten_person( is_adrc = ls_adrc ).
**                                                                            iv_mit_anrede = space ).
*      ENDIF.
*    ENDIF.
*
*    IF NOT ls_vbak-vbeln IS INITIAL.
*
**===== Geschäftszeichen lesen
*      gs_fp_data-pkh_daten-geschaeftszeichen = ls_vbak-zz_001.
*
**===== Erste Kundenauftragsposition ermitteln
*      ls_vbap_first = zcl_db_sd_sales_order=>get_position_first( iv_vbeln = ls_vbak-vbeln ).
*
**===== Finanzstelle ermitteln
*      gs_fp_data-pkh_daten-fistl = zcl_db_fi_fm_fmzuob=>get_fistl(
*        EXPORTING iv_vbeln = ls_vbap_first-vbeln
*                  iv_posnr = ls_vbap_first-posnr
*      ).
*
**===== Sachbearbeiter ermitteln
*      ls_zsachbearbpkh = zcl_db_zsachbearbpkh=>get_record( EXPORTING iv_vkorg = ls_vbak-vkorg iv_vkbur = ls_vbak-vkbur ).
*
*      CONCATENATE ls_zsachbearbpkh-anrede ls_zsachbearbpkh-name INTO gs_fp_data-pkh_daten-sachbearbeiter SEPARATED BY space.
*      gs_fp_data-pkh_daten-sb_telnr = ls_zsachbearbpkh-telnr.
*      gs_fp_data-pkh_daten-sb_telfx = ls_zsachbearbpkh-telfx.
*
** Verwendungszweck
*      CONCATENATE ls_vbak-zz_004 ' ' ls_vbak-zz_008 INTO gs_fp_data-pkh_daten-verwendungszweck RESPECTING BLANKS.
** Anordnungsbetrag
*      lv_anordnungsbetrag = ls_vbak-zz_021 - ls_vbak-zz_022.
*      WRITE lv_anordnungsbetrag TO lv_temp CURRENCY ls_vbak-waerk LEFT-JUSTIFIED.
*      CONCATENATE lv_temp ls_vbak-waerk INTO gs_fp_data-pkh_daten-anordnungsbetrag SEPARATED BY space.
** Raten
*      ls_raten_summen = zcl_db_sd_formulare=>get_ratensummen( iv_vbeln = ls_vbak-vbeln ).
*      WRITE ls_raten_summen-fakwr TO lv_temp CURRENCY ls_raten_summen-waers LEFT-JUSTIFIED.
*
*      CONCATENATE lv_temp ls_raten_summen-waers INTO gs_fp_data-pkh_daten-geforderte_leistung SEPARATED BY space.
*      gs_fp_data-pkh_daten-anzahl_raten = ls_raten_summen-anzahl.
*
** Ratenänderungen
*      gs_fp_data-pkh_daten-ratenaenderungen = zcl_db_sd_formulare=>get_ratenaenderungen( iv_vbeln = ls_vbak-vbeln ).
*
*      ls_faellige_raten_summen = zcl_db_sd_formulare=>get_ratensummen(
*                                    iv_vbeln    = ls_vbak-vbeln
*                                    iv_stichtag = sy-datum
*                                 ).
*      WRITE ls_faellige_raten_summen-fakwr TO lv_temp CURRENCY ls_faellige_raten_summen-waers LEFT-JUSTIFIED.
*      CONCATENATE lv_temp ls_faellige_raten_summen-waers INTO gs_fp_data-pkh_daten-faellige_raten SEPARATED BY space.
*
*      gs_fp_data-pkh_daten-anzahl_faellige_raten = ls_faellige_raten_summen-anzahl.
*
** Zahlungseingänge
*      lv_zahlungseingaenge = zcl_db_sd_formulare=>get_zahlungseingaenge( iv_vbeln = ls_vbak-vbeln ).
*      WRITE lv_zahlungseingaenge TO lv_temp CURRENCY ls_vbak-waerk LEFT-JUSTIFIED.
*      CONCATENATE lv_temp ls_vbak-waerk INTO gs_fp_data-pkh_daten-geleistete_zahlungen SEPARATED BY space.
*
** Kontostand
*      lv_kontostand = lv_zahlungseingaenge + gs_worklist_fe-kwbtr.
*      WRITE lv_kontostand TO lv_temp CURRENCY ls_vbak-waerk LEFT-JUSTIFIED.
*      CONCATENATE lv_temp ls_vbak-waerk INTO gs_fp_data-pkh_daten-kontostand SEPARATED BY space.
*
** Kontoveränderung
*      WRITE gs_worklist_fe-kwbtr TO lv_temp CURRENCY gs_worklist_fe-kwaer LEFT-JUSTIFIED.
*      CONCATENATE lv_temp gs_worklist_fe-kwaer INTO gs_fp_data-pkh_daten-kontoaenderung SEPARATED BY space.
*
*
** Saldo
*      lv_saldo = lv_zahlungseingaenge - ls_faellige_raten_summen-fakwr.
*      WRITE lv_saldo TO lv_temp CURRENCY ls_vbak-waerk NO-SIGN LEFT-JUSTIFIED .
*      CONCATENATE lv_temp ls_vbak-waerk INTO gs_fp_data-pkh_daten-saldo SEPARATED BY space.
*
*      IF lv_saldo GE 0.
** Überzahlung
*        gs_fp_data-pkh_daten-saldo_art = 'U'.
*      ELSE.
** Rückstand
*        gs_fp_data-pkh_daten-saldo_art = 'R'.
*      ENDIF.
*
** Adresse Absender
*      gs_fp_data-pkh_daten-adresse_lok = zcl_sd_formulare=>get_adressdaten_lok( ).
*
** OFD Headersatz für Druckdienstleister (nur bei Erstverarbeitung mit Dateierstellung)
*      CASE gs_fp_data-formtype.
*        WHEN '4'.
*          lv_formid = '540'.
*
*          gs_fp_data-pkh_daten-ofd_header = zcl_db_sd_formulare=>get_ofd_headersatz(
*                                                        iv_form_id     = lv_formid
*                                                        is_adrc        = ls_adrc
*                                                        iv_belnr       = lv_belnr
*                                                        ).
*
*        WHEN '5'.
*          lv_formid = '872'.
*
*          gs_fp_data-pkh_daten-ofd_header = zcl_db_sd_formulare=>get_ofd_headersatz(
*                                                        iv_form_id     = lv_formid
*                                                        is_adrc        = ls_adrc
*                                                        iv_belnr       = lv_belnr
*                                                        ).
*        WHEN OTHERS.
*          lv_formid = '872'.
*
*          gs_fp_data-pkh_daten-ofd_header = zcl_db_sd_formulare=>get_ofd_headersatz(
*                                                        iv_form_id     = lv_formid
*                                                        is_adrc        = ls_adrc
*                                                        iv_belnr       = lv_belnr
*                                                        ).
*      ENDCASE.
*
*    ENDIF.
*  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_external
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> UV_PDF
*&---------------------------------------------------------------------*
FORM send_external  USING uv_pdf TYPE fpcontent..
  DATA:
    lv_mailtxt_size TYPE i,               " Text in mail size
    lt_mailpack     TYPE TABLE OF sopcklsti1,  " Objektbestandteile
    lt_mailhead     TYPE TABLE OF solisti1,    " Kopfdaten
    lt_reclist      TYPE TABLE OF somlreci1,   " Empfängerliste
    lt_mailtxt      TYPE swftlisti1,           " Mail Text
    ls_doc_att      TYPE sodocchgi1,           " Attribute
    ls_mailpack     TYPE sopcklsti1,           " Objektbestandteile
    ls_reclist      TYPE somlreci1.            " Empfängerliste



  DATA:
    lt_att_content_hex TYPE solix_tab,
    lv_length          TYPE i.


* PDF nach BIN konvertieren
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = uv_pdf
*     APPEND_TO_TABLE       = ' '
    IMPORTING
      output_length = lv_length
    TABLES
      binary_tab    = lt_att_content_hex.

*--- Get the e-mail-text
  PERFORM get_internal_mail_body CHANGING lt_mailtxt.
  lv_mailtxt_size = lines( lt_mailtxt ).

* Attribute setzen
  IF gv_betreff IS INITIAL.
    ls_doc_att-obj_descr = gs_outputparams-covtitle.
  ELSE.
    ls_doc_att-obj_descr  = gv_betreff.
  ENDIF.
  ls_doc_att-sensitivty = 'F'.
  ls_doc_att-doc_size   = lv_mailtxt_size * gc_max_comp.

* für Mail Körper
  ls_mailpack-transf_bin   = space.
  ls_mailpack-head_start   = 1.
  ls_mailpack-head_num     = 0.
  ls_mailpack-body_start   = 1.
  ls_mailpack-body_num     = lv_mailtxt_size.
  ls_mailpack-doc_type     = 'RAW'.
  APPEND ls_mailpack TO lt_mailpack.

* für Anhang
  ls_mailpack-transf_bin   = 'X'.
  ls_mailpack-head_start   = 1.
  ls_mailpack-head_num     = 1.
  ls_mailpack-body_start   = 1.
  ls_mailpack-body_num     = lv_length.
  ls_mailpack-doc_type     = 'PDF'.
  WRITE gv_betreff TO ls_mailpack-obj_descr.
  ls_mailpack-doc_size     = lv_length * gc_max_comp.
  APPEND ls_mailpack TO lt_mailpack.

* e-mail Empfänger
  ls_reclist-receiver   = gv_email_addr.
  ls_reclist-rec_type   = 'U'.
*ls_reclist-notif_del  = 'X'. " request delivery notification
*ls_reclist-notif_ndel = 'X'. " request not delivered notification
  APPEND ls_reclist TO lt_reclist.

* Weitere e-mail Empfänger
  LOOP AT gt_email_addr INTO gs_email_addr.
    IF NOT gs_email_addr-receiver IS INITIAL.
      ls_reclist-receiver   = gs_email_addr-receiver.
      ls_reclist-rec_type   = 'U'.
*ls_reclist-notif_del  = 'X'. " request delivery notification
*ls_reclist-notif_ndel = 'X'. " request not delivered notification
      APPEND ls_reclist TO lt_reclist.
    ENDIF.
  ENDLOOP.


* interne E-Mail senden
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = ls_doc_att
      put_in_outbox              = 'X'
      commit_work                = 'X'
    TABLES
      packing_list               = lt_mailpack
      object_header              = lt_mailhead
      contents_txt               = lt_mailtxt
      contents_hex               = lt_att_content_hex
      receivers                  = lt_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ELSE.
* Dokument gesendet
    MESSAGE s022(so).
  ENDIF.
ENDFORM.
