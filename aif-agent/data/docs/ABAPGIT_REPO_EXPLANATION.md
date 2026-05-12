# abapGit Repository Explanation: `#THKR#AIF_20260408_234400`

## Overview

This folder is an **abapGit export** of ABAP development objects from an SAP system. abapGit is an open-source git client for SAP ABAP that serializes ABAP repository objects into text files (XML + `.abap` source) that can be stored in a git repository.

- **Repository name**: `LSA_AIF`
- **Export timestamp**: 2026-04-08 23:44:00
- **SAP namespace**: `/THKR/` (customer namespace for Thüringen/Saxony-Anhalt state government, owned by T-Systems)
- **Total files**: 756 (424 XML metadata + 324 ABAP source + 4 CDS baseinfo + 4 CDS `.asddls`)
- **Starting folder**: `/src/`
- **Folder logic**: `PREFIX` — subfolders are derived from the object name prefix

---

## Repository Root Files

### `.abapgit.xml`
abapGit project configuration file. Contains:
- `NAME` — repository name (`LSA_AIF`)
- `MASTER_LANGUAGE` — the primary language for text elements (`E` = English)
- `STARTING_FOLDER` — root of the ABAP objects (`/src/`)
- `FOLDER_LOGIC` — how subfolders are determined (`PREFIX` = based on package/prefix)

---

## Source Tree Structure (`src/`)

```
src/
├── #thkr#.nspc.xml          ← namespace registration
├── fremdv/                  ← FREMDV package: foreign system interfaces (main)
├── havweb/                  ← HAVWEB package: budget plan interfaces
├── poli/                    ← POLI package: police-specific objects
└── zallge/                  ← ZALLGE package: general/shared utilities
```

---

## File Types and Extensions

abapGit uses a compound filename pattern:
```
#thkr#<object_name>.<object_type>.<component>
```

All names use lowercase on disk even though SAP stores them uppercase. The `#thkr#` prefix corresponds to the SAP namespace `/THKR/`.

### `.nspc.xml` — Namespace Registration
**SAP object type**: `NSPC`
**Serializer**: `LCL_OBJECT_NSPC`

Registers the customer namespace `/THKR/` in the SAP system. Contains:
- `NAMESPACE` — the namespace string (`/THKR/`)
- `NSPC_TEXTS` — multilingual description and owner info (language `D` = German: "HKR Land Sachsen-Anhalt", owner: T-Systems)

One file per namespace at the top of `src/`.

---

### `.fugr.xml` — Function Group Metadata
**SAP object type**: `FUGR`
**Serializer**: `LCL_OBJECT_FUGR`

Defines a **function group** (a container for related function modules, the classic ABAP modularization unit before OO-ABAP). Contains:
- `INCLUDES` — list of include programs that belong to the function group
- `FUNCTIONS` — array of function module definitions with full interface:
  - `FUNCNAME` — full qualified name (e.g., `/THKR/AIF_FREMDV_ACT_DEL_ED_0`)
  - `IMPORT` / `EXPORT` / `CHANGING` / `TABLES` — parameter definitions with type references
  - `DOCUMENTATION` — parameter documentation entries

Each `<item>` in `FUNCTIONS` corresponds to one `.abap` source file in the same directory.

**Function groups in this repo and their roles:**

| Function Group | Purpose |
|---|---|
| `#thkr#aif_fremdv_act` | **Actions** — business logic executed per AIF message line (write FI documents, delete, forward) |
| `#thkr#aif_fremdv_chk` | **Checks** — validation functions for IST-Rückmeldung (actuals feedback) |
| `#thkr#aif_fremdv_map` | **Value/field mappings** — value mapping (VMAP) and aggregate mapping (AMAP) functions |
| `#thkr#aif_fremdv_rueck` | **Rückmeldung** (outbound feedback) — sends actuals back to foreign systems |
| `#thkr#aif_fremdv_serid` | **Serialization ID** — assigns unique serial IDs to inbound messages |
| `#thkr#aif_fremdv_ifdef` | **Interface definition init** — FUBA_INIT functions that initialize AIF interface processing |
| `#thkr#aif_fremdv_edas` | **EDAS-specific** — payment receipt and protocol processing for EDAS (Einwohner-Datenaustausch-System) |
| `#thkr#aif_havweb_act` | **HAVWEB actions** — budget plan XML file processing |
| `#thkr#aif_havweb_map` | **HAVWEB mappings** — field/aggregate mappings for budget interfaces |

