class ZCL_FI_BN_NACHRICHTEN definition
  public
  final
  create protected .

public section.

  class-data GT_LINES_OUT type TLINE_T .
  class-data G_FILENAME type STRING .
  constants C_LAYOUT_STD type SLIS_VARI value '/STANDARD' ##NO_TEXT.
  constants C_LAYOUT_ZL type SLIS_VARI value '/STANDARD_ZL' ##NO_TEXT.
  constants C_LAYOUT_RL type SLIS_VARI value '/STANDARD_RL' ##NO_TEXT.
  constants C_LAYOUT_AB type SLIS_VARI value '/STANDARD_AB' ##NO_TEXT.
  constants C_LAYOUT_ZA type SLIS_VARI value '/STANDARD_ZA' ##NO_TEXT.
  constants C_WT_57 type FM_WRTTP value '57' ##NO_TEXT.
  constants C_WT_54 type FM_WRTTP value '54' ##NO_TEXT.

  class-methods GET_INSTANCE
    exporting
      value(E_INSTANCE) type ref to ZCL_FI_BN_NACHRICHTEN
    returning
      value(R_INSTANCE) type ref to ZCL_FI_BN_NACHRICHTEN .
  methods CONSTRUCTOR .
  methods ADD_BELEG
    importing
      !I_BNBEL type ZFI_F_BNBEL
      !I_FHERK type ZFI_F_BNHERK .
  methods EMAIL_VERSENDEN
    importing
      !I_NACHR type ZFI_F_BN_NACHR
      !I_ATTACH_PDF type SOLIX_TAB optional
      !I_ATTACH_TXT type SOLI_TAB optional
      !I_FILENAME type DXLPATH optional .
  methods MAIL_VERSENDEN
    importing
      !I_NACHR type ZFI_F_DTO_NACHR
      !I_FTEXT type ZFI_CU_BN_FTEXT optional
      !I_AKTION type ZFI_CU_BN_AKTION optional
      !I_EMPF type ZFI_CU_BN_EMPF optional
    exporting
      !E_NACHR type ZFI_F_DTO_NACHR
      !E_ERROR type SYST_SUBRC .
  methods GET_TDTO_NACHR
    importing
      !I_SELECTION type ZFI_F_BN_SELECTION
    exporting
      !E_TDTO type ZFI_T_DTO_NACHR .
  methods MODIFY_NACHRICHT
    importing
      !I_NACHR type ZFI_F_DTO_NACHR .
  methods GET_DUPL_NACHR
    importing
      !I_NACHR type ZFI_F_DTO_NACHR
    exporting
      !E_KZ_SEND type XFELD .
  methods CREATE_ZA_PDF
    importing
      !I_NACHR type ZFI_F_DTO_NACHR
      !I_FTEXT type ZFI_CU_BN_FTEXT optional
      !I_AKTION type ZFI_CU_BN_AKTION optional
      !I_EMPF type ZFI_CU_BN_EMPF optional
      !I_DRUCK type ZFI_BN_DRUCK optional
    exporting
      !E_NACHR type ZFI_F_DTO_NACHR
    raising
      ZCX_FI_GEN .
  methods CREATE_PDF
    importing
      !I_NACHR type ZFI_F_DTO_NACHR
      !I_FTEXT type ZFI_CU_BN_FTEXT optional
      !I_AKTION type ZFI_CU_BN_AKTION optional
      !I_EMPF type ZFI_CU_BN_EMPF optional
    exporting
      !E_NACHR type ZFI_F_DTO_NACHR
    raising
      ZCX_FI_GEN .
  methods WRITE_PDF
    importing
      !I_NACHR type ZFI_F_DTO_NACHR
    exporting
      !E_NACHR type ZFI_F_DTO_NACHR
    raising
      ZCX_FI_GEN .
  methods GET_FISTL
    changing
      !C_BNBEL type ZFI_F_BNBEL .
  methods GET_BN_STEUERUNG
    importing
      !I_HERK type ZFI_BN_HERK
      !I_FEHLERNR type ZFI_BN_FNR
      !I_FISTL type FISTL
      !I_UNAME type XUBNAME
    exporting
      !E_FTEXT type ZFI_CU_BN_FTEXT
      !E_AKTION type ZFI_CU_BN_AKTION
      !E_EMPF type ZFI_CU_BN_EMPF .
  methods DISPLAY_PROT
    importing
      !I_HERK type ZFI_BN_HERK optional
      !I_T_DATA_REF type ref to DATA optional
    exporting
      !E_ANZBN type I .
  methods PROCESS_NACHR1
    importing
      !I_NACHR type ZFI_F_DTO_NACHR
      !I_FTEXT type ZFI_CU_BN_FTEXT optional
      !I_AKTION type ZFI_CU_BN_AKTION optional
      !I_EMPF type ZFI_CU_BN_EMPF optional
    exporting
      !E_NACHR type ZFI_F_DTO_NACHR
      !E_ERROR type SYST_SUBRC
    raising
      ZCX_FI_GEN .
  methods GET_ZAHLUNGSVERW
    importing
      !I_BUKRS type BUKRS
      !I_T_FEBCL type FEB_T_FEBCL
    exporting
      !E_POSTAB type ZFI_T_RFPOS .
  methods ADD_BELEG_AB
    importing
      !I_ZBELEG type ZFI_F_ZBELEG
      !I_BNFEB type ZFI_F_BNFEB
      !I_ALLGAO type ZFI_F_ALLGAO .
  methods ADD_BELEG_RL
    importing
      !I_ZBELEG type ZFI_F_ZBELEG
      !I_BNFEB type ZFI_F_BNFEB
      !I_POSTAB type ZFI_T_RFPOS optional
      !I_ORIGPOSTAB type ZFI_F_BELPOS_T optional
      !I_ZBELEGTAB type ZFI_F_ZBELEG_T optional .
  methods GET_FISTL_FMFIIT
    importing
      !I_ZBELEG type ZFI_F_ZBELEG optional
    changing
      !C_BNBEL type ZFI_F_BNBEL .
  methods CHECK_AUTH_TDTO_NACHR
    changing
      !CT_DTO_NACHR type ZFI_T_DTO_NACHR .
protected section.

  class-data BN_APPL type ref to ZCL_FI_BN_NACHRICHTEN .
  data GT_FNR_Z type ZFI_T_FNR .
  data GT_FNR_A type ZFI_T_FNR .
  data GT_FNR_R type ZFI_T_FNR .
  data GT_RBNKEY type ZFI_T_RBNKEY .
  constants C_GRUSS type SO_TEXT255 value 'Mit freundlichen Grüßen Ihre LOK' ##NO_TEXT.
  constants C_EMPF type AD_SMTPADR value 'ckrebs@dxc.com' ##NO_TEXT.
  constants C_SENDER type AD_SMTPADR value 'ckrebs@csc.com' ##NO_TEXT.
  constants C_SUBJECT_Z type TEXT100 value 'Fehler im Zahllauf' ##NO_TEXT.
  constants C_AUTO1 type SO_TEXT255 value 'Dies ist eine automatisch generierte Mitteilung der LOK, auf die nicht geantwortet werden kann.' ##NO_TEXT.
  constants C_AUTO2 type SO_TEXT255 value 'Bei Fragen wenden Sie sich bitte an ' ##NO_TEXT.
  constants C_AUTO3 type SO_TEXT255 value ' XXX.' ##NO_TEXT.
  constants C_AUTO4 type SO_TEXT255 value 'Automatisch generierte Benachrichtigung der LOK' ##NO_TEXT.
  constants C_HK_ZL type ZFI_BN_HERK value 'Z' ##NO_TEXT.
  constants C_HK_RL type ZFI_BN_HERK value 'R' ##NO_TEXT.
  constants C_HK_AB type ZFI_BN_HERK value 'A' ##NO_TEXT.
  constants C_PATH type STRING value '/usr/sap/tmp/' ##NO_TEXT.
  constants C_LOG_PATH_S_BW type PATHINTERN value 'Z_SST_OUT_0099_S-BW' ##NO_TEXT.
  constants C_555_FORMNAME type TDSFNAME value 'ZFI_FK_ZA_555' ##NO_TEXT.
  constants C_539_FORMNAME type TDSFNAME value 'ZFI_FK_ZA_539' ##NO_TEXT.
  constants C_539_PRODUKT type STRING value 'PKHmitteilu' ##NO_TEXT.
  constants C_555_PRODUKT type STRING value 'Zahlungsanz' ##NO_TEXT.
  constants C_539_FORMID type ZFI_EA_FORMID value '539' ##NO_TEXT.
  constants C_555_FORMID type ZFI_EA_FORMID value '555' ##NO_TEXT.
  constants C_TRUE type C value 'X' ##NO_TEXT.
  constants C_VARIANT type ZFI_EA_VARIANT value '1' ##NO_TEXT.
  constants C_HERK_A_PRODUKT type STRING value 'Kontoabbuch' ##NO_TEXT.
  constants C_HERK_R_PRODUKT type STRING value 'Ruecklaeufe' ##NO_TEXT.
  constants C_HERK_Z_PRODUKT type STRING value 'Zahllauffeh' ##NO_TEXT.
  constants C_AUTH_ACTIV type FM_AUTHACT value '03' ##NO_TEXT.
  constants C_FIKRS type FIKRS value '1000' ##NO_TEXT.
private section.

  data G_PATH type STRING .
ENDCLASS.



CLASS ZCL_FI_BN_NACHRICHTEN IMPLEMENTATION.


  METHOD add_beleg.

    DATA: ls_zfi_bn TYPE zfi_bn_nachricht,
          l_uuid    TYPE sysuuid_c32,
          l_fnr     TYPE zfi_bn_fnr,
          l_bnbel   TYPE zfi_f_bnbel,
          l_uname   TYPE xubname,
          l_ppnam   TYPE ppnam.

*   Fehlernummer prüfen, ob relevant für Benachrichtigung
    l_fnr = i_fherk-fehlernr.
    READ TABLE gt_fnr_z WITH KEY fehlernr = l_fnr TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    l_bnbel = i_bnbel.

*   Finanzstelle nachlesen, falls leer
    get_fistl(
      CHANGING
        c_bnbel = l_bnbel ).

*   Erfasser des Beleges ermitteln
    IF i_bnbel-bukrs IS NOT INITIAL AND
       i_bnbel-gjahr IS NOT INITIAL AND
       i_bnbel-belnr IS NOT INITIAL.

      SELECT SINGLE usnam ppnam FROM bkpf INTO (l_uname, l_ppnam)
             WHERE bukrs = i_bnbel-bukrs
             AND   gjahr = i_bnbel-gjahr
             AND   belnr = i_bnbel-belnr.
    ENDIF.

*   Eindeutigen Systemschlüssel erzeugen
    TRY.
        l_uuid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        l_uuid = 0.
        RETURN.
    ENDTRY.

*   Datensatz erzeugen
    ls_zfi_bn-bnkey = l_uuid.
    MOVE-CORRESPONDING i_fherk TO ls_zfi_bn.
    IF ls_zfi_bn-fehlernr IS INITIAL.
      ls_zfi_bn-fehlernr = '999'.
    ENDIF.
    ls_zfi_bn-erfdat = sy-datum.
    ls_zfi_bn-erftim = sy-uzeit.
    ls_zfi_bn-uname  = l_uname.
    ls_zfi_bn-vname  = l_ppnam.
    MOVE-CORRESPONDING l_bnbel TO ls_zfi_bn.

*   Datensatz einfügen
    INSERT zfi_bn_nachricht FROM ls_zfi_bn.

  ENDMETHOD.


  method add_beleg_ab.

    data: ls_zfi_bn type zfi_bn_nachricht,
          l_uuid    type sysuuid_c32,
          l_fnr     type zfi_bn_fnr,
          l_vgext   type vgext_eb,
          l_bnbel   type zfi_f_bnbel,
          l_uname   type xubname,
          l_ppnam   type ppnam,
          l_lifnr   type lifnr,
          l_fistl   type fistl,   "REPRO-ROC
          l_blart   type blart,
          l_budat   type budat,
          l_bldat   type bldat,
          l_xblnr   type xblnr,
          l         type i.

*   Allg AO muss gefüllt sein
    if i_allgao is initial.
      return.
    endif.

* Nachrichtennummer 100 muss im CU stehen
    l_fnr = 100.
    read table gt_fnr_a with key fehlernr = l_fnr transporting no fields.
    if sy-subrc <> 0.
      return.
    endif.

* Mittelvormerkung lesen
    select single  lifnr fistl  from kblp into ( l_lifnr, l_fistl )
                                  where belnr = i_allgao-belnr
                                  and   blpos = i_allgao-blpos.
    if sy-subrc <> 0.
      return.
    endif.
    select single blart xblnr from kblk into ( l_blart, l_xblnr )
                                        where belnr = i_allgao-belnr.
    if sy-subrc <> 0.
      return.
    endif.

    clear ls_zfi_bn.
    ls_zfi_bn-herk = 'A'.
    ls_zfi_bn-fehlernr = l_fnr.

*   Allg AO - Mittelvormerkung
    ls_zfi_bn-belnr = i_allgao-belnr.
    ls_zfi_bn-buzei = i_allgao-blpos.
*    ls_zfi_bn-bukrs = i_allgao-bukrs.
    ls_zfi_bn-blart = l_blart.
    ls_zfi_bn-xblnr = l_xblnr.
*   Kreditor
    ls_zfi_bn-lifnr = l_lifnr.

*   Anzahlung - Zahlungsbeleg
    ls_zfi_bn-vblnr = i_zbeleg-belnr.
*-----------------------------------------------
    ls_zfi_bn-bukrs = i_zbeleg-bukrs.
* Bukrs der allg AO für Anschreiben benötigt
* zurück geändert;
* der ZahlungsBeleg m u s s aus dem Buchungskreis der
* allg AO kommen- alles andere paßt nicht bei den
* Listen usw.
*-----------------------------------------------
*    ls_zfi_bn-zbukr = i_zbeleg-bukrs.
    ls_zfi_bn-gjahr = i_zbeleg-gjahr.

    move-corresponding i_zbeleg to l_bnbel.
*   Finanzstelle  falls leer übergeben
    if  l_bnbel-fistl is initial.
*   Finanzstelle ermitteln falls nicht in MV
      if l_fistl is initial.
        get_fistl(
          changing
            c_bnbel = l_bnbel ).
        ls_zfi_bn-fistl = l_bnbel-fistl.
