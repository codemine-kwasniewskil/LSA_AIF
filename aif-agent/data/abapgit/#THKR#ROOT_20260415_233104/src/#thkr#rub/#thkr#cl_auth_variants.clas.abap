class /THKR/CL_AUTH_VARIANTS definition
  public
  final
  create public .

public section.

  class-data ALV_AUTH type FLAG .
  class-data ALV_EXISTS type FLAG .

  class-methods REP_AUTH_CHECK
    importing
      !IV_VARIANT type CHAR30
      !IV_AKTVT type CHAR1
    exceptions
      NOT_AUTHORIZED .
  class-methods ALV_AUTH_CHECK
    importing
      !IV_VARIANT type SLIS_VARI
      !IV_AKTVT type CHAR1
      !IV_DEFAULT type FLAG optional
    exceptions
      NOT_AUTHORIZED .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_AUTH_VARIANTS IMPLEMENTATION.


  METHOD alv_auth_check.
    " Variante kann nicht leer sein!
    " Wenn kein globales, überlasse Prüfung dem Standard
    CHECK iv_variant(1) EQ '/'.

    " Prüfung
    DATA(lv_aktvt) = SWITCH activ_auth( iv_aktvt WHEN 'N' THEN COND #( WHEN iv_default IS INITIAL THEN '01' ELSE '70' )
                                                 WHEN 'C' THEN '02'
                                                 WHEN 'D' THEN '06'
                                                 WHEN 'S' THEN '70'
                                                          ELSE '70' ).

    AUTHORITY-CHECK OBJECT 'Z_ALV_VARI'
     ID 'Z_ALV_VARI' FIELD iv_variant+1
     ID 'ACTVT' FIELD lv_aktvt.
    IF sy-subrc <> 0.
      CASE iv_aktvt.
        WHEN 'N'.
          IF iv_default IS INITIAL.
            " Keine Berechtigung zum Anlegen von &1. Bitte Namensraum beachten!
            MESSAGE i105(/thkr/rub_messg) WITH iv_variant RAISING not_authorized.
          ELSE.
            " Keine Berechtigung zum Anlegen einer Variante mit Voreinstellung
            MESSAGE i102(/thkr/rub_messg) RAISING not_authorized.
          ENDIF.
        WHEN 'C'.
          " Keine Berechtigung zum Ändern von &1. Bitte Namensraum beachten!
          MESSAGE i106(/thkr/rub_messg) WITH iv_variant RAISING not_authorized.
        WHEN 'D'.
          " Keine Berechtigung zum Löschen von &1. Bitte Namensraum beachten!
          MESSAGE i107(/thkr/rub_messg) WITH iv_variant RAISING not_authorized.
        WHEN 'S'.
          " Keine Berechtigung die Voreinstellung zu verändern
          MESSAGE i101(/thkr/rub_messg) RAISING not_authorized.
        WHEN OTHERS.
          " Keine Berechtigung für &1. Bitte Namensraum beachten!
          MESSAGE i100(/thkr/rub_messg) WITH iv_variant RAISING not_authorized.
      ENDCASE.
    ENDIF.
  ENDMETHOD.


  METHOD rep_auth_check.
    IF iv_variant IS INITIAL.
      MESSAGE i109(/thkr/rub_messg) RAISING not_authorized.
    ENDIF.

    DATA(lv_aktvt) = SWITCH activ_auth( iv_aktvt WHEN 'N' THEN '01' WHEN 'C' THEN '02' WHEN 'D' THEN '06' ELSE '70' ).
    AUTHORITY-CHECK OBJECT 'Z_REP_VARI'
     ID 'Z_REP_VARI' FIELD iv_variant
     ID 'ACTVT' FIELD lv_aktvt.
    IF sy-subrc <> 0.
      CASE iv_aktvt.
        WHEN 'N'.
          MESSAGE i105(/thkr/rub_messg) WITH iv_variant RAISING not_authorized.
        WHEN 'C'.
          MESSAGE i106(/thkr/rub_messg) WITH iv_variant RAISING not_authorized.
        WHEN 'D'.
          MESSAGE i107(/thkr/rub_messg) WITH iv_variant RAISING not_authorized.
        WHEN 'S'.
          MESSAGE i101(/thkr/rub_messg) RAISING not_authorized.
        WHEN OTHERS.
          MESSAGE i100(/thkr/rub_messg) WITH iv_variant RAISING not_authorized.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
