FUNCTION-POOL /THKR/KLSA966_FG.                  "MESSAGE-ID ..
tables: /thkr/s_klsa966_INCL.
DATA: gv_zins_input_flag TYPE xfeld.

* Aktivität:
CONSTANTS: gc_activity_01 TYPE activ_auth VALUE '01', " Anlegen
           gc_activity_02 TYPE activ_auth VALUE '02', " Ändern
           gc_activity_03 TYPE activ_auth VALUE '03', " Anzeigen
           gc_activity_10 TYPE activ_auth VALUE '10'. " Buchen