*  Fistl aus Mittelvormerkung
      else.
        ls_zfi_bn-fistl = l_fistl.
      endif.
    endif.
*   Erfasser des Zahlungsbeleges ermitteln
    if l_bnbel-bukrs is not initial and
       l_bnbel-gjahr is not initial and
       l_bnbel-belnr is not initial.

      select single usnam ppnam bldat budat from bkpf
             into (l_uname, l_ppnam, l_bldat, l_budat)
             where bukrs = l_bnbel-bukrs
             and   gjahr = l_bnbel-gjahr
             and   belnr = l_bnbel-belnr.
      if sy-subrc = 0.
        ls_zfi_bn-uname  = l_uname.
        ls_zfi_bn-vname  = l_ppnam.
        ls_zfi_bn-bldat  = l_bldat.
        ls_zfi_bn-budat  = l_budat.
      endif.
    endif.

*   Kontoauszugsdaten
    move-corresponding i_bnfeb to ls_zfi_bn.
*   Betrag aus Kontoauszug
    ls_zfi_bn-wrbtr = i_bnfeb-kwbtr.
    ls_zfi_bn-waers = i_bnfeb-kwaer.

*   Eindeutigen Systemschlüssel erzeugen
    try.
        l_uuid = cl_system_uuid=>create_uuid_c32_static( ).
      catch cx_uuid_error.
        l_uuid = 0.
        return.
    endtry.

*   Datensatz erzeugen
    ls_zfi_bn-bnkey = l_uuid.
    ls_zfi_bn-erfdat = sy-datum.
    ls_zfi_bn-erftim = sy-uzeit.

*   Datensatz Benachrichtigung einfügen
    insert zfi_bn_nachricht from ls_zfi_bn.


  endmethod.


  method add_beleg_rl.

    data: ls_zfi_bn type zfi_bn_nachricht,
          l_uuid    type sysuuid_c32,
          l_fnr     type zfi_bn_fnr,
          l_vgext   type vgext_eb,
          l_bnbel   type zfi_f_bnbel,
          l_uname   type xubname,
          l_ppnam   type ppnam,
          l         type i.

    field-symbols: <fs_belpos> type zfi_f_belpos,
                   <fs_zbeleg> type zfi_f_zbeleg.

*   Nur bestimmte Buchungsregeln berücksichtigen
    check i_bnfeb-vgint = '0020' or
          i_bnfeb-vgint = '0021' or
          i_bnfeb-vgint = '0022'.

    check i_bnfeb-vgext is not initial.
*--------------------------------------------------------------------
* REPRO-ROC 20210427  Aufruf geändert
* POSTAB und ORIGPOSTAB sind alternativ
* I_ZBELEG  ist aus zahlendem Bukrs
* I_ZBELEGTAB sind Zahlungen aus den weiteren BUKRS
*--------------------------------------------------------------------
*   Tabelle postab oder ORIGPOSTAB muss gefüllt sein
    if lines( i_postab ) = 0
    and lines( i_origpostab ) = 0.
      return.
    endif.

*   Fehlernummer prüfen, ob relevant für Benachrichtigung
    l_vgext = i_bnfeb-vgext.
    case l_vgext(4).
      when 'RJCT'.
        l_fnr = '001'.
      when '<54>'.
        l = strlen( l_vgext ).
        l = l - 3.
        l_fnr = l_vgext+l(3).
      when others.
        l_fnr = '999'.
    endcase.
*--------------------------------------------------------------------*
* Fehlernummer vorgesehen
*--------------------------------------------------------------------*
    read table gt_fnr_r with key fehlernr = l_fnr transporting no fields.
    if sy-subrc <> 0.
      return.
    endif.

    loop at i_postab assigning field-symbol(<ptab>).
      clear ls_zfi_bn.
      ls_zfi_bn-herk = 'R'.
      ls_zfi_bn-fehlernr = l_fnr.
*
      if <ptab>-koart = 'K'.
        ls_zfi_bn-lifnr = <ptab>-konto.
      elseif <ptab>-koart = 'D'.
        ls_zfi_bn-kunnr = <ptab>-konto.
      endif.

*     Zahlungsbeleg
      ls_zfi_bn-vblnr = i_zbeleg-belnr.

*     ausgeglichener, stornierter Beleg
      move-corresponding <ptab> to ls_zfi_bn.

      ls_zfi_bn-wrbtr = <ptab>-bwwrt.
      ls_zfi_bn-waers = <ptab>-hwaer.

*     Finanzstelle nachlesen, falls leer
      move-corresponding <ptab> to l_bnbel.
      get_fistl(
        changing
          c_bnbel = l_bnbel ).
      ls_zfi_bn-fistl = l_bnbel-fistl.

*     Erfasser des Beleges ermitteln
      if l_bnbel-bukrs is not initial and
         l_bnbel-gjahr is not initial and
         l_bnbel-belnr is not initial.

        select single usnam ppnam from bkpf into (l_uname, l_ppnam)
               where bukrs = l_bnbel-bukrs
               and   gjahr = l_bnbel-gjahr
               and   belnr = l_bnbel-belnr.
      endif.

*     Eindeutigen Systemschlüssel erzeugen
      try.
          l_uuid = cl_system_uuid=>create_uuid_c32_static( ).
        catch cx_uuid_error.
          l_uuid = 0.
          return.
      endtry.

*     Datensatz erzeugen
      ls_zfi_bn-bnkey = l_uuid.
      move-corresponding i_bnfeb to ls_zfi_bn.
      ls_zfi_bn-erfdat = sy-datum.
      ls_zfi_bn-erftim = sy-uzeit.
      ls_zfi_bn-uname  = l_uname.
      ls_zfi_bn-vname  = l_ppnam.

*     Datensatz einfügen
      insert zfi_bn_nachricht from ls_zfi_bn.

    endloop.
    if sy-subrc ne 0.
* Variante 2 ----------------------------------------------*
      loop at i_zbelegtab assigning <fs_zbeleg>.
        loop at i_origpostab assigning <fs_belpos> where bukrs = <fs_zbeleg>-bukrs .
          clear ls_zfi_bn.
          ls_zfi_bn-herk = 'R'.
          ls_zfi_bn-fehlernr = l_fnr.
*
          if <fs_belpos>-koart = 'K'.
            ls_zfi_bn-lifnr = <fs_belpos>-lifnr.
          elseif <fs_belpos>-koart = 'D'.
            ls_zfi_bn-kunnr = <fs_belpos>-kunnr.
          endif.

*     Zahlungsbeleg
          ls_zfi_bn-vblnr = <fs_zbeleg>-belnr.

*     ausgeglichener, stornierter Beleg
          move-corresponding <fs_belpos> to ls_zfi_bn.

*     Finanzstelle nachlesen, weil leer
          move-corresponding <fs_belpos> to l_bnbel.
          get_fistl(
            changing
              c_bnbel = l_bnbel ).
          ls_zfi_bn-fistl = l_bnbel-fistl.

*     Daten aus dem Ursprungsbelegkopf
          if l_bnbel-bukrs is not initial and
             l_bnbel-gjahr is not initial and
             l_bnbel-belnr is not initial.

            select single blart bldat budat usnam  xblnr ppnam from bkpf into
               ( ls_zfi_bn-blart, ls_zfi_bn-bldat, ls_zfi_bn-budat,  ls_zfi_bn-uname, ls_zfi_bn-xblnr,  ls_zfi_bn-vname )
                   where bukrs = l_bnbel-bukrs
                   and   gjahr = l_bnbel-gjahr
                   and   belnr = l_bnbel-belnr.
          endif.

*     Eindeutigen Systemschlüssel erzeugen
          try.
              l_uuid = cl_system_uuid=>create_uuid_c32_static( ).
            catch cx_uuid_error.
              l_uuid = 0.
              return.
          endtry.

*     Datensatz erzeugen
          ls_zfi_bn-bnkey = l_uuid.
          move-corresponding i_bnfeb to ls_zfi_bn.
          ls_zfi_bn-erfdat = sy-datum.
          ls_zfi_bn-erftim = sy-uzeit.

*     Datensatz einfügen
          insert zfi_bn_nachricht from ls_zfi_bn.

        endloop.
      endloop.
    endif.
  endmethod.


  method check_auth_tdto_nachr.
    types: begin of t_fistl_auth,
             fistl type fm_fictr,
             augrp type fm_authgrc,
           end of t_fistl_auth.

    types: begin of t_bukrs_auth,
             bukrs type bukrs,
           end of t_bukrs_auth.

    data: ls_fistl_auth type t_fistl_auth,
          ls_bukrs_auth type t_bukrs_auth,
          lt_fistl_auth type standard table of t_fistl_auth,
          lt_bukrs_auth type standard table of  t_bukrs_auth.

    data:
          lv_subrc             type n.             "Subrc
    field-symbols: <fs_dto> type zfi_f_dto_nachr.


    loop at ct_dto_nachr assigning <fs_dto>.
      ls_fistl_auth-fistl = <fs_dto>-fistl.
* Finanzstelle und Ber.gruppe stimmen überein
      ls_fistl_auth-augrp = <fs_dto>-fistl.
      ls_bukrs_auth-bukrs =  <fs_dto>-bukrs.
      append ls_fistl_auth to lt_fistl_auth.
      append ls_bukrs_auth to lt_bukrs_auth.
    endloop.

    sort lt_fistl_auth by  fistl.
    delete adjacent duplicates from lt_fistl_auth.

    sort lt_bukrs_auth by  bukrs.
    delete adjacent duplicates from lt_bukrs_auth.

    loop at lt_bukrs_auth into ls_bukrs_auth.
* Company Code-Beleg:
      authority-check object 'F_BKPF_BUK'
       id 'ACTVT' field c_auth_activ
       id 'BUKRS' field ls_bukrs_auth-bukrs.

      if sy-subrc ne 0.
        delete ct_dto_nachr where bukrs = ls_bukrs_auth-bukrs.
      endif.
    endloop.

* 5-dimensionale Prüfung auf HMS-Kontierungen
    if 1 = 2.
      authority-check object 'Z_FICA_TRG'
        id 'FM_AUTHACT' field c_auth_activ
        id 'FM_FIKRS'   field c_fikrs
        id 'FM_AUTHGRF' dummy
        id 'FM_AUTHGRC' field ls_fistl_auth-augrp
        id 'FM_AUTHGRP' dummy
        id 'FM_AUTHGRM' dummy
        id 'FM_GRP_FAR' dummy.
    endif.


    loop at lt_fistl_auth into ls_fistl_auth.
      clear lv_subrc.
      call function 'Z_CHECK_FICA_TRG'
        exporting
          activity          = c_auth_activ     "aktuell auf 03
          fm_area           = c_fikrs          "1000
          fm_fmfctr_authgrp = ls_fistl_auth-augrp
*         fm_fipex_authgrp  = lv_fm_fipex_authgrp
*         FM_MEASURE_AUTHGRP       = LS_AUTH_GRP_HHP
*         FM_FAREA_AUTHGRP  =
        importing
          ex_subrc          = lv_subrc.

      if lv_subrc ne 0.
        delete ct_dto_nachr where fistl = ls_fistl_auth-fistl.
      endif.
    endloop.
  endmethod.


  METHOD constructor.

    SELECT herk fehlernr FROM zfi_cu_bn_ftext INTO TABLE gt_fnr_z WHERE herk = 'Z'.

    SELECT herk fehlernr FROM zfi_cu_bn_ftext INTO TABLE gt_fnr_a WHERE herk = 'A'.

    SELECT herk fehlernr FROM zfi_cu_bn_ftext INTO TABLE gt_fnr_r WHERE herk = 'R'.


  ENDMETHOD.


  METHOD create_pdf.

    DATA:
      ls_nachr         TYPE zfi_f_dto_nachr,
      ls_ftext         TYPE zfi_cu_bn_ftext,
      ls_aktion        TYPE zfi_cu_bn_aktion,
      ls_empf          TYPE zfi_cu_bn_empf,
      lt_empf          TYPE TABLE OF zfi_cu_bn_empf,
      l_lauf           TYPE string,
      l_laufd          TYPE laufd,
      l_laufi          TYPE laufi,
      l_beleg          TYPE char20,
      l_betrag         TYPE char20,
      l_text           TYPE string,
      l_line           TYPE zfi_bn_bodyline,
      ls_bndaten       TYPE zfi_sf_bndaten,
      lv_postfach_id   TYPE string,
      lv_kennzeichen   TYPE string,
      lv_produkt       TYPE string,
      lv_timestamp     TYPE timestampl,
      lv_ts_char       TYPE char100,
      lv_msgv1         TYPE string,
      ls_zom_addr_attr TYPE zom_addr_attr,
      ls_zom_addr_out  TYPE zom_addr_out.

    CONSTANTS c_formname TYPE tdsfname VALUE 'ZFI_BENACHRICHTIGUNG'.

    DATA: it_otf   TYPE STANDARD TABLE OF itcoo,
*          it_docs  TYPE STANDARD TABLE OF docs,
          it_lines TYPE STANDARD TABLE OF tline.

    DATA: st_job_output_info      TYPE ssfcrescl,
          st_document_output_info TYPE ssfcrespd,
          st_job_output_options   TYPE ssfcresop,
          st_output_options       TYPE ssfcompop,
          st_control_parameters   TYPE ssfctrlop,
          l_len_in                TYPE so_obj_len,
          l_language              TYPE sflangu VALUE 'D',
          l_e_devtype             TYPE rspoptype,
          l_bin_filesize          TYPE i,
          l_name                  TYPE string,
          l_path                  TYPE string,
          l_fullpath              TYPE string,
          l_filter                TYPE string,
          l_uact                  TYPE i,
          lo_guiobj               TYPE REF TO cl_gui_frontend_services,
          l_filename              TYPE string,
          l_fm_name               TYPE rs38l_fnam.

************************************************************
    IF i_nachr IS INITIAL.
      RETURN.
    ENDIF.

    ls_nachr = i_nachr.
    ls_bndaten-nachr = i_nachr.

******************* NUR zum Test ***************************
**    DATA  l_nachricht TYPE zfi_bn_nachricht.
**    SELECT SINGLE * FROM zfi_bn_nachricht INTO l_nachricht
**                    WHERE herk = 'Z'.
**    MOVE-CORRESPONDING l_nachricht TO ls_nachr.
************************************************************

    IF i_ftext IS INITIAL AND
       i_aktion IS INITIAL AND
       i_empf  IS INITIAL.

