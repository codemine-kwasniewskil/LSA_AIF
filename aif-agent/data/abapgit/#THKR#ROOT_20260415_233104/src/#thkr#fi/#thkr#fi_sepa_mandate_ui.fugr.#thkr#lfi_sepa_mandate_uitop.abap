FUNCTION-POOL /thkr/fi_sepa_mandate_ui.     "MESSAGE-ID ..

* INCLUDE /THKR/LFI_SEPA_MANDATE_UID...      " Local class definition
TABLES: sepa_mandate.
DATA:   crs_field   TYPE fieldname.
DATA:   g_aktyp     TYPE activ_auth.
DATA:   gs_mandate  TYPE sepa_mandate.
