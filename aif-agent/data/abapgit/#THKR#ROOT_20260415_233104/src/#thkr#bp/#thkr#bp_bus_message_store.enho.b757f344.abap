"Name: \FU:BUS_MESSAGE_STORE\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/BP_BUS_MESSAGE_STORE.
"Der Parameter namespace wird im Fall eines leeren Mussfeldes nicht übergeben.
"Da das Feld Geschäftsbereich jedoch mit /THKR/ beginnt, muss hier der Namensraum gesetzt werden,
"da sonst keine Navigation auf das leere Feld erfolgen kann.
IF TBFLD_STRG CS '/THKR/' and namespace is INITIAL.
      namespace = '/thkr/'.
  ENDIF.
ENDENHANCEMENT.
