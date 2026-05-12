*&---------------------------------------------------------------------*
*& Include          /THKR/QS_AIF_ALV_PAI_0200
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:    Frank Brähler (Orexes GmbH) (ZHM000000307)                *
*& Erstellt am: 12.05.2025                                             *
*&                                                                     *
*& l. Änderer : Frank Brähler (ZHM000000307)                           *
*& l. Datum   : 12.05.2025                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& PAI - Dynpro 0200 - Inlcude für /THKR/QS_AIF_T_FMAP                 *
*&                                                                     *
*& PAI für Dynpro 0200                                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Änderungshistorie:                                                  *
*& Datum    Änderer      Beschreibung                                  *
*& -------- ------------ --------------------------------------------- *
*& 20250506 ZHM000000307 Anlage des Reports                            *
*&                                                                     *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       Benutzeraktionen DYNPRO 0200
*----------------------------------------------------------------------*

MODULE user_command_0200 INPUT.
  CASE ref_alv_0200->ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      CLEAR gt_alv_t_fmap_sst[].
      ref_alv_0200->update_grid( ).
      LEAVE TO SCREEN 0.
  ENDCASE.
  CLEAR ref_alv_0200->ok_code.
ENDMODULE.
