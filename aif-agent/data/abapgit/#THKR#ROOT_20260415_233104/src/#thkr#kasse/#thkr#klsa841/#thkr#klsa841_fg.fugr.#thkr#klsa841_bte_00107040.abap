FUNCTION /thkr/klsa841_bte_00107040.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(E_FLG_CHANGE) LIKE  BOOLE-BOOLE
*"  TABLES
*"      U_T_PSO02 STRUCTURE  PSO02
*"      U_T_PSO02S STRUCTURE  PSO02S
*"      C_T_PSO02_SUBST STRUCTURE  PSO02_SUBST
*"      C_T_PSO02S_SUBST STRUCTURE  PSO02S_SUBST
*"----------------------------------------------------------------------
  " 2025-12-17 js: Für AuszAo BKPF-Prüfung nur als als Warnung ausgeben
  " 2026-01-09 js: Für AuszAo KBLK-Prüfung ebenfalls nur als als Warnung ausgeben

*===============================================================================================
* Funktion: Bei diesem Baustein handelt es sich um eine kopie des BTE-FB SAMPLE_PROCESS_00107040
*           Der BTE wird bei der Anlage von Annahmeanordnungen   (z.B. TA:F881  ) durchlaufen.
*           Nur bei   Annahmeanordnung wird das Kassenzeichen ermittelt.
*===============================================================================================
* PSM-Annahmeanordung -->  Vorbelegen Kassenzeichen
*===============================================================================================


*
  DATA: lv_subrc     TYPE sysubrc,
        lv_kzdouble  TYPE xfeld,    "X = Double Kassenzeichen nicht erlaubt
        lv_kzwarning TYPE xfeld.    "X = Belege mit Kassenzeichen werden verwendet
  DATA: lr_range TYPE REF TO data.

  DATA: lv_kaz TYPE /thkr/d_kassenzeichen.
  DATA: lv_rc TYPE nrreturn.
  DATA: lv_msgnr TYPE msgnr.
  DATA: lv_pruefziffer TYPE char1.
  DATA: ls_kass TYPE /thkr/t_kass.
  DATA: lv_laenge TYPE i.
  DATA: lt_xblnr TYPE TABLE OF xblnr.
  DATA: lv_lines TYPE i.
  DATA: lt_mhnd TYPE TABLE OF mhnd.
  DATA: ls_mhnd TYPE mhnd.


  FIELD-SYMBOLS: <lr_tab> TYPE ANY TABLE.


  " Kopfinformationen
  READ TABLE u_t_pso02 ASSIGNING FIELD-SYMBOL(<ls_pso02>)  INDEX 1.         "Kann es mehrere Sätze geben?
  IF sy-subrc <> 0.
    EXIT.                                                                  " Falls keine Informationen vorhanden, Rücksprung
  ENDIF.

  " Sachkonteninformationen
  READ TABLE u_t_pso02s ASSIGNING FIELD-SYMBOL(<ls_pso02s>)  INDEX 1.       "Kann es mehrere Sätze geben?
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  IF <ls_pso02>-psoty = '01' OR <ls_pso02>-psoty = '02'.
    READ TABLE c_t_pso02_subst ASSIGNING FIELD-SYMBOL(<ls_pso02c>) INDEX 1.   "Kann es mehrere Sätze geben?
    IF sy-subrc <> 0.
      INSERT INITIAL LINE INTO  c_t_pso02_subst INDEX 1 ASSIGNING <ls_pso02c>.
      MOVE-CORRESPONDING <ls_pso02> TO <ls_pso02c>.
    ENDIF.
  ENDIF.

  "**********************************************************************
  "** Temporarly MVO
  "** SAVE MVO
  TRY.
      DATA(line) = /thkr/cl_data_store=>get( id = 'MVO' )->get_attr( 'ITEM_LINE_NO' ).
      DATA(mvoflag) = /thkr/cl_data_store=>get( id = 'MVO' )->get_attr( 'FLAG' ).
      READ TABLE c_t_pso02_subst ASSIGNING <ls_pso02c> INDEX line.
      IF <ls_pso02c> IS ASSIGNED.
        <ls_pso02c>-z_mvo_relevant = mvoflag.
        e_flg_change = abap_true.
      ENDIF.
    CATCH cx_sy_itab_line_not_found.
      "Not MVO relevant
  ENDTRY.
  "**********************************************************************

  LOOP AT u_t_pso02 ASSIGNING <ls_pso02>.

    " PSOTY = Annahmeanordnung
    CHECK <ls_pso02>-psoty = '01' OR <ls_pso02>-psoty = '02'.

    " Sachkonteninformationen
    READ TABLE u_t_pso02s ASSIGNING <ls_pso02s> WITH KEY itabkey = <ls_pso02>-itabkey .
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    READ TABLE c_t_pso02_subst ASSIGNING <ls_pso02c> WITH KEY itabkey = <ls_pso02>-itabkey.   "Kann es mehrere Sätze geben?
    IF sy-subrc <> 0.
      EXIT.
