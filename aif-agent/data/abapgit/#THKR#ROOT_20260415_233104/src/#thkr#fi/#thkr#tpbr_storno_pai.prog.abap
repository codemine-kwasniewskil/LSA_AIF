*&---------------------------------------------------------------------*
*& Include          /THKR/TPBR_STORNO_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  OKCOD_VERARBEITUNG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE okcod_verarbeitung INPUT.

  CASE ok-code.
* Abbruch
    WHEN 'AE'.
      PERFORM init.
      IF sy-tcode = gc_tcode_k .                      "001
        CALL SCREEN '0110'.
      ELSE.
        CALL SCREEN '0100'.
      ENDIF.
    WHEN 'RW'.
      PERFORM init.
      IF sy-tcode = gc_tcode_k .                      "001
        CALL SCREEN '0110'.
      ELSE.
        CALL SCREEN '0100'.
      ENDIF.
    WHEN 'END'.
      LEAVE PROGRAM.
    WHEN 'ABR'.
      LEAVE PROGRAM.
* Anzeige
    WHEN 'ANZ'.
      PERFORM beleg_anzeigen.
    WHEN 'ANZRE'.
      PERFORM vertrag_anzeigen.
* Verarbeitung
    WHEN 'OK_MM'.
      CALL SCREEN '0301'.
    WHEN 'OK_SD'.
      CALL SCREEN '0302'.
    WHEN 'OK_FI'.
      gv_modus = 'FI'.
      CALL SCREEN '0303'.
    WHEN 'OK_AL'.
      gv_modus = 'AL'.
      CALL SCREEN '0303'.
    WHEN 'OK_VI'.
      gv_modus = 'VI'.
      CALL SCREEN '0304'.
    WHEN 'OK_FB'.                 "FÖBIS
      gv_modus = 'FB'.
      CALL SCREEN '0304'.
    WHEN 'OK_RE'.                 "REFX
      gv_modus = 'RE'.
*      CLEAR gs_refnr.
      CALL SCREEN '0305'.
    WHEN 'MORER'.                 "Weitere REFX Referenznummern
      CALL SCREEN '0905'.
    WHEN 'SAVE'.
      IF sy-dynnr NE '0100' AND sy-dynnr NE '0110'.      "001
        CLEAR ok-code.
        PERFORM beleg_lesen.
        IF gv_modus = 'RE' AND gv_fehler IS NOT INITIAL.
          " Keine weitere Verarbeitung
        ELSE.
          PERFORM eingaben_verarbeiten.
          IF gv_modus = 'RE' AND gv_fehler IS NOT INITIAL.
            " Keine weitere Verarbeitung
          ELSE.
            PERFORM beleg_sichern.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      IF sy-dynnr NE '0100' AND sy-dynnr NE '0110'.      "001
        CLEAR ok-code.
        PERFORM beleg_lesen.
        PERFORM eingaben_verarbeiten.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  KOMFK_STGRD_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE komfk_stgrd_help INPUT.

  DATA: lt_links TYPE TABLE OF tline.

  CALL FUNCTION 'HELP_OBJECT_SHOW'
    EXPORTING
      dokclass   = 'DE'
      doklangu   = sy-langu
      dokname    = 'J_3RF_SD_STGRD'
      short_text = 'X'
    TABLES
      links      = lt_links.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  XKOMFK_STGRD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE xkomfk_stgrd INPUT.

  gs_storno-stgrd = vbrk-stgrd.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LEAVE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE leave INPUT.

  CASE ok-code.
    WHEN 'RW'.
      PERFORM init.
      IF sy-tcode = gc_tcode_k .                      "001
        CALL SCREEN '0110'.
      ELSE.
        CALL SCREEN '0100'.
      ENDIF.
    WHEN 'END'.
      LEAVE PROGRAM.
    WHEN 'ABR'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0905  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0905 INPUT.

  CASE okcode_t.
    WHEN 'SAVE' OR 'CANC'.
      IF okcode_t = 'SAVE'.
        " Prüfung ob die Referenznummer schon in der Tabelle ZFI_REFX_REFNR
        " vorhanden sind
        PERFORM check_refernzen_unique.
      ELSE.
        " Zurück zum Hauptbild ohne Sicherung
        gv_fehler = abap_false.
      ENDIF.

      IF gv_fehler IS INITIAL.
        " Rücksprung auf das Hauptbild
        CALL SCREEN '0305'.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LEAVE_905  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE leave_905 INPUT.

  CASE okcode_t.
    WHEN 'RW'.
      CALL SCREEN '0305'.
    WHEN 'END'.
      PERFORM init.
      IF sy-tcode = gc_tcode_k .                      "001
        CALL SCREEN '0110'.
      ELSE.
        CALL SCREEN '0100'.
      ENDIF.
    WHEN 'ABR'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'REFERENZEN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE referenzen_modify INPUT.
*  " Prüfung ob Eintrag schon vorhanden
*  READ TABLE gt_referenz ASSIGNING FIELD-SYMBOL(<ls_referenz>)
*                         INDEX referenzen-current_line.
*  IF sy-subrc <> 0.
*    INSERT gs_referenz INTO gt_referenz INDEX referenzen-current_line.
*  ELSEIF <ls_referenz>-refnr <> gs_referenz-refnr.
*    " Prüfung ob Eintrag mit der Referenznummer schon vorhanden
*    READ TABLE gt_referenz TRANSPORTING NO FIELDS WITH KEY refnr = gs_referenz-refnr.
*    IF sy-subrc <> 0.
*      APPEND gs_referenz TO gt_referenz.
*    ENDIF.
*  ENDIF.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'REFERENZEN'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE referenzen_user_command INPUT.
  okcode_t = sy-ucomm.
  PERFORM user_ok_tc USING    'REFERENZEN'
                              'GT_REFERENZ'
                              ' '
                     CHANGING okcode_t.
  sy-ucomm = okcode_t.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_NEXT_NUMBER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_next_number INPUT.

  IF gs_storno-lfdnr IS INITIAL.
    " Vertragsnummer mit Vornullen auffüllen
    DO.
      IF gs_storno-recnnr+12(1) = space.
        SHIFT gs_storno-recnnr RIGHT.
        gs_storno-recnnr(1) = 0.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
    " Setzen Modul
    gs_storno-modul = 'RE'.
    " Ermitteln letzte laufende Nummer
    SELECT lfdnr INTO TABLE @DATA(lt_lfdnr) FROM /THKR/STORNOC
                                            WHERE bukrs = @gs_storno-bukrs
                                              AND modul = @gs_storno-modul
                                              AND gjahr = @gs_storno-gjahr
                                              AND recnnr = @gs_storno-recnnr.
    IF sy-subrc = 0.
      SORT lt_lfdnr BY lfdnr DESCENDING.
      READ TABLE lt_lfdnr INTO gs_storno-lfdnr INDEX 1.
    ENDIF.

    " Setzen der neuen laufenden Nummer
    ADD 1 TO gs_storno-lfdnr.
  ENDIF.

ENDMODULE.
