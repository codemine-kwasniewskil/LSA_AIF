*&---------------------------------------------------------------------*
*& Report /THKR/FI_ELKO_PIPRE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/fi_elko_sgtxt LINE-SIZE 80.

************************************************************************
* ELKO: Hilfprogramm zum Aktualisierung des Belegtextes DZ/KZ im Ziel
************************************************************************
* Beschreibung:
*
* Das Programm überträgt bei fehlerhaften Belegtexten im Ziel-Bukrs
* den Belegtext aus Position 1 des T999-Beleges in die Position 1
* (Deb- oder Kred-Pos) des empfangenden Buchungskreises
*
* 2026-02-19 js Einschränkung KOART auf [D,K], kein Update auf [S]
*
************************************************************************
* Autor: Jörg Seifert
* Firma: BTC
************************************************************************

TABLES:
  bkpf, bseg.

SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
  p_qbukrs LIKE bkpf-bukrs DEFAULT 'T999'.
  SELECT-OPTIONS:
  s_qbelnr FOR bkpf-belnr,
  s_qgjahr FOR bkpf-gjahr,
  s_qblart FOR bkpf-blart,
  s_qcpudt FOR bkpf-cpudt,
  s_qbldat FOR bkpf-bldat,
  s_qbudat FOR bkpf-budat,
  s_qxblnr FOR bkpf-xblnr.
SELECTION-SCREEN END OF BLOCK 1.

SELECTION-SCREEN BEGIN OF BLOCK 2 WITH FRAME TITLE TEXT-002.
  PARAMETERS:
    p_kukey TYPE char8,
    p_test  TYPE flag DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK 2.


INITIALIZATION.
  APPEND VALUE #( sign = 'I' option = 'BT' low = 'DZ' high = 'KZ' ) TO s_qblart[].


START-OF-SELECTION.

  DATA: l_bktxt   TYPE char9,
        l_anzahl  TYPE i,
        lt_accchg TYPE table_type_accchg.

  IF p_kukey IS INITIAL.
    l_bktxt = '000%'.
  ELSE.
    CONDENSE  p_kukey.
    WHILE  strlen( p_kukey ) < 8  .
      SHIFT p_kukey RIGHT.
    ENDWHILE.
    TRANSLATE p_kukey USING ' 0'.
    CONCATENATE p_kukey '%' INTO l_bktxt.
  ENDIF.


  SELECT qk~bktxt , qk~xblnr ,
         qs~bukrs  AS qbukrs, qs~belnr  AS qbelnr, qs~gjahr  AS qgjahr, qs~buzei  AS qbuzei,
         qs~sgtxt  AS qsgtxt, "der korrekte Belegtext in der Quelle (T999)
         zk~bvorg ,
         zs~bukrs , zs~belnr , zs~gjahr , zs~buzei ,
         zs~sgtxt             "der falsche Belegtext im Ziel
  FROM ( bseg  AS qs                "Quell-Segment (T999)
         INNER JOIN bkpf  AS qk     "Quell-Kopf (T999)
         ON  qk~belnr = qs~belnr
         AND qk~bukrs = qs~bukrs
         AND qk~gjahr = qs~gjahr
         INNER JOIN bkpf  AS zk     "Ziel-Kopf (<> T999)
         ON  zk~bvorg = qk~bvorg
         INNER JOIN bseg  AS zs     "Ziel-Segment (<> T999)
         ON  zs~belnr = zk~belnr
         AND zs~bukrs = zk~bukrs
         AND zs~gjahr = zk~gjahr )
       WHERE qs~buzei = 1           "Quelle ist die Zeile 1 des T999-Beleges
         AND qk~bukrs = @p_qbukrs   "Quelle ist der T999-Beleg
         AND qk~belnr IN @s_qbelnr
         AND qk~gjahr IN @s_qgjahr
         AND qk~blart IN @s_qblart
         AND qk~cpudt IN @s_qcpudt
         AND qk~bldat IN @s_qbldat
         AND qk~budat IN @s_qbudat
         AND qk~bvorg IS NOT INITIAL
         AND qk~xblnr IN @s_qxblnr
         AND qk~bktxt LIKE @l_bktxt "Selektion über KuKey für Testzwecke
         AND zk~bukrs <> 'T999'     "Ziel ist der empfangende Buchungskreis
         AND zs~buzei = 1           "Ziel ist Zeile 1 des empf. Beleges
         AND ( zs~koart = 'D' OR zs~koart = 'K' ) "2026-02-19 Deb. o. Kred.
         AND qs~sgtxt <> zs~sgtxt   " nur wo unterschiedliche Texte
  ORDER BY qk~bktxt ASCENDING
  INTO TABLE @DATA(lt_bsid).

  IF lt_bsid IS INITIAL.
    WRITE:  TEXT-003 , sy-subrc.
  ELSE.

    IF p_test IS INITIAL.   "Echtlauf

      LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>).

        REFRESH lt_accchg.
        APPEND VALUE #(
                       fdname = 'SGTXT'
                       oldval = <fs_bsid>-sgtxt   "falscher Text
                       newval = <fs_bsid>-qsgtxt  "Text aus T999
                      ) TO lt_accchg.

        CALL FUNCTION 'FI_DOCUMENT_CHANGE'
          EXPORTING
            x_lock               = 'X'
            i_bukrs              = <fs_bsid>-bukrs
            i_belnr              = <fs_bsid>-belnr
            i_gjahr              = <fs_bsid>-gjahr
            i_buzei              = <fs_bsid>-buzei
          TABLES
            t_accchg             = lt_accchg
          EXCEPTIONS
            no_reference         = 1
            no_document          = 2
            many_documents       = 3
            wrong_input          = 4
            overwrite_creditcard = 5
            OTHERS               = 6.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_msg).
          CONCATENATE 'ERR:' lv_msg INTO <fs_bsid>-qsgtxt.
          CONCATENATE 'ERR:' lv_msg INTO <fs_bsid>-sgtxt.
        ELSE.
          l_anzahl = l_anzahl + 1.
        ENDIF.

        IF l_anzahl MOD 1000 = 0. " Zwischen-Commit nach 1000 Belegen
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDLOOP.

      WRITE: / TEXT-004, l_anzahl.

      COMMIT WORK AND WAIT.


    ENDIF.

* Ausgabe
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                                CHANGING  t_table      = lt_bsid ).

        SET PARAMETER ID 'EXCEL_INPLACE' FIELD space.
        lo_salv->get_functions( )->set_all( abap_true ).
        lo_salv->get_columns( )->set_optimize( abap_true ).
        lo_salv->get_columns( )->get_column( 'QSGTXT' )->set_short_text( 'Korrekt' ).
        lo_salv->get_columns( )->get_column( 'QSGTXT' )->set_long_text( 'Korrekter Text' ).
        lo_salv->get_columns( )->get_column( 'QSGTXT' )->set_medium_text( 'Korrekter Text' ).
        lo_salv->get_columns( )->get_column( 'SGTXT' )->set_short_text( 'Falsch' ).
        lo_salv->get_columns( )->get_column( 'SGTXT' )->set_long_text( 'Falscher Text' ).
        lo_salv->get_columns( )->get_column( 'SGTXT' )->set_medium_text( 'Falscher Text' ).

        lo_salv->display( ).

      CATCH cx_root INTO DATA(lx_txt).
        WRITE: / lx_txt->get_text( ).
    ENDTRY.


  ENDIF.



*&---------------------------------------------------------------------*
