 REPORT /thkr/elko_901_search
                 MESSAGE-ID  /thkr/elko
                 LINE-SIZE  122
*                LINE-COUNT  65
                 NO STANDARD PAGE HEADING.
************************************************************************
* Autor      : REGERDES, BTC-AG,
* Datum      : 22.05.2024
* Art        : Report    (x)     Batch-Input ( )      Include   ( )
*              Sonstiges ( )     Modulpool   ( )
************************************************************************
* Änderungen : Zeichen/Datum                  Art
*
************************************************************************
 INCLUDE /thkr/elko_901_search_top.
 INCLUDE /thkr/elko_901_search_form.
 INCLUDE /thkr/elko_901_search_module.


*----------------------------------------------------------------------*
*        V E R A R B E I T U N G                                       *
*----------------------------------------------------------------------*

 START-OF-SELECTION.

   PERFORM selektion_daten CHANGING gt_ausgabe.

*----------------------------------------------------------------------*
*        E N D - V E R A R B E I T U N G                               *
*----------------------------------------------------------------------*

 END-OF-SELECTION.

   CALL SCREEN '0100'.
