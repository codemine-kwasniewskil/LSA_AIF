FUNCTION /thkr/gi_maintain_rec_fld.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_RECORD_ID) TYPE  /THKR/GI_RECORD_ID
*"----------------------------------------------------------------------

  g_record_id = i_record_id.

  SELECT SINGLE * INTO /thkr/c_gi_rec
    FROM /thkr/c_gi_rec
    WHERE record_id = g_record_id.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_rec_fld
    FROM /thkr/c_girecfld
    WHERE record_id = g_record_id.

  CALL SCREEN 0100.


ENDFUNCTION.
