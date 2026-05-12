FUNCTION Z_NSI_HHV_NEW_XBLNR.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"  EXPORTING
*"     VALUE(E_XBLNR) TYPE  XBLNR1
*"----------------------------------------------------------------------
*+28042004FS
*   Die Vergabe der laufenden Nummer im Kassenzeichen wird komplett
*   verändert. Es gibt jetzt nur noch ein Nummerkreisobjekt (Z_NSI_KZ10)
*   das buchungskreis- und jahresabhängig ist. Die Rechnerkassenzeichen
*   wurden von der LOK neu beantragt und liegen hintereinander im
*   Bereich von 1010 bis 1059 (also 50 Stück). Jedem Buchungskreis wird
*   entsprechend dem bisherigen Bedarf an Kassenzeichen ein zusammen-
*   hängender Bereich von Rechnerkennzeichen zugeordnet. So bekommt der
*   Bukrs 0200 mit ca. 40.000 Kassenzeichen im Jahr 2003 die RKZ 1012
*   bis 1013 (d.h. Nummern von 1012000000 bis 1013999999) und der Bukrs
*   0500 mit ca. 3.000.000 Kassenzeichen im Jahr 2003 die RKZ 1021
*   bis 1027 (d.h. Nummern von 1021000000 bis 1027999999).
*
*   In der Intervallvergabe sind die RKZ 1010 bis 1047 vergeben. Sollte
*   in einem Bukrs die Nummern innerhalb eines Jahres nicht ausreichen,
*   dann können aus den restlichen Rechnerkennzeichen weitere Bereiche
*   vergeben werden.


  data : l_n10_lfdnr(10)   type n,
         l_n1_prfziff(1)   type n,
         l_c2_jahr(2)      type c,
         l_NrKrsObj        like INRI-OBJECT,
         l_rc              like INRI-RETURNCODE,
         l_xblnr           like bkpf-xblnr,
         l_wa_checkkz      like znsi_check_kz,
         l_subrc           like sy-subrc.

  data:  l_range_nr        like INRI-NRRANGENR.

  l_NrKrsObj = 'Z_NSI_KZ10'.

* 15.12.2005FS
* Der Nummernzähler droht im Bukrs 0500 über zu laufen. Deshalb wird eine NR_RANGE_NR = 02
* angelegt und die Vergabe für 2005 und 0500 extra behandelt.
* Der Interval von 1038000000 bis 1039999999 wird vom Bukrs 0900 weggenommen.
*
  if i_bukrs = '0500' and i_gjahr = '2005'.
     l_range_nr = '02'.
    else.
     l_range_nr = '01'.
  endif.

* Abfordern einer neuen Nummer

  CALL FUNCTION 'NUMBER_GET_NEXT'
       EXPORTING
*            NR_RANGE_NR             = '01'              "-15122005FS
            NR_RANGE_NR             = l_range_nr         "+15122005FS
            OBJECT                  = l_NrKrsObj
            subobject               = i_bukrs
            toyear                  = i_gjahr
       IMPORTING
            NUMBER                  = l_n10_lfdnr
            RETURNCODE              = l_rc
       EXCEPTIONS
            INTERVAL_NOT_FOUND      = 01
            NUMBER_RANGE_NOT_INTERN = 02
            OBJECT_NOT_FOUND        = 03
            INTERVAL_OVERFLOW       = 04.


  if sy-subrc <> 0.

    l_subrc = sy-subrc.

    l_wa_checkkz-BUKRS    = i_bukrs.
    l_wa_checkkz-PNAME    = sy-repid.
    l_wa_checkkz-DATUM    = sy-datum.
    l_wa_checkkz-UZEIT    = sy-uzeit.
    l_wa_checkkz-UNAME    = sy-uname.
    l_wa_checkkz-TCODE    = sy-tcode.
    l_wa_checkkz-RC_SUBRC = sy-subrc.
    l_wa_checkkz-XBLNR    = l_n10_lfdnr.

    insert znsi_check_kz from l_wa_checkkz.

    CASE l_SUBRC.
      WHEN 01.
        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '201'
           WITH i_bukrs '01' i_gjahr.

      WHEN 02.
        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '202'
           WITH i_bukrs '01' i_gjahr.

      WHEN 03.
        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '203'
           WITH l_NrKrsObj.

      WHEN 04.
        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '204'
           WITH i_bukrs '01' i_gjahr.

      WHEN OTHERS.
        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '205'.

    ENDCASE.

  endif.

  if l_rc = '1'.

    MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'I' NUMBER '206'
            WITH i_bukrs l_NrKrsObj i_gjahr .

  endif.


  if i_gjahr < '2010'.

    concatenate '8' i_gjahr+3(1) into l_c2_jahr.

  else.

    l_c2_jahr = i_gjahr+2(2).

  endif.

  concatenate l_c2_jahr  l_n10_lfdnr  into l_xblnr.

  CALL FUNCTION 'Z_NSI_HHV_KZ_PRUEFZIFFER'
       EXPORTING
            P_XBLNR       = l_xblnr
       IMPORTING
            P_PRUEFZIFFER = l_n1_prfziff.


  concatenate l_xblnr l_n1_prfziff into e_xblnr.








