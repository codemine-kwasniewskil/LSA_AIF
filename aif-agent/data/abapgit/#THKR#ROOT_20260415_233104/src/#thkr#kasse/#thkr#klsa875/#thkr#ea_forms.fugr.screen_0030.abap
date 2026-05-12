PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_/thkr/ea_fo_abs CURSOR nextline.
    MODULE liste_show_liste.
    MODULE /thkr/edit_form_abs_pbo.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE /thkr/edit_form_abs_text.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD /thkr/ea_fo_abs-abskey .
      FIELD /thkr/ea_fo_abs-ktext .
      FIELD /thkr/ea_fo_abs-iban .
      FIELD /thkr/ea_fo_abs-bic .
      FIELD /thkr/ea_fo_abs-ename .
      FIELD /thkr/ea_fo_abs-txnam_ort .
      FIELD /thkr/ea_fo_abs-txnam_kop .
      FIELD /thkr/ea_fo_abs-txnam_adr .
      FIELD /thkr/ea_fo_abs-txnam_rue .
      FIELD /thkr/ea_fo_abs-txnam_fus .
      FIELD /thkr/ea_fo_abs-tdid .
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD /thkr/ea_fo_abs-abskey .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
