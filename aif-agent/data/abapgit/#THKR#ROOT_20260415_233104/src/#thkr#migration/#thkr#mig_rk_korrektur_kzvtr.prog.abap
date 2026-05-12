*&---------------------------------------------------------------------*
*& Report /THKR/MIG_RK_KORREKTUR_KZVTR
*&---------------------------------------------------------------------*
*& Auftrag/Incident: 4000000834/INC08849269 - Mig.Daten Gläubiger
*& Datum           : 23.02.2023
*& Benutzer        : ZHM000000379
*& Beschreibung
*& Das Programm korrigiert das Vetreterkennzeichen in der Tabelle
*& /THKR/MIGD_RK_ZP, da diese im Ursprung nicht korrekt übergeben wurde
*&
*&
*&---------------------------------------------------------------------*

REPORT /thkr/mig_rk_korrektur_kzvtr.


**********************************************************************
* Deklarationen
**********************************************************************
TABLES: /thkr/migd_rk_zp.

TYPES: BEGIN OF ty_data,
         satz_id         TYPE /thkr/de_satz_id,
         zp_nummer       TYPE /thkr/mig_zp_nummer,
         zp_lfd_nummer   TYPE /thkr/mig_zp_lfd_nummer,
         zp_rolle        TYPE /thkr/migd_rk_zp-zp_rolle,
         kennz_vertreter TYPE /thkr/migd_rk_zp-kennz_vertreter,
         kennz_new       TYPE /thkr/migd_rk_zp-kennz_vertreter,
         namezeile1      TYPE /thkr/migd_rk_zp-namezeile1,
         namezeile2      TYPE /thkr/migd_rk_zp-namezeile2,
         mtype           TYPE bapiret2-type,
         message         TYPE bapiret2-message,
       END OF ty_data,
       tty_data TYPE TABLE OF ty_data.


DATA: gt_data_ch TYPE tty_data.
DATA: gt_data    TYPE TABLE OF /thkr/mig_rk_zph.

**********************************************************************
* Selektionsbild
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: so_SATZ  FOR /thkr/migd_rk_zp-satz_id,        "Satz-ID
                  so_ZPNR  FOR /thkr/migd_rk_zp-zp_nummer,      "Zahlungspartnernummer
                  so_ZPLFD FOR /thkr/migd_rk_zp-zp_lfd_nummer,  "Zahlungspartner laufende Nummer
                  so_ZPRO  FOR /thkr/migd_rk_zp-zp_rolle,       "Rolle Zahlungspartner: H(auptschuldner) V(ertreter)
                  so_KZVR  FOR /thkr/migd_rk_zp-kennz_vertreter."Zahlungspartner Rückstandskonto

SELECTION-SCREEN END OF BLOCK b1 .

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: p_new TYPE /thkr/migd_rk_zp-kennz_vertreter DEFAULT 'G'.
  SELECTION-SCREEN SKIP 1.
  PARAMETERS p_test AS  CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2 .



**********************************************************************
INITIALIZATION.
**********************************************************************
  so_zpro[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'V' ) ).
  so_kzvr[] = VALUE #( ( sign = 'I' option = 'EQ' low = 'K' ) ).


**********************************************************************
START-OF-SELECTION.
**********************************************************************

  p_new = to_upper( p_new ).