*-28042004FS
*  data : l_n6_lfdnr(6)     type n,
*         l_n1_prfziff(1)   type n,
*         l_c2_jahr(2)      type c,
*         l_c2_intervall(2) type c,
*         l_c4_rechnerkz(4) type c,
*         l_NrKrsObj        like  INRI-OBJECT,
*         l_xblnr           like bkpf-xblnr,
*         l_wa_checkkz      like znsi_check_kz,
*         l_subrc           like sy-subrc.
*
*  data:  nr_info like nriv occurs 0 with header line.
*
** Bilden des Nummerkreisobjektes
*
**11.10.2003 FS
** Nummernvergabe werde ich auf Customizingtabelle umstellen, jedoch muß
** ich für den Bukrs 0500 wieder einmal ganz schnell noch eine Lösung *
** schaffen, denn er läuft im Z_NSI_KZ02 bald über
*
*if i_bukrs = '0500'.
*   l_c4_rechnerkz = '2305'.
*   l_NrKrsObj = 'Z_NSI_KZ04'.
*
*  CALL FUNCTION 'NUMBER_GET_NEXT'
*       EXPORTING
*            NR_RANGE_NR             = '01'
*            OBJECT                  = l_NrKrsObj
*            subobject               = i_bukrs
*       IMPORTING
*            NUMBER                  = l_n6_lfdnr
*       EXCEPTIONS
*            INTERVAL_NOT_FOUND      = 01
*            NUMBER_RANGE_NOT_INTERN = 02
*            OBJECT_NOT_FOUND        = 03
*            INTERVAL_OVERFLOW       = 04.
*
* else.
**
*
*  case i_bukrs.
*    when '0100'.
*      l_c4_rechnerkz = '0100'.
*    when '0200'.
*      l_c4_rechnerkz = '0102'.
*    when '0300'.
*      l_c4_rechnerkz = '0803'.
*    when '0400'.
*      l_c4_rechnerkz = '1104'.
*    when '0500'.
*      l_c4_rechnerkz = '2105'.
*    when '0600'.
*      l_c4_rechnerkz = '2806'.
*    when '0700'.
*      l_c4_rechnerkz = '3107'.
*    when '0800'.
*      l_c4_rechnerkz = '3608'.
*    when '0900'.
*      l_c4_rechnerkz = '4109'.
*    when '1000'.
*      l_c4_rechnerkz = '4810'.
*    when '1100'.
*      l_c4_rechnerkz = '0111'.
*    when '1400'.
*      l_c4_rechnerkz = '1814'.
*  endcase.
*
*  l_NrKrsObj = 'Z_NSI_KZ01'.
*
**Abrufen des Nummernstandes
*
*  call function 'NUMBER_GET_INFO'
*       EXPORTING
*            nr_range_nr = '01'
*            object      = l_NrKrsObj
*            subobject   = i_bukrs
*       IMPORTING
*            interval    = nr_info.
*
*  if nr_info-nrlevel = 999999.
*
**Neues Nummerkreisobjekt bilden
*
*    case i_bukrs.
*      when '0100'.
*        l_c4_rechnerkz = '0300'.
*      when '0200'.
*        l_c4_rechnerkz = '0302'.
*      when '0300'.
*        l_c4_rechnerkz = '0903'.
*      when '0400'.
*        l_c4_rechnerkz = '1204'.
*      when '0500'.
*        l_c4_rechnerkz = '2205'.
*      when '0600'.
*        l_c4_rechnerkz = '2906'.
*      when '0700'.
*        l_c4_rechnerkz = '3207'.
*      when '0800'.
*        l_c4_rechnerkz = '4008'.
*      when '0900'.
*        l_c4_rechnerkz = '4209'.
*      when '1000'.
*        l_c4_rechnerkz = '4910'.
*      when '1100'.
*        l_c4_rechnerkz = '0211'.
*      when '1400'.
*        l_c4_rechnerkz = '1914'.
*    endcase.
*
*    l_NrKrsObj = 'Z_NSI_KZ02'.
*
*  endif.
*
** Abfordern einer neuen Nummer
*
*  CALL FUNCTION 'NUMBER_GET_NEXT'
*       EXPORTING
*            NR_RANGE_NR             = '01'
*            OBJECT                  = l_NrKrsObj
*            subobject               = i_bukrs
*       IMPORTING
*            NUMBER                  = l_n6_lfdnr
*       EXCEPTIONS
*            INTERVAL_NOT_FOUND      = 01
*            NUMBER_RANGE_NOT_INTERN = 02
*            OBJECT_NOT_FOUND        = 03
*            INTERVAL_OVERFLOW       = 04.
*
*
*endif.
*
*  if sy-subrc <> 0.
*
*    l_subrc = sy-subrc.
*
*    l_wa_checkkz-BUKRS    = i_bukrs.
*    l_wa_checkkz-PNAME    = sy-repid.
*    l_wa_checkkz-DATUM    = sy-datum.
*    l_wa_checkkz-UZEIT    = sy-uzeit.
*    l_wa_checkkz-UNAME    = sy-uname.
*    l_wa_checkkz-TCODE    = sy-tcode.
*    l_wa_checkkz-RC_SUBRC = sy-subrc.
*    l_wa_checkkz-XBLNR    = l_n6_lfdnr.
*
*    insert znsi_check_kz from l_wa_checkkz.
*
*    CASE l_SUBRC.
*      WHEN 01.
*        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '201'
*           WITH i_bukrs '01' i_gjahr.
*
*      WHEN 02.
*        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '202'
*           WITH i_bukrs '01' i_gjahr.
*
*      WHEN 03.
*        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '203'
*           WITH l_NrKrsObj.
*
*      WHEN 04.
*        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '204'
*           WITH i_bukrs '01' i_gjahr.
*
*      WHEN OTHERS.
*        MESSAGE ID 'Z_NSI_HHVOLLZUG' TYPE 'E' NUMBER '205'.
*
*    ENDCASE.
*
*  endif.
*  if i_gjahr < '2010'.
*
*    concatenate '8' i_gjahr+3(1) into l_c2_jahr.
*
*  else.
*
*    l_c2_jahr = i_gjahr+2(2).
*
*  endif.
*
*  concatenate l_c2_jahr l_c4_rechnerkz l_n6_lfdnr  into l_xblnr.
*
*  CALL FUNCTION 'Z_NSI_HHV_KZ_PRUEFZIFFER'
*       EXPORTING
*            P_XBLNR       = l_xblnr
*       IMPORTING
*            P_PRUEFZIFFER = l_n1_prfziff.
*
*
*  concatenate l_xblnr l_n1_prfziff into e_xblnr.
*
*-28042004FS




ENDFUNCTION.
