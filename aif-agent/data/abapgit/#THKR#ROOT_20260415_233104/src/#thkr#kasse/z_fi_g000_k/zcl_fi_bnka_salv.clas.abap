class ZCL_FI_BNKA_SALV definition
  public
  inheriting from ZCL_GUI_SALV
  final
  create public .

public section.

  methods CONSTRUCTOR .
protected section.

  methods FILL_DATA
    redefinition .
private section.

  data T_RESULT type ZFI_T_BNKA_RESULT .
  constants C_NAME_FUGR type SYREPID value 'SAPLZGUI_SALV' ##NO_TEXT.
  constants C_GUI_STATUS type SYPFKEY value 'SALV_STANDARD' ##NO_TEXT.
  constants C_GUI_TITEL type LVC_TITLE value 'Banken mit manuellen Sperrvermerken' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'ZCL_BNKA_SALV' ##NO_TEXT.
ENDCLASS.



CLASS ZCL_FI_BNKA_SALV IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    gui_status  = c_gui_status.
    gui_title   = c_gui_titel.
    report_name = c_report_name.
    name_fugr   = c_name_fugr.


    APPEND 'MANDT' TO techfields.

  ENDMETHOD.


  METHOD fill_data.

    SELECT * FROM zfi_bnka INTO TABLE t_result.

    GET REFERENCE OF t_result INTO t_data_ref.


  ENDMETHOD.
ENDCLASS.