*   Steuerungsdaten zur Benachrichtigung lesen
      get_bn_steuerung(
        EXPORTING
          i_herk     = ls_nachr-herk
          i_fehlernr = ls_nachr-fehlernr
          i_fistl    = ls_nachr-fistl
          i_uname    = ls_nachr-uname
        IMPORTING
         e_ftext    = ls_ftext
         e_aktion   = ls_aktion
         e_empf     = ls_empf ).

    ELSE.
*     In den Strukturen müssen minimal nur bestimmte Felder gefüllt sein!
*     empf-kzbnart, empf-smtp_addr, empf-empf, aktion-kzkom, ftext-fehlertext,
      ls_ftext  = i_ftext.
      ls_aktion = i_aktion.
      ls_empf   = i_empf.
    ENDIF.

    IF ls_ftext IS INITIAL OR
       ls_aktion IS INITIAL OR
       ls_aktion-kzkom <> 'B' OR
       ls_empf IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_empf-kzbnart <> 'D'.  "Service-BW
      RETURN.
    ENDIF.

***********************************************************************

*Subject
*   Zahllauf
    IF ls_nachr-herk = c_hk_zl.
      l_text = 'im Zahllauf'.
      CONCATENATE ls_nachr-laufd '/' ls_nachr-laufi INTO l_lauf.
      CONCATENATE 'Benachrichtigung zum Fehler:' ls_nachr-fehlernr l_text l_lauf
                  INTO ls_bndaten-subject SEPARATED BY ' '.
*   Abbuchung
    ELSEIF ls_nachr-herk = c_hk_ab.
      l_text = 'im Kontoauszug'.
      CONCATENATE 'Abbuchung' l_text ls_nachr-kukey
                  INTO ls_bndaten-subject SEPARATED BY ' '.
*   Rückläufer
    ELSE. "C_HK_RL
      l_text = 'im Kontoauszug'.
      CONCATENATE 'Rückbuchung' l_text ls_nachr-kukey
                  INTO ls_bndaten-subject SEPARATED BY ' '.

    ENDIF.

* Body
*   Zahllauf
    IF ls_nachr-herk = c_hk_zl.
      CONCATENATE ls_nachr-laufd '/' ls_nachr-laufi INTO l_lauf.
      CONCATENATE ls_nachr-bukrs '/' ls_nachr-gjahr '/' ls_nachr-belnr INTO l_beleg.
      CONCATENATE ls_nachr-fehlernr 'Zahllauf:'
                  l_lauf 'Beleg:' l_beleg INTO l_line SEPARATED BY ' '.
      APPEND l_line TO ls_bndaten-t_lines.
      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      l_line = 'Fehlertext:'.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      IF ls_ftext-alterntext IS NOT INITIAL.
        l_text = ls_ftext-alterntext.
      ELSE.
        l_text = ls_ftext-fehlertext.
      ENDIF.
      MOVE l_text TO l_line.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile
      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      l_line = c_auto1.
      APPEND l_line TO ls_bndaten-t_lines.
      CONCATENATE c_auto2 c_auto3 INTO l_line SEPARATED BY ' '.
      APPEND l_line TO ls_bndaten-t_lines.

*   Abbuchung
    ELSEIF ls_nachr-herk = c_hk_ab.
      CONCATENATE 'Abbuchung im elektronischen Kontoauszug der Bank' ls_nachr-hbkid
                  'mit Kurzschlüssel' ls_nachr-kukey
                  INTO l_line SEPARATED BY ' '.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      l_line = 'Meldung:'.
      APPEND l_line TO ls_bndaten-t_lines.

      IF ls_ftext-alterntext IS NOT INITIAL.
        l_text = ls_ftext-alterntext.
      ELSE.
        l_text = ls_ftext-fehlertext.
      ENDIF.
      MOVE l_text TO l_line.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      CONCATENATE ls_nachr-bukrs '/' ls_nachr-gjahr '/' ls_nachr-belnr INTO l_beleg.
      l_betrag = ls_nachr-wrbtr.
      CONDENSE l_betrag.
      TRANSLATE l_betrag USING '.,'.
      CONCATENATE 'Zahlungsbeleg' ls_nachr-vblnr
                  'mit Betrag' l_betrag 'EUR'
                  'wurde auf die Allgemeine Anordnung:' l_beleg 'gebucht.'
                  INTO l_line SEPARATED BY ' '.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      l_line = 'Bitte überprüfen Sie die Höhe des Zahlungsbetrages.'.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      l_line = c_auto1.
      APPEND l_line TO ls_bndaten-t_lines.
      CONCATENATE c_auto2 c_auto3 INTO l_line SEPARATED BY ' '.
      APPEND l_line TO ls_bndaten-t_lines.

*   Rückläufer
    ELSEIF ls_nachr-herk = c_hk_rl.
      CONCATENATE ls_nachr-bukrs '/' ls_nachr-gjahr '/' ls_nachr-belnr INTO l_beleg.
      CONCATENATE 'Rückbuchung im elektronischen Kontoauszug der Bank' ls_nachr-hbkid
                  'mit Kurzschlüssel' ls_nachr-kukey
                  INTO l_line SEPARATED BY ' '.
      APPEND l_line TO ls_bndaten-t_lines.

      CONCATENATE 'Zahlungsbeleg' ls_nachr-vblnr
                  'Ausgleichsrücknahme im Beleg:' l_beleg
                  INTO l_line SEPARATED BY ' '.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      l_line = 'Meldung:'.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      IF ls_ftext-alterntext IS NOT INITIAL.
        l_text = ls_ftext-alterntext.
      ELSE.
        l_text = ls_ftext-fehlertext.
      ENDIF.
      MOVE l_text TO l_line.
      APPEND l_line TO ls_bndaten-t_lines.

      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile
      CLEAR l_line.
      APPEND l_line TO ls_bndaten-t_lines. "Leerzeile

      l_line = c_auto1.
      APPEND l_line TO ls_bndaten-t_lines.
      CONCATENATE c_auto2 c_auto3 INTO l_line SEPARATED BY ' '.
      APPEND l_line TO ls_bndaten-t_lines.

    ELSE.

    ENDIF.

* Receiver - Dateiname ?
    ls_bndaten-receiver = ls_empf-nutzer.

* Sender
    ls_bndaten-sender = c_auto4.


**********************************************************************************
*   Dateiname
*    CONCATENATE ls_nachr-fistl '_' sy-datum '_' sy-uzeit '.pdf' INTO g_filename.

* Ermittlung Postfach ID
    ls_zom_addr_attr-zpgsbr     =  ls_nachr-fistl(4).
    ls_zom_addr_attr-acc_fcentr =  ls_nachr-fistl.

    CALL FUNCTION 'Z_OM_FIND_ADDRESS'
      EXPORTING
        is_addr_attr            = ls_zom_addr_attr
      IMPORTING
        es_addr_out             = ls_zom_addr_out
      EXCEPTIONS
        is_addr_attr_is_initial = 1
        invalid_addr_type       = 2
        no_object_found         = 3
        OTHERS                  = 4.
    IF sy-subrc EQ 0.
      lv_postfach_id   = ls_zom_addr_out-zzbepo.
    ELSE.
      lv_postfach_id   = ls_nachr-fistl.
    ENDIF.

* Produktzuordnung setzen
    CASE ls_nachr-herk.
      WHEN 'A'.
        lv_produkt = c_herk_a_produkt.
      WHEN 'Z'.
        lv_produkt = c_herk_z_produkt.
      WHEN 'R'.
        lv_produkt = c_herk_r_produkt.
    ENDCASE.

* Kennzeichen
    IF NOT ls_nachr-xblnr IS INITIAL.
      lv_kennzeichen = ls_nachr-xblnr.
    ELSE.
      CONCATENATE ls_nachr-belnr ls_nachr-gjahr
      INTO lv_kennzeichen.
    ENDIF.
    CONDENSE lv_kennzeichen NO-GAPS.

* Zeitstempel
    GET TIME STAMP FIELD lv_timestamp.

    WRITE lv_timestamp TIME ZONE sy-zonlo TO lv_ts_char DECIMALS 4.

    REPLACE ALL OCCURRENCES OF REGEX `\D` IN lv_ts_char WITH ``.
    CONDENSE lv_ts_char NO-GAPS.

* Aufbau Dateiname
    CONCATENATE lv_postfach_id '_' lv_produkt '_' lv_kennzeichen '_' lv_ts_char '.pdf' INTO g_filename.
    TRANSLATE g_filename USING '/-*-:-?-"-<->-|-'.  "unerlaubte Zeichen in Minus umwandeln IN-2031029

*   SF-Formular füllen
    CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
      EXPORTING
        i_language    = l_language
        i_application = 'SAPDEFAULT'
      IMPORTING
        e_devtype     = l_e_devtype.
    st_output_options-tdprinter = l_e_devtype.
    st_control_parameters-no_dialog = 'X'.
    st_control_parameters-getotf = 'X'.

*   Funktionsbaustein zum SF bestimmen
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = c_formname
      IMPORTING
        fm_name            = l_fm_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*  SF aufrufen
    CALL FUNCTION l_fm_name
      EXPORTING
        control_parameters   = st_control_parameters
        output_options       = st_output_options
        l_f_bndaten          = ls_bndaten
        l_f_filename         = g_filename
      IMPORTING
        document_output_info = st_document_output_info
        job_output_info      = st_job_output_info
        job_output_options   = st_job_output_options
      EXCEPTIONS
        formatting_error     = 1
        internal_error       = 2
        send_error           = 3
        user_canceled        = 4
        OTHERS               = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   OTF in PDF konvertieren
    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
      IMPORTING
        bin_filesize          = l_bin_filesize
      TABLES
        otf                   = st_job_output_info-otfdata
        lines                 = it_lines
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        err_bad_otf           = 4
        OTHERS                = 5.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   Ausgabefile- Zeilen (-> WRITE_PDF)
    gt_lines_out = it_lines.

    e_nachr = i_nachr.
    e_nachr-versdat = sy-datum.
    e_nachr-verstim = sy-uzeit.
    e_nachr-kzbnart = 'D'.
    e_nachr-empf    = g_filename.

  ENDMETHOD.


  METHOD create_za_pdf.

    DATA:
      lv_text          TYPE string,
      lv_line          TYPE zfi_bn_bodyline,
      lv_formid        TYPE zfi_ea_formid,
      lv_formname      TYPE tdsfname,
      lv_language      TYPE sflangu VALUE 'D',
      lv_covtitle      TYPE syprtxt,
      lv_e_devtype     TYPE rspoptype,
      lv_bin_filesize  TYPE i,
      lv_name          TYPE string,
      lv_path          TYPE string,
      lv_fullpath      TYPE string,
      lv_filter        TYPE string,
      lv_uact          TYPE i,
      lv_filename      TYPE string,
      lv_postfach_id   TYPE string,
      lv_kennzeichen   TYPE string,
      lv_timestamp     TYPE timestampl,
      lv_ts_char       TYPE char100,
      lv_ts_string     TYPE string,
      lv_fm_name       TYPE rs38l_fnam,
      lv_mess          TYPE string,
      lv_file_appl     TYPE string,
      lv_msgv1         TYPE string,
      lv_beleg         TYPE string,
      lv_temp          TYPE char100,
      lv_ltext         TYPE ltext_003t,
      lv_init_posnr    TYPE posnr,
      ls_outputparams  TYPE sfpoutputparams,
      ls_docparams     TYPE sfpdocparams,
      ls_pdf_file      TYPE fpformoutput,
      ls_fp_data       TYPE zfi_fk_za_fp_data,
      lt_zfi_fk_fo_tb  TYPE zfi_fk_fo_tb_t,
      ls_zom_addr_attr TYPE zom_addr_attr,
      ls_zom_addr_out  TYPE zom_addr_out,
      ls_nachr         TYPE zfi_f_dto_nachr,
      ls_ftext         TYPE zfi_cu_bn_ftext,
      ls_aktion        TYPE zfi_cu_bn_aktion,
      ls_empf          TYPE zfi_cu_bn_empf,
      lt_empf          TYPE TABLE OF zfi_cu_bn_empf,
      ls_bndaten       TYPE zfi_sf_bndaten,
      ls_febep         TYPE febep,
      ls_febre         TYPE febre,
      lt_febre         TYPE STANDARD TABLE OF febre,
      lv_text1         TYPE fibl_txt50.

* Ratenverarbeitung SD
    "js DATA: lv_anordnungsbetrag      TYPE vbak-zz_021,
    "js       ls_raten_summen          TYPE zst_raten_summen,
    "js       ls_faellige_raten_summen TYPE zst_raten_summen,
    DATA: lv_zahlungseingaenge TYPE wrbtr,
          lv_saldo             TYPE wrbtr,
          ls_druck             TYPE zfi_bn_druck,
          ls_adrc              TYPE adrc,
          ls_vbak              TYPE vbak,
          lv_adrnr             TYPE adrnr,
          ls_vbap_first        TYPE vbap,
          "         ls_zsachbearbpkh         TYPE zsachbearbpkh,
          ls_comwa             TYPE vbco6,
          lt_vbfa_tab          TYPE TABLE OF vbfas,
          ls_vbfas             TYPE vbfas.

*************************************************************


*    IF i_nachr IS INITIAL.
*      RETURN.
*    ENDIF.

    ls_druck = i_druck.
    IF ls_druck IS INITIAL.
      ls_druck-dest     = 'PDF1'.
      ls_druck-nodialog = c_true.
      ls_druck-getpdf   = c_true.
    ENDIF.

*
    ls_nachr         = i_nachr.
    ls_bndaten-nachr = i_nachr.

    IF NOT i_empf IS INITIAL.
* manuelle Nachbearbeitung
      ls_empf          = i_empf.
    ELSE.
