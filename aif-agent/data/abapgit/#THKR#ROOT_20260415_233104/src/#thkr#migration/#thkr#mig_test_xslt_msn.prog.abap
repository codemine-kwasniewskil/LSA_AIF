*&---------------------------------------------------------------------*
*& Report /THKR/MIG_TEST_XSLT_MSN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_test_xslt_msn.

TYPES lty_result TYPE x LENGTH 1024.

DATA: lt_result    TYPE STANDARD TABLE OF lty_result,
      l_file       TYPE /thkr/file_w_path,
      l_cstring    TYPE string,
      Lt_msn       type /thkr/t_mig_fipo_msn,
      l_xml_string TYPE xstring.

*Struktur staging tabellen
*data: lt_staging type /1LT/DSEH1000598. "EH1 "/1lt/dskh1000028.
* für Fuba 'Z_FM_COM_ITEM_MIGRATION'
*IS_CMMT_ITEM_DATA  TYPE  IFMCIDAT                        Struktur der Finanzposition Stammdaten
*IS_CMMT_ITEM_TEXT  TYPE  FMCMMT_ITEM_TEXT                        Texte für Finanzstellen (inkl. Sprache)
*IS_CMMT_ITEM_HIER  TYPE  FMCMMT_ITEM_HIER*
data: lt_CMMT_ITEM_DATA TYPE  IFMCIDAT ,
      lt_CMMT_ITEM_TEXT  TYPE  FMCMMT_ITEM_TEXT,
      CMMT_ITEM_HIER  TYPE  FMCMMT_ITEM_HIER.

l_file = 'C:\XML\msn.xml'.

cl_gui_frontend_services=>gui_upload(
  EXPORTING
    filename = CONV #( l_file )
    filetype = 'BIN'
  CHANGING
    data_tab = lt_result ).

LOOP AT lt_result INTO DATA(l_result).
  CONCATENATE l_xml_string l_result INTO l_xml_string IN BYTE MODE.
ENDLOOP.

TRY.


    CALL TRANSFORMATION /thkr/msn_to_abap
      SOURCE XML l_xml_string
      RESULT table = lt_msn.


  CATCH cx_root INTO DATA(l_oerror).
    /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

ENDTRY.
loop at lt_msn into data(l_msn).
* Quelle: Lt_msn       type /thkr/t_mig_fipo_msn,
*  HAUSHALTSJAHR  Type    CHAR  20  0 0 Haushaltsjahr des Unterkontos
*EINZELPLAN Type    CHAR  3 0 0 Dem Titel übergeordneter Einzelplan (siehe AOB)
*KAPITEL  Type    CHAR  12  0 0 Dem Titel übergeordneter Kapitel (siehe KAP)
*TITEL  Type    CHAR  6 0 0 Dem Titel übergeordneter Titel (siehe TIT)
*SCHLUESSEL Type    CHAR  6 0 0 Vom Nutzer festgelegter Schlüssel des Titel
*BEZEICHNUNG  Type    CHAR  60  0 0 Bezeichnung des Unterkontos
*STATUS Type    CHAR  1 0 0 Status des Unterkontos (1=aktiv, 2=inaktiv)
*SPERRE Type    CHAR  1 0 0 Sperrkennzeichen: (j oder n)
*SPERREVON  Type    CHAR  8 0 0 Datum Sperre von im Format JJJJMMTT
*SPERREBIS  Type    CHAR  8 0 0 Datum Sperre bis im Format JJJJMMTT
*KENNZEICHENLIMIT Type    CHAR  1 0 0 Kennzeichen für limitiertes Unterkonto (j oder n)
**ziel
*I_FM_AREA  TYPE  FIKRS                       Finanzkreis
*I_CMMT_ITEM  TYPE  FM_FIPEX                        Finanzposition
*I_FISC_YEAR  TYPE  GJAHR                       Geschäftsjahr
*IS_CMMT_ITEM_DATA  TYPE  IFMCIDAT                        Struktur der Finanzposition Stammdaten
*IS_CMMT_ITEM_TEXT  TYPE  FMCMMT_ITEM_TEXT                        Texte für Finanzstellen (inkl. Sprache)
*IS_CMMT_ITEM_HIER  TYPE  FMCMMT_ITEM_HIER                        Variantenzuordnung Finanzpositionshierarchie
*I_FLG_TEST TYPE  XFELD 'X' Feld zum Ankreuzen
*I_FLG_COMMIT TYPE  XFELD 'X' Feld zum Ankreuzen
*I_LONGTEXT TYPE  STRINGVAL                       Longetxt


*CALL FUNCTION 'Z_FM_COM_ITEM_MIGRATION'
*  EXPORTING
*    i_fm_area               =
*    i_cmmt_item             =
*    i_fisc_year             =
*    is_cmmt_item_data       =
*    is_cmmt_item_text       =
*    is_cmmt_item_hier       =
**   I_FLG_TEST              = 'X'
**   I_FLG_COMMIT            = 'X'
*    i_longtext              =
** IMPORTING
**   ET_MESSAGES             =
*          .





endloop.




CLEAR lt_msn.
