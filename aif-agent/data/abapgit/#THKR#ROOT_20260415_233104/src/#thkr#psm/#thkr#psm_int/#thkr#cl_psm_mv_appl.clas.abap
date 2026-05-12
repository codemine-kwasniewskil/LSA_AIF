class /THKR/CL_PSM_MV_APPL definition
  public
  create public .

public section.

  types:
    tty_fmr_interface_det TYPE TABLE OF fmr_interface_det .
  types:
    TTY_KBLK TYPE TABLE OF KBLK .
  types:
    TTY_KBLP TYPE TABLE OF KBLP .

  constants CON_MEMID_BELNR type CHAR14 value 'FMFR_MEM_BELNR' ##NO_TEXT.

  methods CONSTRUCTOR .
  class-methods GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_MV_APPL .
  methods CREATE_PSM_MV
    importing
      !I_DTO_PSM_MV_BEL_CREATE type /THKR/S_DTO_PSM_MV_CREATE
    exporting
      !E_KBLNR type KBLNR_DY
    returning
      value(R_KBLNR) type KBLNR
    raising
      /THKR/CX_PSM_INT_FI .
  methods READ_PSM_MV
    importing
      !I_KBLNR type KBLNR_DY
    exporting
      !E_DTO_PSM_MV_BEL type /THKR/S_DTO_PSM_MV
    returning
      value(R_DTO_PSM_MV_BEL) type /THKR/S_DTO_PSM_MV
    raising
      /THKR/CX_PSM_INT_FI .
  methods UPDATE_PSM_MV_VALUE
    importing
      !I_DTO_PSM_MV_UPDATE_VAL type /THKR/S_DTO_PSM_MV_UPDATE_VAL
    exporting
      !E_RETURN type BAPIRET2_T
    raising
      /THKR/CX_PSM_INT_FI .
  methods CHANGE_PSM_MV
    importing
      !I_DTO_PSM_MV_BEL_CREATE type /THKR/S_DTO_PSM_MV_CREATE
    exporting
      !E_KBLNR type KBLNR_DY
    returning
      value(R_KBLNR) type KBLNR
    raising
      /THKR/CX_PSM_INT_FI .
protected section.

  data MV_KOART type KOART .

  methods CHECK_MV_DATA
    changing
      !C_DTO_PSM_MV_BEL_CREATE type /THKR/S_DTO_PSM_MV_CREATE
      !C_HEAD_DATA type FMR_INTERFACE_HEAD
      !C_POS_DATA type TTY_FMR_INTERFACE_DET
    raising
      /THKR/CX_PSM_INT_FI .
  methods MAP_FI_TO_DTO_PSM
    importing
      !IT_KBLK type TTY_KBLK
      !IT_KBLP type TTY_KBLP
    returning
      value(R_DTO_PSM_MV_BEL) type /THKR/S_DTO_PSM_MV .
  methods MAP_DTO_TO_MV_DATA
    changing
      !C_DTO_PSM_MV_BEL_CREATE type /THKR/S_DTO_PSM_MV_CREATE
      !C_POS_DATA type TTY_FMR_INTERFACE_DET .
  methods MAP_DTO_TO_MV_HEAD
    changing
      !C_DTO_PSM_MV_BEL_CREATE type /THKR/S_DTO_PSM_MV_CREATE
      !C_HEAD_DATA type FMR_INTERFACE_HEAD .
  methods MAP_MV_DATA
    changing
      !C_DTO_PSM_MV_BEL_CREATE type /THKR/S_DTO_PSM_MV_CREATE optional .
  methods MAP_DTO_TO_MV_DATA_CHANGE
    changing
      !C_DTO_PSM_MV_BEL_CREATE type /THKR/S_DTO_PSM_MV_CREATE
      !C_POS_DATA type TTY_FMR_INTERFACE_DET .
  methods MAP_DTO_TO_MV_HEAD_CHANGE
    changing
      !C_DTO_PSM_MV_BEL_CREATE type /THKR/S_DTO_PSM_MV_CREATE
      !C_HEAD_DATA type FMR_INTERFACE_HEADCHANGE .
private section.

  class-data INSTANCE type ref to /THKR/CL_PSM_MV_APPL .
ENDCLASS.



