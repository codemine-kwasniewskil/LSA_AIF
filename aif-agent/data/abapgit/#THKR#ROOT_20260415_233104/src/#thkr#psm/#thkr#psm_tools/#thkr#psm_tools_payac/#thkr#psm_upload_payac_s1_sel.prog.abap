*&---------------------------------------------------------------------*
*& Include Z_PSM_UPLOAD_PAYAC_S1_SEL
*&---------------------------------------------------------------------*

* Datenquelle
selection-screen begin of block file with frame title text-srv .
* ---
  parameters: p_server radiobutton group z default 'X'.
* ---
  selection-screen skip 1.
* ---
  parameters: p_local  radiobutton group z.
* ---
  parameters: p_file type localfile obligatory default '<<<Verzeichnis/Datei>>>'.
*
selection-screen end of block file.

* Modus
selection-screen begin of block modu with frame title text-mod .
* ---
  parameters: p_restar as checkbox default space.
* ---
  selection-screen skip 1.
* ---
  parameters: p_test   as checkbox default 'X'.
*
selection-screen end of block modu.
