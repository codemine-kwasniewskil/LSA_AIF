*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Anordnung"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_save_text .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <ls_longtext> TYPE /thkr/s_aif_longtext.
*"----------------------------------------------------------------------
  IF curr_line IS NOT INITIAL.
*"----------------------------------------------------------------------
    APPEND VALUE #( id         = 'KM'
                     number     = 418
                     type       = 'I'
                     message_v1 = '/THKR/AIF_ZALLGE_ACT_SAVE_TEXT' ) TO return_tab.
*"----------------------------------------------------------------------
* Check if Actions are allowed.
    CALL FUNCTION '/THKR/AIF_ZALLGE_ACT_OFF'
      TABLES
        return_tab = return_tab
      EXCEPTIONS
        off        = 1
        OTHERS     = 2.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "Longtext aus Struktur ermitteln
    ASSIGN COMPONENT 'LONG_TEXT' OF STRUCTURE curr_line TO <ls_longtext>.
    IF <ls_longtext> IS ASSIGNED.
      IF <ls_longtext>-lines IS NOT INITIAL.
        "Es gibt Zeilen für Langtexte.
        "Also Speichern.
        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
*           CLIENT          = SY-MANDT
            header          = <ls_longtext>-header
            insert          = 'X'
            savemode_direct = 'X'
*           OWNER_SPECIFIED = ' '
*           LOCAL_CAT       = ' '
*           KEEP_LAST_CHANGED       = ' '
*       IMPORTING
*           FUNCTION        =
*           NEWHEADER       =
          TABLES
            lines           = <ls_longtext>-lines
          EXCEPTIONS
            id              = 1
            language        = 2
            name            = 3
            object          = 4
            OTHERS          = 5.
        IF sy-subrc <> 0.
          success = 'N'.
          IF 1 = 0. MESSAGE e064(/thkr/sst) WITH <ls_longtext>-header-tdname.ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                       number = 064
                       type = 'E'
                       message_v1 = <ls_longtext>-header-tdname ) TO return_tab[].
        ELSE.
          IF 1 = 0. MESSAGE s063(/thkr/sst) WITH <ls_longtext>-header-tdname.ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                                 number = 063
                                 type = 'S'
                                 message_v1 = <ls_longtext>-header-tdname ) TO return_tab[].
          success = 'Y'.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.
*"----------------------------------------------------------------------