CLASS /THKR/CL_PSM_MV_APPL IMPLEMENTATION.


  METHOD change_psm_mv.

    DATA:
      lt_return TYPE bapiret2_t,
      lt_mesg   TYPE tsmesg.

    DATA:
      ls_head_data TYPE FMR_INTERFACE_HEADCHANGE,
      lt_pos_data  TYPE tty_fmr_interface_det.

    DATA(ls_dto_psm_mv_bel_create) = i_dto_psm_mv_bel_create.

* Daten Mapping
    map_mv_data( CHANGING c_dto_psm_mv_bel_create = ls_dto_psm_mv_bel_create ).

    map_dto_to_mv_head_change( CHANGING c_head_data = ls_head_data c_dto_psm_mv_bel_create = ls_dto_psm_mv_bel_create ).

    map_dto_to_mv_data_change( CHANGING c_pos_data = lt_pos_data c_dto_psm_mv_bel_create = ls_dto_psm_mv_bel_create ).

*    check_mv_data( CHANGING c_head_data = ls_head_data c_pos_data = lt_pos_data c_dto_psm_mv_bel_create = ls_dto_psm_mv_bel_create ).

* Nachrichten Sammelen
    CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXPORTING
        collect_and_send     = ' '
        reset                = 'X'
        i_store_duplicates   = 'X'
        i_no_duplicate_count = 500
*       check_on_commit      = ' '
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Mittelreservierung aufrufen

    CALL FUNCTION 'FMFR_CHANGE_FROM_DATA'
      EXPORTING
        i_flg_checkonly = ' '
        i_f_headdata    = ls_head_data
        i_belnr         = i_dto_psm_mv_bel_create-belnr
*       I_FLG_COMMIT    = 'X'
*       I_FLG_SET_HEADDATA       = ' '
      TABLES
        t_posdata       = lt_pos_data
      EXCEPTIONS
*       error_occured   = 1
*       OTHERS          = 2.
        error_message   = 1. " notwendig, da die Meldungen sonst direkt als Message ausgegeben werden.
    IF sy-subrc = 1.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Nachrichten holen
    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    CALL FUNCTION 'MESSAGES_STOP'
      EXPORTING
        i_reset_messages  = abap_true
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_ao MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_mesg ASSIGNING FIELD-SYMBOL(<fs_msg>).
      APPEND VALUE #( type       = <fs_msg>-msgty id         = <fs_msg>-arbgb number     = <fs_msg>-txtnr message    = <fs_msg>-text
                      message_v1 = <fs_msg>-msgv1 message_v2 = <fs_msg>-msgv2 message_v3 = <fs_msg>-msgv3 message_v4 = <fs_msg>-msgv4 ) TO lt_return.
    ENDLOOP.


    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH lt_return[ 1 ]-message
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.

* Belegnummer lesen
    IMPORT belnr TO e_kblnr FROM MEMORY ID con_memid_belnr.
    r_kblnr = e_kblnr.



  ENDMETHOD.


  method CHECK_MV_DATA.
  endmethod.


  METHOD constructor.
  ENDMETHOD.


  METHOD create_psm_mv.

    DATA:
      lt_return TYPE bapiret2_t,
      lt_mesg   TYPE tsmesg.

    DATA:
      ls_head_data TYPE fmr_interface_head,
      lt_pos_data  TYPE tty_fmr_interface_det.

    DATA(ls_dto_psm_mv_bel_create) = i_dto_psm_mv_bel_create.

* Daten Mapping
    map_mv_data( CHANGING c_dto_psm_mv_bel_create = ls_dto_psm_mv_bel_create ).

    map_dto_to_mv_head( CHANGING c_head_data = ls_head_data c_dto_psm_mv_bel_create = ls_dto_psm_mv_bel_create ).

    map_dto_to_mv_data( CHANGING c_pos_data = lt_pos_data c_dto_psm_mv_bel_create = ls_dto_psm_mv_bel_create ).

    check_mv_data( CHANGING c_head_data = ls_head_data c_pos_data = lt_pos_data c_dto_psm_mv_bel_create = ls_dto_psm_mv_bel_create ).

* Nachrichten Sammelen
    CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXPORTING
        collect_and_send     = ' '
        reset                = 'X'
        i_store_duplicates   = 'X'
        i_no_duplicate_count = 500
