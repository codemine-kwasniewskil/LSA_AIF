FUNCTION /THKR/AIF_ZALLGE_CHK_BTYP_SUPP .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT)
*"     REFERENCE(DATA_LINE)
*"     REFERENCE(DATA_FIELD)
*"     REFERENCE(MSGTY) TYPE  SYMSGTY DEFAULT 'E'
*"     REFERENCE(VALUE1) TYPE  STRING
*"     REFERENCE(VALUE2) TYPE  STRING
*"     REFERENCE(VALUE3) TYPE  STRING
*"     REFERENCE(VALUE4) TYPE  STRING
*"     REFERENCE(VALUE5) TYPE  STRING
*"     REFERENCE(T_IFCHECK) TYPE  /AIF/T_IFCHECK OPTIONAL
*"     REFERENCE(T_IFACT) TYPE  /AIF/T_IFACT OPTIONAL
*"     REFERENCE(T_ACCHECK) TYPE  /AIF/T_ACCHECK OPTIONAL
*"     REFERENCE(T_FUNC) TYPE  /AIF/T_FUNC OPTIONAL
*"     REFERENCE(T_FMAPCOND) TYPE  /AIF/T_FMAPCOND OPTIONAL
*"     REFERENCE(T_CHECK) TYPE  /AIF/T_CHECK
*"     REFERENCE(T_TABCHK) TYPE  /AIF/T_TABCHK
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"         OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"      DATA_TABLE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"--------------------------------------------------------------------
"Prüfung, ob für die Schnittstelle die Belegart vorgesehen ist.
"Allerdings ist in der Datei das 3stellige Verfahrenkürzel
"in der Tabelle /THKR/CHK_BTYP ist das 4stellige Verfahrenkürzel
"aus diesem Grund wird vorher der 3stellige Schlüssel durch den 4stelligen Schlüssel übersetzt.
SELECT Single t~btyp
  FROM /thkr/chk_btyp as t
 LEFT JOIN /aif/t_vmapval5 as a
   on t~sst = a~int_value
      WHERE a~ns        = @value1
      AND a~vmapname  = @value2
      and a~ext_value1 = @value3
      and t~btyp = @value4
  into @DATA(lv_btyp).
  if sy-subrc = 0.
    "Buchungscode ist für Schnittstelle vorgesehen
    error = abap_false.
  else.
    "Buchngscode ist für Schnittstelle nicht vorgsehen
    error = abap_true.
  endif.
ENDFUNCTION.