* automatische Verarbeitung
* - Steuerungsdaten zur Benachrichtigung lesen
      get_bn_steuerung(
        EXPORTING
          i_herk     = ls_nachr-herk
          i_fehlernr = ls_nachr-fehlernr
          i_fistl    = ls_nachr-fistl
          i_uname    = ls_nachr-uname
        IMPORTING
          e_empf     = ls_empf ).
    ENDIF.

    CASE ls_empf-kzbnart.
      WHEN 'D' OR 'P'.   "Dateierstellung oder Drucken
        ls_zom_addr_attr-zpgsbr     =  i_nachr-fistl(4).
        ls_zom_addr_attr-acc_fcentr =  i_nachr-fistl.

        CALL FUNCTION 'Z_OM_FIND_ADDRESS'
          EXPORTING
            is_addr_attr            = ls_zom_addr_attr
          IMPORTING
            es_addr_out             = ls_zom_addr_out
          EXCEPTIONS
            is_addr_attr_is_initial = 1
            invalid_addr_type       = 2
            no_object_found         = 3
            OTHERS                  = 4.
        IF sy-subrc EQ 0.
          lv_postfach_id   = ls_zom_addr_out-zzbepo.
        ENDIF.
      WHEN OTHERS  .    "Dateierstellung - Service-BW
    ENDCASE.

***********************************************************************
* Übergabestruktur füllen

* Anschrift Dienststellenadresse
    ls_fp_data-addr_z1 = ls_zom_addr_out-line0.
    ls_fp_data-addr_z2 = ls_zom_addr_out-line1.
    ls_fp_data-addr_z3 = ls_zom_addr_out-line2.
    ls_fp_data-addr_z4 = ls_zom_addr_out-line3.
    ls_fp_data-addr_z5 = ls_zom_addr_out-line4.
    ls_fp_data-addr_z6 = ls_zom_addr_out-line5.

    ls_fp_data-fehlernummer = ls_nachr-fehlernr.
* Zahlungsanzeige (Bericht 555)
    IF ls_nachr-fehlernr EQ '200' OR ls_nachr-fehlernr EQ '210'.

      lv_formname = c_555_formname.
      lv_formid   = '555'.

      ls_fp_data-variant          = c_variant.
      ls_fp_data-waers            = i_nachr-waers.
      ls_fp_data-budat            = i_nachr-budat.
      ls_fp_data-hhjahr           = i_nachr-budat(4).
      ls_fp_data-belnr            = i_nachr-belnr.
      ls_fp_data-bukrs            = i_nachr-bukrs.

      DATA(betrag) = COND #( WHEN ls_nachr-fehlernr EQ '200' THEN i_nachr-wrbtr ELSE i_nachr-wrbtr * -1  ).
* Betrag
      WRITE abs( betrag )  TO lv_temp CURRENCY i_nachr-waers LEFT-JUSTIFIED.

* Vorzeichen verschieben
      CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
        CHANGING
          value = lv_temp.

      CONCATENATE lv_temp i_nachr-waers INTO ls_fp_data-betrag SEPARATED BY space.

* Buchungstag
      "WRITE i_nachr-psobt TO lv_temp LEFT-JUSTIFIED.
      WRITE i_nachr-budat TO lv_temp LEFT-JUSTIFIED.
      ls_fp_data-buchungstag      = lv_temp.
* Tagesdatum
      WRITE sy-datlo TO lv_temp LEFT-JUSTIFIED.
      ls_fp_data-tagesdatum      = lv_temp.

* Aktenzeichen
      ls_fp_data-aktenzeichen     = i_nachr-zz_011.

* Kassenzeichen
      ls_fp_data-kassenzeichen    = i_nachr-xblnr.

* Belegreferenz Belegnummer Buchungskreis und Haushaltsjahr
      CONCATENATE i_nachr-belnr '/' i_nachr-bukrs '/' ls_fp_data-hhjahr
        INTO ls_fp_data-belegreferenz SEPARATED BY space.

* Buchungsnumer Belegnummer / Buchungskreis
      CONCATENATE i_nachr-vblnr '/' i_nachr-bukrs
        INTO ls_fp_data-buchungsnummer SEPARATED BY space.

* Finanzposition
      WRITE i_nachr-fipos TO lv_temp LEFT-JUSTIFIED.

      ls_fp_data-finanzposition   = lv_temp.

* Dienststelle
      ls_fp_data-dienststellen_nr = i_nachr-fistl(4).
      ls_fp_data-fistl            = i_nachr-fistl.
* Art der Forderung
      SELECT text1 FROM t047n INTO lv_temp
        UP TO 1 ROWS
        WHERE spras EQ 'D'
          AND bukrs EQ i_nachr-bukrs
          AND maber EQ i_nachr-maber.
      ENDSELECT.
      IF sy-subrc EQ 0.
        SHIFT lv_temp LEFT DELETING LEADING space.
        ls_fp_data-art_forderung    = lv_temp.
      ENDIF.
      CONCATENATE i_nachr-maber ls_fp_data-art_forderung INTO
        ls_fp_data-art_forderung SEPARATED BY space.

* Zahlart
      SELECT ltext FROM t003t INTO lv_ltext
         UP TO 1 ROWS
         WHERE spras EQ sy-langu
           AND blart EQ i_nachr-blart.
      ENDSELECT.
      CONCATENATE i_nachr-blart lv_ltext INTO ls_fp_data-zahlart SEPARATED BY space.

* Bankdaten aus dem Kontoauszug
      IF NOT i_nachr-kukey IS INITIAL.
        SELECT bukrs, hbkid, hktid FROM febko
                    WHERE kukey = @i_nachr-kukey
          ORDER BY bukrs, hbkid, hktid
          INTO @DATA(ls_febko_fields)
          UP TO 1 ROWS.
        ENDSELECT.
        IF sy-subrc EQ 0.
* Zahlweg -> Text zur KontoID
          SELECT SINGLE text1 FROM t012t INTO lv_text1
            WHERE spras EQ sy-langu
              AND bukrs EQ ls_febko_fields-bukrs
              AND hbkid EQ ls_febko_fields-hbkid
              AND hktid EQ ls_febko_fields-hktid.
          IF sy-subrc EQ 0.
            ls_fp_data-zahlweg        = lv_text1.
          ENDIF.
        ENDIF.

        SELECT SINGLE * FROM febep INTO ls_febep
          WHERE kukey EQ i_nachr-kukey
            AND esnum EQ i_nachr-esnum.
        IF sy-subrc EQ 0.
* Zeitbuchnummer Belegnummer / Buchungskreis
          CONCATENATE ls_febep-belnr '/ T999'
            INTO ls_fp_data-zeitbuchnummer SEPARATED BY space.

* IBAN
          ls_fp_data-iban           = ls_febep-piban.
* BIC
          ls_fp_data-bic            = ls_febep-paswi.

* Kontonummer
          ls_fp_data-konto_nr       = ls_febep-pakto.

          IF ls_fp_data-konto_nr IS INITIAL.
            ls_fp_data-konto_nr = ls_febep-piban+12.
          ENDIF.

*Bankleitzahl
          IF ls_fp_data-iban IS INITIAL.
            ls_fp_data-blz = ls_febep-pablz.
          ENDIF.


*Einzahlungstag
          WRITE ls_febep-valut TO lv_temp LEFT-JUSTIFIED.
          ls_fp_data-einzahlungstag = lv_temp.

* Einzahler
          ls_fp_data-einzahler      = ls_febep-partn.

* Debitor Name, Str, Ort
          SELECT adrnr, xcpdk FROM kna1
                 WHERE kunnr EQ @i_nachr-kunnr
          INTO @DATA(ls_kna1).
          ENDSELECT.
          IF sy-subrc EQ 0.
            IF ls_kna1-xcpdk EQ 'X'.
              SELECT name1, name2, name3, name4, stras, pstlz, ort01 FROM bsec
                WHERE bukrs EQ @i_nachr-bukrs
                  AND belnr EQ @i_nachr-belnr
                  AND gjahr EQ @i_nachr-gjahr
                  AND buzei EQ @i_nachr-buzei
              INTO @DATA(ls_bsec).
              ENDSELECT.
              IF sy-subrc EQ 0.
                CONCATENATE ls_bsec-name1 ls_bsec-name2 ls_bsec-name3 ls_bsec-name4
                       INTO ls_fp_data-debitor SEPARATED BY space.

                ls_fp_data-str_hnr = ls_bsec-stras.

                CONCATENATE ls_bsec-pstlz ',' INTO ls_fp_data-plz_ort.
                CONCATENATE ls_fp_data-plz_ort ls_bsec-ort01 INTO ls_fp_data-plz_ort
                  SEPARATED BY space.
              ENDIF.
            ELSE.
              SELECT name1, street, house_num1, post_code1, city1 FROM adrc
*                WHERE addrnumber EQ @lv_adrnr       "Störung: 2000000753, INT3_024-02-07
                 WHERE addrnumber EQ @ls_kna1-adrnr  "Störung: 2000000753, INT3_024-02-07
              INTO @DATA(ls_anschrift)
               UP TO 1 ROWS.
              ENDSELECT.
              IF sy-subrc EQ 0.
                ls_fp_data-debitor = ls_anschrift-name1.
                IF i_nachr-blart = 'AD'.
                  ls_fp_data-debitor = |AZA { ls_anschrift-name1 }|.
                ENDIF.

                CONCATENATE ls_anschrift-street ls_anschrift-house_num1 INTO ls_fp_data-str_hnr
                  SEPARATED BY space.

                CONCATENATE ls_anschrift-post_code1 ',' INTO ls_fp_data-plz_ort.
                CONCATENATE ls_fp_data-plz_ort ls_anschrift-city1 INTO ls_fp_data-plz_ort
                  SEPARATED BY space.
              ENDIF.
            ENDIF.
          ENDIF.

* Verwendungszweck lesen
          CLEAR lt_febre.
          SELECT * FROM febre INTO TABLE lt_febre
                 WHERE kukey = i_nachr-kukey
                   AND esnum = i_nachr-esnum
                  ORDER BY PRIMARY KEY.
          IF sy-subrc EQ 0.
            DELETE lt_febre WHERE vwezw+0(1) = '+' AND vwezw+5(1) = '+'.
          ENDIF.

          LOOP AT lt_febre INTO ls_febre.
            IF ls_febre-vwezw+0(1) = '+' AND ls_febre-vwezw+5(1) = '+'.
            ELSE.
              CONCATENATE ls_fp_data-verwendungszweck ls_febre-vwezw INTO ls_fp_data-verwendungszweck SEPARATED BY space.
            ENDIF.
* Bankreferenz
            IF ls_febre-vwezw CS '+BREF+'.
              ls_fp_data-bankreferenz  = ls_febre-vwezw+6(59).
            ENDIF.
          ENDLOOP.
          SHIFT ls_fp_data-verwendungszweck LEFT DELETING LEADING space. "2025-11-14 js Führende Leerzeichen entfernen
        ENDIF.
      ENDIF.

* Duplikat (für alle nachträglichen Ausgaben)
      IF NOT i_druck IS INITIAL.
        ls_fp_data-duplikat  = c_true.
      ENDIF.
* Has been sent already?
      IF i_nachr-versdat IS NOT INITIAL.
        ls_fp_data-already_sent = abap_true.
      ENDIF.

* Kennzeichen für Dateiname
      IF NOT ls_fp_data-kassenzeichen IS INITIAL.
        lv_kennzeichen = ls_fp_data-kassenzeichen.
      ELSE.
        CONCATENATE i_nachr-belnr ls_fp_data-hhjahr
          INTO lv_kennzeichen.
        CONDENSE lv_kennzeichen.
      ENDIF.

* Zeitstempel
      GET TIME STAMP FIELD lv_timestamp.

      WRITE lv_timestamp TIME ZONE sy-zonlo TO lv_ts_char DECIMALS 4.

      REPLACE ALL OCCURRENCES OF REGEX `\D` IN lv_ts_char WITH ``.
      CONDENSE lv_ts_char.

      IF lv_postfach_id IS INITIAL.
        lv_postfach_id = ls_fp_data-fistl.
      ENDIF.

*   Datei
*     CONCATENATE lv_postfach_id '_' c_555_produkt '_' lv_kennzeichen '_' lv_ts_char '.pdf' INTO g_filename.
      CONCATENATE lv_postfach_id '_' c_555_produkt '_' ls_fp_data-aktenzeichen '_' lv_kennzeichen '_' lv_ts_char '.pdf' INTO g_filename. "2025-14-11 js Aktenzeichen im Dateinamen ergänzt
      TRANSLATE g_filename USING '/-*-:-?-"-<->-|-'.  "unerlaubte Zeichen in Minus umwandeln IN-2031029

      ls_fp_data-dateiname = g_filename.

*     CONCATENATE c_555_produkt ls_lv_kennzeichen sy-uname sy-datum sy-uzeit
      CONCATENATE c_555_produkt ls_fp_data-aktenzeichen lv_kennzeichen sy-uname sy-datum sy-uzeit "2025-14-11 js Aktenzeichen im Dateinamen ergänzt
       INTO lv_covtitle SEPARATED BY '_'.
**********************************************************************************************************
* Zahlungmitteilung PKH (Bericht 539)
    ELSEIF ls_nachr-fehlernr EQ '201' OR ls_nachr-fehlernr EQ '211'.

* Formularname und Formname
      lv_formname = c_539_formname.
      lv_formid   = '539'.

* Auftrag aus Faktura ermitteln
      ls_comwa-vbeln = i_nachr-vbeln.

      CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION'
        EXPORTING
          comwa         = ls_comwa
          nachfolger    = ' '
          vorgaenger    = 'X'
          v_stufen      = '50'
          no_acc_doc    = 'X'
        TABLES
          vbfa_tab      = lt_vbfa_tab
        EXCEPTIONS
          no_vbfa       = 1
          no_vbuk_found = 2
          OTHERS        = 3.
      IF sy-subrc EQ 0.
        READ TABLE lt_vbfa_tab INTO ls_vbfas
          WITH KEY vbeln   = i_nachr-vbeln
                   vbtyp_v = 'L'.
        IF sy-subrc EQ 0.
          ls_vbak-vbeln = ls_vbfas-vbelv.
        ENDIF.
      ENDIF.


      SELECT * FROM vbak INTO ls_vbak
                              UP TO 1 ROWS
                              WHERE vbeln   EQ ls_vbak-vbeln.
      ENDSELECT.
      IF sy-subrc EQ 0.
* Rechnungsempfänger
        SELECT adrnr FROM vbpa INTO lv_adrnr
                                UP TO 1 ROWS
                               WHERE vbeln EQ ls_vbak-vbeln
                                 AND posnr EQ lv_init_posnr
                                 AND parvw EQ 'RE'.
        ENDSELECT.
        IF sy-subrc EQ 0.
          IF NOT lv_adrnr IS INITIAL.
