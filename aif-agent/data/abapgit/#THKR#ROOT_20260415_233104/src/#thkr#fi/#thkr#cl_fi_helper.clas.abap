class /THKR/CL_FI_HELPER definition
  public
  final
  create public .

public section.

  class-methods CHECK_AUTH_STORNO
    importing
      !IV_MODUL type /THKR/DTE_FI_MODUL
    returning
      value(RV_ISALLOWED) type BOOLEAN .
  class-methods CHECK_ZFI_STORNO
    importing
      !IV_PERIOD type RERAPSTNGPERIOD optional
      !IV_MODUL type /THKR/DTE_FI_MODUL
      !IV_BELNR type BELNR_D optional
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR optional
      !IV_RECNNR type RECNNUMBER optional
    exceptions
      BUKRS_FEHLT
      GJAHR_FEHLT
      BELEG_NICHT_IN_TABELLE
      STORNO_LT_STATUS_NOK
      RECNNR_FEHLT
      BELNR_FEHLT
      PERIOD_FEHLT
      REFERENZ_FEHLT
      PERIOD_NOK
      GJAHR_NOK .
  class-methods GET_PARAM
    importing
      !IV_PROGRAMM type PROGRAMM
      !IV_FIELDNAME type FIELDNAME
      !IV_ENTRYKEY type FIELDKEY
    exporting
      !ET_RANGE type ref to DATA
    exceptions
      NO_DATA .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_FI_HELPER IMPLEMENTATION.


  method GET_PARAM.
* Funktion:
* Parameter für Selektion auslesen
*----------------------------------------------------------------------
* Hinweise:
*----------------------------------------------------------------------
*Erstellt:
*09.01.2021 R.Görg TPBR- Parameterliste
*---------------------------------------------------------------------
    DATA:
      lv_obj_sign_descr   TYPE REF TO cl_abap_elemdescr,
      lv_obj_option_descr TYPE REF TO cl_abap_elemdescr,
      lv_obj_value_descr  TYPE REF TO cl_abap_elemdescr.
    DATA: lv_obj_table  TYPE REF TO cl_abap_tabledescr,
          lv_obj_struct TYPE REF TO cl_abap_structdescr.
    DATA: lt_components TYPE cl_abap_structdescr=>component_table.
    FIELD-SYMBOLS: <lv_obj_components> TYPE abap_componentdescr,
<lt_range>          TYPE ANY TABLE.
    IF iv_fieldname IS INITIAL.
      RAISE no_data.
    ELSE.
      DATA(lv_type) = iv_fieldname.
      TRANSLATE lv_type TO UPPER CASE  .
    ENDIF.
    " Rangetabelle mit entsprechendem TYpe aufbauen.
    " Create sign and option elements
    TRY.
        lv_obj_sign_descr   ?= cl_abap_elemdescr=>describe_by_name( 'DDSIGN' ).
        lv_obj_option_descr ?= cl_abap_elemdescr=>describe_by_name( 'DDOPTION' ).
        lv_obj_value_descr  ?= cl_abap_elemdescr=>describe_by_name( lv_type ).

        " Build component table
        APPEND INITIAL LINE TO lt_components ASSIGNING <lv_obj_components>.
        MOVE 'SIGN' TO <lv_obj_components>-name.
        MOVE lv_obj_sign_descr TO <lv_obj_components>-type.

        APPEND INITIAL LINE TO lt_components ASSIGNING <lv_obj_components>.
        MOVE 'BOPTION' TO <lv_obj_components>-name.
        MOVE lv_obj_option_descr TO <lv_obj_components>-type.

        APPEND INITIAL LINE TO lt_components ASSIGNING <lv_obj_components>.
        MOVE 'LOW' TO <lv_obj_components>-name.
        MOVE lv_obj_value_descr TO <lv_obj_components>-type.

        APPEND INITIAL LINE TO lt_components ASSIGNING <lv_obj_components>.
        MOVE 'HIGH' TO <lv_obj_components>-name.
        MOVE lv_obj_value_descr TO <lv_obj_components>-type.

        " Build structure and table
        lv_obj_struct = cl_abap_structdescr=>create( lt_components ).
        lv_obj_table ?= cl_abap_tabledescr=>create( p_line_type = lv_obj_struct ).

        " Create range object

        CREATE DATA Et_range TYPE HANDLE  lv_obj_table.
      CATCH cx_root.
        RAISE no_data.
    ENDTRY.

    " Parameter-Daten lesen
    SELECT sign, boption, low, high FROM /THKR/C_TPBR_PAR  INTO TABLE @DATA(lt_param)
      WHERE programm  = @iv_PROGRAMM
        AND fieldname = @iv_FIELDNAME
        AND entrykey  = @iv_ENTRYKEY.

    ASSIGN et_range->* TO <lt_range>.

*
    LOOP AT lt_param ASSIGNING FIELD-SYMBOL(<ls_param>).
      INSERT INITIAL LINE INTO TABLE <lt_range> ASSIGNING FIELD-SYMBOL(<ls_range>).
      MOVE-CORRESPONDING <ls_param> TO <ls_range>.
    ENDLOOP.

*



