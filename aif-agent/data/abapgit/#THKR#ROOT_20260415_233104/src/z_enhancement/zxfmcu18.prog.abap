*&---------------------------------------------------------------------*
*& Include          ZXFMCU18
*&---------------------------------------------------------------------*

 "Workflow immer starten, egal welches Feld geändert wird.

 IF new_kblk-wf_start = 'X'.
   IF new_kblk-fexec = 'X'.
     IF old_kblk-fexec IS INITIAL.
       wf_restart = 'X'.
     ENDIF.
   ENDIF.

   IF new_kblk-ktext <> old_kblk-ktext.
       wf_restart = 'X'.
   ENDIF.

   IF new_kblk-xblnr <> old_kblk-xblnr.
       wf_restart = 'X'.
   ENDIF.





   IF wf_restart IS INITIAL.
     LOOP AT new_kbld ASSIGNING FIELD-SYMBOL(<lf_kbld>).
       READ TABLE old_kblp
                WITH KEY belnr = <lf_kbld>-belnr
                 blpos = <lf_kbld>-blpos
                 ASSIGNING FIELD-SYMBOL(<lf_kblp>).
       IF sy-subrc = 0.
         IF <lf_kbld>-erlkz = 'X'.
           IF <lf_kblp>-erlkz IS INITIAL.
             wf_restart = 'X'.
             EXIT.
           ENDIF.
         ENDIF.
         "Positionstext
         IF <lf_kbld>-ptext <> <lf_kblp>-ptext OR
           <lf_kbld>-fkber <> <lf_kblp>-fkber OR
           <lf_kbld>-measure <> <lf_kblp>-measure OR
           <lf_kbld>-saknr <> <lf_kblp>-saknr OR
           <lf_kbld>-gsber <> <lf_kblp>-gsber OR
           <lf_kbld>-kostl <> <lf_kblp>-kostl OR
           <lf_kbld>-aufnr <> <lf_kblp>-aufnr OR
           <lf_kbld>-lifnr <> <lf_kblp>-lifnr OR
           <lf_kbld>-refreserv <> <lf_kblp>-refbelnr OR
           <lf_kbld>-refrespos <> <lf_kblp>-refblpos OR
           <lf_kbld>-fdatk <> <lf_kblp>-fdatk OR
           <lf_kbld>-refseterlk <> <lf_kblp>-refseterlk OR
           <lf_kbld>-blpkz <> <lf_kblp>-blpkz OR
           <lf_kbld>-lnrza <> <lf_kblp>-lnrza
           .
           wf_restart = 'X'.
           EXIT.
         ENDIF.

       ELSE."Wenn keine alte Position da.
         wf_restart = 'X'.
         EXIT.

       ENDIF.
     ENDLOOP.

   ENDIF.

   IF wf_restart = 'X'.

     LOOP AT new_kbld ASSIGNING <lf_kbld>.

       CLEAR <lf_kbld>-wkapp.

     ENDLOOP.

   ENDIF.


 ENDIF.
