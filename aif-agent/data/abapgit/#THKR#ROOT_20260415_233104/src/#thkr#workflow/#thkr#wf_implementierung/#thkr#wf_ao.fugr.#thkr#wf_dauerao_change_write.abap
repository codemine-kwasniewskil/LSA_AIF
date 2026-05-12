FUNCTION /THKR/WF_DAUERAO_CHANGE_WRITE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(F_PSO_OLD) LIKE  PSO02 STRUCTURE  PSO02
*"     REFERENCE(I_UNAME) TYPE  USERNAME
*"     REFERENCE(I_TCODE) TYPE  TCODE
*"  TABLES
*"      T_VBKPF_OLD STRUCTURE  VBKPF
*"      T_VBSEC_OLD STRUCTURE  VBSEC
*"      T_VBSEG_OLD STRUCTURE  VBSEG
*"      T_VBSET_OLD STRUCTURE  VBSET
*"      T_PSO_NEW STRUCTURE  PSO02
*"      T_VBKPF_NEW STRUCTURE  VBKPF
*"      T_VBSEC_NEW STRUCTURE  VBSEC
*"      T_VBSEG_NEW STRUCTURE  VBSEG
*"      T_VBSET_NEW STRUCTURE  VBSET
*"----------------------------------------------------------------------

  INCLUDE FF0KHCDT.

  DATA:      I LIKE SY-TABIX.
  DATA:  BEGIN OF DAUERAO_KEY_CHANGE,
             MANDT LIKE PSOKPF-MANDT,
             LOTZK LIKE PSOKPF-LOTKZ,
             BUKRS LIKE PSOKPF-BUKRS,
             ITABKEY LIKE PSOKPF-ITABKEY,
             GJAHR LIKE PSOKPF-GJAHR,
         END OF DAUERAO_KEY_CHANGE.

* Tables should only contain lines for one FI document!
*  READ TABLE T_VBKPF_OLD INDEX 1.
*  CHECK SY-SUBRC EQ 0.
  READ TABLE T_VBKPF_NEW INDEX 1.
  CHECK SY-SUBRC EQ 0.
  READ TABLE T_PSO_NEW INDEX 1.
  CHECK SY-SUBRC EQ 0.

* Objekt-Key fuellen:
  DAUERAO_KEY_CHANGE-MANDT = SY-MANDT.
  DAUERAO_KEY_CHANGE-LOTZK = T_PSO_NEW-LOTKZ.
  DAUERAO_KEY_CHANGE-BUKRS = T_VBKPF_NEW-AUSBK.
  DAUERAO_KEY_CHANGE-ITABKEY = T_PSO_NEW-ITABKEY.
  DAUERAO_KEY_CHANGE-GJAHR = T_VBKPF_NEW-GJAHR.
  OBJECTID  = DAUERAO_KEY_CHANGE.
  UTIME    = SY-UZEIT.
  UDATE    = SY-DATUM.
  USERNAME = I_UNAME.
  TCODE    = I_TCODE.

  PERFORM DAUERAO_CHANGE_FILL
      TABLES  T_VBKPF_NEW
              T_VBSEC_NEW
              T_VBSEG_NEW
              T_VBSET_NEW
              XPSOKPF
              XPSOSEC
              XPSOSEGA
              XPSOSEGS
              XPSOSEGK
              XPSOSEGD
              XPSOSET
      USING   T_PSO_NEW.
  CLEAR: UPD_PSOKPF, UPD_PSOSEC, UPD_PSOSEGS.
  PERFORM DAUERAO_CHANGE_FILL
      TABLES  T_VBKPF_OLD
              T_VBSEC_OLD
              T_VBSEG_OLD
              T_VBSET_OLD
              YPSOKPF
              YPSOSEC
              YPSOSEGA
              YPSOSEGS
              YPSOSEGK
              YPSOSEGD
              YPSOSET
      USING   F_PSO_OLD.

* Kennzeichen fuer Update oder Insert setzten:
  LOOP AT XPSOKPF.
    READ TABLE YPSOKPF INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
      XPSOKPF-KZ = 'I'.
      IF UPD_PSOKPF IS INITIAL.
        UPD_PSOKPF = XPSOKPF-KZ.
      ENDIF.
    ELSEIF XPSOKPF NE YPSOKPF.
      XPSOKPF-KZ = 'U'.
      UPD_PSOKPF = XPSOKPF-KZ.
    ELSE.
      CLEAR XPSOKPF-KZ.
    ENDIF.
    MODIFY XPSOKPF.
  ENDLOOP.
  LOOP AT XPSOSEGS.
