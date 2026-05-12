FUNCTION /THKR/AIF_IFDEF_POL_RKO_PROC .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(CONTEXT) TYPE  STRING OPTIONAL
*"     REFERENCE(FINF) TYPE  /AIF/T_FINF
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_BIC OPTIONAL
*"  EXCEPTIONS
*"      CANCEL
*"----------------------------------------------------------------------

  If data-line is INITIAL.
    if 1 = 0. MESSAGE i044(/THKR/SST).endif.
    APPEND value bapiret2( id = '/THKR/SST'
                           number = 044
                           type = 'I' ) to return_tab[].
 endif.

ENDFUNCTION.