*
  ENDMETHOD.


  method CHECK_AUTH_STORNO.

    DATA: lv_objec TYPE swc_elem,
          lv_trans TYPE sytcode.


    " Vorbelegung
    rv_isallowed = abap_false.

    " Ermittlung Objekt für Parametertabelle anhand des Moduls
    CLEAR lv_objec.
    CONCATENATE 'STORNO' iv_modul INTO lv_objec SEPARATED BY '_'.

    " Ermitteln der Einträge aus der Parametertabelle
    SELECT value_von, value_bis INTO TABLE @DATA(lt_trans) FROM /THKR/T_WF_PARAM
                                WHERE object = @lv_objec.
    IF sy-subrc <> 0 OR lt_trans IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_trans ASSIGNING FIELD-SYMBOL(<ls_trans>).

      " Konvertierung Werte
      CLEAR lv_trans.
      lv_trans = <ls_trans>-value_von.

      " Die Transaktion FB08 darf selber nicht beachtet werden
      IF iv_modul = 'FI' AND lv_trans = 'FB08'.
        CONTINUE.
      ENDIF.

      " Prüfung des Transaktionscodes
      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
        EXPORTING
          tcode  = lv_trans
        EXCEPTIONS
          ok     = 1
          not_ok = 2
          OTHERS = 3.
      IF sy-subrc = 1.
        " Stornierung ohne WF erlaubt
        rv_isallowed = abap_true.
        EXIT.
      ENDIF.

    ENDLOOP.

  endmethod.


  method CHECK_ZFI_STORNO.
* Funktion:
* Prüfung des Beleges in der Tabelle ZFI_STORNO
*----------------------------------------------------------------------
* Hinweise:
* Folgende Module sind im Moment in der Tabelle ZFI_STORNO vorhanden:
* FI => FI-Belege und Föbis
* MM => Eingangsrechnungen
* SD => Fakturen
* RE => REFX
*----------------------------------------------------------------------
* Erstellt:
* 30.12.2022 REPRO-GANZ (T.Ganzer)
*---------------------------------------------------------------------
    DATA lt_storno TYPE TABLE OF /THKR/stornoC.
    " Buchungskreis erforderlich
    IF iv_bukrs IS INITIAL.
      RAISE bukrs_fehlt.
    ENDIF.

    " Geschäftsjahr nur bei FI Belegen erforderlich
    IF iv_gjahr IS INITIAL AND iv_modul = 'FI'.
      RAISE gjahr_fehlt.
    ENDIF.

    " Prüfung der Beleg-/Vertragsnummer
*    IF iv_modul = 'RE' AND iv_recnnr IS INITIAL.
*      RAISE recnnr_fehlt.
*    ELSEIF iv_modul = 'RE' AND it_refnr[] IS INITIAL.
*      RAISE referenz_fehlt.
*    ELSEIF iv_modul = 'RE' AND iv_period IS INITIAL.
*      RAISE period_fehlt.
    IF iv_modul <> 'RE' AND iv_belnr IS INITIAL.
      RAISE belnr_fehlt.
    ENDIF.

    " Selektion der relevanten Einträge aus der TAbelle ZFI_STORNO
*    IF iv_modul = 'RE'.
*      " Selektion REFX Belege
*      SELECT bukrs, modul, belnr, gjahr, recnnr, monat, status INTO
*                         CORRESPONDING FIELDS OF TABLE @lt_storno
*                                                        FROM /THKR/stornoc
*                                                        WHERE bukrs = @iv_bukrs
*                                                          AND modul = @iv_modul
*                                                          AND recnnr = @iv_recnnr.
*    ELSE.
      IF iv_gjahr IS NOT INITIAL AND iv_bukrs IS NOT INITIAL.
        " Selektion FI Belege und eventuell MM Belege
        SELECT bukrs, modul, belnr, gjahr, status INTO
                          CORRESPONDING FIELDS OF TABLE @lt_storno
                                                  FROM /THKR/stornoc
                                                  WHERE bukrs = @iv_bukrs
                                                    AND modul = @iv_modul
                                                    AND belnr = @iv_belnr
                                                    AND gjahr = @iv_gjahr.
      ELSE.
        " Selektion SD Belege
        SELECT bukrs, modul, belnr, gjahr, status INTO
                         CORRESPONDING FIELDS OF TABLE @lt_storno
                                                  FROM /THKR/stornoc
                                                  WHERE bukrs = @iv_bukrs
                                                    AND modul = @iv_modul
                                                    AND belnr = @iv_belnr.
      ENDIF.
*    ENDIF.
    IF sy-subrc <> 0.
      " Kein Storno erlaubt
      RAISE beleg_nicht_in_tabelle.
    ENDIF.
*
*    IF iv_modul = 'RE'.
*      " Prüfung der Belegreferenzen
*      SELECT refnr INTO TABLE @DATA(lt_refnr) FROM zfi_refx_refnr
*                                              FOR ALL ENTRIES IN @it_refnr
*                                              WHERE recnnr = @iv_recnnr
*                                                AND bukrs = @iv_bukrs
*                                                AND refnr = @it_refnr-refnr.
*      IF sy-subrc <> 0.
*        " Kein Storno erlaubt
*        RAISE beleg_nicht_in_tabelle.
*      ELSE.
*        LOOP AT it_refnr ASSIGNING FIELD-SYMBOL(<ls_refnr>).
*          " Beleg vorhanden?
*          READ TABLE lt_refnr TRANSPORTING NO FIELDS WITH KEY refnr = <ls_refnr>-refnr.
*          IF sy-subrc <> 0.
*            " Kein Storno erlaubt
*            RAISE beleg_nicht_in_tabelle.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.

    " Prüfung ob der Status stornorelvant ist
    READ TABLE lt_storno ASSIGNING FIELD-SYMBOL(<ls_storno>) WITH KEY status = '50'.  "genehmigt
    IF sy-subrc <> 0.
      " Kein Storno erlaubt
      RAISE storno_lt_status_nok.
    ELSEIF iv_modul = 'RE'.
      " Prüfung Buchungsperiode
      IF iv_period <> <ls_storno>-monat.
        RAISE period_nok.
      ENDIF.
      " Prüfung Geschäftsjahr
      IF iv_gjahr <> <ls_storno>-gjahr.
        RAISE gjahr_nok.
      ENDIF.
    ENDIF.

  endmethod.
ENDCLASS.