* Daten lesen
  SELECT * FROM /thkr/migd_rk_zp
    INTO CORRESPONDING FIELDS OF TABLE @gt_data
    WHERE satz_id         IN @so_SATZ
    AND   zp_nummer       IN @so_ZPNR
    AND   zp_lfd_nummer   IN @so_ZPLFD
    AND   zp_rolle        IN @so_ZPRO
    AND   kennz_vertreter IN @so_KZVR.


  IF gt_data[] IS INITIAL.
    MESSAGE s001(00) WITH 'Keine Daten gefunden' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).


    <fs_data>-chdate = sy-datum.
    <fs_data>-chtime = sy-uzeit.
    <fs_data>-chuser = sy-uname.

    UPDATE /thkr/migd_rk_zp
    SET kennz_vertreter = p_new
    WHERE satz_id       = <fs_data>-satz_id
    AND   zp_nummer     = <fs_data>-zp_nummer
    AND   zp_lfd_nummer = <fs_data>-zp_lfd_nummer
    AND   zp_rolle      = <fs_data>-zp_rolle.


    APPEND INITIAL LINE TO gt_data_ch ASSIGNING FIELD-SYMBOL(<fs_data_ch>).
    MOVE-CORRESPONDING <fs_data> TO <fs_data_ch>.

    IF p_test EQ abap_false AND sy-subrc EQ 0.
      MODIFY /thkr/mig_rk_zph FROM <fs_data>.
      COMMIT WORK.
      <fs_data_ch>-mtype = 'S'.
      <fs_data_ch>-message = 'Update erfolgreich'.
      <fs_data_ch>-kennz_new = p_new.
    ELSEIF p_test EQ abap_false AND sy-subrc NE 0.
      ROLLBACK WORK.
      <fs_data_ch>-mtype = 'E'.
      <fs_data_ch>-message = 'Update fehlgeschlagen'.
    ELSEIF p_test EQ abap_true AND sy-subrc EQ 0.
      ROLLBACK WORK.
      <fs_data_ch>-mtype = 'I'.
      <fs_data_ch>-message = 'Testmodus, erfolgreich'.
      <fs_data_ch>-kennz_new = p_new.
    ELSEIF p_test EQ abap_true AND sy-subrc EQ 0.
      ROLLBACK WORK.
      <fs_data_ch>-mtype = 'E'.
      <fs_data_ch>-message = 'Testmodus, fehlgeschlagen'.
    ENDIF.

  ENDLOOP.

  FREE gt_data.

*--------------------------------------------------------------------*
* Ergebnis ausgeben
*--------------------------------------------------------------------*
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                              CHANGING  t_table      = gt_data_ch ).

      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).

      lo_salv->get_columns( )->get_column( 'ZP_ROLLE' )->set_short_text( 'Rolle ZP' ).
      lo_salv->get_columns( )->get_column( 'ZP_ROLLE' )->set_long_text( 'Rolle Zahlungspartner' ).
      lo_salv->get_columns( )->get_column( 'ZP_ROLLE' )->set_medium_text( 'Rolle Zahlungsp.' ).
      lo_salv->get_columns( )->get_column( 'KENNZ_VERTRETER' )->set_short_text( 'KzVtr. alt' ).
      lo_salv->get_columns( )->get_column( 'KENNZ_VERTRETER' )->set_long_text( 'KennzVertr. alt' ).
      lo_salv->get_columns( )->get_column( 'KENNZ_VERTRETER' )->set_medium_text( 'KennzVertr. alt' ).
      lo_salv->get_columns( )->get_column( 'KENNZ_NEW' )->set_short_text( 'KzVtr. neu' ).
      lo_salv->get_columns( )->get_column( 'KENNZ_NEW' )->set_long_text( 'KennzVertr. neu' ).
      lo_salv->get_columns( )->get_column( 'KENNZ_NEW' )->set_medium_text( 'KennzVertr. neu' ).
      lo_salv->get_columns( )->get_column( 'NAMEZEILE1' )->set_short_text( 'Name 1' ).
      lo_salv->get_columns( )->get_column( 'NAMEZEILE1' )->set_long_text( 'Name 1' ).
      lo_salv->get_columns( )->get_column( 'NAMEZEILE1' )->set_medium_text( 'Name 1' ).
      lo_salv->get_columns( )->get_column( 'NAMEZEILE2' )->set_short_text( 'Name 2' ).
      lo_salv->get_columns( )->get_column( 'NAMEZEILE2' )->set_long_text( 'Name 2' ).
      lo_salv->get_columns( )->get_column( 'NAMEZEILE2' )->set_medium_text( 'Name 2' ).
      lo_salv->display( ).

    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.
