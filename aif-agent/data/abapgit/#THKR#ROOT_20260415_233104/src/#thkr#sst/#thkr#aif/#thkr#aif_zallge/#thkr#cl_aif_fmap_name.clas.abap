class /THKR/CL_AIF_FMAP_NAME definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF TY_S_TSAD2,
      TITLE_KEY   TYPE AD_TITLE1,
      TITLE_TEXT  TYPE AD_TITLE1T,
      Length      TYPE i,
     END OF ty_s_tsad2 .
  types:
    TY_T_TSAD2 TYPE STANDARD TABLE OF ty_s_tsad2 .

  methods SET_NAME2
    importing
      !IV_46_NAME2 type STRING
    returning
      value(RV_NAME2) type STRING .
  methods SET_FULLNAME
    importing
      !IV_38_RES type STRING
      !IV_NAME2 type STRING optional
    returning
      value(RV_NAME) type STRING .
  methods MAP_NAME
    importing
      !IV_BU_TYPE type BU_TYPE
      !IV_FULLNAME type STRING
      !IV_TARGET_FIELD type STRING
    returning
      value(RV_NAME) type STRING .
  methods MAP_AD_TITLE1
    importing
      !IV_BU_TYPE type BU_TYPE
      !IV_FULLNAME type STRING
    returning
      value(RV_AD_TITLE1) type STRING .
protected section.
private section.

  methods MAP_PERSON_NAME
    importing
      !IV_FULLNAME type STRING
    returning
      value(RV_NAME) type STRING .
  methods GET_AD_TITLE1
    importing
      !IV_FULLNAME type STRING
    exporting
      !EV_TITLE_TEXT type STRING
    returning
      value(RV_AD_TITLE1) type STRING
    raising
      /THKR/CX_AIF .
  methods MAP_ORG_NAME
    importing
      !IV_TARGET_FIELD type STRING
      !IV_FULLNAME type STRING
    returning
      value(RV_NAME) type STRING .
  methods MAP_PERSON_FIRST_NAME
    importing
      !IV_FULLNAME type STRING
    returning
      value(RV_NAME) type STRING .
  methods DELETE_AD_TITLE1_FROM_NAME .
ENDCLASS.