*       check_on_commit      = ' '
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Mittelreservierung aufrufen
    CALL FUNCTION 'FMFR_CREATE_FROM_DATA'
      EXPORTING
        i_flg_checkonly = i_dto_psm_mv_bel_create-test_run
        i_flg_commit    = space
      TABLES
        t_posdata       = lt_pos_data
      CHANGING
        c_f_headdata    = ls_head_data
      EXCEPTIONS
*       doctype_not_allowed = 1
*       error_occured   = 2
*       OTHERS          = 3.
        error_message   = 1. " notwendig, da die Meldungen sonst direkt als Message ausgegeben werden.
    IF sy-subrc = 1.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

* Nachrichten holen
    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    CALL FUNCTION 'MESSAGES_STOP'
      EXPORTING
        i_reset_messages  = abap_true
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_ao MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_mesg ASSIGNING FIELD-SYMBOL(<fs_msg>).
      APPEND VALUE #( type       = <fs_msg>-msgty id         = <fs_msg>-arbgb number     = <fs_msg>-txtnr message    = <fs_msg>-text
                      message_v1 = <fs_msg>-msgv1 message_v2 = <fs_msg>-msgv2 message_v3 = <fs_msg>-msgv3 message_v4 = <fs_msg>-msgv4 ) TO lt_return.
    ENDLOOP.


    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH lt_return[ 1 ]-message
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.

* Belegnummer lesen
    IMPORT belnr TO e_kblnr FROM MEMORY ID con_memid_belnr.
    r_kblnr = e_kblnr.



  ENDMETHOD.


  METHOD get_instance.

    IF instance IS INITIAL.
      instance = NEW #( ).
    ENDIF.

    r_instance = instance.

  ENDMETHOD.


  METHOD map_dto_to_mv_data.

    LOOP AT c_dto_psm_mv_bel_create-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).

      APPEND INITIAL LINE TO c_pos_data ASSIGNING FIELD-SYMBOL(<fs_pos_data>).

      IF <fs_kont>-fipex IS NOT INITIAL.
        CALL FUNCTION 'FM_FIPOS_GET_FROM_FIPEX'
          EXPORTING
            i_fipex        = <fs_kont>-fipex
          IMPORTING
            e_fipos        = <fs_pos_data>-fipos
          EXCEPTIONS
            input_error    = 1
            data_not_found = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
          " Dann bleibt die Fipos erst mal wie übergeben
          <fs_pos_data>-fipos = <fs_kont>-fipos.
        ENDIF.
      ELSE.
        <fs_pos_data>-fipos = <fs_kont>-fipos.
      ENDIF.

      <fs_pos_data>-fistl = <fs_kont>-fistl.
      <fs_pos_data>-geber = <fs_kont>-geber.
      <fs_pos_data>-kostl = <fs_kont>-kostl.
      <fs_pos_data>-wrbtr = <fs_kont>-wtorig.
      <fs_pos_data>-ptext = <fs_kont>-sgtxt.
      <fs_pos_data>-saknr = <fs_kont>-hkont.
      <fs_pos_data>-fkber = <fs_kont>-fkber.
      <fs_pos_data>-aufnr = <fs_kont>-aufnr.
      <fs_pos_data>-ps_psp_pnr = <fs_kont>-ps_psp_pnr.
      <fs_pos_data>-consumekz = <fs_kont>-consumekz.
      <fs_pos_data>-pmactive = <fs_kont>-pmactive.
      <fs_pos_data>-fdatk = <fs_kont>-fdatk.

      <fs_pos_data>-lifnr = COND #( WHEN mv_koart = 'K' THEN <fs_kont>-partner ).
      <fs_pos_data>-kunnr = COND #( WHEN mv_koart = 'D' THEN <fs_kont>-partner ).

