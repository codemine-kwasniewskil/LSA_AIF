*"----------------------------------------------------------------------
* Gereon Koks  TSI  10.1.2025
*"----------------------------------------------------------------------
* Function before Mapping.
* The already existing AO is read via XBLNR = 41_URKASS.
* Afterwards additional fields are mapped.
*"----------------------------------------------------------------------
* Wird bei den Buchungsschlüsseln SAB/SZU und STU verwendet.
* Bei SAB/SZU wird auch nach einer Referenz innerhalb der Datei gesucht.
*      SZU SAB STU
* 0004      X
* 0013  X
* 0031      X   X
* 0039      X   X
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_bmap_reference .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_AIF_BIC
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_AIF_BIC_ZEILE
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_AO
*"     REFERENCE(DEST_TABLE)
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  DATA: lv_message_v1 TYPE symsgv,
        lv_message_v2 TYPE symsgv,
        lv_message_v3 TYPE symsgv,
        lv_message_v4 TYPE symsgv.
*"--------------------------------------------------------------------
  DATA: ls_bkpf     TYPE bkpf,
        lt_kont     TYPE /thkr/t_dto_psm_ao_kont,
        ls_kont     TYPE /thkr/s_dto_psm_ao_kont,
        ls_bseg     TYPE bseg,
        lv_15_betrl TYPE string,
        lv_wrbtr_in TYPE string,
        lv_wrbtr    TYPE string,
        ls_m1       TYPE symsgv.

  append_flag = abap_false.
*"----------------------------------------------------------------------
* BKPF
*"----------------------------------------------------------------------
* Die Orginal-Anordnung hat BLART = 'DR'.
* Die Annahme-AbsetzungsAO hat BLART = 'DG'.
* Eventuell gibt es mehrere/nachfolgenden Annahme-AbsetzungsAO, dann muss differenziert werden.
* D1 FVV AnnahmeAO
* K1 FVV AuszahlungsAO
  DATA: lt_so_blart  TYPE RANGE OF blart,
        tst_blart(2).

  DATA: lv_ns      TYPE /aif/ns,
        lv_ifname  TYPE /aif/ifname,
        lv_ifversion TYPE /aif/ifversion.

*Fuba ermittelt Laufzeitparameter

  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
*     XIMSGGUID =
*     MSGDATE   =
*     MSGTIME   =
*     VARIANT   =
*     TRACE_LEVEL          =
*     SENDING_SYSTEM       =
*     LOG_HANDLE           =
*     TESTRUN   =
      ns        = lv_ns
      ifname    = lv_ifname
      ifversion = lv_ifversion
*     FINF      =
*     PROCESS_ID           =
    .

  SELECT blart FROM /thkr/ao_ref_bla
    WHERE ns = @lv_ns
    AND
    ifname = @lv_ifname
    AND
    ifversion = @lv_ifversion INTO TABLE @DATA(lt_blart).

  IF sy-subrc <> 0.
*      Fehlermeldung.

    IF 1 = 0.
      MESSAGE e079(/thkr/sst).
    ENDIF.

    APPEND VALUE bapiret2( id = '/THKR/SSt'
                           number = 079
                           type = 'E'
                           message_v1 = lv_ns
                           message_v2 = lv_ifname
                           message_v3 = lv_ifversion
                           message_v4 = '/thkr/ao_ref_bla'
     ) TO dest_line-msg.
    append_flag = abap_true.

  ELSE.

    LOOP AT lt_blart ASSIGNING FIELD-SYMBOL(<fs_blart>).
      APPEND VALUE #( sign = 'I'
      option = 'EQ'
      low = <fs_blart>-blart ) TO lt_so_blart.
    ENDLOOP.


    SELECT * FROM bkpf INTO ls_bkpf
      WHERE blart IN lt_so_blart
*    WHERE ( blart = 'D1' OR blart = 'K1' )   "entfällt mit INC08909539
        AND xblnr = raw_line-41_urkass.
*      And gjahr = raw_line-04_hhj.           "entfällt mit INC08909539

* Nicht zurückliefern, weil sonst versucht wird, den alte Beleg zu ändern
*    dest_line-belnr = ls_bkpf-belnr.

* Rechnungsbezug
      dest_line-rebzg = ls_bkpf-belnr.
      dest_line-rebzj = ls_bkpf-gjahr.
      dest_line-rebzz = '1'.
      dest_line-rebzt = 'F'.

      dest_line-bldat = ls_bkpf-bldat.
* BLART wird im Feld-Mapping neu gesetzt
      dest_line-bukrs = ls_bkpf-bukrs.
      dest_line-budat = ls_bkpf-budat.
      dest_line-waers = ls_bkpf-waers.
* Gereon Koks  TSI  7.4.2025
* Bei Buchung über Referenz auf einen alten Beleg,
* erzeugt SAP ein neues Kassenzeichen.
* XBLNR deshalb leer lassen.
* Oder doch drin lassen ? => Fehler beim Buchen aufgetreten
      dest_line-xblnr = ls_bkpf-xblnr.
      dest_line-gjahr = ls_bkpf-gjahr.
      dest_line-psoak = 'A'.
      dest_line-xref1_hd = ls_bkpf-xref1_hd.
      dest_line-monat = ls_bkpf-monat.
      dest_line-psofn = ls_bkpf-psofn.
