*&---------------------------------------------------------------------*
*& Report /THKR/WF_BP_EDIT_GSBER
*&---------------------------------------------------------------------*
*& Mit diesem Report kann der Geschäftsbereich eines Geschäftspartners
*& nachträglich geändert werden.
*& ACHTUNG: ES WERDEN KEINE ÄNDERUNGSBELEGE GESCHRIEBEN!
*& Ersteller: ZHM000000038 - Andreas Baier
*& Datum: 04.04.2025
*&---------------------------------------------------------------------*
REPORT /thkr/wf_bp_edit_gsber.

INCLUDE /thkr/wf_bp_edit_gsber_top.

INITIALIZATION.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
   ID 'TCD' FIELD '/THKR/WF_BP_EDIT_GSB'.
  IF sy-subrc <> 0.
    MESSAGE 'Keine Berechtigung für Transaktion /THKR/WF_BP_EDIT_GSB.' TYPE 'E' DISPLAY LIKE 'S'.
  ENDIF.

AT SELECTION-SCREEN.
  IF pa_bp IS NOT INITIAL.
    CASE sscrfields.

      WHEN 'OLD_GSBER'.
        "Auslesen des alten Geschäftsbereichs
        SELECT SINGLE /thkr/gsber FROM but000
          INTO pa_gsb_o WHERE partner = pa_bp.
        IF sy-subrc <> 0.
          MESSAGE 'Geschäftsbereich konnte nicht ausgelesen werden. Prüfen Sie ihre Eingabe.' TYPE 'S' DISPLAY LIKE 'E'.
        ELSE.
          "Zwischenspeichern des Geschäftsbereich, damit das Feld nur freigegeben wird, wenn der
          "Feldwert mit dem Tabellenwert übereinstimmt
          gv_partner = pa_bp.

        ENDIF.
      WHEN 'NEW_GSBER'.
        IF pa_gsb_o IS NOT INITIAL.
          IF gv_partner = pa_bp.
            CLEAR gs_partner_data.

            SELECT SINGLE partner_GUID FROM but000
              INTO @DATA(lv_guid)
              WHERE partner = @pa_bp.

            gs_partner_data-partner-header-object_instance-bpartner = pa_bp.
            gs_partner_data-partner-header-object_instance-bpartnerguid = lv_guid.
            gs_partner_data-partner-header-object_task = 'U'.

            gs_partner_data-partner-central_data-common-data-/thkr/gsber = pa_gsb_n.
            gs_partner_data-partner-central_data-common-datax-/thkr/gsber = abap_true.

            cl_md_bp_maintain=>validate_single(
            EXPORTING
              i_data = gs_partner_data
              IMPORTING
              et_return_map = DATA(lt_return_map) )
            .
            IF line_exists( lt_return_map[ type = 'E' ] ) OR line_exists( lt_return_map[ type = 'A' ] ).


              LOOP AT lt_return_map ASSIGNING FIELD-SYMBOL(<fs_return_map>)
                WHERE type = 'E' OR type = 'A'.

                MESSAGE <fs_return_map>-message TYPE 'S' DISPLAY LIKE 'E'.
                EXIT.

              ENDLOOP.

            ELSE.
              APPEND gs_partner_data TO gt_partner_data.
              cl_MD_BP_MAINTAIN=>maintain(
               EXPORTING
                i_data     = gt_partner_data
               IMPORTING
                e_return   = DATA(lt_return)
              ).

              IF lt_return IS NOT INITIAL AND line_exists( lt_return[ 1 ]-object_msg[ type = 'E' ] ).

                MESSAGE lt_return[ 1 ]-object_msg[ 1 ]-message TYPE 'S'DISPLAY LIKE 'E'.

              ELSE.

                MESSAGE 'Geschäftsbereich konnte erfolgreich geändert werden.' TYPE 'S'.
                COMMIT WORK.

              ENDIF.

            ENDIF.
          ELSE.
            MESSAGE 'Der aktuelle Geschäftspartner wurde nicht ausgelesen. Bitte Lesen Sie erst die Altdat aus' TYPE 'S' DISPLAY LIKE 'E'.
          ENDIF.

        ELSE.
          MESSAGE 'Bitte lesen Sie erst den alten Geschäftsbereich aus!.' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      WHEN OTHERS.

    ENDCASE.
  ELSE.
    MESSAGE 'Bitte wählen Sie einen Geschäftspartner aus!' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
