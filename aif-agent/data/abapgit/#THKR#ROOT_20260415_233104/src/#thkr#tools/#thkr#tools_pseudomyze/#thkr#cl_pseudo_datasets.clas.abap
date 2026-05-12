CLASS /thkr/cl_pseudo_datasets DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_names
      RETURNING
        VALUE(names) TYPE /thkr/tools_pseudo_datas .
    CLASS-METHODS get_orgs
      RETURNING
        VALUE(names) TYPE /thkr/tools_pseudo_datas .
    CLASS-METHODS get_addr
      RETURNING
        VALUE(names) TYPE /thkr/tools_pseudo_datas .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_PSEUDO_DATASETS IMPLEMENTATION.


    METHOD GET_ADDR.

    names = VALUE #( ( field1 = 'Schmunzelallee 42' field2 = '10115' field3 = 'Berlin' field4 = '' ) ( field1 = 'Witzweg 7' field2 = '20095' field3 = 'Hamburg' field4 = '' ) ( field1 = 'Kichererbsenweg 12' field2 = '28195' field3 = 'Bremen' field4 = '' )
 ( field1 = 'Kalauer-Kringel 8' field2 = '50667' field3 = 'Köln' field4 = '' ) ( field1 = 'Puddingplatz 1' field2 = '60311' field3 = 'Frankfurt am Main' field4 = '' ) ( field1 = 'Keksring 3' field2 = '70173' field3 = 'Stuttgart' field4 = '' )
 ( field1 = 'Donutstraße 13' field2 = '80331' field3 = 'München' field4 = '' ) ( field1 = 'Pixelpromenade 64' field2 = '90403' field3 = 'Nürnberg' field4 = '' ) ( field1 = 'Zauberstaballee 9' field2 = '01067' field3 = 'Dresden' field4 = '' )
 ( field1 = 'Seifenblasenstraße 19' field2 = '04109' field3 = 'Leipzig' field4 = '' ) ( field1 = 'Gummibärchengasse 5' field2 = '93047' field3 = 'Regensburg' field4 = '' ) ( field1 = 'Turteltaubenweg 2' field2 = '53111' field3 = 'Bonn' field4 = '' )
 ( field1 = 'Quatschquellenweg 2' field2 = '68159' field3 = 'Mannheim' field4 = '' ) ( field1 = 'Käsetortenweg 11' field2 = '76133' field3 = 'Karlsruhe' field4 = '' ) ( field1 = 'Mumpitzgasse 6' field2 = '65183' field3 = 'Wiesbaden' field4 = '' )
 ( field1 = 'Senfstraßenring 12' field2 = '39104' field3 = 'Magdeburg' field4 = '' ) ( field1 = 'Bananenboulevard 8' field2 = '14467' field3 = 'Potsdam' field4 = '' ) ( field1 = 'Wackelpuddingweg 77' field2 = '34117' field3 = 'Kassel' field4 = '' )
 ( field1 = 'Kaffeekranzweg 22' field2 = '86150' field3 = 'Augsburg' field4 = '' ) ( field1 = 'Kicherwiese 3' field2 = '37073' field3 = 'Göttingen' field4 = '' ) ).
  ENDMETHOD.


  METHOD get_names.

    names = VALUE #( ( field1 = 'Luke' field2 = 'Skywalker' ) ( field1 = 'Leia' field2 = 'Organa' ) ( field1 = 'Han' field2 = 'Solo' ) ( field1 = 'Obi-Wan' field2 = 'Kenobi' ) ( field1 = 'Anakin' field2 = 'Skywalker' )
    ( field1 = 'Meister' field2 = 'Yoda') (  field1 = 'Darth' field2 = 'Vader' ) ( field1 = 'Homer' field2 = 'Simpson' ) ( field1 = 'Marge' field2 = 'Simpson' ) ( field1 = 'Bart' field2 = 'Simpson' ) ( field1 = 'Lisa' field2 = 'Simpson' )
    ( field1 = 'Ned' field2 = 'Flanders' ) ( field1 = 'Montgomery' field2 = 'Burns' ) ( field1 = 'Moe' field2 = 'Szyslak' ) ( field1 = 'Bibi' field2 = 'Blocksberg' ) ( field1 = 'Benjamin' field2 = 'Blümchen' )
    ( field1 = 'Pippi' field2 = 'Langstrumpf' ) ( field1 = 'Jim' field2 = 'Knopf' ) ( field1 = 'SpongeBob' field2 = 'Schwammkopf' ) ( field1 = 'Patrick' field2 = 'Star' ) ).

  ENDMETHOD.


  METHOD get_orgs.

    names = VALUE #( ( field1 = 'Rainer Zufall' field2 = 'GmbH' field3 = '' field4 = '' ) ( field1 = 'Hans Wurst' field2 = 'AG' field3 = '' field4 = '' ) ( field1 = 'Peter Silie' field2 = 'GmbH & Co. KG' field3 = '' field4 = '' )
    ( field1 = 'Klara Fall' field2 = 'GmbH' field3 = '' field4 = '' ) ( field1 = 'Anna Nass' field2 = 'UG (haftungsbeschränkt)' field3 = '' field4 = '' ) ( field1 = 'Axel Schweiß' field2 = 'OHG' field3 = '' field4 = '' )
    ( field1 = 'Willi Wacker' field2 = 'GmbH' field3 = '' field4 = '' ) ( field1 = 'Das Imperium' field2 = 'KG' field3 = '' field4 = '' ) ( field1 = 'Frank N. Stein' field2 = 'GmbH' field3 = '' field4 = '' )
    ( field1 = 'Wonka Schokolade ' field2 = 'GmbH' field3 = '' field4 = '' ) ( field1 = 'Justin Time' field2 = 'AG' field3 = '' field4 = '' ) ( field1 = 'Chris P. Bacon' field2 = 'UG' field3 = '' field4 = '' )
    ( field1 = 'ACME' field2 = 'AG' field3 = '' field4 = '' ) ( field1 = 'Moes Taverne' field2 = 'GmbH' field3 = '' field4 = '' ) ( field1 = 'Krosse Krabbe' field2 = 'e.K.' field3 = '' field4 = '' )
    ( field1 = 'Polly Ester' field2 = 'GmbH' field3 = '' field4 = '' ) ( field1 = 'Homer Simpson' field4 = 'GmbH' field2 = 'Donutfabrik' field3 = 'Springfield' )
    ( field1 = 'SpongeBob Schwammkopf' field4 = 'UG (haftungsbeschränkt)' field2 = 'Reinigungsservice' field3 = 'Bikini Bottom' ) ( field1 = 'Pippi Langstrumpf' field4 = 'GmbH' field2 = 'Abenteuerreisen' field3 = 'Villa Kunterbunt' )
    ( field1 = 'Bibi Blocksberg' field4 = 'GmbH' field2 = 'Hexerei-Bedarf' field3 = 'Neustadt' ) ).
  ENDMETHOD.
ENDCLASS.