CLASS /THKR/CL_AIF_FMAP_NAME IMPLEMENTATION.


  method DELETE_AD_TITLE1_FROM_NAME.
  endmethod.


  method GET_AD_TITLE1.
    DATA: lt_title TYPE ty_t_tsad2.

    "Lese akademische Titel aus dem System
    SELECT TITLE_KEY, TITLE_TEXT
      FROM TSAD2
      INTO @DATA(ls_tsad2).
      APPEND INITIAL LINE TO lt_title ASSIGNING FIELD-SYMBOL(<ls_title>).
      MOVE-CORRESPONDING ls_tsad2 to <ls_title>.
      <ls_title>-length = strlen( ls_tsad2-title_text ).
    ENDSELECT.
    IF sy-subrc = 0.
      "akademische Schlüssel nach Länge Sortieren
      "Wenn zum Beispiel ein Prof. Dr. Max Mustermann kommt,
      "dann darf nicht die Suche nach Dr. aufhören (weil Teil des akademischen Titels),
      "sondern muss weitersuchen, bis der vollständige Titel gefunden wurde.
      Sort lt_title by length.
      Loop at lt_title ASSIGNING <ls_title>.
        if iv_fullname cs <ls_title>-title_text.
          rv_ad_title1 = <ls_title>-title_key.
          ev_title_text = <ls_title>-title_text.
        endif.
      ENDLOOP.
    else.
      raise EXCEPTION TYPE /thkr/cx_aif MESSAGE e262(R1).
    endif.
  endmethod.


  METHOD map_ad_title1.

    DATA: lv_len TYPE i.
    DATA: lv_titel TYPE string.
    DATA: no_title TYPE flag VALUE abap_false.

    CASE iv_bu_type.
      WHEN: '1'.
        "Person.
        TRY.
            "akademischen Titel ermitteln
            rv_ad_title1 = get_ad_title1(
              EXPORTING
                iv_fullname   = iv_fullname
            ).
          CATCH /thkr/cx_aif INTO DATA(lx_aif). " AIF Ausnahmeklasse
            CLEAR rv_ad_title1.
        ENDTRY.
      WHEN: '2'.
        "Firma
        CLEAR rv_ad_title1.

    ENDCASE.
  ENDMETHOD.


  METHOD MAP_NAME.

    DATA: lv_len TYPE i.
    DATA: lv_titel TYPE string.
    DATA: no_title TYPE flag VALUE abap_false.

    CASE iv_bu_type.
      WHEN: '1'.
        "Person.
        Try.
        "akademischen Titel ermitteln und aus Name entfernen
        DATA(lv_title_key) = get_ad_title1(
          EXPORTING
            iv_fullname   = iv_fullname
          IMPORTING
            ev_title_text = lv_titel
        ).
        if lv_titel is INITIAL.
          no_title = abap_true.
        endif.
        CATCH /thkr/cx_aif INTO DATA(lx_aif). " AIF Ausnahmeklasse
          no_title = abap_true.
        ENDTRY.
        if no_title = abap_false.
          DATA(lv_fullname) = replace( val = iv_fullname sub = lv_titel with = ``).
        else.
          lv_fullname = iv_fullname.
        ENDIF.
        CASE iv_target_field.
          WHEN: 'BU_NAME3' OR 'BU_NAME4'.
            "BU_NAME3 und BU_NAME4 sind für Organisationen.
            CLEAR: rv_name.
          WHEN: 'BU_NAME1'.
            "Nachname
            rv_name = map_person_name( iv_fullname = lv_fullname ).
          WHEN:  'BU_NAME2'.
            "Vorname
            rv_name = map_person_first_name(
              EXPORTING
                iv_fullname = lv_fullname
            ).
        ENDCASE.
      WHEN: '2'.
        "Firma
        rv_name = map_org_name(
                    iv_target_field = iv_target_field
                    iv_fullname     = iv_fullname
                  ).

    ENDCASE.
  ENDMETHOD.


  method MAP_ORG_NAME.
    DATA: lv_len TYPE i.

    CASE iv_target_field.
        WHEN: 'BU_NAME1' .
          "Ersten 40 Zeichen
          lv_len = strlen( iv_fullname ).
          IF lv_len <= 40.
            rv_name = iv_fullname(lv_len).
          ELSE.
            rv_name = iv_fullname(40).
          ENDIF.
        WHEN: 'BU_NAME2'.
          "Zeichen 40 bis 80
          IF strlen( iv_fullname ) > 40.
            lv_len = strlen( iv_fullname ) - 40 .
            IF lv_len <= 40.
              DATA(lv_offset) = lv_len.
              rv_name = iv_fullname+40(lv_offset).
            ELSE.
              rv_name = iv_fullname+40(40).
            ENDIF.
          ENDIF.
        WHEN: 'BU_NAME3'.
          "Zeichen 80 bis 120.
          IF strlen( iv_fullname ) > 80.
            lv_len = strlen( iv_fullname ) - 80 .
            IF lv_len <= 40.
              lv_offset = lv_len.
              rv_name = iv_fullname+80(lv_offset).
            ELSE.
              rv_name = iv_fullname+80(40).
            ENDIF.
          ENDIF.
        WHEN: 'BU_NAME4'.
          "Zeichen 120 bis 160.
          IF strlen( iv_fullname ) > 120.
            lv_len = strlen( iv_fullname ) - 120 .
            IF lv_len <= 40.
              lv_offset = lv_len.
              rv_name = iv_fullname+120(lv_offset).
            ELSE.
              rv_name = iv_fullname+120(40).
            ENDIF.
          ENDIF.
      ENDCASE.
  endmethod.


  METHOD MAP_PERSON_FIRST_NAME.
    IF iv_fullname CS ','.
      SPLIT iv_fullname AT ',' INTO TABLE DATA(lt_name).
      "Name enthält Komma
      "Vermutlich: Name,  Vorname.
      LOOP AT lt_name ASSIGNING FIELD-SYMBOL(<ls_name>).
        AT FIRST.
          "1. Datensatz = Name.
          "Überspringen.
          CONTINUE.
        ENDAT.
        IF <ls_name> IS NOT INITIAL.
          CONCATENATE rv_name <ls_name> INTO rv_name SEPARATED BY space.
        ENDIF.
      ENDLOOP.
    ELSE.
      SPLIT iv_fullname AT space INTO TABLE lt_name.
      DELETE lt_name WHERE table_line IS INITIAL.
      "Name enthält Leerzeichen
      "Vermutlich: Vorname Nachname.
      LOOP AT lt_name ASSIGNING <ls_name>.
        AT LAST.
          "Letzter Eintrag = Nachname.
          "Überspringen.
          CONTINUE.
        ENDAT.
        IF <ls_name> IS NOT INITIAL.
          CONCATENATE rv_name <ls_name> INTO rv_name SEPARATED BY space.
        ENDIF.
      ENDLOOP.
    ENDIF.
    SHIFT rv_name LEFT DELETING LEADING ''.
  ENDMETHOD.


  METHOD MAP_PERSON_NAME.
    IF iv_fullname CS ','.
      SPLIT iv_fullname AT ',' INTO TABLE DATA(lt_name).
      "Name enthält Komma
      "Vermutlich: Name,  Vorname.
      READ TABLE lt_name INDEX 1 INTO rv_name.
    ELSE.
      SPLIT iv_fullname AT space INTO TABLE lt_name.
      DELETE lt_name WHERE table_line IS INITIAL.
      "Name enthält Leerzeichen
      "Vermutlich: Vorname Nachname.
      LOOP AT lt_name ASSIGNING FIELD-SYMBOL(<ls_name>).
        "Letzter Eintrag ist Nachname
        AT LAST.
          rv_name = <ls_name>.
        ENDAT.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD set_fullname.
    IF iv_name2 IS SUPPLIED.

      "nimm vom Feld 46 nur Zeichen 1 bis 54
      "Ab Zeichen 55 Kennzeichen Anrede und Geburtsdatum.
      IF strlen( iv_name2 ) > 54.
        DATA(lv_name2) = iv_name2(54).
      ELSE.
        lv_name2 = iv_name2.
      ENDIF.

      IF iv_name2 CS iv_38_res.
        "Der Name aus 38_RES4 existiert bereits in 46_NAME2
        rv_name = lv_name2.
      ELSE.
        "Name wird in Feld 38_RES4 und 46_NAME2 geschrieben (wird also in Feld 46_NAME2 fortgesetzt)
        rv_name = iv_38_res && lv_name2.
      ENDIF.
    ELSE.
      "Nur Feld 38_RES wird für den Namen benötigt.
      rv_name = iv_38_res.
    ENDIF.

  ENDMETHOD.


  method SET_NAME2.
    "Nur bis Zeichen 54. Zeichen 55 ist vom Inhalt Geschäftspartnertyp.
    DATA(lv_len) = strlen( iv_46_name2 ).
    IF lv_len < 54.
      rv_name2 = iv_46_name2(lv_len).
    ELSE.
      rv_name2 = iv_46_name2(54).
    ENDIF.
  endmethod.
ENDCLASS.
