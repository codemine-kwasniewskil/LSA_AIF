FUNCTION-POOL /thkr/gi_maintain_rec_fld.     "MESSAGE-ID ..

TABLES: /thkr/c_gi_rec.

* INCLUDE LZLSA_GI_MAINTAIN_REC_FLDD...      " Local class definition

DATA: gt_rec_fld  TYPE /thkr/t_gi_rec_fld,
      g_record_id TYPE /thkr/gi_record_id,
      g_alv       TYPE REF TO /thkr/cl_gi_alv_rec_fld,
      g_container TYPE REF TO cl_gui_custom_container,

      ok_code     LIKE sy-ucomm.
