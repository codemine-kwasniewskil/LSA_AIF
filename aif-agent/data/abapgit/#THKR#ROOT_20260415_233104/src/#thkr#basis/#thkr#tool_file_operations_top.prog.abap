*&---------------------------------------------------------------------*
*& Include /THKR/TOOL_FILE_MOVE_TOP                 - Report /THKR/TOOL_FILE_MOVE
*&---------------------------------------------------------------------*
REPORT /thkr/tool_file_move.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
  PARAMETERS: p_path_s TYPE eps2filnam DEFAULT '/usr/sap/data/',
              p_mask   TYPE epsfilnam  DEFAULT '*'.

  PARAMETERS: rbs1 RADIOBUTTON GROUP grps DEFAULT 'X' USER-COMMAND radiogrps, " Default selection
              rbs2 RADIOBUTTON GROUP grps.

  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
    PARAMETERS: p_path_d TYPE eps2filnam DEFAULT '/usr/sap/data/' MODIF ID grm.
    PARAMETERS: rbm1 RADIOBUTTON GROUP grpm DEFAULT 'X' USER-COMMAND radiogrpm MODIF ID grm, " Default selection
                rbm2 RADIOBUTTON GROUP grpm MODIF ID grm,
                rbm3 RADIOBUTTON GROUP grpm MODIF ID grm.
  SELECTION-SCREEN END OF BLOCK bl2.

  SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-f03.
    PARAMETERS: p_path_z TYPE /thkr/dt_zip_filname DEFAULT '/usr/sap/data/' MODIF ID grz.
    PARAMETERS: "rbz1 RADIOBUTTON GROUP grpz DEFAULT 'X' USER-COMMAND radiogrpz MODIF ID grz, " Default selection
      rbz2 RADIOBUTTON GROUP grpz DEFAULT 'X' USER-COMMAND radiogrpz MODIF ID grz.
    "SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: rbz3 RADIOBUTTON GROUP grpz MODIF ID grz.
    "  SELECTION-SCREEN COMMENT (40) TEXT-rz3 FOR FIELD rbz3 MODIF ID grz.
    "SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN END OF BLOCK bl3.
SELECTION-SCREEN END OF BLOCK bl1.
