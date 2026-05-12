CLASS /thkr/cl_ext_if_def DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_def
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_inpdb_btyp_options,
        onum          TYPE n LENGTH 3,     "Verarbeitungsreihenfolge
        btyp          TYPE c LENGTH 3,
        gi_id_beleg0  TYPE /thkr/gi_id,    "Generische Schnittstelle für 1. Belegung /THKR/S_DE_BELEG
        gi_id_beleg1  TYPE /thkr/gi_id,    "Generische Schnittstelle für weitere Belegung /THKR/S_DE_BELEG
        gi_id_ref_key TYPE /thkr/gi_id,    "Generische Schnittstelle für Ermittlung des referenzierten Satzes
      END OF ty_inpdb_btyp_options .
    TYPES:
      tty_inpdb_btyp_options TYPE STANDARD TABLE OF /thkr/s_de_bic_btyp_k .

    CONSTANTS: BEGIN OF c_process_type,
                 anordnung        TYPE /thkr/process_type_de_i VALUE 'AO_I',
                 funktionsplan    TYPE /thkr/process_type_de_i VALUE 'FKT_I',
                 gruppierungsplan TYPE /thkr/process_type_de_i VALUE 'GRP_I',
                 einzelplan       TYPE /thkr/process_type_de_i VALUE 'EZP_I',
                 ist_rueckmeldng  TYPE /thkr/process_type_de_i VALUE 'IR_E',
               END OF c_process_type.
    CONSTANTS: BEGIN OF c_process_subtype,
                 einzelplan  TYPE /thkr/process_subtype VALUE 'EIZPLN',
                 kapitel     TYPE /thkr/process_subtype VALUE 'KAPITL',
                 titelgruppe TYPE /thkr/process_subtype VALUE 'TITGRP',
                 titel       TYPE /thkr/process_subtype VALUE 'TITEL',
               END OF c_process_subtype.

    CONSTANTS: BEGIN OF c_process_id,
                 current_process TYPE /thkr/process_id VALUE -1,
               END OF c_process_id.
    CONSTANTS: BEGIN OF c_run_status,
                 text_interpretiert TYPE /thkr/de_run_status VALUE '12',
                 bin_liegt_vor      TYPE /thkr/de_run_status  VALUE '15',
                 daten_transform    TYPE /thkr/de_run_status VALUE '20',
                 daten_importiert   TYPE /thkr/de_run_status VALUE '25',
               END OF c_run_status.
    CONSTANTS: BEGIN OF c_run_status2,
                 initial     TYPE /thkr/de_run2_status VALUE '00',
                 ep_fehler   TYPE /thkr/de_run2_status VALUE '29',
                 ep_angelegt TYPE /thkr/de_run2_status VALUE '30',
                 ka_fehler   TYPE /thkr/de_run2_status VALUE '39',
                 ka_angelegt TYPE /thkr/de_run2_status VALUE '40',
                 fp_fehler   TYPE /thkr/de_run2_status VALUE '59',
                 fp_angelegt TYPE /thkr/de_run2_status VALUE '60',
               END OF c_run_status2.

    CONSTANTS: BEGIN OF c_ln_art,
                 anordnungsbeleg TYPE /thkr/event_ln_art VALUE 'AO_I_BEL',
                 funktionen      TYPE /thkr/event_ln_art VALUE 'FKT_I',
                 process_type    TYPE /thkr/event_ln_art VALUE 'PROC_DE',
                 einzelplan      TYPE /thkr/event_ln_art VALUE 'EP_I',
                 kapitel         TYPE /thkr/event_ln_art VALUE 'KP_I',
                 titel_gruppe    TYPE /thkr/event_ln_art VALUE 'TG_I',
                 titel           TYPE /thkr/event_ln_art VALUE 'TI_I',
                 fipos           TYPE /thkr/event_ln_art VALUE 'FP_I',
               END OF c_ln_art.

    CONSTANTS: BEGIN OF c_hhmodus,
                 einzelhh_original(4) TYPE c VALUE 'EOHH',
                 einzelhh_nachtrag(4) TYPE c VALUE 'ENHH',
                 doppelhh_original(4) TYPE c VALUE 'DOHH',
                 doppelhh_nachtrj1(4) TYPE c VALUE 'DNH1',
                 doppelhh_nachtrj2(4) TYPE c VALUE 'DNH2',
                 doppelhh_nachtrjh(4) TYPE c VALUE 'DNHH',
               END OF c_hhmodus.

    DATA t_inpdb_btyp_options TYPE tty_inpdb_btyp_options READ-ONLY .
    DATA md TYPE /thkr/s_de_md READ-ONLY .
    DATA cde TYPE /thkr/s_cde .
    CONSTANTS ir_e_rec_id_header TYPE /thkr/gi_record_id VALUE 'RM_FILE' ##NO_TEXT.
    CONSTANTS ir_e_rec_id_item TYPE /thkr/gi_record_id VALUE 'RM_ITEM' ##NO_TEXT.

    METHODS constructor .
    CLASS-METHODS get_instance
      EXPORTING
        !e_instance       TYPE REF TO /thkr/cl_ext_if_def
      RETURNING
        VALUE(r_instance) TYPE REF TO /thkr/cl_ext_if_def .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA instance TYPE REF TO /thkr/cl_ext_if_def .
ENDCLASS.



CLASS /THKR/CL_EXT_IF_DEF IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    DATA: l_bto TYPE ty_inpdb_btyp_options.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF md
      FROM /thkr/de_md.

    ASSERT sy-subrc = 0.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF cde
      FROM /thkr/cde.

    SELECT * INTO CORRESPONDING FIELDS OF TABLE t_inpdb_btyp_options
      FROM /thkr/cbic_btyp.

***    l_bto-btyp = 'FUA'. l_bto-onum = '012'. l_bto-gi_id_beleg0 = 'BC_001'. l_bto-gi_id_beleg1 = 'BC_FUA'.
***    APPEND l_bto TO t_inpdb_btyp_options.
***    l_bto-btyp = 'SST'. l_bto-onum = '007'. l_bto-gi_id_beleg0 = 'BC_001'.l_bto-gi_id_beleg1 = 'BC_SST'.
***    APPEND l_bto TO t_inpdb_btyp_options.
***
***    CLEAR l_bto-gi_id_beleg0.
***    l_bto-btyp = 'KOR'. l_bto-onum = '022'. l_bto-gi_id_beleg1 = 'BC_KOR'. l_bto-gi_id_ref_key = 'BC_KOR_REF'.
***    APPEND l_bto TO t_inpdb_btyp_options.


  ENDMETHOD.


  METHOD get_instance.

    IF instance IS INITIAL.

      CREATE OBJECT instance.

    ENDIF.

    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.
ENDCLASS.
