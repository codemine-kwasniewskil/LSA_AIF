*----------------------------------------------------------------------*
***INCLUDE FVITXTBAF .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TRANSPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_GT_STXH  text
*----------------------------------------------------------------------*
FORM TRANSPORT TABLES P_P_GT_STXH STRUCTURE STXH.


  TABLES: E071,E071K.

  DATA: TR_E071 LIKE E071 OCCURS 0 WITH HEADER LINE,
        TR_E071K LIKE E071K OCCURS 0 WITH HEADER LINE.
  DATA: CON_LOG_PGMID LIKE E071-PGMID VALUE 'R3TR',
        CON_LOG_OBJ  LIKE  E071-OBJECT VALUE 'TEXT'.
  DATA: TR_TASK LIKE E071-TRKORR.

* Vergabe einer Auftragnummer

CALL FUNCTION 'RE_CLDP_TRANSPORT_OPEN'
    EXPORTING
         I_CATEG = 'SYST'
    IMPORTING
         TRKORR  = TR_TASK
    EXCEPTIONS
         CANCEL  = 1
         OTHERS  = 2
          .
IF SY-SUBRC <> 0.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

  REFRESH: TR_E071, TR_E071K.
  CLEAR:   TR_E071, TR_E071K.
  TR_E071-TRKORR = TR_E071K-TRKORR = TR_TASK.
  TR_E071-AS4POS = TR_E071K-AS4POS = 0.
  TR_E071-PGMID  = TR_E071K-PGMID  = 'R3TR'.
  TR_E071-OBJECT = TR_E071K-OBJECT = 'TEXT'.
  LOOP AT P_P_GT_STXH.
    TR_E071-AS4POS = TR_E071-AS4POS + 1.
    PERFORM BUILD_TEXTKEY USING P_P_GT_STXH-TDOBJECT
                                P_P_GT_STXH-TDNAME
                                P_P_GT_STXH-TDID
                                P_P_GT_STXH-TDSPRAS
                                TR_E071
                                TR_E071K.
    APPEND TR_E071.
  ENDLOOP.
CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
     EXPORTING