---

### `.fugr.<funcname>.abap` — Function Module Source
**Content**: Plain ABAP code starting with `FUNCTION /THKR/...` and ending with `ENDFUNCTION.`

Each function module in the `.fugr.xml` has exactly one corresponding `.abap` file named after it. This is the actual business logic:

```
#thkr#aif_fremdv_act.fugr.#thkr#aif_fremdv_act_del_ed_0.abap
                      ^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      group  function module name
```

Common patterns in function module names:
- `ACT_WRT_*` — write/post functions (post FI documents)
- `ACT_DEL_*` — delete/cancel functions
- `ACT_FWD_*` — forward/pass-through functions
- `VMAP_*` — value mapping functions (called by AIF field mapping)
- `AMAP_*` — aggregate mapping functions
- `CHK_*` — check/validation functions

---

### `.fugr.L<FUGNAME>TOP.abap` + `.fugr.L<FUGNAME>TOP.xml` — Function Group TOP Include
The TOP include holds the function group's **global data declarations** (global variables, type definitions, constants shared by all function modules in the group).

Naming pattern: `L` + function group name (without `/THKR/` prefix, abbreviated) + `TOP`
Example: `#thkr#laif_fremdv_acttop.abap` for function group `/THKR/AIF_FREMDV_ACT`

The `.xml` companion holds include program metadata (program properties).

---

### `.fugr.SAPL<FUGNAME>.abap` + `.fugr.SAPL<FUGNAME>.xml` — Function Group Main Include
The SAPL* include is the **top-level include** generated by SAP that pulls together all sub-includes. In abapGit it usually just contains `INCLUDE` statements.

---

### `.tabl.xml` — Transparent Table / Structure Definition
**SAP object type**: `TABL`
**Serializer**: `LCL_OBJECT_TABL`

Defines a DDIC (Data Dictionary) object — either a **transparent database table** or a **flat structure**. Contains:
- `DD02V` — table header: `TABNAME`, `TABCLASS` (`TRANSP`=transparent table, `INTTAB`=structure), `DDTEXT` (description)
- `DD09L` — technical settings: storage category, buffering settings
- `DD03P_TABLE` — field definitions (array of `DD03P`):
  - `FIELDNAME` — field name
  - `KEYFLAG` — `X` if primary key field
  - `ROLLNAME` — data element (type reference)
  - `COMPTYPE` — component type (`E`=element, `S`=structure include)
- `I18N_LANGS` / `DD02_TEXTS` — multilingual descriptions

**Naming conventions for tables in this repo:**

| Pattern | Purpose |
|---|---|
| `/THKR/MI_xxxxyyy` | AIF **Multi-Index table** — stores multi-index key fields per message (one per interface direction); `xxxx`=interface ID, `yyy`=version |
| `/THKR/SI_xxxxyyy` | AIF **Search-Index table** — similar to MI, stores additional index/search keys |
| `/THKR/S_AIF_*` | DDIC **structures** (INTTAB) — flat structures used as AIF message payload types (DDICSTRUCTURE in AIF config) |
| `/THKR/S_AIF_SAP_RUECK_*` | Structures for the IST-Rückmeldung (actuals feedback) per receiver system |

---

### `.dtel.xml` — Data Element Definition
**SAP object type**: `DTEL`
**Serializer**: `LCL_OBJECT_DTEL`

Defines a **data element** (reusable type descriptor used in DDIC structures/tables). Contains:
- `DD04V` — element properties: `ROLLNAME` (technical name), `DATATYPE` (CHAR/NUMC/DEC/etc.), `LENG` (length), `OUTPUTLEN`, label lengths
- `DD04_TEXTS` — multilingual field labels: `DDTEXT` (description), `REPTEXT` (column header), `SCRTEXT_S/M/L` (screen labels short/medium/long)

