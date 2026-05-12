*----------------------------------------------------------------------*
***INCLUDE LZLSA_GI_MAINTAIN_REC_FLDO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo_0100 OUTPUT.
  DATA: l_variant TYPE disvariant,
        l_layout  TYPE lvc_s_layo.

  SET PF-STATUS 'MAIN0100'.
  SET TITLEBAR 'MAIN0100'.

  IF g_container IS INITIAL.

    CREATE OBJECT g_container
      EXPORTING
        container_name = 'CUSTOM_CONTROL_0100'.

    CREATE OBJECT g_alv
      EXPORTING
        i_parent = g_container.

    l_variant-report = '/THKR/GI_MAINTAIN_REC_FLD'.

    g_alv->initialize(
      EXPORTING
        is_variant       = l_variant
        i_editable       = 'X'
        i_allow_new_line = 'X'
        i_allow_del_line = 'X'
      CHANGING
        cs_layout        = l_layout
        ct_data          = gt_rec_fld ).
  ENDIF.



ENDMODULE.