* Standard Adressdaten des Rechnungsempfängers beschaffen
            "js          ls_adrc = zcl_db_address=>get_adrc( EXPORTING iv_addrnumber = lv_adrnr ).

*Formatierte Adressdaten des Rechnungsempfängers beschaffen
            IF NOT ls_adrc IS INITIAL.
              "js           ls_fp_data-recipient = zcl_db_sd_formulare=>get_adressdaten_person( is_adrc = ls_adrc ).
*                                                                                  iv_mit_anrede = space ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF NOT ls_vbak-vbeln IS INITIAL.
*===== Erste Kundenauftragsposition ermitteln
        "js     ls_vbap_first = zcl_db_sd_sales_order=>get_position_first( iv_vbeln = ls_vbak-vbeln ).

*===== Finanzstelle ermitteln
        "js     ls_fp_data-fistl = zcl_db_fi_fm_fmzuob=>get_fistl(
        "js       EXPORTING iv_vbeln = ls_vbap_first-vbeln
        "js                 iv_posnr = ls_vbap_first-posnr
        "js     ).

*===== Sachbearbeiter ermitteln
        "js     ls_zsachbearbpkh = zcl_db_zsachbearbpkh=>get_record( EXPORTING iv_vkorg = ls_vbak-vkorg iv_vkbur = ls_vbak-vkbur ).

        "js     CONCATENATE ls_zsachbearbpkh-anrede ls_zsachbearbpkh-name INTO ls_fp_data-sachbearbeiter SEPARATED BY space.
        "js     ls_fp_data-sb_telnr = ls_zsachbearbpkh-telnr.
        "js     ls_fp_data-sb_telfx = ls_zsachbearbpkh-telfx.

* Verwendungszweck
        "js     CONCATENATE ls_vbak-zz_004 ' ' ls_vbak-zz_008 INTO ls_fp_data-verwendungszweck RESPECTING BLANKS.
* Anordnungsbetrag
        "js     lv_anordnungsbetrag = ls_vbak-zz_021 - ls_vbak-zz_022.
        "js     WRITE lv_anordnungsbetrag TO lv_temp CURRENCY ls_vbak-waerk LEFT-JUSTIFIED.
        CONCATENATE lv_temp ls_vbak-waerk INTO ls_fp_data-anordnungsbetrag SEPARATED BY space.
* Raten
        "js     ls_raten_summen = zcl_db_sd_formulare=>get_ratensummen( iv_vbeln = ls_vbak-vbeln ).
        "js     WRITE ls_raten_summen-fakwr TO lv_temp CURRENCY ls_raten_summen-waers LEFT-JUSTIFIED.

        "js     CONCATENATE lv_temp ls_raten_summen-waers INTO ls_fp_data-geforderte_leistung SEPARATED BY space.
        "js     ls_fp_data-anzahl_raten = ls_raten_summen-anzahl.

* Ratenänderungen
        "js     ls_fp_data-ratenaenderungen = zcl_db_sd_formulare=>get_ratenaenderungen( iv_vbeln = ls_vbak-vbeln ).

        "js     ls_faellige_raten_summen = zcl_db_sd_formulare=>get_ratensummen(
        "js                                   iv_vbeln    = ls_vbak-vbeln
        "js                                   iv_stichtag = sy-datum
        "js                                ).
        "js     WRITE ls_faellige_raten_summen-fakwr TO lv_temp CURRENCY ls_faellige_raten_summen-waers LEFT-JUSTIFIED.
        "js     CONCATENATE lv_temp ls_faellige_raten_summen-waers INTO ls_fp_data-faellige_raten SEPARATED BY space.

        "js     ls_fp_data-anzahl_faellige_raten = ls_faellige_raten_summen-anzahl.

* Zahlungseingänge
        "js     lv_zahlungseingaenge = zcl_db_sd_formulare=>get_zahlungseingaenge( iv_vbeln = ls_vbak-vbeln ).
        WRITE lv_zahlungseingaenge TO lv_temp CURRENCY ls_vbak-waerk LEFT-JUSTIFIED.
        CONCATENATE lv_temp ls_vbak-waerk INTO ls_fp_data-geleistete_zahlungen SEPARATED BY space.


        "js     lv_saldo = lv_zahlungseingaenge - ls_faellige_raten_summen-fakwr.

* Saldo
        WRITE lv_saldo TO lv_temp CURRENCY ls_vbak-waerk NO-SIGN LEFT-JUSTIFIED .

        CONCATENATE lv_temp ls_vbak-waerk INTO ls_fp_data-saldo SEPARATED BY space.

        IF lv_saldo GE 0.
* Überzahlung
          ls_fp_data-saldo_art = 'U'.
        ELSE.
* Rückstand
          ls_fp_data-saldo_art = 'R'.
        ENDIF.
* Falls keine Postfach ID ermittelt werden kann
        ls_fp_data-fistl = ls_nachr-fistl.

* Adresse Absender
        "js     ls_fp_data-adresse_lok = zcl_sd_formulare=>get_adressdaten_lok( ).

* OFD Headersatz für Druckdienstleister (nur bei Erstverarbeitung mit Dateierstellung)
        IF i_druck IS INITIAL.
          ls_fp_data-belnr = i_nachr-vblnr.
          IF NOT ls_fp_data-belnr IS INITIAL.
            "js         ls_fp_data-ofd_header = zcl_db_sd_formulare=>get_ofd_headersatz(
            "js                                                       iv_form_id     = lv_formid
            "js                                                       is_adrc        = ls_adrc
            "js                                                       iv_belnr       = ls_fp_data-belnr
            "js                                                       ).
          ENDIF.
        ENDIF.
      ENDIF.
**********************************************************************************************************
* Duplikat (für alle nachträglichen Ausgaben)
      IF NOT i_druck IS INITIAL.
        ls_fp_data-duplikat  = c_true.
      ENDIF.

* Tagesdatum
      WRITE sy-datlo TO lv_temp LEFT-JUSTIFIED.
      ls_fp_data-tagesdatum      = lv_temp.

* Geschäftszeichen
      "js   ls_fp_data-geschaeftszeichen = ls_vbak-zz_001.

* Kassenzeichen
      ls_fp_data-kassenzeichen    = ls_vbak-xblnr.

* Kennzeichen für Dateiname
      IF NOT ls_fp_data-kassenzeichen IS INITIAL.
        lv_kennzeichen = ls_fp_data-kassenzeichen.
      ELSE.
        CONCATENATE i_nachr-belnr ls_fp_data-hhjahr
          INTO lv_kennzeichen.
        CONDENSE lv_kennzeichen.
      ENDIF.

* Zeitstempel
      GET TIME STAMP FIELD lv_timestamp.

      WRITE lv_timestamp TIME ZONE sy-zonlo TO lv_ts_char DECIMALS 4.
      REPLACE ALL OCCURRENCES OF REGEX `\D` IN lv_ts_char WITH ``.
      CONDENSE lv_ts_char.

      IF lv_postfach_id IS INITIAL.
        lv_postfach_id = ls_fp_data-fistl.
      ENDIF.

      CONCATENATE c_539_produkt '_' lv_kennzeichen sy-uname sy-datum sy-uzeit
       INTO ls_outputparams-covtitle SEPARATED BY '_'.

*   Datei
      CONCATENATE lv_postfach_id '_' c_539_produkt '_' lv_kennzeichen '_' lv_ts_char '.pdf' INTO g_filename.
      TRANSLATE g_filename USING '/-*-:-?-"-<->-|-'.  "unerlaubte Zeichen in Minus umwandeln IN-2031029

      ls_fp_data-dateiname = g_filename.

      CONCATENATE c_539_produkt lv_kennzeichen sy-uname sy-datum sy-uzeit
       INTO lv_covtitle SEPARATED BY '_'.
    ELSE.
      RETURN.
    ENDIF.
**********************************************************************************


* Textelemente lesen
    SELECT * FROM zfi_fk_fo_tb INTO TABLE lt_zfi_fk_fo_tb
        WHERE formid  EQ lv_formid
          AND variant EQ c_variant
      ORDER BY PRIMARY KEY.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
**********************************************************************************

*   Funktionsbaustein zum Adobe Formular bestimmen
    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = lv_formname
          IMPORTING
            e_funcname = lv_fm_name.

      CATCH cx_fp_api_repository
      cx_fp_api_usage
      cx_fp_api_internal.
    ENDTRY.

* Ausgabeparameter setzen

    ls_outputparams-preview   = ls_druck-preview.
    ls_outputparams-covtitle  = lv_covtitle.
    ls_outputparams-dest      = ls_druck-dest.
    ls_outputparams-nodialog  = ls_druck-nodialog.
    ls_outputparams-reqnew    = 'X'.
    ls_outputparams-reqfinal  = 'X'.
    ls_outputparams-reqimm    = 'X'.

    IF ls_empf-kzbnart EQ 'D'.
      ls_outputparams-getpdf   = ls_druck-getpdf.
    ELSE.
      CLEAR ls_outputparams-getpdf.
    ENDIF.

* Neuen Ausgabejob öffnen
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

* Dokumentparameter setzen
    ls_docparams-langu     = 'D'.
    ls_docparams-country   = 'DE'.

* Formularaufruf
    CALL FUNCTION lv_fm_name
      EXPORTING
        /1bcdwb/docparams  = ls_docparams
        es_fp_data         = ls_fp_data
        et_zfi_fk_fo_tb    = lt_zfi_fk_fo_tb
      IMPORTING
        /1bcdwb/formoutput = ls_pdf_file
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

*   Ausgabejob schliessen
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    IF i_druck-preview IS INITIAL.
      IF ls_empf-kzbnart = 'P'.
        IF i_druck IS INITIAL.
          e_nachr = i_nachr.
          e_nachr-versdat = sy-datum.
          e_nachr-verstim = sy-uzeit.
          e_nachr-kzbnart = 'P'.
          e_nachr-empf    = g_filename.
        ENDIF.
        MESSAGE i029(z_fi_nachr).
      ENDIF.
    ENDIF.

*********** Dateiablage **************************
    IF ls_empf-kzbnart EQ 'D'.

      lv_file_appl = g_filename.

      CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
        EXPORTING
          logical_path               = c_log_path_s_bw
          file_name                  = lv_file_appl
        IMPORTING
          file_name_with_path        = lv_file_appl
        EXCEPTIONS
          path_not_found             = 1
          missing_parameter          = 2
          operating_system_not_found = 3
          file_system_not_found      = 4
          OTHERS                     = 5.
      IF sy-subrc NE 0.
        lv_msgv1 = lv_file_appl.
        RAISE EXCEPTION TYPE zcx_fi_gen
          EXPORTING
            textid   = zcx_fi_gen=>file_open_error
            filename = lv_msgv1.
      ELSE.
*  Speichern PDF-Datei auf Applikationsserver
        OPEN DATASET lv_file_appl FOR OUTPUT IN BINARY MODE.                "Datei wird geöffnet
        IF sy-subrc NE 0.
          lv_msgv1 = lv_file_appl.
          RAISE EXCEPTION TYPE zcx_fi_gen
            EXPORTING
              textid   = zcx_fi_gen=>file_open_error
              filename = lv_msgv1.
        ENDIF.
        TRY.
            TRANSFER ls_pdf_file-pdf TO lv_file_appl.                       "Inhalt wird in Datei geschrieben
          CATCH cx_root.
            DELETE DATASET lv_file_appl.
            lv_msgv1 = lv_file_appl.
            RAISE EXCEPTION TYPE zcx_fi_gen
              EXPORTING
                textid   = zcx_fi_gen=>err_write_file
                filename = lv_msgv1.
        ENDTRY.


        CLOSE DATASET lv_file_appl.                                          "Datei wird geschlossen

* Verarbeitungskennzeichen setzen
        IF i_druck IS INITIAL.
          e_nachr = i_nachr.
          e_nachr-versdat = sy-datum.
          e_nachr-verstim = sy-uzeit.
          e_nachr-kzbnart = 'D'.
          e_nachr-empf    = g_filename.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD display_prot.

    DATA: l_bn_selprot  TYPE zfi_f_bn_selection,
          lo_salv_nachr TYPE REF TO zcl_fi_bn_nachr_salv,
          l_vari        TYPE slis_vari.

    FIELD-SYMBOLS <t_data> TYPE STANDARD TABLE.

    IF i_t_data_ref IS NOT BOUND.
      e_anzbn = lines( gt_rbnkey ).
      IF e_anzbn = 0.
        RETURN.
      ELSE.
        l_bn_selprot-r_bnkey = gt_rbnkey.
      ENDIF.
    ELSE.
      ASSIGN i_t_data_ref->* TO <t_data>.
      e_anzbn = lines( <t_data> ).
      IF e_anzbn = 0.
        RETURN.
      ENDIF.
    ENDIF.

    CASE i_herk.
      WHEN 'Z'.
        l_vari = c_layout_zl.
      WHEN 'R'.
        l_vari = c_layout_rl.
      WHEN 'A'.
        l_vari = c_layout_ab.
      WHEN 'Y'.
        l_vari = c_layout_za.
      WHEN OTHERS.
        l_vari = c_layout_std.
    ENDCASE.

    l_bn_selprot-herk = i_herk.

    CREATE OBJECT lo_salv_nachr.

    TRY.

        IF i_t_data_ref IS NOT BOUND.

          lo_salv_nachr->display(
            EXPORTING
              i_vari      = l_vari
              i_selection = l_bn_selprot ).
        ELSE.

          lo_salv_nachr->display(
            EXPORTING
              i_vari      = l_vari
              i_t_data_ref = i_t_data_ref ).
        ENDIF.

      CATCH cx_salv_not_found.

    ENDTRY.

  ENDMETHOD.


  METHOD email_versenden.


    DATA: send_request  TYPE REF TO cl_bcs,
          document      TYPE REF TO cl_document_bcs,
          lr_sender     TYPE REF TO if_sender_bcs,   "e-mail address
