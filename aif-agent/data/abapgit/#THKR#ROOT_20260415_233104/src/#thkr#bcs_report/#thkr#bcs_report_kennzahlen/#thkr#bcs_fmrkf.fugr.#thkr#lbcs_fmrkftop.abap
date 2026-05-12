FUNCTION-POOL /thkr/bcs_fmrkf.              "MESSAGE-ID ..

* INCLUDE /THKR/LBCS_FMRKFD...               " Local class definition

*--------------------------------------------------------------------*
* Includes
*include fmkf_const. -> Include aufgelöst

CONSTANTS: fmkf_bpbyx TYPE bukf_datasource VALUE '0001',
           fmkf_fmtox TYPE bukf_datasource VALUE '0002',
           fmkf_fmfix TYPE bukf_datasource VALUE '0003'.

CONSTANTS: con_applic TYPE bukf_applic VALUE 'ZB',  " 'RP',
           con_true   LIKE boole-boole VALUE 'X'.
*--------------------------------------------------------------------*



* Typdefinitionen
TYPES: BEGIN OF type_kfds,
         keyfig     TYPE bukf_keyfig,
         datasource TYPE bukf_datasource,
         fieldgroup TYPE bukf_fieldgroup,
       END OF type_kfds.

TYPES: type_kfdstab TYPE SORTED TABLE OF type_kfds
                    WITH UNIQUE KEY keyfig datasource.


TYPES: type_dstab TYPE SORTED TABLE OF bukf_dsrc
                  WITH UNIQUE KEY datasource.


TYPES: type_fgtab TYPE SORTED TABLE OF bukf_fg_field
                  WITH UNIQUE KEY datasource fieldgroup fieldname.


TYPES: BEGIN OF type_prog,
         line(72) TYPE c,
       END OF type_prog.

TYPES: type_progtab TYPE STANDARD TABLE OF type_prog.

TYPES: BEGIN OF type_kfform,
         keyfig     TYPE bukf_keyfig,
         datasource TYPE bukf_datasource,
         form1(30)  TYPE c,
         form2(30)  TYPE c,
       END OF type_kfform.

TYPES: type_kfformtab TYPE HASHED TABLE OF type_kfform
                      WITH UNIQUE KEY keyfig datasource.

TYPES: BEGIN OF type_dfies,
         tabname   TYPE tabname,
         fieldname TYPE fieldname,
         position  TYPE tabfdpos,
         leng      TYPE ddleng,
       END OF type_dfies.

TYPES: type_dfiestab TYPE STANDARD TABLE OF type_dfies.

* Globale Daten
DATA: g_t_kfds   TYPE type_kfdstab,
      g_t_ds     TYPE type_dstab,
      g_t_fg     TYPE type_fgtab,
      g_formpool TYPE program.
