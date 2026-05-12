PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_/thkr/ea_fo_tb CURSOR nextline.
    MODULE liste_show_liste.
    MODULE /thkr/edit_fo_tb_text_pbo.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  MODULE /thkr/edit_fo_tb_text.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD /thkr/ea_fo_tb-formid .
      FIELD /thkr/ea_fo_tb-variant .
      FIELD /thkr/ea_fo_tb-objectid .
      FIELD /thkr/ea_fo_tb-ktext .
      FIELD /thkr/ea_fo_tb-tdname .
      FIELD /thkr/ea_fo_tb-tdid .
      FIELD /thkr/ea_fo_tb-tdspras .
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD /thkr/ea_fo_tb-formid .
      FIELD /thkr/ea_fo_tb-variant .
      FIELD /thkr/ea_fo_tb-objectid .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
