class /THKR/CL_PSM_TG_APPL definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    importing
      !TITELGRP type /THKR/S_PSM_TG_KEY
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_TG_APPL .
  methods CREATE_TG
    importing
      !IS_DATA type /THKR/S_PSM_TG_DATA
    returning
      value(R_TG) type /THKR/S_PSM_TG_KEY .
  methods GET_TG_DATA
    returning
      value(R_TG_DATA) type /THKR/S_PSM_TG .
protected section.
private section.

  data M_FIKRS type FIKRS .
  data M_GJAHR type GJAHR .
  data M_FKBER type FKBER .
  data M_TITELGRP type /THKR/TG .

  methods CONSTRUCTOR
    importing
      !FIKRS type FIKRS
      !GJAHR type GJAHR
      !FKBER type FKBER
      !TITELGRP type /THKR/TG .
ENDCLASS.



CLASS /THKR/CL_PSM_TG_APPL IMPLEMENTATION.


  METHOD constructor.
    m_fikrs = fikrs.
    m_gjahr = gjahr.
    m_fkber = fkber.
    m_titelgrp = titelgrp.
  ENDMETHOD.


  METHOD create_tg.
    CHECK m_titelgrp IS NOT INITIAL.
    IF get_tg_data( ) IS INITIAL.
      DATA(new_tg) = CORRESPONDING /thkr/c_titelgrp( is_data ).
      new_tg-mandt = sy-mandt.
      new_tg-fikrs = m_fikrs.
      new_tg-gjahr = m_gjahr.
      new_tg-fkber = m_fkber.
      new_tg-titelgrp   = m_titelgrp.

      INSERT /thkr/c_titelgrp
        FROM new_tg.
      IF sy-subrc = 0.
        r_tg = CORRESPONDING #( new_tg ).
      ENDIF.
    ELSE.
    ENDIF.
  ENDMETHOD.


  METHOD get_instance.
    r_instance = NEW #( fikrs = titelgrp-fikrs
                        gjahr = titelgrp-gjahr
                        fkber = titelgrp-fkber
                        titelgrp = titelgrp-titelgrp ).
  ENDMETHOD.


  METHOD get_tg_data.
    SELECT SINGLE *
      FROM /thkr/c_titelgrp
      INTO CORRESPONDING FIELDS OF @r_tg_data
      WHERE fikrs = @m_fikrs AND
            gjahr = @m_gjahr AND
            fkber = @m_fkber AND
            titelgrp = @m_titelgrp.
  ENDMETHOD.
ENDCLASS.