BIC-prefixed data elements (`/THKR/BIC_*`) represent **BIC key fields** (Buchungsidentifikationscode = booking identification code used by external cash systems like SolumStar/BIC).

---

### `.doma.xml` — Domain Definition
**SAP object type**: `DOMA`
**Serializer**: `LCL_OBJECT_DOMA`

Defines a **domain** — the technical data type and value range (fixed values list) that data elements reference. Contains:
- `DD01V` — domain properties: data type, length, output length
- `DD07V_TABLE` — fixed values (value list with descriptions)

---

### `.prog.abap` — ABAP Program (Report) Source
**SAP object type**: `PROG`

Plain ABAP source code for a standalone report or include program. In this repo:
- `/THKR/AIF_SELSCR_xxxxyyy` — **Selection screen programs** used by AIF for custom selection criteria on interface `xxxx` version `yyy`
- `/THKR/R_SEND_IST_RUECK*` — **IST-Rückmeldung report** — the main outbound program that reads SAP actuals and sends them back to foreign systems
- `/THKR/POLIZEI`, `/THKR/EDAS_ZPPROT` — standalone utility/interface programs

---

### `.prog.xml` — ABAP Program Metadata
Companion XML for each `.prog.abap`. Contains:
- `PROGDIR` — program properties: `NAME`, `SUBC` (program type: `1`=executable, `I`=include, `F`=function pool), `UCCHECK` (Unicode check)
- `I18N_TPOOL` — text pool (text symbols, selection texts, report title)

---

### `.prog.screen_NNNN.abap` — Screen Flow Logic
Screen flow logic (PBO/PAI events) for programs with screen dialogs. Named with screen number suffix.

---

### `.clas.abap` — ABAP Class Source
**SAP object type**: `CLAS`

Object-oriented ABAP class source. In this repo: `/THKR/CL_AIF_RUECK` — the OO encapsulation of the IST-Rückmeldung (actuals outbound) logic.

---

### `.clas.xml` — ABAP Class Metadata
Class definition metadata (class properties, interface implementations, method signatures).

---

### `.xslt.xml` — XSLT Transformation Metadata
**SAP object type**: `XSLT`
**Serializer**: `LCL_OBJECT_XSLT`

Metadata for an SAP **XSLT transformation object** used to convert between XML and ABAP internal formats. Contains the transformation name and properties.

In this repo:
- `/THKR/ABAP_TO_BRUECKE_IST` — converts ABAP structure → Brücke XML (outbound to cash system)
- `/THKR/BRUECKE_AO_TO_ABAP` — converts Brücke XML → ABAP structure (inbound from cash system)

("Brücke" = bridge system — an intermediary cash/payment system.)

---

### `.xslt.source.xml` — XSLT Transformation Source
The actual **XSLT stylesheet** (the transformation rules), stored as XML. This is the human-readable transformation logic — you can read the XSL templates to understand the field-level mapping between XML and ABAP structures.

---

### `.ddls.asddls` — CDS View Source
**SAP object type**: `DDLS` (Data Definition Language Source)

ABAP CDS (Core Data Services) view definition written in ABAP SQL / CDS syntax. These are analytical views over SAP financial and AIF data:
- `/THKR/CDS_AIF_IST_RM_CUBE` — analytics cube view for IST-Rückmeldung (actuals sent)
- `/THKR/CDS_AIF_IST_RM_IBAN` — IBAN data for actuals
- `/THKR/CDS_AIF_IST_RM_SEL` — selection helper for actuals reporting
- `/THKR/CDS_AIF_MI_UNION_IST_RM` — union view combining MI table data across interface versions

---

### `.ddls.baseinfo` — CDS View Base Info
Small companion file with baseline CDS object metadata (activation state, etc.).

---

### `.ddls.xml` — CDS View Metadata
Metadata XML for the CDS view (description, annotations, version).

---

### `.ttyp.xml` — Table Type Definition
**SAP object type**: `TTYP`