* Customer Include
      <fs_pos_data>-zz_mwskz = <fs_kont>-zz_mwskz.

      if c_dto_psm_mv_bel_create-blart = 'M1'.
         <fs_pos_data>-belnr = c_dto_psm_mv_bel_create-belnr.
      endif.

    ENDLOOP.



  ENDMETHOD.


  METHOD MAP_DTO_TO_MV_DATA_CHANGE.


    LOOP AT c_dto_psm_mv_bel_create-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).

      APPEND INITIAL LINE TO c_pos_data ASSIGNING FIELD-SYMBOL(<fs_pos_data>).

      IF <fs_kont>-fipex IS NOT INITIAL.
        CALL FUNCTION 'FM_FIPOS_GET_FROM_FIPEX'
          EXPORTING
            i_fipex        = <fs_kont>-fipex
          IMPORTING
            e_fipos        = <fs_pos_data>-fipos
          EXCEPTIONS
            input_error    = 1
            data_not_found = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
          " Dann bleibt die Fipos erst mal wie übergeben
          <fs_pos_data>-fipos = <fs_kont>-fipos.
        ENDIF.
      ELSE.
        <fs_pos_data>-fipos = <fs_kont>-fipos.
      ENDIF.
      <fs_pos_data>-belnr = c_dto_psm_mv_bel_create-belnr.
      <fs_pos_data>-blpos = <fs_kont>-blpos.
      <fs_pos_data>-fistl = <fs_kont>-fistl.
      <fs_pos_data>-geber = <fs_kont>-geber.
      <fs_pos_data>-kostl = <fs_kont>-kostl.
      <fs_pos_data>-wrbtr = <fs_kont>-wtorig.
      <fs_pos_data>-ptext = <fs_kont>-sgtxt.
      <fs_pos_data>-saknr = <fs_kont>-hkont.
      <fs_pos_data>-fkber = <fs_kont>-fkber.
      <fs_pos_data>-aufnr = <fs_kont>-aufnr.
      <fs_pos_data>-ps_psp_pnr = <fs_kont>-ps_psp_pnr.
      <fs_pos_data>-consumekz = <fs_kont>-consumekz.
      <fs_pos_data>-pmactive = <fs_kont>-pmactive.
      <fs_pos_data>-fdatk = <fs_kont>-fdatk.

      <fs_pos_data>-lifnr = COND #( WHEN mv_koart = 'K' THEN <fs_kont>-partner ).
      <fs_pos_data>-kunnr = COND #( WHEN mv_koart = 'D' THEN <fs_kont>-partner ).

* Customer Include
      <fs_pos_data>-zz_mwskz = <fs_kont>-zz_mwskz.

      if c_dto_psm_mv_bel_create-blart = 'M1'.
         <fs_pos_data>-belnr = c_dto_psm_mv_bel_create-belnr.
      endif.

    ENDLOOP.



  ENDMETHOD.


  METHOD map_dto_to_mv_head.

    MOVE-CORRESPONDING c_dto_psm_mv_bel_create TO c_head_data.

    c_head_data-ktext  = c_dto_psm_mv_bel_create-ktxt.

* Buchen oder nur Parken
    c_head_data-park_doc = c_dto_psm_mv_bel_create-park_doc.

  ENDMETHOD.


  METHOD MAP_DTO_TO_MV_HEAD_CHANGE.

    MOVE-CORRESPONDING c_dto_psm_mv_bel_create TO c_head_data.

    c_head_data-ktext  = c_dto_psm_mv_bel_create-ktxt.

* Buchen oder nur Parken
*    c_head_data-park_doc = c_dto_psm_mv_bel_create-park_doc.

  ENDMETHOD.


  METHOD map_fi_to_dto_psm.

    LOOP AT it_kblk INTO DATA(ls_kblk).
      MOVE-CORRESPONDING ls_kblk TO r_dto_psm_mv_bel.
      r_dto_psm_mv_bel-ktxt = ls_kblk-ktext.

      LOOP AT it_kblp INTO DATA(ls_kblp) WHERE belnr = ls_kblk-belnr.

        APPEND INITIAL LINE TO r_dto_psm_mv_bel-t_kont ASSIGNING FIELD-SYMBOL(<fs_pos>).
        MOVE-CORRESPONDING ls_kblp TO <fs_pos>.

        <fs_pos>-partner = COND #( WHEN ls_kblp-lifnr IS NOT INITIAL THEN ls_kblp-lifnr ELSE ls_kblp-kunnr ).
        <fs_pos>-sgtxt = ls_kblp-ptext.
        <fs_pos>-hkont = ls_kblp-saknr.

      ENDLOOP.

      EXIT.
    ENDLOOP.


  ENDMETHOD.


  METHOD map_mv_data.

* Belegtyp Mittelvormerkung
*002  Mittelumbuchung
*020  Mittelsperre
*030  Mittelreservierung
*040  Mittelvorbindung
*050  Mittelbindung           --> Allg. Auszahlungsanordnung oder Festlegung
*060  Veranschlagte Einnahme  --> Allg. Ein. AO
*080  Kreditkartenbeleg

