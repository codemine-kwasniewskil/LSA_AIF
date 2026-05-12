*----------------------------------------------------------------------*
***INCLUDE LZLSA_GI_MAINTAIN_REC_FLDI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_0100 INPUT.

  DATA: lt_rec_fld_old TYPE STANDARD TABLE OF /THKR/C_GIRECFLD,
        l_rec_fld_wa   TYPE /THKR/C_GIRECFLD.

  CASE ok_code.
    WHEN 'EXIT' OR 'ABBR'.
      PERFORM end_program.

    WHEN 'SAVE'.
      g_alv->check_changed_data( ).
      IF g_alv->flag_changed IS NOT INITIAL.

        "Alten Stand lesen.
        SELECT * FROM /THKR/C_GIRECFLD INTO TABLE lt_rec_fld_old
          WHERE record_id = g_record_id.

        l_rec_fld_wa-record_id = g_record_id.

        LOOP AT gt_rec_fld INTO DATA(l_rec_fld).
          MOVE-CORRESPONDING l_rec_fld TO l_rec_fld_wa.
          MODIFY /THKR/C_GIRECFLD FROM l_rec_fld_wa.
        ENDLOOP.

        "Gelöschte Sätze prüfen
        LOOP AT lt_rec_fld_old INTO l_rec_fld_wa.

          READ TABLE gt_rec_fld WITH KEY record_fld = l_rec_fld_wa-record_fld TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.

            DELETE FROM /THKR/C_GIRECFLD
            WHERE record_id  = g_record_id
              AND record_fld = l_rec_fld_wa-record_fld.

          ENDIF.
        ENDLOOP.
      ENDIF.
      MESSAGE 'Daten gesichert!' TYPE 'I'.

  ENDCASE.


ENDMODULE.