Defines an internal table type in the DDIC (used as parameter types in function modules or class methods). Example: `/THKR/ADR_LSM0_TAB` — a table type for address data.

---

### `.tran.xml` — Transaction Code Definition
**SAP object type**: `TRAN`
**Serializer**: `LCL_OBJECT_TRAN`

Defines a SAP **transaction code** (T-code) that users execute. Contains:
- `TSTC` — transaction: `TCODE` (the code), `PGMNA` (program it calls), `DYPNO` (initial screen)
- `I18N_TPOOL/TSTCT` — multilingual transaction description

In this repo: `/THKR/R_SEND_IST_RUE` → starts program `/THKR/R_SEND_IST_RUECK` (IST-Rückmeldung report).

---

### `package.devc.xml` — Package Definition
**SAP object type**: `DEVC`

Defines an SAP **development package** (formerly called "development class"). Packages organize ABAP objects into logical groups corresponding to the subfolder.

---

## Subfolder Organization

### `src/fremdv/` — FREMDV Package (Main)
The primary development package containing ~95% of all objects. "Fremdv" = "Fremdsystem-Verarbeitung" (foreign system processing). This is the core AIF integration layer for all external specialist systems connecting to SAP FI/PSM.

**Contents:**
- **8 function groups** — actions, checks, mappings, feedback, serialization, interface init, EDAS-specific
- **~70 TABL objects** — MI/SI index tables (one pair per interface direction), S_AIF_* structures for message payloads and feedback structures
- **5 programs** — selection screen programs per interface, IST-Rückmeldung report and variants
- **4 CDS views** — analytics over actuals data
- **2 XSLT transformations** — XML↔ABAP conversion for Brücke cash system
- **Data elements and domains** — BIC key fields (HHJ, KASSZ, URKASS, AKTZ, BELNR, GENNR), IST-Rückmeldung type, Hamissa status
- **1 ABAP class** — `/THKR/CL_AIF_RUECK` for outbound feedback OO layer
- **1 transaction** — `/THKR/R_SEND_IST_RUE`

### `src/havweb/` — HAVWEB Package
Interfaces for the **HAVWEB** (Haushaltsplan Web = budget plan web portal). Contains:
- Function groups for actions (`aif_havweb_act`) and mappings (`aif_havweb_map`)
- MI/SI index tables for budget plan interfaces
- Supporting structures and data elements

### `src/poli/` — POLI Package
A nearly empty **police (Polizei) specific** sub-package. Contains only a `package.devc.xml` — the actual police interface objects are in `fremdv/` (the `aif_fremdv_ifdef` function group has `aif_ifdef_pol_rko_*` function modules, and `mi_0001001.tabl.xml` is described as "für Polizei"/"für SolumStar").

### `src/zallge/` — ZALLGE Package
**General/shared utilities** ("allgemein" = general). Contains:
- Standalone diagnostic and analysis programs (`aif_analyse`, `aif_analyse_polizei`, `aif_bkpf_tool`, `aif_msg_read`)
- Data elements and domains shared across packages
- A field mapping inspection program (`aif_qs_t_fmap`)
- Transaction codes for the utility programs

---

## abapGit File Naming Rules

| Pattern | Meaning |
|---|---|
| `#thkr#` prefix | Corresponds to SAP namespace `/THKR/` — abapGit lowercases names and replaces `/` with `#` |
| `.fugr.xml` | Function group metadata |
| `.fugr.<name>.abap` | One function module's source code |
| `.fugr.l<name>top.abap` | Function group TOP include (global declarations) |
| `.fugr.sapl<name>.abap` | Function group main include |
| `.tabl.xml` | Transparent table or structure |
| `.dtel.xml` | Data element |
| `.doma.xml` | Domain |
| `.prog.abap` | ABAP program source |
| `.prog.xml` | ABAP program metadata + text pool |
| `.prog.screen_NNNN.abap` | Screen flow logic |
| `.clas.abap` | ABAP class source |
| `.clas.xml` | ABAP class metadata |
| `.xslt.xml` | XSLT transformation metadata |
| `.xslt.source.xml` | XSLT stylesheet (actual transformation rules) |
| `.ddls.asddls` | CDS view source (ABAP SQL) |
| `.ddls.baseinfo` | CDS base info |
| `.ddls.xml` | CDS view metadata |
| `.ttyp.xml` | Table type |
| `.tran.xml` | Transaction code |
| `package.devc.xml` | Package definition |
| `.nspc.xml` | Namespace registration |

