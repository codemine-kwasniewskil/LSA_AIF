*"----------------------------------------------------------------------
* Gereon Koks  TSI  7.11.2024
*"----------------------------------------------------------------------
* Map HKONT
* Logik ist Vorab-Näherung und muss noch genauer spezifiziert werden.
*"----------------------------------------------------------------------
* Input
* VALUE_IN  12_OEH
* VALUE_IN2 09_AOB
* VALUE_IN3 Name des Feldes (z.B.: "BUKRS")
* VALUE_IN4 10_KAPITEL
* VALUE_IN5 11_TITEL
*"----------------------------------------------------------------------
* Output
* VALUE_OUT Wert des Feldes aus der CENTRALMAP
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_centralmap .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(RAW_STRUCT)
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  DATA: lv_message_v1 TYPE symsgv,
        lv_message_v2 TYPE symsgv,
        lv_message_v3 TYPE symsgv,
        lv_message_v4 TYPE symsgv,
        lv_ep         TYPE  /thkr/mig_epl,
        lv_oeh        TYPE /thkr/mig_oeh_old,
        lv_titel      TYPE /thkr/mig_titel,
        lv_kapitel    TYPE /thkr/mig_kapitel,
        lv_msn        TYPE /thkr/mig_kam_sub_acc_old,
        lv_dst        TYPE /thkr/mig_dst_old,
        lv_read_cm    TYPE flag VALUE abap_false,
        lo_struc      TYPE REF TO cl_abap_structdescr.
*"----------------------------------------------------------------------
  lo_struc ?= cl_abap_structdescr=>describe_by_data( p_data = raw_line ).
  DATA(lv_struc_name) = lo_struc->get_relative_name(  ).
  IF lv_struc_name = '/THKR/S_AIF_BIC_ZEILE'.
    "Verarbeitung von BIC-Format
    IF /thkr/cl_fi_central_mapping=>get_instance( )->btyp_is_ane( is_raw_line = raw_line ) = abap_true.
      "Auslesen von Feldern aus Central Map für ANE Datensätze
      "Bei ANE-Datensätze sind die Felder EP und OEH leer.
      "Wenn der GP noch nicht vorhanden ist, dann wird mit ANE-Datensätzen
      "Kein Buchungskreis oder Geschäfstbereich ermittelt.
      /thkr/cl_fi_central_mapping=>get_instance( )->determine_ep_oeh_for_ane(
        EXPORTING
          is_raw_line   = raw_line                 " BIC Zeile
          is_raw_struct = raw_struct                 " Output Struktur
        IMPORTING
          ev_ep         = lv_ep                 " Einzelplan
          ev_oeh        = lv_oeh                 " OEH  alt
          ev_kapitel    = lv_kapitel
          ev_titel      = lv_titel
      ).

      "Kein Einzelplan und Organisationseinheit in Datei gefunden.
      "Lese von Datenbank.
*"----------------------------------------------------------------------
      IF lv_ep IS INITIAL AND lv_oeh IS INITIAL.
        ASSIGN COMPONENT '41_urkass' OF STRUCTURE raw_line TO FIELD-SYMBOL(<lv_urkass>).

        IF <lv_urkass> IS INITIAL.
          "es wurde kein Urkassenzeichen geliefert. Allerdings die interne Nummer der Mittelbindung
          "D.h. es wird nach der Belegnummer gesucht.
          ASSIGN COMPONENT '14_REFER' OF STRUCTURE raw_line TO FIELD-SYMBOL(<lv_refer>).
          "Weder Urkassenzeichen noch interne Belegnummer vorhanden.
          "Fehlermeldung ausgeben.
          IF <lv_refer> IS NOT INITIAL.

            CALL FUNCTION '/THKR/AIF_VMAP_ANE_BELNR'
              EXPORTING
                value_in   = CONV string( <lv_refer> )
                value_in2  = value_in3
*               VALUE_IN3  =
*               VALUE_IN4  =
*               VALUE_IN5  =
*               SENDING_SYSTEM       =
*               VALUE_FOUND          =
                raw_line   = raw_line
                raw_struct = raw_struct
              TABLES
                return_tab = return_tab
              CHANGING
                value_out  = value_out
*               EXCEPTIONS
*               NO_VALUE_FOUND       = 1
*               OTHERS     = 2
              .

          ENDIF.

        ELSE.
          "Urkassenzeichen wurde geliefert. Daten zum Urkassenzeichen aus Datenbank ermitteln.
          CALL FUNCTION '/THKR/AIF_VMAP_ANE_FINANCE'
            EXPORTING
              value_in   = conv string( <lv_urkass> )
              value_in2  = value_in3
