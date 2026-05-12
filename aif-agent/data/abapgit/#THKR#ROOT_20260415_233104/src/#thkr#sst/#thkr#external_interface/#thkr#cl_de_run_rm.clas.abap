class /THKR/CL_DE_RUN_RM definition
  public
  inheriting from /THKR/CL_DE_RUN_BASE
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !I_PROCESS_TYPE type /THKR/PROCESS_TYPE
      !I_FREMDVERF type /THKR/FREMDVERF optional
      !I_PROCESS_ID type /THKR/PROCESS_ID optional
      !I_PATH type PATHEXTERN optional
      !I_TEST type XFELD optional
      !I_TEST_SUFFIX type /THKR/TEST_SUFFIX optional
      !I_FI_DOC_SELECTION type /THKR/S_FI_DOCUMENT_SELECTION optional .

  methods PROCESS
    redefinition .
protected section.
private section.

  methods PROCESS_EXPORT .
ENDCLASS.



CLASS /THKR/CL_DE_RUN_RM IMPLEMENTATION.


  METHOD constructor.

    super->constructor(
      EXPORTING
        i_process_type = i_process_type
        i_fremdverf    = i_fremdverf
        i_process_id   = i_process_id
        i_path         = i_path
        i_test         = i_test
        i_test_suffix  = i_test_suffix ).

    IF i_process_id IS NOT INITIAL.
      read( ).
    ENDIF.

    fi_doc_selection = i_fi_doc_selection.

  ENDMETHOD.


  METHOD process.

    DATA: l_is_new_run TYPE xfeld.

    TRY.
        IF process_id IS INITIAL.
          l_is_new_run = 'X'.
          IF i_frontend IS NOT INITIAL.
            "In diesem Fall ist i_filename der Client-Pfad
            path = i_filename.
          ENDIF.

          save( ).  "Prozess-ID ermitteln lassen (falls noch nicht vergeben)
        ELSE.
          RETURN.   "Bisher keine erneutes Anstoßen des Prozesses vorgesehen
        ENDIF.

        DO 1 TIMES.
          CASE process_type.
            WHEN 'IR_E'.      "Export Ist-Rückmeldungern
              process_export( ).
            WHEN OTHERS.
              ASSERT 1 = 2.
          ENDCASE.
        ENDDO.

      CATCH cx_root INTO DATA(l_oerror).
        add_event(
          EXPORTING
            i_exception = l_oerror ).

    ENDTRY.

    save( ).

  ENDMETHOD.


  METHOD process_export.

    TYPES: BEGIN OF lty_para,
             irm_line TYPE REF TO data,
           END OF lty_para.

    DATA: l_para  TYPE lty_para,
          lr_item TYPE REF TO data.

    FIELD-SYMBOLS: <rm_tab> TYPE STANDARD TABLE.

** Für Test ***************
*    DATA: lr_test_line TYPE REF TO data,
*          lr_test_tab  TYPE REF TO data.
*
*    FIELD-SYMBOLS: <treffer> TYPE STANDARD TABLE.
*
*    gi_appl->get_record_type_handles(
*      EXPORTING
*        i_record_id    = 'RM_ITEM'
*      IMPORTING
*        e_struct_descr = DATA(l_struct_descr)
*        e_table_descr  = DATA(l_table_descr) ).
*
*    CREATE DATA lr_test_line TYPE HANDLE l_struct_descr.
*    CREATE DATA lr_test_tab TYPE HANDLE l_table_descr.
*    ASSIGN lr_test_tab->* TO <treffer>.
*
*    DO 2 TIMES.
*      lr_test_line->('BUKRS') = '1234'.
*      lr_test_line->('GJAHR') = '2024'.
*      lr_test_line->('BELNR') = sy-tabix.
*      lr_test_line->('XBLNR') = '987654321'.
*      lr_test_line->('BETRAG') = '12.56'.
*      APPEND lr_test_line->* TO <treffer>.
*    ENDDO.
*
** Ende für Test **********


    DATA: lr_fi_doc_line  TYPE REF TO data,
          lr_fi_doc_tab   TYPE REF TO data,

          lt_dto_fi_beleg TYPE /thkr/t_dto_fi_document,
          l_exc           TYPE xfeld.