**Key decoding rule**: Replace `#` with `/` and uppercase to get the SAP object name.
Example: `#thkr#aif_fremdv_act.fugr.#thkr#aif_fremdv_act_del_ed_0.abap`
→ Function module `/THKR/AIF_FREMDV_ACT_DEL_ED_0` in function group `/THKR/AIF_FREMDV_ACT`

---

## How to Read a Specific Interface's Code

For an interface like `FREMDV / I_0001 / 001` (inbound interface #1):

1. **Structure definition**: `src/fremdv/#thkr#mi_0001001.tabl.xml` — the AIF multi-index table defines which fields are searchable key fields
2. **Message payload structure**: Look for `S_AIF_*` structures referenced in `aif_t_finf.xlsx` (DDICSTRUCTURE column)
3. **Action functions**: In `aif_t_ifact.xlsx` → `aif_t_func.xlsx` → find the function module name → read its `.abap` file in `#thkr#aif_fremdv_act.fugr.*.abap`
4. **Value mappings**: `src/fremdv/#thkr#aif_fremdv_map.fugr.#thkr#aif_vmap_*.abap`
5. **Checks**: `src/fremdv/#thkr#aif_fremdv_chk.fugr.*.abap`
6. **Interface init**: `src/fremdv/#thkr#aif_fremdv_ifdef.fugr.#thkr#aif_ifdef_*_init.abap`
7. **Selection screen**: `src/fremdv/#thkr#aif_selscr_0001_001.prog.abap`

---

## Agent Prompt / Instructions

> Use the following as a system prompt or briefing when asking an AI agent to analyze this repository.

---

### AGENT SYSTEM PROMPT: SAP abapGit Repository Analyst

You are a **senior SAP ABAP developer and SAP AIF (Application Interface Framework) specialist** analyzing an abapGit repository export. This repository represents custom development for a **German state government SAP system** (Thüringen / Saxony-Anhalt state, namespace `/THKR/`, owner T-Systems).

#### Repository Location
`#THKR#AIF_20260408_234400/` — abapGit export of package `LSA_AIF`, exported 2026-04-08.

#### abapGit File System Conventions
- All SAP object names are **lowercased** on disk and the `/` in namespace is replaced with `#`
- To get the SAP name: replace `#thkr#` → `/THKR/`, uppercase everything
- Compound filename: `<namespace><objectname>.<objecttype>.<component>`
- Each function module has its own `.abap` file alongside the `.fugr.xml` metadata
- XML files are metadata/schema; `.abap` files are the actual source code

#### Object Type Quick Reference
| Extension | SAP Type | What it is |
|---|---|---|
| `.fugr.xml` | FUGR | Function group — lists all function modules and their signatures |
| `.fugr.<name>.abap` | FUGR | One function module's ABAP source |
| `.fugr.l*top.abap` | FUGR | Function group global data (TOP include) |
| `.tabl.xml` | TABL | Transparent table or flat structure — read `DD03P_TABLE` for fields |
| `.dtel.xml` | DTEL | Data element — read `DD04V` for type, `DD04_TEXTS` for labels |
| `.doma.xml` | DOMA | Domain — fixed values and data type |
| `.prog.abap` | PROG | ABAP report/program source |
| `.prog.xml` | PROG | Program metadata + text symbols |
| `.clas.abap` | CLAS | ABAP OO class source |
| `.xslt.source.xml` | XSLT | XSLT stylesheet — actual transformation rules |
| `.ddls.asddls` | DDLS | CDS view — ABAP SQL analytics view |
| `.ttyp.xml` | TTYP | Internal table type |
| `.tran.xml` | TRAN | Transaction code |
| `package.devc.xml` | DEVC | Package definition |

#### Subfolder = SAP Package
| Folder | SAP Package | Domain |
|---|---|---|
| `src/fremdv/` | FREMDV | Foreign system interfaces (main AIF package — all inbound/outbound) |
| `src/havweb/` | HAVWEB | Budget plan (Haushaltsplan) web interfaces |
| `src/poli/` | POLI | Police sub-package (mostly empty, objects are in fremdv) |
| `src/zallge/` | ZALLGE | General utilities and diagnostic tools |

#### AIF-Specific Object Naming
| Object name pattern | Purpose |
|---|---|
| `/THKR/MI_xxxxyyy` | AIF Multi-Index table for interface `xxxx` version `yyy` — stores key fields per message for indexing and duplicate prevention |
| `/THKR/SI_xxxxyyy` | AIF Search-Index table — additional searchable key fields |
| `/THKR/S_AIF_*` | DDIC structure used as AIF message payload (DDICSTRUCTURE) |
| `/THKR/AIF_FREMDV_ACT_*` | AIF **action** function modules — execute business logic (post FI documents, delete, forward) |
| `/THKR/AIF_FREMDV_CHK_*` | AIF **check** function modules — validate message data |
| `/THKR/AIF_?MAP_*` | AIF **mapping** function modules — VMAP (value map) or AMAP (aggregate map) |
| `/THKR/AIF_SELSCR_xxxxyyy` | **Selection screen** program for interface `xxxx` version `yyy` |
| `/THKR/R_SEND_IST_RUECK*` | IST-Rückmeldung (actuals outbound) report |
| `/THKR/CDS_AIF_*` | CDS analytics views over AIF and FI data |

#### Interface Naming Convention (from AIF config)
- `I_xxxx_yyy` = **Inbound** — foreign system → SAP (e.g., `I_0001_001`)
- `O_xxxx_yyy` = **Outbound** — SAP → foreign system (actuals feedback, e.g., `O_0001_002`)
- `xxxx` = 4-digit interface ID (inbound and outbound with same ID are paired)
- `yyy` = sub-type (`001` = primary inbound, `002` = actuals outbound, `003/004` = additional outbound)

#### How to Find Code for a Specific Interface
1. **Identify interface** from `aif_t_finf_de.xlsx` by NS+IFNAME+IFVERSION → get DDICSTRUCTURE, FUBA_CHECK, FUBA_INIT
2. **Find ABAP source**: search in `src/fremdv/` for files matching the function module name (replace `/THKR/` → `#thkr#`, lowercase)
3. **Read `.fugr.xml`** to see all function modules and their parameter signatures
4. **Read `.abap` files** for the actual business logic
5. **Read `.tabl.xml`** for the MI/SI table structure (key fields used for duplicate check / AIF index)
6. **Read `.xslt.source.xml`** for XML↔ABAP field-level transformation rules

#### Business Context
This is a **German public administration financial system** (Kommunales Haushaltswesen). The AIF interfaces integrate external specialist systems (police, city authorities, budget systems, EDAS payment system) into SAP FI/PSM-FM:
- **Inbound**: External systems send payment/order data → AIF processes → posts to SAP FI
- **Outbound (IST-Rückmeldung)**: SAP reads actual posted values → sends back to external systems as confirmation
- **Brücke**: An intermediary XML-based cash/payment system with its own XML format (handled via XSLT)
- **BIC** (Buchungsidentifikationscode): The key correlation ID used by the cash systems (SolumStar, BIC)
- **German terminology**: Kassenzeichen=cash reference, Haushaltsjahr=fiscal year, Rückmeldung=feedback, Fremdv=foreign system processing

#### Analysis Approach
When asked to analyze an interface or function module:
1. State the **purpose** in business terms (what data flows, from/to where)
2. Describe the **data structure** (key fields from MI table, payload from S_AIF_* structure)
3. Explain the **processing steps** (init → check → mapping → action sequence)
4. Show **key ABAP logic** (summarize critical code sections, not just list them)
5. Note any **external dependencies** (SAP standard BAPIs called, FI posting FMs used)