*          lr_sender     TYPE REF TO cl_sapuser_bcs,  "USER
          recipient     TYPE REF TO if_recipient_bcs,
          bcs_exception TYPE REF TO cx_bcs.

    DATA: l_sender     TYPE ad_smtpadr, "E-Mail-Adresse
          l_empfaenger TYPE ad_smtpadr, "E-Mail-Adresse
          lt_bodytxt   TYPE bcsy_text,  "Texttabelle
          ls_bodytxt   TYPE soli,
          l_dateiname  TYPE char_50,    "Name Dateianhang .pdf oder .txt
          l_filename   TYPE dxlpath,    "Name und Pfad des Protokollfiles
          l_subject    TYPE so_obj_des, "Betreff
          sent_to_all  TYPE os_boolean,
          l_lenght     TYPE so_obj_len,
          l            TYPE i,
          ls_nachr     TYPE zfi_f_bn_nachr,
          ls_ftext     TYPE zfi_cu_bn_ftext,
          ls_aktion    TYPE zfi_cu_bn_aktion,
          ls_empf      TYPE zfi_cu_bn_empf,
          lt_empf      TYPE TABLE OF zfi_cu_bn_empf,
          l_lauf       type char15,
          l_beleg      type char20.


* Customizing lesen
    ls_nachr = i_nachr.

*   CU Fehlertext
    SELECT SINGLE * FROM zfi_cu_bn_ftext INTO ls_ftext
             WHERE herk = ls_nachr-herk
             AND   fehlernr = ls_nachr-fehlernr.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*   CU Aktion
    SELECT SINGLE * FROM zfi_cu_bn_aktion INTO ls_aktion
             WHERE herk = ls_nachr-herk
             AND   fehlernr = ls_nachr-fehlernr
             AND   kzkom = 'B'.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*   CU Empfänger
    SELECT * FROM zfi_cu_bn_empf
             WHERE herk = @ls_nachr-herk
             AND  fistl = @ls_nachr-fistl
             AND smtp_addr IS NOT INITIAL
             INTO TABLE @lt_empf.

    IF ls_nachr-fistl  <> ls_aktion-fistl AND
       ls_aktion-fistl <> '*'.
      RETURN.
    ENDIF.


*** Dateiname des Protokolls
**    l_filename = i_filename.
**
*** Anhang-Name
**    IF i_attach_pdf IS NOT INITIAL OR i_attach_txt IS NOT INITIAL.
**      l_dateiname = i_filename.
**    ENDIF.
**

* Body-Text

    CONCATENATE ls_nachr-laufd '/' ls_nachr-laufi INTO l_lauf.
    CONCATENATE ls_nachr-bukrs '/' ls_nachr-gjahr '/' ls_nachr-belnr INTO l_beleg.
    CONCATENATE 'Fehler:' ls_nachr-fehlernr 'Zahllauf:'
                l_lauf l_beleg INTO ls_bodytxt SEPARATED BY ' '.
    l = strlen( ls_bodytxt ).
    l_lenght = l_lenght + l.
    APPEND ls_bodytxt TO lt_bodytxt.

    CLEAR ls_bodytxt.
    APPEND ls_bodytxt TO lt_bodytxt.    "Leerzeile

    ls_bodytxt = 'Fehlermeldung:'.
    l = strlen( ls_bodytxt ).
    l_lenght = l_lenght + l.
    APPEND ls_bodytxt TO lt_bodytxt.

    CLEAR ls_bodytxt.
    APPEND ls_bodytxt TO lt_bodytxt.    "Leerzeile

    IF ls_ftext-alterntext IS NOT INITIAL.
      ls_bodytxt = ls_ftext-alterntext.
    ELSE.
      ls_bodytxt = ls_ftext-fehlertext.
    ENDIF.
*    CONCATENATE ':' ls_bodytxt INTO ls_bodytxt SEPARATED BY ' '.
    l = strlen( ls_bodytxt ).
    l_lenght = l_lenght + l.
    APPEND ls_bodytxt TO lt_bodytxt.

** Body-Gruß
*    CLEAR ls_bodytxt.
*    APPEND ls_bodytxt TO lt_bodytxt.    "Leerzeile
*    CLEAR ls_bodytxt.
*    APPEND ls_bodytxt TO lt_bodytxt.    "Leerzeile
*
*    ls_bodytxt = c_gruss.
*    l = strlen( ls_bodytxt ).
*    l_lenght = l_lenght + l.
*    APPEND ls_bodytxt TO lt_bodytxt.

*  Automatisch generierte Mail
    CLEAR ls_bodytxt.
    APPEND ls_bodytxt TO lt_bodytxt.    "Leerzeile
    CLEAR ls_bodytxt.
    APPEND ls_bodytxt TO lt_bodytxt.    "Leerzeile

    CONCATENATE c_auto1 c_auto2 c_auto3 INTO ls_bodytxt SEPARATED BY ' '.
    l = strlen( ls_bodytxt ).
    l_lenght = l_lenght + l.
    APPEND ls_bodytxt TO lt_bodytxt.

* Empfänger
    LOOP AT lt_empf INTO ls_empf.
      EXIT.
    ENDLOOP.
    IF ls_empf-smtp_addr IS NOT INITIAL.
      l_empfaenger = ls_empf-smtp_addr.
    ELSE.
      l_empfaenger = c_empf. "'ckrebs@dxc.com'. guenther.bosch@bitbw.bwl.de
    ENDIF.
* Sender
    l_sender =  c_sender.     "'ckrebs@csc.com'. falko.schroeter@soprasteria.com

* Subjekt / Betreff
    CONCATENATE 'Fehler:' ls_nachr-fehlernr 'im Zahllauf' l_lauf
                INTO l_subject SEPARATED BY ' '.

    IF l_subject IS INITIAL.
      l_subject = c_subject_z.   "'Fehler im Zahllauf'.
    ENDIF.

**********************************************************************
    TRY.
*     -------- create persistent send request ------------------------
        send_request = cl_bcs=>create_persistent( ).
        IF send_request IS NOT BOUND.
          RAISE EXCEPTION TYPE cx_send_req_bcs.
        ENDIF.

*     --------- Maildokument mit Body und Betreff anlegen ------------
        document = cl_document_bcs=>create_document(
                        i_type    = 'RAW'
                        i_text    = lt_bodytxt     "Body
                        i_length  = l_lenght
                        i_subject = l_subject ).   " 'Betreff'
        IF document IS NOT BOUND.
          RAISE EXCEPTION TYPE cx_document_bcs.
        ENDIF.
**     --------- PDF Attachment anhängen ------------------------------
*        IF i_attach_pdf IS NOT INITIAL.
*          CALL METHOD document->add_attachment
*            EXPORTING
*              i_attachment_type    = 'PDF'
*              i_attachment_subject = l_dateiname     "PDF attachment
**               VALUE( I_ATTACHMENT_SIZE )
**               VALUE( I_ATTACHMENT_LANGUAGE )
**               VALUE( I_ATT_CONTENT_TEXT )
*              i_att_content_hex    = i_attach_pdf.    "data
**               VALUE( I_ATTACHMENT_HEADER )
*        ENDIF.
*
**     --------- TXT Attachment anhängen ------------------------------
*        IF i_attach_txt IS NOT INITIAL.
*          CALL METHOD document->add_attachment
*            EXPORTING
*              i_attachment_type    = 'TXT'
*              i_attachment_subject = l_dateiname     "TXT attachment
*              i_att_content_text   = i_attach_txt.    "data
*        ENDIF.
*


*     --------- add document to send request --------------------------
        CALL METHOD send_request->set_document( document ).

*     --------- set sender (e-mail address) ---------------------------
*       e-mail address:
        lr_sender  = cl_cam_address_bcs=>create_internet_address(
                          i_address_string = l_sender ).
**       aktueller User als Sender
*        lr_sender = cl_sapuser_bcs=>create( sy-uname ).
        CALL METHOD send_request->set_sender
          EXPORTING
            i_sender = lr_sender.

*     --------- add recipient (e-mail address) -----------------------
        recipient = cl_cam_address_bcs=>create_internet_address(
                          i_address_string = l_empfaenger ).
        CALL METHOD send_request->add_recipient
          EXPORTING
            i_recipient = recipient.
*          i_express   = 'X'.

*     --------- Setzen diverser Attribute ----------------------------
*     Einstellungen für die Statusrückmeldung
        send_request->set_status_attributes(
              EXPORTING
                i_requested_status = 'N' ).

*    Sofort Senden nicht warten
*    Bei großen Datenmengen nicht empfohlen
        send_request->set_send_immediately( 'X' ).

*     ---------- send document ---------------------------------------
        CALL METHOD send_request->send(
          EXPORTING
            i_with_error_screen = 'X'
          RECEIVING
            result              = sent_to_all ).
        IF sent_to_all = 'X'. " Alles OK
        ELSE.
*      Fehler
        ENDIF.

      CATCH cx_send_req_bcs cx_document_bcs cx_address_bcs cx_bcs  INTO bcs_exception.
        MESSAGE i865(so) WITH bcs_exception->error_type.

    ENDTRY.

    COMMIT WORK.


  ENDMETHOD.


  METHOD get_bn_steuerung.

*    DATA:
*      lt_aktion   TYPE TABLE OF zfi_cu_bn_aktion,
*      ls_aktion_a TYPE zfi_cu_bn_aktion,
*      ls_aktion_f TYPE zfi_cu_bn_aktion.
*      lt_empf     TYPE TABLE OF zfi_cu_bn_empf.


    CLEAR: e_ftext, e_aktion, e_empf.

*   Fehlertext
    SELECT SINGLE * FROM zfi_cu_bn_ftext INTO e_ftext
             WHERE herk = i_herk
             AND   fehlernr = i_fehlernr.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*   Aktion
    SELECT SINGLE * FROM zfi_cu_bn_aktion INTO e_aktion
             WHERE herk = i_herk
             AND   fehlernr = i_fehlernr
             AND   fistl = i_fistl
             AND   nutzer = i_uname.
    IF sy-subrc <> 0.

      SELECT SINGLE * FROM zfi_cu_bn_aktion INTO e_aktion
               WHERE herk = i_herk
               AND   fehlernr = i_fehlernr
               AND   fistl = i_fistl
               AND   nutzer = ''.
      IF sy-subrc <> 0.

        SELECT SINGLE * FROM zfi_cu_bn_aktion INTO e_aktion
                 WHERE herk = i_herk
                 AND   fehlernr = i_fehlernr
                 AND   fistl = '*'.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

      ENDIF.
    ENDIF.

*   Empfänger
    SELECT SINGLE * FROM zfi_cu_bn_empf INTO e_empf
             WHERE herk = i_herk
             AND  fistl = i_fistl
             AND  nutzer = i_uname.
    IF sy-subrc <> 0.
      SELECT SINGLE * FROM zfi_cu_bn_empf INTO e_empf
               WHERE herk = i_herk
               AND  fistl = i_fistl
               AND  nutzer = '*'.
      IF sy-subrc <> 0.
        SELECT SINGLE * FROM zfi_cu_bn_empf INTO e_empf
                 WHERE herk  = i_herk
                 AND  fistl  = '*'
                 AND  nutzer = '*'.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_dupl_nachr.

    DATA: lt_nachr        TYPE zfi_t_dto_nachr,
          ls_nachr        TYPE zfi_f_dto_nachr,
          ls_aktion       TYPE zfi_cu_bn_aktion,
          lt_bn_nachricht TYPE TABLE OF zfi_bn_nachricht,
          l_dat           TYPE dats.

    FIELD-SYMBOLS: <nachr> TYPE zfi_bn_nachricht.

    CLEAR e_kz_send.
    ls_nachr = i_nachr.

    SELECT SINGLE * FROM zfi_cu_bn_aktion INTO ls_aktion
             WHERE herk = ls_nachr-herk
             AND   fehlernr = ls_nachr-fehlernr
             AND   fistl = ls_nachr-fistl
             AND   kzkom = 'B'.
    IF sy-subrc <> 0.
      SELECT SINGLE * FROM zfi_cu_bn_aktion INTO ls_aktion
               WHERE herk = ls_nachr-herk
               AND   fehlernr = ls_nachr-fehlernr
               AND   fistl = '*'
               AND   kzkom = 'B'.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT * FROM zfi_bn_nachricht INTO TABLE lt_bn_nachricht
      WHERE herk     = ls_nachr-herk
      AND   fehlernr = ls_nachr-fehlernr
      AND   fistl    = ls_nachr-fistl
      AND   lifnr    = ls_nachr-lifnr
      AND   kunnr    = ls_nachr-kunnr
      AND   zbukr    = ls_nachr-zbukr
      AND   bukrs    = ls_nachr-bukrs
      AND   belnr    = ls_nachr-belnr
      AND   gjahr    = ls_nachr-gjahr
      AND   blart    = ls_nachr-blart
      AND   versdat  <= sy-datum
      AND   versdat  > 0.

    IF lines( lt_bn_nachricht ) = 0.
      e_kz_send = 'X'.
      RETURN.
    ENDIF.

    SORT lt_bn_nachricht BY versdat DESCENDING.
    LOOP AT lt_bn_nachricht ASSIGNING <nachr>.
      EXIT.
    ENDLOOP.
    l_dat = <nachr>-versdat + ls_aktion-bnwdh.

    IF l_dat <= sy-datum.
      e_kz_send = 'X'.
    ENDIF.

  ENDMETHOD.


  METHOD get_fistl.

    DATA: l_awitem TYPE fins_awitem,
          l_fistl  TYPE  fistl.

    IF c_bnbel-fistl IS INITIAL.

      IF c_bnbel-buzei IS NOT INITIAL.
        CONCATENATE '000' c_bnbel-buzei INTO l_awitem.

        SELECT SINGLE fistl FROM acdoca
                            WHERE rldnr = '0L'
                            AND  rbukrs = @c_bnbel-bukrs
                            AND  gjahr  = @c_bnbel-gjahr
                            AND  belnr  = @c_bnbel-belnr
                            AND  awitem = @l_awitem
                            INTO @l_fistl.
      ELSE.
        SELECT SINGLE fistl FROM acdoca
                            WHERE rldnr = '0L'
                            AND  rbukrs = @c_bnbel-bukrs
                            AND  gjahr  = @c_bnbel-gjahr
                            AND  belnr  = @c_bnbel-belnr
                            AND  fistl IS NOT INITIAL
                            INTO @l_fistl.
      ENDIF.

      IF sy-subrc = 0.
        c_bnbel-fistl = l_fistl.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  method get_fistl_fmfiit.
    types: begin of t_fistl,
             fistl type fistl,
           end of t_fistl.

    data: lt_fistl type table of t_fistl.
    data:
      l_fistl   type  fistl,
      l_fmbelnr type fm_belnr,
      l_vobelnr type fm_vobelnr,
      l_awkey  type awkey,
      l_awref type awref,
      l_awtyp type awtyp,
      l_aworg type aworg,
      l_fikrs type fikrs.

    data: lt_fmifiit type table of fmifiit.
    check c_bnbel-fistl is initial.

