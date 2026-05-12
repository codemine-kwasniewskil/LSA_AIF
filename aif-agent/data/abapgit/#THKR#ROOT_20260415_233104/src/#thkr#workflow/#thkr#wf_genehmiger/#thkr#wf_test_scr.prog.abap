*&---------------------------------------------------------------------*
*& Include          /THKR/WF_TEST_SCR
*&---------------------------------------------------------------------*

PARAMETERS: p_wf   TYPE z_om_dte_wf_id DEFAULT 'AO', "MATCHCODE OBJECT ZOM_WF_TEST_F4HELP,
              p_funk TYPE z_om_dte_funktion.
  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF SCREEN 100 AS SUBSCREEN.
    PARAMETERS: p_doc  TYPE ebeln.

  SELECTION-SCREEN END OF SCREEN 100.

  SELECTION-SCREEN BEGIN OF SCREEN 200 AS SUBSCREEN.

    PARAMETERS: p_attr1  LIKE t77omattrt-attrib,
                p_value1 TYPE om_attrval.
    SELECTION-SCREEN SKIP.

    PARAMETERS: p_attr2  LIKE t77omattrt-attrib,
                p_value2 TYPE om_attrval.
    SELECTION-SCREEN SKIP.

    PARAMETERS: p_attr3  LIKE t77omattrt-attrib,
                p_value3 TYPE om_attrval.
    SELECTION-SCREEN SKIP.

    PARAMETERS: p_attr4  LIKE t77omattrt-attrib,
                p_value4 TYPE om_attrval.
    SELECTION-SCREEN SKIP.

    PARAMETERS: p_attr5  LIKE t77omattrt-attrib,
                p_value5 TYPE om_attrval.
    SELECTION-SCREEN SKIP.

    PARAMETERS: p_attr6  LIKE t77omattrt-attrib,
                p_value6 TYPE om_attrval.
    SELECTION-SCREEN SKIP.

    PARAMETERS: p_attr7  LIKE t77omattrt-attrib,
                p_value7 TYPE om_attrval.

  SELECTION-SCREEN END OF SCREEN 200.

  SELECTION-SCREEN BEGIN OF SCREEN 300 AS SUBSCREEN.
    PARAMETERS: p_id TYPE char10.
  SELECTION-SCREEN END OF SCREEN 300.

  SELECTION-SCREEN BEGIN OF SCREEN 400 AS SUBSCREEN.
    PARAMETERS: p_wi TYPE swwwihead-wi_id.
  SELECTION-SCREEN END OF SCREEN 400.

  SELECTION-SCREEN BEGIN OF SCREEN 500 AS SUBSCREEN.
    PARAMETERS: p_bukrs TYPE recn_contract_x-bukrs,
                p_contr TYPE recn_contract_x-recnnr.
  SELECTION-SCREEN END OF SCREEN 500.
*
  SELECTION-SCREEN: BEGIN OF SCREEN 600 AS SUBSCREEN,
  PUSHBUTTON 1(40) pbut1 USER-COMMAND pbut1,
  SKIP,
  PUSHBUTTON /1(40) pbut2 USER-COMMAND pbut2,
  SKIP,
  PUSHBUTTON /1(40) pbut3 USER-COMMAND pbut3,
  SKIP,
  PUSHBUTTON /1(40) pbut4 USER-COMMAND pbut4.
  SELECTION-SCREEN END OF SCREEN 600.

*  SELECTION-SCREEN: BEGIN OF SCREEN 601 AS SUBSCREEN.
*    PARAMETERS: p_mmbel  TYPE zfi_storno-belnr.
*    PARAMETERS: p_mmgja TYPE zfi_storno-gjahr.
*    SELECTION-SCREEN SKIP.

*    SELECTION-SCREEN: BEGIN OF LINE,
*    PUSHBUTTON 1(10) pback1 USER-COMMAND pback.
*    SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN END OF SCREEN 601.

*  SELECTION-SCREEN: BEGIN OF SCREEN 602 AS SUBSCREEN.
*    PARAMETERS: p_fibel TYPE zfi_storno-belnr,
*                p_fibuk TYPE zfi_storno-bukrs,
*                p_figja TYPE zfi_storno-gjahr.
*    SELECTION-SCREEN SKIP.

*    SELECTION-SCREEN: BEGIN OF LINE,
*    PUSHBUTTON 1(10) pback2 USER-COMMAND pback.
*    SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN END OF SCREEN 602.

*  SELECTION-SCREEN: BEGIN OF SCREEN 603 AS SUBSCREEN.
*    PARAMETERS: p_fobel TYPE zfi_storno-belnr,
*                p_fobuk TYPE zfi_storno-bukrs,
*                p_fogja TYPE zfi_storno-gjahr.
*    SELECTION-SCREEN SKIP.
*
*    SELECTION-SCREEN: BEGIN OF LINE,
*    PUSHBUTTON 1(10) pback3 USER-COMMAND pback.
*    SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN END OF SCREEN 603.

*  SELECTION-SCREEN: BEGIN OF SCREEN 604 AS SUBSCREEN.
*    PARAMETERS: p_sdbel  TYPE zfi_storno-belnr. "VBRK-VBELN
*    SELECTION-SCREEN SKIP.
*
*    SELECTION-SCREEN: BEGIN OF LINE,
*    PUSHBUTTON 1(10) pback4 USER-COMMAND pback.
*    SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN END OF SCREEN 604.

  SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 20 LINES,
  TAB (20) button1 USER-COMMAND push1,
  TAB (20) button2 USER-COMMAND push2,
  TAB (30) button3 USER-COMMAND push3,
  TAB (20) button4 USER-COMMAND push4,
  TAB (20) button5 USER-COMMAND push5,
  TAB (20) button6 USER-COMMAND push6,
  END OF BLOCK mytab.
