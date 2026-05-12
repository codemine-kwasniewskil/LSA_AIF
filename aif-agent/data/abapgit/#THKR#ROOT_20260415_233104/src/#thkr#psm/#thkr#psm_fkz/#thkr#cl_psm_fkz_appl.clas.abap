class /THKR/CL_PSM_FKZ_APPL definition
  public
  final
  create private .

public section.

  class-methods GET_INSTANCE
    importing
      !FKZ type /THKR/S_PSM_FKZ_KEY
    returning
      value(R_INSTANCE) type ref to /THKR/CL_PSM_FKZ_APPL .
  methods CREATE_FKZ
    importing
      !IS_DATA type /THKR/S_PSM_FKZ_DATA
    returning
      value(R_FKZ) type /THKR/S_PSM_FKZ_KEY .
  methods GET_FKZ_DATA
    returning
      value(R_FKZ_DATA) type /THKR/S_PSM_FKZ_DATA .
protected section.
private section.

  data M_FIKRS type FIKRS .
  data M_GJAHR type GJAHR .
  data M_FKZ type /THKR/FKZ .

  methods CONSTRUCTOR
    importing
      !FIKRS type FIKRS
      !GJAHR type GJAHR
      !FKZ type /THKR/FKZ .
ENDCLASS.



CLASS /THKR/CL_PSM_FKZ_APPL IMPLEMENTATION.


  METHOD constructor.
    m_fikrs = fikrs.
    m_gjahr = gjahr.
    m_fkz   = fkz.
  ENDMETHOD.


  METHOD create_fkz.
    CHECK m_fkz IS NOT INITIAL.
    IF get_fkz_data( ) IS INITIAL.
      DATA(new_fkz) = CORRESPONDING /thkr/c_fkz( is_data ).
      new_fkz-mandt = sy-mandt.
      new_fkz-fikrs = m_fikrs.
      new_fkz-gjahr = m_gjahr.
      new_fkz-fkz   = m_fkz.

      INSERT /thkr/c_fkz
        FROM new_fkz.
      IF sy-subrc = 0.
        r_fkz = CORRESPONDING #( new_fkz ).
      ENDIF.
    ELSE.
    ENDIF.
  ENDMETHOD.


  METHOD get_fkz_data.
    SELECT SINGLE *
      FROM /thkr/c_fkz
      INTO CORRESPONDING FIELDS OF @r_fkz_data
      WHERE fikrs = @m_fikrs AND
            gjahr = @m_gjahr AND
            fkz   = @m_fkz.
  ENDMETHOD.


  METHOD get_instance.
    r_instance = NEW #( fikrs = fkz-fikrs
                        gjahr = fkz-gjahr
                        fkz   = fkz-fkz ).
  ENDMETHOD.
ENDCLASS.