*    IF XPSOSEGS-BUZEI NE SY-TABIX.                "Funktioniert hier
*      MESSAGE A105(FQ).                           "nicht
*    ENDIF.
    READ TABLE  YPSOSEGS INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
      XPSOSEGS-KZ = 'I'.
      IF UPD_PSOSEGS IS INITIAL.
        UPD_PSOSEGS = XPSOSEGS-KZ.
      ENDIF.
    ELSEIF XPSOSEGS NE YPSOSEGS.
      XPSOSEGS-KZ = 'U'.
      UPD_PSOSEGS = XPSOSEGS-KZ.
    ELSE.
      CLEAR XPSOSEGS-KZ.
    ENDIF.
    MODIFY XPSOSEGS.
  ENDLOOP.
  LOOP AT XPSOSEGA.
*    IF XPSOSEGS-BUZEI NE SY-TABIX.                "Funktioniert hier
*      MESSAGE A105(FQ).                           "nicht
*    ENDIF.
    READ TABLE  YPSOSEGA INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
      XPSOSEGA-KZ = 'I'.
      IF UPD_PSOSEGA IS INITIAL.
        UPD_PSOSEGA = XPSOSEGA-KZ.
      ENDIF.
    ELSEIF XPSOSEGA NE YPSOSEGA.
      XPSOSEGA-KZ = 'U'.
      UPD_PSOSEGA = XPSOSEGA-KZ.
    ELSE.
      CLEAR XPSOSEGA-KZ.
    ENDIF.
    MODIFY XPSOSEGA.
  ENDLOOP.
  LOOP AT XPSOSEGK.
    IF XPSOSEGK-BUZEI NE SY-TABIX.
      MESSAGE A105(FQ).
    ENDIF.
    READ TABLE  YPSOSEGK INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
      XPSOSEGK-KZ = 'I'.
      IF UPD_PSOSEGK IS INITIAL.
        UPD_PSOSEGK = XPSOSEGK-KZ.
      ENDIF.
    ELSEIF XPSOSEGK NE YPSOSEGK.
      XPSOSEGK-KZ = 'U'.
      UPD_PSOSEGK = XPSOSEGK-KZ.
    ELSE.
      CLEAR XPSOSEGK-KZ.
    ENDIF.
    MODIFY XPSOSEGK.
  ENDLOOP.
  LOOP AT XPSOSEGD.
    IF XPSOSEGD-BUZEI NE SY-TABIX.
      MESSAGE A105(FQ).
    ENDIF.
    READ TABLE  YPSOSEGD INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
      XPSOSEGD-KZ = 'I'.
      IF UPD_PSOSEGD IS INITIAL.
        UPD_PSOSEGD = XPSOSEGD-KZ.
      ENDIF.
    ELSEIF XPSOSEGD NE YPSOSEGD.
      XPSOSEGD-KZ = 'U'.
      UPD_PSOSEGD = XPSOSEGD-KZ.
    ELSE.
      CLEAR XPSOSEGD-KZ.
    ENDIF.
    MODIFY XPSOSEGD.
  ENDLOOP.
  LOOP AT XPSOSET.
    READ TABLE YPSOSET INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
      XPSOSET-KZ = 'I'.
      IF UPD_PSOSET IS INITIAL.
        UPD_PSOSET = XPSOSET-KZ.
      ENDIF.
    ELSEIF XPSOSET NE YPSOSET.
      XPSOSET-KZ = 'U'.
      UPD_PSOSET = XPSOSET-KZ.
    ELSE.
      CLEAR XPSOSET-KZ.
    ENDIF.
    MODIFY XPSOSET.
  ENDLOOP.
  DESCRIBE TABLE XPSOSET LINES I.
  DESCRIBE TABLE YPSOSET LINES SY-TABIX.
  IF SY-TABIX GT I.
    LOOP AT YPSOSET.
      IF SY-TABIX GT I.
        YPSOSET-KZ = 'D'.
        IF UPD_PSOSET IS INITIAL.
          UPD_PSOSET = YPSOSET-KZ.
        ENDIF.
        MODIFY YPSOSET.
      ENDIF.
    ENDLOOP.
  ENDIF.
  LOOP AT XPSOSEC.
    CLEAR XPSOSEC-EMPFG.
    MODIFY XPSOSEC.
  ENDLOOP.
  LOOP AT YPSOSEC.
    CLEAR YPSOSEC-EMPFG.
    MODIFY YPSOSEC.
  ENDLOOP.
  LOOP AT XPSOSEC.
    READ TABLE YPSOSEC INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
      XPSOSEC-KZ = 'I'.
      IF UPD_PSOSEC IS INITIAL.
        UPD_PSOSEC = XPSOSEC-KZ.
      ENDIF.
    ELSEIF XPSOSEC NE YPSOSEC.         "im Org. anders: Was richtig?
      XPSOSEC-KZ = 'U'.
      UPD_PSOSEC = XPSOSEC-KZ.
    ELSE.
      CLEAR XPSOSEC-KZ.
    ENDIF.
    MODIFY XPSOSEC.
  ENDLOOP.
  LOOP AT YPSOSEC.
    READ TABLE XPSOSEC INDEX SY-TABIX.
    IF SY-SUBRC NE 0.
      YPSOSEC-KZ = 'D'.
      IF UPD_PSOSEC IS INITIAL.
        UPD_PSOSEC = YPSOSEC-KZ.
      ENDIF.
      MODIFY YPSOSEC.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'PSODAUERAO_WRITE_DOCUMENT'
       EXPORTING
            OBJECTID                = OBJECTID
            TCODE                   = TCODE
            UTIME                   = UTIME
            UDATE                   = UDATE
            USERNAME                = USERNAME
            PLANNED_CHANGE_NUMBER   = PLANNED_CHANGE_NUMBER
            OBJECT_CHANGE_INDICATOR = CDOC_UPD_OBJECT
            PLANNED_OR_REAL_CHANGES = CDOC_PLANNED_OR_REAL
            UPD_PSOKPF              = UPD_PSOKPF
            UPD_PSOSEC              = UPD_PSOSEC
            UPD_PSOSEGA             = UPD_PSOSEGA
            UPD_PSOSEGD             = UPD_PSOSEGD
            UPD_PSOSEGK             = UPD_PSOSEGK
            UPD_PSOSEGS             = UPD_PSOSEGS
            UPD_PSOSET              = UPD_PSOSET
       TABLES
            XPSOKPF                 = XPSOKPF
            YPSOKPF                 = YPSOKPF
            XPSOSEC                 = XPSOSEC
            YPSOSEC                 = YPSOSEC
            XPSOSEGD                = XPSOSEGD
            YPSOSEGD                = YPSOSEGD
            XPSOSEGK                = XPSOSEGK
            YPSOSEGK                = YPSOSEGK
            XPSOSEGS                = XPSOSEGS
            YPSOSEGS                = YPSOSEGS
            XPSOSEGA                = XPSOSEGA
            YPSOSEGA                = YPSOSEGA
            XPSOSET                 = XPSOSET
            YPSOSET                 = YPSOSET.

  CLEAR PLANNED_CHANGE_NUMBER.




