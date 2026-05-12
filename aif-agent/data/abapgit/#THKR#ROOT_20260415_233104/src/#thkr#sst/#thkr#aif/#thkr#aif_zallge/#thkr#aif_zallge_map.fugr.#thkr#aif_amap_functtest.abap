*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* CUSTOMER anhängen.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_amap_functtest .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT)
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"     REFERENCE(DEST_LINE)
*"     REFERENCE(DEST_TABLE)
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  CONSTANTS: lc_vmap_run_conf TYPE /AIF/vmapname VALUE 'MAP_RUN_CONFIG'.
  CONSTANTS: lc_vmap_ns_zallge TYPE /AIF/ns VALUE 'ZALLGE'.
  CONSTANTS: lc_overwrite TYPE /aif/vmap_extval VALUE 'OVWR'.

  DATA: lv_ns TYPE /aif/ns.
  DATA: lv_ifname TYPE /AIF/ifname.

  ASSIGN dest_line TO FIELD-SYMBOL(<ls_dest_line>).
  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns     = lv_ns
      ifname = lv_ifname.

  "Parameter abrufen
  SELECT *
    FROM /aif/t_mvmapval5
   WHERE ns = @lc_vmap_ns_zallge
     AND vmapname = @lc_vmap_run_conf
     AND ext_value1 = @lv_ns
     AND ext_value2 = @lv_ifname
  INTO TABLE @DATA(lt_run_param).
  IF sy-subrc = 0.
    READ TABLE lt_run_param WITH KEY ext_value3 = lc_overwrite
    ASSIGNING FIELD-SYMBOL(<ls_run_param>).
    IF sy-subrc = 0 AND <ls_run_param> IS ASSIGNED.
      "Sollen Daten überschrieben werden?
      IF <ls_run_param>-int_value = abap_true.
        LOOP AT lt_run_param ASSIGNING <ls_run_param>.
          ASSIGN COMPONENT <ls_run_param>-ext_value3 OF STRUCTURE <ls_dest_line> TO FIELD-SYMBOL(<lv_field>).
          IF sy-subrc = 0 AND <lv_field> IS ASSIGNED.
            "Überschreiben nur, für bestimmte
            IF ( <ls_run_param>-ext_value4 IS INITIAL
                OR <ls_run_param>-ext_value4 = '*'
                OR <ls_run_param>-ext_value4 = smap-smapnr ).
              <lv_field> = <ls_run_param>-int_value.
            ELSE.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDLOOP.
        append_flag = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
*"----------------------------------------------------------------------