*          fi_doc TYPE ref to /thkr/cl_fi_int.

    FIELD-SYMBOLS: <treffer> TYPE STANDARD TABLE.

    gi_appl->get_record_type_handles(
      EXPORTING
        i_record_id    = 'RM_ITEM'
      IMPORTING
        e_struct_descr = DATA(l_struct_descr)
        e_table_descr  = DATA(l_table_descr) ).

    CREATE DATA lr_fi_doc_line TYPE HANDLE l_struct_descr.
    CREATE DATA lr_fi_doc_tab TYPE HANDLE l_table_descr.
    ASSIGN lr_fi_doc_tab->* TO <treffer>.

*    CREATE OBJECT fi_doc TYPE /thkr/cl_fi_int.

* Obsolet
*    fi_doc->get_tdto_fi_document(
*      EXPORTING
*        i_selection        = fi_doc_selection
*        i_raise_exceptions = l_exc
*      IMPORTING
*        et_dto             = lt_dto_fi_beleg ).

    LOOP AT lt_dto_fi_beleg ASSIGNING FIELD-SYMBOL(<beleg>).
      lr_fi_doc_line->('BUKRS') = <beleg>-bukrs.
      lr_fi_doc_line->('GJAHR') = <beleg>-gjahr.
      lr_fi_doc_line->('BELNR') = <beleg>-belnr.
      lr_fi_doc_line->('XBLNR') = <beleg>-xblnr.
      LOOP AT <beleg>-t_line ASSIGNING FIELD-SYMBOL(<line>).
        lr_fi_doc_line->('BETRAG') = lr_fi_doc_line->('BETRAG') + <line>-dmbtr.
      ENDLOOP.
      APPEND lr_fi_doc_line->* TO <treffer>.
    ENDLOOP.







    "Datensatz-Informationen zur Ist-Rückmeldungs-Datei ermitteln
    gi_appl->get_record_definition(
      EXPORTING
        i_record_id = dto_fv_pr_art-record_id_header
      IMPORTING
        e_record    = DATA(l_record_definition) ).

    "Aus der Datensatzbeschreibung das Feld auslesen, welches die Tabelle mit den Einzelsätzen
    "enthält

    READ TABLE l_record_definition-t_fld WITH KEY table_record_id = dto_fv_pr_art-record_id_item
      INTO DATA(l_rec_fld).
    ASSERT sy-subrc = 0.

    ASSIGN exch_data-proc_data->(l_rec_fld-record_fld) TO <rm_tab>.
    CREATE DATA lr_item TYPE HANDLE type_handle_item.
    ASSIGN lr_item->* TO FIELD-SYMBOL(<rm>).

    LOOP AT <treffer> REFERENCE INTO l_para-irm_line.
      TRY.
        clear: <rm>.
          gi_appl->get_data_by_gi(
            EXPORTING
              i_gi_id = 'IR_E_LINE_T'
              i_para  = l_para
            CHANGING
              c_data  = <rm> ).

          APPEND <rm> TO <rm_tab>.

        CATCH /thkr/cx_gi.
          "Fehlerbehandlung Satz-Export
      ENDTRY.

    ENDLOOP.

    IF <rm_tab> IS NOT INITIAL.
      "Datei erzeugen
      TRY.

          IF dto_fv_pr_art-de_format = 'XML'.
            ASSIGN exch_data-proc_data->* TO FIELD-SYMBOL(<proc_data>).

            CALL TRANSFORMATION (dto_fv_pr_art-de_xslt)
              SOURCE file = <proc_data>
              RESULT XML xml_string.

          ELSE.
            "Textexport
            ASSERT 1 = 2.
          ENDIF.

          IF is_test IS INITIAL.
            create_export_file( ).
          ENDIF.

        CATCH cx_root INTO DATA(l_oerror).
          add_event(
            EXPORTING
              i_event_category = 'E'
*             i_event_category2 = ''
*             i_mess           =
*             i_amnt           =
*             i_waers          =
*             i_event_date     =
              i_exception      = l_oerror
*             it_mapping       =
*             it_ln_evt        =
*             i_ln_art         =
*             i_ln_key         =
*             i_date           =
*             i_time           =
*             i_cr_user        =
          ).

      ENDTRY.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