* besondere Kennzeichen pro Belegtyp
    CASE c_dto_psm_mv_bel_create-bltyp.
      WHEN '050'. " Mittelbindung -->  Allg. Ausz. AO
        " Mittelbindung --> Festlegungsbuchungen mit und ohne Verpflichtungsermächtigungen
        mv_koart = 'K'.
        c_dto_psm_mv_bel_create-blart = COND #( WHEN c_dto_psm_mv_bel_create-blart IS INITIAL THEN 'MB' ELSE c_dto_psm_mv_bel_create-blart ).

      WHEN '060'. " Veranschlagte Einnahme --> Allg. Ein. AO
        mv_koart = 'D'.
        c_dto_psm_mv_bel_create-blart = COND #( WHEN c_dto_psm_mv_bel_create-blart IS INITIAL THEN 'AN' ELSE c_dto_psm_mv_bel_create-blart ).

      WHEN OTHERS.
    ENDCASE.


* Vorbelegung Buchungs-/Belegdatum
    IF c_dto_psm_mv_bel_create-budat IS INITIAL.
      c_dto_psm_mv_bel_create-budat = sy-datum.
    ENDIF.
    IF c_dto_psm_mv_bel_create-bldat IS INITIAL.
      c_dto_psm_mv_bel_create-bldat = sy-datum.
    ENDIF.



  ENDMETHOD.


  METHOD read_psm_mv.

    DATA:
      lt_kblk TYPE tty_kblk,
      lt_kblp TYPE tty_kblp.


    CALL FUNCTION 'FMR2_READ_ALL_KBLX'
      EXPORTING
        i_belnr            = i_kblnr
*       I_BLPOS            =
*       I_BLTYP            =
*       REFRESH            = 'X'
*       WITH_KBLE          = 'X'
*       I_BUFFERING        =
* IMPORTING
*       E_KBLK             =
      TABLES
        t_kblk             = lt_kblk
        t_kblp             = lt_kblp
*       T_KBLPS            =
*       T_KBLE             =
*       T_KBLEW            =
      EXCEPTIONS
        not_found          = 1
        position_not_found = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF lt_kblk IS NOT INITIAL.
      e_dto_psm_mv_bel = map_fi_to_dto_psm( it_kblk = lt_kblk it_kblp = lt_kblp ).
    ENDIF.


  ENDMETHOD.


  METHOD update_psm_mv_value.
* Anlegen von Wertanpassungen für Mittelvormerkungen
* Wenn der Parameter I_XMINUS gefüllt ist, wird der Wert reduziert, ist er leer, wird der Wert erhöht.

    DATA:
      lt_mesg   TYPE tsmesg.

* Nachrichten Sammelen
    CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXPORTING
        collect_and_send     = ' '
        reset                = 'X'
        i_store_duplicates   = 'X'
        i_no_duplicate_count = 500
*       check_on_commit      = ' '
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


* Funktion ausführen
    CALL FUNCTION 'FMRS_VA_DIRECT_CREATE'
      EXPORTING
        i_xminus  = i_dto_psm_mv_update_val-xminus
        i_pmbldat = i_dto_psm_mv_update_val-pmbldat
        i_belnr   = i_dto_psm_mv_update_val-belnr
        i_blpos   = i_dto_psm_mv_update_val-blpos
        i_wtsupp  = i_dto_psm_mv_update_val-wtsupp
        i_btext   = i_dto_psm_mv_update_val-btext
        i_testrun = i_dto_psm_mv_update_val-test_run.


* Nachrichten holen
    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    CALL FUNCTION 'MESSAGES_STOP'
      EXPORTING
        i_reset_messages  = abap_true
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_ao MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_mesg ASSIGNING FIELD-SYMBOL(<fs_msg>).
      APPEND VALUE #( type       = <fs_msg>-msgty id         = <fs_msg>-arbgb number     = <fs_msg>-txtnr message    = <fs_msg>-text
                      message_v1 = <fs_msg>-msgv1 message_v2 = <fs_msg>-msgv2 message_v3 = <fs_msg>-msgv3 message_v4 = <fs_msg>-msgv4 ) TO e_return.
    ENDLOOP.

    IF e_return IS NOT INITIAL AND line_exists( e_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH e_return[ 1 ]-message
        EXPORTING bapiret2_tab = e_return.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