ENDFUNCTION.


FORM dauerao_change_fill TABLES   p_p_t_vbkpf_new STRUCTURE vbkpf
                                  p_p_t_vbsec_new STRUCTURE vbsec
                                  p_p_t_vbseg_new STRUCTURE vbseg
                                  p_p_t_vbset_new STRUCTURE vbset
                                  p_xpsokpf STRUCTURE vpsokpf
                                  p_xpsosec STRUCTURE vpsosec
                                  p_xpsosega STRUCTURE vpsosega
                                  p_xpsosegs STRUCTURE vpsosegs
                                  p_xpsosegk STRUCTURE vpsosegk
                                  p_xpsosegd STRUCTURE vpsosegd
                                  p_xpsoset  STRUCTURE vpsoset
                          USING   p_p_t_pso_new STRUCTURE pso02.
 DATA: l_counter LIKE pso02-buzei.

  CLEAR: p_xpsokpf, p_xpsosec, p_xpsosegs.
  REFRESH: p_xpsokpf, p_xpsosec, p_xpsosegs.

  LOOP AT p_p_t_vbkpf_new.
    MOVE-CORRESPONDING p_p_t_vbkpf_new TO p_xpsokpf.
    CLEAR p_xpsokpf-koars.
    LOOP AT p_p_t_vbseg_new.
      CASE p_p_t_vbseg_new-koart.
        WHEN 'A'.
          p_xpsokpf-koars+0(1) = 'A'.
        WHEN 'K'.
          p_xpsokpf-koars+1(1) = 'K'.
        WHEN 'S'.
          p_xpsokpf-koars+2(1) = 'S'.
        WHEN 'B'.
          p_xpsokpf-koars+2(1) = 'S'.
        WHEN 'M'.
          p_xpsokpf-koars+2(1) = 'S'.
        WHEN 'D'.
          p_xpsokpf-koars+3(1) = 'D'.
      ENDCASE.
    ENDLOOP.
    CONDENSE p_xpsokpf-koars NO-GAPS.

