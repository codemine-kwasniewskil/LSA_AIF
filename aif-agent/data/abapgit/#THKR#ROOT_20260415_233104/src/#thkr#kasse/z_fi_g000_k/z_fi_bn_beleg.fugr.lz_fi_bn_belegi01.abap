*----------------------------------------------------------------------*
***INCLUDE LZ_FI_BN_BELEGI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_9110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_9110 INPUT.

  PERFORM pai_9110_okcode.

*  LEAVE TO SCREEN 0.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form PAI_9110_OKCODE
*&---------------------------------------------------------------------*
*& OK_CODE im Bild Nachricht versenden
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM pai_9110_okcode .

  DATA: l_nachr     TYPE zfi_bn_nachricht,
        l_dto_nachr TYPE zfi_f_dto_nachr,
        ls_aktion   TYPE zfi_cu_bn_aktion,
        ls_empf     TYPE zfi_cu_bn_empf,
        ls_out      TYPE zfi_bn_druck,
        lo_oerror   TYPE REF TO cx_root,
        l_error     TYPE syst_subrc,
        l_message   TYPE string,
        l_bname     TYPE xubname.


  CASE ok_code.
    WHEN 'ENTER'.
      gs_out = zfi_bn_druck.
    WHEN 'CANCEL'.
      CLEAR gs_out.
      LEAVE TO SCREEN 0.
    WHEN 'PRINT'.

      IF zfi_f_dto_nachr-herk = 'Y'.
        gs_out = zfi_bn_druck.
*        gs_out-getpdf muss leer bleiben

*                   TRY.
        ls_empf-kzbnart = zfi_f_dto_nachr-kzbnart.
        zcl_fi_bn_nachrichten=>get_instance( )->create_za_pdf(
          EXPORTING
            i_nachr = zfi_f_dto_nachr
            i_empf = ls_empf
            i_druck = gs_out
          IMPORTING
           e_nachr = zfi_f_dto_nachr ).


      ENDIF.
    WHEN 'SENDEN'. "Nachricht senden

      TRY.
          ls_aktion-kzkom = 'B'.
          ls_empf-kzbnart = zfi_f_dto_nachr-kzbnart.

          IF zfi_f_dto_nachr-kzbnart = 'I'.
            ls_empf-empf = zfi_f_dto_nachr-empf.
            TRANSLATE ls_empf-empf TO UPPER CASE.
*           Existiert USER?
            SELECT SINGLE bname INTO l_bname
              FROM usr01
              WHERE bname EQ ls_empf-empf.
            IF sy-subrc <> 0.
              MESSAGE e027(z_fi_nachr) WITH ls_empf-empf.
            ENDIF.

          ELSEIF zfi_f_dto_nachr-kzbnart = 'E'.
            ls_empf-smtp_addr = zfi_f_dto_nachr-empf.
*           E-Mail-Adresse gültig?
            IF zfi_f_dto_nachr-empf NA '@'.
              MESSAGE e026(z_fi_nachr) WITH ls_empf-smtp_addr.
            ENDIF.
          ENDIF.

          zcl_fi_bn_nachrichten=>get_instance( )->process_nachr1(
            EXPORTING
             i_nachr  = zfi_f_dto_nachr
             i_ftext  = g_ftext
             i_aktion = ls_aktion
             i_empf   = ls_empf
            IMPORTING
             e_nachr = l_dto_nachr
             e_error = l_error  ).

        CATCH zcx_fi_gen INTO lo_oerror.
          l_message = lo_oerror->get_text( ).
          MESSAGE e002(z_fi_nachr) WITH l_message.
      ENDTRY.


    WHEN 'DELETE'. "Zeile löschen

      MOVE-CORRESPONDING zfi_f_dto_nachr TO l_nachr.
      DELETE zfi_bn_nachricht FROM l_nachr.
      COMMIT WORK.

    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.

  ok_code = space.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_FIELDS_9110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_fields_9110 INPUT.
  PERFORM display_fields_0911.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form display_fields_0911
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_fields_0911 .
  DATA: ls_screen     TYPE screen,
        lt_return_tab	TYPE TABLE OF ddshretval,
        ls_return_tab TYPE ddshretval.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = 'ZFI_F_DTO_NACHR'
      fieldname         = 'KZBNART'
    TABLES
      return_tab        = lt_return_tab
    EXCEPTIONS
      field_not_found   = 1
      no_help_for_field = 2
      inconsistent_help = 3
      no_values_found   = 4
      OTHERS            = 5.
  IF sy-subrc = 0.
    READ TABLE lt_return_tab INTO ls_return_tab
         INDEX 1.
    IF sy-subrc EQ 0.
      zfi_f_dto_nachr-kzbnart = ls_return_tab-fieldval.
    ENDIF.

    CASE ls_return_tab-fieldval.
      WHEN 'D' OR 'P'.
        LOOP AT SCREEN INTO ls_screen .
* Feld Empfänger ausblenden
          IF ls_screen-group1 = 'ZA1'.
            ls_screen-input = 0.
            ls_screen-output = 0.
            ls_screen-invisible = 1.
            MODIFY SCREEN FROM ls_screen.
          ENDIF.
        ENDLOOP.
      WHEN OTHERS.
        LOOP AT SCREEN INTO ls_screen .
* Feld Empfänger einblenden
          IF ls_screen-group1 = 'ZA1'.
            ls_screen-input = 1.
            ls_screen-output = 1.
            ls_screen-invisible = 0.
            MODIFY SCREEN FROM ls_screen.
          ENDIF.
        ENDLOOP.
    ENDCASE.
  ENDIF.

ENDFORM.
