class /THKR/CL_MIG_DEF definition
  public
  inheriting from /THKR/CL_DEF
  final
  create public .

public section.

  types:
    BEGIN OF ty_inpdb_btyp_options,
        onum          TYPE n LENGTH 3,     "Verarbeitungsreihenfolge
        btyp          TYPE c LENGTH 3,
        gi_id_beleg0  TYPE /thkr/gi_id,    "Generische Schnittstelle für 1. Belegung /THKR/S_DE_BELEG
        gi_id_beleg1  TYPE /thkr/gi_id,    "Generische Schnittstelle für weitere Belegung /THKR/S_DE_BELEG
        gi_id_ref_key TYPE /thkr/gi_id,    "Generische Schnittstelle für Ermittlung des referenzierten Satzes
      END OF ty_inpdb_btyp_options .
  types:
    tty_inpdb_btyp_options TYPE STANDARD TABLE OF /thkr/s_de_bic_btyp_k .

  constants:
    BEGIN OF process_type,
                 mig_anordnung    TYPE /thkr/process_type VALUE 'MIG_AO',
                 mig_rk           type /thkr/process_type VALUE 'MIG_RK',
               END OF process_type .
  constants:
    BEGIN OF c_process_id,
                 current_process TYPE /thkr/process_id VALUE -1,
               END OF c_process_id .
  constants:
    BEGIN OF c_run_status,
                 text_interpretiert TYPE /thkr/de_run_status VALUE '12',
                 bin_liegt_vor      TYPE /thkr/de_run_status  VALUE '15',
                 daten_transform    TYPE /thkr/de_run_status VALUE '20',
                 daten_importiert   TYPE /thkr/de_run_status VALUE '25',
               END OF c_run_status .
  constants:
    BEGIN OF c_run_status2,
                 initial     TYPE /thkr/de_run2_status VALUE '00',
                 ep_fehler   TYPE /thkr/de_run2_status VALUE '29',
                 ep_angelegt TYPE /thkr/de_run2_status VALUE '30',
                 ka_fehler   TYPE /thkr/de_run2_status VALUE '39',
                 ka_angelegt TYPE /thkr/de_run2_status VALUE '40',
               END OF c_run_status2 .
  constants:
    BEGIN OF c_ln_art,
                 anordnungsbeleg TYPE /thkr/event_ln_art VALUE 'AO_I_BEL',
                 funktionen      TYPE /thkr/event_ln_art VALUE 'FKT_I',
                 process_type    TYPE /thkr/event_ln_art VALUE 'PROC_DE',
                 einzelplan      TYPE /thkr/event_ln_art VALUE 'EP_I',
                 kapitel         TYPE /thkr/event_ln_art VALUE 'KP_I',
                 titel_gruppe    TYPE /thkr/event_ln_art VALUE 'TG_I',
                 titel           TYPE /thkr/event_ln_art VALUE 'TI_I',
                 fipos           TYPE /thkr/event_ln_art VALUE 'FP_I',
               END OF c_ln_art .
  constants:
    BEGIN OF c_hhmodus,
                 einzelhh_original(4) TYPE c VALUE 'EOHH',
                 einzelhh_nachtrag(4) TYPE c VALUE 'ENHH',
                 doppelhh_original(4) TYPE c VALUE 'DOHH',
                 doppelhh_nachtrj1(4) TYPE c VALUE 'DNH1',
                 doppelhh_nachtrj2(4) TYPE c VALUE 'DNH2',
                 doppelhh_nachtrjh(4) TYPE c VALUE 'DNHH',
               END OF c_hhmodus .
  data MIG_MD type /THKR/S_MIG_MD .

  methods CONSTRUCTOR .
  class-methods GET_INSTANCE
    exporting
      !E_INSTANCE type ref to /THKR/CL_MIG_DEF
    returning
      value(R_INSTANCE) type ref to /THKR/CL_MIG_DEF .
  PROTECTED SECTION.
private section.

  class-data INSTANCE type ref to /THKR/CL_MIG_DEF .
ENDCLASS.



CLASS /THKR/CL_MIG_DEF IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF mig_md
      FROM /thkr/mig_md.

*    ASSERT sy-subrc = 0.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_mig
        MESSAGE e006(/thkr/mig) .
    ENDIF.

  ENDMETHOD.


  METHOD GET_INSTANCE.

    IF instance IS INITIAL.

      CREATE OBJECT instance.

    ENDIF.

    e_instance = instance.
    r_instance = instance.

  ENDMETHOD.
ENDCLASS.