*   DAUERANORDNUNGSDATEN:
    p_xpsokpf-dbmon = p_p_t_pso_new-dbmon.
    p_xpsokpf-dbtag = p_p_t_pso_new-dbtag.
    p_xpsokpf-dbbdt = p_p_t_pso_new-dbbdt.
    p_xpsokpf-dbatr = p_p_t_pso_new-dbatr.
    p_xpsokpf-dbedt = p_p_t_pso_new-dbedt.
    p_xpsokpf-xdelt = p_p_t_pso_new-xdelt.
    p_xpsokpf-dbzhl = p_p_t_pso_new-dbzhl.
    p_xpsokpf-dbakz = p_p_t_pso_new-dbakz.
    p_xpsokpf-bstat = p_p_t_pso_new-bstat.

    p_xpsokpf-mandt = sy-mandt.
    p_xpsokpf-lotkz = p_p_t_pso_new-lotkz.
    p_xpsokpf-itabkey = p_p_t_pso_new-itabkey.
    APPEND p_xpsokpf.
  ENDLOOP.

* PSOSEGS fuellen ------------------------------------------------------
  CLEAR l_counter.
  LOOP AT p_p_t_vbseg_new.
    l_counter = l_counter + 1.
    CASE p_p_t_vbseg_new-koart.
      WHEN 'D'.
        MOVE-CORRESPONDING p_p_t_vbseg_new TO p_xpsosegd.
        p_xpsosegd-itabkey = p_p_t_pso_new-itabkey.
        p_xpsosegd-lotkz = p_p_t_pso_new-lotkz.
        p_xpsosegd-bzkey = l_counter.
        p_xpsosegd-mandt = sy-mandt.
        APPEND p_xpsosegd.
      WHEN 'K'.
        MOVE-CORRESPONDING p_p_t_vbseg_new TO p_xpsosegk.
        p_xpsosegk-itabkey = p_p_t_pso_new-itabkey.
        p_xpsosegk-lotkz = p_p_t_pso_new-lotkz.
        p_xpsosegk-bzkey = l_counter.
        p_xpsosegk-mandt = sy-mandt.
        APPEND p_xpsosegk.
      WHEN 'S'.
        MOVE-CORRESPONDING p_p_t_vbseg_new TO p_xpsosegs.
        p_xpsosegs-itabkey = p_p_t_pso_new-itabkey.
        p_xpsosegs-lotkz = p_p_t_pso_new-lotkz.
        p_xpsosegs-bzkey = l_counter.
        APPEND p_xpsosegs.
      WHEN 'A'.
        MOVE-CORRESPONDING p_p_t_vbseg_new TO p_xpsosega.
        p_xpsosega-itabkey = p_p_t_pso_new-itabkey.
        p_xpsosega-lotkz = p_p_t_pso_new-lotkz.
        p_xpsosega-bzkey = l_counter.
        APPEND p_xpsosega.
    ENDCASE.
  ENDLOOP.

* PSOSEC fuellen -------------------------------------------------------
  LOOP AT p_p_t_vbseg_new.
    IF p_p_t_vbseg_new-xcpdd EQ 'X' OR "CPD/Abweich. Zahlungsempf.
       p_p_t_vbseg_new-xzemp EQ 'X'.
      LOOP AT p_p_t_vbsec_new WHERE buzei EQ p_p_t_vbseg_new-buzei.
        MOVE-CORRESPONDING p_p_t_vbsec_new TO p_xpsosec.
        p_xpsosec-bukrs = p_p_t_pso_new-bukrs.
        p_xpsosec-itabkey = p_p_t_pso_new-itabkey.
        p_xpsosec-lotkz = p_p_t_pso_new-lotkz.
        p_xpsosec-mandt = sy-mandt.
        APPEND p_xpsosec.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

* PSOSET fuellen ------------------------------------------------------
  LOOP AT p_p_t_vbset_new.
    MOVE-CORRESPONDING p_p_t_vbset_new  TO p_xpsoset.
    p_xpsoset-bukrs = p_p_t_pso_new-bukrs.
    p_xpsoset-itabkey = p_p_t_pso_new-itabkey.
    p_xpsoset-lotkz = p_p_t_pso_new-lotkz.
    p_xpsoset-mandt = sy-mandt.
    APPEND p_xpsoset.
  ENDLOOP.

ENDFORM.                               " DAUERAO_CHANGE_FILL
