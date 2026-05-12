*&---------------------------------------------------------------------*
*& Report /THKR/MIG_RK_KORREKTUR_BUSORT1
*&---------------------------------------------------------------------*
*& Auftrag/Incident: 4000000796/INC08849269
*& Datum           : 09.03.2026
*& Benutzer        : ZHM000000379
*& Beschreibung:
*& Bei der Migration wurden bei einigen Geschäftspartner die externe
*& Geschäftspartnernummer überflüssigen Leerzeichen am Ende in das
*& Feld BU_SORT1 übernommen. Dadurch kommt zu Fehlern in der Methode
*& /THKR/CL_MIG_RK->FB_RK, die ohne die Leerzeichen liest.
*& Der Reprot entfernt die Überflüssigen Leerzeichen aus den Feldern
*&---------------------------------------------------------------------*

REPORT /thkr/mig_rk_korrektur_busort1.


**********************************************************************
* Types
**********************************************************************
TABLES: but000.

TYPES: BEGIN OF ty_data,
         partner  TYPE bu_partner,
         bu_sort1 TYPE bu_sort1,
         len_old  TYPE i,
         sort_new TYPE bu_sort1,
         len_new  TYPE i,
         mtype    TYPE bapiret2-type,
         message  TYPE bapiret2-message,
       END OF ty_data,
       tty_data TYPE TABLE OF ty_data.


**********************************************************************
* Data
**********************************************************************
DATA gv_space  TYPE c LENGTH 1 VALUE ' '.  "<- Geschütztes Leerzeichen!

DATA: gt_data TYPE tty_data.

DATA: gt_return    TYPE bapiret2_t.
DATA: gs_partner   TYPE bapibus1006_central.
DATA: gs_partner_x TYPE BAPIBUS1006_CENTRAL_x.
DATA: gv_error     TYPE abap_bool.

**********************************************************************
* Selktionsbild
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: so_partn FOR but000-partner.
  SELECT-OPTIONS: so_sort1 FOR but000-bu_sort1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.


**********************************************************************
INITIALIZATION.
**********************************************************************
  so_sort1[] = VALUE #( ( sign = 'I' option = 'CP' low = 'AHE*') ).


**********************************************************************
START-OF-SELECTION.
**********************************************************************


*--------------------------------------------------------------------*
* Daten zusammensuchen
*--------------------------------------------------------------------*
  SELECT partner, bu_sort1 FROM but000
    INTO TABLE @gt_data
    WHERE partner IN @so_partn
    AND   bu_sort1 IN @so_sort1.


  IF gt_data[] IS INITIAL.
    MESSAGE s001(00) WITH 'Keine Daten gefunden' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


*--------------------------------------------------------------------*
* Verarbeiten
*--------------------------------------------------------------------*
  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).


    FREE: gt_return.
    CLEAR: gs_partner, gs_partner_x, gv_error.
    gv_error = abap_false.
    DATA(lv_yes) = abap_false.


*   muss was gemacht werden?
    <fs_data>-len_old = strlen( <fs_data>-bu_sort1 ).
    DATA(lv_len) = <fs_data>-len_old - 1. "-1. weil bei 0 angefangen wird
    IF lv_len > 0 AND
    ( <fs_data>-bu_sort1+lv_len(1) = space OR <fs_data>-bu_sort1+lv_len(1) = gv_space ).
      lv_yes = abap_true.
    ENDIF.

    IF lv_yes EQ abap_true.

      gs_partner-searchterm1 = <fs_data>-bu_sort1.

      SHIFT gs_partner-searchterm1 RIGHT DELETING TRAILING space.
      SHIFT gs_partner-searchterm1 RIGHT DELETING TRAILING gv_space.
      SHIFT gs_partner-searchterm1 LEFT DELETING LEADING space.
      gs_partner-searchterm1 = gs_partner-searchterm1.
      gs_partner_x-searchterm1 = abap_true.

      <fs_data>-sort_new = gs_partner-searchterm1.
      <fs_data>-len_new = strlen( <fs_data>-sort_new ).

      CALL FUNCTION 'BAPI_BUPA_CENTRAL_CHANGE'
        EXPORTING
          businesspartner = <fs_data>-partner
          centraldata     = gs_partner
          centraldata_x   = gs_partner_x
        TABLES
          return          = gt_return.

      LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WHERE type CA 'AEX'.
        gv_error = abap_true.

        EXIT.
      ENDLOOP.

      IF gv_error EQ abap_true.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        <fs_data>-mtype = 'E'.
        <fs_data>-message = <fs_return>-message.
        CONTINUE.
      ENDIF.

      IF p_test EQ abap_true.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        <fs_data>-mtype = 'S'.
        <fs_data>-message = 'Korrektur wird erfolgen'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        <fs_data>-mtype = 'S'.
        <fs_data>-message = 'Korrektur erfolgt'.
      ENDIF.


    ELSE.
      <fs_data>-mtype = 'I'.
      <fs_data>-message = 'Keine Leerzeichen vorhanden'.
    ENDIF.

  ENDLOOP.


*--------------------------------------------------------------------*
* Ergebnis ausgeben
*--------------------------------------------------------------------*
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                              CHANGING  t_table      = gt_data ).

      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).
      lo_salv->get_columns( )->get_column( 'SORT_NEW' )->set_short_text( 'Suchb. neu' ).
      lo_salv->get_columns( )->get_column( 'SORT_NEW' )->set_long_text( 'Suchbegriff 1 neu' ).
      lo_salv->get_columns( )->get_column( 'SORT_NEW' )->set_medium_text( 'Suchbegriff 1 neu' ).
      lo_salv->get_columns( )->get_column( 'LEN_NEW' )->set_short_text( 'Länge neu' ).
      lo_salv->get_columns( )->get_column( 'LEN_NEW' )->set_long_text( 'Länge neu' ).
      lo_salv->get_columns( )->get_column( 'LEN_NEW' )->set_medium_text( 'Länge neu' ).
      lo_salv->get_columns( )->get_column( 'LEN_OLD' )->set_short_text( 'Länge alt' ).
      lo_salv->get_columns( )->get_column( 'LEN_OLD' )->set_long_text( 'Länge alt' ).
      lo_salv->get_columns( )->get_column( 'LEN_OLD' )->set_medium_text( 'Länge alt' ).
      lo_salv->display( ).

    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.
