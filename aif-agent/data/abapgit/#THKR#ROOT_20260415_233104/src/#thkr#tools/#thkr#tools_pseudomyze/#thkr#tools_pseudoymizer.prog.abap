*&---------------------------------------------------------------------*
*& Report /THKR/TOOLS_PSEUDOYMIZER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/tools_pseudoymizer.

SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN : BEGIN OF LINE.
    PARAMETERS: p_but  RADIOBUTTON GROUP rbg DEFAULT 'X' USER-COMMAND flag.
    SELECTION-SCREEN COMMENT 03(10) TEXT-s11.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: p_addr  RADIOBUTTON GROUP rbg.
    SELECTION-SCREEN COMMENT 17(10) TEXT-s12.
*    SELECTION-SCREEN POSITION 30.
*    PARAMETERS: p_ce  RADIOBUTTON GROUP rbg.
*    SELECTION-SCREEN COMMENT 32(12) TEXT-s13.
  SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK d1.

SELECTION-SCREEN BEGIN OF BLOCK d2 WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_chunk TYPE num6 DEFAULT 30000.
  PARAMETERS: p_test TYPE flag DEFAULT abap_true.
  SELECTION-SCREEN COMMENT /1(79) TEXT-002.
SELECTION-SCREEN END OF BLOCK d2.

CASE abap_true.
  WHEN p_but.
    DATA(pseudo_bp) = NEW /thkr/cl_pseudo_process_bp( ).
    DATA(results) = pseudo_bp->process( i_testmode = p_test i_chunksize = p_chunk ).
  WHEN p_addr.
    DATA(pseudo_add) = NEW /thkr/cl_pseudo_process_addr( ).
    results = pseudo_add->process( i_testmode = p_test i_chunksize = p_chunk ).
ENDCASE.

cl_salv_table=>factory( IMPORTING r_salv_table = DATA(alv)
                        CHANGING  t_table      = results ).

alv->display( ).