*         WI_SIMULATION                  = ' '
*         WI_SUPPRESS_KEY_CHECK          = ' '
          WI_TRKORR                      = TR_TASK
     TABLES
          WT_E071                        = TR_E071
          WT_E071K                       = TR_E071K
    EXCEPTIONS
         KEY_CHAR_IN_NON_CHAR_FIELD     = 1
         KEY_CHECK_KEYSYNTAX_ERROR      = 2
         KEY_INTTAB_TABLE               = 3
         KEY_LONGER_FIELD_BUT_NO_GENERC = 4
         KEY_MISSING_KEY_MASTER_FIELDS  = 5
         KEY_MISSING_KEY_TABLEKEY       = 6
         KEY_NON_CHAR_BUT_NO_GENERIC    = 7
         KEY_NO_KEY_FIELDS              = 8
         KEY_STRING_LONGER_CHAR_KEY     = 9
         KEY_TABLE_HAS_NO_FIELDS        = 10
         KEY_TABLE_NOT_ACTIV            = 11
         KEY_UNALLOWED_KEY_FUNCTION     = 12
         KEY_UNALLOWED_KEY_OBJECT       = 13
         KEY_UNALLOWED_KEY_OBJNAME      = 14
         KEY_UNALLOWED_KEY_PGMID        = 15
         KEY_WITHOUT_HEADER             = 16
         OB_CHECK_OBJ_ERROR             = 17
         OB_DEVCLASS_NO_EXIST           = 18
         OB_EMPTY_KEY                   = 19
         OB_GENERIC_OBJECTNAME          = 20
         OB_ILL_DELIVERY_TRANSPORT      = 21
         OB_ILL_LOCK                    = 22
         OB_ILL_PARTS_TRANSPORT         = 23
         OB_ILL_SOURCE_SYSTEM           = 24
         OB_ILL_SYSTEM_OBJECT           = 25
         OB_ILL_TARGET                  = 26
         OB_INTTAB_TABLE                = 27
         OB_LOCAL_OBJECT                = 28
         OB_LOCKED_BY_OTHER             = 29
         OB_MODIF_ONLY_IN_MODIF_ORDER   = 30
         OB_NAME_TOO_LONG               = 31
         OB_NO_APPEND_OF_CORR_ENTRY     = 32
         OB_NO_APPEND_OF_C_MEMBER       = 33
         OB_NO_CONSOLIDATION_TRANSPORT  = 34
         OB_NO_ORIGINAL                 = 35
         OB_NO_SHARED_REPAIRS           = 36
         OB_NO_SYSTEMNAME               = 37
         OB_NO_SYSTEMTYPE               = 38
         OB_NO_TADIR                    = 39
         OB_NO_TADIR_NOT_LOCKABLE       = 40
         OB_PRIVAT_OBJECT               = 41
         OB_REPAIR_ONLY_IN_REPAIR_ORDER = 42
         OB_RESERVED_NAME               = 43
         OB_SYNTAX_ERROR                = 44
         OB_TABLE_HAS_NO_FIELDS         = 45
         OB_TABLE_NOT_ACTIV             = 46
         TR_ENQUEUE_FAILED              = 47
         TR_ERRORS_IN_ERROR_TABLE       = 48
         TR_ILL_KORRNUM                 = 49
         TR_LOCKMOD_FAILED              = 50
         TR_LOCK_ENQUEUE_FAILED         = 51
         TR_NOT_OWNER                   = 52
         TR_NO_SYSTEMNAME               = 53
         TR_NO_SYSTEMTYPE               = 54
         TR_ORDER_NOT_EXIST             = 55
         TR_ORDER_RELEASED              = 56
         TR_ORDER_UPDATE_ERROR          = 57
         TR_WRONG_ORDER_TYPE            = 58
         OB_INVALID_TARGET_SYSTEM       = 59
         TR_NO_AUTHORIZATION            = 60
         OB_WRONG_TABLETYP              = 61
         OB_WRONG_CATEGORY              = 62
         OB_SYSTEM_ERROR                = 63
         OB_UNLOCAL_OBJEKT_IN_LOCAL_ORD = 64
         TR_WRONG_CLIENT                = 65
         OB_WRONG_CLIENT                = 66
         KEY_WRONG_CLIENT               = 67
         OTHERS                         = 68
          .
IF SY-SUBRC = 0.
 MESSAGE S104(69) WITH TR_E071-TRKORR.
ELSE.
 MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

ENDFORM.                               " TRANSPORT
*&---------------------------------------------------------------------*
*&      Form  BUILD_TEXTKEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_P_GT_STXH_TDOBJNAME  text
*      -->P_P_P_GT_STXH_TDNAME  text
*      -->P_P_P_GT_STXH_TDID  text
*      -->P_P_P_GT_STXH_TDSPRAS  text
*      -->P_TR_E071  text
*      -->P_TR_E071K  text
*----------------------------------------------------------------------*
FORM BUILD_TEXTKEY USING    OBJECT
                            NAME
                            ID
                            SPRAS
                            TR_E071 LIKE E071
                            TR_E071K LIKE E071K.
  DATA: TEXTKEY LIKE E071-OBJ_NAME,
        LEN TYPE I.
  FIELD-SYMBOLS: <P>.

  TEXTKEY = '%,$,%,%'.
  REPLACE '%' WITH OBJECT INTO TEXTKEY.
  REPLACE '%' WITH ID     INTO TEXTKEY.
  REPLACE '%' WITH SPRAS  INTO TEXTKEY.
  CONDENSE TEXTKEY NO-GAPS.
  LEN = STRLEN( NAME ).
  ASSIGN NAME(LEN) TO <P>.
  REPLACE '$' WITH <P> INTO TEXTKEY.
  TR_E071-OBJ_NAME = TEXTKEY.

ENDFORM.                               " BUILD_TEXTKEY