* In Header selbst taucht der Zahlungsbeleg nicht auf, aber die
* Forderung- der FB 'FMCT_READ_FMIFIHD' ist leider falsch
* als Richlinie gerade für SD-Beleg ...
* gehen davon aus das Bukrs , Bel, gjahr und buzei auftauchen
*
select single
       awtyp
       awkey
       fikrs
  into ( l_AWTYP, l_AWKEY, l_FIKRS )
   from bkpf
  where bukrs = c_bnbel-bukrs
    and belnr =  c_bnbel-belnr
    and gjahr = c_bnbel-gjahr.

L_AWORG = l_awkey+10.
* das war da alte coding FMCT_READ_FMIFIHD
****IF I_AWTYP cs 'BKPF' or
****   i_Awtyp = 'FMPSO'.
****   L_AWORG = l_awkey+10.
****
**** elseif I_AWTYP = 'VBRK'.
****   L_AWORG = ' '.
**** else.
**** L_AWORG  = I_GJAHR.
****ENDIF.

   SELECT FMBELNR into l_FMBELNR  FROM FMIFIHD
        WHERE AWREF   = l_AWKEY(10)
          and AWORG   = L_AWORG
          and AWTYP   = l_AWTYP.

*    MOVE FMIFIHD-REFBN   TO l_FIBELNR.
   ENDSELECT.


 if i_zbeleg-belnr is not initial.
* welche Eigenschaften sollen ausgewertet werden
      select fistl from fmifiit into table lt_fistl
        where fmbelnr =  l_FMBELNR
          and wrttp = c_wt_57
          and gjahr  = c_bnbel-gjahr
          and bukrs =  c_bnbel-bukrs
          and vobukrs = i_zbeleg-bukrs
          and vogjahr = i_zbeleg-gjahr
          and vobelnr = i_zbeleg-belnr
          and kngjahr = c_bnbel-gjahr
          and knbelnr = c_bnbel-belnr
          and knbuzei = c_bnbel-buzei.
 else.
         select fistl from fmifiit into table lt_fistl
           where fmbelnr =  l_FMBELNR
          and wrttp = c_wt_54
          and gjahr  = c_bnbel-gjahr
          and bukrs =  c_bnbel-bukrs
          and kngjahr = c_bnbel-gjahr
          and knbelnr = c_bnbel-belnr
          and knbuzei = c_bnbel-buzei.
 endif.
*----------------------------------------------------
* über knbuzei müsste genau eine fistl herauskommen
*----------------------------------------------------
      if lines( lt_fistl ) = 1.
        loop at lt_fistl into l_fistl.
          c_bnbel-fistl = l_fistl.
        endloop .
      else.
*----------------------------------------------------
* falls nicht - wegen Werttyp Rechnung - Original und Abbau
* alles ok - solange eine Fistl
*----------------------------------------------------
        loop at lt_fistl into l_fistl.
          if c_bnbel-fistl is initial.
          c_bnbel-fistl = l_fistl.
          elseif c_bnbel-fistl = l_fistl.
          else.
*----------------------------------------------------
* hier neue Fistl
*----------------------------------------------------
            clear c_bnbel-fistl.
            exit.
          endif.
        endloop.
      endif.



  endmethod.


  METHOD get_instance.

    IF bn_appl IS INITIAL.
      CREATE OBJECT bn_appl.
    ENDIF.

    e_instance = bn_appl.
    r_instance = bn_appl.


  ENDMETHOD.


  method get_tdto_nachr.
    constants : c_off type xfeld value ' '.
    data: l_select_clause type string,
          l_where_clause  type string,
          l_from_clause   type string,
          l_and           type string.

    if i_selection is initial or i_selection-herk is initial.
      return.
    endif.

    l_select_clause = '*'.
    l_from_clause = 'zfi_bn_nachricht AS a'.

*   Herkunft
    concatenate l_where_clause l_and 'a~herk = i_selection-herk'
      into l_where_clause separated by space.
    l_and = 'and'.

*   Zahllauf
    if i_selection-laufd is not initial.
      concatenate l_where_clause l_and 'a~laufd = i_selection-laufd'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-laufi is not initial.
      concatenate l_where_clause l_and 'a~laufi = i_selection-laufi'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-zbukr is not initial.
      concatenate l_where_clause l_and 'a~zbukr = i_selection-zbukr'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.

*   ELKO
    if i_selection-hbkid is not initial.
      concatenate l_where_clause l_and 'a~hbkid = i_selection-hbkid'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-hktid is not initial.
      concatenate l_where_clause l_and 'a~hktid = i_selection-hktid'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-kukey is not initial.
      concatenate l_where_clause l_and 'a~kukey = i_selection-kukey'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-kukey is not initial and i_selection-esnum is not initial.
      concatenate l_where_clause l_and 'a~esnum = i_selection-esnum'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-vgext is not initial.
      concatenate l_where_clause l_and 'a~vgext = i_selection-vgext'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-vblnr is not initial.
      concatenate l_where_clause l_and 'a~vblnr = i_selection-vblnr'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.

*   Versanddaten
    if i_selection-versdat is not initial or
       i_selection-versdat_i is not initial.
      concatenate l_where_clause l_and 'a~versdat = i_selection-versdat'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.


    if i_selection-inaktiv is not initial and  i_selection-aktiv is not initial.
* keine zusätzliche Selektion
    elseif i_selection-inaktiv is not initial and i_selection-aktiv is initial.
      concatenate l_where_clause l_and 'a~inaktiv = i_selection-inaktiv'
        into l_where_clause separated by space.
      l_and = 'and'.
    elseif i_selection-inaktiv is initial and i_selection-aktiv is not initial.
      concatenate l_where_clause l_and 'a~inaktiv = c_off'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.

*   Ranges
    if i_selection-r_fnr is not initial.
      concatenate l_where_clause l_and 'a~fehlernr in i_selection-r_fnr'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_erfd is not initial.
      concatenate l_where_clause l_and 'a~erfdat in i_selection-r_erfd'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_uname is not initial.
      concatenate l_where_clause l_and 'a~uname in i_selection-r_uname'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_vname is not initial.
      concatenate l_where_clause l_and 'a~vname in i_selection-r_vname'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_lifnr is not initial.
      concatenate l_where_clause l_and 'a~lifnr in i_selection-r_lifnr'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_kunnr is not initial.
      concatenate l_where_clause l_and 'a~kunnr in i_selection-r_kunnr'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_fistl is not initial.
      concatenate l_where_clause l_and 'a~fistl in i_selection-r_fistl'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_versdat is not initial and
       i_selection-versdat is initial and
       i_selection-versdat_i is initial.
      concatenate l_where_clause l_and 'a~versdat in i_selection-r_versdat'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_kzbnart is not initial.
      concatenate l_where_clause l_and 'a~kzbnart in i_selection-r_kzbnart'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_empf is not initial.
      concatenate l_where_clause l_and 'a~empf in i_selection-r_empf'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_bnkey is not initial.
      concatenate l_where_clause l_and 'a~bnkey in i_selection-r_bnkey'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_belnr is not initial.
      concatenate l_where_clause l_and 'a~belnr in i_selection-r_belnr'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_bukrs is not initial.
      concatenate l_where_clause l_and 'a~bukrs in i_selection-r_bukrs'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.
    if i_selection-r_gjahr is not initial.
      concatenate l_where_clause l_and 'a~gjahr in i_selection-r_gjahr'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.

    if i_selection-r_xblnr is not initial.
      concatenate l_where_clause l_and 'a~xblnr in i_selection-r_xblnr'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.


    if i_selection-r_blart is not initial.
      concatenate l_where_clause l_and 'a~blart in i_selection-r_blart'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.

    if i_selection-r_fipos is not initial.
      concatenate l_where_clause l_and 'a~fipos in i_selection-r_fipos'
        into l_where_clause separated by space.
      l_and = 'and'.
    endif.


*   Selektion
    select (l_select_clause) into corresponding fields of table e_tdto
      from (l_from_clause)
      where (l_where_clause).

  endmethod.


  METHOD get_zahlungsverw.

    DATA: l_febcl TYPE febcl,
          l_bkpf  TYPE bkpf.

    CLEAR e_postab.

*   Ausgleichsbeleg bzw. Zahlungsbeleg lesen
    LOOP AT i_t_febcl INTO l_febcl WHERE ( selfd = 'AUGBL'
                                        OR selfd = 'BELNR' )
                                   AND selvon NE '*'.

      SELECT * FROM bkpf INTO l_bkpf
        WHERE bukrs = i_bukrs
        AND   belnr = l_febcl-selvon
        ORDER BY PRIMARY KEY.
      ENDSELECT.

      EXIT.
    ENDLOOP.

    IF sy-subrc = 0 AND l_bkpf IS NOT INITIAL.
*     Ausgeglichene Belege suchen
      CALL FUNCTION 'Z_FI_GET_CLEARED_ITEMS'
        EXPORTING
          i_belnr  = l_bkpf-belnr
          i_bukrs  = l_bkpf-bukrs
          i_gjahr  = l_bkpf-gjahr
          i_bvorg  = l_bkpf-bvorg
        IMPORTING
          et_items = e_postab.
    ENDIF.

    LOOP AT e_postab ASSIGNING FIELD-SYMBOL(<ptab>).
      IF <ptab>-augbl = l_bkpf-belnr AND
         <ptab>-belnr = l_bkpf-belnr.
*       Ausgleichsbeleg/Zahlungsbeleg selbst löschen
*       es sollen nur die ausgeglichenen Belege übrig bleiben
        DELETE e_postab.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD mail_versenden.

    DATA:
      ls_nachr  TYPE zfi_f_dto_nachr,
      ls_ftext  TYPE zfi_cu_bn_ftext,
      ls_aktion TYPE zfi_cu_bn_aktion,
      lt_aktion TYPE TABLE OF zfi_cu_bn_aktion,
      ls_empf   TYPE zfi_cu_bn_empf,
      lt_empf   TYPE TABLE OF zfi_cu_bn_empf,
      l_lauf    TYPE string,
      l_laufd   TYPE laufd,
      l_laufi   TYPE laufi,
      l_elko    TYPE string,
      l_beleg   TYPE char20,
      l_betrag  TYPE char20,
      l_text    TYPE string.



*** to store data about mail containts
**    DATA: lt_pack_list TYPE STANDARD TABLE OF sopcklsti1,
**          ls_pack_list TYPE sopcklsti1.

* To store the data of mail body containt
    DATA: lt_mail_body TYPE STANDARD TABLE OF solisti1,
          ls_mail_body TYPE  solisti1.
* Receiver list
    DATA: lt_reclist TYPE STANDARD TABLE OF somlreci1,
          ls_reclist TYPE somlreci1.
* Mail Header Info
    DATA: ls_mail_header TYPE sodocchgi1.
* Variable to store the line in mail body
    DATA: lv_tab_lines TYPE sytabix.

************************************************************

    ls_nachr = i_nachr.

    IF i_nachr IS INITIAL.
      RETURN.
    ENDIF.

    IF i_ftext IS INITIAL AND
       i_aktion IS INITIAL AND
       i_empf  IS INITIAL.

*   Steuerungsdaten zur Benachrichtigung lesen
      get_bn_steuerung(
        EXPORTING
          i_herk     = ls_nachr-herk
          i_fehlernr = ls_nachr-fehlernr
          i_fistl    = ls_nachr-fistl
          i_uname    = ls_nachr-uname
        IMPORTING
         e_ftext    = ls_ftext
         e_aktion   = ls_aktion
         e_empf     = ls_empf ).

    ELSE.
*     In den Strukturen müssen minimal nur bestimmte Felder gefüllt sein!
*     empf-kzbnart, empf-smtp_addr, empf-empf, aktion-kzkom, ftext-fehlertext,
      ls_ftext  = i_ftext.
      ls_aktion = i_aktion.
      ls_empf   = i_empf.
    ENDIF.

    IF ls_ftext IS INITIAL OR
       ls_aktion IS INITIAL OR
       ls_aktion-kzkom <> 'B' OR
       ls_empf IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_empf-kzbnart <> 'I' AND ls_empf-kzbnart <> 'E'.
      RETURN.
    ENDIF.


***********************************************************************

* Header
    ls_mail_header-obj_name = 'MAIL'.
    ls_mail_header-obj_descr = 'Benachrichtigung'.

*Subject in Mail
*   Zahllauf
    IF ls_nachr-herk = c_hk_zl.
      l_text = 'im Zahllauf'.
      l_laufd = ls_nachr-laufd.
      l_laufi = ls_nachr-laufi.
      CONCATENATE 'Fehler:' ls_nachr-fehlernr l_text l_laufd '/' l_laufi
                  INTO ls_mail_header-obj_descr SEPARATED BY ' '.
*   Abbuchung
    ELSEIF ls_nachr-herk = c_hk_ab.
      l_text = 'im Kontoauszug'.
      CONCATENATE 'Kontoabbuchung' l_text ls_nachr-kukey
                  INTO ls_mail_header-obj_descr SEPARATED BY ' '.

*   Rückläufer
    ELSE. "C_HK_RL
      l_text = 'im Kontoauszug'.
      CONCATENATE 'Rückbuchung' l_text ls_nachr-kukey
                  INTO ls_mail_header-obj_descr SEPARATED BY ' '.
    ENDIF.

* Mail Body
*   Zahllauf
    IF ls_nachr-herk = c_hk_zl.
      CONCATENATE ls_nachr-laufd '/' ls_nachr-laufi INTO l_lauf.
      CONCATENATE ls_nachr-bukrs '/' ls_nachr-gjahr '/' ls_nachr-belnr INTO l_beleg.
      CONCATENATE 'Fehler:' ls_nachr-fehlernr 'Zahllauf:'
                  l_lauf 'Beleg:' l_beleg INTO ls_mail_body-line SEPARATED BY ' '.
      APPEND ls_mail_body TO lt_mail_body.
      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      ls_mail_body-line = 'Fehlermeldung:'.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      IF ls_ftext-alterntext IS NOT INITIAL.
        l_text = ls_ftext-alterntext.
      ELSE.
        l_text = ls_ftext-fehlertext.
      ENDIF.
      MOVE l_text TO ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile
      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      CONCATENATE c_auto1 c_auto2 c_auto3 INTO ls_mail_body-line SEPARATED BY ' '.
      APPEND ls_mail_body TO lt_mail_body.