*"----------------------------------------------------------------------
* BSEG (01,D)
*"----------------------------------------------------------------------
      SELECT * FROM bseg INTO ls_bseg
        WHERE bukrs = ls_bkpf-bukrs
          AND belnr = ls_bkpf-belnr
          AND gjahr = ls_bkpf-gjahr
          AND bschl = '01'.

        dest_line-partner = ls_bseg-kunnr.
* Mahnbereich aus der Refe
        dest_line-maber = ls_bseg-maber.
        dest_line-mansp = ls_bseg-mansp.
        dest_line-zlsch = ls_bseg-zlsch.
* Kann auch bei BSCHL = 50 sein
* Noch nicht final geklärt
        dest_line-zfbdt = ls_bseg-zfbdt.
* Rechnungsbezug (noch nicht klar, ob wirklich bei BSCHL = 01)
*      dest_line-rebzg = ls_bseg-rebzg.
*      dest_line-rebzj = ls_bseg-rebzj.
*      dest_line-rebzz = ls_bseg-rebzz.
        dest_line-bvtyp = ls_bseg-bvtyp.

        EXIT.
      ENDSELECT.
*"----------------------------------------------------------------------
* BSEG (50,S)
*"----------------------------------------------------------------------
      SELECT * FROM bseg INTO ls_bseg
        WHERE bukrs = ls_bkpf-bukrs
          AND belnr = ls_bkpf-belnr
          AND bschl = '50'.

        ls_kont-hkont = ls_bseg-hkont.
        ls_kont-fipex = ls_bseg-fipos.
        ls_kont-fistl = ls_bseg-fistl.
        ls_kont-mwskz = 'A0'.
        ls_kont-wrbtr = ls_bseg-wrbtr.
        ls_kont-fkber = ls_bseg-fkber.
        ls_kont-geber = ls_bseg-geber.
        ls_kont-kostl = ls_bseg-kostl.
        ls_kont-sgtxt = ls_bseg-sgtxt.
        ls_kont-fikrs = ls_bkpf-fikrs.

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        APPEND ls_kont TO lt_kont.
        dest_line-t_kont = lt_kont.

        EXIT.
      ENDSELECT.
*"----------------------------------------------------------------------
* Nach dem ersten Treffer verlassen.
      append_flag = abap_true.

      EXIT.
    ENDSELECT.
*"----------------------------------------------------------------------
    IF sy-subrc = 0.
* Gefunden !
      CONCATENATE 'MAP_REF 06_QBELNR' raw_line-06_qbelnr INTO lv_message_v1 SEPARATED BY space.
      CONCATENATE '01_BTYP' raw_line-01_btyp INTO lv_message_v2 SEPARATED BY space.
      CONCATENATE '41_URKASS' raw_line-41_urkass INTO lv_message_v3 SEPARATED BY space.
      CONCATENATE 'BELNR:' ls_bkpf-belnr 'gefunden.' INTO lv_message_v4 SEPARATED BY space.

      APPEND VALUE #( id         = '/THKR/SST'
                      number     = 001
                      type       = 'S'
                      message_v1 = lv_message_v1
                      message_v2 = lv_message_v2
                      message_v3 = lv_message_v3
                      message_v4 = lv_message_v4 ) TO return_tab.

      APPEND VALUE #( id         = '/THKR/SST'
                      number     = 001
                      type       = 'S'
                      message_v1 = 'MAP_REF Referenz auf DB gefunden' ) TO return_tab.
    ELSE.
* Nicht gefunden !
      CONCATENATE 'MAP_REF 06_QBELNR' raw_line-06_qbelnr INTO lv_message_v1 SEPARATED BY space.
      CONCATENATE '01_BTYP' raw_line-01_btyp INTO lv_message_v2 SEPARATED BY space.
      CONCATENATE '41_URKASS' raw_line-41_urkass INTO lv_message_v3 SEPARATED BY space.

      "Fehlermeldung darf nicht in return_tab geschrieben werden, weil sonst die Aktion nicht ausgeführt wird.
* Gereon:
* Wir müssen hier nochmal sprechen.
* Wenn die Referenz nicht gefunden wurde, möchte ich die Info darüber direkt im Protokoll haben.
      APPEND VALUE #( id         = '/THKR/SST'
                      number     = 001
                      type       = 'I'
                      message_v1 = lv_message_v1
                      message_v2 = lv_message_v2
                      message_v3 = lv_message_v3
                      message_v4 = 'nicht gefunden.' ) TO return_tab.

      APPEND VALUE #( id         = '/THKR/SST'
                      number     = 001
                      type       = 'S'
                      message_v1 = 'MAP_REF Referenz auf DB nicht gefunden' ) TO return_tab.

      "Es konnte zwar keine Referenz gefunden werden aber die Datenzeile darf auch nicht einfach verschwnden.
      append_flag = abap_true.

      "Führe Fehlermeldung in Datenzeile ein.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                         number = 033
                         type = 'E'
                         message_v1 = raw_line-41_urkass ) TO dest_line-msg.
      dest_line-ao_proc_status = 'E'.
      RETURN.
    ENDIF.

  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