*      INSERT INITIAL LINE INTO  c_t_pso02_subst INDEX 1 ASSIGNING <ls_pso02c>.
*      MOVE-CORRESPONDING <ls_pso02> TO <ls_pso02c>.
    ENDIF.

    IF <ls_pso02>-xblnr IS INITIAL.
      CASE <ls_pso02>-blart.
        WHEN 'MG' OR 'SG' OR 'SN'. "kommt nur bei Mahnlauf vor
        WHEN OTHERS.
          CALL METHOD /thkr/cl_kassenzeichen=>create
            EXPORTING
              i_fonds = <ls_pso02s>-geber
              i_gsber = <ls_pso02s>-gsber
              i_nrnr  = '00'
            IMPORTING
              e_kaz   = lv_kaz
              e_rc    = lv_rc.

          IF lv_rc <> 0.
            CONCATENATE '01' lv_rc INTO lv_msgnr.
            MESSAGE ID '/THKR/KLSA841'  TYPE 'E' NUMBER lv_msgnr.
            IF 1 = 2. MESSAGE e001(/thkr/klsa841). ENDIF.
* Fehler Kassenzeichen ermitteln.
            " Fehlermeldung prüfen, ob sie hier ausgegeben werden
          ELSE.
            e_flg_change = abap_true.
            <ls_pso02c>-xblnr = lv_kaz.
          ENDIF.
      ENDCASE.

    ELSE.

      CASE <ls_pso02>-blart.
        WHEN 'MG' OR 'SG' OR 'SN'. "kommt nur bei Mahnlauf vor
        WHEN OTHERS.
          CASE sy-tcode.
            WHEN 'F871' OR 'F881' OR 'F8Q1' OR 'F8Q2' OR 'FMZ1' OR 'FMV1'.
            WHEN OTHERS. EXIT.
          ENDCASE.


          CLEAR: ls_kass.
          SELECT SINGLE * FROM /thkr/t_kass INTO ls_kass
                 WHERE blart = <ls_pso02>-blart.

          IF ls_kass IS NOT INITIAL. "Eintrag in /THKR/T_KASS

            lv_laenge = strlen( <ls_pso02>-xblnr ).
            IF lv_laenge NOT BETWEEN ls_kass-laenge_von AND ls_kass-laenge_bis.
              lv_msgnr = '031'.
              MESSAGE ID '/THKR/KLSA841' TYPE 'E' NUMBER lv_msgnr.
              IF 1 = 2. MESSAGE e001(/thkr/klsa841). ENDIF.
            ELSE.


              CALL METHOD /thkr/cl_kassenzeichen=>check
                EXPORTING
                  i_xblnr       = <ls_pso02>-xblnr
                  is_kass       = ls_kass
                IMPORTING
                  e_pruefziffer = lv_pruefziffer
                  e_rc          = lv_rc.

              IF lv_rc <> 0.
                CONCATENATE '02' lv_rc INTO lv_msgnr.
                IF sy-tcode = 'F871' AND ( lv_msgnr = '022' OR lv_msgnr = '023' ). "2025-12-17 js: Für AuszAo Prüfung nur als als Warnung ausgeben
                  MESSAGE ID '/THKR/KLSA841'  TYPE 'W' NUMBER lv_msgnr.
                ELSE.
                  MESSAGE ID '/THKR/KLSA841'  TYPE 'E' NUMBER lv_msgnr.
                ENDIF.
                " Fehlermeldung prüfen, ob sie hier ausgegeben werden
                IF 1 = 2. MESSAGE e001(/thkr/klsa841). ENDIF.
                IF 1 = 2. MESSAGE e021(/thkr/klsa841). ENDIF. "Prüfziffer
                IF 1 = 2. MESSAGE e022(/thkr/klsa841). ENDIF. "BKPF
                IF 1 = 2. MESSAGE e023(/thkr/klsa841). ENDIF. "KBLK

*   Fehler Kassenzeichen ermitteln.
              ELSE.
                " Nur ändern bei Unterschied

                IF <ls_pso02>-xblnr <> <ls_pso02c>-xblnr.
                  e_flg_change = abap_true.
                ENDIF.
              ENDIF.

            ENDIF.
          ELSE. "kein Eintrag in /THKR/T_KASS

            CALL METHOD /thkr/cl_kassenzeichen=>check
              EXPORTING
                i_xblnr       = <ls_pso02>-xblnr
                is_kass       = ls_kass
              IMPORTING
                e_pruefziffer = lv_pruefziffer
                e_rc          = lv_rc.

            IF lv_rc <> 0.
              CONCATENATE '02' lv_rc INTO lv_msgnr.
              IF sy-tcode = 'F871' AND ( lv_msgnr = '022' OR lv_msgnr = '023' ). "2025-12-17 js: Für AuszAo Prüfung nur als als Warnung ausgeben

                MESSAGE ID '/THKR/KLSA841'  TYPE 'W' NUMBER lv_msgnr.
              ELSE.
                MESSAGE ID '/THKR/KLSA841'  TYPE 'E' NUMBER lv_msgnr.
              ENDIF.
              " Fehlermeldung prüfen, ob sie hier ausgegeben werden
              IF 1 = 2. MESSAGE e001(/thkr/klsa841). ENDIF.
              IF 1 = 2. MESSAGE e021(/thkr/klsa841). ENDIF. "Prüfziffer
              IF 1 = 2. MESSAGE e022(/thkr/klsa841). ENDIF. "BKPF
              IF 1 = 2. MESSAGE e023(/thkr/klsa841). ENDIF. "KBLK

*     Fehler Kassenzeichen ermitteln.
            ELSE.
              " Nur ändern bei Unterschied

              IF <ls_pso02>-xblnr <> <ls_pso02c>-xblnr.
                e_flg_change = abap_true.
              ENDIF.
            ENDIF.

          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