*   Abbuchung
    ELSEIF ls_nachr-herk = c_hk_ab.
      CONCATENATE 'Abbuchung im elektronischen Kontoauszug der Bank' ls_nachr-hbkid
                  'mit Kurzschlüssel' ls_nachr-kukey
                  INTO ls_mail_body-line SEPARATED BY ' '.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      ls_mail_body-line = 'Meldung:'.
      APPEND ls_mail_body TO lt_mail_body.

      IF ls_ftext-alterntext IS NOT INITIAL.
        l_text = ls_ftext-alterntext.
      ELSE.
        l_text = ls_ftext-fehlertext.
      ENDIF.
      MOVE l_text TO ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      CONCATENATE ls_nachr-bukrs '/' ls_nachr-gjahr '/' ls_nachr-belnr INTO l_beleg.
      l_betrag = ls_nachr-wrbtr.
      CONDENSE l_betrag.
      TRANSLATE l_betrag USING '.,'.
      CONCATENATE 'Zahlungsbeleg' ls_nachr-vblnr
                  'mit Betrag' l_betrag 'EUR'
                  'wurde auf die Allgemeine Anordnung:' l_beleg 'gebucht.'
                  INTO ls_mail_body-line SEPARATED BY ' '.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      ls_mail_body-line = 'Bitte überprüfen Sie die Höhe des Zahlungsbetrages.'.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      CONCATENATE c_auto1 c_auto2 c_auto3 INTO ls_mail_body-line SEPARATED BY ' '.
      APPEND ls_mail_body TO lt_mail_body.

*   Rückläufer
    ELSE. "C_HK_R
      CONCATENATE 'Rückbuchung im elektronischen Kontoauszug der Bank' ls_nachr-hbkid
                  'mit Kurzschlüssel' ls_nachr-kukey
                  INTO ls_mail_body-line SEPARATED BY ' '.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      CONCATENATE ls_nachr-bukrs '/' ls_nachr-gjahr '/' ls_nachr-belnr INTO l_beleg.
      CONCATENATE 'Zahlungsbeleg' ls_nachr-vblnr
                  'Ausgleichsrücknahme im Beleg:' l_beleg
                  INTO ls_mail_body-line SEPARATED BY ' '.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      ls_mail_body-line = 'Meldung:'.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      IF ls_ftext-alterntext IS NOT INITIAL.
        l_text = ls_ftext-alterntext.
      ELSE.
        l_text = ls_ftext-fehlertext.
      ENDIF.
      MOVE l_text TO ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body.

      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile
      CLEAR ls_mail_body-line.
      APPEND ls_mail_body TO lt_mail_body. "Leerzeile

      CONCATENATE c_auto1 c_auto2 c_auto3 INTO ls_mail_body-line SEPARATED BY ' '.
      APPEND ls_mail_body TO lt_mail_body.

    ENDIF.


* Setting the size of mail document
    DESCRIBE TABLE lt_mail_body LINES lv_tab_lines.
    READ TABLE lt_mail_body INTO ls_mail_body INDEX lv_tab_lines.
    ls_mail_header-doc_size = ( lv_tab_lines - 1 ) * 255 + strlen( ls_mail_body-line ).

* Receiver - Empfänger
* Type U – Internet Email address B- SAP user
    IF ls_empf-smtp_addr IS NOT INITIAL AND ls_empf-kzbnart = 'E'.
      IF ls_empf-smtp_addr NA '@'.  "ungültige E-Mail-Adresse
        RETURN.
      ENDIF.
      ls_reclist-receiver = ls_empf-smtp_addr.
      ls_reclist-rec_type = 'U'.  "Externe E-Mail
    ELSEIF ls_empf-empf IS NOT INITIAL AND ls_empf-kzbnart = 'I'.
      ls_reclist-rec_type = 'B'.  "SAP-Workplace
      ls_reclist-receiver = ls_empf-empf.

*  kzbnart = 'B' gibt es nicht mehr
**    ELSEIF ls_empf-empf IS NOT INITIAL AND
**           ls_empf-smtp_addr IS NOT INITIAL AND ls_empf-kzbnart = 'B'.
**      ls_reclist-receiver = ls_empf-smtp_addr.
**      ls_reclist-rec_type = 'U'.  "Externe E-Mail

    ELSE.
      RETURN.  "smtp_addr leer/nutzer leer
    ENDIF.
    APPEND ls_reclist TO lt_reclist.

* Sending the document
    CALL FUNCTION 'SO_NEW_DOCUMENT_SEND_API1'
      EXPORTING
        document_data              = ls_mail_header
*       DOCUMENT_TYPE              = 'RAW'
*       PUT_IN_OUTBOX              = ' '
        commit_work                = 'X'
*       IP_ENCRYPT                 =
*       IP_SIGN                    =
*     IMPORTING
*       SENT_TO_ALL                =
*       NEW_OBJECT_ID              =
      TABLES
*       OBJECT_HEADER              =
        object_content             = lt_mail_body
*       CONTENTS_HEX               =
*       OBJECT_PARA                =
*       OBJECT_PARB                =
        receivers                  = lt_reclist
      EXCEPTIONS
        too_many_receivers         = 1
        document_not_sent          = 2
        document_type_not_exist    = 3
        operation_no_authorization = 4
        parameter_error            = 5
        x_error                    = 6
        enqueue_error              = 7
        OTHERS                     = 8.
    IF sy-subrc <> 0.
      e_error = sy-subrc.
      CASE sy-subrc.
        WHEN 1.
          l_text = 'too_many_receivers'.
        WHEN 2.
          l_text = 'document_not_sent'.
        WHEN 3.
          l_text = 'document_type_not_exist'.
        WHEN 4.
          l_text = 'operation_no_authorization'.
        WHEN 5.
          l_text = 'parameter_error'.
        WHEN 6.
          l_text = 'x_error'.
        WHEN 7.
          l_text = 'enqueue_error'.
        WHEN 8.
          l_text = 'other'.
      ENDCASE.
*      RAISE EXCEPTION TYPE zcx_fi_gen
*        EXPORTING
*          textid = zcx_fi_gen=>err_send_mail
*          mess   = l_text.

    ELSE.
      e_nachr = i_nachr.
      e_nachr-versdat = sy-datum.
      e_nachr-verstim = sy-uzeit.
      e_nachr-kzbnart = ls_empf-kzbnart.
      e_nachr-empf    = ls_reclist-receiver.
    ENDIF.

  ENDMETHOD.


  METHOD modify_nachricht.

    DATA: ls_bn_nachricht TYPE zfi_bn_nachricht,
          l_rbnkey        TYPE zfi_f_rbnkey.

    MOVE-CORRESPONDING i_nachr TO ls_bn_nachricht.

    MODIFY zfi_bn_nachricht FROM ls_bn_nachricht.
    IF sy-subrc NE 0.
*      RAISE EXCEPTION TYPE zcx_fi_gen
*        EXPORTING mess = 'Abbruch beim Ändern Tabelle ZFI_BN_NACHRICHT'.
    ENDIF.

*   Für Protokoll
    l_rbnkey-sign = 'I'.
    l_rbnkey-option = 'EQ'.
    l_rbnkey-low = ls_bn_nachricht-bnkey.
    APPEND l_rbnkey TO gt_rbnkey.

  ENDMETHOD.


  METHOD process_nachr1.

    DATA:
      ls_nachr  TYPE zfi_f_dto_nachr,
      ls_ftext  TYPE zfi_cu_bn_ftext,
      ls_aktion TYPE zfi_cu_bn_aktion,
      ls_empf   TYPE zfi_cu_bn_empf,
      l_error   TYPE syst_subrc.

    ls_nachr = i_nachr.

    IF i_nachr IS INITIAL OR
       i_ftext IS INITIAL OR
       i_aktion IS INITIAL OR
       i_empf  IS INITIAL.
      RETURN.
    ELSE.
*     In den Strukturen müssen minimal nur bestimmte Felder gefüllt sein!
*     empf-kzbnart, empf-smtp_addr, empf-empf, aktion-kzkom, ftext-fehlertext,
      ls_ftext  = i_ftext.
      ls_aktion = i_aktion.
      ls_empf   = i_empf.
    ENDIF.

    IF ls_nachr-fistl IS INITIAL.
      RAISE EXCEPTION TYPE zcx_fi_gen
        EXPORTING
          textid = zcx_fi_gen=>err_fistl.
*      RETURN.
    ENDIF.

    IF ls_empf-kzbnart = 'I' OR ls_empf-kzbnart = 'E'.

*     Benachrichtigung als e-Mail / SAP WP
      mail_versenden(
        EXPORTING
          i_nachr  = ls_nachr
          i_ftext  = ls_ftext
          i_aktion = ls_aktion
          i_empf   = ls_empf
        IMPORTING
          e_nachr = ls_nachr
          e_error = l_error ).

      IF l_error = 0 AND ls_nachr-versdat IS NOT INITIAL.
        modify_nachricht(
          EXPORTING
            i_nachr = ls_nachr ).
      ENDIF.

    ELSEIF  ls_empf-kzbnart = 'D' .

*     Benachrichtigung als PDF-Datei auf Applikationsserver ablegen
      create_pdf(
        EXPORTING
          i_nachr  = ls_nachr
          i_ftext  = ls_ftext
          i_aktion = ls_aktion
          i_empf   = ls_empf
        IMPORTING
         e_nachr = ls_nachr ).

      IF ls_nachr-kzbnart = 'D'.

        write_pdf(
          EXPORTING
            i_nachr  = ls_nachr
          IMPORTING
            e_nachr  = ls_nachr ).

        modify_nachricht(
          EXPORTING
            i_nachr = ls_nachr ).
      ENDIF.

    ENDIF.
    IF sy-subrc EQ 0 AND l_error EQ 0 AND ls_nachr-kzbnart NE 'P'.
      MESSAGE i029(z_fi_nachr).
    ENDIF.


  ENDMETHOD.


  METHOD write_pdf.

    DATA: lv_name          TYPE string,
          lv_file_appl     TYPE string,
          lv_postfach_id   TYPE string,
          lv_kennzeichen   TYPE string,
          lv_produkt       TYPE string,
          lv_timestamp     TYPE timestampl,
          lv_ts_char       TYPE char100,
          lv_msgv1         TYPE string,
          ls_zom_addr_attr TYPE zom_addr_attr,
          ls_zom_addr_out  TYPE zom_addr_out.

* Ermittlung Postfach ID
    ls_zom_addr_attr-zpgsbr     =  i_nachr-fistl(4).
    ls_zom_addr_attr-acc_fcentr =  i_nachr-fistl.

    CALL FUNCTION 'Z_OM_FIND_ADDRESS'
      EXPORTING
        is_addr_attr            = ls_zom_addr_attr
      IMPORTING
        es_addr_out             = ls_zom_addr_out
      EXCEPTIONS
        is_addr_attr_is_initial = 1
        invalid_addr_type       = 2
        no_object_found         = 3
        OTHERS                  = 4.
    IF sy-subrc EQ 0.
      lv_postfach_id   = ls_zom_addr_out-zzbepo.
    ELSE.
      lv_postfach_id   = i_nachr-fistl.
    ENDIF.

* Produktzuordnung setzen
    CASE i_nachr-herk.
      WHEN 'A'.
        lv_produkt = c_herk_a_produkt.
      WHEN 'Z'.
        lv_produkt = c_herk_z_produkt.
      WHEN 'R'.
        lv_produkt = c_herk_r_produkt.
    ENDCASE.

* Kennzeichen
    IF NOT i_nachr-xblnr IS INITIAL.
      lv_kennzeichen = i_nachr-xblnr.
    ELSE.
      CONCATENATE i_nachr-belnr i_nachr-gjahr
      INTO lv_kennzeichen.
    ENDIF.
    CONDENSE lv_kennzeichen NO-GAPS.

* Zeitstempel
    GET TIME STAMP FIELD lv_timestamp.

    WRITE lv_timestamp TIME ZONE sy-zonlo TO lv_ts_char DECIMALS 4.

    REPLACE ALL OCCURRENCES OF REGEX `\D` IN lv_ts_char WITH ``.
    CONDENSE lv_ts_char NO-GAPS.

* Aufbau Dateiname
    CONCATENATE lv_postfach_id '_' lv_produkt '_' lv_kennzeichen '_' lv_ts_char '.pdf' INTO g_filename.
    TRANSLATE g_filename USING '/-*-:-?-"-<->-|-'.  "unerlaubte Zeichen in Minus umwandeln IN-2031029

* Datei auf den server schreiben
    lv_file_appl = g_filename.

    CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
      EXPORTING
        logical_path               = c_log_path_s_bw
        file_name                  = lv_file_appl
      IMPORTING
        file_name_with_path        = lv_file_appl
      EXCEPTIONS
        path_not_found             = 1
        missing_parameter          = 2
        operating_system_not_found = 3
        file_system_not_found      = 4
        OTHERS                     = 5.
    IF sy-subrc NE 0.
      lv_msgv1 = lv_file_appl.
      RAISE EXCEPTION TYPE zcx_fi_gen
        EXPORTING
          textid   = zcx_fi_gen=>file_open_error
          filename = lv_msgv1.
    ELSE.
      OPEN DATASET lv_file_appl FOR OUTPUT IN BINARY MODE.
      IF sy-subrc <> 0.
        lv_msgv1 = lv_file_appl.
        RAISE EXCEPTION TYPE zcx_fi_gen
          EXPORTING
            textid   = zcx_fi_gen=>file_open_error
            filename = lv_msgv1.
*      RETURN.
      ENDIF.

      TRY.
*       Write the file to the application server
          LOOP AT gt_lines_out ASSIGNING FIELD-SYMBOL(<line>).
            TRANSFER <line> TO lv_file_appl.
          ENDLOOP.
        CATCH cx_root.
          DELETE DATASET lv_file_appl.
          lv_msgv1 = lv_file_appl.
          RAISE EXCEPTION TYPE zcx_fi_gen
            EXPORTING
              textid   = zcx_fi_gen=>err_write_file
              filename = lv_msgv1.
      ENDTRY.

*   close the dataset
      CLOSE DATASET lv_file_appl.

* verwendeter Dateiname zurückmelden
      e_nachr-empf    = g_filename.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
