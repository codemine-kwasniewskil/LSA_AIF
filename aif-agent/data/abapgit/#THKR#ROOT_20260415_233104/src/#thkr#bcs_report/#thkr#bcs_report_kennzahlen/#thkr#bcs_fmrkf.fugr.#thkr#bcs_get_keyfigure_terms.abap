FUNCTION /thkr/bcs_get_keyfigure_terms.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_KEYFIGURE) TYPE  BUKF_KEYFIG
*"     REFERENCE(I_DATASOURCE) TYPE  BUKF_DATASOURCE
*"  EXPORTING
*"     REFERENCE(E_T_TERMS) TYPE  STANDARD TABLE
*"----------------------------------------------------------------------

***  data: l_ref_kf type ref to cl_bukf_kf,
***        l_ref_tm type ref to cl_bukf_terms.
***
**** Terme ermitteln
**** Kennzahl erzeugen
***  create object l_ref_kf
***         exporting
***           im_applic = con_applic
***           im_keyfig = i_keyfigure.
***
**** Terme ermitteln
***  call method l_ref_kf->get_ref_terms
***    exporting
***      im_datasource = i_datasource
***    receiving
***      re_ref_terms  = l_ref_tm.
***
***  call method l_ref_tm->get_terms
***     importing
***       ex_terms = e_t_terms.




  DATA: ls_zcbb_bukf_dsrc   TYPE /thkr/kf_dsrc.                               " zcbb_bukf_dsrc. - Kennzahlen - Datenquelle
  DATA: lt_0001_budt        TYPE STANDARD TABLE OF /thkr/sbcs_kf_s_fmbdt_bcs. " zsbb_fmkf_s_fmbdt_bcs.   - Kennzahlen - Struktur für die Datenbanktabelle FMBDT
  DATA: lt_0002_fmtox       TYPE STANDARD TABLE OF fmkf_s_fmtox.
  DATA: lt_0003_avct        TYPE STANDARD TABLE OF /thkr/sbcs_kf_s_fmavct_bcs. " zsbb_fmkf_s_fmavct_bcs. - Kennzahlen - Struktur für die Datenbanktabelle FMAVCT


  IF i_datasource = '0001'.  " BUDT - Budgetierungsdaten (logDB: BUDT ->  SAPTab:  FMBDT)

    SELECT * FROM /thkr/kf_repterm INTO CORRESPONDING FIELDS OF TABLE lt_0001_budt    " zcbbfmkf_repterm
      WHERE keyfig      = i_keyfigure
        AND datasource  = i_datasource.
    IF sy-subrc = 0.
      e_t_terms[] = lt_0001_budt[].
    ENDIF. " IF sy-subrc = 0.

  ELSEIF i_datasource = '0002'. " FMTOX - Summensätze Obligo & Ist

    SELECT * FROM /thkr/kf_repterm INTO CORRESPONDING FIELDS OF TABLE lt_0002_fmtox   " zcbbfmkf_repterm
      WHERE keyfig      = i_keyfigure
        AND datasource  = i_datasource.
    IF sy-subrc = 0.
      e_t_terms[] = lt_0002_fmtox[].
    ENDIF. " IF sy-subrc = 0.


  ELSEIF i_datasource = '0003'. " AVCT - VbK-Daten (logDB: AVCT ->  SAPTab:  FMAVCT)

    SELECT * FROM /thkr/kf_repterm INTO CORRESPONDING FIELDS OF TABLE lt_0003_avct   " zcbbfmkf_repterm
      WHERE keyfig      = i_keyfigure
        AND datasource  = i_datasource.
    IF sy-subrc = 0.
      e_t_terms[] = lt_0003_avct[].
    ENDIF. " IF sy-subrc = 0.

  ENDIF. " IF i_datasource = 'xxxx'.



ENDFUNCTION.