*             VALUE_IN3  =
*             VALUE_IN4  =
*             VALUE_IN5  =
*             SENDING_SYSTEM       =
*             VALUE_FOUND          =
              raw_line   = raw_line
              raw_struct = raw_struct
            TABLES
              return_tab = return_tab
            CHANGING
              value_out  = value_out
* EXCEPTIONS
*             NO_VALUE_FOUND       = 1
*             OTHERS     = 2
            .

        ENDIF.
      ELSE.
        "Daten aus zentraler Mappingtabelle lesen
        lv_read_cm = abap_true.
      ENDIF.
*"----------------------------------------------------------------------
    ELSE.
      lv_oeh = value_in.
      lv_ep = value_in2.
      lv_kapitel = value_in4.
      lv_titel = value_in5.
      CONDENSE lv_titel NO-GAPS.
      ASSIGN COMPONENT '13_MSN' OF STRUCTURE raw_line TO FIELD-SYMBOL(<lv_msn>).
      lv_msn = <lv_msn>.
      ASSIGN COMPONENT '49_DSTNR' OF STRUCTURE raw_line TO FIELD-SYMBOL(<lv_dst>).
      lv_dst = <lv_dst>.
      "Daten aus zentraler Mappingtabelle lesen
      lv_read_cm = abap_true.
    ENDIF.
  ELSE.
    "Bearbeitung in anderen Formaten
    lv_oeh = value_in.
    lv_ep = value_in2.
    lv_kapitel = value_in4.
    lv_titel = value_in5.
    CONDENSE lv_titel NO-GAPS.
    CLEAR: lv_msn.
    CLEAR: lv_dst.
    "Daten aus zentraler Mappingtabelle lesen
    lv_read_cm = abap_true.
  ENDIF.

  IF lv_read_cm = abap_true.

    "pTRAVEL liefert einen KRK-Datensatz.
    "in diesem KRK-Datensatz stehen zusätzliche Informationen für das Auslesen der zentralen Mappingtabelle
    "22_res1 = Sachkonto
    "24_res2 = Kostenstelle
    "26_res3 = Innenauftrag.
    IF lv_struc_name = '/THKR/S_AIF_BIC_ZEILE'.
      /thkr/cl_fi_central_mapping=>get_instance( )->get_krk_information(
        EXPORTING
          is_raw_struc    = raw_struct                " BIC Struktur
          is_raw_line     = raw_line                 " BIC Zeile
        IMPORTING
          ev_sachkonto    = DATA(lv_sachkonto)                 " Sachkonto alt
          ev_innenauftrag = DATA(lv_innenauftrag)                 " Innenauftrag alt
          ev_kostenstelle = DATA(lv_kostenstelle)                 " Kostenstelle alt
      ).
    ENDIF.
    IF lv_sachkonto IS NOT INITIAL
    OR lv_innenauftrag IS NOT INITIAL
    OR lv_kostenstelle IS NOT INITIAL.
      "Es wurden zusätzliche Attribute identifiziert.
      "Also muss mit diesen die zentrale Mappingtabelle gelesen werden

      /thkr/cl_fi_central_mapping=>get_instance( )->read_centr_map_with_add_fields(
        iv_ep           =  lv_ep                 " Einzelplan
        iv_oeh          =  lv_oeh                " OEH  alt
        iv_titel        =  lv_titel              " Titel
        iv_kapitel      =  lv_kapitel            " Kapitel
        iv_sachkonto    =  lv_sachkonto          " Sachkonto alt
        iv_kostenstelle =  lv_kostenstelle       " Innenauftrag alt
        iv_innenauftrag =  lv_innenauftrag       " Kostenstelle alt
        iv_msn          =  lv_msn                " kamerales Unterkonto alt
      ).
    ELSE.
      "Keine zusätzlichen Attribute.
      "Lese zentrale Mappingtabelle mit Einzelplan, OEH, Kapitel und Titel
      /thkr/cl_fi_central_mapping=>get_instance( )->read_central_mapping(
        iv_ep  = lv_ep              " Einzelplan
        iv_oeh = lv_oeh           " OEH  alt
        iv_kapitel = lv_kapitel
        iv_titel = lv_titel
        iv_msn   = lv_msn
        iv_dst   = lv_dst
       ).
    ENDIF.

    ASSIGN COMPONENT value_in3 OF STRUCTURE /thkr/cl_fi_central_mapping=>mo_instance->ms_central_map TO FIELD-SYMBOL(<lv_field>).
    IF <lv_field> IS ASSIGNED.
      value_out = <lv_field>.
    ELSE.
      CLEAR value_out.
    ENDIF.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
